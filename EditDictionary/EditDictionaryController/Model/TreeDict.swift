//
//  TreeNode.swift
//  EditDictionary
//
//  Created by LAP15335 on 22/11/2022.
//

import Foundation

class TreeDict{
    var listDict : [DictNode]
    
    init(listDict: [DictNode]) {
        self.listDict = listDict
    }
    
    
    func getMaxLengthParent() -> [String]{
        var max = 0
        var parentMax : [String] = []
        listDict.forEach { dictNode in
            guard let parent = dictNode.parent else{
                return
            }
            if(parent.count > max){
                parentMax = parent
                max = parent.count
            }
        }
        return parentMax
    }
    
    func getListByLengthParent(length: Int) -> [DictNode]{
        var result : [DictNode] = []
        listDict.forEach { dictNode in
            guard let parent = dictNode.parent else{
                return
            }
            if(parent.count == length){
                result.append(dictNode)
            }
        }
        return result
    }
    
    @discardableResult
    func recursionCreateDict(result: inout [String : Any] ,iterator: Int = 0, parentMaxLength: [String]) -> [String : Any]{
        
        if(iterator == parentMaxLength.count){
            return result
        }
        else{
            var resultRecursion: [String : Any] = [:]
            let listByLength = getListByLengthParent(length: iterator + 1)
            if(listByLength.isEmpty){
                resultRecursion[parentMaxLength[iterator]] = recursionCreateDict(result: &resultRecursion,iterator: iterator + 1, parentMaxLength: parentMaxLength)
            }else{
                listByLength.forEach { dictNode in
                    guard dictNode.parent != nil else{
                        resultRecursion = dictNode.dict
                        return
                    }
                    result[parentMaxLength[iterator]] = recursionCreateDict(result: &dictNode.dict,iterator: iterator + 1, parentMaxLength: parentMaxLength)
                }
            }
            return resultRecursion
        }
    }
    
    
}
