//
//  RouletteViewController.swift
//  Proyecto
//
//  Created by DESIGN on 18/12/25.
//

import UIKit

class RouletteViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel = RouletteViewModel()
    
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
        layer.colors = [
            UIColor(red: 0.6, green: 0.2, blue: 0.9, alpha: 1.0).cgColor, // Morado
            UIColor(red: 0.1, green: 0.1, blue: 0.4, alpha: 1.0).cgColor  // Azul oscuro
        ]
        layer.startPoint = CGPoint(x: 0.2, y: 0.2)
        layer.endPoint = CGPoint(x: 0.8, y: 0.8)
        layer.cornerRadius = 100 // Radio 100 para círculo de 200
        return layer
    }()
    
    private let sparklesImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "sparkles")
        iv.tintColor = .white.withAlphaComponent(0.8)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.font = .italicSystemFont(ofSize: 18)
        label.textColor = .systemPurple
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        
        // Cargar datos a través del ViewModel
        viewModel.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ajustar el frame del gradient
        ballLayer.frame = crystalBallView.bounds
        
        // Efecto de sombra (Glow externo)
        crystalBallView.layer.shadowColor = UIColor.systemPurple.cgColor
        crystalBallView.layer.shadowOffset = .zero
        crystalBallView.layer.shadowRadius = 20
        crystalBallView.layer.shadowOpacity = 0.6
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(crystalBallView)
        view.addSubview(instructionLabel)
        view.addSubview(statusLabel)
        
        crystalBallView.layer.addSublayer(ballLayer)
        crystalBallView.addSubview(sparklesImage)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            crystalBallView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            crystalBallView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            crystalBallView.widthAnchor.constraint(equalToConstant: 200),
            crystalBallView.heightAnchor.constraint(equalToConstant: 200),
            
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
        
        startFloatingAnimation()
    }
    
    // MARK: - Animaciones y Lógica
    
    private func startFloatingAnimation() {
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       options: [.autoreverse, .repeat, .curveEaseInOut, .allowUserInteraction],
                       animations: {
            self.crystalBallView.transform = CGAffineTransform(translationX: 0, y: -10)
        }, completion: nil)
    }
    
    @objc private func handleBallTap() {
        print("🔮 ¡Bola de cristal tocada!")
        
        // Usamos el ViewModel para verificar si hay datos
        guard viewModel.isDataReady else {
            print("⏳ Aún cargando películas...")
            let alert = UIAlertController(title: "Cargando", message: "Los astros se están alineando... intenta de nuevo en unos segundos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        crystalBallView.isUserInteractionEnabled = false
        
        // 1. Feedback táctil
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // 2. Animación
        self.crystalBallView.layer.removeAllAnimations()
        statusLabel.alpha = 1
        instructionLabel.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat, .curveEaseIn], animations: {
            self.crystalBallView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.crystalBallView.layer.shadowRadius = 40
            self.crystalBallView.layer.shadowOpacity = 1.0
        }, completion: nil)
        
        // 3. Iniciar secuencia de textos
        changeStatusTextRecursive(count: 0)
    }
    
    private func changeStatusTextRecursive(count: Int) {
        if count < 4 {
            // Pedimos una frase al ViewModel
            statusLabel.text = viewModel.getRandomPhrase()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.changeStatusTextRecursive(count: count + 1)
            }
        } else {
            showResult()
        }
    }
    
    private func showResult() {
        // Pedimos el ganador al ViewModel
        guard let winner = viewModel.getWinner() else { return }
        
        guard let movieID = winner.id else { return }
        
        self.crystalBallView.layer.removeAllAnimations()
        
        let detailVC = MovieDetailViewController(movieID: movieID)
        
        // Restaurar estado visual
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.statusLabel.alpha = 0
            self.instructionLabel.alpha = 1
            self.crystalBallView.isUserInteractionEnabled = true
            self.startFloatingAnimation()
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
