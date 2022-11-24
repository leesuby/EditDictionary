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
          "items":
              {
                "Long" : {
                    "Name" : "longnct"
                },
                "An" : {
                    "Name" : "annct",
                    "test" : {
                                "Long" : {
                                    "Name" : "longnct"
                                },
                                "An" : {
                                    "Name" : "annct"

                                }
                    }
                }
              },
        "Long":
                {
                    "Name" : 12121313,
                    "batter":
                        [
                            { "id": "1001", "type": "Regular" },
                            { "id": "1002", "type": "Chocolate" },
                            { "id": "1003", "type": "Blueberry" },
                            { "id": "1004", "type": "Devil's Food" }
                        ]

                    },
        "muahahaha" : 122121212,
        "onononono" : "123123123123123"
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

//        """
//      {
//          "items":
//              {
//                  "item":
//                          {
//                              "id": "0001",
//                              "type": "donut",
//                              "name": "Cake",
//                              "ppu": 0.55,
//                              "batters":
//                                  {"haha" : 1213,
//                                    "id" : 123123123123123123123,
//                                    "batter":
//                                          [
//                                              { "id": "1001", "type": "Regular" },
//                                              { "id": "1002", "type": "Chocolate" },
//                                              { "id": "1003", "type": "Blueberry" },
//                                              { "id": "1004", "type": "Devil's Food" }
//                                          ],
//                                    "long": {
//                                        "name" : "long",
//                                        "aasdasd" : "asdasda"
//                                    },
//                                    "an": {
//                                        "name":  "an"
//                                    }
//                                  },
//                              "topping":
//                                  [
//                                      { "id": "5001", "type": "None" },
//                                      { "id": "5002", "type": "Glazed" },
//                                      { "id": "5005", "type": "Sugar" },
//                                      { "id": "5007", "type": "Powdered Sugar" },
//                                      { "id": "5006", "type": "Chocolate with Sprinkles" },
//                                      { "id": "5003", "type": "Chocolate" },
//                                      { "id": "5004", "type": "Maple" }
//                                  ],
//                                      "batter":
//                                          [
//                                              { "id": "1001", "type": "Regular" },
//                                              { "id": "1002", "type": "Chocolate" },
//                                              { "id": "1003", "type": "Blueberry" },
//                                              { "id": "1004", "type": "Devil's Food" }
//                                          ]
//                          }
//              },
//        "Long":
//                {
//                    "Name" : 12121313,
//                    "batter":
//                        [
//                            { "id": "1001", "type": "Regular" },
//                            { "id": "1002", "type": "Chocolate" },
//                            { "id": "1003", "type": "Blueberry" },
//                            { "id": "1004", "type": "Devil's Food" }
//                        ]
//
//                    },
//        "muahahaha" : 122121212,
//        "onononono" : "123123123123123"
//      }
//"""
