//
//  ScalePresentAnimationController.swift
//  TransitionTests
//
//  Created by Michał Kwiecień on 05/01/2018.
//  Copyright © 2018 Michał Kwiecień. All rights reserved.
//

import UIKit

final class ScalePresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let animationDuration: TimeInterval = 1.0
    private let originFrame: CGRect
    private let originView: UIView
    
    init(originFrame: CGRect, originView: UIView) {
        self.originFrame = originFrame
        self.originView = originView
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
        else { return }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        snapshot.frame = originFrame
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        toVC.view.isHidden = true
        originView.isHidden = true
        
        UIView.animateKeyframes(
            withDuration: animationDuration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/4) {
                    snapshot.layer.transform = CATransform3DMakeScale(0.75, 0.75, 1)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3) {
                    snapshot.frame = finalFrame
                }
        },
            completion: { _ in
                toVC.view.isHidden = false
                self.originView.isHidden = false
                snapshot.removeFromSuperview()
                fromVC.view.layer.transform = CATransform3DIdentity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
