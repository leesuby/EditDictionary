//
//  EditDictionaryView.swift
//  EditDictionary
//
//  Created by LAP15335 on 17/11/2022.
//

import Foundation
import UIKit

class EditDictionaryView {
    weak var viewController : EditDictionaryViewController?
    
    init(vc: EditDictionaryViewController? = nil) {
        self.viewController = vc
        
        initView()
        initConstraint()
    }
    
    func initView(){
        guard let vc = viewController else{
            return
        }
        
        vc.view.backgroundColor = .white
        
        vc.dataCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        vc.dataCollectionView.backgroundColor = .white
    }
    
    func initConstraint(){
        guard let vc = viewController else{
            return
        }
        
        vc.view.addSubview(vc.dataCollectionView)
        vc.dataCollectionView.translatesAutoresizingMaskIntoConstraints = false
        vc.dataCollectionView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor).isActive = true
        vc.dataCollectionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: Constant.padding).isActive = true
        vc.dataCollectionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -Constant.padding).isActive = true
        vc.dataCollectionView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor).isActive = true
    }
}
