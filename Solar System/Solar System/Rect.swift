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
    private var x:Float32
    private var y:Float32
    private var width:Float32
    private var height:Float32
    
    init(x:Float32,y:Float32,width:Float32,height:Float32,modelName: String, device: MTLDevice, modelType: ModelType,textureImage:String)
    {
        self.x=x
        self.y=y
        self.width=width
        self.height=height
        super.init(modelName: modelName, device: device, modelType: modelType)
        mess = meshGenerator.getRectangleMess(x: x, y: y, width: width, height: height)
        loadMessInBuffer()
        texture = textureLoader.loadTexture(imageName: textureImage)

        
    }
}
