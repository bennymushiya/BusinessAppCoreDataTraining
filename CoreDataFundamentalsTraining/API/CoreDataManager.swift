//
//  CoreDataManager.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 06/05/2022.
//

import UIKit
import CoreData

// will live forever as long as your application is still alive, its properties will too
struct CoreDataManager {
    
    // this shared is an instance of this class and as static wherever we are in our code we can access it, but everytime we do access it we will be creating a single instance of this struct, so reusing the same structure over and over.
    static let shared = CoreDataManager()
    
    // this is basically the over model and we have objects inside this model
    let persistanceContainer: NSPersistentContainer = {
        
        // this needs to match with the name of the coreData model you created
        let container = NSPersistentContainer(name: "CompanyModel")

        container.loadPersistentStores { storeDescription, error in
             
            if let error = error {
                
                fatalError("loading of error failed \(error)")
                
            }
         }
        
        return container
    }()
    
    
    func fetchCompanies() -> [Company] {
        
        let context = persistanceContainer.viewContext
        
        // the entity name needs to be the same as the name of the model, so it knows eactly which data its fetching.
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        
        do {
            
            // fetches the information we have saved
           let companies = try context.fetch(fetchRequest)
            
            return companies
                
        } catch let error {
            
            print("failed to fetch company \(error.localizedDescription)")
            return []
        }
    
    }
    
    
    func resetCompanyList(companies: [Company], indexPathsToRemove: [IndexPath]) {
        
        let context = persistanceContainer.viewContext
        
        companies.forEach { company in
            context.delete(company)
        }
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Company.fetchRequest())
        
        do {
            
            try context.execute(batchDeleteRequest)

            // upon deletion from core data succeeded
            
            
            // removes it with an effect
            var indexPathsToRemove = [IndexPath]()
            
            for (index, _) in companies.enumerated() {
                
                let indexPath = IndexPath(row: index, section: 0)
                indexPathsToRemove.append(indexPath)
            }
            
            
            //companies.removeAll()
//            tableView.deleteRows(at: indexPathsToRemove, with: .left)
//            companies.removeAll()
//            tableView.reloadData()

        } catch {
            
            print("failed to delete everything broo")
        }
        
    }
    
    // here we return a tuple  and create an employee
    func createEmployee(employeeName: String, birthday: Date, employeType: String, company: Company) -> (Employee?, Error?) {
        
        let context = persistanceContainer.viewContext
        
        //create an employee
        let employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as! Employee
        
        employee.setValue(employeeName, forKey: "name")
        
        // the employee we create we set/assign them to a specific company so they belong to a single company.
        employee.company = company
        employee.type = employeType
        
        // we create an employeeInformation, then downcast it to employee information object
        let employeeInformation = NSEntityDescription.insertNewObject(forEntityName: "EmployeeInformation", into: context) as! EmployeeInformation
        
        // we set the taxid property here
        employeeInformation.taxId = "456"
        employeeInformation.birthday = birthday
        
        // then we assign the employee information we created above to the actaul employee information
        employee.employeeInformation = employeeInformation
        
        
        
        do {
            
            try  context.save()
            // save succeceded
            return (employee, nil)

        } catch let error {
            
            print("failed to create employeee '\(error)")
            
            return (nil, error)
        }
    }
    
}
