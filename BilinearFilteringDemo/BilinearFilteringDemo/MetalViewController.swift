import Cocoa
import MetalKit
import simd

let vertices :[Float] = [
    
    //position    //texture cordinate
    -1,1,1,1,     0,0,
    -1,-1,1,1,    0,1,
    1,1,1,1,     1,0,
    
    1,1,1,1,     1,0,
    1,-1,1,1,    1,1,
    -1,-1,1,1,   0,1
    
]


class MetalViewController: NSViewController,MTKViewDelegate
{
    private var device:MTLDevice!
    /*this buffer is for storing number of pixels color values which are found same between custom bilinear and built-in 
     bilinear filtering*/
    private var countBuffer:MTLBuffer!
    /*this buffer is to provide the image dimension to the fragment shader for calculating the the pixel color as per bilinear filtering*/
    private var imageDimensionBuffer:MTLBuffer!
    /*this buffer is for vertex shader to use vertex and texture coordinate to apply transformation*/
    private var verticesBuffer:MTLBuffer!
    /*This is the input texture in which given image is loaded*/
    private var inputTexture:MTLTexture!
    /* this is the texture for storing contents of default frame buffer when pipelinestate1 is specified to the renderCommandEncoder*/
    private var texture1:MTLTexture!
    /*This texture works as framebuffer where color values are stored in the format of rgba8Unorm.this texture is created because we can't read color values
     of default framebuffer which is attached to view of this view controller because default framebuffer is restricted for being accessed by renderCommandEncoder,
     blitCommandEncoder and computeCommandEncoder as a argument.*/
    private var renderTarget:MTLTexture!
    /* this is custom depth texture which will be associted renderPassDescriptor created by application*/
    private var depthTexure: MTLTexture!
    
    
    private var renderPassDescriptor:MTLRenderPassDescriptor!
    /*this pipeline state is for specifying fragment shader function which has implementation of custom bilinear filtering*/
    private var pipelineState1:MTLRenderPipelineState!
    /*this pipeline state is for specifying frament shader which uses metal built-in bilinear filtering implementation*/
    private var pipelineState2:MTLRenderPipelineState!
    /*this computePipeline state is for specifying the kernel function which compares corresponding pixel values between 
     texture1 and contents for default frame buffer which is updated in pipelineState2*/
    private var computePipelineState:MTLComputePipelineState!
    
    private var commandQueue:MTLCommandQueue!
    
    
    private var computeFunctionLibrary:MTLLibrary!
    private var renderFunctionLibrary:MTLLibrary!
    private var imageDimension:uint2!
    
