//
//  MovieListCoordinator.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import UIKit
import SwiftUI

/// Coordinator for the Movie List tab.
///
/// Manages navigation within the Movie List flow.
/// Wraps SwiftUI views in UIHostingController for UIKit navigation.
final class MovieListCoordinator {
    private let navigationController: UINavigationController
    private let container: DependencyContainer
    private var viewModel: MovieListViewModel?

    init(navigationController: UINavigationController, container: DependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    /// Starts the coordinator and displays the movie list.
    func start() {
        let repository = container.makeMovieRepository()
        viewModel = MovieListViewModel(repository: repository,
                                       onMovieSelected: self.navigateToDetailScreenFor)
        let view = MovieListView(viewModel: viewModel!)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Popular Movies"
        navigationController.pushViewController(hostingController, animated: false)
    }
    
    func navigateToDetailScreenFor(movie:Movie) {
        let view = MovieDetailView(movie: movie)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = movie.title
        navigationController.pushViewController(hostingController, animated: true)
    }
}
