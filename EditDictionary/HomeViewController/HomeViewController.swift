//
//  ViewController.swift
//  EditDictionary
//
//  Created by LAP15335 on 17/11/2022.
//

import UIKit

//Using for Testing
class HomeViewController: UIViewController{
    private var homeView : HomeView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init View and Constraint
        homeView = HomeView(viewController: self)
        
        //Setting Navigation
        settingNavigation()
    }
    
    func settingNavigation(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
    }
    
    
    //Edit button tapped
    @objc func editTapped(){
        let vc = EditDictionaryViewController()
        vc.datasource = self
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension HomeViewController: EditDictionaryDelegate{
    func changedData(result: [String : Any]?, error: String?) {
        result?.forEach({ (key: String, value: Any) in
//            print("---------")
//            print(key)
//            print(value)
        })
    }
}

extension HomeViewController: EditDictionaryDataSource{
    func dictionaryData() -> [String : Any] {
        return DataConverter.convertToDictionary(text: (self.homeView?.jsonData.text)!)!
    }
    
    
}
