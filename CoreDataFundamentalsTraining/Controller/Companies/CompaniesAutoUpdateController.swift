//
//  CompaniesAutoUpdateController.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 14/05/2022.
//

import UIKit
import CoreData

private let reuseIdentifier = "cell id"

class CompaniesAutoUpdateController: UITableViewController {
    
    //MARK: - PROPERTIES
    
    // warning this code is going to be abit of a monster
    
    // helps you guage when things occur inside of core data so it can be update instantly in real time, like snapshot listener in firebase
    lazy var fetchResultController: NSFetchedResultsController<Company> = {
        
        let context = CoreDataManager.shared.persistanceContainer.viewContext
        
        // always tell the type of fetch request and object you want to fetch
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        
        // returns the fetch request in alphabetical order
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true) ]
        
        
        // lets you create sections aswel
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        
        do {
            
            try frc.performFetch()
            
        } catch let error {
            
            print("faiedl to perform fetch in the monster \(error)")
        }
        
        // you cant specifying self inside a closure unless its a lazy var
        frc.delegate = self
        
        return frc
    }()
    
    
    
    //MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    
    
    //MARK: - HELPERS
    
    func configureUI() {
        
        view.backgroundColor = .white
        
        navigationItem.title = "Company Auto Updates"
        
        configureNavigation()
        
        configureNavigationLeftButton(selector: #selector(handleAdd))
        
        configureNavigationRightButton(selector: #selector(handleDelete))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        fetchResultController.fetchedObjects?.forEach({ company in
            
            print(" bo \(company.name ?? "")")
        })
        
    }
    
    
    //MARK: - ACTION
    
    @objc func handleAdd() {
        
        
        print("lets add a company called bmw")
        
        let context = CoreDataManager.shared.persistanceContainer.viewContext
        
        let company = Company(context: context)
        company.name = "alott"
        
        try? context.save()
    }
    
    // will delete all companies with the name b its case sensitive so whichever letter we choose will ve deleted
    @objc private func handleDelete() {
        
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        
        request.predicate = NSPredicate(format: "name CONTAINS %@", "b")
        
        let context = CoreDataManager.shared.persistanceContainer.viewContext
        
        let companiesWithB = try? context.fetch(request)
        
        companiesWithB?.forEach { company in
            context.delete(company)
        }
        
        try? context.save()
    }
    
}

//MARK: - UITableViewDataSource

extension CompaniesAutoUpdateController {
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchResultController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.text = fetchResultController.sectionIndexTitles[section]
        label.backgroundColor = .orange
        
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchResultController.sections![section].numberOfObjects
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        let company = fetchResultController.object(at: indexPath)
        
        cell.textLabel?.text = company.name
        
        return cell
    }
    
    
}


//MARK: - UITableViewDelegate

extension CompaniesAutoUpdateController {
    
    
    
    
    
}


//MARK: - NSFetchedResultsControllerDelegate

extension CompaniesAutoUpdateController: NSFetchedResultsControllerDelegate {
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        
        return sectionName
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .insert:
            
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            
        case .delete:
            
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            
        case .move:
            break
        case .update:
            break
        }
    }
    
    // gets called any time any updates add, delete or update happens inside core data.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    
        switch type {
        case .insert:
            
            tableView.insertRows(at: [newIndexPath!], with: .middle)

        case .delete:
            
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .move:
            break
        case .update:
            
            tableView.reloadRows(at: [indexPath!], with: .fade)
        }
        
    }
    
    
}
