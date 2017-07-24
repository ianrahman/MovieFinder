//
//  Movie.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import Foundation
import Marshal

// MARK: - Movie

struct Movie {
    
    // MARK: - Properties
    
    let id: Int
    let title: String
    let popularity: Double
    let overview: String
    let posterPath: String
    let genreIDs: [Int]?
    let cast: [Person]?
    
}

// MARK: - Unmarshaling Conformance

extension Movie: Unmarshaling {
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        title = try object.value(for: "title")
        popularity = try object.value(for: "popularity")
        overview = try object.value(for: "overview")
        posterPath = try object.value(for: "poster_path")
        genreIDs = try object.value(for: "genre_ids")
        cast = try object.value(for: "credits.cast")
    }
    
}
