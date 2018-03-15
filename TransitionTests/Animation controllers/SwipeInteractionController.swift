//
//  SwipeInteractionController.swift
//  TransitionTests
//
//  Created by Michał Kwiecień on 05/01/2018.
//  Copyright © 2018 Michał Kwiecień. All rights reserved.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {

    var presentationStyle: PresentationStyle = .modal
    private let maxTranslationAvailable: CGFloat = 200
    private let translationProgressNeededToDismiss: CGFloat = 0.1
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        prepareGestureRecognizer(in: viewController.view)
    }
    
    private func prepareGestureRecognizer(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view, let superview = view.superview else { return }
        let translation = gestureRecognizer.translation(in: superview)
        let translationValue = fmax(abs(translation.y), abs(translation.x))
        var progress = (translationValue / maxTranslationAvailable)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch gestureRecognizer.state {
        case .began:
            switch presentationStyle {
            case .modal:
                viewController.dismiss(animated: true, completion: nil)
            case .push:
                viewController.navigationController?.popViewController(animated: true)
            }
        case .changed:
            shouldCompleteTransition = progress > translationProgressNeededToDismiss
            update(progress)
        case .cancelled:
            cancel()
        case .ended:
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}
