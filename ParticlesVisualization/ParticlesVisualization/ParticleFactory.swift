//
//  ParticleFactory.swift
//  ParticlesVisualization
//
//  Created by Admin on 15/05/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Metal
import MetalKit
import GameplayKit

struct Particle
{
    var A = Vector4(x: 0,y: 0,z: 0,w: 0)
    var B = Vector4(x: 0,y: 0,z: 0,w: 0)
    var C = Vector4(x: 0,y: 0,z: 0,w: 0)
    var D = Vector4(x: 0,y: 0,z: 0,w: 0)
}
// Particle use x and y for position in 2d grid and z and w for velocity
// gravityWell use x and y for position and z for mass and w for spin

struct  Vector4 {
    var x:Float32 = 0
    var y:Float32 = 0
    var z:Float32 = 0
    var w:Float32 = 0
}

enum GravityWell
{
    case one
    case two
    case three
    case four
}

enum ParticleCount:Int
{
  
  case halfMillion = 131072
  case oneMillion = 10000
  case twoMillion = 524288
  case fourMillion = 1048576
  case eightMillion = 2097152
}

struct ParticleColor
{
    var R:Float32 = 0
    var G:Float32 = 0
    var B:Float32 = 0
    var A:Float32 = 1
}

//this is how we want generate random numbers in between a range eg: getting random numbers by rolling dice
enum Distribution
{
  case Gaussian
  case Uniform
}

//this is the protocol to update particle Factory data in each frame so that we can see animated particles moving in space 
// with different speed each time
protocol ParticleFactoryDelegate : NSObjectProtocol
{
    func particleFactoryDidUpdate()
}


class ParticleFactory : MTKView
{
    //this is the dimension of 2D grid of Particles
    let imageWidth: UInt
    let imageHeight: UInt
    
    //these are the two buffers which are used to pass dimension of particles' grid in kernel function as argument
    private var imageWidthFloatBuffer: MTLBuffer!
    private var imageHeightFloatBuffer: MTLBuffer!
    
    //these are the metal objects to get work done by GPU
    private var kernelFunction:MTLFunction!
    private var pipelineState:MTLComputePipelineState!
    private var defaultLibary:MTLLibrary!
    private var commandQueue:MTLCommandQueue!
    
    //this is how we divide workload amongs threads
    private var threadsPerThreadGroup: MTLSize!
    private var threadGroupPerGrid: MTLSize!
    
    //this is the number of particles we want to produce
    let particleCount:Int
    //we allocate memory in multiple of this alignment,this is because that our particle data is divided among multiple 
    //threads.aligment memory allocation will give us performance benefit.
    let alignment: Int = 0x4000
    //this is the total memory size of all produced particles in the terms of bytes
    let particleMemoryByteSize: Int
    
    //this pointer is for untyped memory that is managed by application programmer only.system is not responsible to take 
    //care of this memory.this pointer references a number of bytes in memory with specified memory alighnment.
    private var particlesMemory: UnsafeMutableRawPointer? = nil
    
    //this is used to convert unsafe pointer to c-type pointer
    private var particlesVoidPtr: OpaquePointer!
    //this is used to c-type pointer to Particle type
    private var particlesParticlePtr: UnsafeMutablePointer<Particle>!
    //this is the pointer of a collection of particles
    private var particlesParticleBufferPtr: UnsafeMutableBufferPointer<Particle>!
    
    // this is the gravitational field around the particles.this gravitational field would be kept updating in each frame 
    //so that particles seem as they are trying to come out of this gravitational force.
    var gravityWellParticle = Particle(A: Vector4(x:0,y:0,z:0,w:0),
                                                B: Vector4(x:0,y:0,z:0,w:0),
                                                C: Vector4(x:0,y:0,z:0,w:0),
                                                D: Vector4(x:0,y:0,z:0,w:0))
    
    //this reference will be used to call implemented methods of the class which conforms protocol ParticleFactoryDelegate.
    weak var particleFactoryDelegate: ParticleFactoryDelegate?
    var particleColor = ParticleColor(R: 1,G: 0.5,B: 0.2,A: 1)
    var dragFactor = 0.97
    //this is the flag to know that whether particles out of grid must be regenerated or not
    var respawnOutOfBoundsParticle = true
    var clearStep = true
    private var frameStartTime: CFAbsoluteTime!
    private var particleSize :Int = 0
    private var particleColorSize :Int = 0
    
