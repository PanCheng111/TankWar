//
//  GameScene.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation

class GameScene: SCNScene {
    var sceneView: SCNView!
    var cameraNode: SCNNode!
    
    init(view: SCNView) {
        super.init()
        sceneView = view
        
        // create and add a light to the scene
        self.setupPointLight()
        
        // create and add an ambient light to the scene
        self.setupAmbientLight()
        
        // Setup Floor
        self.setupFloor()
        
        // Setup Map
        self.setupMap()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSkyboxWithName(name:String, andFileExtension ext:String) {
        let right = "\(name)_right.\(ext)"
        let left = "\(name)_left.\(ext)"
        let top = "\(name)_top.\(ext)"
        let bottom = "\(name)_bottom.\(ext)"
        let front = "\(name)_front.\(ext)"
        let back = "\(name)_back.\(ext)"
        
        self.background.contents = [right, back, top, bottom, left, front]
    }
    
    func setupFloor() {
        let floor = SCNFloor()
        floor.reflectivity = 0.0;
        //
        let floorNode = SCNNode()
        floorNode.geometry = floor;
        floorNode.physicsBody = SCNPhysicsBody(type: .Static, shape: SCNPhysicsShape(geometry: floor, options: nil))
        
        //        let floorMaterial = SCNMaterial()
        //        floorMaterial.litPerPixel = false;
        //        floorMaterial.diffuse.contents = UIImage(named: "art.scnassets/grass.jpg")
        //        floorMaterial.diffuse.wrapS = .Repeat;
        //        floorMaterial.diffuse.wrapT = .Repeat;
        //        floor.materials = [floorMaterial]
        //        self.rootNode.addChildNode(floorNode)
    }
    
    func setupMap() {
        let scene = SCNScene(named: "art.scnassets/3d-model.scn")!
        let nodes = scene.rootNode.childNodes
        let sceneNode = SCNNode()
        for node in nodes {
            sceneNode.addChildNode(node)
        }
        
        sceneNode.physicsBody = SCNPhysicsBody(type: .Static, shape: SCNPhysicsShape(node: sceneNode, options: [SCNPhysicsShapeKeepAsCompoundKey: true]))
        sceneNode.physicsBody?.categoryBitMask = ContactCategory.mapCategory.rawValue
        sceneNode.physicsBody?.collisionBitMask = 0//ContactCategory.allCategory.rawValue
        sceneNode.physicsBody?.contactTestBitMask = ~0
        sceneNode.position = SCNVector3(0, 0, 0)
        sceneNode.physicsBody?.resetTransform()
        rootNode.addChildNode(sceneNode)
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
    
}