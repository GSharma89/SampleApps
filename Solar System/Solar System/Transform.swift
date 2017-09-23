//
//  Transform.swift
//  Solar System
//
//  Created by Admin on 29/05/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//


import Foundation

import simd


class Transform
{
    private var model_matrix: float4x4
    private var Identity: float4x4
    init() {
        
        let col1: float4 = [1,0,0,0]
        let col2: float4 = [0,1,0,0]
        let col3: float4 = [0,0,1,0]
        let col4: float4 = [0,0,0,1]
        
        
        Identity = float4x4.init([col1,col2,col3,col4])
        model_matrix = Identity
        
    }
    
    func setTranslate(tx: Float, ty: Float,tz: Float)
    {
        model_matrix = Identity//removing previous values
        model_matrix[3][0] = tx
        model_matrix[3][1] = ty
        model_matrix[3][2] = tz
    }
    func setScale(sx: Float,sy:Float,sz:Float)
    {
        model_matrix = Identity//removing previous values
        model_matrix[0][0] = sx
        model_matrix[1][1] = sy
        model_matrix[2][2] = sz
    }
    func setRotation(angle_in_deg: Float,Axis: Character)
    {
        var angle_in_rad:Float = 0.0
        if(angle_in_deg<0)//-ve sign represents the anticlock wise rotation
        {
            angle_in_rad = 3.141592 * (360.0 + angle_in_deg)/Float(180)//for anticlock wise rotation
        }
        else
        {
            
            angle_in_rad = 3.141592 * angle_in_deg/Float(180)
        }
        
        let a = cos(angle_in_rad)
        
        let b = sin(angle_in_rad)
        
        model_matrix = Identity
        
        
        switch Axis
        {
        case "z","Z":
            
            model_matrix[0][0] = a
            
            model_matrix[0][1] = b
            
            model_matrix[1][0] = -b
            
            model_matrix[1][1] = a
            break
            
        case "y","Y":
            
            model_matrix[0][0] = a
            
            model_matrix[0][2] = -b
            
            model_matrix[2][0] = b
            
            model_matrix[2][2] = a
            break
            
        case "x","X":
            
            model_matrix[1][1] = a
            
            model_matrix[1][2] = b
            
            model_matrix[2][1] = -b
            
            model_matrix[2][2] = a
            break
            
        default:
            print("Wrong Axiz is given")
            
            
            
        }
    }
    
    func appendTranslation(tx: Float, ty: Float,tz: Float)
    {
        var trans_mat: float4x4 = Identity
        trans_mat[3][0] = tx
        trans_mat[3][1] = ty
        trans_mat[3][2] = tz
        
        model_matrix = trans_mat*model_matrix
        
    }
    func appendScaling(sx: Float,sy: Float,sz: Float)
    {
        var scal_matrix = Identity
        
        scal_matrix[0][0] = sx
        scal_matrix[1][1] = sy
        scal_matrix[2][2] = sz
        model_matrix = scal_matrix*model_matrix
    }
    
    func appendRotation( angle_in_deg: Float,Axis: Character)
    {
        var angle_in_rad:Float = 0.0
        if(angle_in_deg<0)//-ve sign represents the anticlock wise rotation
        {
         angle_in_rad = 3.141592 * (360.0 + angle_in_deg)/Float(180)//for anticlock wise rotation
        }
        else
        {
        
            angle_in_rad = 3.141592 * angle_in_deg/Float(180)
        }
        
        let a = cos(angle_in_rad)
        
        let b = sin(angle_in_rad)
        
        
        var rotate_matrix = Identity
        
        
        switch Axis
        {
        case "z","Z":
            
            rotate_matrix[0][0] = a
            
            rotate_matrix[0][1] = b
            
            rotate_matrix[1][0] = -b
            
            rotate_matrix[1][1] = a
            break
            
        case "y","Y":
            
            rotate_matrix[0][0] = a
            
            rotate_matrix[0][2] = -b
            
            rotate_matrix[2][0] = b
            
            rotate_matrix[2][2] = a
            break
            
        case "x","X":
            
            rotate_matrix[1][1] = a
            
            rotate_matrix[1][2] = b
            
            rotate_matrix[2][1] = -b
            
            rotate_matrix[2][2] = a
            break
            
        default:
            print("Wrong Axiz is given")
            
            
            
        }
        model_matrix = rotate_matrix*model_matrix
        
        
    }
    
       
    func getModelTransform()->float4x4
    {
        
        return model_matrix
    }
    func setPivotPoint(px: Float,py:Float,pz:Float)
    {
        var trans = Identity;
        var inv_trans = Identity;
        trans[3][0] = px;trans[3][1] = py; trans[3][2] = pz
        inv_trans[3][0] = -px;inv_trans[3][1] = -py; inv_trans[3][2] = -pz
        
        model_matrix = trans*model_matrix*inv_trans
        
    }
            
}

