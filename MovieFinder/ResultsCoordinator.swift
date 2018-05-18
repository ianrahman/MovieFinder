//
//  ResultsCoordinator.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Marshal
import Speech

// MARK: - App Coordinator

final class AppCoordinator: NSObject, RootViewCoordinator {
    
    // MARK: - Properties
    
    let services: Services
    var childCoordinators: [Coordinator] = []
    fileprivate lazy var navigationController: UINavigationController = UINavigationController()
    fileprivate let window: UIWindow
    fileprivate let movieCellIdentifier = "movieCell"
    fileprivate var movies = [Movie]()
    fileprivate var genres = [Genre]()
    fileprivate var nextPage: Int = 1
    fileprivate var totalPages: Int = Int.max
    fileprivate var notificationView: NotificationView?
    fileprivate var isLoading = false
    fileprivate var currentEndpoint: APIEndpoint = .genres
    fileprivate let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    fileprivate var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    fileprivate lazy var audioEngine = AVAudioEngine()
    
    var rootViewController: UIViewController {
        return self.navigationController
    }
    
    // MARK: - Init
    
    public init(window: UIWindow, services: Services) {
        self.services = services
        self.window = window
    }
    
    // MARK: - Functions
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        speechRecognizer?.delegate = self
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = .white
        navigationBarAppearace.barTintColor = .black
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        showInitialViewController { (viewController) in
            loadCurrentEndpoint(with: viewController, completion: { (result) in
                self.currentEndpoint = .popularMovies(page: self.nextPage)
                self.loadCurrentEndpoint(with: viewController, completion: { (result) in
                    self.navigationController.viewControllers = [viewController]
                })
            })
        }
    }
    
    fileprivate func showInitialViewController(with completion: (ResultsViewController) -> Void) {
        let storyboard = UIStoryboard(.results)
        let viewController: ResultsViewController = storyboard.instantiateViewController()
        viewController.coordinator = self
        completion(viewController)
    }
    
    fileprivate func startAndPresent(_ movieCoordinator: MovieCoordinator) {
        movieCoordinator.start()
        addChildCoordinator(movieCoordinator)
        rootViewController.present(movieCoordinator.rootViewController, animated: true)
    }
    
    fileprivate func resetPages() {
        nextPage = 1
        totalPages = Int.max
    }
    
    fileprivate func shouldLoadNextPage() -> Bool {
        return nextPage <= totalPages && !isLoading
    }
}

// MARK: - Networking Interface

extension AppCoordinator {
    
    fileprivate func loadCurrentEndpoint(with viewController: ResultsViewController,
                                         completion: @escaping (Result<Any>) -> Void) {
        
        switch currentEndpoint {
        case .search(let query, _):
            currentEndpoint = .search(query: query, page: nextPage)
            guard shouldLoadNextPage() else { return }
        case .popularMovies(_):
            currentEndpoint = .popularMovies(page: nextPage)
            guard shouldLoadNextPage() else { return }
        default: break
        }
        
        isLoading = true
        showNotificationView(.loading)
        
        services.networking.fetch(currentEndpoint) { (result) in
            self.isLoading = false
            self.hideNotification()
            
            switch result {
            case .success(let value):
                switch self.currentEndpoint {
                case .genres:
                    self.updateGenres(from: value)
                case .popularMovies(_):
                    self.displayMovies(from: value, with: viewController)
                case .search(_):
                    self.displayMovies(from: value, with: viewController, isSearch: true)
                default: break
                }
            case .failure(_):
                self.handleError(for: result)
            }
            
            completion(result)
        }
    }
    
    fileprivate func updateGenres(from value: Any) {
        guard let json = value as? JSONObject else {
            showNotification(type: .jsonError)
            return
        }
        
        do {
            self.genres = try json.value(for: "genres")
        } catch _ {
            showNotification(type: .jsonError)
        }
    }
    
    fileprivate func displayMovies(from value: Any,
                                   with viewController: ResultsViewController,
                                   isSearch: Bool = false) {
        guard let json = value as? JSONObject else {
            self.showNotification(type: .jsonError)
            return
        }
        
        do {
            nextPage = try json.value(for: "page") + 1
            totalPages = try json.value(for: "total_pages")
            let newMovies: [Movie] = try json.value(for: "results")
            isSearch ? movies = newMovies : movies.append(contentsOf: newMovies)
            let tableView = viewController.tableView
            tableView?.reloadData()
        } catch _ {
            showNotification(type: .jsonError)
        }
    }
    
    fileprivate func handleError(for result: Result<Any>) {
        switch result {
        case .failure(let error):
            let message = error.localizedDescription
            showNotificationView(.defaultError(message))
        case.success(_): break
        }
    }
    
}

// MARK: - Results View Controller Delegate

extension AppCoordinator: ResultsCoordinator {
    
    func viewDidLoad(_ viewController: ResultsViewController) {
        viewController.tableView.register(cellType: MovieCell.self)
        viewController.tableView.delegate = self
        viewController.tableView.dataSource = self
        setUI(for: viewController)
    }
    
