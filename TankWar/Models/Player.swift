//
//  Player.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import Foundation
import SceneKit
import MultipeerConnectivity

private let myName = UIDevice.currentDevice().name

struct Player: Hashable, Equatable, MPCSerializable {
    
    // MARK: Properties
    
    let name: String
    let tankName: String
    var location: Location
    
    // MARK: Computed Properties
    
    var me: Bool { return name == myName }
    var displayName: String { return me ? "You" : name }
    var hashValue: Int { return name.hash }
    var mpcSerialized: NSData {
        let dict = ["name": NSKeyedArchiver.archivedDataWithRootObject(name),
                    "tankName": NSKeyedArchiver.archivedDataWithRootObject(tankName),
                    "location": NSKeyedArchiver.archivedDataWithRootObject(location)]
        return NSKeyedArchiver.archivedDataWithRootObject(dict)
    }
    
    // MARK: Initializers
    
    init(name: String, tankName: String) {
        self.name = name
        self.tankName = tankName
        self.location = Location(position: SCNVector3Make(Float(arc4random() % 2000), 0, -Float(arc4random() % 2000)), rotation: SCNVector4Make(0, 0, 0, 0))
    }
    
    init(mpcSerialized: NSData) {
        let dict = NSKeyedUnarchiver.unarchiveObjectWithData(mpcSerialized) as! [String: NSData]
        self.name = NSKeyedUnarchiver.unarchiveObjectWithData(dict["name"]!) as! String
        self.tankName = NSKeyedUnarchiver.unarchiveObjectWithData(dict["tankName"]!) as! String
        self.location = NSKeyedUnarchiver.unarchiveObjectWithData(dict["location"]!) as! Location
    }
    
    init(peerName: String) {
        name = peerName
        tankName = "T-90"
        self.location = Location(position: SCNVector3Make(Float(arc4random() % 2000), 0, -Float(arc4random() % 2000)), rotation: SCNVector4Make(0, 0, 0, 0))
    }
    
    // MARK: Methods
    
    func winningString() -> String {
        if me {
            return "You win this round!"
        }
        return "\(name) wins this round!"
    }
    
}

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.name == rhs.name
}
