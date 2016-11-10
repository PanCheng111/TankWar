//
//  TouchableLabel.swift
//  TankWar
//
//  Created by 阿若 on 16/6/27.
//  Copyright © 2016年 阿若. All rights reserved.
//

import UIKit

final class TouchableLabel: UILabel {
    var placeholderRanges = [NSRange]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setLastTokenAlpha(alpha: CGFloat) {
        if let lastRange = placeholderRanges.last,
            mAttributedText = attributedText?.mutableCopy() as? NSMutableAttributedString {
            mAttributedText.addAttribute(NSForegroundColorAttributeName, value: tintColor.colorWithAlphaComponent(alpha), range: lastRange)
            attributedText = mAttributedText
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        setLastTokenAlpha(0.5)
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        setLastTokenAlpha(1)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        setLastTokenAlpha(1)
    }
}
