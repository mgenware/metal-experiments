//
//  shaders.metal
//  MetalBoilerplate
//
//  Created by Mgen on 28/12/2016.
//  Copyright © 2016 Mgen. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};


vertex Vertex vertex_shader(constant Vertex *vertices [[buffer(0)]], uint vid [[vertex_id]]) {
    // extract corresponding vertex by given index
    return vertices[vid];
}

fragment float4 fragment_shader(Vertex vert [[stage_in]]) {
    return vert.color;
}
