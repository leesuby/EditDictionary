//
//  DictionaryCell.swift
//  EditDictionary
//
//  Created by LAP15335 on 17/11/2022.
//

import UIKit


protocol DictionaryCellDelegate{
    func textViewDidChange(key: String, value: Any)
}

class DictionaryCell: UICollectionViewCell, UITextViewDelegate {
    
    var itemsNumber : Int?
    private var keyText : UILabel!
    private var valueText : UITextView!
    private var typeOfValue : Any.Type?
    var delegate : DictionaryCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
        initConstraint()
    }
    
    func initView(){
        keyText = UILabel()
        keyText.textColor = Constant.Text.color
        keyText.textAlignment = .right
        keyText.font = Constant.Text.font
        
        valueText = UITextView()
        valueText.textColor = Constant.Text.color
        valueText.font = Constant.Text.font
        valueText.layer.borderColor = UIColor.black.cgColor
        valueText.layer.borderWidth = 1
        valueText.delegate = self
    }
    
    func initConstraint(){
        addSubview(keyText)
        keyText.translatesAutoresizingMaskIntoConstraints = false
        keyText.topAnchor.constraint(equalTo: topAnchor, constant: Constant.padding).isActive = true
        keyText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.padding).isActive = true
        keyText.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3).isActive = true
        keyText.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constant.padding).isActive = true
        
        addSubview(valueText)
        valueText.translatesAutoresizingMaskIntoConstraints = false
        valueText.topAnchor.constraint(equalTo: topAnchor).isActive = true
        valueText.leadingAnchor.constraint(equalTo: keyText.trailingAnchor, constant: Constant.padding).isActive = true
        valueText.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 2/3 ,constant: -(2*Constant.padding)).isActive = true
        valueText.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let key = keyText.text?.dropLast(1) ?? ""
        
        //Valid JSON datatypes: number, string, array(String), bool -> __NSCFNumber, __NSCFString
        let value : Any!
        if valueText.text.isDouble {
            value = Double(valueText.text)
        }else if valueText.text.isInt{
            value = Int(valueText.text)
        } else if let bool = valueText.text.isBool{
            value = bool
        } else {
            value = valueText.text
        }
        
        delegate?.textViewDidChange(key: String(key), value: value ?? "")
        
    }
    
    func config(key: String, value: Any){
        keyText.text = "\(key):"
        typeOfValue = type(of: value)
        valueText.text = String(describing: value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error while create DictionaryCell")
    }
    
}
