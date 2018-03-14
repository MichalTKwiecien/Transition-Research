//
//  ViewController.swift
//  TransitionTests
//
//  Created by Michał Kwiecień on 05/01/2018.
//  Copyright © 2018 Michał Kwiecień. All rights reserved.
//

import UIKit

enum PresentationStyle {
    case modal
    case push
}

enum TransitionStyle {
    case spring
    case dissolve
}

final class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var presentationControl: UISegmentedControl!
    @IBOutlet weak var transitionControl: UISegmentedControl!
    private let cellImages = [#imageLiteral(resourceName: "image1"), #imageLiteral(resourceName: "image2"), #imageLiteral(resourceName: "image3"), #imageLiteral(resourceName: "image4"), #imageLiteral(resourceName: "image5")]
    
    /// Modal animation controllers
    private var scalePresentAnimationController: ScalePresentAnimationController?
    private var scaleDismissAnimationController: ScaleDismissAnimationController?
    
    /// Navigation Controller animation controller
    private var crossDisolveAnimationController: CrossDisolveAnimationController?
    
    private var presentationStyle: PresentationStyle {
        return presentationControl.selectedSegmentIndex == 0 ? .modal : .push
    }
    
    private var transitionStyle: TransitionStyle {
        return transitionControl.selectedSegmentIndex == 0 ? .spring : .dissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.delegate = self
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellImages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as? PhotoTableViewCell else {
            return UITableViewCell()
        }
        let image = cellImages[indexPath.row]
        cell.photoImageView.image = image
        cell.label.text = "Image at row \(indexPath.row)"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? PhotoTableViewCell else { return }
        let image = cellImages[indexPath.row]
        let detailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        detailVC.transitioningDelegate = self
        detailVC.loadViewIfNeeded()
        detailVC.imageView.image = image
        
        let convertedFrame = view.convert(cell.photoImageView.frame, from: cell)
        
        /// Sets presentation style for interaction controller
        let interactionController = detailVC.swipeInteractionController
        interactionController.presentationStyle = presentationStyle
        
        /// Modal animation controllers
        scalePresentAnimationController = ScalePresentAnimationController(
            originFrame: convertedFrame,
            originView: cell.photoImageView
        )
        scaleDismissAnimationController = ScaleDismissAnimationController(
            destinationFrame: convertedFrame,
            interactionController: interactionController
        )
        
        /// Navigation Controller animation controllers
        crossDisolveAnimationController = CrossDisolveAnimationController(
            interactionController: interactionController
        )
        
        switch presentationStyle {
        case .modal:
            navigationController?.present(detailVC, animated: true)
        case .push:
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
    }
    
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch transitionStyle {
        case .spring:
            return scalePresentAnimationController
        case .dissolve:
            return crossDisolveAnimationController
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch transitionStyle {
        case .spring:
            return scaleDismissAnimationController
        case .dissolve:
            return crossDisolveAnimationController
        }
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? ScaleDismissAnimationController,
            let interactionController = animator.interactionController,
            interactionController.isInProgress
            else { return nil }
        return interactionController
    }
    
}

extension MainViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return transitionStyle == .dissolve ? crossDisolveAnimationController : scalePresentAnimationController
        case .pop:
            return transitionStyle == .dissolve ? crossDisolveAnimationController : scaleDismissAnimationController
        default:
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animationController as? CrossDisolveAnimationController,
            let interactionController = animator.interactionController,
            interactionController.isInProgress
            else { return nil }
        return interactionController
    }
    
}


