//
//  Reusable.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit

// MARK: - Reusable Protocol

public protocol Reusable: class {

    static var reuseIdentifier: String { get }

}

public typealias NibReusable = Reusable & NibLoadable

// MARK: - Default Implementation

public extension Reusable {

    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}
