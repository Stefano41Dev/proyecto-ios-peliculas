//
//  ProfileViewController.swift
//  Proyecto
//
//  Created by DESIGN on 17/12/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // Obtener datos del usuario
    private var userEmail: String {
            return KeychainManager.getCurrentUser() ?? "Invitado"
        }

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped) // Estilo moderno iOS
        tv.backgroundColor = .black
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // Opciones del menú
    private let menuItems = [
        ("Cuenta", "person.fill"),
        ("Notificaciones", "bell.fill"),
        ("Ayuda", "questionmark.circle"),
        ("Cerrar Sesión", "rectangle.portrait.and.arrow.right")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Mi Perfil"
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        setupHeader()
    }
    
    private func setupHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 200))
        headerView.backgroundColor = .black
        
        let avatarContainer = UIView()
        avatarContainer.backgroundColor = .darkGray
        avatarContainer.layer.cornerRadius = 50
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let avatarLabel = UILabel()
        avatarLabel.text = String(userEmail.prefix(1)).uppercased() // Primera letra del email
        avatarLabel.font = .systemFont(ofSize: 40, weight: .bold)
        avatarLabel.textColor = .white
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let emailLabel = UILabel()
        emailLabel.text = userEmail
        emailLabel.textColor = .white
        emailLabel.font = .systemFont(ofSize: 18, weight: .medium)
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarLabel)
        headerView.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            avatarContainer.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            avatarContainer.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -20),
            avatarContainer.widthAnchor.constraint(equalToConstant: 100),
            avatarContainer.heightAnchor.constraint(equalToConstant: 100),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 16),
            emailLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func handleLogout() {
            // Alerta de confirmación
            let alert = UIAlertController(title: "¿Cerrar Sesión?", message: "¿Estás seguro de que quieres salir?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive, handler: { _ in
                
                // 1. IMPORTANTE: Limpiamos solo la "sesión activa" (el registro de quién está usándola ahora).
                // NO llamamos a clearCredentials(), para que la contraseña siga guardada en el Keychain.
                KeychainManager.clearCurrentSession()
                
                // 2. Navegar al Login (Reseteando toda la pila de navegación)
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let delegate = windowScene.delegate as? SceneDelegate,
                      let window = delegate.window else { return }
                
                let loginVC = LoginViewController()
                window.rootViewController = loginVC
                window.makeKeyAndVisible()
                
                // Animación de transición suave
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            present(alert, animated: true)
        }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        let item = menuItems[indexPath.row]
        
        cell.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        cell.textLabel?.text = item.0
        cell.textLabel?.textColor = .white
        cell.imageView?.image = UIImage(systemName: item.1)
        cell.imageView?.tintColor = .white
        cell.accessoryType = .disclosureIndicator
        
        // Estilo especial para Logout
        if item.0 == "Cerrar Sesión" {
            cell.textLabel?.textColor = .systemRed
            cell.imageView?.tintColor = .systemRed
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if menuItems[indexPath.row].0 == "Cerrar Sesión" {
            handleLogout()
        }
    }
}
