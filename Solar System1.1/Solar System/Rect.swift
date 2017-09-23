//
//  Rect.swift
//  Solar System
//
//  Created by Admin on 12/07/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation
import MetalKit
class Rect: Model
{
    
    init(modelName: String, device: MTLDevice, modelType: ModelType,textureImage:String,meshGenerator:ObjectMeshGenerator,textureLoader:TextureLoader,parent:Model)
    {
        
        super.init(id: modelName, device: device, modelType: modelType,meshGenerator: meshGenerator,textureLoader: textureLoader,parentModel:parent,imageName: textureImage)
        
        

        
    }
}
