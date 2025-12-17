import UIKit

class WelcomeViewController: UIViewController {

    private let viewModel = WelcomeViewModel()

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
        bindViewModel()
        viewModel.fetchTopMovies()
    }

    private func setupUI() {
        carousel.backgroundColor = .black
        carousel.delegate = self
        carousel.dataSource = self
        carousel.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        view.addSubview(carousel)

        NSLayoutConstraint.activate([
            carousel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            carousel.heightAnchor.constraint(equalToConstant: 450)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onMoviesUpdated = { [weak self] in
            self?.carousel.reloadData()
        }
        
        viewModel.onError = { error in
            print("Error al obtener películas: \(error)")
        }
    }
}

extension WelcomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.topMovies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
        let movie = viewModel.topMovies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }
}
