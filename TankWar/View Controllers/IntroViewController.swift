//
//  IntroViewController.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class IntroViewController: UIViewController, SCNSceneRendererDelegate, UIGestureRecognizerDelegate {
    
    var scnView: SCNView!
    var scene: ShowScene!
    var overlayScene: IntroScene!
    var lookGesture: UIPanGestureRecognizer!
    
    var elevation: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("intro view did load")
        scnView = self.view as! SCNView
        scene = ShowScene(name: "T-90")
        //setupLaunchImage()
        setupHUD()
        setupLookGesture()
        scene.physicsWorld.gravity = SCNVector3(x: 0, y: -9, z: 0)
        scene.physicsWorld.timeStep = 1.0 / 60
        
        scnView.scene = scene
        scnView.backgroundColor = UIColor.grayColor()
        scnView.showsStatistics = true
        scnView.delegate = self
        scnView.playing = true
        //scnView.allowsCameraControl = true
    }
    
    func setupLaunchImage() {
        let image = UIImageView(image: UIImage(named: "launch_screen.png"))
        image.bounds = view.bounds
        view.addSubview(image)
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        blurView.frame = view.bounds
        view.addSubview(blurView)
    }
    
    func setupHUD() {
        overlayScene = IntroScene(size: scnView.bounds.size)
        overlayScene.scaleMode = .AspectFill
        scnView.overlaySKScene = overlayScene
    }
    
    func setupLookGesture() {
        lookGesture = UIPanGestureRecognizer(target: self, action: #selector(IntroViewController.lookGestureRecognized(_:)))
        lookGesture.delegate = self
        self.view.addGestureRecognizer(lookGesture)
    }
    
    func lookGestureRecognized(gesture: UIPanGestureRecognizer) {
        
        //get translation and convert to rotation
        let translation = gesture.translationInView(self.view)
        //let hAngle = acos(Float(translation.x) / 200) - Float(M_PI_2)
        let vAngle = acos(Float(translation.y) / 200) - Float(M_PI_2)
        
        //rotate hero
        //NSLog("hAngle=\(hAngle) physicsBody=\(scene.thisTank.tankNode.physicsBody!)")
        //scene.thisTank.tankNode.physicsBody?.applyTorque(SCNVector4(x: 0, y: 1, z: 0, w: hAngle), impulse: false)
        
        //tilt camera
        elevation = max(Float(0), min(Float(M_PI_4), elevation + vAngle))
        var height = max(200, scene.cameraNode.position.y + Float(translation.y))
        height = min(500, height)
        scene.cameraNode.position.y = height
        
        //reset translation
        gesture.setTranslation(CGPointZero, inView: self.view)
    }
    
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        if (overlayScene.selectedTank != scene.curTank) {
            scene.curTank = overlayScene.selectedTank
            dispatch_async(dispatch_get_main_queue()) {
                self.scene.setupTank(self.scene.curTank)
            }
        }
        if (overlayScene.startGame) {
            overlayScene.startGame = false
            dispatch_async(dispatch_get_main_queue()) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let ChooseVC = storyboard.instantiateViewControllerWithIdentifier("ChooseViewController") as! ChooseViewController
                ChooseVC.tankName = self.overlayScene.selectedTank
                self.presentViewController(ChooseVC, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
        if self.isViewLoaded() && self.view.window == nil {
            self.view = nil
            NSLog("remove intro view")
        }
    }
}