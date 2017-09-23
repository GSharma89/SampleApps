//
//  DataTypes.swift
//  Solar System
//
//  Created by Admin on 31/05/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation
import simd
func getRotationAroundZ(_ radians : Float) -> matrix_float4x4
{
    var m : matrix_float4x4 = matrix_identity_float4x4;
    
    m.columns.0.x = cos(radians);
    m.columns.0.y = sin(radians);
    
    m.columns.1.x = -sin(radians);
    m.columns.1.y = cos(radians);
    
    return m;
}

func getRotationAroundY(_ radians : Float) -> matrix_float4x4
{
    var m : matrix_float4x4 = matrix_identity_float4x4;
    
    m.columns.0.x =  cos(radians);
    m.columns.0.z = -sin(radians);
    
    m.columns.2.x = sin(radians);
    m.columns.2.z = cos(radians);
    
    return m;
}

func getRotationAroundX(_ radians : Float) -> matrix_float4x4
{
    var m : matrix_float4x4 = matrix_identity_float4x4;
    
    m.columns.1.y = cos(radians);
    m.columns.1.z = sin(radians);
    
    m.columns.2.y = -sin(radians);
    m.columns.2.z =  cos(radians);
    
    return m;
}
func getTranslationMatrix(_ translation : vector_float4) -> matrix_float4x4
{
    var m : matrix_float4x4 = matrix_identity_float4x4
    
    m.columns.3 = translation
    
    return m
}

func getScaleMatrix(_ x : Float, y : Float, z : Float) -> matrix_float4x4
{
    var m = matrix_identity_float4x4
    
    m.columns.0.x = x
    m.columns.1.y = y
    m.columns.2.z = z
    
    return m
}
func crossProduct(_ a : vector_float3, _ b : vector_float3) -> vector_float3
{
    var r : vector_float3 = vector_float3()
    
    r.x = a.y*b.z - a.z*b.y
    r.y = a.z*b.x - a.x*b.z
    r.z = a.x*b.y - a.y*b.x
    
    return r
}
