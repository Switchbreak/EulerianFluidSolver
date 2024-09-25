#iChannel0 "file://Advection.glsl"
#iChannel1 "file://cf46k9svvl471.jpg"

const float EPSILON = 0.00000001;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 color = texture2D(iChannel0, uv);

    if (color.r < EPSILON)
    {
        fragColor = texture2D(iChannel1, uv);
    } else {
        fragColor = vec4(pow(color.xyz, vec3(1.0 / 5.0)), 1.0);
    }
}