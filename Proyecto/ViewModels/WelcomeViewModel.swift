import Foundation

class WelcomeViewModel {
    
    private let repository = MovieRepository()
    
    var topMovies: [Movie] = []
    
    // Callback para notificar cambios en la UI
    var onMoviesUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    func fetchTopMovies() {
        repository.getPopularMovies { [weak self] movies, error in
            guard let self = self else { return }
            
            if let movies = movies {
                self.topMovies = Array(movies.prefix(5))
                DispatchQueue.main.async {
                    self.onMoviesUpdated?()
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.onError?(error)
                }
            }
        }
    }
}
