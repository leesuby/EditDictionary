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
    //List Data get From Another Controller
    private var listJson : [String : Any]? {
        didSet{
            if(listJson != nil){
                keys = Array(listJson!.keys)}
            else{
                print("You should set DataSource for EditDictionaryViewController by implement EditDictionaryDatasource")
            }
        }
    }
    
    //Array of keys get from listJson
    private var keys: [String]?
    
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
    
        Helper.convertToJsonData(dic: dictionary) { result in
            self.delegate?.changedData(data: result)
        }
        
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
        guard let dictionary = listJson else{
            return
        }

        let result = dictionary.filter { (key, value) in
            key.lowercased().contains(keyword.lowercased())
        }
        
        if(keyword.isEmpty){
            self.keys = Array(dictionary.keys)
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

        Helper.convertToJsonData(dic: dictionary) { result in
            self.delegate?.changedData(data: result)
        }
    
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
            
            dictionCell.config(key: keys![indexPath.item], value: listJson?[keys![indexPath.item]] ?? "")
            dictionCell.delegate = self
            cell = dictionCell
        }
        
        return cell
    }
    
    
}

//MARK: CollectionView Delegate
extension EditDictionaryViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let calculatedHeight = String(describing: listJson?[(self.keys![indexPath.item])]).height(withConstrainedWidth: collectionView.frame.size.width * 2/3, font: Constant.Text.font)
        return CGSize(width: collectionView.frame.size.width, height: calculatedHeight + Constant.padding*2)
    }

}
