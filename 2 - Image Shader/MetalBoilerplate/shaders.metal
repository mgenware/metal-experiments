//
//  shaders.metal
//  MetalBoilerplate
//
//  Created by Mgen on 28/12/2016.
//  Copyright © 2016 Mgen. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void compute_shader(texture2d<float, access::read> input [[texture(0)]],
                    texture2d<float, access::write> output [[texture(1)]],
                    uint2 gid [[thread_position_in_grid]])
{
    float4 color = input.read(gid);
    output.write(float4(color.g, color.r, color.b, 1), gid);
}
