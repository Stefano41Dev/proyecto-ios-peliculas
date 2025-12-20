//
//  RouletteViewController.swift
//  Proyecto
//
//  Created by DESIGN on 18/12/25.
//

import UIKit

class RouletteViewController: UIViewController {

    // MARK: - Propiedades
    private let apiManager = APIManager.shared
    private var candidateMovies: [Movie] = []
    
    // Textos para la animación de carga
    private let mysticalPhrases = [
        "Consultando a los astros...",
        "Analizando el destino...",
        "Las estrellas se alinean...",
        "Buscando tu película ideal...",
        "El oráculo está decidiendo..."
    ]
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Cine-Roulette"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Toca la bola de cristal para revelar tu destino cinematográfico."
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Contenedor de la Bola de Cristal
    private lazy var crystalBallView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Gesto de Tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBallTap))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // Capas visuales de la bola (Gradient y Brillo)
    private let ballLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        // Colores místicos: Morado oscuro a Azul brillante
        layer.colors = [
            UIColor(red: 0.6, green: 0.2, blue: 0.9, alpha: 1.0).cgColor, // Morado
            UIColor(red: 0.1, green: 0.1, blue: 0.4, alpha: 1.0).cgColor  // Azul oscuro
        ]
        layer.startPoint = CGPoint(x: 0.2, y: 0.2) // Luz viene de arriba izquierda
        layer.endPoint = CGPoint(x: 0.8, y: 0.8)
        layer.cornerRadius = 100 // Radio para hacerla circular (200x200)
        return layer
    }()
    
    // Icono dentro de la bola (Opcional, o un destello)
    private let sparklesImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "sparkles")
        iv.tintColor = .white.withAlphaComponent(0.8)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Feedback visual (Cargando)
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.font = .italicSystemFont(ofSize: 18)
        label.textColor = .systemPurple
        label.textAlignment = .center
        label.alpha = 0 // Oculto al inicio
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        preloadMovies() // Cargar datos silenciosamente
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ajustar el frame del gradient cuando el layout esté listo
        ballLayer.frame = crystalBallView.bounds
        
        // Efecto de sombra (Glow externo)
        crystalBallView.layer.shadowColor = UIColor.systemPurple.cgColor
        crystalBallView.layer.shadowOffset = .zero
        crystalBallView.layer.shadowRadius = 20
        crystalBallView.layer.shadowOpacity = 0.6
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(crystalBallView)
        view.addSubview(instructionLabel)
        view.addSubview(statusLabel)
        
        // Añadir capa a la vista de la bola
        crystalBallView.layer.addSublayer(ballLayer)
        crystalBallView.addSubview(sparklesImage)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Bola de Cristal centrada (Tamaño 200x200)
            crystalBallView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            crystalBallView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            crystalBallView.widthAnchor.constraint(equalToConstant: 200),
            crystalBallView.heightAnchor.constraint(equalToConstant: 200),
            
            // Destellos dentro
            sparklesImage.centerXAnchor.constraint(equalTo: crystalBallView.centerXAnchor),
            sparklesImage.centerYAnchor.constraint(equalTo: crystalBallView.centerYAnchor),
            sparklesImage.widthAnchor.constraint(equalToConstant: 80),
            sparklesImage.heightAnchor.constraint(equalToConstant: 80),
            
            statusLabel.topAnchor.constraint(equalTo: crystalBallView.bottomAnchor, constant: 30),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            instructionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        // Animación "flotante" permanente
        startFloatingAnimation()
    }
    
    private func preloadMovies() {
        // Cargamos Top Rated para asegurar calidad en la recomendación
        apiManager.fetchMovies(endpoint: .topRated) { [weak self] movies, _ in
            if let movies = movies {
                self?.candidateMovies = movies
            }
        }
    }
    
    // MARK: - Animaciones y Lógica
    
    private func startFloatingAnimation() {
        // Animación suave de arriba a abajo para parecer que levita
        UIView.animate(withDuration: 2.0,
                               delay: 0,
                               options: [.autoreverse, .repeat, .curveEaseInOut, .allowUserInteraction],
                               animations: {
                    self.crystalBallView.transform = CGAffineTransform(translationX: 0, y: -10)
                }, completion: nil)
    }
    
    @objc private func handleBallTap() {
        // Evitar doble tap
        guard !candidateMovies.isEmpty else {
                print("⏳ Aún cargando películas o error de conexión...")
                // Opcional: Mostrar una pequeña alerta visual
                let alert = UIAlertController(title: "Cargando", message: "Los astros se están alineando (cargando datos)... intenta de nuevo en unos segundos.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
        }
        crystalBallView.isUserInteractionEnabled = false
        
        // 1. Feedback táctil
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // 2. Animación de "Pensando" (Latido rápido)
        self.crystalBallView.layer.removeAllAnimations() // Parar levitación
        statusLabel.alpha = 1
        instructionLabel.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat, .curveEaseIn], animations: {
            self.crystalBallView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.crystalBallView.layer.shadowRadius = 40 // Más brillo
            self.crystalBallView.layer.shadowOpacity = 1.0
        }, completion: nil)
        
        // 3. Cambiar textos rápidamente
        changeStatusTextRecursive(count: 0)
    }
    
    private func changeStatusTextRecursive(count: Int) {
        // Cambia el texto 4 veces antes de mostrar el resultado
        if count < 4 {
            statusLabel.text = mysticalPhrases.randomElement()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.changeStatusTextRecursive(count: count + 1)
            }
        } else {
            // FIN: Mostrar resultado
            showResult()
        }
    }
    
    private func showResult() {
        // 1. Elegimos una película al azar
                guard let winner = candidateMovies.randomElement() else { return }
                
                // 2. CORRECCIÓN: Desempaquetamos el ID de forma segura
                // Si winner.id es nil, detenemos la ejecución para evitar errores
                guard let movieID = winner.id else { return }
                
                // Parar animaciones
                self.crystalBallView.layer.removeAllAnimations()
                
                // 3. Ahora pasamos 'movieID' que ya es un Int seguro (no opcional)
                let detailVC = MovieDetailViewController(movieID: movieID)
                
                // Restaurar estado visual por si vuelve atrás
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.statusLabel.alpha = 0
                    self.instructionLabel.alpha = 1
                    self.crystalBallView.isUserInteractionEnabled = true
                    self.startFloatingAnimation()
                }
                
                navigationController?.pushViewController(detailVC, animated: true)
    }
}
