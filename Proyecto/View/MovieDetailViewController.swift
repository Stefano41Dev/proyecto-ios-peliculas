//
//  MovieDetailViewController.swift
//  Proyecto
//
//  Created by Gemini on 17/12/25.
//

import UIKit
import Kingfisher

class MovieDetailViewController: UIViewController {

    private let viewModel: MovieDetailViewModel
    
    // MARK: - UI Elements
    private let backButton: UIButton = {
            let btn = UIButton(type: .system)
            // Usamos un ícono de sistema (SF Symbol)
            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
            let image = UIImage(systemName: "chevron.left", withConfiguration: config) // O "xmark"
            btn.setImage(image, for: .normal)
            
            // Estilo: Círculo blanco semitransparente o negro
            btn.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            btn.tintColor = .white
            btn.layer.cornerRadius = 20 // Para que sea redondo (mitad de 40)
            btn.translatesAutoresizingMaskIntoConstraints = false
            return btn
        }()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backdropImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .darkGray // Placeholder visual
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.locations = [0.0, 1.0]
        return layer
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoLabel: UILabel = { // Fecha, Duración, Ranking
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.9)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let castLabel: UILabel = {
        let label = UILabel()
        label.text = "Reparto Principal"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // CollectionView para el reparto (horizontal)
    private let castCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 150)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let watchTrailerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Ver Trailer", for: .normal)
        btn.backgroundColor = .systemRed
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
        btn.isHidden = true // Se oculta hasta cargar datos
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let favoriteButton: UIButton = {
            let btn = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
            let image = UIImage(systemName: "heart", withConfiguration: config)
            btn.setImage(image, for: .normal)
            btn.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            btn.tintColor = .white
            btn.layer.cornerRadius = 20
            btn.translatesAutoresizingMaskIntoConstraints = false
            return btn
        }()

    // MARK: - Init
    
    init(movieID: Int) {
        self.viewModel = MovieDetailViewModel(movieID: movieID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        bindViewModel()
        viewModel.loadDetails()
        setupBackButton()
        setupFavoritesButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = backdropImageView.bounds
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backdropImageView)
        backdropImageView.layer.insertSublayer(gradientLayer, at: 0)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(watchTrailerButton)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(castLabel)
        contentView.addSubview(castCollectionView)
        
        // Configuración del CollectionView de actores
        castCollectionView.dataSource = self
        castCollectionView.register(CastCell.self, forCellWithReuseIdentifier: CastCell.identifier) // (Debes crear esta celda simple)
        
        watchTrailerButton.addTarget(self, action: #selector(playTrailer), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Backdrop Image (Cabecera)
            backdropImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalToConstant: 300),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Info (Rating, fecha, etc)
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Botón Trailer
            watchTrailerButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16),
            watchTrailerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            watchTrailerButton.widthAnchor.constraint(equalToConstant: 120),
            watchTrailerButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Overview
            overviewLabel.topAnchor.constraint(equalTo: watchTrailerButton.bottomAnchor, constant: 24),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Cast Label
            castLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 24),
            castLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Cast CollectionView
            castCollectionView.topAnchor.constraint(equalTo: castLabel.bottomAnchor, constant: 12),
            castCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            castCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            castCollectionView.heightAnchor.constraint(equalToConstant: 160),
            castCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    private func setupFavoritesButton() {
            view.addSubview(favoriteButton)
            favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                // Lo ponemos a la derecha, opuesto al botón atrás
                favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                favoriteButton.widthAnchor.constraint(equalToConstant: 40),
                favoriteButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    private func updateFavoriteIcon() {
            guard let movie = viewModel.movie, let id = movie.id else { return }
            let isFav = FavoritesManager.shared.isFavorite(movieID: id)
            let imageName = isFav ? "heart.fill" : "heart"
            let color: UIColor = isFav ? .systemRed : .white
            
            favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
            favoriteButton.tintColor = color
        }
    private func setupBackButton() {
            // IMPORTANTE: Añadirlo directamente a la 'view' principal, NO al ScrollView,
            // para que se quede fijo flotando aunque bajes haciendo scroll.
            view.addSubview(backButton)
            
            backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                // Posición: Arriba a la izquierda
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                
                // Tamaño: 40x40
                backButton.widthAnchor.constraint(equalToConstant: 40),
                backButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }

        // Mostrarla de nuevo al salir (para que no afecte a otras pantallas)
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.onDataLoaded = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onError = { errorMsg in
            print("Error: \(errorMsg)")
        }
    }
    
    private func updateUI() {
        titleLabel.text = viewModel.title
        overviewLabel.text = viewModel.overview
        infoLabel.text = viewModel.infoText
        
        if let url = viewModel.backdropURL {
            backdropImageView.kf.setImage(with: url)
        }
        
        watchTrailerButton.isHidden = viewModel.trailers.isEmpty
        castCollectionView.reloadData()
    }
    
    @objc private func playTrailer() {
        // Lógica similar a la de tu CarouselCell para reproducir youtube
        guard let trailer = viewModel.trailers.first(where: { $0.site == "YouTube" }) else { return }
        let url = URL(string: "https://www.youtube.com/watch?v=\(trailer.key)")!
        UIApplication.shared.open(url)
    }
    @objc private func didTapBack() {
            // Si hay una pila de navegación (Navigation Controller), hacemos "Pop" (Retroceder)
            if let navigationController = navigationController {
                navigationController.popViewController(animated: true)
            } else {
                // Si por alguna razón se presentó modal, usamos Dismiss
                dismiss(animated: true, completion: nil)
            }
        }
    @objc private func toggleFavorite() {
            guard let movie = viewModel.movie else { return }
            FavoritesManager.shared.toggleFavorite(movie: movie)
            updateFavoriteIcon() // Actualiza visualmente
            
            // Feedback háptico (vibración ligera)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
}

// MARK: - Extensions for CollectionView (Cast)

extension MovieDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! CastCell
        let actor = viewModel.cast[indexPath.row]
        cell.configure(with: actor)
        return cell
    }
}

// Celda simple interna para los actores
class CastCell: UICollectionViewCell {
    static let identifier = "CastCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 35 // Circular
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with cast: Cast) {
        nameLabel.text = cast.name
        if let url = cast.profileURL {
            imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle"))
        } else {
            imageView.image = UIImage(systemName: "person.circle")
        }
    }
}
