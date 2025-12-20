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
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        btn.setImage(image, for: .normal)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        btn.tintColor = .white
        btn.layer.cornerRadius = 20
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
        iv.backgroundColor = .darkGray
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
    
    // NUEVO: Tagline (Frase promocional)
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 16)
        label.textColor = .systemGray2
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // NUEVO: Géneros y Metadata
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemRed // Color destacado
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let watchTrailerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Ver Trailer", for: .normal)
        btn.backgroundColor = .systemRed
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
        btn.isHidden = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateFavoriteIcon()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backdropImageView)
        backdropImageView.layer.insertSublayer(gradientLayer, at: 0)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(taglineLabel) // Nuevo
        contentView.addSubview(infoLabel)
        contentView.addSubview(genresLabel) // Nuevo
        contentView.addSubview(watchTrailerButton)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(castLabel)
        contentView.addSubview(castCollectionView)
        
        castCollectionView.dataSource = self
        castCollectionView.register(CastCell.self, forCellWithReuseIdentifier: CastCell.identifier)
        
        watchTrailerButton.addTarget(self, action: #selector(playTrailer), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Image
            backdropImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalToConstant: 300),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Tagline (Nuevo)
            taglineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            taglineLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            taglineLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Info (Rating, Fecha)
            infoLabel.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 12),
            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Genres (Nuevo)
            genresLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8),
            genresLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            genresLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Button
            watchTrailerButton.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 20),
            watchTrailerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            watchTrailerButton.widthAnchor.constraint(equalToConstant: 140),
            watchTrailerButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Overview
            overviewLabel.topAnchor.constraint(equalTo: watchTrailerButton.bottomAnchor, constant: 24),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Cast
            castLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 24),
            castLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
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
            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Binding y Lógica
    
    private func bindViewModel() {
        viewModel.onDataLoaded = { [weak self] in
            self?.updateUI()
        }
        viewModel.onError = { errorMsg in
            print("Error: \(errorMsg)")
        }
    }
    
    private func updateUI() {
        guard let movie = viewModel.movie else { return } // Accedemos al modelo crudo para los campos nuevos
        
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        infoLabel.text = viewModel.infoText // Mantiene formato de Fecha | Duración | Rating
        
        // --- NUEVO: Mapeo de datos ---
        
        // Tagline (si existe)
        if let tagline = movie.tagline, !tagline.isEmpty {
            taglineLabel.text = "\"\(tagline)\""
            taglineLabel.isHidden = false
        } else {
            taglineLabel.isHidden = true
        }
        
        // Géneros y Lenguaje
        var metaText = ""
        if let genres = movie.genres {
            let genreNames = genres.map { $0.name }.joined(separator: ", ")
            metaText += genreNames
        }
        
        if let lang = movie.originalLanguage {
            let langUpper = lang.uppercased()
            if !metaText.isEmpty { metaText += "  •  " }
            metaText += "Idioma: \(langUpper)"
        }
        
        genresLabel.text = metaText
        // -----------------------------
        
        if let url = viewModel.backdropURL {
            backdropImageView.kf.setImage(with: url)
        }
        
        watchTrailerButton.isHidden = viewModel.trailers.isEmpty
        updateFavoriteIcon()
        castCollectionView.reloadData()
    }
    
    private func updateFavoriteIcon() {
        guard let movie = viewModel.movie, let id = movie.id else { return }
        let isFav = FavoritesManager.shared.isFavorite(movieID: id)
        let imageName = isFav ? "heart.fill" : "heart"
        let color: UIColor = isFav ? .systemRed : .white
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = color
    }
    
    @objc private func toggleFavorite() {
        guard let movie = viewModel.movie else { return }
        FavoritesManager.shared.toggleFavorite(movie: movie)
        updateFavoriteIcon()
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func playTrailer() {
        guard let trailer = viewModel.trailers.first(where: { $0.site == "YouTube" }) else { return }
        if let url = URL(string: "https://www.youtube.com/watch?v=\(trailer.key)") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapBack() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - CollectionView DataSource
extension MovieDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCell.identifier, for: indexPath) as! CastCell
        let actor = viewModel.cast[indexPath.row]
        cell.configure(with: actor)
        return cell
    }
}

// Celda interna para actores
class CastCell: UICollectionViewCell {
    static let identifier = "CastCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 35
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
