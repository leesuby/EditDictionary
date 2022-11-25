//
//  EditDictionaryViewController.swift
//  EditDictionary
//
//  Created by LAP15335 on 17/11/2022.
//

import UIKit

protocol EditDictionaryDelegate : AnyObject {
    func changedData(result: [String : Any]?, error : String?)
}

protocol EditDictionaryDataSource : AnyObject {
    func dictionaryData() -> [String : Any]
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
                
                //Convert to keys
                keys = Array(dict.keys)
            }
            else{
                error = "DATASOURCE NOT FOUND: EditDictionaryDatasource is not conform"
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
        if(self.error != nil){
            delegate?.changedData(result: nil, error: self.error)
        }
        else{
            updateJSON(dictionary: dict)
            delegate?.changedData(result: self.listJson, error: self.error)
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
        guard listJson != nil else{
            return
        }
        
        if(self.error != nil){
            delegate?.changedData(result: nil, error: self.error)
        }
        else{
            updateJSON(dictionary: dict)
            delegate?.changedData(result: listJson, error: self.error)
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
    
    //MARK: REBASE Data
    func rebaseDictionary(dictionary d : [KeyNode : Any]) -> [String : Any]{
        var result : [String : Any] = [:]
        let familyTree : [[String]] = getFamilyTree(dictionary: d)
        let listOfParent : [[String]?] = getListofParent(dictionnary: d)
        result = generateGenerationTree(dictionary: d, familyTree: familyTree, generations: listOfParent, family: nil)
        return result
    }
    
    //MARK: GET generation tree by using
    func generateGenerationTree(dictionary d : [KeyNode : Any], familyTree : [[String]], generations : [[String]?], family : [String]?, iterator : Int = 0) -> [String : Any]{
        var generation : [String : Any] = [:]
        var flagHaveChild : Bool = false
        
        //Pass all Value which is not Dictionary
        d.forEach { (keyNode: KeyNode, value: Any) in
            if (keyNode.parent == family){
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
                    generation[keyNode.key] = data
                }else{
                    generation[keyNode.key] = value}
            }
            
            guard let keyNodeParent = keyNode.parent,
                  let familyParent = family else{
                return
            }
            
            if( keyNodeParent.count > familyParent.count && keyNodeParent.contains(familyParent)){
                flagHaveChild = true
            }
        }
        
        //Recursion if check Family Tree exist family wasn't add
        if(iterator < familyTree.count && (flagHaveChild || family == nil) ){
            for gene in familyTree[iterator]{
                var flagContain : Bool = false
                var tmpFamily : [String]
                if(family != nil){
                    tmpFamily = family!
                }else{
                    tmpFamily = []
                }
                tmpFamily.append(gene)
                generations.forEach { result in
                    guard let res = result else{
                        return
                    }
                    
                    if(res.count >= tmpFamily.count && Helper.checkStringContainsOrder(a: res, b: tmpFamily)){
                        flagContain = true
                    }
                }
                
                if(flagContain || family == nil){
                    generation[gene] = generateGenerationTree(dictionary: d, familyTree: familyTree, generations: generations, family: tmpFamily, iterator: iterator + 1)}
            }
        }
        
        return generation
    }
    
    //MARK: GET Matrix of parent
    func getFamilyTree(dictionary d: [KeyNode : Any]) -> [[String]]{
        var familyTree : [[String]] = []
        let generations: Int = getGenerations(dictionary: d)
        
        for gene in 0..<generations{
            var leaf : [String] = []
            d.forEach { (key: KeyNode, value: Any) in
                guard let parent = key.parent,
                      parent.count > gene,
                      !leaf.contains(parent[gene]) else{
                    return
                }
                leaf.append(parent[gene])
            }
            familyTree.append(leaf)
        }
        
        return familyTree
    }
    
    //MARK: GET generation of family tree
    func getGenerations(dictionary d: [KeyNode : Any]) -> Int{
        var generations: Int = 0
        d.forEach { (key: KeyNode, value: Any) in
            guard let parent = key.parent else{
                return
            }
            
            generations = parent.count >= generations ? parent.count : generations
        }
        return generations
    }
    
    //MARK: GET list of parent
    func getListofParent(dictionnary d: [KeyNode : Any]) -> [[String]?]{
        let arrayOfDictionaryHaveSameFamily : TreeDict = groupingDataSameFamily(dictionary: d)
        var listParent : [[String]?] = []
        arrayOfDictionaryHaveSameFamily.listDict.forEach { dictNode in
            listParent.append(dictNode.parent)
        }
        return listParent
    }
    
    
    ///DEPRECATED: OLD REBASE METHOD
    ///WORKS WELL except case json{{json,json},json,json}
    ///Maybe fix in future
    func firstMethod(dictionary d: [KeyNode : Any]) -> [String : Any]{
        //STEP 1: GROUPING data have same family ([parent] = [parent]) -> TreeDict
        let arrayOfDictionaryHaveSameFamily : TreeDict = groupingDataSameFamily(dictionary: d)
        
        //STEP 2: GROUPING data have same subset family set ([parent] containt ORDER [parent]) -> [TreeDict]
        let arrayOfArrayOfDictionaryHaveSameParentSubset : [TreeDict] = groupingDataSameParentSubset(treeBaseDict: arrayOfDictionaryHaveSameFamily)
        
        //STEP 3: GENERATE array of Dictionary from GROUPED data
        let arrayOfDictionaryResult : [[String: Any]] = generateDictionaryFromGroupedData(groupedData: arrayOfArrayOfDictionaryHaveSameParentSubset)
    
        //STEP 4: GET Result
        let result : [String : Any] = convertArrayDictionaryToDictionary(arrayDictionnary: arrayOfDictionaryResult, arrayDataHaveSameFamily: arrayOfDictionaryHaveSameFamily)
        
        return result
    }
    
    
    //MARK: GROUP data which have same family
    func groupingDataSameFamily(dictionary d : [KeyNode : Any]) -> TreeDict{
        let treeBaseDict : TreeDict = TreeDict(listDict: [])
        var alreadyCheckParent : [[String]?]  = []
        d.forEach { (keyNode: KeyNode, value: Any) in
            if !alreadyCheckParent.contains(keyNode.parent){
                alreadyCheckParent.append(keyNode.parent)
                var dictSameParent : [String : Any] = [ : ]
                d.forEach { (keyNode2: KeyNode, value2: Any) in
                    if(keyNode2.parent == keyNode.parent){
                        if (keyNode2.isArray){
                            guard let value2 = value2 as? String else{
                                self.error = "ERROR DATATYPE: \(Helper.generateString(keyNode: keyNode2)) value can't cast to String"
                                return
                            }
                            let stringData : String = value2
                            
                            guard let data = (stringData.toJSON()) as? NSArray else{
                                self.error = "ERROR DATATYPE: \(Helper.generateString(keyNode: keyNode2)) value can't cast to NSArray. Please check again input JSON Array"
                                return
                            }
                            dictSameParent[keyNode2.key] = data
                        }else{
                            dictSameParent[keyNode2.key] = value2}
                    }
                }
                treeBaseDict.listDict.append(DictNode(parent: keyNode.parent, dict: dictSameParent))
            }
            
        }
        return treeBaseDict
    }
    
    //MARK: GROUP data have same parent subset
    func groupingDataSameParentSubset(treeBaseDict: TreeDict) -> [TreeDict]{
        var listTreeDictSameSubsetParent : [TreeDict] = []
        var alreadyCheckSubsetParent : [[String]] = []
        treeBaseDict.listDict.forEach { dictNode in
            guard let parentToCompare = dictNode.parent else{
                self.error = "ERROR 100: Contact Longnct to fix this"
                return
            }
            var flagContain: Bool = false
            alreadyCheckSubsetParent.forEach { parent in
                if(Helper.checkStringContainsOrder(a: parentToCompare, b: parent)){
                    flagContain = true
                }
            }
            
            if(flagContain){
                return
            }
            
            alreadyCheckSubsetParent.append(parentToCompare)
            
            let treeSameSubsetParent : TreeDict = TreeDict(listDict: [])
            treeBaseDict.listDict.forEach { nodeCheckSameSubsetParent in
                guard let parentNode = nodeCheckSameSubsetParent.parent else{
                    self.error = "ERROR 101: Contact Longnct to fix this"
                    return
                }
                if(Helper.checkStringContainsOrder(a: parentToCompare, b: parentNode)) {
                    treeSameSubsetParent.listDict.append(nodeCheckSameSubsetParent)
                }
            }
            listTreeDictSameSubsetParent.append(treeSameSubsetParent)
        }
        return listTreeDictSameSubsetParent
    }
    
    //MARK: GENERATE dictionary from grouped data
    func generateDictionaryFromGroupedData(groupedData: [TreeDict]) -> [[String : Any]]{
        var listFinalDict : [[String : Any]] = [[:]]
        groupedData.forEach { treeDict in
            let dictMerge : [String : Any] = treeDict.recursionCreateDict(parentMaxLength: treeDict.getMaxLengthParent())
            listFinalDict.append(dictMerge)
        }
        return listFinalDict
    }
    
    func convertArrayDictionaryToDictionary(arrayDictionnary : [[String: Any]], arrayDataHaveSameFamily : TreeDict) -> [String : Any]{
        var result : [String : Any] = [:]
        
        arrayDictionnary.forEach { dict in
            let keys = Array(dict.keys)
            if keys.isEmpty{
                return
            }
            result[keys[0]] = dict[keys[0]]
        }
        
        arrayDataHaveSameFamily.listDict.forEach { dictNode in
            if(dictNode.parent == nil){
                dictNode.dict.forEach { (key: String, value: Any) in
                    result[key] = value
                }
            }
        }
        return result
    }
    
    @discardableResult
    func finalDict(baseDict : inout [String:Any], leafDict : [String : Any],parent: [String], iterator: Int = 0) -> [String : Any]{
        if(parent.count == iterator){
            return leafDict
        }else{
            var resultDict: [String : Any] = [:]
            resultDict[parent[iterator]] = finalDict(baseDict: &resultDict, leafDict: leafDict, parent: parent, iterator: iterator + 1)
            return resultDict
        }
        
    }
}
