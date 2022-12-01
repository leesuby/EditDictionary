//
//  EditDictionaryViewController.swift
//  EditDictionary
//
//  Created by LAP15335 on 17/11/2022.
//

import UIKit

protocol EditDictionaryDelegate : AnyObject {
    func editDictionary(resultAfterEdit result: [String : Any]?, error : String?)
}

protocol EditDictionaryDataSource : AnyObject {
    func editDictionary(dataForEdit data: [String : Any]) -> [String : Any]
}

class EditDictionaryViewController: UIViewController {
    private var error : String?
    //Origin Data get From Another Controller
    private var listJson : [String : Any]? {
        didSet{
            if(listJson != nil){
                //Flatten Data
                var tmpKeyNode : KeyNode? = nil
                flattenJSONDictionary(listJson: listJson!, result: &dict, parentKey: &tmpKeyNode)
                
                //Sort and get to keys
                sortKey(dictionary: self.dict)
            }
            else{
                error = "DATASOURCE NOT FOUND: EditDictionaryDatasource is not conform"
            }
        }
    }
    
    //Dictionary after convert from Origin Data
    private var dict: [KeyNode : Any] = [ : ]
    
    //Array of keys get from listJson
    private var keys: [KeyNode] = []
    private var sortKeys: [KeyNode] = []
    
    private let searchController = UISearchController()
    private var editDictionaryView : EditDictionaryView?
    var dataCollectionView : UICollectionView!
    weak var delegate : EditDictionaryDelegate?
    weak var datasource : EditDictionaryDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get data from Datasource
        listJson = datasource?.editDictionary(dataForEdit: [:])
        
        //Init View and Constraint
        editDictionaryView = EditDictionaryView(vc: self)
        
        //Setting CollectionView
        dataCollectionView.delegate = self
        dataCollectionView.dataSource = self
        dataCollectionView.register(DictionaryCell.self, forCellWithReuseIdentifier: "dictionaryCell")
        
        //Setting SearchController
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.setValue("Save", forKey: "cancelButtonText")
        
        //Setting Navigation
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
    }
    
    @objc func saveTapped(){
        guard listJson != nil else{
            return
        }
        if(self.error != nil){
            delegate?.editDictionary(resultAfterEdit: nil, error: self.error)
        }
        else{
            updateJSON(dictionary: dict)
            delegate?.editDictionary(resultAfterEdit: self.listJson, error: self.error)
        }
        navigationController?.popViewController(animated: true)
    }
}

//MARK: Cell Delegate
extension EditDictionaryViewController : DictionaryCellDelegate {
    func raiseError(error: String) {
        self.error = error
    }
    
    func textViewDidChange(keyNode: KeyNode, value: Any) {
        dict[keyNode] = value
    }
}

//MARK: Search Controller
extension EditDictionaryViewController : UISearchResultsUpdating, UISearchBarDelegate {
    //Get Data on Keyword
    func updateSearchResults(for searchController: UISearchController) {
        //Hiding when user touch to searchbar, now we use Save Button of SearchBar
        if #available(iOS 16.0, *) {
            navigationItem.rightBarButtonItem?.isHidden = true
        } else {
            // Fallback on earlier versions
            navigationItem.rightBarButtonItem = nil
        }
        
        guard let text = searchController.searchBar.text else{
            return
        }
        
        getDataOnKeyword(keyword: text)
    }
    
    func getDataOnKeyword(keyword: String){
        
        let result = sortKeys.filter { keyNode in
            keyNode.key.lowercased().contains(keyword.lowercased())
        }
        
        if(keyword.isEmpty){
            self.keys = sortKeys
        }else{
            self.keys = Array(result)
        }
        
        self.dataCollectionView.reloadData()
    }
    
    //Save data
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard listJson != nil else{
            return
        }
        
        if(self.error != nil){
            delegate?.editDictionary(resultAfterEdit: nil, error: self.error)
        }
        else{
            updateJSON(dictionary: dict)
            delegate?.editDictionary(resultAfterEdit: self.listJson, error: self.error)
        }
        
        //Because there is 2 ViewController : Edit + Search
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: CollectionView DataSource
extension EditDictionaryViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if let dictionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dictionaryCell", for: indexPath) as? DictionaryCell {
            
            dictionCell.config(keyNode: keys[indexPath.item], value: dict[keys[indexPath.item]] ?? "")
            dictionCell.delegate = self
            cell = dictionCell
        }
        
        return cell
    }
}

