
/*In This application,we are using right handed world coordinate system.that means +ve z axis is towards us and negative
 z axis is going through screen*/

import MetalKit

class  Renderer: NSViewController,MTKViewDelegate {
    
    private var commandQueue:MTLCommandQueue! = nil
    private var renderPipeline: MTLRenderPipelineState! = nil
    private var sampler:MTLSamplerState!
    private var depthStencilState:MTLDepthStencilState!
    private var rotate_angle:Float32 = 0
    private var camera:Camera!
    private var uniformBuffer:MTLBuffer!
    private var models = [Model]()
    private var device:MTLDevice!
    private var frame_count:Int32 = 0
    private var lastFrameTime:Float32 = 0.0
    private var modelTransformBuffer:MTLBuffer!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("metal can't be inialized")
            exit(0)
        }
        self.device = device
        
        let view  = self.view as!MTKView
        view.delegate = self
        view.device = device
        view.sampleCount = 4
        setUpMetalPipeline()
        camera = Camera()
        camera.viewingWidth = Float32((view.window?.frame.width)!)
        camera.viewingHeight = Float32((view.window?.frame.height)!)
        let eventHandler = EventHandler(camera:camera,frame: view.frame)
        self.view.addSubview(eventHandler)//it is needed because this is the object on which mouseDown,mouseMove or keyDown function will be called by Window object
        //setting window delegate to window object
        view.window?.delegate = eventHandler
        //print("window width:\(camera.viewingWidth)")
        //print("window height:\(camera.viewingHeight)")
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.size, options: [])
        modelTransformBuffer = device.makeBuffer(length: MemoryLayout<float4x4>.size, options: [])
        /*we draw it only once because background is static.*/
        /*This is the background rectangle specified relative to the bottom-left corner of our app's window because this corner
         is origin of our app's window.we have give posx and posy origin of our background rect that will coincide on our app's origin.
         below this rectangle's origin is converted as per world coordinate system.*/
        //let posx=Float32(0)
        //let posy=Float32(0)
        //let width=Float32((view.window?.frame.width)!)
        //let height=Float32((view.window?.frame.height)!)
        
        
        /*Our world coordinate system has the origin(0,0,0) at center of our App window so every 2d or 3d object must be specified
         relative to app's window's origin so if we want to specify a background rectangle that will overlap our window then this
         background's origin will be (-windowWidth/2,-windowHeight/2) relative to our app's window's center because world coordinate
         system's origin(0,0,0) is mapped to our app's window's center.*/
        //let rectx = posx-Float32((view.window?.frame.width)!)/2//relative to world coordinate system's origin
        //let recty = posy-Float32((view.window?.frame.height)!)/2//relative to world coordinate system's origin
        
        //models.append(Rect(x: rectx, y: recty, width: width, height: height , modelName: "Background", device: device, modelType:ModelType.Rect, textureImage: "Space"))
        
        let backGroundSpace = Planet(name:"BackgroundHemiSphere",center:float3(0,0,200),radius:11000,textureImage:"Space",type: ModelType.Planet,device: device)
        //backGroundSpace.transform.appendRotation(angle_in_deg: 30, Axis: "z")
        //backGroundSpace.transform.setPivotPoint(px: 0, py: 0, pz: 200)
        models.append(backGroundSpace)
        
        models.append(Planet(name: "Sun",center:float3(0,0,0),radius:15,textureImage:"sun",type: ModelType.Planet,device: device))
        models.append(Planet(name: "Mercury", center: float3(40,-3,-20), radius: 1, textureImage: "mercury",type: ModelType.Planet,device: device))
        models.append(Planet(name: "Venus", center: float3(60,-3,-15), radius: 2, textureImage: "venus",type: ModelType.Planet,device: device))
        models.append(Planet(name: "Earth", center: float3(80,-3,-10), radius: 3, textureImage: "Earth",type: ModelType.Planet,device: device))
        models.append(Planet(name: "Mars", center: float3(100,-3,-5), radius: 4, textureImage: "mars",type: ModelType.Planet,device: device))
        models.append(Planet(name: "Jupiter", center: float3(120,-3,0), radius: 5, textureImage: "Jupiter",type: ModelType.Planet,device: device))
        
        
        //let cube = Cube(cubeSide: 1, modelName: "Cube", device: device, modelType: ModelType.Cube, textureImage:"dice2" )
        //let transform = cube.transform
        //transform?.appendTranslation(tx: 5, ty: 10, tz: 5)
        //transform?.setRotation(angle_in_deg: 89, Axis: "x")
        //transform?.setPivotPoint(px: 0, py: 0, pz: 0.5)
        //models.append(cube)
        
        
        
        
        
    }
    private func setUpMetalPipeline()
    {
        
        
        commandQueue = device?.makeCommandQueue()
        
        let samplerStateDescrip = MTLSamplerDescriptor()
        samplerStateDescrip.minFilter = MTLSamplerMinMagFilter.linear
        samplerStateDescrip.magFilter = MTLSamplerMinMagFilter.linear
        samplerStateDescrip.mipFilter = MTLSamplerMipFilter.linear
        samplerStateDescrip.sAddressMode = MTLSamplerAddressMode.clampToEdge
        samplerStateDescrip.tAddressMode = .clampToEdge
        samplerStateDescrip.rAddressMode = .clampToEdge
        samplerStateDescrip.normalizedCoordinates = true
        samplerStateDescrip.lodMinClamp = 0
        samplerStateDescrip.lodMaxClamp = FLT_MAX
        sampler = device?.makeSamplerState(descriptor: samplerStateDescrip)
        
        //metal library creation
        let defaultLibrary = device?.newDefaultLibrary()
        let vert_func = defaultLibrary?.makeFunction(name: "vertexShader" )
        let frag_func = defaultLibrary?.makeFunction(name: "fragmentShader")
        let vertexDescriptor = MTLVertexDescriptor()
        //vertex descriptor creation
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float32>.size * 4
        vertexDescriptor.attributes[2].bufferIndex = 0
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = 8 * MemoryLayout<Float32>.size
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.size
        vertexDescriptor.layouts[0].stepFunction = .perVertex
         //renderstatepipline creation
        let renderPipelineDesc = MTLRenderPipelineDescriptor()
        renderPipelineDesc.colorAttachments[0].pixelFormat = (self.view as!MTKView).colorPixelFormat
        renderPipelineDesc.sampleCount = (self.view as!MTKView).sampleCount
        renderPipelineDesc.vertexFunction = vert_func
        renderPipelineDesc.fragmentFunction = frag_func
        renderPipelineDesc.vertexDescriptor = vertexDescriptor
        do
        {
        try renderPipeline = device?.makeRenderPipelineState(descriptor: renderPipelineDesc)
        
        }
        catch _
        {
         print("Unable to create render pipeline state")
        }
        let depthStencilDesc = MTLDepthStencilDescriptor()
        depthStencilDesc.depthCompareFunction = .less
        depthStencilDesc.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDesc)
        
        
    }

    func draw(in view: MTKView)
    {
        
        //here we are getting current absolute system time in seconds
        camera.deltaTime = Float32(CACurrentMediaTime())-lastFrameTime
        lastFrameTime = Float32(CACurrentMediaTime())
        //print("Delta Time:\(camera.deltaTime)")
        //print("last frame time:\(lastFrameTime)")
        let commandBuffer = commandQueue.makeCommandBuffer()
        if let currentPassDesc = view.currentRenderPassDescriptor
        {
            
            for model in models
            {
                
                let transform = model.transform
                //let angle = frame_count /*% Int32(360)*/
                //transform?.setTranslate(tx: 1, ty: 1, tz: 0)
                //transform?.setRotation(angle_in_deg: Float(Double(angle)*0.5), Axis: "x")
                //transform?.setPivotPoint(px: 0, py: 0, pz: -400)
                //transform?.appendRotation(angle_in_deg: Float(angle), Axis: "y")
                if(model.type == ModelType.Planet)
                {
                    let planet = model as! Planet
                    let pivot = planet.center!
                /* 
                 Here we have taken revolution rate and rotation rate differently with respect of number of frames.
                 
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
                
                let revolve_angle = (360.0/Float(1 * revolve_period)) * Float((frame_count % framesPerRevolution))
                
                let rotate_period = planet.rotate_period
                
                let framesPerRotation = Int32(360 * planet.rotate_period)
                
                let rotate_angle = (360.0/Float(360 * rotate_period)) * Float((frame_count % framesPerRotation))
                
                /*print("Name of Planet:\(planet.name!)")
                print("Rotate Angle:\(rotate_angle)")
                print("Revolve Angle:\(revolve_angle)")*/
                    if(planet.name != "Sun" && planet.name != "BackgroundHemiSphere")
                    {
                        transform?.setRotation(angle_in_deg: (-rotate_angle), Axis: "y")
                        transform?.setPivotPoint(px: pivot.x, py: pivot.y, pz: pivot.z)
                        transform?.appendRotation(angle_in_deg: (-revolve_angle), Axis: "y")
                    }
            
            }
                
                memcpy(uniformBuffer.contents(), &camera.uniforms, MemoryLayout<Uniforms>.size)
                
                var modelMatrix = transform?.getModelTransform()
                
                //memcpy(modelTransformBuffer.contents(), &modelMatrix, MemoryLayout<float4x4>.size)
            
                let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentPassDesc)
                //renderCommandEncoder.setDepthStencilState(depthStencilState)
                
                //renderCommandEncoder.setCullMode(.back)
                renderCommandEncoder.setRenderPipelineState(renderPipeline)
            
                renderCommandEncoder.setVertexBuffer(model.vertexBuffer, offset: 0, at: 0)
                renderCommandEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
                renderCommandEncoder.setVertexBytes(&modelMatrix, length: MemoryLayout<float4x4>.size, at: 2)
                //renderCommandEncoder.setVertexBuffer(modelTransformBuffer, offset: 0, at: 2)
                renderCommandEncoder.setFragmentTexture(model.texture, at: 0)
                renderCommandEncoder.setFragmentSamplerState(sampler, at: 0)
            
                renderCommandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: model.mess.1.count, indexType: .uint32, indexBuffer: model.indexBuffer, indexBufferOffset: 0)
                renderCommandEncoder.endEncoding()
                /*Because we get new currentPassDesc each time with default load action that is clear for each model so if we would not use this
                 flag then only last model in rendering order will be displayed and rest of models will be cleared.this flag tells metal
                 to preserve all models in render target.*/
                currentPassDesc.colorAttachments[0].loadAction = .dontCare
                
               
                
            }
            let currentDrawable = view.currentDrawable
            commandBuffer.present(currentDrawable!)
        }
        
        
        commandBuffer.commit()
        
        frame_count = frame_count + 1
        
        
        
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
}
