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
    
    static func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
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
}
