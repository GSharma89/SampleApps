//
//  Cube.swift
//  Solar System
//
//  Created by Admin on 16/06/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation
import MetalKit
class Cube:Model
{
    
    init(modelName: String, device: MTLDevice, modelType: ModelType,textureImage:String,meshGenerator:ObjectMeshGenerator,textureLoader:TextureLoader,parent:Model)
    {
        
        super.init(id: modelName, device: device, modelType: modelType,meshGenerator: meshGenerator,textureLoader:textureLoader,parentModel: parent,imageName: textureImage)
                
        
    }
}
