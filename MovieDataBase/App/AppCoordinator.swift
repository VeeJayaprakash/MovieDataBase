//
//  AppCoordinator.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import UIKit

/// Main app coordinator managing the tab bar and child coordinators.
///
/// Creates and configures the UITabBarController with Movie List and Search tabs.
/// Each tab has its own coordinator managing its navigation stack.
final class AppCoordinator {
    private let window: UIWindow
    private let container: DependencyContainer

    private var movieListCoordinator: MovieListCoordinator?
    private var searchCoordinator: SearchCoordinator?

    init(window: UIWindow, container: DependencyContainer) {
        self.window = window
        self.container = container
    }

    /// Starts the coordinator and displays the tab bar.
    func start() {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = UIColor(named: "AccentColor") 

        // Movie List Tab
        let movieListNav = UINavigationController()
        movieListNav.tabBarItem = UITabBarItem(
            title: "Movies",
            image: UIImage(systemName: "film"),
            selectedImage: UIImage(systemName: "film.fill")
        )
        movieListCoordinator = MovieListCoordinator(
            navigationController: movieListNav,
            container: container
        )
        movieListCoordinator?.start()

        // Search Tab
        let searchNav = UINavigationController()
        searchNav.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        searchCoordinator = SearchCoordinator(
            navigationController: searchNav,
            container: container
        )
        searchCoordinator?.start()

        tabBarController.viewControllers = [movieListNav, searchNav]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
