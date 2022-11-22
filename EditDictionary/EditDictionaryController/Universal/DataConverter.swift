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
                    var keyRecursion : KeyNode? = KeyNode(parent: (parentKey?.parent)!)
                    flattenJSONDictionary(listJson: value as! [String : Any], result: &result, parentKey: &keyRecursion)
                    
                }
                else{
                    var keyNodeRecursion : KeyNode? = KeyNode(parent: [])
                    keyNodeRecursion?.parent?.append(key)
                    flattenJSONDictionary(listJson: value as! [String : Any], result: &result, parentKey: &keyNodeRecursion)
                }
                parentKey?.parent?.removeLast()
                //Vì inout sử dụng tham chiếu parentKey nên sau khi đệ quy có thể thay đổi, quay lui về set Default
            case is NSArray: 
                if(parentKey != nil){
                    parentKey?.key = key
                    parentKey?.isArray = true
                    result[parentKey!] = json(from: value)
                    
                }else{
                    var keyNodeResult = KeyNode(key: key)
                    keyNodeResult.isArray = true
                    result[keyNodeResult] = json(from: value)
                }
                
                parentKey?.isArray = false
                //Vì inout sử dụng tham chiếu parentKey nên sau khi đệ quy có thể thay đổi, quay lui về set Default
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

    static func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}
