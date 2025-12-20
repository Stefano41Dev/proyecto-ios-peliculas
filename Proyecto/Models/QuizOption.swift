//
//  QuizOption.swift
//  Proyecto
//
//  Created by DESIGN on 20/12/25.
//

import Foundation
struct QuizOption {
    let title: String
    let emoji: String
    let filter: (Movie) -> Bool // Cada opción tiene su propia lógica de filtro
}
