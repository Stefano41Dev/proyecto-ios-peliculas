//
//  CategoryCell.swift
//  Proyecto
//
//  Created by DESIGN on 17/12/25.
//

import Foundation
import UIKit

class CategoryCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        contentView.layer.cornerRadius = 16 // Bordes redondeados
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with genre: Genre, isSelected: Bool = false) {
        label.text = genre.name
        // Cambio visual si está seleccionado
        if isSelected {
            contentView.backgroundColor = .systemRed
            contentView.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            contentView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        }
    }
}
