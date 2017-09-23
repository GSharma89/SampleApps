#include <metal_stdlib>

using namespace metal;

kernel void particleRendererShader(texture2d<float ,access::write> outTexture [[texture(0)]],device const float4x4 *inParticles [[buffer(0)]],
                                   device float4x4 *outParticles [[buffer(1)]],constant float4x4& gravityWell [[buffer(2)]],
                                   constant float4& particleColor [[buffer(3)]],
                                   constant float& imageWidth [[buffer(4)]],constant float& imageHeight [[buffer(5)]],
                                   constant float& dragFactor [[buffer(6)]], constant bool& respawnParticles [[buffer(7)]],
                                   uint id [[thread_position_in_grid]])
                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                        
{
    const float4x4 inParticle = inParticles[id];
    float4x4 outParticle;
    const uint type = id % 3;
    float spawnSpeedMultiplier = 2.0;
    const float typeTweak = 1 + type;
    
    float4 colors[] = {float4(particleColor.r,particleColor.g,particleColor.b,particleColor.a),
                       
                       float4(particleColor.b,particleColor.r,particleColor.g,particleColor.a),
                       
                       float4(particleColor.g,particleColor.b,particleColor.r,particleColor.a)
                       };
    
    const float4 outColor = colors[type];
    
    
    //writing the particles in outTexture
    for(int i=0; i<4; i++)
    {
        const uint2 particlePos(inParticle[i].x,inParticle[i].y);
                                                               
        if(0<particlePos.x && 0<particlePos.y && particlePos.x<imageWidth && particlePos.y<imageHeight)
            outTexture.write(outColor,particlePos);
        
        else if(respawnParticles)
        {
                inParticle[i].z = spawnSpeedMultiplier * sin(inParticle[i].x + inParticle[i].y);
                inParticle[i].w = spawnSpeedMultiplier * cos(inParticle[i].x + inParticle[i].y);
                inParticle[i].x = imageWidth/2;
                inParticle[i].y = imageHeight/2;
                                                               
                                                               
        }
                                                               
    }

    //transforming particles as per gravityWell
    for(int i=0;  i<4;i++)
    {
        float2 posFloat = float2(inParticle[i].x,inParticle[i].y);
        float2 gravityWellPos = float2(gravityWell[i].x,gravityWell[i].y);
        float distance = max(distance_squared(posFloat,gravityWellPos),0.01);
        float massFac = gravityWell[i].z * typeTweak / distance;
        float spinFac = gravityWell[i].w * typeTweak / distance;
        outParticle[i] = float4((inParticle[i].x + inParticle[i].z),(inParticle[i].y + inParticle[i].w),
                             (inParticle[i].z * dragFactor + (gravityWell[i].x - inParticle[i].x) * massFac),
                             (inParticle[i].w * dragFactor + (gravityWell[i].y - inParticle[i].y) * spinFac));
                                                               
    }
    outParticles[id] = outParticle;

}
