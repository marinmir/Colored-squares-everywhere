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
    @IBOutlet var suggestedColorsView: UIView!
    
    private var screenHistory: UICollectionView!
    private var statesHistory: [ViewControllerState] = []
    private var viewControllersStack: [ViewController] = []
    private var wasAlreadyCreated = false
    private var state = ViewControllerState()
    private let requiredSelectedColorsCount = 3
    
    // MARK: - Public methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        leftView.backgroundColor = state.leftColor
        middleView.backgroundColor = state.middleColor
        rightView.backgroundColor = state.rightColor
        
        setAppearance()
        
        if (state.selectedColor != nil) {
            drawSelectedColor(for: getViewForSelectedColor())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let indexPath = IndexPath(row: statesHistory.count - 1, section: 0)
        screenHistory.scrollToItem(at: indexPath, at: .right, animated: false)
    }
    
    @IBAction func didSelectColor(_ sender: UITapGestureRecognizer) {
        guard let viewColor = sender.view?.backgroundColor else {
            return
        }
        
        state.selectedColor = viewColor
        
        UIView.animate(withDuration: 1, animations: {
            self.drawSelectedColor(for: sender.view!)
            
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.chooseNextStep()
            }
        )
    }
    
    // MARK: - Private methods
    private func setAppearance() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = .horizontal
        
        screenHistory = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        screenHistory.dataSource = self
        screenHistory.delegate = self
        screenHistory.register(ScreenHistoryCell.self, forCellWithReuseIdentifier: ScreenHistoryCell.cellID)
        screenHistory.showsVerticalScrollIndicator = false
        screenHistory.showsHorizontalScrollIndicator = true
        screenHistory.isPagingEnabled = true
        screenHistory.backgroundColor = UIColor.white

        screenHistory.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(screenHistory)
        
        NSLayoutConstraint.activate([
            screenHistory.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -40),
            screenHistory.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 40),
            screenHistory.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            screenHistory.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -22),
        ])
    }
    
    private func chooseNextStep() {
        if isEnoughSelectedColors() && wasSameColors() {
            if navigationController?.viewControllers.count == requiredSelectedColorsCount {
                finishGame()
            } else {
                returnToPreviousColor()
            }
        }
        else {
            goToNextVC()
        }
    }
    
    private func finishGame() {
        let newVC = createNewVC()
        navigationController?.setViewControllers([newVC], animated: true)
        newVC.showVictoryAlert()
    }
    
    private func returnToPreviousColor() {
        guard let lastVC = navigationController?.viewControllers[navigationController!.viewControllers.count - requiredSelectedColorsCount - 1] as? ViewController else {
            assert(false, "There should be no other view controllers")
            return
        }
        lastVC.wasAlreadyCreated = false
        lastVC.viewControllersStack.removeLast()
        navigationController?.popToViewController(lastVC, animated: true)
    }
    
    private func goToNextVC() {
        let newVC = getNextVC()
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    private func getNextVC() -> ViewController {
        if !wasAlreadyCreated {
            let newVC = createNewVC()
            
            newVC.statesHistory = statesHistory + [state]
            viewControllersStack.append(newVC)
            wasAlreadyCreated = true
            
            return newVC
        } else {
            let lastVC = viewControllersStack.removeLast()
            let newVC = createNewVC()
            
            newVC.wasAlreadyCreated = lastVC.wasAlreadyCreated
            newVC.viewControllersStack = lastVC.viewControllersStack
            newVC.state = lastVC.state
            newVC.statesHistory = lastVC.statesHistory
            
            viewControllersStack.append(newVC)
            
            return newVC
        }
    }
    
    private func createNewVC() -> ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewController(identifier: "Main") as! ViewController
        
        return newVC
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
    
    private func drawSelectedColor(for selectedView: UIView) {
        if state.selectedColor != nil {
            suggestedColorsView.bringSubviewToFront(selectedView)
            
            NSLayoutConstraint.activate([
                selectedView.widthAnchor.constraint(equalTo: suggestedColorsView.widthAnchor),
            ])
            
            suggestedColorsView.layoutIfNeeded()
        }
    }
    
    private func wasSameColors() -> Bool {
        let lastColor = statesHistory[statesHistory.count - 1].selectedColor ?? UIColor.white
        let preLastColor = statesHistory[statesHistory.count - 2].selectedColor ?? UIColor.white
        
        return state.selectedColor == lastColor && state.selectedColor == preLastColor
    }
    
    private func isEnoughSelectedColors() -> Bool {
        return (statesHistory.count + 1) >= requiredSelectedColorsCount // +1 for current controller
    }
    
    private func showVictoryAlert() {
        let alertVC = UIAlertController(title: "Victory!!!", message: "You won", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statesHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = screenHistory.dequeueReusableCell(withReuseIdentifier: ScreenHistoryCell.cellID, for: indexPath) as! ScreenHistoryCell
        
        let color = statesHistory[indexPath.row].selectedColor ?? UIColor.black
        cell.setColor(color)
        return cell
    }
    
}
