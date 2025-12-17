//
//  Movie.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//
import Foundation

struct Movie: Codable {
    let title: String
    let posterPath: String?
    let overview: String
    let id: Int?

    // CLAVE: Mapeo y URL de la Imagen 
    
    private enum CodingKeys: String, CodingKey {
        case title
        case posterPath = "poster_path" // Mapea 'poster_path' del JSON a 'posterPath' de Swift
        case overview
        case id
    }

    
    var posterURL: URL? {
        let imageBaseURL = "https://image.tmdb.org/t/p/w500"
        guard let path = posterPath else { return nil }
        
        return URL(string: imageBaseURL + path)
    }
}
