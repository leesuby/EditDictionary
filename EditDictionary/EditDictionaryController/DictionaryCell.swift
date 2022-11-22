//
//  DictionaryCell.swift
//  EditDictionary
//
//  Created by LAP15335 on 17/11/2022.
//

import UIKit

enum EditDataType{
    case number
    case string
    
}

protocol DictionaryCellDelegate{
    func textViewDidChange(key: String, value: Any)
}

class DictionaryCell: UICollectionViewCell, UITextViewDelegate {
    
    var itemsNumber : Int?
    private var keyLabel : UILabel!
    private var valueTextView : UITextView!
    private var typeOfValue : EditDataType?
    var delegate : DictionaryCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
        initConstraint()
    }
    
    func initView(){
        keyLabel = UILabel()
        keyLabel.textColor = Constant.Text.color
        keyLabel.textAlignment = .right
        keyLabel.font = Constant.Text.font
        
        valueTextView = UITextView()
        valueTextView.textColor = Constant.Text.color
        valueTextView.font = Constant.Text.font
        valueTextView.layer.borderColor = UIColor.black.cgColor
        valueTextView.layer.borderWidth = 1
        valueTextView.delegate = self
    }
    
    func initConstraint(){
        addSubview(keyLabel)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constant.padding).isActive = true
        keyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.padding).isActive = true
        keyLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3).isActive = true
        keyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constant.padding).isActive = true
        
        addSubview(valueTextView)
        valueTextView.translatesAutoresizingMaskIntoConstraints = false
        valueTextView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        valueTextView.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor, constant: Constant.padding).isActive = true
        valueTextView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 2/3 ,constant: -(2*Constant.padding)).isActive = true
        valueTextView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let key = keyLabel.text?.dropLast(1) ?? ""
        
        //Valid JSON datatypes: number, string, array(String), bool -> __NSCFNumber, __NSCFString
        let value : Any!
    
        switch typeOfValue{
        case .number:
            if(valueTextView.text.isDouble()){
                value = NSNumber(value: Double(valueTextView.text) ?? 0)
            }
            else{
                //Case: User enter Character in Number Field
                return
            }
        case .string:
            value = NSString(string: valueTextView.text)
        case .none:
            value = nil
        }
        
        delegate?.textViewDidChange(key: String(key), value: value ?? "")
        
    }
    
    func config(key: String, value: Any){
        keyLabel.text = "\(key):"
        switch value{
        case is NSNumber:
            typeOfValue = .number
        default:
            typeOfValue = .string
        }
        valueTextView.text = String(describing: value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error while create DictionaryCell")
    }
    
}
