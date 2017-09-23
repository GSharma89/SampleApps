//
//  ObjectMeshGenerator.swift
//  Solar System
//
//  Created by Admin on 25/05/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation
import simd


class ObjectMeshGenerator
{
    /*here slices are the number of circles along y-axis from north pole to south pole. slice_triangles are the number of triangles in each slice*/
    func getSphereVerticesMesh(center:float3,radius:Float,slices:UInt, slice_triangles:UInt)->([Vertex],[UInt32])
    {
    
        var vertices = [Vertex]()
        var indices = [UInt32]()
        let pi = Float(M_PI)
        let delta_theta = (2 * pi) / Float(slice_triangles)
        let delta_phi = pi / Float(slices)
        
        var phi:Float = 0;//-Float(M_PI/2)
        for _ in 0...slices
        {
            var theta:Float = 0
            for _ in 0...slice_triangles
            {
              let a = sin(phi) * cos(theta)
              let b = cos(phi)
              let c = sin(phi) * sin(theta)
              
                let pos = Vector4(x:center.x + radius*a,y:center.y + radius*b,z: center.z + radius*c,w:1)
                /*
                 normal of sphere for phi and theta parameter is given by vector (a,b,c).
                 Finding normal of sphere surface
                 --------------------------------
                 1.we have parametric coordinates of sphere as given below-
                 x = r*sin(phi)*cos(theta),y = r*sin(phi)*sin(theta),z=r*cos(theta)
                 where phi is angle between z-axis and point(x,y,z) and theta is angle between x-axis and
                 projectionpoint(x,y,z) in xy plane.r is radius
                 so the equation of surface of sphere is represented as-
                 
                 T = xi + yj + zk
                 2.then find  two tangent vectors in suface T which are T(phi) and T(theta) by partial differentiation of T with respect to phi and theta respectively
                 
                 3.now compute cross product of T(phi) and T(theta) and compute magnitude of resultant cross product.
                 
                 4.now divide cross product vector by magnitude that gives us unit normal vector which is exactly same as we set below.
                 */
                let norm = Vector4(x:a,y:b,z:c,w:0)
                
                /*
                 Finding texture coordinate(u,v) corresponding to point(x,y,z) on sphere surface
                 -------------------------------------------------------------------------------
                 
                 1. we know that theta and phi are the angles which are variable to produce point(x,y,z).so we mapped theta's range which is 0 to 2pi to the width of our 2d texture and similarly phi angle which has range 0 to pi is mapped to height of our 2d texure.
                 
                 2.if (theta,phi) is equal to (2pi,pi) then resulantant point(x,y,z) will be textured by pixel at (1,1) position of our given 2d texture.if (theta,phi) is equal to (0,0) then resultant (x,y,z) will be texture by pixel at (0,0) position of texture.
                 */
                let u = theta / (2*pi)
                
                let v = phi / pi
                
                let tex_cord = TexCoords(u:u,v:v)
                
                let vertex = Vertex(position: pos,normal: norm,texCoords: tex_cord)
                vertices.append(vertex)
                //print("position vector\(slice_triangle_index + slice_index * (slice_triangles+1)):\(vertex.position)")
                theta = theta + delta_theta
              
            }
            
            phi = phi+delta_phi
            
        
        }
        /*
         we can visualize the subdivision of sphere surface in quads such that two points will be on a particular slice and other
         two points will be on just below slice of that particular slice.
         */
        for slice_index in 0..<slices
        {
            for slice_triangle_index in 0..<slice_triangles
            {
                
                //these four indices give us four vertices on shpere surface.these four vertices form a quadilateral by which we
                // form two triangles
                let i0 = UInt32(slice_triangle_index + slice_index * slice_triangles)
                
                //this is to handle a situation when we cross boundary of current slice
                let i1 = ((i0 + 1) %  UInt32(slice_triangles)) + UInt32(slice_index * slice_triangles)
                
                let i2 = i0 + UInt32(slice_triangles)
                
                //this is to handle a situation when we cross boundary of slice next to current slice
                let i3 = ((i2 + 1) %  UInt32(slice_triangles)) + UInt32((slice_index + 1) * slice_triangles)
                
                
                //a triangle vertices' indices
                indices.append(i0)
                indices.append(i1)
                indices.append(i3)
                
                //a triangle vertices' indices
                indices.append(i0)
                indices.append(i3)
                indices.append(i2)
                
                
            }
        }
        
        
     //print("Address of vertices and indices array in ObjectMeshGenerator module:\(vertices[0]) and \(indices[0])")
     return (vertices,indices)
    }
 
