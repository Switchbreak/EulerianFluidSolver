#iChannel0 "file://VelocitySolver.glsl"

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

    float rate = iTimeDelta * DIFFUSION_RATE;
    return cell + rate * (upperCell + lowerCell + leftCell + rightCell - 4.0 * cell);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 cell = texture2D(iChannel0, uv);
    vec2 velocity = cell.gb;

    if (iMouse.z > 0.0 && abs(fragCoord.x - iMouse.x) < 5.0 && abs(fragCoord.y - iMouse.y) < 5.0)
    {
        velocity = ((iMouse.xy - abs(iMouse.wz)) / iResolution.xy) * 5.0;
        fragColor = vec4(1.0, velocity, cell.a);
    } else if (fragCoord.x >= 100.0 && fragCoord.x <= 120.0 && fragCoord.y >= 100.0 && fragCoord.y <= 120.0) {
        fragColor = vec4(1.0, 10.5, 0.5, cell.a);
    } else {
        float density = diffusion(fragCoord);
        // float density = cell.r;
        fragColor = vec4(density, velocity, cell.a);
    }
}