    func didTapMovie(_ movie: Movie) {
        let movieCoordinator = MovieCoordinator(with: services, delegate: self, movie: movie)
        startAndPresent(movieCoordinator)
    }
    
    func didTapVoiceSearchButton(on viewController: ResultsViewController) {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        switch speechStatus {
        case .authorized:
            if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                viewController.voiceSearchBarButtonItem.isEnabled = false
                viewController.voiceSearchBarButtonItem.title = "Search"
            } else {
                startRecording(with: viewController)
                viewController.voiceSearchBarButtonItem.title = "Stop"
            }
        default:
            configureSpeech(with: viewController)
        }
    }
    
}

// MARK: - View Controller Functions

extension ResultsCoordinator {
    
    fileprivate func setUI(for viewController: ResultsViewController) {
        viewController.title = "Movie Finder"
        viewController.navigationItem.rightBarButtonItem = viewController.voiceSearchBarButtonItem
        viewController.tableView.rowHeight = 100
        viewController.tableView.separatorInset = .zero
        
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        switch speechStatus {
        case .authorized, .notDetermined:
            viewController.voiceSearchBarButtonItem.isEnabled = true
        default:
            viewController.voiceSearchBarButtonItem.isEnabled = false
        }
    }
    
}

// MARK: - TableView Delegate

extension AppCoordinator: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let movieCoordinator = MovieCoordinator(with: services, delegate: self, movie: movie)
        startAndPresent(movieCoordinator)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if yOffset > maximumOffset && nextPage < totalPages {
            guard let viewController = rootViewController.childViewControllers.first as? ResultsViewController else { return }
            
            loadCurrentEndpoint(with: viewController, completion: {_ in })
        }
    }
    
}

// MARK: - TableView Data Source

extension AppCoordinator: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as MovieCell
        let movie = movies[indexPath.row]
        
        configure(cell, for: movie)
        
        return cell
    }
    
    fileprivate func configure(_ cell: MovieCell, for movie: Movie) {
        var movieGenres = [Genre]()
        
        if let genreIDs = movie.genreIDs {
            for id in genreIDs {
                if let genre = genres.filter({$0.id == id}).first {
                    movieGenres.append(genre)
                }
            }
        }
        
        cell.titleLabel.text = movie.title
        cell.genresLabel.text = movieGenres.map({$0.name}).joined(separator: ", ")
        cell.posterImage.fetchImage(for: movie, with: services.networking)
    }
    
}

// MARK: - Movie Coordinator Delegate

extension AppCoordinator: MovieCoordinatorDelegate {
    
    func didTapCloseButton(movieCoordinator: MovieCoordinator) {
        movieCoordinator.rootViewController.dismiss(animated: true)
        removeChildCoordinator(movieCoordinator)
    }
    
    func handleError(_ result: Result<Any>) {
        handleError(for: result)
    }
    
    func showNotification(type: NotificationType) {
        showNotificationView(type)
    }
    
    func hideNotification() {
        hideNotificationView()
    }
    
}

// MARK: - Notification View Functions

extension AppCoordinator {
    
    fileprivate func showNotificationView(_ type: NotificationType) {
        if let notificationView = notificationView {
            switch notificationView.type {
            case .loading:
                switch type {
                case .loading: return
                default: break
                }
            default: return
            }
        }
        self.notificationView = NotificationView(type: type)
        self.notificationView?.present()
        self.notificationView?.delegate = self
    }
    
    fileprivate func hideNotificationView() {
        notificationView?.dismiss()
        notificationView = nil
    }
    
}

// MARK: - Speech Recognizer Delegate

extension AppCoordinator: SFSpeechRecognizerDelegate {
    
    func configureSpeech(with viewController: ResultsViewController) {
        SFSpeechRecognizer.requestAuthorization { (speechStatus) in
            switch speechStatus {
            case .authorized:
                viewController.voiceSearchBarButtonItem.isEnabled = true
            default:
                viewController.voiceSearchBarButtonItem.isEnabled = false
            }
        }
    }
    
    func startRecording(with viewController: ResultsViewController) {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            let message = "Unable to set up audio session."
            showNotificationView(.defaultError(message))
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
                let message = "Unable to initiate speech recognition."
                showNotificationView(.defaultError(message))
                return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if let result = result {
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                viewController.voiceSearchBarButtonItem.isEnabled = true
            }
            
            if let error = error {
                self.handleError(for: .failure(error))
                return
            }
            
            if isFinal, let result = result {
                let query = result.bestTranscription.formattedString
                self.resetPages()
                self.currentEndpoint = .search(query: query, page: self.nextPage)
                self.loadCurrentEndpoint(with: viewController, completion: {_ in })
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch let error {
            let message = error.localizedDescription
            showNotificationView(.defaultError(message))
        }
    }
    
}

// MARK: - Notification View Delegate Conformance

extension AppCoordinator: NotificationViewDelegate {
    
    func retry() {
        hideNotificationView()
        
        guard let viewController = rootViewController.childViewControllers.first as? ResultsViewController else { return }
        
        resetPages()
        movies = [Movie]()
        currentEndpoint = .popularMovies(page: nextPage)
        loadCurrentEndpoint(with: viewController) { _ in }
    }
    
}
