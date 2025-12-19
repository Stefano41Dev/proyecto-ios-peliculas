//
//  ProfileViewController.swift
//  Proyecto
//
//  Created by DESIGN on 17/12/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Propiedades
    private let authViewModel = AuthViewModel()
    
    // Obtener datos del usuario
    private var userEmail: String {
        return KeychainManager.getCurrentUser() ?? "Invitado"
    }
    
    // Opciones del menú
    private let menuItems = [
        ("Cuenta", "person.fill"),
        ("Panel de Preferencias", "bell.fill"),
        ("Ayuda", "questionmark.circle"),
        ("Cerrar Sesión", "rectangle.portrait.and.arrow.right")
    ]
    
    // MARK: - Elementos de UI
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .black
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // Imagen de perfil (Interactiva)
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .darkGray
        iv.layer.cornerRadius = 50 // Radio de 50 para que sea un círculo de 100x100
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.isUserInteractionEnabled = true // IMPORTANTE: Permite recibir toques
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Texto de iniciales (se muestra si no hay foto)
    private let initialsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Mi Perfil"
        setupUI()
        loadProfileImage() // Cargar imagen guardada al iniciar
    }
    
    // MARK: - Setup UI
    
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
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 220))
        headerView.backgroundColor = .black
        
        // Contenedor para alinear imagen y label
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Configurar iniciales
        initialsLabel.text = String(userEmail.prefix(1)).uppercased()
        
        let emailLabel = UILabel()
        emailLabel.text = userEmail
        emailLabel.textColor = .white
        emailLabel.font = .systemFont(ofSize: 18, weight: .medium)
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Añadir vistas
        headerView.addSubview(container)
        container.addSubview(avatarImageView)
        avatarImageView.addSubview(initialsLabel) // Las iniciales van DENTRO de la imagen (por si está vacía)
        headerView.addSubview(emailLabel)
        
        // Gesto para detectar click en la imagen
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageSelection))
        avatarImageView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            // Contenedor centrado
            container.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -20),
            container.widthAnchor.constraint(equalToConstant: 100),
            container.heightAnchor.constraint(equalToConstant: 100),
            
            // Imagen llena el contenedor
            avatarImageView.topAnchor.constraint(equalTo: container.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            // Iniciales centradas en la imagen
            initialsLabel.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            
            // Email debajo del contenedor
            emailLabel.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 16),
            emailLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Gestión de Imagen de Perfil
    
    @objc private func handleImageSelection() {
        let alert = UIAlertController(title: "Foto de Perfil", message: "Selecciona una opción", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Abrir Galería", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Eliminar Foto Actual", style: .destructive, handler: { _ in
            self.deleteProfileImage()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    private func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true // Permite recortar la imagen a cuadrado
            present(imagePicker, animated: true)
        }
    }
    
    // --- Persistencia de Imagen (Guardar en Archivos) ---
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Genera una ruta única basada en el email del usuario
    private var imagePath: URL {
        let safeEmail = userEmail.replacingOccurrences(of: "@", with: "_").replacingOccurrences(of: ".", with: "-")
        return getDocumentsDirectory().appendingPathComponent("profile_\(safeEmail).jpg")
    }
    
    private func saveImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: imagePath)
        }
    }
    
    private func loadProfileImage() {
        let path = imagePath.path
        if FileManager.default.fileExists(atPath: path) {
            // Si existe imagen guardada, la ponemos y ocultamos las iniciales
            avatarImageView.image = UIImage(contentsOfFile: path)
            initialsLabel.isHidden = true
        } else {
            // Si no, mostramos iniciales y fondo gris
            avatarImageView.image = nil
            avatarImageView.backgroundColor = .darkGray
            initialsLabel.isHidden = false
        }
    }
    
    private func deleteProfileImage() {
        try? FileManager.default.removeItem(at: imagePath)
        loadProfileImage() // Recargar para volver a mostrar las iniciales
    }
    
    // MARK: - Lógica de Logout
    
    private func handleLogout() {
        let alert = UIAlertController(title: "¿Cerrar Sesión?", message: "¿Estás seguro de que quieres salir?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive, handler: { _ in
            KeychainManager.clearCurrentSession()
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate,
                  let window = delegate.window else { return }
            
            let loginVC = LoginViewController()
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - Extension: TableView Delegate & DataSource

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
        
        if item.0 == "Cerrar Sesión" {
            cell.textLabel?.textColor = .systemRed
            cell.imageView?.tintColor = .systemRed
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let itemTitle = menuItems[indexPath.row].0
        
        switch itemTitle {
        case "Cuenta":
            showAccountOptions()
            
        case "Panel de Preferencias":
            let notificationsVC = NotificationSettingsViewController()
            navigationController?.pushViewController(notificationsVC, animated: true)
            
        case "Cerrar Sesión":
            handleLogout()
            
        case "Ayuda":
            let alert = UIAlertController(title: "Ayuda", message: "Versión de la App: 0.1.0\nContacta a soporte@movieapp.com", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
        default:
            break
        }
    }
}

// MARK: - Extension: Lógica de "Cuenta" (Cambiar Email/Pass)

extension ProfileViewController {
    
    private func showAccountOptions() {
        let actionSheet = UIAlertController(title: "Configuración de Cuenta", message: "¿Qué deseas modificar?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cambiar Correo / Usuario", style: .default, handler: { _ in
            self.showChangeEmailAlert()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cambiar Contraseña", style: .default, handler: { _ in
            self.showChangePasswordAlert()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    // ALERTA: Cambiar Email
    private func showChangeEmailAlert() {
        let alert = UIAlertController(title: "Actualizar Correo", message: "Ingresa tu contraseña actual y el nuevo correo.", preferredStyle: .alert)
        
        alert.addTextField { tf in
            tf.placeholder = "Nuevo Correo"
            tf.keyboardType = .emailAddress
        }
        alert.addTextField { tf in
            tf.placeholder = "Contraseña Actual"
            tf.isSecureTextEntry = true
        }
        
        let saveAction = UIAlertAction(title: "Guardar", style: .default) { _ in
            guard let newEmail = alert.textFields?[0].text, !newEmail.isEmpty,
                  let currentPass = alert.textFields?[1].text, !currentPass.isEmpty else {
                self.showError("Por favor completa todos los campos.")
                return
            }
            
            let success = self.authViewModel.changeEmail(currentEmail: self.userEmail, currentPass: currentPass, newEmail: newEmail)
            
            if success {
                self.showSuccess("Correo actualizado correctamente.")
                self.setupHeader() // Recargar el header para ver el nuevo correo/inicial
            } else {
                self.showError("Contraseña incorrecta o error al guardar.")
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    // ALERTA: Cambiar Contraseña
    private func showChangePasswordAlert() {
        let alert = UIAlertController(title: "Cambiar Contraseña", message: nil, preferredStyle: .alert)
        
        alert.addTextField { tf in
            tf.placeholder = "Contraseña Actual"
            tf.isSecureTextEntry = true
        }
        alert.addTextField { tf in
            tf.placeholder = "Nueva Contraseña"
            tf.isSecureTextEntry = true
        }
        alert.addTextField { tf in
            tf.placeholder = "Confirmar Nueva Contraseña"
            tf.isSecureTextEntry = true
        }
        
        let saveAction = UIAlertAction(title: "Actualizar", style: .default) { _ in
            guard let currentPass = alert.textFields?[0].text, !currentPass.isEmpty,
                  let newPass = alert.textFields?[1].text, !newPass.isEmpty,
                  let confirmPass = alert.textFields?[2].text, !confirmPass.isEmpty else {
                self.showError("Completa todos los campos.")
                return
            }
            
            guard newPass == confirmPass else {
                self.showError("Las nuevas contraseñas no coinciden.")
                return
            }
            
            if newPass.count < 6 {
                self.showError("La contraseña debe tener al menos 6 caracteres.")
                return
            }
            
            let success = self.authViewModel.changePassword(email: self.userEmail, currentPass: currentPass, newPass: newPass)
            
            if success {
                self.showSuccess("Tu contraseña ha sido actualizada.")
            } else {
                self.showError("La contraseña actual es incorrecta.")
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccess(_ message: String) {
        let alert = UIAlertController(title: "Éxito", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Extension: Image Picker Delegate (Gestión de Galería)

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 1. Obtener la imagen (Editada o Original)
        if let editedImage = info[.editedImage] as? UIImage {
            self.avatarImageView.image = editedImage
            self.saveImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            self.avatarImageView.image = originalImage
            self.saveImage(originalImage)
        }
        
        // 2. Ocultar las iniciales porque ya tenemos foto
        self.initialsLabel.isHidden = true
        
        // 3. Cerrar la galería
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
