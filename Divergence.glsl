#iChannel0 "file://Advection.glsl"

float divergence(vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    vec2 upperCell  = textureOffset(iChannel0, uv, ivec2(0, 1)).gb;
    vec2 lowerCell  = textureOffset(iChannel0, uv, ivec2(0, -1)).gb;
    vec2 leftCell   = textureOffset(iChannel0, uv, ivec2(-1, 0)).gb;
    vec2 rightCell  = textureOffset(iChannel0, uv, ivec2(1, 0)).gb;
    vec2(leftCell.x, rightCell.y);

    return -0.5 * (rightCell.x - leftCell.x + lowerCell.y - upperCell.y);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
    fragColor = vec4(divergence(fragCoord), 0, 0, 1.0);
}