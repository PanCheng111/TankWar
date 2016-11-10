//
//  FirePod.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import Foundation
import SpriteKit

class FirePod : SKNode {
    let backNode: SKSpriteNode
    var isTapped: Bool = false
    
    func anchorPointInPoints() -> CGPoint {
        return CGPointMake(0, 0)
    }
    
    init(backNode: SKSpriteNode = SKSpriteNode(imageNamed: "shotpoint")) {
        self.backNode = backNode
        
        super.init()
        
        self.addChild(self.backNode)
        self.userInteractionEnabled = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchPoint: CGPoint = touch.locationInNode(self)
            NSLog("touch begin, touch.x=%f, touch.y=%f", touchPoint.x, touchPoint.y)
            if self.isTapped == false && CGRectContainsPoint(self.backNode.frame, touchPoint) {
                self.isTapped = true
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.resetTapped()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.resetTapped()
    }
    
    func resetTapped() {
        self.isTapped = false
    }
}
