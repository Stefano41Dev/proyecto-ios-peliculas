//
//  MovieRepository.swift
//  Proyecto
//
//  Created by DESIGN on 17/12/25.
//

import Foundation

class MovieRepository {
    
    private let apiManager = APIManager.shared
    
    func getPopularMovies(page: Int = 1, completion: @escaping ([Movie]?, Error?) -> Void) {
        apiManager.fetchMovies(page: page) { movies, error in
            completion(movies, error)
        }
    }
    
    func getMovieTrailers(movieID: Int, completion: @escaping ([Trailer]?, Error?) -> Void) {
        apiManager.fetchMovieTrailers(movieID: movieID) { trailers, error in
            completion(trailers, error)
        }
    }
    
}
