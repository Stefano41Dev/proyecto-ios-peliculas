

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
    // Obtener detalles completos de una película (Info, Reparto, Trailers)
        func fetchMovieDetails(movieID: Int, completion: @escaping (Movie?, Error?) -> Void) {
            // 'append_to_response' permite traer los créditos y videos en la misma respuesta del detalle
            let urlString = "\(baseURL)/movie/\(movieID)?api_key=\(apiKey)&language=es&append_to_response=credits,videos"
            
            guard let url = URL(string: urlString) else { return }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Error en fetchMovieDetails: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                guard let data = data else {
                    completion(nil, nil)
                    return
                }
                
                do {
                    let movieDetail = try JSONDecoder().decode(Movie.self, from: data)
                    completion(movieDetail, nil)
                } catch {
                    print("Error decoding movie details: \(error)")
                    completion(nil, error)
                }
            }
            task.resume()
        }
    func fetchMovies(endpoint: MovieEndpoint, completion: @escaping ([Movie]?, Error?) -> Void) {
            let urlString = "\(baseURL)/movie/\(endpoint.rawValue)?api_key=\(apiKey)&language=es-ES"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error { completion(nil, error); return }
                guard let data = data else { completion(nil, nil); return }
                
                do {
                    let response = try JSONDecoder().decode(MovieResponse.self, from: data)
                    completion(response.results, nil)
                } catch {
                    completion(nil, error)
                }
            }.resume()
        }
    func searchMovies(query: String, completion: @escaping ([Movie]?, Error?) -> Void) {
            // Reemplazar espacios por %20 para la URL
            guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            
            let urlString = "\(baseURL)/search/movie?api_key=\(apiKey)&language=es-ES&query=\(encodedQuery)&page=1&include_adult=false"
            
            guard let url = URL(string: urlString) else { return }
            
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let data = data else { return }
                
                do {
                    let response = try JSONDecoder().decode(MovieResponse.self, from: data)
                    completion(response.results, nil)
                } catch {
                    completion(nil, error)
                }
            }
            task.resume()
        }
    
    
    
}
