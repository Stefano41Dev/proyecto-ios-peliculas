//
//  QuizViewController.swift
//  Proyecto
//
//  Created by DESIGN on 20/12/25.
//

import UIKit

class QuizViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = QuizViewModel()
    
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
        label.text = "Cargando..."
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
    
    // Loading View Elements
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
        bindViewModel()
        
        // Iniciar carga de datos
        questionLabel.text = "Preparando Quiz..."
        viewModel.loadData()
    }
    
    private func setupNavigation() {
        title = "Quiz Personalidad"
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        
        // 1. Datos listos para empezar
        viewModel.onDataLoaded = { [weak self] in
            self?.updateUI()
        }
        
        // 2. Cambio de pregunta
        viewModel.onQuestionChanged = { [weak self] in
            self?.updateUI()
        }
        
        // 3. Quiz terminado
        viewModel.onQuizFinished = { [weak self] in
            self?.finishQuizAnimation()
        }
        
        viewModel.onError = { error in
            print("Error en quiz: \(error)")
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        guard let question = viewModel.getCurrentQuestion() else { return }
        
        // Animación Texto
        UIView.transition(with: questionLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.questionLabel.text = question.text
        }, completion: nil)
        
        // Actualizar Barra
        progressBar.setProgress(viewModel.getProgress(), animated: true)
        
        // Actualizar Botones
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let btnA = createOptionButton(option: question.optionA, tag: 0)
        let btnB = createOptionButton(option: question.optionB, tag: 1)
        
        stackView.addArrangedSubview(btnA)
        stackView.addArrangedSubview(btnB)
        
        // Animación Entrada
        stackView.alpha = 0
        stackView.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.stackView.alpha = 1
            self.stackView.transform = .identity
        }, completion: nil)
    }
    
    private func finishQuizAnimation() {
        progressBar.setProgress(1.0, animated: true)
        
        // Mostrar Loading
        loadingView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        activityIndicator.startAnimating()
        
        // Simular pensamiento y navegar
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.navigateToResult()
        }
    }
    
    private func navigateToResult() {
        activityIndicator.stopAnimating()
        loadingView.alpha = 0
        
        guard let movie = viewModel.getResultMovie(), let movieID = movie.id else { return }
        
        let detailVC = MovieDetailViewController(movieID: movieID)
        
        var navigationStack = navigationController?.viewControllers ?? []
        navigationStack.removeLast() // Sacamos QuizVC
        navigationStack.append(detailVC) // Metemos DetalleVC
        navigationController?.setViewControllers(navigationStack, animated: true)
    }
    
    // MARK: - Setup UI Constraints (Sin cambios, solo copia y pega lo visual)
    
    private func setupUI() {
        view.addSubview(progressBar)
        view.addSubview(questionLabel)
        view.addSubview(stackView)
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
            stackView.heightAnchor.constraint(equalToConstant: 180),
            
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
    
    private func createOptionButton(option: QuizOption, tag: Int) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .darkGray
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        let attributedTitle = NSAttributedString(string: "\(option.emoji)  \(option.title)", attributes: titleAttributes)
        config.attributedTitle = AttributedString(attributedTitle)
        
        let button = UIButton(configuration: config)
        button.tag = tag
        button.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        // ACCIÓN: Llamar al ViewModel
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.submitAnswer(optionIndex: tag)
        }), for: .touchUpInside)
        
        return button
    }
}
