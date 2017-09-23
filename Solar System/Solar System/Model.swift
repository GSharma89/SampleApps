//
//  3DObject.swift
//  Solar System
//
//  Created by Admin on 16/06/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation
import MetalKit
class Model
{
    var name:String!
    var transform:Transform!
    var vertexBuffer:MTLBuffer!
    var indexBuffer:MTLBuffer!
    var texture:MTLTexture!
    var mess:([Vertex],[UInt32])!
    var meshGenerator:ObjectMeshGenerator!
    var textureLoader:TextureLoader!
    var device:MTLDevice!
    var type:ModelType!
    
    init(modelName:String,device:MTLDevice,modelType:ModelType) {
        name = modelName
        type = modelType
        self.device = device
        transform = Transform()
        meshGenerator = ObjectMeshGenerator()
        textureLoader = TextureLoader(device: device)
    }
    func loadMessInBuffer() {
        
        let verticesByteSize = mess.0.count * MemoryLayout<Vertex>.size
        vertexBuffer = device.makeBuffer(bytes: mess.0, length: verticesByteSize, options: [])
        let indexByteSize = mess.1.count * MemoryLayout<UInt32>.size
        indexBuffer = device.makeBuffer(bytes: mess.1, length: indexByteSize, options: [])
        

    }
    
}
