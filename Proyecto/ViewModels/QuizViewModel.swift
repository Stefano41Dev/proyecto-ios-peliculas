//
//  QuizViewModel.swift
//  Proyecto
//
//  Created by DESIGN on 20/12/25.
//


import Foundation

class QuizViewModel {
    
    // MARK: - Propiedades
    private let repository = MovieRepository()
    
    // Estado de datos
    private var allMovies: [Movie] = []
    private var filteredMovies: [Movie] = []
    
    // Estado del juego
    private(set) var questions: [Question] = []
    private(set) var currentQuestionIndex = 0
    
    // MARK: - Bindings (Closures para notificar a la Vista)
    var onDataLoaded: (() -> Void)?
    var onQuestionChanged: (() -> Void)?
    var onQuizFinished: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Inicialización
    init() {
        setupQuestions()
    }
    
    // MARK: - Lógica de Negocio
    
    func loadData() {
        let group = DispatchGroup()
        var tempMovies: [Movie] = []
        
        let requests: [(endpoint: MovieEndpoint, page: Int)] = [
            (.popular, 1),
            (.topRated, 1),
            (.topRated, 2)
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
        }
    }
    
    func submitAnswer(optionIndex: Int) {
        guard currentQuestionIndex < questions.count else { return }
        
        let question = questions[currentQuestionIndex]
        let selectedOption = (optionIndex == 0) ? question.optionA : question.optionB
        
        // Lógica de Filtrado
        let sourceList = (currentQuestionIndex == 0) ? allMovies : filteredMovies
        let newFiltered = sourceList.filter(selectedOption.filter)
        
        if !newFiltered.isEmpty {
            filteredMovies = newFiltered
        } else {
            print("⚠️ Filtro estricto: Manteniendo opciones anteriores para evitar resultados vacíos.")
        }
        
        // Avanzar
        currentQuestionIndex += 1
        
        if currentQuestionIndex < questions.count {
            onQuestionChanged?()
        } else {
            onQuizFinished?()
        }
    }
    
    func getCurrentQuestion() -> Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    func getProgress() -> Float {
        return Float(currentQuestionIndex) / Float(questions.count)
    }
    
    func getResultMovie() -> Movie? {
        return filteredMovies.randomElement() ?? allMovies.randomElement()
    }
    
    // MARK: - Configuración de Preguntas
    private func setupQuestions() {
        // (Aquí va la misma lógica de creación de preguntas que tenías antes)
        let q1 = Question(
            text: "¿Qué busca tu cuerpo hoy?",
            optionA: QuizOption(title: "Risas y Aventura", emoji: "🤣", filter: { movie in
                let lightGenres = [35, 12, 16, 10751, 14]
                guard let genres = movie.genreIds else { return false }
                return !Set(genres).intersection(lightGenres).isEmpty
            }),
            optionB: QuizOption(title: "Tensión y Drama", emoji: "😰", filter: { movie in
                let heavyGenres = [18, 53, 27, 9648, 80]
                guard let genres = movie.genreIds else { return false }
                return !Set(genres).intersection(heavyGenres).isEmpty
            })
        )
        
        let q2 = Question(
            text: "¿En qué mundo prefieres estar?",
            optionA: QuizOption(title: "Mundo Real", emoji: "🌍", filter: { movie in
                let realGenres = [18, 36, 10749, 99, 80]
                guard let genres = movie.genreIds else { return false }
                return !Set(genres).intersection(realGenres).isEmpty
            }),
            optionB: QuizOption(title: "Ciencia Ficción / Fantasía", emoji: "🚀", filter: { movie in
                let fantasyGenres = [878, 14, 28, 27, 12]
                guard let genres = movie.genreIds else { return false }
                return !Set(genres).intersection(fantasyGenres).isEmpty
            })
        )
        
        let q3 = Question(
            text: "¿Qué estilo prefieres?",
            optionA: QuizOption(title: "Cine Moderno", emoji: "📱", filter: { movie in
                guard let date = movie.releaseDate else { return true }
                let year = Int(date.prefix(4)) ?? 2020
                return year >= 2015
            }),
            optionB: QuizOption(title: "Clásicos / Consagrados", emoji: "🎞️", filter: { movie in
                guard let date = movie.releaseDate else { return false }
                let year = Int(date.prefix(4)) ?? 2000
                return year < 2015
            })
        )
        
        questions = [q1, q2, q3]
    }
}
