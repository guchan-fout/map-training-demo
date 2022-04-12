//
//  ViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2021/11/25.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController  {
    
    let locationManager = CLLocationManager()
    let tableView = UITableView()
    let titleLable = UILabel()
    var safeArea: UILayoutGuide!
    let cellID = "cell"
    
    var characters = ["Ask for Location permisson", "Open a map", "Open a train map", "current marker","location consumer","master","Navigator"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLayoutSubviews() {
        setupTitle()
        setupTableView()
    }
    
    func setupTitle () {
        titleLable.text = "Choose the option"
        titleLable.textAlignment = .center
        titleLable.backgroundColor = .brown
        titleLable.frame = CGRect(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top, width: view.bounds.width, height: 50)
        view.addSubview(titleLable)
    }
    
    func setupTableView() {
        print("setupTableView")
        
        safeArea = view.layoutMarginsGuide
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor,constant: titleLable.frame.height).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
}


extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = characters[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            print("\(#function) ask for permission")
            askForLocationPermisson()
        case 1:
            print("\(#function) open a basic map")
            let mapVC = MapViewController()
            mapVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(mapVC, animated: true)
        case 2:
            print("\(#function) open a train")
            let mapVC = CustomTrainMapViewController()
            mapVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(mapVC, animated: true)
        case 3:
            print("\(#function) open a train")
            let mapVC = MarkerViewController()
            mapVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(mapVC, animated: true)
        case 4:
            print("\(#function) open a train")
            let mapVC = LocationComsumerViewController()
            mapVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(mapVC, animated: true)
        case 5:
            print("\(#function) open a master")
            let mapVC = MasterViewController()
            mapVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(mapVC, animated: true)
        case 6:
            print("\(#function) open a navigator")
            let mapVC = AdvancedViewController()
            mapVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(mapVC, animated: true)
        default:
            print("\(#function) no options")
        }
        
        
    }
    
    func askForLocationPermisson() {
        locationManager.delegate = self
        let authorizationStatus: CLAuthorizationStatus

        if #available(iOS 14, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        print("authorizationStatus: \(authorizationStatus.rawValue)")
        
        switch authorizationStatus {
        case .denied:
            print("denied")
            //requst permission dialog will not work
            showAlert()
        case .authorizedAlways, .authorizedWhenInUse:
            print("Already have permission")
        default:
            locationManager.requestWhenInUseAuthorization()
    
            break
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Please enable the location permisson", message: "", preferredStyle: .actionSheet)
        
        let yesAction = UIAlertAction(title: "OK", style: .default) { action in
            print("tapped yes")
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { action in
            print("tapped cancel")
            alert.dismiss(animated: true, completion:  nil)
        }
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        // UIAlertControllerの表示
        present(alert, animated: true, completion: nil)

    }
}


extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .notDetermined:
                print("user haven't decided yet")
            case .denied:
                print("user denied, need to change it from setting")
            case .restricted:
                print("this device's location service is restricted")
            case .authorizedAlways:
                print("user permitted always use")
            case .authorizedWhenInUse:
                print("user permitted when in use")
            default:
                break
        }
    }
}



