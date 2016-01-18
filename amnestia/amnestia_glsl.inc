vsh_full_triangle:
LN '#version 440 core'
LN 'out gl_PerVertex'
LN '{'
LN '  vec4 gl_Position;'
LN '};'
LN 'void main()'
LN '{'
LN '  vec2 p[3] = { vec2(-0.7, -0.7), vec2(0.7, -0.7), vec2(0.0, 0.7) };'
LN '  gl_Position = vec4(p[gl_VertexID], 0.0, 1.0);'
LN '}'
db 0

fsh_green:
LN '#version 440 core'
LN 'layout(location = 0) out vec4 fs_out_color;'
LN 'void main()'
LN '{'
LN '  fs_out_color = vec4(0.2, 0.8, 0.2, 0.2);'
LN '}'
db 0

align 8
vsh_full_triangle_ptr dq vsh_full_triangle
fsh_green_ptr dq fsh_green