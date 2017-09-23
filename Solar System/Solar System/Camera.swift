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
    private var cameraPos:float3//this is the position where camera is placed in world coordinate system
    private var cameraTarget:float3//this is the direction vector toward which camera is looking
    private var cameraUP:float3//this is up direction which rotates camera around z-axis.this is the angle which is roll.
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
        pitch = -90
        cameraPos = float3(0.0,0.0,200.0)
        cameraTarget = float3(0.0,0.0,1.0)
        cameraUP = float3(0.0,1.0,0.0)
        fovy = 45.0
        viewingWidth = 0.0
        viewingHeight = 0.0
        near = 0.1
        far = 100000000000000000000
        deltaTime = 0.0
        cameraSpeedFactor = 200.5
        sensitivity = 0.2
        lastMousePosX = 0.0
        lastMousePosY = 0.0
        uniforms = Uniforms()
        setViewMatrix(target: cameraTarget, up: cameraUP, eye: cameraPos)
    }
    
    func updateCamera()
    {
       
        
        

       
       
    }
    private func setProjectionMatrix()
    {
        
        //print("setProjection is called")
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
        
        
        
        let d =  1/tan(fovy * 0.5 * Float(M_PI) / 180 )
        let aspectRatio = viewingWidth / viewingHeight
        
        uniforms.proj_matrix[0][0] = d/aspectRatio
        uniforms.proj_matrix[1][1] = d
        uniforms.proj_matrix[2][2] = -(far+near)/(far-near)
        uniforms.proj_matrix[2][3] = -1
        uniforms.proj_matrix[3][2] = -2*far*near/(far-near)
        uniforms.proj_matrix[3][3] = 0
        //print("Projection Matrix:\(uniforms.proj_matrix)")
                                
    }
    func handleMouseMove(posx:Float32,posy:Float32)
    {
        /*Ensuring here that mouse position is within our rendering window frame*/
        
        if(posx>=0 && posy>=0)
        {
            if(posx<=viewingWidth && posy<=viewingHeight )
            {
               // print("Posx:\(posx) and Posy:\(posy)")
                /*var xOffset = Float32(posx) - lastMousePosX
                var yOffset = Float32(posy) - lastMousePosY
                lastMousePosX = Float32(posx)
                lastMousePosY = Float32(posy)
                xOffset*=sensitivity
                yOffset*=sensitivity
        
                yaw+=xOffset
                pitch+=yOffset*/
                
                yaw = ((Float32(posx))/viewingWidth ) * 2 * 180 * sensitivity
                pitch = ((Float32(posy))/viewingHeight) * 180 * sensitivity
                //Swift.print("Camera Yaw:\(yaw)")
                //Swift.print("Camera pitch:\(pitch)")
        
                let cosPitch = cos(3.141592*pitch/Float(180))
                let sinPitch = sin(3.141592*pitch/Float(180))
                let cosYaw = cos(3.141592*yaw/Float(180))
                let sinYaw = sin(3.141592*yaw/Float(180))
        
                //setting camera target
                cameraTarget.x = sinPitch * cosYaw//cosYaw*cosPitch
                cameraTarget.y = cosPitch//sinPitch
                cameraTarget.z = sinPitch * sinYaw//sinYaw*cosPitch
        
                let right = float3(cosPitch,0,sinPitch)
                //setting camera up direction
                cameraUP = normalize(cross(right, cameraTarget))
        
                //setting camera position
                cameraPos.x = posx//sinPitch * cosYaw
                cameraPos.y = posy//cosPitch
                //cameraPos.z = //sinPitch * sinYaw
            }
        }
        setViewMatrix(target: cameraTarget, up: cameraUP, eye: cameraPos)
    }
    
    
    func handleKeyBoardEvent(eventType:KeyBoardEventType,key:String)
    {
        
        if(eventType == .KEY_DOWN)
        {
            switch key
            {
            case "L","l"://left
                
                cameraPos-=normalize(cross(cameraTarget, cameraUP)) * cameraSpeedFactor * deltaTime

                break;
            case "R","r"://right
                
                cameraPos+=normalize(cross(cameraTarget, cameraUP)) * cameraSpeedFactor * deltaTime
                break;
        
            case "U","u"://up
                
                cameraPos+=cameraSpeedFactor * deltaTime * cameraUP
                break;
            
            case "D","d"://down
                
                cameraPos-=cameraSpeedFactor * deltaTime * cameraUP
                break;
            
            case "F","f"://forward
                
                
                cameraPos+=cameraSpeedFactor * deltaTime * cameraTarget
                break;
            case "B","b"://backward
                
                
                cameraPos-=cameraSpeedFactor * deltaTime * cameraTarget
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
    
        setViewMatrix(target: cameraPos+cameraTarget, up: cameraUP, eye: cameraPos)
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
    func setViewMatrix(target:float3,up:float3,eye:float3)
    {
        
        /*Actually camera points towards -z axis direction and we are setting up here camera space so we need to get camera's +z direction.
         if we substract eye position i.e. camera position from target then we will get camera's -z axis that'why we negate this substraction so that
         we could get camera's +z direction*/
        
        let temp_axis = -(target-eye)
        
        let l = sqrt((temp_axis.x*temp_axis.x)+(temp_axis.y*temp_axis.y)+(temp_axis.z*temp_axis.z))
        
        let zaxis = float3(temp_axis.x/l,temp_axis.y/l,temp_axis.z/l)//normalized forward axis
        
        let a1 = up.x
        let b1 = up.y
        let c1 = up.z
        
        let a2 = zaxis.x
        let b2 = zaxis.y
        let c2 = zaxis.z
        
        //print("zaxis:(\(a2) ,\(b2),\(c2))")
        let a = (b1 * c2 - c1*b2)
        let b = -(a1*c2 - c1*a2)
        let c = (a1*b2 - b1*a2)
        let length_of_vector = sqrt(a*a+b*b+c*c)
        
        let xaxis = float3(a/length_of_vector,b/length_of_vector,c/length_of_vector)//right axis of camera
        
        let a3 = xaxis.x
        let b3 = xaxis.y
        let c3 = xaxis.z
        
        //print("xaxis:(\(a3) ,\(b3),\(c3))")
        
        let x1 = (b2*c3 - c2*b3)
        let y1 = -(a2*c3 - a3*c2)
        let z1 = (a2*b3 - b2*a3)
        
        let yaxis = float3(x1,y1,z1)//up axis of camera
        
        //print("yaxis:(\(x1) ,\(y1),\(z1))")
        
        /*
         |xaxis.x    xaxis.y   xaxis.z  0|          |1    0   0  -ex|
         |yaxis.x    yaxis.y   yaxis.z  0|    X     |0    1   0  -ey|
         |zaxis.x    zaxis.y   zaxis.z  0|          |0    0   1  -ez|
         |    0        0           0    1|          |0    0   0    1|
         
         */
        
        
        //column 1
        uniforms.view_matrix[0][0] = xaxis.x
        uniforms.view_matrix[0][1] = yaxis.x
        uniforms.view_matrix[0][2] = zaxis.x
        //uniforms.view_matrix[0][3] = -(eye.x * xaxis.x + eye.y * xaxis.y + eye.z*xaxis.z)
        //column 2
        uniforms.view_matrix[1][0] = xaxis.y
        uniforms.view_matrix[1][1] = yaxis.y
        uniforms.view_matrix[1][2] = zaxis.y
        //uniforms.view_matrix[1][3] = -(eye.x * yaxis.x + eye.y * yaxis.y + eye.z*yaxis.z)
        
        //column 3
        uniforms.view_matrix[2][0] = xaxis.z
        uniforms.view_matrix[2][1] = yaxis.z
        uniforms.view_matrix[2][2] = zaxis.z
        //uniforms.view_matrix[2][3] = -(eye.x * zaxis.x + eye.y * zaxis.y + eye.z*zaxis.z)
        //column 4
        uniforms.view_matrix[3][0] = -(eye.x * xaxis.x + eye.y * xaxis.y + eye.z*xaxis.z)
        uniforms.view_matrix[3][1] = -(eye.x * yaxis.x + eye.y * yaxis.y + eye.z*yaxis.z)
        uniforms.view_matrix[3][2] = -(eye.x * zaxis.x + eye.y * zaxis.y + eye.z*zaxis.z)
        
        //print("camera target:\(xaxis)")
        //print("camera position\(yaxis)")
        //print("camera Up:\(zaxis)")
        //print("view matrix:\(uniforms.view_matrix)")
        
        
    }
    


}
