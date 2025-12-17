//
//  SearchViewController.swift
//  Proyecto
//
//  Created by DESIGN on 17/12/25.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let viewModel = SearchViewModel()
    
    private let searchController = UISearchController(searchResultsController: nil)
    var isCategoryMode = false
    var initialGenre: Genre?
    
    private lazy var categoriesCollectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.estimatedItemSize = CGSize(width: 80, height: 32)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.backgroundColor = .black
            cv.showsHorizontalScrollIndicator = false
            cv.translatesAutoresizingMaskIntoConstraints = false
            return cv
        }()
    
    private lazy var resultsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 110, height: 180) // Un poco más pequeños
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.isHidden = true // Oculto al inicio
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    // 2. Vista para HISTORIAL (Lista simple)
    private let historyTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .black
        tv.separatorColor = .darkGray
        tv.tableFooterView = UIView()
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Buscar"
        setupSearchController()
        setupUI()
        bindViewModel()
        if isCategoryMode, let genre = initialGenre {
                    title = genre.name
                    searchController.isActive = false // Ocultamos buscador si quieres, o lo dejas
                    viewModel.searchByGenre(id: genre.id)
                    resultsCollectionView.isHidden = false
                    historyTableView.isHidden = true
                    categoriesCollectionView.isHidden = true // Ocultamos barra de filtros
                } else {
                    // Modo Normal (Buscador + Filtros)
                    setupCategoriesUI()
                    viewModel.loadGenres { [weak self] in
                        DispatchQueue.main.async {
                            self?.categoriesCollectionView.reloadData()
                        }
                    }
                }
    }
    private func setupCategoriesUI() {
            // Insertar categoriesCollectionView debajo del SafeArea y arriba de los resultados
            view.addSubview(categoriesCollectionView)
            
            categoriesCollectionView.delegate = self
            categoriesCollectionView.dataSource = self
            categoriesCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
            
            NSLayoutConstraint.activate([
                categoriesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                categoriesCollectionView.heightAnchor.constraint(equalToConstant: 50),
                
                // Ajustar las otras vistas para que empiecen debajo de las categorías
                historyTableView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor),
                resultsCollectionView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor)
                // (El resto de constraints bottom/leading/trailing se mantienen igual)
            ])
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadHistory()
        historyTableView.reloadData()
    }
    
    private func setupSearchController() {
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Películas, series, géneros..."
            searchController.searchBar.barStyle = .black
            searchController.searchBar.tintColor = .systemRed
            
            // Personalizar texto blanco en searchbar
            searchController.searchBar.searchTextField.textColor = .white
            
            navigationItem.searchController = searchController
            
            // CORRECCIÓN: Esta línea obliga a que el buscador se muestre siempre
            navigationItem.hidesSearchBarWhenScrolling = false
            
            definesPresentationContext = true
        }
    
    private func setupUI() {
        view.addSubview(historyTableView)
        view.addSubview(resultsCollectionView)
        
        historyTableView.frame = view.bounds
        resultsCollectionView.frame = view.bounds
        
        // Configurar TableView (Historial)
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        
        // Botón limpiar historial en footer
        let footerBtn = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        footerBtn.setTitle("Borrar historial reciente", for: .normal)
        footerBtn.setTitleColor(.systemRed, for: .normal)
        footerBtn.addTarget(self, action: #selector(clearHistory), for: .touchUpInside)
        historyTableView.tableFooterView = footerBtn
        
        // Configurar CollectionView (Resultados)
        resultsCollectionView.delegate = self
        resultsCollectionView.dataSource = self
        resultsCollectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
    }
    
    private func bindViewModel() {
        viewModel.onResultsUpdated = { [weak self] in
            guard let self = self else { return }
            self.resultsCollectionView.reloadData()
            self.historyTableView.reloadData()
            
            // Alternar vistas
            let isSearching = self.searchController.isActive && !(self.searchController.searchBar.text?.isEmpty ?? true)
            self.resultsCollectionView.isHidden = !isSearching
            self.historyTableView.isHidden = isSearching
        }
    }
    
    @objc private func clearHistory() {
        viewModel.clearHistory()
        historyTableView.reloadData()
    }
}

// MARK: - Search Updating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        viewModel.search(query: text)
    }
}

// MARK: - TableView (Historial)
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .lightGray
        cell.textLabel?.text = viewModel.searchHistory[indexPath.row]
        cell.imageView?.image = UIImage(systemName: "clock.arrow.circlepath")
        cell.imageView?.tintColor = .gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = viewModel.searchHistory[indexPath.row]
        searchController.isActive = true
        searchController.searchBar.text = text
        viewModel.search(query: text)
    }
}

// MARK: - CollectionView (Resultados)
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
        cell.configure(with: viewModel.movies[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoriesCollectionView {
                    // Filtrar por género
                    let genre = viewModel.genres[indexPath.row]
                    viewModel.searchByGenre(id: genre.id)
                    
                    // Actualizar UI
                    searchController.searchBar.text = "" // Limpiar texto
                    searchController.searchBar.resignFirstResponder()
                    searchController.isActive = false
                    
                    resultsCollectionView.isHidden = false
                    historyTableView.isHidden = true
                } else {
                    // Click en película (Tu código existente para ir al detalle)
                    let movie = viewModel.movies[indexPath.row]
                    
                    // Guardar en historial al seleccionar
                    if let text = searchController.searchBar.text {
                        viewModel.addToHistory(query: text)
                    }
                    
                    guard let id = movie.id else { return }
                    let detailVC = MovieDetailViewController(movieID: id)
                    detailVC.modalPresentationStyle = .fullScreen
                    present(detailVC, animated: true)
                }
        
    }
}
