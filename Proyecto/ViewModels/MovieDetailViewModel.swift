//
//  MovieDetailViewModel.swift
//  Proyecto
//
//  Created by Gemini on 17/12/25.
//

import Foundation

class MovieDetailViewModel {
    
    private let apiManager = APIManager.shared
    private var movieID: Int
    
    // Datos listos para la vista
    var movie: Movie?
    var cast: [Cast] = []
    var trailers: [Trailer] = []
    
    // Closures para notificar a la vista (Binding)
    var onDataLoaded: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(movieID: Int) {
        self.movieID = movieID
    }
    
    func loadDetails() {
        // Usamos el método que combina detalles, créditos y videos
        apiManager.fetchMovieDetails(movieID: movieID) { [weak self] movieResponse, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
                return
            }
            
            guard let movie = movieResponse else {
                DispatchQueue.main.async {
                    self.onError?("No se encontraron detalles.")
                }
                return
            }
            
            self.movie = movie
            // Extraemos el reparto y trailers de la respuesta anidada
            self.cast = movie.credits?.cast ?? []
            self.trailers = movie.videos?.results ?? []
            
            DispatchQueue.main.async {
                self.onDataLoaded?()
            }
        }
    }
    
    // Helpers para formatear datos
    var backdropURL: URL? {
        return movie?.backdropURL
    }
    
    var title: String {
        return movie?.title ?? ""
    }
    
    var overview: String {
        return movie?.overview ?? "Sin descripción disponible."
    }
    
    var infoText: String {
        // Ej: "2024 • 120 min • 8.5 ★"
        var parts: [String] = []
        if let date = movie?.releaseDate?.prefix(4) { parts.append(String(date)) }
        if let runtime = movie?.runtime { parts.append("\(runtime) min") }
        if let rating = movie?.voteAverage { parts.append(String(format: "%.1f ★", rating)) }
        return parts.joined(separator: " • ")
    }
}