    //this is the buffer which will store all the particles data and this buffer will be passed to kernel function to 
    //manipulate the data
    var particleBuffer: MTLBuffer!
    
    init(width: UInt,height: UInt,numParticles: ParticleCount)
    {
        
        
        particleCount = numParticles.rawValue
        imageWidth = width
        imageHeight = height
        particleMemoryByteSize = particleCount*MemoryLayout<Particle>.stride
        Swift.print("Memory byte size:\(particleMemoryByteSize)")
        
        
        super.init(frame: CGRect(x: 0,y: 0,width: Int(width),height: Int(height)),device: MTLCreateSystemDefaultDevice())
        
        framebufferOnly = false
        colorPixelFormat = .bgra8Unorm
        sampleCount = 1
        preferredFramesPerSecond = 60
        drawableSize = CGSize(width: CGFloat(width),height: CGFloat(height))
        particleSize = MemoryLayout<Particle>.size
        Swift.print("size of particle:\(particleSize)")
        
        particleColorSize = MemoryLayout<ParticleColor>.size
        
        Swift.print("Particle color size:\(particleColorSize)")
        
        //this method allocates system  memory for the specified number of particles and then populate that memory
        setUpParticles()
        //this method will configure all metal related objects
        setUpMetal()
        
        //upto this point,we would have particles data which is referenced by particlesMemoy pointer so this data is 
        //copied to this GPU buffer
        particleBuffer = device?.makeBuffer(bytes: particlesMemory!, length: particleMemoryByteSize, options: [])
    
    
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit
    {
        free(particlesMemory)
    }
    private func setUpParticles()
    {
        /*This function resides in stdlib.h,this method allocates the memory as per alignment*/
        let ret_value = posix_memalign(&particlesMemory, alignment, particleMemoryByteSize)
      
        if(ret_value == 0)
        {
          particlesVoidPtr = OpaquePointer(particlesMemory)
          particlesParticlePtr = UnsafeMutablePointer<Particle>(particlesVoidPtr)
          Swift.print("Particle buffer pointer:\(particlesParticlePtr)")
          particlesParticleBufferPtr = UnsafeMutableBufferPointer(start: particlesParticlePtr, count:particleCount)
        
          resetParticles()
          resetGravityWell()
        }
        else
        {
            exit(0)
        }
      
     
    }
    private func setUpMetal()
    {
        defaultLibary = device?.newDefaultLibrary()
        commandQueue = device?.makeCommandQueue()
        kernelFunction = defaultLibary.makeFunction(name: "particleRendererShader")
        do
        {
            try pipelineState = device?.makeComputePipelineState(function: kernelFunction)
        }
        catch
        {
            Swift.print("unable to create pipeline state")
        }
        let threadExecutionWidth = pipelineState.threadExecutionWidth
        Swift.print("threadExecutionWidth:\(threadExecutionWidth)")
        threadsPerThreadGroup = MTLSize(width: threadExecutionWidth,height:1,depth:1)
        threadGroupPerGrid = MTLSize(width: particleCount/threadExecutionWidth,height:1,depth:1)
        var imageWidthFloat = Float(imageWidth)
        var imageHeightFloat = Float(imageHeight)
        
        imageWidthFloatBuffer = device?.makeBuffer(bytes: &imageWidthFloat, length: MemoryLayout<Float>.size, options: [])
        imageHeightFloatBuffer = device?.makeBuffer(bytes: &imageHeightFloat, length: MemoryLayout<Float>.size, options: [])
        
        
        
    
    }
    private  func resetParticles()
    {
        func rand()-> Float32
        {
            //drand48 returns double value uniformly distributed over interval [0,1]
            return Float(drand48()-0.5) * 0.005
        }
        
        
        let randomSource = GKRandomSource()
        let randomWidth = GKGaussianDistribution(randomSource: randomSource,lowestValue: 0 ,highestValue:Int(imageWidth))
        let randomHeight = GKGaussianDistribution(randomSource: randomSource,lowestValue: 0,highestValue: Int(imageHeight))
        
        //populating the collection particlesParticleBufferPtr with random particle objects
        for index in particlesParticleBufferPtr.startIndex..<particlesParticleBufferPtr.endIndex
        {
        
            //getting a random integer from randomWidth and randomHeight
            let posAx = Float(randomWidth.nextInt())
            let posAy = Float(randomHeight.nextInt())
            
            let posBx = Float(randomWidth.nextInt())
            let posBy = Float(randomHeight.nextInt())
            
            let posCx = Float(randomWidth.nextInt())
            let posCy = Float(randomHeight.nextInt())
            
            let posDx = Float(randomWidth.nextInt())
            let posDy = Float(randomHeight.nextInt())
            
            let particle = Particle(A : Vector4(x:posAx,y:posAy,z: rand(),w: rand()),B : Vector4(x:posBx,y:posBy,z: rand(),w: rand()),C : Vector4(x:posCx,y:posCy,z: rand(),w: rand()),D : Vector4(x:posDx,y:posDy,z: rand(),w: rand()))
            particlesParticleBufferPtr[index] = particle
        
        }
        
        
    }
    //this method sets the gravitational area surroundings of particles,it is defined by position,mass and spin parameter
    private func resetGravityWell()
    {
      setGravityWellProperties(gravityWell: .one, normalizedX: 0.25, normalizedY: 0.75, mass: 10, spin: 0.2)
      setGravityWellProperties(gravityWell: .two, normalizedX: 0.25, normalizedY: 0.25, mass: 10, spin: -0.2)
      setGravityWellProperties(gravityWell: .three, normalizedX: 0.75, normalizedY: 0.25, mass: 10, spin: 0.2)
      setGravityWellProperties(gravityWell: .four, normalizedX: 0.75, normalizedY: 0.75, mass: 10, spin: -0.2)
    }
    
    final func setGravityWellProperties(gravityWell: GravityWell, normalizedX:Float,normalizedY:Float,mass:Float,spin:Float)
    {
        let wellPosX = Float(imageWidth) * normalizedX
        let wellPosY = Float(imageHeight) * normalizedY
        
        
        switch(gravityWell)
        {
        case .one:
            
            gravityWellParticle.A.x = wellPosX
            gravityWellParticle.A.y = wellPosY
            gravityWellParticle.A.z = mass
            gravityWellParticle.A.w = spin
            
        case .two:
            gravityWellParticle.B.x = wellPosX
            gravityWellParticle.B.y = wellPosY
            gravityWellParticle.B.z = mass
            gravityWellParticle.B.w = spin
            
        case .three:
            
            gravityWellParticle.C.x = wellPosX
            gravityWellParticle.C.y = wellPosY
            gravityWellParticle.C.z = mass
            gravityWellParticle.C.w = spin
            
        case .four:
            gravityWellParticle.D.x = wellPosX
            gravityWellParticle.D.y = wellPosY
            gravityWellParticle.D.z = mass
            gravityWellParticle.D.w = spin

            }
    }

    override func draw(_ dirtyRect: CGRect)
    {
       
       let commandBuffer = commandQueue.makeCommandBuffer()
       let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder.setComputePipelineState(pipelineState)
        computeEncoder.setBuffer(particleBuffer, offset: 0, at: 0)
        computeEncoder.setBuffer(particleBuffer, offset: 0, at: 1)
        computeEncoder.setBuffer(imageWidthFloatBuffer, offset: 0, at: 4)
        computeEncoder.setBuffer(imageHeightFloatBuffer, offset: 0, at: 5)
        computeEncoder.setBytes(&gravityWellParticle, length: particleSize, at: 2)
        computeEncoder.setBytes(&particleColor, length: particleColorSize, at: 3)
        computeEncoder.setBytes(&dragFactor, length: MemoryLayout<Double>.size, at: 6)
        computeEncoder.setBytes(&respawnOutOfBoundsParticle, length: MemoryLayout<Bool>.size, at: 7)
        
        guard let drawable = currentDrawable else
        {
            Swift.print("current Drawable returned nil")
            return
        }
        computeEncoder.setTexture(drawable.texture, at: 0)
        computeEncoder.dispatchThreadgroups(threadGroupPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        computeEncoder.endEncoding()
        commandBuffer.present(drawable)
        //commandBuffer.addCompletedHandler(_ in  )
        commandBuffer.commit()
        
        DispatchQueue.global().async {
           self.particleFactoryDelegate?.particleFactoryDidUpdate()  
        }
       
        
        
        
    
    }
    
    

}
