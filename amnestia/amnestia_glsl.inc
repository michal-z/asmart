vsh_full_triangle:
ln '#version 440 core'
ln 'out gl_PerVertex'
ln '{'
ln '  vec4 gl_Position;'
ln '};'
ln 'void main()'
ln '{'
ln '  vec2 p[3] = { vec2(-0.7, -0.7), vec2(0.7, -0.7), vec2(0.0, 0.7) };'
ln '  gl_Position = vec4(p[gl_VertexID], 0.0, 1.0);'
ln '}'
db 0

fsh_green:
ln '#version 440 core'
ln 'layout(location = 0) out vec4 fs_out_color;'
ln 'void main()'
ln '{'
ln '  fs_out_color = vec4(0.2, 0.8, 0.2, 0.2);'
ln '}'
db 0

align 8
vsh_full_triangle_ptr dq vsh_full_triangle
fsh_green_ptr dq fsh_green