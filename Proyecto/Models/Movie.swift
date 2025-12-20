//
//  Movie.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//
import Foundation

struct Movie: Codable {
    let id: Int?
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String? // Imagen de fondo para el detalle
    let releaseDate: String?
    let voteAverage: Double?  // Tu "Ranking" o calificación
    let runtime: Int?         // Duración en minutos
    let genreIds: [Int]?
    
    let tagline: String?          // Ej: "El mundo cambiará para siempre."
    let status: String?           // Ej: "Released"
    let originalLanguage: String? // Ej: "en"
    let genres: [Genre]?          // Lista de objetos género con nombre
    // Estos campos vendrán llenos solo cuando usemos el endpoint de detalle con append_to_response
    let credits: CreditsResponse?
    let videos: TrailerResponse?

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case runtime
        case genreIds = "genre_ids"
        case credits, videos
        
        case tagline
        case status
        case originalLanguage = "original_language"
        case genres
    }

    var posterURL: URL? {
        let imageBaseURL = "https://image.tmdb.org/t/p/w500"
        guard let path = posterPath else { return nil }
        return URL(string: imageBaseURL + path)
    }
    
    var backdropURL: URL? {
        let imageBaseURL = "https://image.tmdb.org/t/p/w780" // Mejor calidad para el fondo
        guard let path = backdropPath else { return nil }
        return URL(string: imageBaseURL + path)
    }
    
    // Formato amigable para el ranking (ej: "8.5 ★")
    // Nota: TMDB no da "Rotten Tomatoes", da su propio "Vote Average".
    var ratingDisplay: String {
        guard let rating = voteAverage else { return "N/A" }
        return String(format: "%.1f ★", rating)
    }
}
