//
//  EventHandlerView.swift
//  Solar System
//
//  Created by Admin on 06/07/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation
import Cocoa
import simd
let CUBE_COUNT:Int = 10
import MetalKit
class ModelView:NSView,NSWindowDelegate
{
    
    var cameraInstance:Camera!
    private var modelTreeHolder:Model!
    private var renderer:Renderer
    init(camera:Camera,frame:NSRect,renderer:Renderer)
    {
        cameraInstance = camera
        
        self.renderer = renderer
                
        super.init(frame: frame)
        
        
    }
        required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override var acceptsFirstResponder: Bool//this variable needs to be overridden otherwise no event will come on our custom view
    {
        return true
    }
    override func mouseDown(with event: NSEvent) {
        
        Swift.print("mouseDown")
    }
    
    override func mouseDragged(with event: NSEvent)
    {
        
        /*this is mouse pointer position relative to window which we associated for rendering.this window's frame orgin is 
         bottom left corner*/
        let point = event.locationInWindow
        //let pointRelativeToView = convert(point, to: nil)//this is the function to convert window's point in current view coordinate
        //system
        cameraInstance.handleMouseDragged(posx: Float32(point.x),posy: Float32(point.y))
        //Swift.print("mouse move")
        
    }
    override func keyDown(with event: NSEvent)
    {
        cameraInstance.handleKeyBoardEvent(eventType: .KEY_DOWN, key: event.characters!)
    }
    
    
    
    
    //it is for manipulating fovy
    override func scrollWheel(with event: NSEvent)
    {
       
        cameraInstance.handleMouseWheel(scrollingDeltaY: Float32(event.scrollingDeltaY))
    }
    func windowDidResize(_ notification: Notification)
    {
        
            let window = notification.object as! NSWindow
            let width = window.frame.width
            let height = window.frame.height
            Swift.print("New window size:\(window.frame)")//Swift is necessary here otherwise mac will be hanged up
            cameraInstance.handleResizeEvent(width: Float32(width), height: Float32(height))
    }
    
    func windowDidMiniaturize(_ notification: Notification)
    {
        Swift.print("window minimized")
        let window = notification.object as! NSWindow
        let width = window.frame.width
        let height = window.frame.height
        cameraInstance.handleResizeEvent(width: Float32(width), height: Float32(height))
        
    }
    func windowDidDeminiaturize(_ notification: Notification)
    {
        Swift.print("window maximized")
        let window = notification.object as! NSWindow
        let width = window.frame.width
        let height = window.frame.height
        cameraInstance.handleResizeEvent(width: Float32(width), height: Float32(height))
    }
    func createModelTree(id:String,device:MTLDevice,meshGenerator:ObjectMeshGenerator,textureLoader:TextureLoader)->Model
    {
        
        
        modelTreeHolder = Model(id: id,device: device,modelType: ModelType.Group,meshGenerator: meshGenerator,textureLoader: textureLoader,parentModel:nil,imageName:nil)
        
        let p = modelTreeHolder.addPlanetModel(id:"BackgroundHemiSphere",textureImage:"Space",device: device)
        var transform = p?.transform
        transform?.model_matrix = getScaleMatrix(11000, y: 11000, z: 11000)
        transform?.model_matrix = matrix_multiply(getTranslationMatrix(vector_float4(0,0,200,1.0)), (transform?.model_matrix)!)
        
        
        let p1 = modelTreeHolder.addPlanetModel(id: "Sun",textureImage:"sun",device: device)
        transform = p1?.transform
        transform?.model_matrix = getScaleMatrix(15, y: 15, z: 15)
       
        
        
         let p2 = modelTreeHolder.addPlanetModel(id: "Mercury",textureImage: "mercury",device: device)
         (p2 as! Planet).animate = true
        
         transform = p2?.transform
         transform?.position = vector_float4(40,-3,-20,1.0)
        
        let p3 = modelTreeHolder.addPlanetModel(id: "Venus",textureImage: "venus",device: device)
         (p3 as! Planet).animate = true
        
        transform = p3?.transform
        transform?.position = vector_float4(60,-3,-15,1.0)
        transform?.scale = vector_float3(2,2,2)
        
         let p4 = modelTreeHolder.addPlanetModel(id: "Earth", textureImage: "Earth",device: device)
         (p4 as! Planet).animate = true
         transform = p4?.transform
         transform?.position = vector_float4(80,-3,-10,1.0)
         transform?.scale = vector_float3(3, 3, 3)
        
         
         let p5 = modelTreeHolder.addPlanetModel(id: "Mars", textureImage: "mars",device: device)
         (p5 as! Planet).animate = true
        
         transform = p5?.transform
         transform?.position = vector_float4(100,-3,-5,1.0)
         transform?.scale = vector_float3(4, 4, 4)

        
         let p6 = modelTreeHolder.addPlanetModel(id: "Jupiter", textureImage: "Jupiter",device: device)
         (p6 as! Planet).animate = true
         transform = p6?.transform
         transform?.position = vector_float4(120,-3,0,1.0)
         transform?.scale = vector_float3(5, 5, 5)
        /*for i in 0..<CUBE_COUNT
        {
         let cube = modelTreeHolder.addCubeModel(id: "Cube\(i)", device: device, imageName:"dice2" )
        
         let transform = cube?.transform
         
         transform?.position = vector_float4(Float(getRandomValue(500)),Float(getRandomValue(100)),Float(getRandomValue(700)),1.0)
         
        
        }*/
        
        return modelTreeHolder
    }
    //Returns a value from -max to max
    func getRandomValue(_ max : Double) -> Double
    {
        let r : Int32 = Int32(Int64(arc4random()) - Int64(RAND_MAX))
        let v = (Double(r) / Double(RAND_MAX)) * max
        
        return v
    }

    
}
