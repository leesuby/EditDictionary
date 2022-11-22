//
//  DataConverter.swift
//  EditDictionary
//
//  Created by LAP15335 on 22/11/2022.
//

import Foundation

enum JSONDataType{
    case number
    case string
    case json
    case array
    case null
}

class DataConverter{
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    //Using to convert dictionary and cast data to datatype of Json (__NSCFNumber, __NSCFString...)
    static func convertToJsonData(dic: [String : Any], completion : @escaping ([String : Any]) -> ()){
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            
            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            if let dictFromJSON = decoded as? [String:Any] {
                completion(dictFromJSON)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func flattenJSONDictionary(listJson: [String : Any], result: inout [KeyNode: Any], parentKey: inout KeyNode?){
        
        listJson.forEach { (key: String, value: Any) in
            switch value{
            case is NSDictionary: //(JSON type)
                if (parentKey != nil){
                    parentKey?.parent?.append(key)
                    flattenJSONDictionary(listJson: value as! [String : Any], result: &result,parentKey: &parentKey)
                }
                else{
                    var keyNodeRecursion : KeyNode? = KeyNode(parent: [])
                    keyNodeRecursion?.parent?.append(key)
                    flattenJSONDictionary(listJson: value as! [String : Any], result: &result, parentKey: &keyNodeRecursion)
                }
            case is NSArray: // Nếu kiểu Array chắc em vẫn để là String
                if(parentKey != nil){
                    parentKey?.key = key
                    result[parentKey!] = value
                }else{
                    let keyNodeResult = KeyNode(key: key)
                    result[keyNodeResult] = value
                }
            default:
                if(parentKey != nil){
                    parentKey?.key = key
                    result[parentKey!] = value
                }else{
                    let keyNodeResult = KeyNode(key: key)
                    result[keyNodeResult] = value
                }
            }
        }
    }
}
