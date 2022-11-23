//
//  NumberTextView.swift
//  EditDictionary
//
//  Created by LAP15335 on 23/11/2022.
//

import UIKit

class NumberTextView: UITextView {

    func textView(_ textField: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }

}
