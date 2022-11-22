//
//  HomeView.swift
//  EditDictionary
//
//  Created by LAP15335 on 17/11/2022.
//

import Foundation
import UIKit

class HomeView{
    weak var vc : HomeViewController?
    var jsonData : UILabel!
    
    init(viewController: HomeViewController) {
        self.vc = viewController
        initView()
        initConstraint()
    }
    
    
    func initView(){
        vc!.view.backgroundColor = .white
        
        jsonData = UILabel()
        jsonData.font = Constant.Text.font
        jsonData.numberOfLines = 0
        jsonData.textColor = Constant.Text.color
        jsonData.text = """
      {
        "id": 1,
        "Information":{
            "title": "iPhone 9",
            "description": "An apple mobile which is nothing like apple",
            "category": "smartphones"
            },
        "price": 549,
        "rating": 4.69,
        "stock": 94,
        "thumbnail": "https://dummyjson.com/image/i/products/1/thumbnail.jpg",
        "images": [
          "https://dummyjson.com/image/i/products/1/1.jpg",
          "https://dummyjson.com/image/i/products/1/2.jpg",
          "https://dummyjson.com/image/i/products/1/3.jpg",
          "https://dummyjson.com/image/i/products/1/4.jpg",
          "https://dummyjson.com/image/i/products/1/thumbnail.jpg"
        ],
        "null": null
      }
"""
        
        
    }
    
    func initConstraint(){
        vc!.view.addSubview(jsonData)
        jsonData.translatesAutoresizingMaskIntoConstraints = false
        jsonData.topAnchor.constraint(equalTo: vc!.view.safeAreaLayoutGuide.topAnchor).isActive = true
        jsonData.leadingAnchor.constraint(equalTo: vc!.view.leadingAnchor, constant: Constant.padding).isActive = true
        jsonData.trailingAnchor.constraint(equalTo: vc!.view.trailingAnchor, constant: -Constant.padding).isActive = true
    }
    
    
}
