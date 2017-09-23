//
//  FPSCamera.swift
//  Solar System
//
//  Created by Admin on 06/07/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation
import simd
class Camera
{
    private var yaw:Float32//this is the angle around y -axis.it tells how much horizontally camera is looking our  3d scene
    private var pitch:Float32//this is the angle around x-axis.it tells how much vertically is camera looking our 3d scene
    private var position:vector_float3//this is the position where camera is placed in world coordinate system
    private var direction:vector_float3//this is the direction vector toward which camera is looking
    private var up:vector_float3//this is up direction which rotates camera around z-axis.this is the angle which is roll.
    
    private var fovy:Float32//this is vertical field of view
    private let cameraSpeedFactor:Float32
    private var lastMousePosX:Float32
    private var lastMousePosY:Float32
    private let sensitivity:Float32
    var uniforms:Uniforms!//this is the projection and view transform
    var deltaTime:Float32
    
    var near:Float32{
        didSet
        {
            setProjectionMatrix()
        }
    }
    var far:Float32{
        didSet
        {
            setProjectionMatrix()
        }
    }

    var viewingWidth:Float32{
        didSet
        {
            setProjectionMatrix()
        }
    }

    var viewingHeight:Float32{
        didSet
        {
            setProjectionMatrix()
        }
    }

    init()
    {
        yaw = 0.0
        pitch = 0
        position = vector_float3(0.0,0.0,100.0)
        direction = vector_float3(0.0,0.0,1.0)
        up = vector_float3(0.0,-1.0,0.0)
        fovy = 60.0
        viewingWidth = 0.0
        viewingHeight = 0.0
        near = 0.1
        far = 100000000000
        deltaTime = 0.0
        cameraSpeedFactor = 2000
        sensitivity = 0.2
        lastMousePosX = 0.0
        lastMousePosY = 0.0
        uniforms = Uniforms()
        uniforms.proj_matrix = matrix_identity_float4x4
        uniforms.view_matrix = matrix_identity_float4x4
        uniforms.view_matrix=getViewMatrix(direction:direction, up: up, position:position)
        
    }
    
    
    private func setProjectionMatrix()
    {
        
        /*
         the perspective projection row -wise matrix:
         _                                                                                  _
         | d/aspect_ratio    0                     0                             0            |
         |                                                                                    |
         |    0              d                     0                             0            |
         |                                                                                    |
         |    0              0               -(far+near)/(far-near) - 2*far*near/(far-near)   |
         |                                                                                    |
         |_    0             0                  -1                               0           _|
         
         where d is distance between camera and projection plane i.e d = 1/tan(verticalFieldOfView/2) and far and near are
         distance from camera to far and near plane respectively.
         
         the below matrix is same perspective projection matrix but it is set in column wise order.
         */
        
        
        
        let d =  1/tan(fovy * 0.5 * Float(Double.pi) / 180 )
        
        let aspectRatio = viewingWidth / viewingHeight
        
        uniforms.proj_matrix.columns.0.x = d/aspectRatio
        uniforms.proj_matrix.columns.1.y = d
        uniforms.proj_matrix.columns.2.z = -(far+near)/(far-near)
        uniforms.proj_matrix.columns.2.w = -1
        uniforms.proj_matrix.columns.3.z = -2*far*near/(far-near)
        uniforms.proj_matrix.columns.3.w = 0
       
                                
    }
    func handleMouseDragged(posx:Float32,posy:Float32)
    {
        
        resetViewMatrix()
        var xOffset = Float32(posx) - lastMousePosX
        var yOffset = Float32(posy) - lastMousePosY
        lastMousePosX = Float32(posx)
        lastMousePosY = Float32(posy)
        xOffset*=sensitivity
        yOffset*=sensitivity
        
        yaw+=xOffset
        pitch+=yOffset
        let mat = matrix_multiply(getRotationAroundY(Float(Double.pi) * yaw/180), getRotationAroundX(Float(Double.pi)*pitch/180))
        uniforms.view_matrix = matrix_multiply(uniforms.view_matrix,mat)
        
    }
    
    
    func handleKeyBoardEvent(eventType:KeyBoardEventType,key:String)
    {
        
        if(eventType == .KEY_DOWN)
        {
            switch key
            {
            case "L","l"://left
                
                position-=normalize(crossProduct(direction, up)) * cameraSpeedFactor * deltaTime

                break;
            case "R","r"://right
                
                position+=normalize(crossProduct(direction,up)) * cameraSpeedFactor * deltaTime
                break;
        
            case "U","u"://up
                
                position-=cameraSpeedFactor * deltaTime * up
                break;
            
            case "D","d"://down
                
                position+=cameraSpeedFactor * deltaTime * up
                break;
            
            case "F","f"://forward
                
                
                position-=cameraSpeedFactor * deltaTime * direction
                break;
            case "B","b"://backward
                
                
                position+=cameraSpeedFactor * deltaTime * direction
                break;
            
            default:
                print("Invalid key is pressed")
                break;
                
            }
        
        }
        else if(eventType == .KEY_UP)
        {
            //take action on key up
        }
        
        uniforms.view_matrix = getViewMatrix(direction: direction, up: up, position: position)
        
    }
    func handleResizeEvent(width:Float32,height:Float32)
    {
        viewingHeight = height
        viewingWidth = width
    
    }
    func handleMouseWheel(scrollingDeltaY:Float32)
    {
       //we need only change in y direction of mouse wheel here because fovy that is vertical angle is to be manipulated for Zoom in and Zoom Out
       fovy-=Float32(scrollingDeltaY)
        setProjectionMatrix()

    }
    
    //this is the correct view matrix like gluLookAt
    func getViewMatrix(direction:vector_float3,up:vector_float3,position:vector_float3)->matrix_float4x4
    {
        
        
        let norm_dir = vector_normalize(direction)
        let norm_up = vector_normalize(up)
        let norm_right = crossProduct(norm_up,norm_dir)
        

        var view_matrix:matrix_float4x4 = matrix_identity_float4x4
        //column 1
        view_matrix.columns.0 = vector_float4(norm_right.x,norm_right.y,norm_right.z,0.0)
        
        //column 2
        view_matrix.columns.1 = vector_float4(norm_up.x,norm_up.y,norm_up.z,0.0)
        
        //column 3
        view_matrix.columns.2 = vector_float4(norm_dir.x,norm_dir.y,norm_dir.z,0.0)
        
        //column 4
        view_matrix.columns.3 = vector_float4(position.x,position.y,position.z,1.0)
        
        //because we need to apply inverse transformation of camera on our vertices to simulate camera like real world
        view_matrix = matrix_invert(view_matrix)
        
        return view_matrix
        
        
        
        
        
    }
    
    func resetViewMatrix()
    {
        
        position = vector_float3(0.0,0.0,100.0)
        direction = vector_float3(0.0,0.0,1.0)
        up = vector_float3(0.0,-1.0,0.0)
        uniforms.view_matrix = getViewMatrix(direction: direction, up: up, position: position)

    }


}
