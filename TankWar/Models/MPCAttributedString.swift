//
//  MPCAttributedString.swift
//  TankWar
//
//  Created by 阿若 on 16/6/27.
//  Copyright © 2016年 阿若. All rights reserved.
//

import UIKit

struct MPCAttributedString: MPCSerializable {
    let attributedString: NSAttributedString

    var mpcSerialized: NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(attributedString)
    }

    init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }

    init(mpcSerialized: NSData) {
        let attributedString = NSKeyedUnarchiver.unarchiveObjectWithData(mpcSerialized) as! NSAttributedString
        self.init(attributedString: attributedString)
    }
}
