//
//  AIViewController.swift
//  Proyecto
//
//  Created by DESIGN on 18/12/25.
//

import UIKit

class AIViewController: UIViewController {
    
    // MARK: - Propiedades
    
    private var userEmail: String {
        return KeychainManager.getCurrentUser() ?? "Cinéfilo"
    }
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.text = "Selecciona una de nuestras herramientas inteligentes para encontrar tu próxima película favorita."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        // Configurar texto de bienvenida
        titleLabel.text = "Hola,\n\(userEmail)"
        
        view.addSubview(titleLabel)
        view.addSubview(introLabel)
        view.addSubview(stackView)
        
        // Crear las 3 opciones
        let option1 = createOptionRow(title: "Mood Matcher",
                                      iconName: "face.smiling",
                                      desc: "Selecciona tu estado de ánimo y te recomendaremos la película perfecta.",
                                      action: #selector(goToMoodMatcher))
        
        let option2 = createOptionRow(title: "Cine-Roulette",
                                      iconName: "dice",
                                      desc: "Deja que el azar decida por ti. Ideal para indecisos.",
                                      action: #selector(goToRoulette))
        
        let option3 = createOptionRow(title: "Quiz de Personalidad",
                                      iconName: "brain.head.profile",
                                      desc: "Responde 3 preguntas rápidas y nuestra IA analizará tus gustos.",
                                      action: #selector(goToQuiz))
        
        stackView.addArrangedSubview(option1)
        stackView.addArrangedSubview(option2)
        stackView.addArrangedSubview(option3)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            introLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            introLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            introLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackView.heightAnchor.constraint(equalToConstant: 240) // Altura total de los botones
        ])
    }
    
    // MARK: - Helper para crear filas (Botón Principal + Botón Ayuda)
    
    private func createOptionRow(title: String, iconName: String, desc: String, action: Selector) -> UIView {
        let container = UIView()
                container.translatesAutoresizingMaskIntoConstraints = false
                
                // 1. Botón Principal (Funcionalidad) - SISTEMA MODERNO
                // Usamos .filled() que ya nos da el fondo de color sólido por defecto
                var config = UIButton.Configuration.filled()
                
                // Configuración de colores
                config.baseBackgroundColor = .systemRed
                config.baseForegroundColor = .white
                
                // Contenido (Texto e Icono)
                config.title = title
                config.image = UIImage(systemName: iconName)
                config.imagePadding = 10 // Espacio entre el icono y el texto
                config.imagePlacement = .leading // El icono va a la izquierda
                
                // AQUÍ ESTÁ EL CAMBIO: Usamos 'contentInsets' en lugar de 'contentEdgeInsets'
                // 'leading' es izquierda (en idiomas occidentales)
                config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
                
                // Bordes redondeados
                config.cornerStyle = .medium // Equivale a cornerRadius = 12 aprox (sistema adaptativo)
                
                // Creamos el botón aplicando la configuración
                let mainButton = UIButton(configuration: config)
                
                // Importante: Alinear el contenido a la izquierda del botón
                mainButton.contentHorizontalAlignment = .leading
                
                mainButton.addTarget(self, action: action, for: .touchUpInside)
                mainButton.translatesAutoresizingMaskIntoConstraints = false
                
                // 2. Botón de Ayuda (?) - (Este se queda igual, es un botón simple)
                let helpButton = UIButton(type: .system)
                helpButton.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
                helpButton.tintColor = .white
                helpButton.translatesAutoresizingMaskIntoConstraints = false
                
                let helpAction = UIAction { [weak self] _ in
                    self?.showHelpAlert(title: title, message: desc)
                }
                helpButton.addAction(helpAction, for: .touchUpInside)
                
                // Layout
                container.addSubview(mainButton)
                container.addSubview(helpButton)
                
                NSLayoutConstraint.activate([
                    helpButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                    helpButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                    helpButton.widthAnchor.constraint(equalToConstant: 44),
                    helpButton.heightAnchor.constraint(equalToConstant: 44),
                    
                    mainButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                    mainButton.topAnchor.constraint(equalTo: container.topAnchor),
                    mainButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                    mainButton.trailingAnchor.constraint(equalTo: helpButton.leadingAnchor, constant: -12)
                ])
                
                return container
    }
    
    private func showHelpAlert(title: String, message: String) {
        let alert = UIAlertController(title: "¿Qué hace esto?", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navegación (Placeholders)
    
    @objc private func goToMoodMatcher() {
        let moodVC = MoodMatcherViewController()
        navigationController?.pushViewController(moodVC, animated: true)
    }
    
    @objc private func goToRoulette() {
        let rouletteVC = RouletteViewController()
        navigationController?.pushViewController(rouletteVC, animated: true)
    }
    
    @objc private func goToQuiz() {
        print("Navegar a Quiz")
        // Aquí conectaremos el VC real en el siguiente paso
    }
}
