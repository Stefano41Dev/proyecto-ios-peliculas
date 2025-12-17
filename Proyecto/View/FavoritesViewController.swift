//
//  FavoritesViewController.swift
//  Proyecto
//
//  Created by DESIGN on 17/12/25.
//

import UIKit

class FavoritesViewController: UIViewController {

    private var favorites: [Movie] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 160, height: 280) // Mismo tamaño que en Welcome
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No tienes favoritos aún"
        label.textColor = .lightGray
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Mis Favoritos"
        setupUI()
        loadFavorites()
        
        // Escuchar cambios para recargar si agregas/quitas desde el detalle
        NotificationCenter.default.addObserver(self, selector: #selector(loadFavorites), name: NSNotification.Name("FavoritesChanged"), object: nil)
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func loadFavorites() {
        favorites = FavoritesManager.shared.getAllFavorites()
        emptyLabel.isHidden = !favorites.isEmpty
        collectionView.reloadData()
    }
}

extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
        cell.configure(with: favorites[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Navegar al detalle igual que en Welcome
        guard let movieID = favorites[indexPath.row].id else { return }
        let detailVC = MovieDetailViewController(movieID: movieID)
        detailVC.modalPresentationStyle = .fullScreen
        present(detailVC, animated: true)
    }
}
