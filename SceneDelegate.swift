//
//  SceneDelegate.swift
//  PhotoLibrary
//
//  Created by 김윤석 on 2023/10/31.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let repository = RepositoryImp()
        let viewModel = MainViewModel(repository)
        let vc = MainViewController(viewModel)
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
}
