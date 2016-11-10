//
//  MenuViewController.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import UIKit
import Cartography

private let myName = UIDevice.currentDevice().name


final class MenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Properties
    
    private let startGameButton = UIButton(type: .System)
    private let backButton = UIButton(type: .System)
    private let separator = UIView()
    private let collectionView = UICollectionView(frame: CGRectZero,
                                                  collectionViewLayout: UICollectionViewFlowLayout())
    private var playerLocation = [String: Player]()
    private var thisPlayer: Player!
    var tankName: String!
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        //setupNavigationBar()
        //setupLaunchImage()
        setupBackButton()
        setupStartGameButton()
        setupSeparator()
        setupCollectionView()
        playerLocation = [:]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updatePlayers()
        
        connectionManager.onConnect { _ in
            NSLog("onConnect")
            self.updatePlayers()
        }
        connectionManager.onDisconnect { _ in
            self.updatePlayers()
        }
        connectionManager.onEvent(.Location) { [unowned self] _, object in
            let dict = object as! [String: NSData]
            let data = dict["player"]!
            let player = Player(mpcSerialized: data)
            NSLog("Player.name=\(player.name), Player.location=\(player.location)")
            if (self.playerLocation[player.name] == nil) {
                self.playerLocation[player.name] = player
            }
            if (self.playerLocation.count == connectionManager.otherPlayers.count
                && self.thisPlayer != nil) {
                self.startGame(otherPlayers: self.playerLocation)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        connectionManager.onConnect(nil)
        connectionManager.onDisconnect(nil)
        let observedEvents: [Event] = [.Move, .Location, .StartGame, .Fire, .ReLive, .EndGame]
        for event in observedEvents {
            connectionManager.onEvent(event, run: nil)
        }

        super.viewWillDisappear(animated)
    }
    
    // MARK: UI
    
    private func setupNavigationBar() {
        navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.translucent = true
    }
    
    private func setupLaunchImage() {
        view.addSubview(UIImageView(image: UIImage.launchImage()))
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        blurView.frame = view.bounds
        view.addSubview(blurView)
    }
    
    private func setupStartGameButton() {
        // Button
        startGameButton.translatesAutoresizingMaskIntoConstraints = false
        startGameButton.titleLabel!.font = startGameButton.titleLabel!.font.fontWithSize(25)
        startGameButton.setTitle("Waiting For Players", forState: .Disabled)
        startGameButton.setTitle("Start Game", forState: .Normal)
        startGameButton.addTarget(self, action: #selector(MenuViewController.startGame as (MenuViewController) -> () -> ()), forControlEvents: .TouchUpInside)
        startGameButton.enabled = false
        view.addSubview(startGameButton)
        
        // Layout
        constrain(startGameButton) { button in
            button.top == button.superview!.top + 30
            button.centerX == button.superview!.centerX
        }
    }
    
    private func setupBackButton() {
        // Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.titleLabel!.font = startGameButton.titleLabel!.font.fontWithSize(25)
        backButton.setTitle("<<", forState: .Normal)
        backButton.addTarget(self, action: #selector(MenuViewController.goBack as (MenuViewController) -> () -> ()), forControlEvents: .TouchUpInside)
        backButton.enabled = true
        view.addSubview(backButton)
        
        // Layout
        constrain(backButton) { button in
            button.top == button.superview!.top + 30
            button.leadingMargin == button.superview!.leadingMargin
        }

    }
    
    private func setupSeparator() {
        // Separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = lightColor
        view.addSubview(separator)
        
        
        // Layout
        constrain(separator, startGameButton) { separator, startGameButton in
            separator.top == startGameButton.bottom + 20
            separator.centerX == separator.superview!.centerX
            separator.width == separator.superview!.width - 40
            //NSLog("separator, width = %d\n", separator.superview!.width - 40)
            separator.height == 1 / UIScreen.mainScreen().scale
        }
    }
    
    private func setupCollectionView() {
        // Collection View
        let cvLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cvLayout.itemSize = CGSizeMake(separator.frame.size.width, 50)
        cvLayout.minimumLineSpacing = 0
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerClass(PlayerCell.self,
                                     forCellWithReuseIdentifier: PlayerCell.reuseID)
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        
        // Layout
        constrain(collectionView, separator) { collectionView, separator in
            collectionView.top == separator.bottom
            collectionView.left == separator.left
            collectionView.right == separator.right
            collectionView.bottom == collectionView.superview!.bottom
        }
    }
    
    // MARK: Actions
    
    func goBack() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chooseVC = storyboard.instantiateViewControllerWithIdentifier("ChooseViewController") as! ChooseViewController
        self.presentViewController(chooseVC, animated: true, completion: nil)
    }
    
    func startGame() {
        thisPlayer = Player(name: myName, tankName: tankName);
        sendThisPlayer(thisPlayer)
        SVProgressHUD.showWithStatus("Loading the Scene...")
        if (self.playerLocation.count == connectionManager.otherPlayers.count
            && self.thisPlayer != nil) {
            self.startGame(otherPlayers: self.playerLocation)
        }
    }
    
    private func startGame(otherPlayers otherPlayer: [String:Player]) {
//        if thisPlayer == nil {
//            thisPlayer = Player(name: myName, tankName: tankName)
//            sendThisPlayer(thisPlayer)
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gameVC = storyboard.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        gameVC.thisPlayer = thisPlayer
        gameVC.otherPlayers = otherPlayer
        self.presentViewController(gameVC, animated: true, completion: nil)
        //self.navigationController!.presentViewController(gameVC, animated: true, completion: nil)
    }
    
    // MARK: Multipeer
    
    private func sendThisPlayer(thisPlayer: Player) {
        connectionManager.sendEventForEach(.Location) {
            return ["player": self.thisPlayer!]
        }
    }
    
    private func updatePlayers() {
        startGameButton.enabled = (connectionManager.otherPlayers.count > 0)
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return connectionManager.otherPlayers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlayerCell.reuseID, forIndexPath: indexPath) as! PlayerCell
        cell.label.text = connectionManager.otherPlayers[indexPath.row].name
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
        if self.isViewLoaded() && self.view.window == nil {
            self.view = nil
            NSLog("remove menu view")
        }
    }
}
