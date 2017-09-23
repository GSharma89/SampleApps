#include <simd/simd.h>
#include <metal_stdlib>
using namespace metal;

struct vertexInput
{
    float4 position [[attribute(0)]];
    float2 tex_cord [[attribute(1)]];
};

struct vertexOutput
{
    float4 position [[position]];
    float2 tex_cord;
};

vertex vertexOutput vertexShader(vertexInput vi [[stage_in]])
{
    vertexOutput vo;
    vo.position = vi.position;
    vo.tex_cord = vi.tex_cord;
    return vo;
};

fragment float4 fragmentShader(vertexOutput vo [[stage_in]],texture2d<float,access::read> inputTexture [[texture(0)]],device simd::uint2& dim [[buffer(1)]])
{
    float4 color,c1,c2,c3,c4,c11,c21;
    
    float x = vo.tex_cord.x * dim.x;
    
    float y = vo.tex_cord.y * dim.y;
    
    uint x1 = floor(x);
    uint y1 = floor(y);
    uint x2 = (floor(x)+1);
    uint y2 = y1;
    uint x3 = x1;
    uint y3 = (floor(y)+1);
    uint x4 = x2;
    uint y4 = y3;
    
    
    c1 = inputTexture.read(uint2(x1,y1));
    c2 = inputTexture.read(uint2(x2,y2));
    c3 = inputTexture.read(uint2(x3,y3));
    c4 = inputTexture.read(uint2(x4,y4));
    
    c11 = c1 + (c2-c1)*(x-x1);
    c21 = c3 + (c4-c3)*(x-x1);
    
    color = c11 +(c21-c11)*(y-y1);
    
    return color;
}
fragment float4 fragmentShader1(vertexOutput vo [[stage_in]],texture2d<float,access::sample> inputTexture [[texture(0)]],sampler sampler2d [[sampler(0)]])
{

    float4 color = inputTexture.sample(sampler2d,vo.tex_cord);
    
    return color;
    
}

kernel void compareShader(texture2d<float,access::read> texture1 [[texture(0)]],texture2d<float,access::read> texture2 [[texture(1)]], uint2 thread_pos [[thread_position_in_grid]], device simd::uint& matched_pixel_count [[buffer(0)]])
{
    float4 color1 = texture1.read(thread_pos);
    float4 color2 = texture2.read(thread_pos);
    if(color1.r == color2.r && color1.g == color2.g && color1.b== color2.b && color1.a == color2.a)
        matched_pixel_count =1;
    else
        matched_pixel_count = 0;
    
}
