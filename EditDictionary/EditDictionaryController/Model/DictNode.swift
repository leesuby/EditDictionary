//
//  DictNode.swift
//  EditDictionary
//
//  Created by LAP15335 on 22/11/2022.
//

import Foundation

class DictNode{
    var parent : [String]?
    var dict : [String : Any]
    
    init(parent: [String]?, dict: [String : Any]) {
        self.parent = parent
        self.dict = dict
    }
    
    @discardableResult
    func recursionCreateDict(iterator: Int = 1) -> [String : Any]{
        var result: [String : Any] = [:]
        if(iterator == parent!.count){
            return dict
        }
        else{
            result[parent![iterator]] = recursionCreateDict(iterator: iterator + 1)
            return result
        }
        
    }
}
