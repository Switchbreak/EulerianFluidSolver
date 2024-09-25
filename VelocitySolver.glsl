#iChannel0 "file://Pressure.glsl"

const float DIFFUSION_RATE = 10.0;
const float GRAVITY = 100.0;

vec2 diffusion(vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    vec2 cell       = texture2D(iChannel0, uv).gb;
    vec2 upperCell  = textureOffset(iChannel0, uv, ivec2(0, 1)).gb;
    vec2 lowerCell  = textureOffset(iChannel0, uv, ivec2(0, -1)).gb;
    vec2 leftCell   = textureOffset(iChannel0, uv, ivec2(-1, 0)).gb;
    vec2 rightCell  = textureOffset(iChannel0, uv, ivec2(1, 0)).gb;

    float rate = iTimeDelta * DIFFUSION_RATE; // * iResolution.x * iResolution.y;
    return cell + rate * (upperCell + lowerCell + leftCell + rightCell - 4.0 * cell);
}

vec2 advection(vec2 fragCoord, vec2 velocity)
{
    vec2 startPoint = fragCoord.xy - iTimeDelta * velocity;
    vec2 startUV = startPoint / iResolution.xy;

    vec2 cell               = texture2D(iChannel0, startUV).gb;
    vec2 upperCell          = textureOffset(iChannel0, startUV, ivec2(0, 1)).gb;
    vec2 rightCell          = textureOffset(iChannel0, startUV, ivec2(1, 0)).gb;
    vec2 upperRightCell     = textureOffset(iChannel0, startUV, ivec2(1, 1)).gb;

    float rightCellFactor   = startPoint.x - 0.5 - floor(startPoint.x);
    float leftCellFactor    = 1.0 - rightCellFactor;
    float upperCellFactor   = startPoint.y - 0.5 - floor(startPoint.y);
    float lowerCellFactor   = 1.0 - upperCellFactor;

    return leftCellFactor * (lowerCellFactor * cell + upperCellFactor * upperCell) +
        rightCellFactor * (lowerCellFactor * rightCell + upperCellFactor * upperRightCell);
}

vec2 pressure(vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    float upperCell  = textureOffset(iChannel0, uv, ivec2(0, 1)).a;
    float lowerCell  = textureOffset(iChannel0, uv, ivec2(0, -1)).a;
    float leftCell   = textureOffset(iChannel0, uv, ivec2(-1, 0)).a;
    float rightCell  = textureOffset(iChannel0, uv, ivec2(1, 0)).a;

    return vec2(rightCell - leftCell, upperCell - lowerCell);
}

vec2 project(vec2 fragCoord, vec2 velocity)
{
    return velocity - pressure(fragCoord) * 0.5;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 cell = texture2D(iChannel0, uv);

    // vec2 velocity = (cell.gb - 0.5) * 100.0;
    vec2 velocity = diffusion(fragCoord);
    velocity = project(fragCoord, velocity);
    velocity = advection(fragCoord, velocity);
    velocity.y = velocity.y - iTimeDelta * GRAVITY;

    fragColor = vec4(cell.r, velocity, cell.a);
}