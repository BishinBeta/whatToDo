//
//  CategoryViewController.swift
//  whatToDo
//
//  Created by Biswajit Sarker on 8/24/18.
//  Copyright © 2018 UnHunch. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Wait for View to be Loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print File Path for debugging
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadData()

    }
    
    // MARK: - Table View Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }

    // MARK:- Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(categoryArray[indexPath.row].name!)
        
        performSegue(withIdentifier: "goToItems", sender: self)

        //tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! WhatToDoViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray[indexPath.row]
    }
    }
    
    
    
    //MARK: - Add button functionality to Add categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            print("Category Added!")
            
            if (textField.text != ""){
                let newCategory = Category(context: self.context)
                newCategory.name = textField.text!
                self.categoryArray.append(newCategory)
                self.saveData()
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
    
    func saveData(){
        do {
            try context.save()
        } catch {
            print("Error saving Data : \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(from request: NSFetchRequest<Category> = Category.fetchRequest() ){
        
        do{
        categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching Data: \(error)")
        }
        
        tableView.reloadData()
    }
}

