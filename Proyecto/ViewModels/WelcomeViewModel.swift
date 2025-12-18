import Foundation

class WelcomeViewModel {
    
    private let apiManager = APIManager.shared
        
        // Diccionario para guardar las películas por sección
        var moviesBySection: [MovieSection: [Movie]] = [:]
        
        var genres: [Genre] = []
        // Orden de las secciones para la vista
        let sections = MovieSection.allCases
        
        var selectedGenre: Genre?     // ¿Qué género está seleccionado?
        var filteredMovies: [Movie] = [] // Las películas de ese género
        var onDataUpdated: (() -> Void)?
        var onError: ((String) -> Void)?
        
        func fetchAllCategories() {
            let group = DispatchGroup()
            
            // 1. En Cartelera
            group.enter()
            apiManager.fetchGenres { [weak self] genres, _ in
                        self?.genres = genres ?? []
                        group.leave()
            }
            
            MovieSection.allCases.forEach { section in
                        group.enter()
                        // Asumiendo que tienes el endpoint mapeado en tu enum o manager
                        let endpoint: MovieEndpoint
                        switch section {
                        case .nowPlaying: endpoint = .nowPlaying
                        case .popular: endpoint = .popular
                        case .topRated: endpoint = .topRated
                        case .upcoming: endpoint = .upcoming
                        }
                        
                        apiManager.fetchMovies(endpoint: endpoint) { [weak self] movies, _ in
                            self?.moviesBySection[section] = movies
                            group.leave()
                }
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
    func selectGenre(_ genre: Genre) {
            // Si pulsamos el mismo que ya estaba, lo quitamos (toggle off)
            if selectedGenre?.id == genre.id {
                selectedGenre = nil
                filteredMovies = []
                onDataUpdated?()
                return
            }
            
            // Si es nuevo, lo seleccionamos y buscamos
            selectedGenre = genre
            filteredMovies = [] // Limpiar mientras carga
            onDataUpdated?()    // Actualizar UI para mostrar selección
            
            apiManager.fetchMoviesByGenre(genreId: genre.id) { [weak self] movies, error in
                if let movies = movies {
                    self?.filteredMovies = movies
                    DispatchQueue.main.async {
                        self?.onDataUpdated?()
                    }
                }
            }
        }
}
