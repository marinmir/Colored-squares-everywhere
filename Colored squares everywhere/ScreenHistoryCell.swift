//
//  ScreenHistoryCell.swift
//  Colored squares everywhere
//
//  Created by Мирошниченко Марина on 17.04.2020.
//  Copyright © 2020 Мирошниченко Марина. All rights reserved.
//

import UIKit

class ScreenHistoryCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let cellID = "ScreenHistoryCell"
    
    
    // MARK: - Public methods
    public func setColor(_ color: UIColor) {
        contentView.backgroundColor = color
    }
}
