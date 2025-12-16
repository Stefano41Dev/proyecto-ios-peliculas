// WelcomeViewController.swift

import UIKit
import AVKit

class WelcomeViewController: UIViewController {

    private var topMovies: [Movie] = [] // Usa la estructura Movie modificada

    private let carousel: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 300, height: 450)
        layout.minimumLineSpacing = 16
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        fetchTopMovies()
    }

    private func setupUI() {
        carousel.backgroundColor = .black
        carousel.delegate = self
        carousel.dataSource = self
        // 🌟 Se registra la MovieCell 🌟
        carousel.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        
        view.addSubview(carousel)
        
        NSLayoutConstraint.activate([
            carousel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            carousel.heightAnchor.constraint(equalToConstant: 450)
        ])
    }

    private func fetchTopMovies() {
        APIManager.shared.fetchMovies { [weak self] movies, error in
            guard let self = self else { return }
            if let movies = movies {
                self.topMovies = Array(movies.prefix(5))

                DispatchQueue.main.async {
                    self.carousel.reloadData() // Recarga la vista con los datos
                }
            } else if let error = error {
                print("Error al obtener las películas: \(error)")
            }
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension WelcomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topMovies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
        let movie = topMovies[indexPath.row]
        // 🌟 Se llama al método configure de la celda 🌟
        cell.configure(with: movie)
        return cell
    }
}

