//
//  ViewController.swift
//  Colored squares everywhere
//
//  Created by Мирошниченко Марина on 13.04.2020.
//  Copyright © 2020 Мирошниченко Марина. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var leftView: UIView!
    @IBOutlet var middleView: UIView!
    @IBOutlet var rightView: UIView!
    @IBOutlet var upView: UIView!
    
    private var statesHistory: [ViewControllerState] = []
    
    private var viewControllersStack: [ViewController] = []
    
    private var wasAlreadyCreated = false
    
    private var state = ViewControllerState()
    
    // MARK: - Public methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        leftView.backgroundColor = state.leftColor
        middleView.backgroundColor = state.middleColor
        rightView.backgroundColor = state.rightColor
        
        if state.selectedColor != nil {
            
            let selectedView = getViewForSelectedColor()
            upView.bringSubviewToFront(selectedView)
            
            NSLayoutConstraint.activate([
                selectedView.widthAnchor.constraint(equalTo: upView.widthAnchor),
            ])
            
            upView.layoutIfNeeded()
        }
    }
    
    @IBAction func didSelectColor(_ sender: UITapGestureRecognizer) {
        guard let viewColor = sender.view?.backgroundColor else {
            return
        }
        
        state.selectedColor = viewColor
        
        UIView.animate(withDuration: 1, animations: {
            self.upView.bringSubviewToFront(sender.view!)
            
            NSLayoutConstraint.activate([
                sender.view!.widthAnchor.constraint(equalTo: self.upView.widthAnchor),
            ])
            
            self.upView.layoutIfNeeded()
            
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            
            let newVC = self.getNewVC()
            self.navigationController?.pushViewController(newVC, animated: true)
            }
        )
    }

    
    // MARK: - Private methods
    private func getNewVC() -> ViewController {
        if !wasAlreadyCreated {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let newVC = storyboard.instantiateViewController(identifier: "Main") as! ViewController
            
            newVC.statesHistory = statesHistory + [state]
            
            viewControllersStack.append(newVC)
            
            wasAlreadyCreated = true
            
            return newVC
            
            } else {
            let lastVC = viewControllersStack.removeLast()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let newVC = storyboard.instantiateViewController(identifier: "Main") as! ViewController
            
            newVC.wasAlreadyCreated = lastVC.wasAlreadyCreated
            newVC.viewControllersStack = lastVC.viewControllersStack
            newVC.state = lastVC.state
            newVC.statesHistory = lastVC.statesHistory
            
            viewControllersStack.append(newVC)
            
            return newVC
        }
    }
    
    private func getViewForSelectedColor() -> UIView {
        switch state.selectedColor {
        case leftView.backgroundColor:
            return leftView
        case middleView.backgroundColor:
            return middleView
        case rightView.backgroundColor:
            return rightView
        default:
            assert(false, "Should never reach there")
            return UIView()
        }
    }
}

