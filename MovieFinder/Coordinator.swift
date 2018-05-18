//
//  Coordinator.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit

// MARK: - Coordinator Protocol

protocol Coordinator: class {
    
    var services: Services { get }
    var childCoordinators: [Coordinator] { get set }
    var rootViewController: UIViewController { get }
    func start()
}

// MARK: - Default Implementations

extension Coordinator {
    
    func addChildCoordinator(_ childCoordinator: Coordinator) {
        self.childCoordinators.append(childCoordinator)
    }
    
    func removeChildCoordinator(_ childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter { $0 !== childCoordinator }
    }
}
