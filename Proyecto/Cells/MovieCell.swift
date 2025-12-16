// MovieCell.swift

import UIKit
import Kingfisher // ¡Necesario para cargar imágenes de URL!

class MovieCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MovieCell"

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(posterImageView)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Cancela la descarga anterior y limpia la imagen al reutilizar la celda
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
    }

    // 🌟 CLAVE: Configuración y carga de la imagen con Kingfisher 🌟
    func configure(with movie: Movie) {
        
        guard let url = movie.posterURL else {
            posterImageView.image = UIImage(systemName: "film") // Placeholder
            return
        }

        posterImageView.kf.indicatorType = .activity // Muestra el indicador de carga
        posterImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "film"),
            options: [
                .transition(.fade(0.3)) // Efecto de transición
            ]
        )
    }
}


