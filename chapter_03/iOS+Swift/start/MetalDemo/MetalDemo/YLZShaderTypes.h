//
//  YLZShaderTypes.h
//  MetalDemo
//
//  Created by roni on 2019/6/10.
//  Copyright © 2019 Colin. All rights reserved.
//

#ifndef YLZShaderTypes_h
#define YLZShaderTypes_h

#include <simd/simd.h>

typedef struct
{
    vector_float2 position;
    vector_float4 color;
} YLZVertex;

typedef enum YLZVertexInputIndex
{
    YLZVertexInputIndexVertices = 0,
    YLZVertexInputIndexCount    = 1,
} YLZVertexInputIndex;

#endif /* YLZShaderTypes_h */
