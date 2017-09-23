//
//  DataTypes.swift
//  Solar System
//
//  Created by Admin on 10/08/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//


import simd
struct Uniforms
{
    var view_matrix:  matrix_float4x4
    var proj_matrix:  matrix_float4x4
    
    
    init() {
        
        
        
        view_matrix = matrix_identity_float4x4
        proj_matrix = matrix_identity_float4x4
    }
}

struct Vector4
{
    var x: Float32
    var y: Float32
    var z: Float32
    var w: Float32
}

struct TexCoords
{
    var u: Float32
    var v: Float32
}


struct Vertex
{
    var position: Vector4
    var normal: Vector4
    var texCoords: TexCoords
    /*This is because added here so that our vertex memory's size could be in multiple of 16 otherwise vertex_array in shader will not work with vertex_id*/
    //var lightCord:TexCoords
    
}

enum ModelType
{
    case Planet
    
    case Cube
    
    case Rect
    
    case Group
}

enum KeyBoardEventType
{
    case KEY_DOWN
    
    case KEY_UP
}

enum MouseEventType
{
    case MOUSE_LEFT_DOWN
    case MOUSE_LEFT_UP
    case MOUSE_RIGHT_DOWN
    case MOUSE_RIGHT_UP
    case MOUSE_MOVE
    
}
