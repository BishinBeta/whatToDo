//
//  CategoryViewController.swift
//  whatToDo
//
//  Created by Biswajit Sarker on 8/24/18.
//  Copyright © 2018 UnHunch. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    
    // MARK: - Wait for View to be Loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print File Path for debugging
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.rowHeight = 80.0
        loadData()

    }
    
    // MARK: - Table View Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added"
        return cell
    }

    // MARK:- Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(categories?[indexPath.row].name)
        
        performSegue(withIdentifier: "goToItems", sender: self)

        //tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! WhatToDoViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
    }
    }
    
    
    
    //MARK: - Add button functionality to Add categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            print("Category Added!")
            
            if (textField.text != ""){
                let newCategory = Category()
                newCategory.name = textField.text!
                
                self.saveData(category: newCategory)
                self.tableView.reloadData()
            }
            
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "What's the Category?"
            textField = alertTextField
        }
        present(alert,animated: true)
    }
    
    //MARK:- Save Data in Persistance Storage
    
    func saveData(category: Category){
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving Data : \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(){
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
}

extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            if let categoryForDeletion = self.categories?[indexPath.row]{
                
                do{
                    try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                    }
                } catch {
                    print("Error deleting category: \(error)")
                }
                
                //tableView.reloadData()
            }
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}

