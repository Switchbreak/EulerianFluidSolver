#iChannel0 "file://VelocitySolver.glsl"

const int ITERATION_COUNT = 20;
const float DIFFUSION_RATE = 10.0;
const float OBSTACLE_SIZE = 50.0;
const float DISSIPATION = 0.0001;

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

    if (iMouse.z > 0.0
            && fragCoord.x >= iMouse.x && fragCoord.x <= iMouse.x + OBSTACLE_SIZE
            && fragCoord.y >= iMouse.y && fragCoord.y <= iMouse.y + OBSTACLE_SIZE) {
        velocity = ((iMouse.xy - abs(iMouse.wz)) / iResolution.xy) * 5.0;
        fragColor = vec4(1.0, velocity, cell.a);
    } else {
        float density = diffusion(fragCoord) - DISSIPATION;
        fragColor = vec4(density, velocity, cell.a);
    }
}