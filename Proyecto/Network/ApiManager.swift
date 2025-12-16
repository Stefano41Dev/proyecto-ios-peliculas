// APIManager.swift

import Foundation

// MARK: - Modelos de Respuesta de la API (TMDb)

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let title: String
    let posterPath: String?
    let overview: String
    let id: Int?

    // 🌟 CLAVE: Mapeo y URL de la Imagen 🌟
    
    private enum CodingKeys: String, CodingKey {
        case title
        case posterPath = "poster_path" // Mapea 'poster_path' del JSON a 'posterPath' de Swift
        case overview
        case id
    }

    // Propiedad Calculada: URL COMPLETA del póster, lista para Kingfisher
    var posterURL: URL? {
        let imageBaseURL = "https://image.tmdb.org/t/p/w500"
        guard let path = posterPath else { return nil }
        
        return URL(string: imageBaseURL + path)
    }
}

struct TrailerResponse: Codable {
    let results: [Trailer]
}

struct Trailer: Codable {
    let key: String // YouTube key
    let name: String
    let site: String // YouTube
    let type: String // Trailer, Teaser
}

// MARK: - Clase APIManager

class APIManager {
    static let shared = APIManager()
    private let apiKey = "f930fa213d5cf22cd62dd1c0df2e303e" // Tu API Key
    private let baseURL = "https://api.themoviedb.org/3"
    
    // Función para obtener películas populares
    func fetchMovies(page: Int = 1, completion: @escaping ([Movie]?, Error?) -> Void) {
        let urlString = "\(baseURL)/movie/popular?api_key=\(apiKey)&page=\(page)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
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
    
    // Función para obtener trailers
    func fetchMovieTrailers(movieID: Int, completion: @escaping ([Trailer]?, Error?) -> Void) {
        let urlString = "\(baseURL)/movie/\(movieID)/videos?api_key=\(apiKey)&language=es"
        
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(TrailerResponse.self, from: data)
                completion(result.results, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
