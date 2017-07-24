//
//  Person.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/22/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import Foundation
import Marshal

// MARK: - Person Model

struct Person {
    
    let name: String
    
}

// MARK: - Unmarshaling Conformance

extension Person: Unmarshaling {
    
    init(object: MarshaledObject) throws {
        name = try object.value(for: "name")
    }
    
}
