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
        return KeychainManager.save(email: email, password: password)
    }

    func login(email: String, password: String) -> Bool {
        let creds = KeychainManager.getCredentials()
        return email == creds.email && password == creds.password
    }
}
