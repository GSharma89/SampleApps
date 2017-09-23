
import Cocoa

class ParticleFactoryController: NSViewController, ParticleFactoryDelegate
{
    
    var gravityWellAngle:Float = 0.0
    var particleFactory: ParticleFactory!
    let floatPi = Float(M_PI)
    override func viewDidLoad()
    {
        super.viewDidLoad()
        particleFactory = ParticleFactory(width: 1024,height: 768,numParticles: ParticleCount.oneMillion)
        particleFactory.particleFactoryDelegate = self
        particleFactory.dragFactor = 0.85
        particleFactory.respawnOutOfBoundsParticle = true
        particleFactory.clearStep = true
        view.addSubview(particleFactory)
        
    }
        func particleFactoryDidUpdate()
        {
            updateGravityWell()
        }
                
        func updateGravityWell()
        {
            gravityWellAngle = gravityWellAngle + 0.02
            
            particleFactory.setGravityWellProperties(gravityWell: .one,
                                                     normalizedX: 0.5 + 0.1 * sin(gravityWellAngle + floatPi * 0.5 ),
                                                     
                                                     normalizedY: 0.5 + 0.1 * cos(gravityWellAngle + floatPi * 0.5),
                                                     mass: 11 * sin(gravityWellAngle / 1.9),
                                                     spin: 23 * cos(gravityWellAngle / 2.1))
            
            particleFactory.setGravityWellProperties(gravityWell: .four,
                                                     normalizedX: 0.5 + 0.1 * sin(gravityWellAngle + floatPi * 1.5),
                                                     normalizedY: 0.5 + 0.1 * cos(gravityWellAngle + floatPi * 1.5),
                                                     mass: 11 * sin(gravityWellAngle / 1.9),
                                                     spin: 23 * cos(gravityWellAngle/2.1))
            
            particleFactory.setGravityWellProperties(gravityWell: .two,
                                            normalizedX: 0.5 + 0.2 * (sin(gravityWellAngle) * cos(gravityWellAngle)),
                                            normalizedY: 0.5 + 0.2 * (sin(gravityWellAngle) / cos(gravityWellAngle)),
                                            mass: 20 * sin(gravityWellAngle / 2.5),
                                            spin: 32 * cos(gravityWellAngle / 3.5))
            
            particleFactory.setGravityWellProperties(gravityWell: .three,
                                            normalizedX: 0.5 + 0.37 * (sin(gravityWellAngle) * cos(gravityWellAngle)),
                                            normalizedY: 0.5 + 0.37 * (sin(gravityWellAngle) / cos(gravityWellAngle)),
                                            mass: 25 * sin(gravityWellAngle / 2.5),
                                            spin: 40 * cos(gravityWellAngle / 3.5))
            /*print("value of gravity well")
            let gravityWell = particleFactory.gravityWellParticle
            print("vector A: \(gravityWell.A.x) \(gravityWell.A.y) \(gravityWell.A.z) \(gravityWell.A.w)")
            print("vector B: \(gravityWell.B.x) \(gravityWell.B.y) \(gravityWell.B.z) \(gravityWell.B.w)")
            print("vector C: \(gravityWell.C.x) \(gravityWell.C.y) \(gravityWell.C.z) \(gravityWell.C.w)")
            print("vector D: \(gravityWell.D.x) \(gravityWell.D.y) \(gravityWell.D.z) \(gravityWell.D.w)")*/
                
            
        
        }
    

}
