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

enum TransitionStyle: Int {
    case `default`
    case dissolve
    case spring
}

final class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var presentationControl: UISegmentedControl!
    @IBOutlet weak var transitionControl: UISegmentedControl!
    private let cellImages = [#imageLiteral(resourceName: "image1"), #imageLiteral(resourceName: "image2"), #imageLiteral(resourceName: "image3"), #imageLiteral(resourceName: "image4"), #imageLiteral(resourceName: "image5")]
    
    private var lastSelectedCellFrame: CGRect?
    private weak var detailVC: DetailViewController?
    
    private var presentationStyle: PresentationStyle {
        return presentationControl.selectedSegmentIndex == 0 ? .modal : .push
    }
    
    private var transitionStyle: TransitionStyle {
        return TransitionStyle(rawValue: transitionControl.selectedSegmentIndex)!
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
        detailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController
        detailVC?.transitioningDelegate = self
        detailVC?.loadViewIfNeeded()
        detailVC?.imageView.image = image
        
        // Saves last selected cell frame
        lastSelectedCellFrame = view.convert(cell.photoImageView.frame, from: cell)
        
        // Sets presentation style for interaction controller
        detailVC?.swipeInteractionController.presentationStyle = presentationStyle
        
        switch presentationStyle {
        case .modal:
            navigationController?.present(detailVC!, animated: true)
        case .push:
            navigationController?.pushViewController(detailVC!, animated: true)
        }
        
    }
    
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch transitionStyle {
        case .spring:
            return ScaleAnimationController(originFrame: lastSelectedCellFrame, isPresenting: true)
        case .dissolve:
            return CrossDisolveAnimationController()
        case .default:
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch transitionStyle {
        case .spring:
            return ScaleAnimationController(originFrame: lastSelectedCellFrame, isPresenting: false)
        case .dissolve:
            return CrossDisolveAnimationController()
        case .default:
            return nil
        }
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let detailVC = detailVC, detailVC.swipeInteractionController.isInProgress else { return nil }
        return detailVC.swipeInteractionController
    }
    
}

extension MainViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            switch transitionStyle {
            case .spring:
                return ScaleAnimationController(originFrame: lastSelectedCellFrame, isPresenting: true)
            case .dissolve:
                return CrossDisolveAnimationController()
            case .default:
                return nil
            }
        case .pop:
            switch transitionStyle {
            case .spring:
                return ScaleAnimationController(originFrame: lastSelectedCellFrame, isPresenting: false)
            case .dissolve:
                return CrossDisolveAnimationController()
            case .default:
                return nil
            }
        default:
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let detailVC = detailVC, detailVC.swipeInteractionController.isInProgress else { return nil }
        return detailVC.swipeInteractionController
    }
}
