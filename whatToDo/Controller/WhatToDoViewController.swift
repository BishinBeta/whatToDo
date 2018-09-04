//
//  ViewController.swift
//  whatToDo
//
//  Created by Biswajit Sarker on 8/16/18.
//  Copyright © 2018 UnHunch. All rights reserved.
//

import UIKit
import RealmSwift

class WhatToDoViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    
    var selectedCategory: Category?{
        didSet{
            loadData()
        }
    }
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    // User's defaults Database
    // let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        loadData()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
//        if let items = defaults.array(forKey: "ToDoListArray") as? [String] {
//            itemArray = items
//        }
    }


    //MARK: - Tableview DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let currentItem = todoItems?[indexPath.row]{
            
            cell.textLabel?.text = currentItem.title
            
            if currentItem.done == true {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
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
    
    // self.defaults.set(self.itemArray, forKey: "ToDoListArray")
    
//    func saveItems(item: Item) {
//
//        do {
//            try realm.write {
//                realm.add(item)
//            }
//        } catch {
//            print("Error Saving Realm: \(error)")
//        }
//
//        tableView.reloadData()
//    }
//
    func loadData(){

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
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
        
        
        
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadData(with: request,predicate: predicate)
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
