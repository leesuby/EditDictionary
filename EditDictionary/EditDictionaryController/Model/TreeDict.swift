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
    
    func getDictByLengthParent(length: Int) -> DictNode?{
        var result : DictNode? = nil
        listDict.forEach { dictNode in
            guard let parent = dictNode.parent else{
                return
            }
            if(parent.count == length){
                result = dictNode
            }
        }
        return result
    }
    
    @discardableResult
    func recursionCreateDict(iterator: Int = 1, parentMaxLength: [String]) -> [String : Any]{
        var resultRecursion: [String : Any] = [:]
        
        if(iterator == parentMaxLength.count){
            let dictByLength = getDictByLengthParent(length: iterator)
            resultRecursion[parentMaxLength[iterator - 1]] = dictByLength!.dict
        }
        else{
            let dictByLength = getDictByLengthParent(length: iterator)
            if(dictByLength == nil){
                resultRecursion[parentMaxLength[iterator - 1]] = recursionCreateDict(iterator: iterator + 1, parentMaxLength: parentMaxLength)
            }else{
                let copyDict : DictNode = dictByLength!
                copyDict.dict.merge(recursionCreateDict(iterator: iterator + 1, parentMaxLength: parentMaxLength)) { (current, _) in
                    current
                }
                resultRecursion[parentMaxLength[iterator - 1]] = copyDict.dict
            }
        }
        return resultRecursion
    }
    
    
}


