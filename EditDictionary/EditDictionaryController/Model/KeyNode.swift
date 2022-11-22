//
//  KeyNode.swift
//  EditDictionary
//
//  Created by LAP15335 on 22/11/2022.
//

import Foundation

struct KeyNode{
    var parent: [String]?
    var key: String = ""
    
    init(parent: [String]){
        self.parent = parent
    }
    
    init(key: String){
        self.key = key
    }
    
    init(){}
}

extension KeyNode: Hashable{}
