//
//  Transform.swift
//  Solar System
//
//  Created by Admin on 29/05/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//


import Foundation
import MetalKit
import simd
class Transform
{
    var model_matrix:matrix_float4x4
    var position:vector_float4
    var scale:vector_float3
    var rotation:vector_float3
    
    
    init()
    {
        model_matrix = matrix_identity_float4x4
        position = vector_float4(0,0,0,1.0)
        scale = vector_float3(1,1,1)
        rotation = vector_float3(0,0,0)
    }
    
    
            
}

