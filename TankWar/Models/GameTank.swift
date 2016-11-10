//
//  GameTank.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

enum ActionState : Int {
    case ActionStateNone = 0
    case ActionStateIdle = 1
    case ActionStateAttack = 2
    case ActionStateWalk = 3
    case ActionStateHurt = 4
    case ActionStateKnockedOut = 5
}

enum ContactCategory: Int {
    case tankCategory = 1
    case bombCategory = 2
    case mapCategory = 4
    case allCategory = 7
}

class GameTank: NSObject {
    var scene: SCNScene!
    var environmentScene: SCNScene!
    var tankNode: SCNNode!
    var nodes: [SCNNode]!
    var actionState: ActionState!
    
    init(scene scn: SCNScene, withName name:String) {
        super.init()
        scene = scn
        nodes = scn.rootNode.childNodes
        
        tankNode = SCNNode()
        for node in nodes {
            let node_b = node.clone()
            tankNode.addChildNode(node_b)
        }
        tankNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape:
            SCNPhysicsShape(node: tankNode, options: [SCNPhysicsShapeKeepAsCompoundKey: true]))
        tankNode.physicsBody!.categoryBitMask = ContactCategory.tankCategory.rawValue
        tankNode.physicsBody!.contactTestBitMask = ContactCategory.bombCategory.rawValue
        tankNode.physicsBody!.collisionBitMask = ContactCategory.allCategory.rawValue ^ ContactCategory.mapCategory.rawValue
        tankNode.physicsBody!.angularDamping = 0.1
        tankNode.physicsBody?.damping = 0.9999999
        tankNode.physicsBody?.rollingFriction = 0
        tankNode.physicsBody?.friction = 0.5
        tankNode.physicsBody?.restitution = 0
        tankNode.physicsBody?.velocityFactor = SCNVector3(x: 1, y: 0, z: 1)
        actionState = .ActionStateNone
    }
}