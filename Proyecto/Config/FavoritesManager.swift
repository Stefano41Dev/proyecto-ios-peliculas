//
//  FavoritesManager.swift
//  Proyecto
//
//  Created by DESIGN on 17/12/25.
//

import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    private let userDefaults = UserDefaults.standard
    
    // Genera una clave única basada en el email del usuario que tiene la sesión activa.
    // Si Juan entra, la clave será "favorites_juan@test.com".
    private var currentUserKey: String? {
        // Usamos el método que creamos para obtener el usuario de la sesión actual
        guard let email = KeychainManager.getCurrentUser() else { return nil }
        return "favorites_\(email)"
    }
    
    // Verifica si una película ya está en favoritos
    func isFavorite(movieID: Int) -> Bool {
        guard let key = currentUserKey else { return false }
        let favorites = getFavoritesIDs(key: key)
        return favorites.contains(movieID)
    }
    
    // Agrega o quita una película de favoritos
    func toggleFavorite(movie: Movie) {
        guard let key = currentUserKey, let id = movie.id else { return }
        
        var favorites = getFavoritesIDs(key: key)
        var savedMovies = getSavedMovies(key: key)
        
        if favorites.contains(id) {
            // Si ya existe, la borramos
            favorites.removeAll { $0 == id }
            savedMovies.removeAll { $0.id == id }
        } else {
            // Si no existe, la agregamos
            favorites.append(id)
            savedMovies.append(movie)
        }
        
        // Guardamos los IDs (para búsqueda rápida)
        userDefaults.set(favorites, forKey: key + "_ids")
        
        // Guardamos los objetos Movie completos (para mostrar la lista sin llamar a la API)
        if let encoded = try? JSONEncoder().encode(savedMovies) {
            userDefaults.set(encoded, forKey: key + "_objects")
        }
        
        // Notificamos a toda la app que los favoritos cambiaron (para actualizar vistas)
        NotificationCenter.default.post(name: NSNotification.Name("FavoritesChanged"), object: nil)
    }
    
    // Devuelve la lista completa de objetos Movie guardados
    func getAllFavorites() -> [Movie] {
        guard let key = currentUserKey else { return [] }
        return getSavedMovies(key: key)
    }
    
    // MARK: - Helpers Privados
    
    private func getFavoritesIDs(key: String) -> [Int] {
        return userDefaults.array(forKey: key + "_ids") as? [Int] ?? []
    }
    
    private func getSavedMovies(key: String) -> [Movie] {
        guard let data = userDefaults.data(forKey: key + "_objects"),
              let movies = try? JSONDecoder().decode([Movie].self, from: data) else {
            return []
        }
        return movies
    }
}
