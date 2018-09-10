//
//  ViewController.swift
//  whatToDo
//
//  Created by Biswajit Sarker on 8/16/18.
//  Copyright © 2018 UnHunch. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class WhatToDoViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    
    var selectedCategory: Category?{
        didSet{
            loadData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
            loadData()
    }


    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        
        
        guard let colorHex = selectedCategory?.bgcolor else {fatalError()}
        
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    
    func updateNavBar(withHexCode colorHex: String){
        
        guard let navbar = navigationController?.navigationBar else {fatalError()}
        guard let navbarcolor = UIColor(hexString: colorHex) else {fatalError()}
        
        navbar.barTintColor = navbarcolor
        navbar.tintColor = ContrastColorOf(navbarcolor, returnFlat: true)
        navbar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navbarcolor, returnFlat: true)]
        
        searchBar.barTintColor = navbarcolor
    }
    
    
    //MARK: - Tableview DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let currentItem = todoItems?[indexPath.row]{
            
            cell.textLabel?.text = currentItem.title
            
            if let color = UIColor(hexString: selectedCategory!.bgcolor)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            if currentItem.done == true {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            //cell.backgroundColor = UIColor(hexString: selectedCategory!.bgcolor)
        } else {
            cell.textLabel?.text = "No Items Added"
        }

        return cell
        
    }
    
    //MARK: - TableView delegate Methods
    
    // Get the selected Row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status: \(error)")
            }
            
        }
        
        tableView.reloadData()
        
        // Deselect row with animation
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    // MARK : - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            print("added!")
            
            if textField.text != "" {
                
                if let currentCategory = self.selectedCategory{
                    
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error saving data: \(error)")
                    }
                    
                }
                
                self.tableView.reloadData()
            }
            
        }
        
  
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "What's the plan?"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert,animated: true, completion: nil)
    }
    

    func loadData(){

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
        }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let currentItem = todoItems?[indexPath.row] {
            
            do{
                try realm.write {
                    realm.delete(currentItem)
                }
            } catch {
                print("Error deleting item:\(error)")
            }
        }
        }
        
        
    
}

// MARK: - Search Bar methods

extension WhatToDoViewController : UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
       
        if let textToSearch = searchBar.text{
            if textToSearch != ""{
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", textToSearch).sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
            }
        }
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
