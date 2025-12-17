import UIKit

class WelcomeViewController: UIViewController {

    private let viewModel = WelcomeViewModel()

    // CollectionView principal
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupNavigation()
        setupUI()
        bindViewModel()
        viewModel.fetchAllCategories()
    }
    
    private func setupNavigation() {
        // Título estilizado estilo app de cine
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Películas"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.red] // Rojo tipo Netflix/TMDB
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupUI() {
        view.addSubview(collectionView)
        
        // Registro de celdas y headers
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        viewModel.onError = { error in
            print("Error: \(error)")
        }
    }
    
    // MARK: - Layout Compositional
    // Esto crea el efecto de listas horizontales dentro del scroll vertical
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // 1. Definir el tamaño del item (la celda de la película)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            // 2. Definir el grupo (cuántos items se ven o el tamaño del contenedor horizontal)
            // widthDimension: .absolute(160) define el ancho fijo de cada poster
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(160),
                                                   heightDimension: .absolute(280)) // Altura del poster + texto
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // 3. Definir la sección
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous // Habilita el scroll horizontal
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 24, trailing: 8)
            
            // 4. Agregar el Header (Título de la sección)
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                     elementKind: UICollectionView.elementKindSectionHeader,
                                                                     alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
}

// MARK: - DataSource & Delegate

extension WelcomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = viewModel.sections[section]
        return viewModel.moviesBySection[sectionType]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as? MovieCell else {
            return UICollectionViewCell()
        }
        
        if let movie = viewModel.movie(at: indexPath) {
            cell.configure(with: movie)
        }
        return cell
    }
    
    // Configurar el Header (Título de la categoría)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        
        let title = viewModel.sections[indexPath.section].title
        header.configure(with: title)
        return header
    }

    // Navegación al detalle
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Usamos el helper del ViewModel para obtener la película correcta de la sección correcta
        guard let selectedMovie = viewModel.movie(at: indexPath),
              let movieID = selectedMovie.id else { return }
        
        // Instanciamos el controlador de detalle que creamos antes
        let detailVC = MovieDetailViewController(movieID: movieID)
        
        // Navegación
        if let navigationController = navigationController {
            navigationController.pushViewController(detailVC, animated: true)
        } else {
            // Fallback si no hay navigationController
            detailVC.modalPresentationStyle = .fullScreen
            present(detailVC, animated: true)
        }
    }
}
