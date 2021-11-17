//
//  ViewController.swift
//  Assignment5
//
//  Created by Andrew Vijay on 17/11/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var toDoItems:[Item]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        
        let toDoItem = self.toDoItems?[indexPath.row]
        
        cell.textLabel?.text = toDoItem?.toDo
        
        return cell
    }
    
    func fetchToDoItem(){
        do{
            self.toDoItems = try context.fetch(Item.fetchRequest())
            
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
            
        }
        catch{
            print("Error")
        }
    }

    @IBAction func PlusTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Write an Item"
        }
        
        let okButton = UIAlertAction(title: "OK", style: .default) { (action) in
            
            let toDoItemTextField = alert.textFields![0]
            
            //Create a To Do List Item
            let newToDoItem = Item(context: self.context)
            newToDoItem.toDo = toDoItemTextField.text
            //Save the data
            
            do{
                try self.context.save()
            }
            catch {
                print("Error in saving data")
            }
            
            self.fetchToDoItem()
            
            //Refetch the data
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.context.delete((self.toDoItems?[indexPath.row])!)
            
            do{
                try self.context.save()
            }
            catch {
                print("Error in saving data")
            }
            
            self.fetchToDoItem()
            
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

