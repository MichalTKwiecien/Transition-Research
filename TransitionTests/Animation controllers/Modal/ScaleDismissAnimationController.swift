//
//  ScaleDismissAnimationController.swift
//  TransitionTests
//
//  Created by Michał Kwiecień on 05/01/2018.
//  Copyright © 2018 Michał Kwiecień. All rights reserved.
//

import UIKit

class ScaleDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let animationDuration: TimeInterval = 0.5
    private let destinationFrame: CGRect
    let interactionController: SwipeInteractionController?
    
    init(destinationFrame: CGRect, interactionController: SwipeInteractionController?) {
        self.destinationFrame = destinationFrame
        self.interactionController = interactionController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = fromVC.view.snapshotView(afterScreenUpdates: true),
            let snapshotToVC = toVC.view.snapshotView(afterScreenUpdates: true)
            else { return }
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(snapshotToVC)
        containerView.addSubview(snapshot)
       
        fromVC.view.isHidden = true
        
        UIView.animateKeyframes(
            withDuration: animationDuration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    snapshot.frame = self.destinationFrame
                }
        },
            completion: { _ in
                fromVC.view.isHidden = false
                snapshot.removeFromSuperview()
                snapshotToVC.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
    

