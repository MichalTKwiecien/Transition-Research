//
//  DetailViewController.swift
//  TransitionTests
//
//  Created by Michał Kwiecień on 05/01/2018.
//  Copyright © 2018 Michał Kwiecień. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    lazy var swipeInteractionController = SwipeInteractionController(viewController: self)
    
}
