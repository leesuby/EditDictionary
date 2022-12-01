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
    private var originData : [String : Any]!
    
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
    func editDictionary(resultAfterEdit result: [String : Any]?, error: String?) {
        print(error)
        print(result)
    }
    
    
}

extension HomeViewController: EditDictionaryDataSource{
    func editDictionary(dataForEdit data: [String : Any]) -> [String : Any] {
        originData = DataConverter.convertToDictionary(text: (self.homeView?.jsonData.text)!)!
        return originData
    }
}
