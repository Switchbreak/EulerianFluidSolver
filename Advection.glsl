#[compute]
#version 450

layout (local_size_x = 2, local_size_y = 2) in;

layout (binding = 0, rgba16f) restrict readonly uniform image2D uVelocityFieldR;
layout (binding = 1, rgba16f) restrict uniform image2D uVelocityFieldW;

layout (binding = 2) uniform Behavior {
    uniform float uDeltaTime;
};

vec4 avgTexelFetch(vec2 pos) {
    vec2 size = imageSize(uVelocityFieldR);
    
    pos.x = clamp(pos.x, 1.5, size.x - 1.5);
    pos.y = clamp(pos.y, 1.5, size.y - 1.5);
    
    vec4 cell             = imageLoad(uVelocityFieldR, ivec2(pos));
    vec4 rightCell        = imageLoad(uVelocityFieldR, ivec2(pos) + ivec2(1, 0));
    vec4 upperCell        = imageLoad(uVelocityFieldR, ivec2(pos) + ivec2(0, 1));
    vec4 upperRightCell   = imageLoad(uVelocityFieldR, ivec2(pos) + ivec2(1, 1));
    
    float rightCellFactor = pos.x - floor(pos.x);
    float leftCellFactor  = 1.0 - rightCellFactor;
    float upperCellFactor = pos.y - floor(pos.y);
    float lowerCellFactor = 1.0 - upperCellFactor;
    
    return leftCellFactor * (lowerCellFactor * cell + upperCellFactor * upperCell) +
        rightCellFactor * (lowerCellFactor * rightCell + upperCellFactor * upperRightCell);
}

vec4 advectDensity(ivec2 pos, vec4 cell) {
    vec4 rightCell = imageLoad(uVelocityFieldR, pos + ivec2(1, 0));
    vec4 lowerCell = imageLoad(uVelocityFieldR, pos + ivec2(0, 1));
    
    vec2 velocity = (cell.xy + vec2(rightCell.x, lowerCell.y)) / 2.0;
    vec2 prev = pos - uDeltaTime * velocity;

    return mix(avgTexelFetch(prev), vec4(0, 0, 0, 1), float(prev.x < 4 || prev.y < 4));
}

void main() {
    ivec2 pos = ivec2(gl_GlobalInvocationID.xy) + ivec2(1, 1);
    vec4 cell = imageLoad(uVelocityFieldR, pos);
    
    cell = mix(cell, vec4(advectDensity(pos, cell).xyz, cell.a), cell.a);
    
    imageStore(uVelocityFieldW, pos, cell);
}
