//
//  SplashViewController.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplashImage()
        startSplashTimer()
    }

    private func setupSplashImage() {
        // Imagen que cubre toda la pantalla
        let splashImageView = UIImageView(frame: self.view.bounds)
        splashImageView.image = UIImage(named: "splashImage") // tu imagen
        splashImageView.contentMode = .scaleAspectFill
        splashImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(splashImageView)
    }

    private func startSplashTimer() {
        // Esperar 2 segundos antes de pasar a Login
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showLoginScreen()
        }
    }

    private func showLoginScreen() {
        let loginVC = LoginViewController() // tu pantalla de login
        loginVC.modalTransitionStyle = .crossDissolve
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true)
    }
}
