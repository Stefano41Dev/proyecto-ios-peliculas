//
//  Cast.swift
//  Proyecto
//
//  Created by DESIGN on 17/12/25.
//

import Foundation

struct Cast: Codable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }
    
    // Helper para obtener la URL de la foto del actor
    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200\(path)")
    }
}

// Estructura contenedora que devuelve la API dentro de "credits"
struct CreditsResponse: Codable {
    let cast: [Cast]
}
