//
//  Joystick.swift
//  TankWar
//
//  Created by 阿若 on 16/6/27.
//  Copyright © 2016年 阿若. All rights reserved.
//

import Foundation
import SpriteKit
//import PeerKit

class Joystick : SKNode {
    let kThumbSpringBackDuration: Double =  0.3
    let backdropNode, thumbNode: SKSpriteNode
    var isTracking: Bool = false
    var velocity: CGPoint = CGPointMake(0, 0)
    var travelLimit: CGPoint = CGPointMake(0, 0)
    var angularVelocity: Float = 0.0
    var size: Float = 0.0
    
    func anchorPointInPoints() -> CGPoint {
        return CGPointMake(0, 0)
    }
    
    init(thumbNode: SKSpriteNode = SKSpriteNode(imageNamed: "joystick.png"), backdropNode: SKSpriteNode = SKSpriteNode(imageNamed: "dpad.png")) {
        self.thumbNode = thumbNode
        self.backdropNode = backdropNode
        
        super.init()
        
        self.addChild(self.backdropNode)
        self.addChild(self.thumbNode)
        
        self.userInteractionEnabled = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchPoint: CGPoint = touch.locationInNode(self)
            NSLog("touch begin, touch.x=%f, touch.y=%f", touchPoint.x, touchPoint.y)
            if self.isTracking == false && CGRectContainsPoint(self.thumbNode.frame, touchPoint) {
                self.isTracking = true
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchPoint: CGPoint = touch.locationInNode(self)
            let dist = sqrtf(powf((Float(touchPoint.x) - Float(self.thumbNode.position.x)), 2) + powf((Float(touchPoint.y) - Float(self.thumbNode.position.y)), 2))
            if self.isTracking == true && dist < Float(self.thumbNode.size.width) {
                if sqrtf(powf((Float(touchPoint.x) - Float(self.anchorPointInPoints().x)), 2) + powf((Float(touchPoint.y) - Float(self.anchorPointInPoints().y)), 2)) <= Float(self.thumbNode.size.width) {
                    NSLog("touch moved, touch.x=%f, touch.y=%f", touchPoint.x, touchPoint.y)
                    let moveDifference: CGPoint = CGPointMake(touchPoint.x - self.anchorPointInPoints().x, touchPoint.y - self.anchorPointInPoints().y)
                    self.thumbNode.position = CGPointMake(self.anchorPointInPoints().x + moveDifference.x, self.anchorPointInPoints().y + moveDifference.y)
                    NSLog("thumbNode.x=%f, thumbNode.y=%f", self.thumbNode.position.x, self.thumbNode.position.y)
                } else {
                    let vX: Double = Double(touchPoint.x) - Double(self.anchorPointInPoints().x)
                    let vY: Double = Double(touchPoint.y) - Double(self.anchorPointInPoints().y)
                    let magV: Double = sqrt(vX*vX + vY*vY)
                    let aX: Double = Double(self.anchorPointInPoints().x) + vX / magV * Double(self.thumbNode.size.width)
                    let aY: Double = Double(self.anchorPointInPoints().y) + vY / magV * Double(self.thumbNode.size.width)
                    self.thumbNode.position = CGPointMake(CGFloat(aX), CGFloat(aY))
                }
            }
            self.velocity = CGPointMake(((self.thumbNode.position.x - self.anchorPointInPoints().x)), ((self.thumbNode.position.y - self.anchorPointInPoints().y)))
            self.angularVelocity = Float(-atan2(self.thumbNode.position.x - self.anchorPointInPoints().x, self.thumbNode.position.y - self.anchorPointInPoints().y))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSLog("touch end")
        self.resetVelocity()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.resetVelocity()
    }
    
    func resetVelocity() {
        self.isTracking = false
        self.velocity = CGPointZero
        let easeOut: SKAction = SKAction.moveTo(self.anchorPointInPoints(), duration: kThumbSpringBackDuration)
        easeOut.timingMode = SKActionTimingMode.EaseOut
        self.thumbNode.runAction(easeOut)
        //self.thumbNode.position = CGPointZero
    }
}
