//
//  IntroScene.swift
//  TankWar
//
//  Created by 阿若 on 16/6/27.
//  Copyright © 2016年 阿若. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

let TankDetail = [
    "T-90": ["速度": 100, "攻击力": 200, "防御力": 600, "装弹速度": 10],
    "AUSFB": ["速度": 120, "攻击力": 180, "防御力": 500, "装弹速度": 12],
    "FV510": ["速度": 90, "攻击力": 190, "防御力": 620, "装弹速度": 11]
]

let TankScene = [
    "T-90": SCNScene(named: "art.scnassets/T-90/T-90.dae")!,
    "AUSFB": SCNScene(named: "art.scnassets/AUSFB/AUSFB.dae")!,
    "FV510": SCNScene(named: "art.scnassets/FV510/FV510.dae")!
]

class IntroScene: SKScene {
    var startGame = false
    var selectedTank: String = "T-90"
    var topBar: SKSpriteNode!
    var label: SKLabelNode!
    var nameLabel: SKLabelNode!
    var overlay: SKSpriteNode!
    
    let buttomBarButtonHeight: CGFloat = 70
    let buttomBarButtonWidth: CGFloat = 100
    
    override init(size: CGSize) {
        super.init(size: size)
        // to do
        let background = SKSpriteNode(imageNamed: "infoview.jpg")
        background.size = size
        background.position = CGPointMake(background.size.width / 2, background.size.height / 2)
        //self.addChild(background)
        let startButton = SKSpriteNode(imageNamed: "startButton.png")
        let buttomBar = SKSpriteNode(imageNamed: "header.png")
        topBar = SKSpriteNode(imageNamed: "header.png")
        let T90 = SKSpriteNode(imageNamed: "T-90.png")
        let AUSFB = SKSpriteNode(imageNamed: "AUSFB.png")
        let FV510 = SKSpriteNode(imageNamed: "FV510.png")
        buttomBar.alpha = 0.9
        topBar.alpha = 0.9
        topBar.size.height = 50
        topBar.size.width = size.width
        
        buttomBar.size.height = 80
        buttomBar.size.width = size.width
        startButton.size.width = 140
        startButton.size.height = 70
        T90.size.height = buttomBarButtonHeight
        T90.size.width = buttomBarButtonWidth
        AUSFB.size.height = buttomBarButtonHeight
        AUSFB.size.width = buttomBarButtonWidth
        FV510.size.height = buttomBarButtonHeight
        FV510.size.width = buttomBarButtonWidth
        
        topBar.position = CGPointMake(topBar.size.width / 2, size.height - topBar.size.height / 2)
        buttomBar.position = CGPointMake(buttomBar.size.width / 2, buttomBar.size.height / 2)
        startButton.position = CGPointMake(size.width - startButton.size.width / 2 - 10, startButton.size.height / 2 + 5)
        startButton.name = "startButton"
        T90.position = CGPointMake(T90.size.width / 2 + 10, T90.size.height / 2 + 5)
        T90.name = "T-90"
        AUSFB.position = CGPointMake(AUSFB.size.width / 2 + T90.size.width + 20, AUSFB.size.height / 2 + 5)
        AUSFB.name = "AUSFB"
        FV510.position = CGPointMake(FV510.size.width / 2 + T90.size.width + AUSFB.size.width + 30, FV510.size.height / 2 + 5)
        FV510.name = "FV510"
        
        self.addChild(topBar)
        self.addChild(buttomBar)
        self.addChild(startButton)
        self.addChild(T90)
        self.addChild(AUSFB)
        self.addChild(FV510)
        setupLabel(selectedTank)
        if connectionManager == nil {
            setupOverlay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel(name: String) {
        if (label != nil) {
            label.removeFromParent()
            nameLabel.removeFromParent()
        }
        let dict = TankDetail[name]!
        label = SKLabelNode(text: "速度：\(dict["速度"]!)   攻击力：\(dict["攻击力"]!)   防御力：\(dict["防御力"]!)   装弹速度：\(dict["装弹速度"]!)")
        label.fontName = "Chalkduster"
        label.fontSize = 20
        label.position = topBar.position
        
        nameLabel = SKLabelNode(fontNamed: "Chalkduster")
        nameLabel.text = name
        nameLabel.fontSize = 40
        nameLabel.position.x = topBar.position.x
        nameLabel.position.y = topBar.position.y - 60
        self.addChild(label)
        self.addChild(nameLabel)
    }
    
    func setupOverlay()  {
        overlay = SKSpriteNode(imageNamed: "buttomBar.png")
        overlay.position.x = size.width / 2
        overlay.position.y = size.height / 2
        overlay.size = self.size
        overlay.alpha = 0.9
        overlay.name = "overlay"
        addChild(overlay)
        
        let serverNode = SKLabelNode(fontNamed: "Chalkduster")
        serverNode.text = "As Server"
        serverNode.fontSize = 40
        serverNode.position.x = size.width / 2 - 150
        serverNode.position.y = size.height / 2
        serverNode.name = "serverNode"
        addChild(serverNode)
        
        let clientNode = SKLabelNode(fontNamed: "Chalkduster")
        clientNode.text = "As Client"
        clientNode.fontSize = 40
        clientNode.position.x = size.width / 2 + 150
        clientNode.position.y = size.height / 2
        clientNode.name = "clientNode"
        addChild(clientNode)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            if node.name == "startButton" {
                self.startGame = true
            }
            if node.name == "T-90" {
                self.selectedTank = "T-90"
            }
            if node.name == "AUSFB" {
                self.selectedTank = "AUSFB"
            }
            if node.name == "FV510" {
                self.selectedTank = "FV510"
            }
            if node.name == "serverNode" {
                overlay.removeFromParent()
                node.removeFromParent()
                childNodeWithName("clientNode")?.removeFromParent()
                dispatch_async(dispatch_get_main_queue()) {
                    connectionManager = ConnectionManager()
                    connectionManager.isServer = true
                    connectionManager.initSocket()
                    connectionManager.start()
                }
            }
            if node.name == "clientNode" {
                overlay.removeFromParent()
                node.removeFromParent()
                childNodeWithName("serverNode")?.removeFromParent()
                dispatch_async(dispatch_get_main_queue()) {
                    connectionManager = ConnectionManager()
                    connectionManager.isServer = false
                    connectionManager.initSocket()
                    connectionManager.start()
                }
            }
        }
        setupLabel(selectedTank)
    }
}