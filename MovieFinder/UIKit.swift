//
//  UIKit.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit

// MARK: - UIStoryboard

extension UIStoryboard {
    
    enum Storyboard: String {
        case results
        case movie
        
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    convenience init(_ storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.filename, bundle: bundle)
    }
    
    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Developer Error: Please ensure identifiers are correct and set accordingly in respective storyboards/nibs.")
        }
        return viewController
    }
    
}

// MARK: - UIViewController

extension UIViewController: StoryboardIdentifiable { }

// MARK: - UITableViewCell

extension UITableViewCell: StoryboardIdentifiable { }

// MARK: - UITableView

extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.storyboardIdentifier, for: indexPath) as? T else {
            fatalError("Developer Error: Could not find cell with identifier \(T.storyboardIdentifier).")
        }
        return cell
    }
    
    func cellForRow<T: UITableViewCell>(at indexPath: IndexPath) -> T {
        guard let cell = cellForRow(at: indexPath) as? T else {
            fatalError("Developer Error: Could not find cell with identifier \(T.storyboardIdentifier).")
        }
        return cell
    }
    
    func register<T: UITableViewCell>(cellType: T.Type)
        where T: Reusable & NibLoadable {
            self.register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T
        where T: Reusable {
            guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
                fatalError("Could not find cell with identifier \(cellType.reuseIdentifier).")
            }
            return cell
    }
    
}

// MARK: - UIView

extension UIView {
    
    func loadNib(name: String) -> UIView {
        guard let view = UINib(nibName: name, bundle: nil).instantiate(withOwner: self, options: nil)[0] as? UIView else {
            fatalError("Developer Error: Could not find nib named \(name).")
        }
        view.frame = bounds
        return view
    }
    
}

// MARK: - UIImageView

extension UIImageView {
    
    // TODO: - Move into Networking Service
    func fetchImage(for movie: Movie, with networkingService: NetworkingService) {
        let fullPath = "https://image.tmdb.org/t/p/w500\(movie.posterPath)?\(APIEndpoint.apiKeyParameter)=\(Secrets.apiKey)"
        let url = URL(string: fullPath)!
        let placeholderImage = UIImage(named: "placeholder")!
        self.af_setImage(withURL: url, placeholderImage: placeholderImage)
    }
    
}
