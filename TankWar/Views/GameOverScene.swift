//
//  GameOverScene.swift
//  TankWar
//
//  Created by 阿若 on 16/6/27.
//  Copyright © 2016年 阿若. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

class GameOverScene: SKScene {
    
    var back = false
    
    init(size: CGSize, score: [String: Int]) {
        super.init(size: size)
        // to do
        //backgroundColor = UIColor.blackColor()
        let background = SKSpriteNode(imageNamed: "buttomBar.png")
        background.alpha = 0.99
        background.size = size
        background.position = CGPointMake(size.width / 2, size.height / 2)
        self.addChild(background)
        
        let sortedKeys = score.keys.sort({ (firstKey, secondKey) -> Bool in
            return score[firstKey] > score[secondKey]
        })
        
        let gameOver = SKLabelNode(fontNamed: "Chalkduster")
        gameOver.text = "Game Over"
        gameOver.fontSize = 50
        gameOver.position = CGPointMake(size.width / 2, size.height / 2 + gameOver.fontSize)
        self.addChild(gameOver)
        
        let name = SKLabelNode(fontNamed: "Chalkduster")
        name.text = "Name"
        name.color = UIColor.redColor()
        name.fontSize = 20
        name.position = CGPointMake(size.width / 2 - 100, size.height / 2)
        self.addChild(name)
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score"
        scoreLabel.color = UIColor.redColor()
        scoreLabel.fontSize = 20
        scoreLabel.position = CGPointMake(size.width / 2 + 100, size.height / 2)
        self.addChild(scoreLabel)
        var i = 0
        for key in sortedKeys {
            i = i + 1
            if i == 3 { break }
            let num = score[key]!
            let entry1 = SKLabelNode(fontNamed: "Chalkduster")
            entry1.text = key
            entry1.color = UIColor.blueColor()
            entry1.fontSize = 15
            entry1.position = CGPointMake(size.width / 2 - 100, size.height / 2 - CGFloat(i) * 20)
            self.addChild(entry1)
            
            let entry2 = SKLabelNode(fontNamed: "Chalkduster")
            entry2.text = "\(num)"
            entry2.color = UIColor.blueColor()
            entry2.fontSize = 15
            entry2.position = CGPointMake(size.width / 2 + 100, size.height / 2 - CGFloat(i) * 20)
            self.addChild(entry2)
        }
        
        let back = SKLabelNode(fontNamed: "Chalkduster")
        back.text = "Go Back"
        back.fontSize = 30
        back.position = CGPointMake(size.width / 2, back.fontSize / 2 + 10)
        back.name = "back"
        
        self.addChild(back)
        
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
}

