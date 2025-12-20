//
//  MoodMatcherViewController.swift
//  Proyecto
//
//  Created by DESIGN on 20/12/25.
//

import UIKit

class MoodMatcherViewController: UIViewController {

    // MARK: - Lógica de  (Estados de Ánimo)
    // Mapeamos emociones humanas a IDs técnicos de TMDB
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
        
        // IDs de Géneros TMDB
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
    private let apiManager = APIManager.shared
    private var allMovies: [Movie] = []
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "¿Cómo te sientes hoy?"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Selecciona una emoción y la IA encontrará tu película ideal."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // StackView para los botones
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Indicador de carga
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    // Texto de "Pensando..."
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Analizando tus emociones..."
        label.font = .italicSystemFont(ofSize: 16)
        label.textColor = .white
        label.alpha = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        preloadMovies()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(buttonsStack)
        view.addSubview(activityIndicator)
        view.addSubview(loadingLabel)
        
        // Crear botones dinámicamente
        for mood in Mood.allCases {
            let button = createMoodButton(for: mood)
            buttonsStack.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            buttonsStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            buttonsStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // Diseño del Botón (Estilo Tarjeta Moderna)
    private func createMoodButton(for mood: Mood) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = mood.color.withAlphaComponent(0.2) // Fondo suave
        config.baseForegroundColor = mood.color // Texto brillante
        
        config.title = "\(mood.emoji)  \(mood.rawValue)"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            return outgoing
        }
        
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let button = UIButton(configuration: config)
        button.layer.borderColor = mood.color.cgColor
        button.layer.borderWidth = 1
        button.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        // Acción
        let action = UIAction { [weak self] _ in
            self?.handleMoodSelection(mood)
        }
        button.addAction(action, for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Lógica
    
    private func preloadMovies() {
            let group = DispatchGroup()
            var tempMovies: [Movie] = []
            
            // ESTRATEGIA:
            // 1. Traemos 3 páginas de "Top Rated" (Clásicos y variedad de años)
            // 2. Traemos 1 página de "Popular" (Estrenos recientes)
            // Total: ~80 películas para elegir
            
            let endpoints: [(endpoint: MovieEndpoint, page: Int)] = [
                (.topRated, 1),
                (.topRated, 2),
                (.topRated, 3),
                (.popular, 1)
            ]
            
            for request in endpoints {
                group.enter()
                apiManager.fetchMovies(endpoint: request.endpoint, page: request.page) { movies, _ in
                    if let movies = movies {
                        tempMovies.append(contentsOf: movies)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                // Eliminamos duplicados por si una película está en ambas listas
                // (Usamos un diccionario para filtrar por ID único)
                let uniqueMovies = Dictionary(grouping: tempMovies, by: { $0.id })
                    .compactMap { $0.value.first }
                
                self?.allMovies = uniqueMovies
                print("🎬 IA Lista: Se cargaron \(uniqueMovies.count) películas de diferentes años.")
            }
        }
    
    private func handleMoodSelection(_ mood: Mood) {
        guard !allMovies.isEmpty else {
            print("⏳ Esperando datos de películas...")
            return
        }
        
        // 1. Efecto visual "Pensando"
        buttonsStack.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.buttonsStack.alpha = 0.2
            self.loadingLabel.alpha = 1.0
        }
        activityIndicator.startAnimating()
        
        // 2. Simular retraso de "IA" (1.5 segundos)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.processRecommendation(for: mood)
        }
    }
    
    private func processRecommendation(for mood: Mood) {
        // Restaurar UI
        activityIndicator.stopAnimating()
        loadingLabel.alpha = 0
        buttonsStack.alpha = 1.0
        buttonsStack.isUserInteractionEnabled = true
        
        // 3. Filtrar Películas
        // Buscamos películas que contengan AL MENOS UNO de los géneros del mood
        let targetGenreIds = Set(mood.genreIds)
        
        let matchingMovies = allMovies.filter { movie in
            // IMPORTANTE: Asegúrate de que tu modelo Movie usa 'genreIds' o 'genre_ids'
            guard let genres = movie.genreIds else { return false }
            let movieGenres = Set(genres)
            return !movieGenres.intersection(targetGenreIds).isEmpty
        }
        
        // 4. Elegir una ganadora
        if let winner = matchingMovies.randomElement() ?? allMovies.randomElement() {
            showResult(movie: winner, mood: mood)
        }
    }
    
    private func showResult(movie: Movie, mood: Mood) {
        let alert = UIAlertController(title: "Para un mood \(mood.rawValue)...",
                                      message: "Te recomendamos ver:\n\n🎬 \(movie.title)\n\n\(movie.overview)",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Ver Detalles", style: .default, handler: { _ in
            if let movieID = movie.id {
                let detailVC = MovieDetailViewController(movieID: movieID)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
}
