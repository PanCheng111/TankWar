//
//  GameViewController.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import AVFoundation

private let myName = UIDevice.currentDevice().name

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    var cameraNode: SCNNode!
    var node: SCNNode!
    var scene: GameScene!
    var otherTanks: [String: GameTank]!
    var thisTank: GameTank!
    var scnView: SCNView!
    var overlay: SKScene!
    
    var forwardDirectionVector: SCNVector3!
    
    var thisPlayer: Player!
    var otherPlayers: [String: Player]!
    var liveness: [String: Int]!
    var livenessLabel : [SCNNode]!
    var scores: [String: Int]!
    
    var playEffect = SCNAction.playAudioSource(SCNAudioSource(fileNamed: "bomb.wav")!, waitForCompletion: false)
    var backgroundMusicPlayer : AVAudioPlayer?
    var lastUpdateTime: NSTimeInterval!
    // var timeLabel: SKLabelNode!
    var curTime = 120
    var dieTime = -1
    
    let attributes : [String: AnyObject] = [
        NSFontAttributeName : UIFont(name: "Copperplate", size: 40.0)!,
        NSUnderlineStyleAttributeName : 1,
        NSForegroundColorAttributeName : UIColor.redColor(),
        //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
        NSStrokeWidthAttributeName : 3.0]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scnView = self.view as! SCNView
        
        // Setup Game Scene
        scene = GameScene(view: scnView)
        scene.physicsWorld.contactDelegate = self
        scene.physicsWorld.gravity = SCNVector3(0, 0, 0)
        scene.setupSkyboxWithName("sun1", andFileExtension:"bmp")
        scnView.backgroundColor = UIColor.darkGrayColor()
        
        // Setup Game Character
        self.setupTanks()
        
        // Setup view
        scnView.scene = scene;
        scnView.showsStatistics = true
        scnView.delegate = self
        scnView.playing = true
        
        // Setup HUD
        self.setupHUD()
    }
    
    override func viewWillAppear(animated: Bool) {
        SVProgressHUD.dismiss()
        super.viewWillAppear(animated)
        setupMultipeerEventHandlers()
        self.playBackgroundMusic("background", withExtension: "wav")
    }
    
    override func viewWillDisappear(animated: Bool) {
        //blackCardLabel.removeObserver(self, forKeyPath: boundsKeyPath)
        let observedEvents: [Event] = [.Move, .Location, .StartGame, .Fire, .ReLive, .EndGame]
        for event in observedEvents {
            connectionManager.onEvent(event, run: nil)
        }
        backgroundMusicPlayer?.stop()
        super.viewWillDisappear(animated)
    }
    
    // MARK: Sounds
    func playBackgroundMusic(filename: String, withExtension extensions: String) {
        let url = NSBundle.mainBundle().URLForResource(
            filename, withExtension: extensions)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        self.backgroundMusicPlayer = try? AVAudioPlayer(contentsOfURL: url!)
        
        if backgroundMusicPlayer == nil {
            print("Could not create audio player!")
            return
        }
        
        self.backgroundMusicPlayer!.numberOfLoops = -1
        self.backgroundMusicPlayer!.prepareToPlay()
        self.backgroundMusicPlayer!.play()
    }
    
    // MARK: Multipeer
    
    private func setupMultipeerEventHandlers() {
        // Answer
        NSLog("did setup multipeer event handler")
        connectionManager.onEvent(.Move) { [unowned self] peer, object in
            let dict = object as! [String: NSData]
            let data = dict["player"]
            let player = Player(mpcSerialized: data!)
            let tank = self.otherTanks[player.name]!
            self.otherPlayers[player.name] = player
            tank.tankNode.position = player.location.position
            tank.tankNode.rotation = player.location.rotation
            NSLog("onEvent_move, position=\(player.location.position)")
            tank.tankNode.physicsBody?.resetTransform()
        }
        
        connectionManager.onEvent(.ReLive) { [unowned self] peer, object in
            let dict = object as! [String: NSData]
            let data = dict["player"]
            let player = Player(mpcSerialized: data!)
            let tank = self.otherTanks[player.name]!
            self.otherPlayers[player.name] = player
            self.scene.rootNode.addChildNode(tank.tankNode)
            tank.tankNode.position = player.location.position
            tank.tankNode.rotation = player.location.rotation
            NSLog("onEvent_relive, position=\(player.location.position)")
            tank.tankNode.physicsBody?.resetTransform()
            self.liveness[player.name] = TankDetail[player.tankName]!["防御力"]!
        }
        
        connectionManager.onEvent(.Fire) { [unowned self] peer, object in
            let dict = object as! [String: NSData]
            let data = dict["destination"]
            let fireTrail = FireTrail(mpcSerialized: data!)
            let player = Player(mpcSerialized: dict["player"]!)
            let projectile = SCNNode(geometry: SCNSphere(radius: 20))
            projectile.name = player.name
            NSLog("onEvent_fire, destination=\(fireTrail.source.destination)")
            
            projectile.addParticleSystem(self.createTrail())
            projectile.position = fireTrail.source.destination
            projectile.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
            projectile.physicsBody?.categoryBitMask = ContactCategory.bombCategory.rawValue
            projectile.physicsBody?.contactTestBitMask = ContactCategory.tankCategory.rawValue
            projectile.physicsBody?.collisionBitMask = 0//ContactCategory.allCategory.rawValue
            self.scene.rootNode.addChildNode(projectile)
            projectile.physicsBody?.applyForce(fireTrail.destination.destination, impulse: true)
            let action = self.playEffect
            projectile.runAction(action)
            
        }
        
        // End Game
        //ConnectionManager.onEvent(.EndGame) { [unowned self] _, _ in
        //self.dismiss()
        //}
    }
    
    
    func setupHUD() {
        /* Create overlay SKScene for 3D scene */
        let scnView = self.view as! SCNView
        overlay = GameOverlayScene(size: scnView.bounds.size)
        overlay.scaleMode = .AspectFill;
        scnView.overlaySKScene = overlay;
    }
    
    func setupTanks() {
        otherTanks = [:]
        liveness = [:]
        livenessLabel = []
        scores = [:]
        //otherPlayers = ["test": Player(name: "test", tankName: "T-90")]
        if otherPlayers != nil {
            for (str, player) in otherPlayers {
                let tank = GameTank(scene: TankScene[player.tankName]!, withName: player.tankName)
                tank.environmentScene = scene;
                scene.rootNode.addChildNode(tank.tankNode)
                
                // Reset character to idle pose (rather than T-pose)
                tank.actionState = .ActionStateIdle;
                tank.tankNode.position = player.location.position //SCNVector3Make(0, 0, -250)
                //tank.tankNode.position.y = 200
                tank.tankNode.rotation = player.location.rotation //SCNVector4Make(0, 1, 0, Float(M_PI))
                tank.tankNode.name = str
                otherTanks[str] = tank
                
                let content = NSAttributedString(string: player.name + "\n防御力：\(TankDetail[player.tankName]!["防御力"]!)", attributes: attributes)
                let labelText = SCNText(string: content, extrusionDepth: 0)
                let labelNode = SCNNode(geometry: labelText)
                labelNode.position = SCNVector3Make(-20, 300, 0)
                labelNode.name = "label"
                tank.tankNode.addChildNode(labelNode)
                liveness[player.name] = TankDetail[player.tankName]!["防御力"]!
                livenessLabel.append(labelNode)
                scores[player.name] = 0
            }
        }
        if thisPlayer == nil {
            thisPlayer = Player(name: myName, tankName: "T-90")
        }
        thisTank = GameTank(scene: TankScene[thisPlayer.tankName]!, withName: "T-90")
        thisTank.environmentScene = scene
        scene.rootNode.addChildNode(thisTank.tankNode)
        
        // Reset character to idle pose (rather than T-pose)
        thisTank.actionState = .ActionStateIdle;
        thisTank.tankNode.position =  thisPlayer.location.position //SCNVector3Make(0, 0, -250)
        thisTank.tankNode.rotation = thisPlayer.location.rotation //SCNVector4Make(0, 1, 0, Float(M_PI))
        thisTank.tankNode.name = thisPlayer.name
        
        let content = NSAttributedString(string: thisPlayer.name + "\n防御力：\(TankDetail[thisPlayer.tankName]!["防御力"]!)", attributes: attributes)
        let labelText = SCNText(string: content, extrusionDepth: 0)
        let labelNode = SCNNode(geometry: labelText)
        labelNode.position = SCNVector3Make(-20, 300, 0)
        labelNode.name = "label"
        thisTank.tankNode.addChildNode(labelNode)
        liveness[thisPlayer.name] = TankDetail[thisPlayer.tankName]!["防御力"]!
        scores[thisPlayer.name] = 0
        
        let shotpointMaterial = SCNMaterial()
        shotpointMaterial.diffuse.contents = UIImage(named: "shotpoint")
        shotpointMaterial.emission.contents = UIColor.redColor()
        let shotpoint = SCNNode()
        shotpoint.name = "shotpoint"
        shotpoint.geometry = SCNPlane(width: 100, height: 100)
        shotpoint.geometry?.firstMaterial = shotpointMaterial
        shotpoint.position = SCNVector3(0, 200, -2000)
        thisTank.tankNode.addChildNode(shotpoint)
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        //cameraNode.camera?.usesOrthographicProjection = true
        //cameraNode.camera?.orthographicScale = 1000
        cameraNode.camera!.zFar = 25000
        cameraNode.camera!.zNear = 50
        
        //cameraNode.camera!.xFov = 60
        
        cameraNode.position = SCNVector3Make(0, 500, 800)
        //SCNConstraint
        let constraint = SCNLookAtConstraint(target: shotpoint)
        //constraint.gimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        thisTank.tankNode.addChildNode(cameraNode)
        
        
    }
    
    // MARK contact delegate
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        NSLog("enter contact delegate")
        var firstBody, secondBody: SCNNode!
        if (contact.nodeA.physicsBody!.categoryBitMask < contact.nodeB.physicsBody!.categoryBitMask)
        {
            firstBody = contact.nodeA
            secondBody = contact.nodeB
        }
        else
        {
            firstBody = contact.nodeB;
            secondBody = contact.nodeA;
        }
        print("cate1=\(firstBody.physicsBody!.categoryBitMask)")
        print("cate2=\(secondBody.physicsBody!.categoryBitMask)")
        if ((firstBody.physicsBody!.categoryBitMask & ContactCategory.tankCategory.rawValue) != 0 &&
            (secondBody.physicsBody!.categoryBitMask & ContactCategory.bombCategory.rawValue) != 0) {
            self.bomb(secondBody, didCollideWithTank: firstBody)
        }
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        if lastUpdateTime == nil {
            lastUpdateTime = time
        }
        if (time - lastUpdateTime >= 1 && overlay is GameOverlayScene) {
            curTime -= 1
            if dieTime != -1 {
                dieTime = dieTime - 1
                dispatch_async(dispatch_get_main_queue()) {
                    (self.overlay as! GameOverlayScene).updateTime()
                }
                if dieTime == -1 {
                    let tmp = Player(name: myName, tankName: thisPlayer.tankName)
                    thisTank.tankNode.position = tmp.location.position
                    thisTank.tankNode.rotation = tmp.location.rotation
                    thisTank.tankNode.physicsBody?.resetTransform()
                    thisPlayer.location = tmp.location
                    liveness[thisPlayer.name] = TankDetail[thisPlayer.tankName]!["防御力"]!
                    let labelNode = thisTank.tankNode.childNodeWithName("label", recursively: true)
                    let labelText = labelNode?.geometry as! SCNText
                    labelText.string = NSAttributedString(string: thisPlayer.name + "\n防御力：\(liveness[thisPlayer.name]!)", attributes: attributes)
                    connectionManager.sendEventForEach(.ReLive, objectBlock: { () -> ([String : MPCSerializable]) in
                        return ["player": thisPlayer]
                    })
                    
                }
            }
            (overlay as! GameOverlayScene).timeLabel.text = "倒计时：\(curTime)s"
            lastUpdateTime = time
            if (curTime == 0) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.overlay.removeAllChildren()
                    let scnView = self.view as! SCNView
                    self.overlay = GameOverScene(size: self.view.bounds.size, score: self.scores)
                    scnView.overlaySKScene = self.overlay
                }
            }
        }
        if overlay is GameOverScene {
            let gameOverScene = overlay as! GameOverScene
            if gameOverScene.back {
                gameOverScene.back = false
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let IntroVC = storyboard.instantiateViewControllerWithIdentifier("IntroViewController") as! IntroViewController
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(IntroVC, animated: true, completion: nil)
                }
                
            }
            return
        }
        if(overlay is GameOverlayScene && (overlay as! GameOverlayScene).movementJoystick.velocity.x != 0 || (overlay as! GameOverlayScene).movementJoystick.velocity.y != 0){
            /* Start walk animation */
            
            /* Calculate angle in degrees */
            let angleInDegrees = (overlay as! GameOverlayScene).movementJoystick.angularVelocity * 57.3;
            var backward : Float = 1.0
            var angular = (overlay as! GameOverlayScene).movementJoystick.angularVelocity
            /* thumb is in top left region */
            if(angleInDegrees >= 0 && angleInDegrees <= 90){
                NSLog("TL");
            }
                /* thumb is in bottom left region */
            else if(angleInDegrees > 90 && angleInDegrees <= 179){
                NSLog("BL");
                backward = -1
                angular = angular - Float(M_PI)
            }
                /* thumb is in top right region */
            else if(angleInDegrees < 0 && angleInDegrees >= -90){
                NSLog("TR");
            }
                /* thumb is in bottom right region */
            else if(angleInDegrees < -90 && angleInDegrees >= -180){
                NSLog("BR");
                backward = -1
                angular = angular + Float(M_PI)
            }
            
            //cameraNode.rotation = SCNVector4Make(0, 1, 0, movementJoystick.angularVelocity);
            
            /* Create a vector to move forward in z direction */
            forwardDirectionVector = SCNVector3Make(0, 0, 1);
            forwardDirectionVector = self.rotateVector3(forwardDirectionVector, aroundAxis:1, byAngleInRadians:thisTank.tankNode.rotation.w+angular)
            NSLog("[%f: %f, %f, %f]", angleInDegrees, forwardDirectionVector.x, forwardDirectionVector.y, forwardDirectionVector.z);
            
            /* Increment character position by vector rotated in correct direction */
            let speed = Float(TankDetail[thisPlayer.tankName]!["速度"]!) * 1.0 / 100
            thisTank.tankNode.position = SCNVector3Make(
                thisTank.tankNode.position.x - backward*forwardDirectionVector.x * 5 * speed,
                thisTank.tankNode.position.y + backward*forwardDirectionVector.y * 5 * speed,
                thisTank.tankNode.position.z - backward*forwardDirectionVector.z * 5 * speed);
            
            thisTank.tankNode.rotation = SCNVector4Make(0, 1, 0, thisTank.tankNode.rotation.w + angular * 0.01);
            // cameraNode.rotation = SCNVector4Make(0, 1, 0, cameraNode.rotation.w + movementJoystick.angularVelocity * 0.1 / 2);
            thisTank.tankNode.physicsBody!.resetTransform()
            
            thisPlayer.location.position = thisTank.tankNode.position
            thisPlayer.location.rotation = thisTank.tankNode.rotation
            for labelNode in livenessLabel {
                labelNode.rotation = thisTank.tankNode.rotation
            }
            
            connectionManager.sendEventForEach(.Move, objectBlock: { () -> ([String : MPCSerializable]) in
                return ["player": thisPlayer]
            })
        }
        
        if (overlay is GameOverlayScene && (overlay as! GameOverlayScene).fireNode.isTapped) {
            NSLog("Fire off!\n")
            let projectile = SCNNode(geometry: SCNSphere(radius: 20))
            projectile.name = thisPlayer.name
            projectile.addParticleSystem(self.createTrail())
            projectile.position = thisTank.tankNode.position
            projectile.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
            projectile.physicsBody?.categoryBitMask = ContactCategory.bombCategory.rawValue
            projectile.physicsBody?.contactTestBitMask = ContactCategory.tankCategory.rawValue
            projectile.physicsBody?.collisionBitMask = 0//ContactCategory.allCategory.rawValue
            scene.rootNode.addChildNode(projectile)
            
            let shotpoint = thisTank.tankNode.childNodeWithName("shotpoint", recursively: true)!
            var position = shotpoint.position
            position.z *= 10
            var dst = thisTank.tankNode.convertPosition(position, toNode: scene.rootNode)
            dst.x -= thisTank.tankNode.position.x
            dst.y -= thisTank.tankNode.position.y
            dst.z -= thisTank.tankNode.position.z
            projectile.physicsBody?.applyForce(dst, impulse: true)
            //var action = SCNAction.moveTo(dst, duration: 5)
            let action = playEffect
            projectile.runAction(action)
            (overlay as! GameOverlayScene).fireNode.resetTapped()
            connectionManager.sendEventForEach(.Fire, objectBlock: { () -> ([String : MPCSerializable]) in
                return ["player": thisPlayer,
                    "destination": FireTrail(src: thisTank.tankNode.position, dst: dst)
                ]
            })
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(overlay)
            let touchNode = overlay.nodeAtPoint(location)
            print("\(touchNode.name)")
        }
    }
    
    func createTrail() -> SCNParticleSystem {
        // 2
        let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        // 3
        //trail.particleColor = color
        // 4
        //trail.emitterShape = geometry
        // 5
        return trail
    }
    
    func bomb(bomb: SCNNode, didCollideWithTank tank:SCNNode) {
        if (bomb.name != tank.name) {
            NSLog("bomb hit tank\n")
            bomb.removeFromParentNode()
            tank.addParticleSystem(SCNParticleSystem(named: "smoke.scnp", inDirectory: nil)!)
            for node in tank.childNodes {
                node.addParticleSystem(SCNParticleSystem(named: "smoke.scnp", inDirectory: nil)!)
            }
            var attack = 0
            if bomb.name == thisPlayer.name {
                attack = TankDetail[thisPlayer.tankName]!["攻击力"]!
            }
            else {
                attack = TankDetail[otherPlayers[bomb.name!]!.tankName]!["攻击力"]!
            }
            liveness[tank.name!]! -= attack
            if (liveness[tank.name!]! <= 0) {
                if (tank != thisTank.tankNode) {
                    tank.removeFromParentNode()
                }
                else {
                    (overlay as! GameOverlayScene).setTime(5)
                    dieTime = 5
                }
                scores[bomb.name!]! += 1
            }
            let labelNode = tank.childNodeWithName("label", recursively: true)
            let labelText = labelNode?.geometry as! SCNText
            labelText.string = NSAttributedString(string: tank.name! + "\n防御力：\(liveness[tank.name!]!)", attributes: attributes)
        }
    }
    
    func rotateVector3(vector:SCNVector3, aroundAxis axis: Int, byAngleInRadians angle:Float) -> SCNVector3 {
        if(axis == 1){
            let result = SCNVector3Make(cosf(angle)*vector.x+sinf(angle)*vector.z, vector.y, -sinf(angle)*vector.x+cosf(angle)*vector.z);
            return result;
        }
        else{
            return SCNVector3Zero;
        }
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
        if self.isViewLoaded() && self.view.window == nil {
            self.view = nil
            NSLog("remove game view")
        }
    }
    
}
