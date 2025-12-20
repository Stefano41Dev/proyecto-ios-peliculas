//
//  MoodMatcherViewController.swift
//  Proyecto
//
//  Created by DESIGN on 20/12/25.
//

import UIKit

class MoodMatcherViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel = MoodMatcherViewModel()
    
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
        label.text = "Selecciona una emoción para encontrar tu película ideal."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
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
        bindViewModel()
        viewModel.loadData()
    }
    
    // MARK: - Binding (Conexión con ViewModel)
    
    private func bindViewModel() {
        
        // Reaccionar a cambios de estado de carga ("Pensando...")
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            self?.updateLoadingState(isLoading: isLoading)
        }
        
        // Reaccionar cuando se encuentra una recomendación
        viewModel.onRecommendationFound = { [weak self] movie, mood in
            self?.showResult(movie: movie, mood: mood)
        }
        
        // Reaccionar a errores
        viewModel.onError = { errorMsg in
            print("Error/Info: \(errorMsg)")
        }
    }
    
    // MARK: - UI Logic
    
    private func updateLoadingState(isLoading: Bool) {
        if isLoading {
            buttonsStack.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.3) {
                self.buttonsStack.alpha = 0.2
                self.loadingLabel.alpha = 1.0
            }
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            loadingLabel.alpha = 0
            buttonsStack.alpha = 1.0
            buttonsStack.isUserInteractionEnabled = true
        }
    }
    
    private func showResult(movie: Movie, mood: MoodMatcherViewModel.Mood) {
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
    
    // MARK: - Setup UI Elements
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(buttonsStack)
        view.addSubview(activityIndicator)
        view.addSubview(loadingLabel)
        
        // Crear botones usando los datos del ViewModel
        for mood in viewModel.availableMoods {
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
    
    private func createMoodButton(for mood: MoodMatcherViewModel.Mood) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = mood.color.withAlphaComponent(0.2)
        config.baseForegroundColor = mood.color
        
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
        
        // Acción conecta directamente al ViewModel
        let action = UIAction { [weak self] _ in
            self?.viewModel.selectMood(mood)
        }
        button.addAction(action, for: .touchUpInside)
        
        return button
    }
}
