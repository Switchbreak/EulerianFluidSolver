#iChannel0 "file://VelocitySolver.glsl"
#iChannel1 "file://cf46k9svvl471.jpg"

const float EPSILON = 0.00000001;
const float OBSTACLE_SIZE = 50.0;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 color = texture2D(iChannel0, uv);

    if (iMouse.z > 0.0
            && fragCoord.x >= iMouse.x && fragCoord.x <= iMouse.x + OBSTACLE_SIZE
            && fragCoord.y >= iMouse.y && fragCoord.y <= iMouse.y + OBSTACLE_SIZE) {
        fragColor = vec4(0, 0, 1.0, 1.0);
    } else if (color.r < EPSILON)
    {
        fragColor = texture2D(iChannel1, uv);
    } else {
        fragColor = vec4(vec3(pow(color.r, 1.0 / 5.0)), 1.0);
    }
}