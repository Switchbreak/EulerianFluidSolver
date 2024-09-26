#iChannel0 "file://Divergence.glsl"
#iChannel1 "file://Advection.glsl"

float project(vec2 uv, float divergence)
{
    float cell       = texture2D(iChannel0, uv).r;
    float upperCell  = textureOffset(iChannel0, uv, ivec2(0, 1)).r;
    float lowerCell  = textureOffset(iChannel0, uv, ivec2(0, -1)).r;
    float leftCell   = textureOffset(iChannel0, uv, ivec2(-1, 0)).r;
    float rightCell  = textureOffset(iChannel0, uv, ivec2(1, 0)).r;

    return (divergence + leftCell + rightCell + lowerCell + upperCell) / 4.0;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{ 
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 densityVelocity = texture2D(iChannel1, uv).rgb;
    float divergence = texture2D(iChannel0, uv).x;

    float pressure = project(uv, divergence);
    fragColor = vec4(densityVelocity, pressure);
}