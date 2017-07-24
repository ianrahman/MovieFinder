//
//  MovieViewController.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit

// MARK: - Movie View Controller Delegate

protocol MovieViewControllerDelegate {
    
    func viewDidLoad(_ viewController: MovieViewController)
    func didTapCloseButton(on viewController: MovieViewController)
    
}

// MARK: - Movie View Controller

final class MovieViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: MovieCoordinator?
    
    lazy var closeBarButtonItem: UIBarButtonItem = {
        let closeBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(didTapCloseButton))
        return closeBarButtonItem
    }()
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var overviewContentLabel: UILabel!
    @IBOutlet weak var castContentLabel: UILabel!
    
    // MARK: - Actions
    
    @objc fileprivate func didTapCloseButton() {
        coordinator?.didTapCloseButton(on: self)
    }
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        coordinator?.viewDidLoad(self)
    }
    
}
