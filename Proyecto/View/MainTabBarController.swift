//
//  MainTabBarController.swift
//  Proyecto
//
//  Created by DESIGN on 17/12/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance() // Configura colores negro/rojo
        setupTabs()       // Configura las pestañas
    }
    
    private func setupTabs() {
        // 1. INICIO
        let homeVC = WelcomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        // Icono: Casa
        homeNav.tabBarItem = UITabBarItem(title: "Inicio", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        // 2. BUSCADOR (¡Asegúrate de tener este bloque!)
        let searchVC = SearchViewController() // Debes tener creada la clase SearchViewController
        let searchNav = UINavigationController(rootViewController: searchVC)
        // Icono: Lupa
        searchNav.tabBarItem = UITabBarItem(title: "Buscar", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "magnifyingglass"))
        
        // --- 3. NUEVO: Asistente IA ---
        let aiVC = AIViewController()
        let navAI = UINavigationController(rootViewController: aiVC)
        navAI.tabBarItem = UITabBarItem(title: "Asistente", image: UIImage(systemName: "sparkles"), tag: 2) // Icono 'sparkles' queda genial para IA
        
        // 3. FAVORITOS
        let favoritesVC = FavoritesViewController() // Debes tener creada la clase FavoritesViewController
        let favNav = UINavigationController(rootViewController: favoritesVC)
        // Icono: Corazón
        favNav.tabBarItem = UITabBarItem(title: "Favoritos", image: UIImage(systemName: "heart"), selectedImage: UIImage(systemName: "heart.fill"))
        
        // 4. PERFIL
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        // Icono: Persona
        profileNav.tabBarItem = UITabBarItem(title: "Perfil", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        // Asignar todos los controladores al TabBar
        setViewControllers([homeNav, searchNav, navAI, favNav, profileNav], animated: true)
    }
    
    private func setupAppearance() {
        // Colores globales del TabBar
        tabBar.tintColor = .systemRed       // Icono seleccionado (Rojo)
        tabBar.unselectedItemTintColor = .gray // Icono no seleccionado (Gris)
        tabBar.backgroundColor = .black     // Fondo
        tabBar.barTintColor = .black
        
        // Ajuste para iOS 15+ para evitar que se vuelva transparente
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
