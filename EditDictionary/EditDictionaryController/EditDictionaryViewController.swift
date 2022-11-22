//
//  EditDictionaryViewController.swift
//  EditDictionary
//
//  Created by LAP15335 on 17/11/2022.
//

import UIKit

protocol EditDictionaryDelegate : AnyObject {
    func changedData(data: [String : Any]?)
}

protocol EditDictionaryDataSource : AnyObject {
    func dictionaryData() -> [String : Any]
}

class EditDictionaryViewController: UIViewController {
    //Origin Data get From Another Controller
    private var listJson : [String : Any]? {
        didSet{
            if(listJson != nil){
                //Flatten Data
                var tmpKeyNode : KeyNode? = nil
                DataConverter.flattenJSONDictionary(listJson: listJson!, result: &dict, parentKey: &tmpKeyNode)
                
                //Convert to keys
                keys = Array(dict.keys)
            }
            else{
                print("You should set DataSource for EditDictionaryViewController by implement EditDictionaryDatasource")
            }
        }
    }
    
    //Dictionary after convert from Origin Data
    private var dict: [KeyNode : Any] = [ : ]
    
    //Array of keys get from listJson
    private var keys: [KeyNode]?
    
    private let searchController = UISearchController()
    private var editDictionaryView : EditDictionaryView?
    var dataCollectionView : UICollectionView!
    weak var delegate : EditDictionaryDelegate?
    weak var datasource : EditDictionaryDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get data from Datasource
        listJson = datasource?.dictionaryData()
        
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
        
        dict.forEach { (key: KeyNode, value: Any) in
            print(key.key)
            print(key.isArray)
        }
        print(rebaseDictionary(dictionary: dict))
        
        //delegate?.changedData(data: listJson)
        
        navigationController?.popViewController(animated: true)
    }
    
    func rebaseDictionary(dictionary d : [KeyNode : Any]) -> [String : Any]{
        var treeDict : TreeDict = TreeDict(listDict: [])
        
        var alreadyCheck : [[String]?]  = []
        d.forEach { (keyNode: KeyNode, value: Any) in
            if !alreadyCheck.contains(keyNode.parent){
                alreadyCheck.append(keyNode.parent)
                var dictSameParent : [String : Any] = [ : ]
                d.forEach { (keyNode2: KeyNode, value2: Any) in
                    if(keyNode2.parent == keyNode.parent){
                        
                        if (keyNode2.isArray){
                            let stringData : String = value2 as! String
                            dictSameParent[keyNode2.key] = (stringData.toJSON()) as? NSArray
                        }else{
                            dictSameParent[keyNode2.key] = value2}
                    }
                }
                treeDict.listDict.append(DictNode(parent: keyNode.parent, dict: dictSameParent))
            }
            
        }
        
        var result : [String : Any] = [:]
        
        treeDict.listDict.forEach { dictNode in
            if(dictNode.parent == nil){
                dictNode.dict.forEach { (key: String, value: Any) in
                    result[key] = value
                }
            }else{
                result[(dictNode.parent?.first)!] = dictNode.recursionCreateDict()
                }
        }

        return result
    }
    
}
//            alreadyCheck.append(parent)
//            guard let parent = keyNode.parent else{
//                if (keyNode.isArray){
//                    let stringData : String = value as! String
//                    dict[keyNode.key] = (stringData.toJSON()) as? NSArray
//                }else{
//                    dict[keyNode.key] = value}
//                return
//            }
//            if(!parent.isEmpty){
//                count = count + 1
//                result.listDict.append(DictNode(pa: count, dict: dict))
//                dict = [ keyNode.key : "" ]
//            }
 //       }
//        d.forEach { (keyNode: KeyNode, value: Any) in
//            guard let parent = keyNode.parent else{
//                if (keyNode.isArray){
//                    let stringData : String = value as! String
//                    result[keyNode.key] = (stringData.toJSON()) as? NSArray
//                }else{
//                    result[keyNode.key] = value}
//                return
//            }
//            if(!parent.isEmpty){
//                setValueToLeaf(node: &result, keyNode: keyNode, value: value, numsParent: keyNode.parent!.count )
//            }
//        }
//        var result : [String : Any] = [ : ]
//        d.forEach { (keyNode: KeyNode, value: Any) in
//            guard let parent = keyNode.parent else{
//                if (keyNode.isArray){
//                    let stringData : String = value as! String
//                    result[keyNode.key] = (stringData.toJSON()) as? NSArray
//                }else{
//                    result[keyNode.key] = value}
//                return
//            }
//            if(!parent.isEmpty){
//                setValueToLeaf(node: &result, keyNode: keyNode, value: value, numsParent: keyNode.parent!.count )
//            }
//        }
//    }
    
//    func setValueToLeaf(node : inout [String : Any], keyNode: KeyNode, value : Any, numsParent: Int){
//        if(numsParent == 0){
//            node[keyNode.key] = value
//        }else{
//            let parentKey : String = keyNode.parent![keyNode.parent!.count - numsParent]
//            node[parentKey] as! [String : Any]
//            setValueToLeaf(node: &node[parentKey], keyNode: keyNode, value: value, numsParent: numsParent - 1)
//        }
//    }
   




//MARK: Cell Delegate
extension EditDictionaryViewController : DictionaryCellDelegate {
    func textViewDidChange(keyNode: KeyNode, value: Any) {
        dict[keyNode] = value
    }
}

//MARK: Search Controller
extension EditDictionaryViewController : UISearchResultsUpdating, UISearchBarDelegate {
    //Get Data on Keyword
    func updateSearchResults(for searchController: UISearchController) {
        //Hiding when user touch to searchbar, now we use Save Button of SearchBar
        navigationItem.rightBarButtonItem?.isHidden = true
        
        guard let text = searchController.searchBar.text else{
            return
        }
        
        getDataOnKeyword(keyword: text)
    }
    
    func getDataOnKeyword(keyword: String){
      
        let result = dict.filter { (keyNode, value) in
            keyNode.key.lowercased().contains(keyword.lowercased())
        }
        
        if(keyword.isEmpty){
            self.keys = Array(dict.keys)
        }else{
            self.keys = Array(result.keys)
        }
        
        self.dataCollectionView.reloadData()
    }
    
    //Save data
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let dictionary = listJson else{
            return
        }
        
        delegate?.changedData(data: dictionary)

        //Because there is 2 ViewController : Edit + Search
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }

}

//MARK: CollectionView DataSource
extension EditDictionaryViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keys?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if let dictionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dictionaryCell", for: indexPath) as? DictionaryCell {
            
            dictionCell.config(keyNode: keys![indexPath.item], value: dict[keys![indexPath.item]] ?? "")
            dictionCell.delegate = self
            cell = dictionCell
        }
        
        return cell
    }
    
    
}

//MARK: CollectionView Delegate
extension EditDictionaryViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let calculatedHeightValue = String(describing: dict[keys![indexPath.item]]).height(withConstrainedWidth: collectionView.frame.size.width * 2/3 - Constant.padding, font: Constant.Text.font)
        
        let calculatedHeightKey = Helper.generateString(keyNode: keys![indexPath.item]).height(withConstrainedWidth: collectionView.frame.size.width * 1/3 - Constant.padding , font: Constant.Text.font)
        
        return CGSize(width: collectionView.frame.size.width, height: calculatedHeightKey > calculatedHeightValue ? calculatedHeightKey + Constant.padding * 2 : calculatedHeightValue + Constant.padding * 2)
    }

}
