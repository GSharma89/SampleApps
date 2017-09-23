//
//  Planet.swift
//  Solar System
//
//  Created by Admin on 07/06/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation
import simd
import MetalKit

class Planet:Model
{
    
    var center:float3!
    let no_of_days_to_be_revolved:Int32
    let rotate_period:Float32
   
    init(name:String,center:float3,radius:Float32,textureImage:String,type:ModelType, device:MTLDevice)
    {
        
        switch name {
        case "Mercury":
            no_of_days_to_be_revolved = 88
            rotate_period = 58
            break
        case "Venus":
            no_of_days_to_be_revolved = 225
            rotate_period = -243
            break
        case "Earth":
            no_of_days_to_be_revolved = 365
            rotate_period = 1
            break
        case "Mars":
            no_of_days_to_be_revolved = 687
            rotate_period = 1
            break
        case "Jupiter":
            no_of_days_to_be_revolved = 43332
            rotate_period = 0.5
            break
        case "Sun":
            no_of_days_to_be_revolved = 35
            rotate_period = 35
        default:
            no_of_days_to_be_revolved = 1
            rotate_period = 1
            print("Invalid name of planet")
            break
        }
        self.center = center
        
        super.init(modelName:name,device: device,modelType: type)
        mess = meshGenerator.getSphereVerticesMesh(center:center,radius: radius, slices: 100, slice_triangles: 100)
        loadMessInBuffer()
        texture = textureLoader.loadTexture(imageName: textureImage)
        
      
        
    }
    

   
}
