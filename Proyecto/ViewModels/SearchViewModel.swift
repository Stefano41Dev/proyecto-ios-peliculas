//
//  SearchViewModel.swift
//  Proyecto
//
//  Created by DESIGN on 17/12/25.
//

import Foundation

class SearchViewModel {
    
    var movies: [Movie] = []
    var searchHistory: [String] = []
    var genres: [Genre] = []
    var onResultsUpdated: (() -> Void)?
    
    private var searchTimer: Timer?
    private let historyKey = "user_search_history"
    
    init() {
        loadHistory()
    }
    
    func loadGenres(completion: @escaping () -> Void) {
            APIManager.shared.fetchGenres { [weak self] genres, _ in
                self?.genres = genres ?? []
                completion()
            }
    }
    func searchByGenre(id: Int) {
            APIManager.shared.fetchMoviesByGenre(genreId: id) { [weak self] movies, _ in
                self?.movies = movies ?? []
                DispatchQueue.main.async {
                    self?.onResultsUpdated?()
                }
            }
        }
    // Búsqueda en tiempo real con debounce
    func search(query: String) {
        searchTimer?.invalidate()
        
        // Si borra el texto, mostramos historial
        if query.isEmpty {
            movies = []
            onResultsUpdated?()
            return
        }
        
        // Esperamos 0.5 segs antes de llamar a la API para no saturar
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.performSearch(query: query)
        }
    }
    
    private func performSearch(query: String) {
        APIManager.shared.searchMovies(query: query) { [weak self] results, error in
            guard let self = self else { return }
            if let results = results {
                self.movies = results
                DispatchQueue.main.async {
                    self.onResultsUpdated?()
                }
            }
        }
    }
    
    // MARK: - Gestión de Historial
    func loadHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: historyKey) ?? []
    }
    
    func addToHistory(query: String) {
        guard !query.isEmpty else { return }
        // Evitar duplicados y mantener solo los últimos 10
        if let index = searchHistory.firstIndex(of: query) {
            searchHistory.remove(at: index)
        }
        searchHistory.insert(query, at: 0)
        if searchHistory.count > 10 { searchHistory.removeLast() }
        
        UserDefaults.standard.set(searchHistory, forKey: historyKey)
        loadHistory() // Refrescar lista
    }
    
    func clearHistory() {
        searchHistory = []
        UserDefaults.standard.removeObject(forKey: historyKey)
        onResultsUpdated?()
    }
}
