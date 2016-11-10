//
//  FireTrail.swift
//  TankWar
//
//  Created by 潘成 on 16/6/27.
//  Copyright © 2016年 潘成. All rights reserved.
//

import Foundation
import SceneKit

struct FireTrail: MPCSerializable {
    
    // MARK: Properties
    var source: Destination
    var destination: Destination
    
    var mpcSerialized: NSData {
        let dict = ["destination": NSKeyedArchiver.archivedDataWithRootObject(destination),
                    "source": NSKeyedArchiver.archivedDataWithRootObject(source)]
        return NSKeyedArchiver.archivedDataWithRootObject(dict)
    }
    
    // MARK: Initializers
    
    init(src: SCNVector3, dst: SCNVector3) {
        self.source = Destination(destination: src)
        self.destination = Destination(destination: dst)
    }
    
    init(mpcSerialized: NSData) {
        let dict = NSKeyedUnarchiver.unarchiveObjectWithData(mpcSerialized) as! [String: NSData]
        self.destination = NSKeyedUnarchiver.unarchiveObjectWithData(dict["destination"]!) as! Destination
        self.source = NSKeyedUnarchiver.unarchiveObjectWithData(dict["source"]!) as! Destination
    }
    
}

