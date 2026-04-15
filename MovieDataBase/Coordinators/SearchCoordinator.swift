//
//  SearchCoordinator.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import UIKit
import SwiftUI

/// Coordinator for the Search tab.
///
/// Manages navigation within the Search flow.
/// Wraps SwiftUI views in UIHostingController for UIKit navigation.
final class SearchCoordinator {
    private let navigationController: UINavigationController
    private let container: DependencyContainer

    init(navigationController: UINavigationController, container: DependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    /// Starts the coordinator and displays the search screen.
    func start() {
        let repository = container.makeMockMovieRepository()
        let viewModel = SearchViewModel(repository: repository)
        let view = SearchView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Search"
        navigationController.pushViewController(hostingController, animated: false)
    }
}
