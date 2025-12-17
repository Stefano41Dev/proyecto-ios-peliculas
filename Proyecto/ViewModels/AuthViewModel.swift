//
//  AuthViewModel.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//

import Foundation

class AuthViewModel {

    func register(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else { return false }
        // Guardamos la cuenta en el Keychain
        return KeychainManager.save(email: email, password: password)
    }

    func login(email: String, password: String) -> Bool {
        // 1. Buscamos si existe una contraseña guardada para este email
        guard let storedPassword = KeychainManager.getPassword(for: email) else {
            return false // El usuario no existe o el email está mal
        }
        
        // 2. Verificamos que la contraseña coincida
        if storedPassword == password {
            // 3. ¡Éxito! Guardamos que este usuario es el que está conectado ahora
            KeychainManager.saveCurrentSession(email: email)
            return true
        }
        
        return false // Contraseña incorrecta
    }
}
