import UIKit
import AVKit

class CarouselCell: UICollectionViewCell {

    static let reuseID = "CarouselCell"

    // Crear UIImageView para la imagen
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // Crear UILabel para el título de la película
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var trailerKey: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        // Configuración de constraints para la imagen
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // Configuración de constraints para el título
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])

        // Agregar gesto de tap para reproducir el trailer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playTrailer))
        self.addGestureRecognizer(tapGesture)
    }

    // Configura la celda con los datos de la película
    func configure(with movie: Movie, trailerKey: String?) {
        titleLabel.text = movie.title

        // Aquí usamos el posterPath para cargar la imagen
        if let posterPath = movie.posterPath {
            let imageUrlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
            imageView.loadImage(from: imageUrlString)  // Usamos la extensión para cargar la imagen
        }

        self.trailerKey = trailerKey
    }

    // Función para reproducir el trailer al hacer tap
    @objc private func playTrailer() {
        guard let trailerKey = trailerKey else {
            print("No trailer available")
            return
        }

        let urlString = "https://www.youtube.com/watch?v=\(trailerKey)"
        if let url = URL(string: urlString) {
            let playerVC = AVPlayerViewController()
            let player = AVPlayer(url: url)
            playerVC.player = player
            if let topVC = UIApplication.shared.windows.first?.rootViewController {
                topVC.present(playerVC, animated: true) {
                    player.play()
                }
            }
        }
    }
}





