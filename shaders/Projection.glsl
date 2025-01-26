#[compute]
#version 450

layout (local_size_x = 1, local_size_y = 1) in;
layout (binding = 0, rgba16f) uniform image2D uVelocityFieldR;

layout (binding = 2) uniform Behavior {
    uniform float uDeltaTime;
    uniform float uOverrelaxation;
    uniform float uOffset;
};

void project(ivec2 pos)
{
    vec4 cell       = imageLoad(uVelocityFieldR, pos);

    /*if (cell.a == 0.0) {
        return;
    }*/
    
    vec4 upperCell  = imageLoad(uVelocityFieldR, pos + ivec2(0, 1));
    vec4 lowerCell  = imageLoad(uVelocityFieldR, pos + ivec2(0, -1));
    vec4 leftCell   = imageLoad(uVelocityFieldR, pos + ivec2(-1, 0));
    vec4 rightCell  = imageLoad(uVelocityFieldR, pos + ivec2(1, 0));
    
    float adjacentCells = leftCell.a + rightCell.a + upperCell.a + lowerCell.a;
    /*if (adjacentCells == 0.0) {
        return;
    }*/
    
    float divergence = mix(uOverrelaxation * (rightCell.x - cell.x + upperCell.y - cell.y) / adjacentCells, 0.0, (cell.a == 0 || adjacentCells == 0.0));
    
    imageStore(uVelocityFieldR, pos,               vec4(cell.x + leftCell.a * divergence, cell.y + lowerCell.a * divergence, cell.zw));
    imageStore(uVelocityFieldR, pos + ivec2(1, 0), vec4(rightCell.x - rightCell.a * divergence, rightCell.yzw));
    imageStore(uVelocityFieldR, pos + ivec2(0, 1), vec4(upperCell.x, upperCell.y - upperCell.a * divergence, upperCell.zw));
}

void main() {
    ivec2 pos = ivec2(gl_GlobalInvocationID.x * 2 + (gl_GlobalInvocationID.y + int(uOffset)) % 2 + 1, gl_GlobalInvocationID.y + 1);
    project(pos);
}
