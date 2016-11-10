//
//  Location.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import Foundation
import SceneKit

class Location: NSObject, NSCoding {
    var position: SCNVector3
    var rotation: SCNVector4
    
    init(position: SCNVector3, rotation: SCNVector4) {
        self.position = position
        self.rotation = rotation
    }
    
    required init?(coder aDecoder: NSCoder) {
        let px = aDecoder.decodeObjectForKey("position.x") as! Float
        let py = aDecoder.decodeObjectForKey("position.y") as! Float
        let pz = aDecoder.decodeObjectForKey("position.z") as! Float
        self.position = SCNVector3Make(px, py, pz)
        
        
        let rx = aDecoder.decodeObjectForKey("rotation.x") as! Float
        let ry = aDecoder.decodeObjectForKey("rotation.y") as! Float
        let rz = aDecoder.decodeObjectForKey("rotation.z") as! Float
        let rw = aDecoder.decodeObjectForKey("rotation.w") as! Float
        self.rotation = SCNVector4Make(rx, ry, rz, rw)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(position.x, forKey: "position.x")
        aCoder.encodeObject(position.y, forKey: "position.y")
        aCoder.encodeObject(position.z, forKey: "position.z")
        aCoder.encodeObject(rotation.x, forKey: "rotation.x")
        aCoder.encodeObject(rotation.y, forKey: "rotation.y")
        aCoder.encodeObject(rotation.z, forKey: "rotation.z")
        aCoder.encodeObject(rotation.w, forKey: "rotation.w")
    }
}