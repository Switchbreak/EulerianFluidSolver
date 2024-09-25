#iChannel0 "file://Diffusion.glsl"
#iChannel1 "file://cf46k9svvl471.jpg"
// #iChannel1 "self"

float advection(vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 velocity = (texture2D(iChannel1, uv).gb - 0.5) * 1000.0;

    vec2 startPoint = fragCoord.xy - iTimeDelta * velocity;
    vec2 startUV = startPoint / iResolution.xy;

    float cell              = texture2D(iChannel0, startUV).r;
    float upperCell         = textureOffset(iChannel0, startUV, ivec2(0, 1)).r;
    float rightCell         = textureOffset(iChannel0, startUV, ivec2(1, 0)).r;
    float upperRightCell    = textureOffset(iChannel0, startUV, ivec2(1, 1)).r;

    float rightCellFactor   = startPoint.x - floor(startPoint.x);
    float leftCellFactor    = 1.0 - rightCellFactor;
    float upperCellFactor   = startPoint.y - floor(startPoint.y);
    float lowerCellFactor   = 1.0 - upperCellFactor;

    float density = leftCellFactor * (lowerCellFactor * cell + upperCellFactor * upperCell) +
        rightCellFactor * (lowerCellFactor * rightCell + upperCellFactor * upperRightCell);

    return density;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec4 color;
    if (iMouse.z > 0.0 && abs(fragCoord.x - iMouse.x) < 5.0 && abs(fragCoord.y - iMouse.y) < 5.0)
    {
        color = vec4(1.0);
    } else {
        float density = advection(fragCoord);
        color = vec4(vec3(density), 1.0);
    }

    // Output to screen
    fragColor = color;
}