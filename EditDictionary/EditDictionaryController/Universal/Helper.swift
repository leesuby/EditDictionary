//
//  Helper.swift
//  EditDictionary
//
//  Created by LAP15335 on 17/11/2022.
//

import Foundation
import UIKit

class Helper{
    static func generateString(keyNode : KeyNode) -> String{
        guard let parentsKey = keyNode.parent else{
            return keyNode.key
        }
        var result: String = ""
        
        parentsKey.forEach { parent in
            result.append("\(parent).")
        }
        
        result.append(keyNode.key)
        
        return result
    }
    
    static func checkStringContainsOrder(a: [String], b: [String]) -> Bool{
        let minimumCount : Int = a.count >= b.count ? b.count : a.count
        
        for i in 0..<minimumCount{
            if(!a[i].elementsEqual(b[i])){
                return false
            }
        }
        print("----------------------")
        print(a)
        print(b)
        return true
    }

}
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    var isBool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y":
            return true
        case "false", "f", "no", "n", "":
            return false
        default:
            if let int = Int(self) {
                return int != 0
            }
            return nil
        }
    }
    
    
    func isInt() -> Bool {
        
        if Int(self) != nil {
            return true
        }
        
        return false
    }
    
    
    
    func isDouble() -> Bool {
        
        if Double(self) != nil {
            return true
        }
        
        return false
    }
    

    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
   
}
