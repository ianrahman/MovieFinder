//
//  NetworkingService.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Marshal

// MARK: - API Endpoint

enum APIEndpoint {
    
    // MARK: - Cases
    
    case movie(id: Int)
    case popularMovies(page: Int)
    case search(query: String, page: Int)
    case image(path: String)
    case genres
    
    // MARK: - Static Properties
    
    static let apiURL = "https://api.themoviedb.org/3"
    static let imageURL = "https://image.tmdb.org/t/p/w500"
    static let apiKeyParameter = "api_key"
    static let pageKey = "page"
    static let appendParameter = "append_to_response"
    static let creditsValue = "credits"
    static let queryKey = "query"
    
    // MARK: - Computed Properties
    
    fileprivate var url: String {
        return baseUrl + path
    }
    
    fileprivate var baseUrl: String {
        switch self {
        case .image:
            return APIEndpoint.imageURL
        default:
            return APIEndpoint.apiURL
        }
    }
    
    fileprivate var apiKey: String {
        return Secrets.apiKey
    }
    
    fileprivate var method: Alamofire.HTTPMethod {
        switch self {
        case .movie,
             .popularMovies,
             .genres,
             .image,
             .search:
            return .get
        }
    }
    
    fileprivate var path: String {
        switch self {
        case .movie(let id):
            return "/movie/\(id)"
        case .popularMovies:
            return "/movie/popular"
        case .genres:
            return "/genre/movie/list"
        case .image(let path):
            return path
        case .search(_):
            return "/search/movie"
        }
    }
    
    fileprivate var parameters: [String: Any] {
        var params: [String: Any] = [APIEndpoint.apiKeyParameter: apiKey]
        
        switch self {
        case .movie(_):
            params[APIEndpoint.appendParameter] = APIEndpoint.creditsValue
            return params
        case .popularMovies(let page):
            params[APIEndpoint.pageKey] = page
            return params
        case .genres:
            return params
        case .image(_):
            return params
        case .search(let query, let page):
            params[APIEndpoint.pageKey] = page
            params[APIEndpoint.queryKey] = query
            return params
        }
    }
    
    fileprivate var encoding: URLEncoding {
        return .queryString
    }
    
}

// MARK: - Networking Service

struct NetworkingService {
    
    func fetch(_ endpoint: APIEndpoint,
               with completion: @escaping (Result<Any>) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        Alamofire.request(endpoint.url,
                          method: endpoint.method,
                          parameters: endpoint.parameters,
                          encoding: endpoint.encoding,
                          headers: nil)
        .validate()
        .responseJSON { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
