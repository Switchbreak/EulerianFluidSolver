#iChannel0 "file://Diffusion.glsl"

float advection(vec2 fragCoord, vec2 velocity)
{
    vec2 startPoint = fragCoord.xy - iTimeDelta * velocity;
    vec2 startUV = startPoint / iResolution.xy;

    float cell              = texture2D(iChannel0, startUV).r;
    float upperCell         = textureOffset(iChannel0, startUV, ivec2(0, 1)).r;
    float rightCell         = textureOffset(iChannel0, startUV, ivec2(1, 0)).r;
    float upperRightCell    = textureOffset(iChannel0, startUV, ivec2(1, 1)).r;

    float rightCellFactor   = startPoint.x - 0.5 - floor(startPoint.x);
    float leftCellFactor    = 1.0 - rightCellFactor;
    float upperCellFactor   = startPoint.y - 0.5 - floor(startPoint.y);
    float lowerCellFactor   = 1.0 - upperCellFactor;

    return leftCellFactor * (lowerCellFactor * cell + upperCellFactor * upperCell) +
        rightCellFactor * (lowerCellFactor * rightCell + upperCellFactor * upperRightCell);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 cell = texture2D(iChannel0, uv);
    vec2 velocity = cell.gb;

    float density = advection(fragCoord, (velocity - 0.5) * 100.0);
    fragColor = vec4(density, velocity, cell.a);
}