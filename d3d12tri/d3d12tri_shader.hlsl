
float4 vs_triangle(uint id : SV_VertexID) : SV_Position
{
  float2 verts[] = { float2(-0.7f, -0.7f), float2(0.7f, -0.7f), float2(0.0f, 0.7f) };
  return float4(verts[id], 0.0f, 1.0f);
}

float4 ps_triangle(float4 position : SV_Position) : SV_Target0
{
  return float4(0.2f, 0.8f, 0.2f, 0.2f);
}