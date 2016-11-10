//
//  PlayerCell.swift
//  TankWar
//
//  Created by 阿若 on 16/6/27.
//  Copyright © 2016年 阿若. All rights reserved.
//

import UIKit
import Cartography

final class PlayerCell: UICollectionViewCell {

    class var reuseID: String { return "PlayerCell" }
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel() {
        // Label
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = lightColor
        label.font = UIFont.boldSystemFontOfSize(22)

        // Layout
        constrain(label) { label in
            label.edges == inset(label.superview!.edges, 15, 10); return
        }
    }
}
