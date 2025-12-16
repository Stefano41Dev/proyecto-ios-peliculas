//
//  ApiManager.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    private let apiKey = "f930fa213d5cf22cd62dd1c0df2e303e" // Aquí pega tu clave API de TMDb
    private let baseURL = "https://api.themoviedb.org/3"
    
    // Función para obtener películas populares
    func fetchMovies(page: Int = 1, completion: @escaping ([Movie]?, Error?) -> Void) {
        let urlString = "\(baseURL)/movie/popular?api_key=\(apiKey)&page=\(page)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(result.results, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}

// Modelo de la respuesta de la API
struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let title: String
    let posterPath: String?
    let overview: String
}

