struct transform_t
{
  float4x4 mat;
};
ConstantBuffer<transform_t> g_transform : register(b0);

float4 vs_transform(float4 position : POSITION) : SV_Position
{
  return mul(float4(position.xyz, 1.0f), g_transform.mat);
}
