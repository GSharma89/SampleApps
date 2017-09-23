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
    private var side:Float32
    init(cubeSide:Float32,modelName: String, device: MTLDevice, modelType: ModelType,textureImage:String)
    {
        side = cubeSide
        super.init(modelName: modelName, device: device, modelType: modelType)
        mess = meshGenerator.getQubeMess(side: cubeSide)
        loadMessInBuffer()
        texture = textureLoader.loadTexture(imageName:textureImage)
    }
}
