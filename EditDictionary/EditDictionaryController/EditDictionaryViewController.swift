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
        guard let dictionary = listJson else{
            return
        }
    
        delegate?.changedData(data: dictionary)
        
        navigationController?.popViewController(animated: true)
    }
   
}



//MARK: Cell Delegate
extension EditDictionaryViewController : DictionaryCellDelegate {
    func textViewDidChange(key: String, value: Any) {
        listJson?[key] = value
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
        
        let calculatedHeightValue = String(describing: dict[keys![indexPath.item]]).height(withConstrainedWidth: collectionView.frame.size.width * 2/3, font: Constant.Text.font)
        
        let calculatedHeightKey = keys![indexPath.item].key.height(withConstrainedWidth: collectionView.frame.size.width * 1/3, font: Constant.Text.font)
        
        return CGSize(width: collectionView.frame.size.width, height: calculatedHeightKey > calculatedHeightValue ? calculatedHeightKey + Constant.padding*2 : calculatedHeightValue + Constant.padding*2)
    }

}
