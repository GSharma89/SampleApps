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
class EventHandler:NSView,NSWindowDelegate
{
    
    var cameraInstance:Camera!
    
    init(camera:Camera,frame:NSRect)
    {
        cameraInstance = camera
                
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
    override func mouseMoved(with event: NSEvent)
    {
        
        /*this is mouse pointer position relative to window which we associated for rendering.this window's frame orgin is 
         bottom left corner*/
        let point = event.locationInWindow
        //let pointRelativeToView = convert(point, to: nil)//this is the function to convert window's point in current view coordinate
        //system
        cameraInstance.handleMouseMove(posx: Float32(point.x),posy: Float32(point.y))
        //Swift.print("mouse move")
        
    }
    override func keyDown(with event: NSEvent)
    {
        cameraInstance.handleKeyBoardEvent(eventType: .KEY_DOWN, key: event.characters!)
    }
    
    
    
    
    //it is for manipulating fovy
    override func scrollWheel(with event: NSEvent)
    {
        Swift.print("Wheel event")
        cameraInstance.handleMouseWheel(scrollingDeltaY: Float32(event.scrollingDeltaY))
    }
    func windowDidResize(_ notification: Notification)
    {
            Swift.print("window resized")
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
}
