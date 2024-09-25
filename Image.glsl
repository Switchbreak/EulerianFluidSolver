#iChannel0 "file://VelocitySolver.glsl"
#iChannel1 "file://cf46k9svvl471.jpg"

const float EPSILON = 0.00000001;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 color = texture2D(iChannel0, uv);

    if (color.r < EPSILON)
    {
        fragColor = texture2D(iChannel1, uv);
    } else if (fragCoord.x >= 100.0 && fragCoord.x <= 120.0 && fragCoord.y >= 100.0 && fragCoord.y <= 120.0) {
        fragColor = vec4(0, 0, 1.0, 1.0);
    } else {
        fragColor = vec4(vec3(pow(color.r, 1.0 / 5.0)), 1.0);
    }
}