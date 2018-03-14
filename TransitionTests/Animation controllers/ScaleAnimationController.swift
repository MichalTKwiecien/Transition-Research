//
//  ScaleAnimationController.swift
//  TransitionTests
//
//  Created by Michał Kwiecień on 05/01/2018.
//  Copyright © 2018 Michał Kwiecień. All rights reserved.
//

import UIKit

final class ScaleAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let animationDuration: TimeInterval = 1.0
    private let originFrame: CGRect
    private let isPresenting: Bool
    
    init(originFrame: CGRect?, isPresenting: Bool) {
        self.originFrame = originFrame ?? .zero
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let toSnapshot = toVC.view.snapshotView(afterScreenUpdates: true),
            let fromVC = transitionContext.viewController(forKey: .from),
            let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: true)
        else { return }
        let containerView = transitionContext.containerView
        
        let snapshot = isPresenting ? toSnapshot : fromSnapshot
        snapshot.frame = isPresenting ? originFrame : fromVC.view.frame
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        toVC.view.isHidden = isPresenting
    
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                snapshot.frame = self.isPresenting ? transitionContext.finalFrame(for: toVC) : self.originFrame
            }, completion: { _ in
                toVC.view.isHidden = transitionContext.transitionWasCancelled
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
