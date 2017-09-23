


import Foundation
import MetalKit
class Model
{
    var name:String!
    var transform:Transform!
    var meshGenerator:ObjectMeshGenerator!
    var textureLoader:TextureLoader!
    var device:MTLDevice!
    var type:ModelType!
    var parent:Model!
    var childModels = [Model]()
    var textureImage:String!
    init(id:String,device:MTLDevice,modelType:ModelType,meshGenerator:ObjectMeshGenerator,textureLoader:TextureLoader,parentModel:Model?,imageName:String?)
    {
        name = id
        type = modelType
        parent = parentModel
        self.device = device
        transform = Transform()
        self.meshGenerator = meshGenerator
        self.textureLoader = textureLoader
        textureImage = imageName
        
    }
    
    func update(frameNo:Int32)
    {
        
       
        switch type! {
        
        
        case .Planet:
            
            let planet = self as! Planet
            
            if(planet.animate)
            {
                
                /*Here we have taken revolution rate and rotation rate differently with respect of number of frames.
                
                Planet spinning days to frames mapping for rotation of planet about their own axe
                ---------------------------------------------------------------------------------
                1.I have taken 360 frames per earth day for rotation.it means that 360 frames are equal to 1 day and if
                any planet takes n days to be rotated 360 degree around its own axe then in this application, planet will
                complete its 360 degree rotation in n*360 frames.
                
                Planet revolution days to frames mapping for revolution of planet about sun
                ---------------------------------------------------------------------------
                
                2.I have taken 1 frame per earth day for revolution.it means that if any planet takes n days to complete its on revolution around sun then in this application,it will take 1*n frames to complete one revolution around sun.
                */
                
                let revolve_period = planet.no_of_days_to_be_revolved
                
                let framesPerRevolution = Int32(1 * planet.no_of_days_to_be_revolved)
                
                let revolve_angle = (360.0/Float(1 * revolve_period)) * Float((frameNo % framesPerRevolution))
                
                let rotate_period = planet.rotate_period
                
                let framesPerRotation = Int32(360 * planet.rotate_period)
                
                let rotate_angle = (360.0/Float(360 * rotate_period)) * Float((frameNo % framesPerRotation))
                transform.model_matrix = matrix_identity_float4x4
                transform.model_matrix = matrix_multiply(getScaleMatrix(transform.scale.x, y: transform.scale.y, z: transform.scale.z), transform.model_matrix)
                transform.model_matrix = matrix_multiply(getRotationAroundY(Float(Double.pi) * (rotate_angle/180)), transform.model_matrix)
                transform.model_matrix = matrix_multiply(getTranslationMatrix(transform.position), transform.model_matrix)
                transform.model_matrix = matrix_multiply(getRotationAroundY(Float(Double.pi) * (revolve_angle/180)), transform.model_matrix)
                

            }
            break
            
            
            
        case .Cube:
            
            transform.rotation = vector_float3(Float(Double(frameNo)*0.05))
            transform.model_matrix = matrix_identity_float4x4
            /*transform.model_matrix = matrix_multiply(getRotationAroundX(transform.rotation.x), transform.model_matrix)
            transform.model_matrix = matrix_multiply(getRotationAroundY(transform.rotation.y), transform.model_matrix)
            transform.model_matrix = matrix_multiply(getRotationAroundZ(transform.rotation.z), transform.model_matrix)*/
            //transform.model_matrix = matrix_multiply(getTranslationMatrix(transform.position+vector_float4(Float(Double(frameNo)*0.05),0,0,0)), transform.model_matrix)
           
            
            break
            
        case .Rect:
            
            print("Animation is not supported on Rect")
            
            break
        
        default:
            //print("Type is mismatched")
            
            break
            }
        
        for child in childModels
        {
            child.update(frameNo: frameNo)
        }
    }
    
    func addPlanetModel(id:String,textureImage:String,device:MTLDevice)->Model?
    {
        var planet:Planet! = nil
        if(type == ModelType.Group )
        {
            planet = Planet.init(name: id,  textureImage: textureImage, type: .Planet, device:self.device,
                                 meshGenerator:meshGenerator,textureLoader:textureLoader,parent:self)
            childModels.append(planet)
        }
        return planet
    }
    
    func addCubeModel(id: String, device: MTLDevice,imageName:String)->Model?
    {
        var cube:Cube! = nil
        if(type == ModelType.Group)
        {
            cube = Cube.init(modelName: id, device: device, modelType: .Cube , textureImage: imageName, meshGenerator: meshGenerator, textureLoader: textureLoader, parent: self)
            childModels.append(cube)
        }
        return cube
    }
    
    func addRectModel(id: String, device: MTLDevice, modelType: ModelType,textureImage:String)->Model?
    {
        var rect:Rect!
        if(type == ModelType.Rect)
        {
        
        rect = Rect.init(modelName: id, device: device, modelType: .Rect, textureImage: textureImage, meshGenerator: meshGenerator, textureLoader: textureLoader, parent: self)
            childModels.append(rect)
        }
        return rect
    }
    func getLeafModelCount()->Int
    {
        var count = 0
        if(type != ModelType.Group)
        {
            count += 1
        }
        else
        {
            for child in childModels
            {
                count = count + child.getLeafModelCount()
            }
        }
        return count
    }
    
        
    func updateModelsMess(modelMessList:[ModelType:ModelMess])
    {
        
        if(type != .Group)
        {
            let mess = modelMessList[type]
            var messData:([Vertex],[UInt32])? = nil
            switch type!
            {
                case .Planet:
                
                    if(mess?.verticesBuffer == nil)
                    {
                        messData = meshGenerator.getSphereVerticesMesh(center: float3(0,0,0), radius: 1, slices: 1000, slice_triangles: 400)
                        
                    }
                   break
        
            case .Cube:
                    if(mess?.verticesBuffer == nil)
                    {
                        messData = meshGenerator.getQubeMess(side: 1)
                    }
                
                break
            case .Rect:
                    if(mess?.verticesBuffer == nil)
                    {
                        messData = meshGenerator.getRectangleMess(x: 0, y: 0, width: 1, height: 1)
                    }
                    break
        
             default:
                    print("No model matched")
            
                    break
        
        
        }
        
        if(mess?.verticesBuffer == nil)
        {
            mess?.verticesBuffer = device.makeBuffer(bytes: (messData?.0)!, length: MemoryLayout<Vertex>.stride * (messData?.0.count)!, options: .storageModeShared)
            mess?.indicesBuffer = device.makeBuffer(bytes: (messData?.1)!, length: MemoryLayout<UInt32>.size * (messData?.1.count)!, options: .storageModeShared)
            mess?.index_count = (messData?.1.count)!
        }
        mess?.instance_count = (mess?.instance_count)! + 1
        
       
        mess?.modelTransformArray.append(transform.model_matrix)
        mess?.textureImagesArray.append(textureImage)
        
    
        }
        for child in childModels
        {
            child.updateModelsMess(modelMessList: modelMessList)
        }
    }
    
}

