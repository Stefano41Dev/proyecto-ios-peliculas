//
//  AuthViewModel.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//

import Foundation

class AuthViewModel {

    func register(email: String, password: String) -> Bool {
        guard !email.isEmpty, password.count >= 6 else { return false }
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
    
    func changePassword(email: String, currentPass: String, newPass: String) -> Bool {
            // 1. Validar que la contraseña actual sea correcta
            guard let storedPassword = KeychainManager.getPassword(for: email),
                  storedPassword == currentPass else {
                return false
            }
            
            // 2. Guardar la nueva contraseña (sobrescribe la anterior para este email)
            return KeychainManager.save(email: email, password: newPass)
        }
    
    func changeEmail(currentEmail: String, currentPass: String, newEmail: String) -> Bool {
            // 1. Validar contraseña actual
            guard let storedPassword = KeychainManager.getPassword(for: currentEmail),
                  storedPassword == currentPass else {
                return false
            }
            
            // 2. Validar que el nuevo email no esté vacío
            guard !newEmail.isEmpty else { return false }
            
            // 3. Guardar el nuevo registro con la misma contraseña
            let saveSuccess = KeychainManager.save(email: newEmail, password: storedPassword)
            
            if saveSuccess {
                // 4. Actualizar la sesión activa al nuevo email
                KeychainManager.saveCurrentSession(email: newEmail)
                
                return true
            }
            
            return false
        }
}