    func getQubeMess(side:Float32)->([Vertex],[UInt32])
    {
      var vertices = [Vertex]()
      var indices = [UInt32]()
      var a:Float32 =   1
      var b:Float32 =   1
      var c:Float32 =   1
        let faceToNormalMap: [Int:Vector4] = [0 : Vector4(x:0,y:0,z:-1,w:1),1 : Vector4(x:0,y:0,z:1,w:1),2 : Vector4(x:0,y:-1,z:0,w:1),3 : Vector4(x:0,y:1,z:0,w:1),4 : Vector4(x:-1,y:0,z:0,w:1),5 : Vector4(x:1,y:0,z:0,w:1),]
        
        /*Actually we were getting cube covered with texture wrongly because these texture coordinates are given as per
         texture coordinate system which has +ve y axis upward and +x axis towards right hand side while we must have specified 
         these texture coordinates as per texture image coordinate system which has +y axis downward and +x axis towards right
         hand side as before. 
          */
        let faceToTextureMap:[Int:[TexCoords]] = [0:[TexCoords(u:0.333333,v:0.50),TexCoords(u:0.666666,v:0.50),TexCoords(u:0.333333,v:0.25),TexCoords(u:0.666666,v:0.25)],1:[TexCoords(u:0.333333,v:0.75),TexCoords(u:0.666666,v:0.75),TexCoords(u:0.333333,v:1.0),TexCoords(u:0.666666,v:1.0)],2:[TexCoords(u:0.333333,v:0.50),TexCoords(u:0.666666,v:0.50),TexCoords(u:0.333333,v:0.75),TexCoords(u:0.666666,v:0.75)],3:[TexCoords(u:0.333333,v:0.25),TexCoords(u:0.666666,v:0.25),TexCoords(u:0.333333,v:0),TexCoords(u:0.666666,v:0)],4:[TexCoords(u:0.333333,v:0.50),TexCoords(u:0,v:0.50),TexCoords(u:0.333333,v:0.75),TexCoords(u:0.0,v:0.75)],5:[TexCoords(u:0.666666,v:0.50),TexCoords(u:1,v:0.52),TexCoords(u:0.666666,v:0.75),TexCoords(u:1,v:0.75)]]
        
        var vert_ind = 0
        for i in 0..<6//face index
        {
            c = -1*c
            var tex_cord_index = 0
            
            for _ in 0..<2
            {
                b = -1 * b
                
                for _ in 0..<2
                {
                    a = -1*a
                    var position:Vector4!
                    
                    if(i == 0 || i==1)//specifying xy plane along z-axe,0 is back face,1 is front face
                    {
                        position = Vector4(x: a * side/2,y: b * side/2,z: c * side/2,w: 1)
                        //vertices.append()
                    }
                    else if(i==2 || i==3)//specifying xz plane along y-axe,2 is bottom face,3 is top face
                    {
                        position = Vector4(x: a*side/2,y: c*side/2,z: b*side/2,w:1)
                        
                    }
                    else if(i==4 || i==5)//speciying yz plane along x-axe,4 is left face and 5 is right face
                    {
                        position = Vector4(x:c*side/2,y: a*side/2,z: b*side/2,w:1)
                    }
                    
                    let normal = faceToNormalMap[i]
                    var texCord = faceToTextureMap[i]?[tex_cord_index]
                    /*to solve the problem mentioned above,we substracted each v coordinate from 1 in so that +y axis upward could be treated as downward.now we are getting correct result after adding this line of code*/
                    texCord?.v = 1 - (texCord?.v)!
                    let vertex = Vertex(position:position,normal:normal!,texCoords:texCord!)
                    //print("Vertex \(vert_ind):\(vertex.position) \(vertex.texCoords)")
                    vertices.append(vertex)
                    tex_cord_index = tex_cord_index + 1
                    vert_ind = vert_ind + 1
                    
                    
                }
                
            }
            //if(i == 1)
            //{
            
            indices.append(UInt32(4*i))
            indices.append(UInt32(4*i+1))
            indices.append(UInt32(4*i+2))
            
            indices.append(UInt32(4*i+1))
            indices.append(UInt32(4*i+3))
            indices.append(UInt32(4*i+2))
            
            
        //}
           
            
        }
        
      
        
        
        
      return (vertices,indices)
    }
    
    func getRectangleMess(x:Float32,y:Float32,width:Float32,height:Float32)->([Vertex],[UInt32])
    {
        
        var vertices = [Vertex]()
        var indices =  [UInt32]()
        var position = Vector4(x:x,y:y,z:0,w:1)
        var textCord = TexCoords(u:0,v:0)
        let normal = Vector4(x:0,y:0,z:1,w:1)//z axis
        vertices.append(Vertex(position: position,normal: normal,texCoords: textCord))
        
        position = Vector4(x:x+width,y:y,z:0,w:1)
        textCord = TexCoords(u:1,v:0)
        
        vertices.append(Vertex(position: position,normal: normal,texCoords: textCord))
        
        position = Vector4(x:x+width,y:y+height,z:0,w:1)
        textCord = TexCoords(u:1,v:1)
        
        vertices.append(Vertex(position: position,normal: normal,texCoords: textCord))
        
        position = Vector4(x:x,y:y+height,z:0,w:1)
        textCord = TexCoords(u:0,v:1)
        vertices.append(Vertex(position: position,normal: normal,texCoords: textCord))

        indices.append(0)
        indices.append(1)
        indices.append(2)
        
        indices.append(2)
        indices.append(3)
        indices.append(0)
        
        return (vertices,indices)
        
    }
    
}
