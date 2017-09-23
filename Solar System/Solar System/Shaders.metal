
#include<simd/simd.h>
#include <metal_stdlib>
using namespace metal;

struct VertexInput
{
    simd::float4 position [[attribute(0)]];
    simd::float4 normal [[attribute(1)]];
    simd::float2 tex_cord [[attribute(2)]];
   
};

struct VertexOutput
{
    simd::float4 position [[position]];
    simd::float4 normal;
    simd::float2 tex_cord;

};

struct Uniforms
{
    float4x4 view_matrix;
    float4x4 proj_matrix;
    
    
};


vertex VertexOutput vertexShader( VertexInput vert [[stage_in]],constant Uniforms& uniform [[buffer(1)]], constant float4x4 &model_matrix [[buffer(2)]])
{
    VertexOutput vo;
    vo.position = uniform.proj_matrix*uniform.view_matrix*model_matrix*vert.position;
    vo.normal = model_matrix * vert.normal;
    //float4 tex = float4(vert.tex_cord.x,vert.tex_cord.y,0,1);
    vo.tex_cord = vert.tex_cord;
    
    return vo;
}

fragment half4 fragmentShader( VertexOutput vo [[stage_in]],texture2d<float, access::sample> sphere_texture [[texture(0)]],
                              sampler samplr [[sampler(0)]])
    {

    half4 color = half4(sphere_texture.sample(samplr,vo.tex_cord));
     
    return color;
    }
