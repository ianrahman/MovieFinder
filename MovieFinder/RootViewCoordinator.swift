//
//  RootViewCoordinator.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit

// MARK: - Root View Controller Provider Protocol

protocol RootViewControllerProvider: class {
    
    var rootViewController: UIViewController { get }
    
}

// MARK: - Root View Coordinator Typealias

typealias RootViewCoordinator = Coordinator & RootViewControllerProvider
