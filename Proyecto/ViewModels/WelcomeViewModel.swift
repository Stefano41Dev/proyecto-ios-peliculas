import Foundation

class WelcomeViewModel {
    
    private let apiManager = APIManager.shared
        
        // Diccionario para guardar las películas por sección
        var moviesBySection: [MovieSection: [Movie]] = [:]
        
        // Orden de las secciones para la vista
        let sections = MovieSection.allCases
        
        var onDataUpdated: (() -> Void)?
        var onError: ((String) -> Void)?
        
        func fetchAllCategories() {
            let group = DispatchGroup()
            
            // 1. En Cartelera
            group.enter()
            apiManager.fetchMovies(endpoint: .nowPlaying) { [weak self] movies, _ in
                self?.moviesBySection[.nowPlaying] = movies
                group.leave()
            }
            
            // 2. Populares
            group.enter()
            apiManager.fetchMovies(endpoint: .popular) { [weak self] movies, _ in
                self?.moviesBySection[.popular] = movies
                group.leave()
            }
            
            // 3. Top Rated
            group.enter()
            apiManager.fetchMovies(endpoint: .topRated) { [weak self] movies, _ in
                self?.moviesBySection[.topRated] = movies
                group.leave()
            }
            
            // 4. Upcoming
            group.enter()
            apiManager.fetchMovies(endpoint: .upcoming) { [weak self] movies, _ in
                self?.moviesBySection[.upcoming] = movies
                group.leave()
            }
            
            // Cuando todas terminen
            group.notify(queue: .main) { [weak self] in
                self?.onDataUpdated?()
            }
        }
        
        // Helper para obtener película específica
        func movie(at indexPath: IndexPath) -> Movie? {
            let sectionType = sections[indexPath.section]
            return moviesBySection[sectionType]?[indexPath.row]
        }
}
