//
//  LoginViewController.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//

import UIKit

class LoginViewController: UIViewController {

    private let viewModel = AuthViewModel()

   
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "IconApp")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    

    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Correo electrónico / Usuario"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        tf.textColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Contraseña"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        tf.textColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Iniciar sesión", for: .normal)
        btn.backgroundColor = .systemRed
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let registerLabel: UILabel = {
        let label = UILabel()
        label.text = "¿No tienes cuenta?"
        label.textColor = .white.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let createAccountButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Crear cuenta", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black
        
        // Añadir la imagen a la vista
        view.addSubview(iconImageView)
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(registerLabel)
        view.addSubview(createAccountButton)

        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(openRegister), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // --- Constraints para la Imagen ---
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 120), // Puedes ajustar el tamaño aquí
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            // ----------------------------------

            // Modificamos el topAnchor del email para que esté debajo de la imagen
            emailTextField.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor),

            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            registerLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 40),
            registerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            createAccountButton.topAnchor.constraint(equalTo: registerLabel.bottomAnchor, constant: 8),
            createAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }

        if viewModel.login(email: email, password: password) {
            let mainTabBar = MainTabBarController()
            mainTabBar.modalPresentationStyle = .fullScreen
            mainTabBar.modalTransitionStyle = .crossDissolve
            present(mainTabBar, animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "Usuario o contraseña incorrectos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    @objc private func openRegister() {
        let registerVC = RegisterViewController()
        registerVC.modalPresentationStyle = .fullScreen
        present(registerVC, animated: true)
    }
}
