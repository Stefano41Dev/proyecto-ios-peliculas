//
//  WelcomeViewController.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//

import UIKit

class WelcomeViewController: UIViewController {

    private let viewModel = WelcomeViewModel()

    // MARK: - UI Elements
    
    private lazy var collectionView: UICollectionView = {
        // Iniciamos con el layout por defecto
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupNavigation()
        setupUI()
        bindViewModel()
        
        viewModel.fetchAllCategories()
    }
    
    // MARK: - Setup Methods
    
    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Películas"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemRed]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .systemRed
    }

    private func setupUI() {
        view.addSubview(collectionView)
        
        // Registro de Celdas y Headers
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
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
            guard let self = self else { return }
            // Al actualizar datos, refrescamos el layout por si cambió de Modo Normal a Filtrado
            self.collectionView.setCollectionViewLayout(self.createCompositionalLayout(), animated: true)
            self.collectionView.reloadData()
        }
        
        viewModel.onError = { error in
            print("Error: \(error)")
        }
    }
    
    // MARK: - Compositional Layout Dinámico
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // SECCIÓN 0: Categorías (Siempre igual)
            if sectionIndex == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100),
                                                      heightDimension: .absolute(32))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100),
                                                       heightDimension: .absolute(32))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
                section.interGroupSpacing = 10
                return section
            }
            
            // LÓGICA DINÁMICA: ¿Estamos filtrando?
            let isFiltering = self.viewModel.selectedGenre != nil
            
            if isFiltering {
                // LAYOUT MODO FILTRADO: Grid Vertical (3 columnas)
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(180)) // Altura fija de cada fila
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 10, bottom: 16, trailing: 10)
                return section
                
            } else {
                // LAYOUT MODO NORMAL: Carruseles Horizontales
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(160),
                                                       heightDimension: .absolute(280))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 24, trailing: 8)
                
                // Header (Título de sección)
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
}

// MARK: - DataSource & Delegate

extension WelcomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if viewModel.selectedGenre != nil {
            // Modo Filtrado: Categorías (0) + Resultados (1)
            return 2
        } else {
            // Modo Normal: Categorías (0) + Secciones Originales (1..N)
            return 1 + viewModel.sections.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Sección 0: Categorías
        if section == 0 {
            return viewModel.genres.count
        }
        
        // Modo Filtrado
        if viewModel.selectedGenre != nil {
            // Sección 1 es el Grid de resultados
            return viewModel.filteredMovies.count
        }
        
        // Modo Normal (Secciones originales)
        let sectionType = viewModel.sections[section - 1]
        return viewModel.moviesBySection[sectionType]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // --- CELDA DE CATEGORÍA ---
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as! CategoryCell
            let genre = viewModel.genres[indexPath.row]
            
            // Marcamos visualmente si está seleccionada
            let isSelected = (genre.id == viewModel.selectedGenre?.id)
            cell.configure(with: genre, isSelected: isSelected)
            
            return cell
        }
        
        // --- CELDA DE PELÍCULA ---
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
        
        if viewModel.selectedGenre != nil {
            // Estamos mostrando resultados filtrados
            let movie = viewModel.filteredMovies[indexPath.row]
            cell.configure(with: movie)
        } else {
            // Estamos mostrando las listas normales
            let sectionType = viewModel.sections[indexPath.section - 1]
            if let movies = viewModel.moviesBySection[sectionType] {
                cell.configure(with: movies[indexPath.row])
            }
        }
        
        return cell
    }
    
    // Headers de Sección
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        // No mostramos headers en la sección de Categorías ni en el Grid de Filtro
        if indexPath.section == 0 || viewModel.selectedGenre != nil {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as! SectionHeaderView
        let title = viewModel.sections[indexPath.section - 1].title
        header.configure(with: title)
        return header
    }

    // Selección
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // A) Click en CATEGORÍA
        if indexPath.section == 0 {
            let genre = viewModel.genres[indexPath.row]
            viewModel.selectGenre(genre) // Esto dispara la recarga y el cambio de layout
        }
        
        // B) Click en PELÍCULA
        else {
            var selectedMovie: Movie?
            
            if viewModel.selectedGenre != nil {
                selectedMovie = viewModel.filteredMovies[indexPath.row]
            } else {
                let sectionType = viewModel.sections[indexPath.section - 1]
                selectedMovie = viewModel.moviesBySection[sectionType]?[indexPath.row]
            }
            
            if let movieID = selectedMovie?.id {
                let detailVC = MovieDetailViewController(movieID: movieID)
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}   
