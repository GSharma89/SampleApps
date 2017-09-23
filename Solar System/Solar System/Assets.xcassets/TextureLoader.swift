//
//  TextureLoader.swift
//  Solar System
//
//  Created by Admin on 30/05/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation
import Cocoa

//this class is required to get a new populated texture by specified NSImage.
class TextureLoader
{
    //this metal reference is required to create texture objeccts
    private var device:MTLDevice
    
    init(device:MTLDevice) {
        self.device = device
    }
    
    func loadTexture(imageName:String)->MTLTexture
    {
        var populatedTexture:MTLTexture!
        let image = NSImage.init(named: imageName)
        let cgimage = image?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let width = cgimage?.width
        let height = cgimage?.height
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width!
        var rawData = [UInt8](repeating:0 ,count: bytesPerRow * height!)
        let colorSpace = cgimage?.colorSpace
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let context = CGContext(data:&rawData,width: width!,height:height!,bitsPerComponent:bitsPerComponent,bytesPerRow:bytesPerRow,space:colorSpace!,bitmapInfo:bitmapInfo.rawValue)
        
        let rect = CGRect.init(x:0,y:0,width:width!,height:height!)

        //here this context draw image in specified rect area and populate the rawData array also 
        //so we need only rawData that is used to populate our texture in specified pixel format
        context?.draw(cgimage!, in: rect)
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width!, height: height!, mipmapped: false)
        
        populatedTexture = device.makeTexture(descriptor: textureDescriptor)
        
        let region = MTLRegion(origin: MTLOrigin(x:0,y:0,z:0), size: MTLSize(width:width!,height:height!,depth:1))
        
        populatedTexture.replace(region: region, mipmapLevel: 0, withBytes: &rawData, bytesPerRow: bytesPerRow )
    
       return populatedTexture
    }
}
