

import Foundation

class APIManager {
    
    static let shared = APIManager()
    private let apiKey = "f930fa213d5cf22cd62dd1c0df2e303e"
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
