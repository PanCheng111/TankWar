//
//  GameOverlayScene.swift
//  TankWar
//
//  Created by 阿若 on 16/6/27.
//  Copyright © 2016年 阿若. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

class GameOverlayScene: SKScene {
    
    var back = false
    var movementJoystick: Joystick
    var fireNode: FirePod
    var timeLabel: SKLabelNode
    var timeDown: Int!
    
    override init(size: CGSize) {
        
        // to do
        /* Create jostick */
        let jsThumb = SKSpriteNode(imageNamed: "joystick")
        let jsBackdrop = SKSpriteNode(imageNamed: "dpad")
        movementJoystick = Joystick(thumbNode:jsThumb, backdropNode:jsBackdrop)
        movementJoystick.position = CGPointMake(jsBackdrop.size.width / 1.5, jsBackdrop.size.height / 1.5)
        
        
        let fire = SKSpriteNode(imageNamed: "jSubstrate")
        fireNode = FirePod(backNode: fire)
        fireNode.position = CGPointMake(size.width - fire.size.width / 1.5, fire.size.height / 1.2)
        
        timeLabel = SKLabelNode(text: "倒计时：120s")
        timeLabel.fontSize = 20
        timeLabel.position = CGPointMake(size.width / 2, size.height - timeLabel.fontSize)
        
        super.init(size: size)
        
        self.addChild(movementJoystick)
        self.addChild(fireNode)
        self.addChild(timeLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            if node.name == "back" {
                self.back = true
            }
        }
    }
    
    func setTime(time: Int) {
        timeDown = time
        let background = SKSpriteNode(imageNamed: "buttomBar.png")
        background.alpha = 0.9
        background.size = size
        background.position = CGPointMake(size.width / 2, size.height / 2)
        background.name = "background"
        
        let timeDownLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeDownLabel.text = "\(timeDown)"
        timeDownLabel.fontSize = 80
        timeDownLabel.color = UIColor.redColor()
        timeDownLabel.position = CGPointMake(size.width / 2, size.height / 2)
        timeDownLabel.name = "timeDownLabel"
        self.addChild(background)
        self.addChild(timeDownLabel)
    }
    
    func updateTime() {
        timeDown = timeDown - 1
        if (timeDown == -1) {
            let background = self.childNodeWithName("background")!
            let timeDownLabel = self.childNodeWithName("timeDownLabel")!
            background.removeFromParent()
            timeDownLabel.removeFromParent()
        }
        else {
            let timeDownLabel = self.childNodeWithName("timeDownLabel")! as! SKLabelNode
            timeDownLabel.text = "\(timeDown)"
        }
    }
}

