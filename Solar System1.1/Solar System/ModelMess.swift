//
//  ModelMess.swift
//  Solar System
//
//  Created by Admin on 26/07/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation
import MetalKit
class ModelMess
{
    var verticesBuffer:MTLBuffer!
    var indicesBuffer:MTLBuffer!
    var index_count:Int
    var prev_instance_count:Int32
    var instance_count:Int32
    var modelTransformArray = [matrix_float4x4]()
    var textureImagesArray:[String]
    var modelTransformPerInstanceBuffer:[Int: MTLBuffer]!
    var texturePerInstanceArray:[Int:MTLTexture]!
    var type:ModelType
    
    init(type:ModelType)
    {
        self.type = type
        instance_count = 0
        prev_instance_count = 0
        index_count = 0
        textureImagesArray = [String]()
        texturePerInstanceArray = [Int:MTLTexture]()
        modelTransformPerInstanceBuffer = [Int: MTLBuffer]()
    }
    
}
