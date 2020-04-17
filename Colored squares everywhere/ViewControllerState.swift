//
//  ViewControllerState.swift
//  Colored squares everywhere
//
//  Created by Мирошниченко Марина on 13.04.2020.
//  Copyright © 2020 Мирошниченко Марина. All rights reserved.
//

import UIKit

struct ViewControllerState {
    
    // MARK: - Properties
    var leftColor: UIColor!
    var middleColor: UIColor!
    var rightColor: UIColor!
    
    var selectedColor: UIColor?
    
    let availableColors: [UIColor] = [.red, .blue, .green, .orange, .systemPurple]
    
    // MARK: - Public methods
    init() {
        generateColors()
    }
    
    mutating func generateColors() {
        leftColor = availableColors.randomElement() ?? UIColor.white
        
        var lastColors = availableColors
        lastColors.remove(at: lastColors.firstIndex(of: leftColor)!)
        middleColor = lastColors.randomElement() ?? UIColor.white
        
        lastColors.remove(at: lastColors.firstIndex(of: middleColor)!)
        rightColor = lastColors.randomElement() ?? UIColor.white
    }
    
}
