
#include "ShaderDataTypes.h"
#include<simd/simd.h>
#include <metal_stdlib>
using namespace metal;


struct VertexInput
{
    simd::packed_float4 position [[attribute(0)]];
    simd::packed_float4 normal [[attribute(1)]];
    simd::packed_float2 tex_cord [[attribute(2)]];
    /*This is because added here so that our vertex memory's size could be in multiple of 16 otherwise vertex_array in shader will not work with vertex_id*/
    //simd::float2 light_cord [[attribute(3)]];
   
};

struct VertexOutput
{
    simd::float4 position [[position]];
    simd::float4 normal;
    simd::float2 tex_cord;
    uint texture_id;

};

constant float4 verts[] =
{
    float4(-1.0, 1.0, 0.0, 0.0),
    float4( 1.0, 1.0, 1.0, 0.0),
    float4(-1.0,-1.0, 0.0, 1.0),
    float4( 1.0,-1.0, 1.0, 1.0),
};

struct Varying
{
    float4 position [[position]];
    float2 tex_cord;
};

vertex Varying visualizeVertexShader(uint id [[vertex_id]])
{
    Varying vo;
    vo.position = float4(verts[id].xy,0.0,1.0);
    vo.tex_cord =float2(verts[id].z,verts[id].w);
    return vo;
};


fragment float4 visualizeFragmentShader(Varying vo [[stage_in]], texture2d<float,access::sample> texture [[texture(0)]],
                               sampler sampler2d [[sampler(0)]])
{
    
    float4 color;
    color = texture.sample(sampler2d,vo.tex_cord);
    
    return color;
}




/*kernel void matrixMultiplication(device float4x4 *rows [[buffer(0)]],device float4x4 *columns [[buffer(1)]],device float4x4
                                 *out_rows  [[buffer(2)]],uint index [[thread_position_in_grid]])
{
    float4 row = rows[index];
    float4 out_row;
    float4 v1 = row*columns[0];
    float4 v2 = row*columns[1];
    float4 v3 = row*columns[2];
    float4 v4 = row*columns[3];
    out_row.x = v1.x + v1.y + v1.z + v1.z;//row.x * col1.x + row.y * col1.y + row.z * col1.z + row.w * col1.w;
    
    out_row.y = v2.x + v2.y + v2.z + v2.z;//row.x * col2.x + row.y * col2.y + row.z * col2.z + row.w * col2.w;
    
    out_row.z = v3.x + v3.y + v3.z + v3.z;//row.x * col3.x + row.y * col3.y + row.z * col3.z + row.w * col3.w;
    out_row.w = v4.x + v4.y + v4.z + v4.z;//row.x * col4.x + row.y * col4.y + row.z * col4.z + row.w * col4.w;
    out_rows[index] = out_row;
    
    out_rows[index] = rows[index] * columns[index];
    
}*/

vertex VertexOutput vertexShader( device VertexInput *vert_array [[buffer(0)]],constant Uniforms& uniform [[buffer(1)]],
                                  device matrix_float4x4 *model_matrix_array [[buffer(2)]],
                                  uint vid [[vertex_id]],
                                  uint iid [[instance_id]]
                                 )
{
    VertexOutput vo;
    VertexInput vert = vert_array[vid];
    matrix_float4x4 model_matrix = model_matrix_array[iid];
    vo.position = uniform.proj_matrix*uniform.view_matrix*model_matrix*float4(vert.position);
    vo.normal = model_matrix * float4(vert.normal);
    vo.tex_cord = vert.tex_cord;
    vo.texture_id = iid;
    
    return vo;
}

fragment half4 fragmentShader( VertexOutput vo [[stage_in]],const texture2d_array<float,access::sample> tex_array [[texture(0)]],
                              sampler samplr [[sampler(0)]])
    {

        
    
        half4 color = half4(tex_array.sample(samplr,vo.tex_cord,vo.texture_id));
        //half4 color = half4(1,0,0,1);
    
        return color;
    }

