//
//  ShowScene.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

class ShowScene: SCNScene {
    
    var curTank: String
    var thisTank: GameTank!
    var cameraNode: SCNNode!
    
    init(name: String) {
        curTank = name
        super.init()
        setupTank(curTank)
        setupCamera()
        setupAmbientLight()
        setupPointLight()
        setupFloor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTank(name: String) {
        if thisTank != nil {
            thisTank.tankNode.removeFromParentNode()
        }
        thisTank = GameTank(scene: SCNScene(named: "art.scnassets/\(name)/\(name).dae")!, withName: name)
        thisTank.environmentScene = self
        self.rootNode.addChildNode(thisTank.tankNode)
        
        // Reset character to idle pose (rather than T-pose)
        thisTank.tankNode.position =  SCNVector3Make(0, 0, -250)
        var action = SCNAction.rotateByX(0, y: CGFloat(M_PI_4), z: 0, duration: 1.0)
        action = SCNAction.repeatActionForever(action)
        thisTank.tankNode.runAction(action)
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera!.zFar = 10000
        //cameraNode.camera!.zNear = 10
        cameraNode.camera!.yFov = 90
        cameraNode.camera?.xFov = 45
        //cameraNode.camera!.xFov = 60
        cameraNode.position = SCNVector3Make(0, 500, 350)
        
        let constrain = SCNLookAtConstraint(target: thisTank.tankNode)
        cameraNode.constraints = [constrain]
        self.rootNode.addChildNode(cameraNode)
    }
    
    func setupPointLight() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni;
        lightNode.position = SCNVector3Make(0, 200, -100)
        self.rootNode.addChildNode(lightNode)
    }
    
    func setupAmbientLight() {
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient;
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        self.rootNode.addChildNode(ambientLightNode)
    }
    
    func setupFloor() {
        let floorNode = SCNNode()
        floorNode.geometry = SCNPlane(width: 2000, height: 2000)
        floorNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(-M_PI_2))
        floorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        self.rootNode.addChildNode(floorNode)
    }
    
}