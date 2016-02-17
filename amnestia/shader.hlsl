struct transform_t
{
  float4x4 mat;
};
ConstantBuffer<transform_t> g_transform : register(b0);

float4 vs_triangle(uint id : SV_VertexID) : SV_Position
{
  float2 verts[] = { float2(-0.7f, -0.7f), float2(0.7f, -0.7f), float2(0.0f, 0.7f) };
  float4 p = float4(verts[id].x, verts[id].y, 0.0f, 1.0f);
  return mul(p, g_transform.mat);
}

float4 ps_triangle(float4 position : SV_Position) : SV_Target0
{
  return float4(1.0f, 0.9f, 0.0f, 1.0f);
}
