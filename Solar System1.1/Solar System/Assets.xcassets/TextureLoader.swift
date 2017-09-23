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
    
    
    func getTextureWithSlices(imageArray:[String])->MTLTexture
    {
        
        var cgImageObjects = [CGImage]()
        for imageName in imageArray
        {
            let nsimage = NSImage(named:imageName)
            let cgimage = nsimage?.cgImage(forProposedRect: nil, context: nil, hints: nil)
            cgImageObjects.append(cgimage!)
            
        }
        let textureWidth = cgImageObjects[0].width
        let textureHeight = cgImageObjects[0].height
        
        print("texture width:\(textureWidth)")
        print("texture height:\(textureHeight)")
        print("no of images:\(imageArray.count)")
        
        return loadTextureWithSlices(images: cgImageObjects, texureWidth: Float32(textureWidth), textureHeight: Float32(textureHeight))
    }

    private func loadTextureWithSlices(images:[CGImage],texureWidth:Float32,textureHeight:Float32)->MTLTexture
    {
        var returnTexture:MTLTexture!
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(texureWidth), height: Int(textureHeight), mipmapped: false)
        textureDescriptor.textureType = .type2DArray
        textureDescriptor.arrayLength = images.count
        returnTexture = device.makeTexture(descriptor: textureDescriptor)
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        var slice_index = 0
        for cgimage in images
        {
            
            let width = cgimage.width
            let height = cgimage.height
            let bytesPerRow = bytesPerPixel * width
            let bytesPerImage = bytesPerRow * height
            
            var rawData = [UInt8](repeating:0,count:bytesPerRow*height)
            let colorSpace = cgimage.colorSpace
            let bitMapInfo = CGBitmapInfo(rawValue:CGBitmapInfo.byteOrder32Big.rawValue|CGImageAlphaInfo.premultipliedLast.rawValue)
            let context = CGContext(data:&rawData,width:width,height:height,bitsPerComponent:bitsPerComponent,bytesPerRow:bytesPerRow,space:colorSpace!,bitmapInfo:bitMapInfo.rawValue)
            let rect = CGRect.init(x:0,y:0,width:width,height:height)
            
            context?.draw(cgimage, in: rect)
            let region = MTLRegion(origin:MTLOrigin(x:0,y:0,z:0),size:MTLSize(width:Int(width),height:Int(height),depth:1))
            //returnTexture.replace(region: region, mipmapLevel: 0, withBytes: &rawData, bytesPerRow: bytesPerRow )
            returnTexture.replace(region: region, mipmapLevel: 0, slice: slice_index, withBytes: &rawData, bytesPerRow: bytesPerRow, bytesPerImage: bytesPerImage)
            slice_index = slice_index + 1
        
        }
        
      return returnTexture
    }
}
