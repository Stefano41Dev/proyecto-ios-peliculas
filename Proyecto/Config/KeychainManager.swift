//
//  KeychainManager.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//

import Foundation
import Security

class KeychainManager {

    static func save(email: String, password: String) -> Bool {
        let emailData = email.data(using: .utf8)!
        let passwordData = password.data(using: .utf8)!

        // Guardar email
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userEmail",
            kSecValueData as String: emailData
        ]
        SecItemDelete(emailQuery as CFDictionary)
        let emailStatus = SecItemAdd(emailQuery as CFDictionary, nil)

        // Guardar contraseña
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userPassword",
            kSecValueData as String: passwordData
        ]
        SecItemDelete(passwordQuery as CFDictionary)
        let passwordStatus = SecItemAdd(passwordQuery as CFDictionary, nil)

        return emailStatus == errSecSuccess && passwordStatus == errSecSuccess
    }

    static func getCredentials() -> (email: String?, password: String?) {
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userEmail",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var emailResult: AnyObject?
        SecItemCopyMatching(emailQuery as CFDictionary, &emailResult)
        let email = (emailResult as? Data).flatMap { String(data: $0, encoding: .utf8) }

        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userPassword",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var passwordResult: AnyObject?
        SecItemCopyMatching(passwordQuery as CFDictionary, &passwordResult)
        let password = (passwordResult as? Data).flatMap { String(data: $0, encoding: .utf8) }

        return (email, password)
    }

    static func clearCredentials() {
        let emailQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: "userEmail"]
        SecItemDelete(emailQuery as CFDictionary)

        let passwordQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: "userPassword"]
        SecItemDelete(passwordQuery as CFDictionary)
    }
}


