//
//  ViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2021/11/25.
//

import UIKit

class MainViewController: UIViewController  {
    
    let tableView = UITableView()
    let titleLable = UILabel()
    var safeArea: UILayoutGuide!
    let cellID = "cell"
    
    var characters = ["Open a map", "", "", ""]
    
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
        print(view.safeAreaInsets.top)
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
            print("\(#function) open a map")
            let mapVC = MapViewController()
            mapVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(mapVC, animated: true)
            //self.navigationController?.present(mapVC, animated: true, completion: nil)
        default:
            print("\(#function) no options")
        }
        
        
    }
}



