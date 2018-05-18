//
//  MovieCoordinator.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit
import Alamofire
import Marshal

//  MARK: - Movie Coordinator Delegate

protocol MovieCoordinatorDelegate: class {
    
    func didTapCloseButton(movieCoordinator: MovieCoordinator)
    func handleError(_ result: Result<Any>)
    func showNotification(type: NotificationType)
    func hideNotification()
    
}

//  MARK: - Movie Coordinator

class MovieCoordinator: NSObject, RootViewCoordinator {

    //  MARK: - Properties
    
    let services: Services
    var childCoordinators: [Coordinator] = []
    fileprivate weak var delegate: MovieCoordinatorDelegate?
    fileprivate var movie: Movie
    
    var rootViewController: UIViewController {
        return self.navigationController
    }
    
    fileprivate lazy var navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        return navigationController
    }()
    
    // MARK: - Init
    
    init(with services: Services, delegate: MovieCoordinatorDelegate, movie: Movie) {
        self.services = services
        self.delegate = delegate
        self.movie = movie
    }
    
    // MARK: - General Functions
    
    func start() {
        delegate?.showNotification(type: .loading)
        loadMovieDetails(for: movie) { (result) in
            switch result {
            case .success(let value):
                guard let json = value as? JSONObject else {
                    self.delegate?.showNotification(type: .jsonError)
                    return
                }
                
                do {
                    self.movie = try Movie(object: json)
                } catch {
                    self.delegate?.showNotification(type: .jsonError)
                }
                
            case .failure(let error):
                self.delegate?.handleError(.failure(error))
            }
            
            self.delegate?.hideNotification()
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(.movie)
                let viewController: MovieViewController = storyboard.instantiateViewController()
                self.configureAndPresent(viewController: viewController)
            }
        }
    }
    
    fileprivate func configureAndPresent(viewController: MovieViewController) {
        viewController.coordinator = self
        navigationController.viewControllers = [viewController]
    }
    
    fileprivate func loadMovieDetails(for movie: Movie, completion: @escaping (Result<Any>) -> ()) {
        services.networking.fetch(.movie(id: movie.id)) { (result) in
            completion(result)
        }
    }
    
}

// MARK: - Movie View Controller Delegate

extension MovieCoordinator: MovieViewControllerDelegate {
    
    func viewDidLoad(_ viewController: MovieViewController) {
        setUI(for: viewController)
    }
    
    func didTapCloseButton(on viewController: MovieViewController) {
        delegate?.didTapCloseButton(movieCoordinator: self)
    }
    
}

// MARK: - View Controller Functions

extension MovieCoordinator {
    
    fileprivate func setUI(for viewController: MovieViewController) {
        viewController.navigationItem.leftBarButtonItem = viewController.closeBarButtonItem
        viewController.title = movie.title
        viewController.overviewContentLabel.text = movie.overview
        viewController.posterImage.fetchImage(for: movie, with: services.networking)
        
        var subCast = [Person]()
        if var cast = movie.cast {
            let castLimit = min(5, cast.count)
            while subCast.count < castLimit {
                if let first = cast.first {
                    subCast.append(first)
                    cast.remove(at: 0)
                }
            }
            viewController.castContentLabel.text = subCast.map({$0.name}).joined(separator: "\n").appending("\n\n")
        }
        
        viewController.containerView.layoutIfNeeded()
        viewController.scrollView.contentSize = viewController.containerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
}