    private var sampler:MTLSamplerState!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allocateMetalResources()
    }

    private func allocateMetalResources()
    {
        device = MTLCreateSystemDefaultDevice()
        guard device != nil else
        {
            print("Metal does not support to device")
            return
        }
        computeFunctionLibrary = device.newDefaultLibrary()
        renderFunctionLibrary = device.newDefaultLibrary()
        
        commandQueue = device.makeCommandQueue()
        
        let view = self.view as! MTKView
        view.delegate = self
        view.device = device
        view.framebufferOnly = false
        //view.colorPixelFormat = .rgba8Unorm
        print("width of view:\(view.frame.width)")
        print("height of view:\(view.frame.height)")
        print("Pixel format of framebuffer:\(view.colorPixelFormat.rawValue)")
        print("width of color attachment texture:\(view.currentRenderPassDescriptor?.colorAttachments[0].texture?.width)")
        print("height of color attachement texture:\(view.currentRenderPassDescriptor?.colorAttachments[0].texture?.height)")
        
        let textureDiscrip = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:view.colorPixelFormat, width: 1120, height: 800, mipmapped: false)
        
        texture1 = device.makeTexture(descriptor: textureDiscrip)
        
        //renderTarget = device.makeTexture(descriptor: textureDiscrip)
        //let depthTextDescrip = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: Int(view.frame.width), height: Int(view.frame.height), mipmapped: false)
        
        //depthTexure =  device.makeTexture(descriptor: depthTextDescrip)
        
        
        
        /*renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture1
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0,green: 0.0,blue: 0.0,alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.depthAttachment.texture = depthTexure*/
        
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
        sampler = device.makeSamplerState(descriptor: samplerStateDescrip)
        
        imageDimension = uint2(0,0)
        loadImage()
        
        setUpRenderPipelineStates()
        
        setUpComputePipelineState()
        
        allocateBuffers()
        
        
        
    }
    private func loadImage()
    {
        let image = NSImage(named:"healthy_food")
        let cgimage = image?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let size  = image?.size
        let width = Int((size?.width)!)
        let height = Int((size?.height)!)
        /*setting image dimension*/
        imageDimension.x = UInt32(width)
        imageDimension.y = UInt32(height)
        print("The width of Image:\(width)")
        print("The Height of Image:\(height)")
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * width
        
        var rawData = [UInt8](repeating:0,count: bytesPerRow * height)
        let bitMapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let colorSpace = cgimage?.colorSpace
        print("color space of input image:\(colorSpace!)")
        let context = CGContext(data:&rawData,width: width,height:height,bitsPerComponent:bitsPerComponent,bytesPerRow:bytesPerRow,space:colorSpace!,bitmapInfo:bitMapInfo.rawValue)
        
        let rect = CGRect.init(x:0,y:0,width:width,height:height)
        
        context?.draw(cgimage!, in: rect)
        
        let textureDiscriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        
        inputTexture = device.makeTexture(descriptor: textureDiscriptor)
        
        let region = MTLRegion(origin: MTLOrigin(x:0,y:0,z:0),size: MTLSize(width:width,height:height,depth:1))
        
        inputTexture.replace(region: region, mipmapLevel: 0, withBytes: &rawData, bytesPerRow: bytesPerRow)
        
        //createNSImage(texture: inputTexture)
        
        
        
    }
    
    func createNSImage( texture:MTLTexture)
    {
        let width = texture.width
      
        let height = texture.height
      
        let rowbytes = 4*width
        
        var rawData = malloc(rowbytes*height)
        
        
        texture.getBytes(&rawData, bytesPerRow: rowbytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        let bitMapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let colorspace  = CGColorSpaceCreateDeviceRGB()
        let dataProvider = CGDataProvider(data:NSData(bytes:rawData,length:rowbytes))
        
        let cgImage = CGImage(width:width,height:height,bitsPerComponent:8,bitsPerPixel:32,bytesPerRow:rowbytes,space:colorspace,bitmapInfo:bitMapInfo,provider: dataProvider!,decode:nil,shouldInterpolate:false,intent:CGColorRenderingIntent.defaultIntent)
        
        //let nsimage = NSImage(cgImage: cgImage!,size: NSSize(width:width,height:height))
    
        
        
            
        
        
        
    }
    private func setUpComputePipelineState()
    {
      let compareShader = computeFunctionLibrary.makeFunction(name:"compareShader")
      do{
         try computePipelineState = device.makeComputePipelineState(function: compareShader!)
        }
      catch let error
      {
            print("Unable to create compute state pipeline:\(error)")
      }
    }
    
    private func setUpRenderPipelineStates()
    {
      let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = 16
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.layouts[0].stride = 6*MemoryLayout<Float>.size
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        let vert_function = renderFunctionLibrary.makeFunction(name: "vertexShader")
        let frag_function = renderFunctionLibrary.makeFunction(name: "fragmentShader")
        let frag_function1 = renderFunctionLibrary.makeFunction(name: "fragmentShader1")
        
        let pipelineStateDesc = MTLRenderPipelineDescriptor()
        pipelineStateDesc.vertexFunction = vert_function
        pipelineStateDesc.fragmentFunction = frag_function
        pipelineStateDesc.vertexDescriptor = vertexDescriptor
        let view = self.view as! MTKView
        pipelineStateDesc.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDesc.sampleCount = view.sampleCount
        do
        {
            
            try  pipelineState1 = device.makeRenderPipelineState(descriptor: pipelineStateDesc)
            
        }
        catch let err
        {
            print("Unable to create pipeline state:\(err)")
        }
        pipelineStateDesc.fragmentFunction = frag_function1
        do
        {
            try pipelineState2 = device.makeRenderPipelineState(descriptor: pipelineStateDesc)
        }
        catch let error
        {
            print("unable to create pipeline state:\(error)")
        }
    
    }
    private func allocateBuffers()
    {
        countBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        verticesBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])
        imageDimensionBuffer = device.makeBuffer(bytes: &imageDimension, length: MemoryLayout<uint2>.size, options: [])
    }
    
    func draw(in view: MTKView)
    {
        
        if let currentRenderPassDesc = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable
        {
        
            
            let commandBuffer = commandQueue.makeCommandBuffer()
        
            /* creation of renderCommander */
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDesc)
            renderCommandEncoder.setRenderPipelineState(pipelineState1)
            renderCommandEncoder.setVertexBuffer(verticesBuffer, offset: 0, at: 0)
            renderCommandEncoder.setFragmentTexture(inputTexture, at: 0)
            renderCommandEncoder.setFragmentBuffer(imageDimensionBuffer, offset: 0, at: 1)
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount:1)
            renderCommandEncoder.endEncoding()
            commandBuffer.present(currentDrawable)
            let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder()
                let viewTexture = currentRenderPassDesc.colorAttachments[0].texture!
                blitCommandEncoder.copy(from: viewTexture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: MTLOrigin(x:0,y:0,z:0), sourceSize: MTLSize(width:Int(viewTexture.width),height:Int(viewTexture.height),depth:1), to: self.texture1, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin(x:0,y:0,z:0))
            
                blitCommandEncoder.endEncoding()

            let renderCommandEncoder1 = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDesc)
            renderCommandEncoder1.setRenderPipelineState(pipelineState2)
            renderCommandEncoder1.setFragmentTexture(inputTexture, at: 0)
            renderCommandEncoder1.setFragmentSamplerState(sampler, at: 0)
            renderCommandEncoder1.setVertexBuffer(verticesBuffer, offset: 0, at: 0 )
            renderCommandEncoder1.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
            renderCommandEncoder1.endEncoding()
            
            
            
            let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()
            computeCommandEncoder.setComputePipelineState(computePipelineState)
            computeCommandEncoder.setTexture(texture1, at: 0)
            computeCommandEncoder.setTexture(currentRenderPassDesc.colorAttachments[0].texture!, at: 1)
            computeCommandEncoder.setBuffer(countBuffer, offset: 0, at: 0)
            let threadsPerGroup = MTLSize(width: 8,height: 8,depth: 1)
            
            
            let threadGroupsPerGrid = MTLSize(width:texture1.width/threadsPerGroup.width,height:texture1.height/threadsPerGroup.height,depth:1)
            computeCommandEncoder.dispatchThreadgroups(threadGroupsPerGrid, threadsPerThreadgroup: threadsPerGroup)
                computeCommandEncoder.endEncoding()
            
            commandBuffer.addCompletedHandler({_ in
                
                let data = Data(bytes:self.countBuffer.contents(),count:MemoryLayout<uint>.size)
                var result = [uint8](repeating:0,count:MemoryLayout<uint>.size)
                data.copyBytes(to: &result[0], count: MemoryLayout<uint>.size)
                let nsData = NSData(bytes:result,length:MemoryLayout<uint>.size)
                var valueInInt:uint = 0
                nsData.getBytes(&valueInInt,length:MemoryLayout<uint>.size)
                
                print("Number of pixels matched:\(valueInInt)")})

                
                
 
            

            commandBuffer.commit()
        }
            
            
            
        
        
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }


}
