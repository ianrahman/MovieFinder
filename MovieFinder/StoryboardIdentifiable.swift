//
//  StoryboardIdentifiable.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit

// MARK: - Storyboard Identifiable Protocol

protocol StoryboardIdentifiable {
    
    static var storyboardIdentifier: String { get }
    
}

// MARK: - View Controller

extension StoryboardIdentifiable where Self: UIViewController {
    
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
    
}

// MARK: - Table View Cell

extension StoryboardIdentifiable where Self: UITableViewCell {
    
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
    
}
