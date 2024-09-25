#iChannel0 "file://Advection.glsl"

const int ITERATION_COUNT = 20;
const float DIFFUSION_RATE = 10.0;

float diffusion(vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    float cell       = texture2D(iChannel0, uv).r;
    float upperCell  = textureOffset(iChannel0, uv, ivec2(0, 1)).r;
    float lowerCell  = textureOffset(iChannel0, uv, ivec2(0, -1)).r;
    float leftCell   = textureOffset(iChannel0, uv, ivec2(-1, 0)).r;
    float rightCell  = textureOffset(iChannel0, uv, ivec2(1, 0)).r;

    float rate = iTimeDelta * DIFFUSION_RATE; // * iResolution.x * iResolution.y;
    float density = cell + rate * (upperCell + lowerCell + leftCell + rightCell - 4.0 * cell);

    return density;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec4 color;
    if (iMouse.z > 0.0 && abs(fragCoord.x - iMouse.x) < 5.0 && abs(fragCoord.y - iMouse.y) < 5.0)
    {
        color = vec4(1.0);
    } else {
        float density = clamp(diffusion(fragCoord), 0.0, 1.0);
        color = vec4(vec3(density), 1.0);
    }

    // Output to screen
    fragColor = color;
}