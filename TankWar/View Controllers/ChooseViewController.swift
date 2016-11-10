//
//  ChooseViewController.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class ChooseViewController: UIViewController, SCNSceneRendererDelegate, UIGestureRecognizerDelegate {
    
    var scnView: SCNView!
    var scene: SCNScene!
    var overlayScene: ChooseScene!
    var tankName: String!
    
    var elevation: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scnView = self.view as! SCNView
        scene = SCNScene()
        setupHUD()
        
        scnView.scene = scene
        scnView.backgroundColor = UIColor.grayColor()
        scnView.showsStatistics = true
        scnView.delegate = self
        scnView.playing = true
    }
    
    func setupHUD() {
        overlayScene = ChooseScene(size: scnView.bounds.size)
        overlayScene.scaleMode = .AspectFill
        scnView.overlaySKScene = overlayScene
    }
    
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        if overlayScene.needBack {
            overlayScene.needBack = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let IntroVC = storyboard.instantiateViewControllerWithIdentifier("IntroViewController") as! IntroViewController
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(IntroVC, animated: true, completion: nil)
            }
        }
        if overlayScene.selectedLevel != nil {
            if overlayScene.selectedLevel == "level1" {
                overlayScene.selectedLevel = nil
                let vc = MenuViewController()
                vc.tankName = tankName
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
        if self.isViewLoaded() && self.view.window == nil {
            self.view = nil
            NSLog("remove choose view")
        }
    }
    
}
