//
//  ViewController.swift
//  whatToDo
//
//  Created by Biswajit Sarker on 8/16/18.
//  Copyright © 2018 UnHunch. All rights reserved.
//

import UIKit
import CoreData

class WhatToDoViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory: Category?{
        didSet{
            loadData()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let currentItem = itemArray[indexPath.row]
        
        cell.textLabel?.text = currentItem.title
        
        if currentItem.done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
        
    }
    
    //MARK: - TableView delegate Methods
    
    // Get the selected Row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // print(itemArray[indexPath.row])
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
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
                
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                
                self.saveItems()
                
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
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error Saving Context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@" , (selectedCategory!.name!))
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do{
            itemArray =  try context.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
        tableView.reloadData()
        }
    
}

// MARK: - Search Bar methods

extension WhatToDoViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadData(with: request,predicate: predicate)
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
