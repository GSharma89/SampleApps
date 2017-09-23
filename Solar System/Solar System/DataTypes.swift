//
//  DataTypes.swift
//  Solar System
//
//  Created by Admin on 31/05/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation
import simd

struct Uniforms
{
    var view_matrix:  float4x4
    var proj_matrix:  float4x4
    var Identity:     float4x4
    
    init() {
        
        
        let col1: float4 = [1,0,0,0]
        let col2: float4 = [0,1,0,0]
        let col3: float4 = [0,0,1,0]
        let col4: float4 = [0,0,0,1]
        
        
        Identity = float4x4.init([col1,col2,col3,col4])
        view_matrix = Identity
        proj_matrix = Identity
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
    
}

enum ModelType
{
    case Planet
    
    case Cube
    
    case Rect
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