//MARK: CollectionView Delegate
extension EditDictionaryViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let calculatedHeightValue = String(describing: dict[keys[indexPath.item]]).height(withConstrainedWidth: collectionView.frame.size.width * 2/3 - Constant.padding, font: Constant.Text.font)
        
        let calculatedHeightKey = Helper.generateString(keyNode: keys[indexPath.item]).height(withConstrainedWidth: collectionView.frame.size.width * 1/3 - Constant.padding , font: Constant.Text.font)
        
        return CGSize(width: collectionView.frame.size.width, height: calculatedHeightKey > calculatedHeightValue ? calculatedHeightKey + Constant.padding * 2 : calculatedHeightValue + Constant.padding * 2)
    }
    
}

//MARK: Update JSON
extension EditDictionaryViewController{
    func updateJSON(dictionary d : [KeyNode : Any]){
        d.forEach { (keyNode: KeyNode, value: Any) in
            let keyPaths : KeyPath = KeyPath(Helper.generateString(keyNode: keyNode))
            if (keyNode.isArray){
                guard let value = value as? String else{
                    self.error = "ERROR DATATYPE: \(Helper.generateString(keyNode: keyNode)) value can't cast to String"
                    return
                }
                let stringData : String = value
                
                guard let data = (stringData.toJSON()) as? NSArray else{
                    self.error = "ERROR DATATYPE: \(Helper.generateString(keyNode: keyNode)) value can't cast to NSArray. Please check again input JSON Array"
                    return
                }
                self.listJson![keyPath: keyPaths] = data
            }else{
                self.listJson![keyPath: keyPaths] = value}
        }
    }
    
    func sortKey(dictionary d : [KeyNode : Any]){
        let keyArray = Array(d.keys)
        let listParent = getListParent(listKey: keyArray)
        listParent.forEach { parents in
            keyArray.forEach { keyNode in
                if(keyNode.parent == parents && !self.keys.contains(keyNode)){
                    sortKeys.append(keyNode)
                }
            }
        }
        self.keys = sortKeys
    }
    
    func getListParent(listKey list : [KeyNode]) -> [[String]?]{
        var listParent : [[String]?] = []
        var counting : Int = 0, iterator : Int = 0
        while(counting != list.count){
            counting = 0
            list.forEach { keyNode in
                if(keyNode.parent == nil && iterator == 0 && !listParent.contains(keyNode.parent)){
                    listParent.append(keyNode.parent)
                }else{
                    guard let parent = keyNode.parent else{
                        counting = counting + 1
                        return
                    }
                    if(parent.count == iterator && !listParent.contains(parent)){
                        listParent.append(parent)
                    }else{
                        counting = counting + 1
                    }
                }
            }
            iterator = iterator + 1
        }
        return listParent
    }
    
}

//MARK: Method to REBASE and FLATTEN json
extension EditDictionaryViewController{
    //MARK: FLATTEN data
    func flattenJSONDictionary(listJson: [String : Any], result: inout [KeyNode: Any], parentKey: inout KeyNode?){
        
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
                //inout parentKey: recursion maybe change, set to Default
            case is NSArray:
                if(parentKey != nil){
                    parentKey?.key = key
                    parentKey?.isArray = true
                    result[parentKey!] = DataConverter.json(from: value)
                    
                }else{
                    var keyNodeResult = KeyNode(key: key)
                    keyNodeResult.isArray = true
                    result[keyNodeResult] = DataConverter.json(from: value)
                }
                
                parentKey?.isArray = false
                //inout parentKey: recursion maybe change, set to Default
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
