//
//  QuizViewController.swift
//  Proyecto
//
//  Created by DESIGN on 20/12/25.
//

import UIKit

class QuizViewController: UIViewController {
    
    
    // MARK: - Propiedades
    private let repository = MovieRepository()
    private var allMovies: [Movie] = []
    private var filteredMovies: [Movie] = []
    
    private var currentQuestionIndex = 0
    private var questions: [Question] = []
    
    // MARK: - UI Elements
    
    private let progressBar: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .bar)
        pv.trackTintColor = .darkGray
        pv.progressTintColor = .systemRed
        pv.layer.cornerRadius = 2
        pv.clipsToBounds = true
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "¿Pregunta?"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Contenedor para la animación de carga final
    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .systemRed
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    private let analyzingLabel: UILabel = {
        let label = UILabel()
        label.text = "Buscando tu match perfecto..."
        label.font = .italicSystemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigation()
        setupUI()
        setupQuestions()
        preloadMovies() // Cargar datos
    }
    
    private func setupNavigation() {
        title = "Quiz Personalidad"
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - Configuración de Preguntas y Lógica
    
    private func setupQuestions() {
        // PREGUNTA 1: Tono (Ligero vs Intenso)
        // Usamos géneros como proxy
        let q1 = Question(
            text: "¿Qué busca tu cuerpo hoy?",
            optionA: QuizOption(title: "Risas y Aventura", emoji: "🤣", filter: { movie in
                let lightGenres = [35, 12, 16, 10751, 14] // Comedia, Aventura, Animación, Familia, Fantasía
                guard let genres = movie.genreIds else { return false }
                return !Set(genres).intersection(lightGenres).isEmpty
            }),
            optionB: QuizOption(title: "Tensión y Drama", emoji: "😰", filter: { movie in
                let heavyGenres = [18, 53, 27, 9648, 80] // Drama, Thriller, Terror, Misterio, Crimen
                guard let genres = movie.genreIds else { return false }
                return !Set(genres).intersection(heavyGenres).isEmpty
            })
        )
        
        // PREGUNTA 2: Realidad vs Ficción
        let q2 = Question(
            text: "¿En qué mundo prefieres estar?",
            optionA: QuizOption(title: "Mundo Real", emoji: "🌍", filter: { movie in
                let realGenres = [18, 36, 10749, 99, 80] // Drama, Historia, Romance, Documental, Crimen
                guard let genres = movie.genreIds else { return false }
                return !Set(genres).intersection(realGenres).isEmpty
            }),
            optionB: QuizOption(title: "Ciencia Ficción / Fantasía", emoji: "🚀", filter: { movie in
                let fantasyGenres = [878, 14, 28, 27, 12] // Sci-Fi, Fantasía, Acción, Terror, Aventura
                guard let genres = movie.genreIds else { return false }
                return !Set(genres).intersection(fantasyGenres).isEmpty
            })
        )
        
        // PREGUNTA 3: Época (Antiguas vs Nuevas)
        // Usamos '2015' como punto de corte
        let q3 = Question(
            text: "¿Qué estilo prefieres?",
            optionA: QuizOption(title: "Cine Moderno", emoji: "📱", filter: { movie in
                guard let date = movie.releaseDate else { return true } // Si no hay fecha, asumimos moderna
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
        showQuestion(at: 0)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(progressBar)
        view.addSubview(questionLabel)
        view.addSubview(stackView)
        
        // Pantalla de carga (oculta al inicio)
        view.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(analyzingLabel)
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressBar.heightAnchor.constraint(equalToConstant: 6),
            
            questionLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 40),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackView.heightAnchor.constraint(equalToConstant: 180), // Altura para 2 botones
            
            // Constraints Loading View
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -20),
            
            analyzingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
            analyzingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor)
        ])
    }
    
    // MARK: - Lógica de Juego
    
    private func showQuestion(at index: Int) {
        guard index < questions.count else {
            finishQuiz()
            return
        }
        
        let question = questions[index]
        
        // Animación de cambio de texto
        UIView.transition(with: questionLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.questionLabel.text = question.text
        }, completion: nil)
        
        // Actualizar progreso
        let progress = Float(index) / Float(questions.count)
        progressBar.setProgress(progress, animated: true)
        
        // Limpiar botones anteriores
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Crear nuevos botones
        let btnA = createOptionButton(option: question.optionA, tag: 0)
        let btnB = createOptionButton(option: question.optionB, tag: 1)
        
        stackView.addArrangedSubview(btnA)
        stackView.addArrangedSubview(btnB)
        
        // Animación de entrada de botones
        stackView.alpha = 0
        stackView.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.stackView.alpha = 1
            self.stackView.transform = .identity
        }, completion: nil)
    }
    
    private func handleAnswer(optionIndex: Int) {
        let question = questions[currentQuestionIndex]
        let selectedOption = (optionIndex == 0) ? question.optionA : question.optionB
        
        // 1. Filtrar lista actual
        // Si es la primera pregunta, filtramos sobre 'allMovies'. Si no, sobre 'filteredMovies'
        let sourceList = (currentQuestionIndex == 0) ? allMovies : filteredMovies
        let newFiltered = sourceList.filter(selectedOption.filter)
        
        // Si el filtro nos deja sin películas, somos permisivos y mantenemos la lista anterior para no romper el juego
        if !newFiltered.isEmpty {
            filteredMovies = newFiltered
        } else {
            print("⚠️ El filtro fue muy estricto, manteniendo opciones anteriores.")
        }
        
        // 2. Avanzar
        currentQuestionIndex += 1
        showQuestion(at: currentQuestionIndex)
    }
    
    private func finishQuiz() {
        progressBar.setProgress(1.0, animated: true)
        
        // Mostrar Loading
        loadingView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        activityIndicator.startAnimating()
        
        // Simular pensamiento (2 seg)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showResult()
        }
    }
    
    private func showResult() {
        activityIndicator.stopAnimating()
        loadingView.alpha = 0
        
        // Elegir ganadora
        let winner = filteredMovies.randomElement() ?? allMovies.randomElement()
        
        guard let movie = winner, let movieID = movie.id else { return }
        
        // Navegar directo al detalle (Experiencia fluida)
        // O mostrar alerta si prefieres. Aquí voy directo al detalle como "Resultado Mágico"
        let detailVC = MovieDetailViewController(movieID: movieID)
        
        // Reemplazar la pila de navegación para que al volver atrás vaya al menú de IA, no al Quiz vacío
        var navigationStack = navigationController?.viewControllers ?? []
        navigationStack.removeLast() // Quitamos el QuizVC
        navigationStack.append(detailVC) // Ponemos el Detalle
        navigationController?.setViewControllers(navigationStack, animated: true)
        
        // Mostrar un Toast o Alerta pequeña encima del detalle sería ideal, pero esto funciona bien.
    }
    
    // MARK: - Helper UI
    
    private func createOptionButton(option: QuizOption, tag: Int) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .darkGray
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        
        // Título con emoji grande
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        let attributedTitle = NSAttributedString(string: "\(option.emoji)  \(option.title)", attributes: titleAttributes)
        config.attributedTitle = AttributedString(attributedTitle)
        
        let button = UIButton(configuration: config)
        button.tag = tag
        button.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.handleAnswer(optionIndex: tag)
        }), for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Carga de Datos (Mix Popular + TopRated)
    
    private func preloadMovies() {
            let group = DispatchGroup()
            var tempMovies: [Movie] = []
            
            // REFACTOR: Usamos MovieEndpoint que ya está definido en tu proyecto
            let requests: [(endpoint: MovieEndpoint, page: Int)] = [
                (.popular, 1),
                (.topRated, 1),
                (.topRated, 2)
            ]
            
            for req in requests {
                group.enter()
                // Llamada al repositorio
                repository.getMoviesList(by: req.endpoint, page: req.page) { movies, _ in
                    if let movies = movies {
                        tempMovies.append(contentsOf: movies)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                let uniqueMovies = Dictionary(grouping: tempMovies, by: { $0.id })
                    .compactMap { $0.value.first }
                self?.allMovies = uniqueMovies
                print("🧠 Quiz listo con \(uniqueMovies.count) películas (vía Repository).")
            }
    }
}
