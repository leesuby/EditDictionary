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
    case null
}

protocol DictionaryCellDelegate{
    func textViewDidChange(keyNode: KeyNode, value: Any)
}

class DictionaryCell: UICollectionViewCell, UITextViewDelegate {
    
    var itemsNumber : Int?
    private var keyLabel : UILabel!
    private var valueTextView : UITextView!
    private var typeOfValue : EditDataType?
    var delegate : DictionaryCellDelegate?
    var keyNode : KeyNode?

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
        keyLabel.numberOfLines = 0
        
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
        //Valid JSON datatypes: number, string, array(String), bool -> __NSCFNumber, __NSCFString
        let value : Any!
    
        switch typeOfValue{
        case .number:
            if(valueTextView.text.isDouble()){
                value = NSNumber(value: Double(valueTextView.text) ?? 0)
            }
            else{
                return
            }
            
        case .string:
            if(valueTextView.text.elementsEqual("null")){
                value = NSNull()}
            else{
                value = NSString(string: valueTextView.text)}
            
        case .null:
            // Case: Ban đầu là Null nhưng sau đó chỉnh sửa thành số hay chữ khác.
            if(valueTextView.text.isDouble()){
                value = NSNumber(value: Double(valueTextView.text) ?? 0)
            }
            else{
                value = NSString(string: valueTextView.text)}
        case .none:
            value = nil
        }
        
        delegate?.textViewDidChange(keyNode: self.keyNode!, value: value ?? "")
        
    }
    
    func config(keyNode: KeyNode, value: Any){
        keyLabel.text = Helper.generateString(keyNode: keyNode)
        self.keyNode = keyNode
        switch value{
        case is NSNumber:
            typeOfValue = .number
        case is NSNull:
            typeOfValue = .null
        default:
            typeOfValue = .string
        }
        valueTextView.text = String(describing: value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error while create DictionaryCell")
    }
    
}
