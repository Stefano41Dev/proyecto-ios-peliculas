//
//  KeychainManager.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//

import Foundation
import Security

class KeychainManager {

    // MARK: - Gestión de Credenciales (Base de Datos Segura)
    
    // Guarda una nueva cuenta (o actualiza contraseña si el email ya existe)
    static func save(email: String, password: String) -> Bool {
        let passwordData = password.data(using: .utf8)!

        // Usamos el propio 'email' como la clave única (kSecAttrAccount)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecValueData as String: passwordData
        ]

        // 1. Intentamos borrar por si ya existe (update)
        SecItemDelete(query as CFDictionary)
        
        // 2. Guardamos la nueva entrada
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // Obtiene la contraseña específica para un email dado
    static func getPassword(for email: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // (Opcional) Borrar una cuenta específica del Keychain permanentemente
    static func deleteAccount(email: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Gestión de Sesión Activa (Quién está logueado)
    
    // Guarda quién es el usuario actual para que el Perfil sepa qué mostrar
    static func saveCurrentSession(email: String) {
        UserDefaults.standard.set(email, forKey: "current_active_user")
    }
    
    // Recupera el email del usuario que está usando la app
    static func getCurrentUser() -> String? {
        return UserDefaults.standard.string(forKey: "current_active_user")
    }
    
    // Cierra sesión (Solo olvida quién está activo, NO borra la cuenta del Keychain)
    static func clearCurrentSession() {
        UserDefaults.standard.removeObject(forKey: "current_active_user")
    }
}


