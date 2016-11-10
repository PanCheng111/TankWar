//
//  ChooseScene.swift
//  TankWar
//
//  Created by 阿若 on 16/6/27.
//  Copyright © 2016年 阿若. All rights reserved.
//

import Foundation
import SpriteKit

class ChooseScene: SKScene {
    var startGame = false
    var selectedLevel: String!
    var needBack = false
    var startFight = false
    
    let buttomBarButtonHeight: CGFloat = 70
    let buttomBarButtonWidth: CGFloat = 100
    
    override init(size: CGSize) {
        super.init(size: size)
        // to do
        let background = SKSpriteNode(imageNamed: "infoview.jpg")
        background.size = size
        background.position = CGPointMake(background.size.width / 2, background.size.height / 2)
        self.addChild(background)
        let level1 = SKSpriteNode(imageNamed: "level1.png")
        let level2 = SKSpriteNode(imageNamed: "level2.png")
        let level3 = SKSpriteNode(imageNamed: "level1.png")
        let topBar = SKSpriteNode(imageNamed: "header.png")
        let backButton = SKSpriteNode(imageNamed: "backButton.png")
        let fightButton = SKSpriteNode(imageNamed: "Fight.png")
        
        //topBar.alpha = 0.9
        topBar.size.height = 50
        topBar.size.width = size.width
        topBar.position = CGPointMake(topBar.size.width / 2, size.height - topBar.size.height / 2)
        backButton.size.height = 40
        backButton.size.width = 60
        backButton.position = CGPointMake(backButton.size.width / 2 + 5, topBar.position.y)
        backButton.name = "backButton"
        
        let levelWidth = size.width / 3 - 20
        level1.size.height = 160
        level1.size.width = levelWidth
        level1.position = CGPointMake(level1.size.width / 2 + 10, size.height / 2)
        level1.name = "level1"
        
        level2.size.height = 160
        level2.size.width = levelWidth
        level2.position = CGPointMake(level2.size.width / 2 + level1.size.width + 30, size.height / 2)
        level2.name = "level2"
        
        level3.size.height = 160
        level3.size.width = levelWidth
        level3.position = CGPointMake(level3.size.width / 2 + level1.size.width + level2.size.width + 50, size.height / 2)
        level3.name = "level3"
        
        fightButton.size.height = 80
        fightButton.size.width = 150
        fightButton.position = CGPointMake(size.width - fightButton.size.width / 2 - 10, fightButton.size.height / 2 + 10)
        fightButton.name = "fightButton"
        
        self.addChild(topBar)
        self.addChild(backButton)
        self.addChild(level1)
        self.addChild(level2)
        self.addChild(level3)
        //self.addChild(fightButton)
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Choose a Scene"
        label.fontSize = 30
        label.position = topBar.position
        label.position.y -= 10
        self.addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            if node.name == "level1" {
                self.selectedLevel = "level1"
            }
            if node.name == "level2" {
                self.selectedLevel = "level2"
            }
            if node.name == "level3" {
                self.selectedLevel = "level3"
            }
            
            if node.name == "backButton" {
                self.needBack = true
            }
            if node.name == "fightButton" {
                self.startFight = true
            }
        }
    }
}
