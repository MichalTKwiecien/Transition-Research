//
//  ScalePushAnimationController.swift
//  TransitionTests
//
//  Created by Michał Kwiecień on 05/01/2018.
//  Copyright © 2018 Michał Kwiecień. All rights reserved.
//

import UIKit

final class CrossDisolveAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let animationDuration: TimeInterval = 1.0
    var isPushing: Bool = true
    let interactionController: SwipeInteractionController?
    
    init(interactionController: SwipeInteractionController?) {
        self.interactionController = interactionController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to)else { return }

        transitionContext.containerView.addSubview(toVC.view)
        toVC.view.alpha = 0
        
        UIView.animateKeyframes(
            withDuration: animationDuration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    toVC.view.alpha = 1
                }
        },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

