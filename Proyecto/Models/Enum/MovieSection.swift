//
//  MovieSection.swift
//  Proyecto
//
//  Created by DESIGN on 17/12/25.
//

import Foundation

enum MovieSection: CaseIterable {
    case nowPlaying
    case popular
    case topRated
    case upcoming
    
    var title: String {
        switch self {
        case .nowPlaying: return "En Cartelera"
        case .popular: return "Populares"
        case .topRated: return "Mejor Valoradas"
        case .upcoming: return "Próximamente"
        }
    }
}
