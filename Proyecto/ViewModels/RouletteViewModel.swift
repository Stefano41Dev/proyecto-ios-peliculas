//
//  RouletteViewModel.swift
//  Proyecto
//
//  Created by DESIGN on 20/12/25.
//


import Foundation

class RouletteViewModel {
    
    // MARK: - Propiedades
    private let repository = MovieRepository()
    private var candidateMovies: [Movie] = []
    
    // Frases místicas (Datos estáticos)
    private let mysticalPhrases = [
        "Consultando a los astros...",
        "Analizando el destino...",
        "Las estrellas se alinean...",
        "Buscando tu película ideal...",
        "El oráculo está decidiendo..."
    ]
    
    // MARK: - Bindings (Comunicación)
    var onDataLoaded: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Lógica de Datos
    
    func loadData() {
        // Usamos el repositorio con endpoint .topRated para asegurar calidad
        repository.getMoviesList(by: .topRated, page: 1) { [weak self] movies, error in
            guard let self = self else { return }
            
            if let movies = movies {
                self.candidateMovies = movies
                self.onDataLoaded?()
                print("🔮 Roulette: Datos cargados (\(movies.count) películas).")
            } else if let error = error {
                self.onError?(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Lógica del Juego
    
    /// Verifica si ya tenemos datos para jugar
    var isDataReady: Bool {
        return !candidateMovies.isEmpty
    }
    
    /// Devuelve una frase aleatoria para la animación
    func getRandomPhrase() -> String {
        return mysticalPhrases.randomElement() ?? "Pensando..."
    }
    
    /// Elige la película ganadora
    func getWinner() -> Movie? {
        return candidateMovies.randomElement()
    }
}
