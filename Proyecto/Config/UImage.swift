//
//  UIImageView+Extensions.swift
//  Proyecto
//
//  Created by DESIGN on 16/12/25.
//

import UIKit

class UImage:UIImage{
    
}
extension UIImageView {
    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        // Coloca un placeholder mientras carga
        DispatchQueue.main.async {
            self.image = placeholder
        }

        guard let url = URL(string: urlString) else {
            print("URL is not valid: \(urlString)") // Debugging
            return
        }
        
        // Descarga la imagen en background
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            } else {
                print("Failed to convert data to image")
            }
        }.resume()
    }
}


