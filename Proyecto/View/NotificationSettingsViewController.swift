//
//  NotificationSettingsViewController.swift
//  Proyecto
//
//  Created by DESIGN on 18/12/25.
//

import UIKit

class NotificationSettingsViewController: UIViewController {

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .black
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // Modelo de datos simple para las opciones
    struct NotificationOption {
        let title: String
        let key: String // Clave para UserDefaults
    }
    
    private let options = [
        NotificationOption(title: "Nuevos Estrenos", key: "notif_new_releases"),
        NotificationOption(title: "Recomendaciones", key: "notif_recommendations"),
        NotificationOption(title: "Actualizaciones de App", key: "notif_updates"),
        NotificationOption(title: "Recordatorios de Favoritos", key: "notif_favorites")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notificaciones"
        view.backgroundColor = .black
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        // Registramos una celda estándar, no necesitamos una personalizada compleja
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // Acción cuando cambia un switch
    @objc private func switchChanged(_ sender: UISwitch) {
        let key = options[sender.tag].key
        UserDefaults.standard.set(sender.isOn, forKey: key)
        print("Opción \(key) cambiada a: \(sender.isOn)")
        
        // Opcional: Aquí podrías pedir permiso de notificaciones al sistema real
        if sender.isOn {
            requestSystemPermissions()
        }
    }
    
    private func requestSystemPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permiso concedido")
            }
        }
    }
}

extension NotificationSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath)
        let option = options[indexPath.row]
        
        // Configuración visual
        cell.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        cell.textLabel?.text = option.title
        cell.textLabel?.textColor = .white
        cell.selectionStyle = .none
        
        // Crear el Switch
        let switchControl = UISwitch()
        switchControl.onTintColor = .systemRed // Color de tu marca
        switchControl.tag = indexPath.row // Usamos el tag para saber qué fila es
        switchControl.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        // Cargar estado guardado (o true por defecto si no existe)
        // 'register(defaults:)' en AppDelegate sería lo ideal, pero esto funciona rápido:
        let isSaved = UserDefaults.standard.object(forKey: option.key) as? Bool
        switchControl.isOn = isSaved ?? false
        
        cell.accessoryView = switchControl
        
        return cell
    }
    
    // Título del header para que se vea más organizado
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Configurar Alertas"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .lightGray
        }
    }
}
