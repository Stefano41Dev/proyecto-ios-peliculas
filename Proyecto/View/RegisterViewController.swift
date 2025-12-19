//
//  RegisterViewController.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//

import UIKit

class RegisterViewController: UIViewController {

    private let viewModel = AuthViewModel()

    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Correo electrónico"
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

    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Crear cuenta", for: .normal)
        btn.backgroundColor = .systemRed
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // NUEVO BOTÓN: Para ir al Login si ya tiene cuenta
    private let loginAccountButton: UIButton = {
        let btn = UIButton(type: .system)
        // Usamos un texto con dos colores o simple, aquí uno simple pero elegante
        let attributedTitle = NSMutableAttributedString(string: "¿Ya tienes cuenta? ", attributes: [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7),
            .font: UIFont.systemFont(ofSize: 14)
        ])
        attributedTitle.append(NSAttributedString(string: "Inicia sesión", attributes: [
            .foregroundColor: UIColor.systemRed,
            .font: UIFont.boldSystemFont(ofSize: 14)
        ]))
        
        btn.setAttributedTitle(attributedTitle, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(registerButton)
        view.addSubview(loginAccountButton) // Agregamos el nuevo botón a la vista

        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        // Conectamos la acción de ir al login
        loginAccountButton.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)

        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor),

            registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            registerButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Constraints para el botón de Login
            loginAccountButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 16),
            loginAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginAccountButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        if password.count < 6 {
                    let alert = UIAlertController(title: "Contraseña muy corta", message: "La contraseña debe tener al menos 6 caracteres.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Entendido", style: .default))
                    present(alert, animated: true)
                    return
                }
        
        if viewModel.register(email: email, password: password) {
            let alert = UIAlertController(title: "¡Éxito!", message: "Cuenta creada exitosamente", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true)
            })
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "No se pudo crear la cuenta", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    // Acción para volver al Login
    @objc private func handleGoToLogin() {
        // Simplemente cerramos esta pantalla para volver a la anterior (Login)
        dismiss(animated: true, completion: nil)
    }
}
