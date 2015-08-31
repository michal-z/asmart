struct sphere4_t
{
  float4 x;
  float4 y;
  float4 z;
  float4 r;
  float4 red;
  float4 green;
  float4 blue;
};

struct light_t
{
  float4 position;
  float4 color_intensity;
};

static const float k_normal_eps = 0.001f;
static const float k_hit_eps = 0.002f;
static const float k_view_distance = 20.0f;


RWTexture2D<float2> uav_raymarch_texture : register(u0);
RWStructuredBuffer<uint> uav_atomic_counter : register(u1);
Texture2D<float2> srv_raymarch_texture : register(t0);

cbuffer cbv_frame_info : register(b0)
{
  sphere4_t cbv_sphere[2];
  float3 cbv_eye_position;
  float3 cbv_eye_target;
  light_t cbv_light[3];
};

void generate_ray(in float2 screen_coord,
                  in float3 eye_position,
                  in float3 eye_target,
                  out float3 ro,
                  out float3 rd)
{
  float3 iz = normalize(eye_position - eye_target);
  float3 ix = normalize(cross(float3(0.0f, 1.0f, 0.0f), iz));
  float3 iy = normalize(cross(iz, ix));

  float2 pn = float2(screen_coord.x - 512.0f, 512.0f - screen_coord.y) / float2(511.5f, 511.5f);

  ro = eye_position;
  rd = normalize(pn.x * ix + pn.y * iy - 1.5f * iz);
}

float sphere_distance(float3 p, float4 sphere)
{
  return distance(p, sphere.xyz) - sphere.w;
}

float2 nearest_object(float3 p)
{
  float2 obj[2];
  float4 s;

  s = float4(cbv_sphere[0].x[0], cbv_sphere[0].y[0], cbv_sphere[0].z[0], cbv_sphere[0].r[0]);
  obj[0].x = sphere_distance(p, s);
  obj[0].y = 0.0f;

  for (int i = 1;
       i < 8;
       ++i)
  {
    int idx0 = i >> 2;
    int idx1 = i & 0x3;
    s = float4(cbv_sphere[idx0].x[idx1], cbv_sphere[idx0].y[idx1], cbv_sphere[idx0].z[idx1], cbv_sphere[idx0].r[idx1]);
    obj[1].x = sphere_distance(p, s);
    obj[1].y = (float)i;

    if (obj[1].x < obj[0].x) obj[0] = obj[1];
  }

  obj[1].x = p.y + 2.0f;
  obj[1].y = 3.0f;

  if (obj[1].x < obj[0].x) obj[0] = obj[1];

  return obj[0];
}

float4 vs_full_triangle(uint id : SV_VertexID) : SV_Position
{
  float2 verts[] = { float2(-1.0f, -1.0f), float2(3.0f, -1.0f), float2(-1.0f, 3.0f) };
  return float4(verts[id], 0.0f, 1.0f);
}

float3 compute_normal(float3 p)
{
  float xpos = nearest_object(float3(p.x + k_normal_eps, p.y, p.z)).x;
  float xneg = nearest_object(float3(p.x - k_normal_eps, p.y, p.z)).x;
  float ypos = nearest_object(float3(p.x, p.y + k_normal_eps, p.z)).x;
  float yneg = nearest_object(float3(p.x, p.y - k_normal_eps, p.z)).x;
  float zpos = nearest_object(float3(p.x, p.y, p.z + k_normal_eps)).x;
  float zneg = nearest_object(float3(p.x, p.y, p.z - k_normal_eps)).x;
  return normalize(float3(xpos - xneg, ypos - yneg, zpos - zneg));
}

float4 ps_shade(float4 position : SV_Position) : SV_Target0
{
  float4 color = float4(0.2f, 0.2f, 0.2f, 0.2f);
  float2 obj = srv_raymarch_texture[position.xy];
  if (obj.x < k_view_distance)
  {
    float3 ro, rd;
    generate_ray(position.xy, cbv_eye_position, cbv_eye_target, ro, rd);

    float3 p = ro + obj.x * rd;
    float3 n = compute_normal(p);

    float ndl = dot(n, float3(0.0f, 0.0f, 1.0f));

    int idx0 = ((int)obj.y) >> 2;
    int idx1 = ((int)obj.y) & 0x3;
    color = float4(cbv_sphere[idx0].red[idx1], cbv_sphere[idx0].green[idx1], cbv_sphere[idx0].blue[idx1], 1.0f);

    color *= ndl;
  }
  return color;
}

[numthreads(8, 8, 1)]
void cs_raymarch()
{
  uint idx;
  uint2 rcoord;
  float3 ro, rd;
  float2 hit_object;

  idx = uav_atomic_counter.IncrementCounter();
  rcoord = uint2(idx & 0x3ff, idx >> 10);
  generate_ray(rcoord, cbv_eye_position, cbv_eye_target, ro, rd);

  hit_object = float2(1.0f, -1.0f);

  [allow_uav_condition] while (idx < 1024 * 1024)
  {
    float2 obj = nearest_object(ro + hit_object.x * rd);

    if (obj.x < k_hit_eps || hit_object.x > k_view_distance)
    {
      uav_raymarch_texture[rcoord] = float2(hit_object.x, obj.y);
      hit_object = float2(1.0f, -1.0f);

      idx = uav_atomic_counter.IncrementCounter();
      rcoord = uint2(idx & 0x3ff, idx >> 10);
      generate_ray(rcoord, cbv_eye_position, cbv_eye_target, ro, rd);
    }
    else
      hit_object.x += obj.x;
  }
}