//
//  MoodMatcherViewModel.swift
//  Proyecto
//
//  Created by DESIGN on 20/12/25.
//

import Foundation
import UIKit 

class MoodMatcherViewModel {
    
    // MARK: - Definición de Mood (Lógica de Datos)
    enum Mood: String, CaseIterable {
        case happy = "Feliz"
        case sad = "Melancólico"
        case intense = "Intenso"
        case chill = "Relajado"
        
        var emoji: String {
            switch self {
            case .happy: return "😄"
            case .sad: return "😢"
            case .intense: return "😱"
            case .chill: return "😎"
            }
        }
        
        var color: UIColor {
            switch self {
            case .happy: return .systemYellow
            case .sad: return .systemBlue
            case .intense: return .systemRed
            case .chill: return .systemTeal
            }
        }
        
        var genreIds: [Int] {
            switch self {
            case .happy: return [35, 10751, 16] // Comedia, Familia, Animación
            case .sad: return [18, 10749]       // Drama, Romance
            case .intense: return [28, 27, 53]  // Acción, Terror, Thriller
            case .chill: return [12, 14, 878]   // Aventura, Fantasía, Sci-Fi
            }
        }
    }
    
    // MARK: - Propiedades
    private let repository = MovieRepository()
    private var allMovies: [Movie] = []
    
    // Lista pública de moods para la vista
    var availableMoods: [Mood] {
        return Mood.allCases
    }
    
    // MARK: - Bindings (Comunicación con la Vista)
    var onDataLoaded: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)? // True = Pensando, False = Listo
    var onRecommendationFound: ((Movie, Mood) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Lógica de Negocio
    
    func loadData() {
        let group = DispatchGroup()
        var tempMovies: [Movie] = []
        
        // Estrategia de Carga Mixta (Top Rated + Popular)
        let requests: [(endpoint: MovieEndpoint, page: Int)] = [
            (.topRated, 1),
            (.topRated, 2),
            (.topRated, 3),
            (.popular, 1)
        ]
        
        for req in requests {
            group.enter()
            repository.getMoviesList(by: req.endpoint, page: req.page) { [weak self] movies, error in
                if let movies = movies {
                    tempMovies.append(contentsOf: movies)
                } else if let error = error {
                    self?.onError?(error.localizedDescription)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            // Eliminar duplicados
            let uniqueMovies = Dictionary(grouping: tempMovies, by: { $0.id })
                .compactMap { $0.value.first }
            
            self.allMovies = uniqueMovies
            self.onDataLoaded?()
            print("🎬 MoodMatcher: Cargadas \(uniqueMovies.count) películas.")
        }
    }
    
    func selectMood(_ mood: Mood) {
        guard !allMovies.isEmpty else {
            // Si el usuario toca muy rápido antes de cargar
            onError?("⏳ Esperando datos de películas...")
            return
        }
        
        // 1. Notificar a la vista que empiece la animación de carga
        onLoadingStateChanged?(true)
        
        // 2. Simular "Pensamiento de IA" (Delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.processRecommendation(for: mood)
        }
    }
    
    private func processRecommendation(for mood: Mood) {
        // Detener animación de carga
        onLoadingStateChanged?(false)
        
        // 3. Filtrar Películas
        let targetGenreIds = Set(mood.genreIds)
        
        let matchingMovies = allMovies.filter { movie in
            guard let genres = movie.genreIds else { return false }
            let movieGenres = Set(genres)
            return !movieGenres.intersection(targetGenreIds).isEmpty
        }
        
        // 4. Elegir Ganador y Notificar
        if let winner = matchingMovies.randomElement() ?? allMovies.randomElement() {
            onRecommendationFound?(winner, mood)
        }
    }
}
