//
//  Destination.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import Foundation
import SceneKit

class Destination: NSObject, NSCoding {
    var destination: SCNVector3
    
    init(destination: SCNVector3) {
        self.destination = destination
    }
    
    required init?(coder aDecoder: NSCoder) {
        let px = aDecoder.decodeObjectForKey("destination.x") as! Float
        let py = aDecoder.decodeObjectForKey("destination.y") as! Float
        let pz = aDecoder.decodeObjectForKey("destination.z") as! Float
        self.destination = SCNVector3Make(px, py, pz)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(destination.x, forKey: "destination.x")
        aCoder.encodeObject(destination.y, forKey: "destination.y")
        aCoder.encodeObject(destination.z, forKey: "destination.z")
    }
}