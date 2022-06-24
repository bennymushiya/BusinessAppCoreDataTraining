//
//  MainController.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 06/05/2022.
//

import UIKit
import CoreData

private let reuseIdentifier = "cell"

class CompaniesController: UITableViewController {
    
    //MARK: - PROPERTIES
    
    private lazy var headerView = CompaniesHeader(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.bubble.fill"), for: .normal)
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(handleReset), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var doWorkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Nested Updates", for: .normal)
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(handleNestedUpdates), for: .touchUpInside)
        
        return button
    }()
    
    
    //empty array
    private var companies = [Company]()
    
    //MARK: - LIFECYCLE
    
    // usaully we need to reload our table when fetching data but because where under viewdidLoad it automaticly reloads itself at the end of its caled function.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
                
    }
    
    //MARK: - HELPERS
    
    func configureUI() {
        
        view.backgroundColor = .white
        
        // fetches all the companies.
        self.companies = CoreDataManager.shared.fetchCompanies()

        tableView.register(CompaniesCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // changes the color of the lines separator underneath each cell.
        tableView.separatorColor = .white
        tableView.tableHeaderView = headerView
        
        configureNavigation(title: "")
        navigationItem.title = "Companies"
        
        let addButton = UIBarButtonItem(customView: plusButton)
        navigationItem.rightBarButtonItem = addButton
        
        let resetButton = UIBarButtonItem(customView: resetButton)
        let WorkButton = UIBarButtonItem(customView: doWorkButton)
        
        navigationItem.leftBarButtonItems = [resetButton, WorkButton]
        
        
        APIServices.shared.getRequest()
        
    }
    
    //MARK: - API
    
    func fetchCompanies() {

        let context = CoreDataManager.shared.persistanceContainer.viewContext

        // the entity name needs to be the same as the name of the model, so it knows eactly which data its fetching.
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")

        do {

            // fetches the information we have saved
           let companies = try context.fetch(fetchRequest)

            companies.forEach { names in

                print(names.name)
            }
            
            print("successfully fetch the data")
            // we assign the array full of companies to our company
            self.companies = companies
            self.tableView.reloadData()

        } catch let error {

            print("failed to fetch company \(error.localizedDescription)")
        }
    }
    
    
    // deletes data from core data
    func deleteData(company: Company) {
        
        // even though this deletes the data from core data it doesnt persists the changes
        let context = CoreDataManager.shared.persistanceContainer.viewContext
        context.delete(company)
        
        
        // this block of code below makes the changes persists.
        do {
            
            try context.save()

        } catch let error {
            
            print("failed to delete company \(error.localizedDescription)")
            return
        }
        
    }

    
    //MARK: - ACTION
    
    
    @objc private func handleNestedUpdates() {
        
        // where operating on thhe background thread
        DispatchQueue.global(qos: .background).async {
            
            // we'll try to perform our updates
            
            // we'll first construct a custom MOC
            
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            
            privateContext.parent = CoreDataManager.shared.persistanceContainer.viewContext
            
            // execute updates on privateContext now
            
            // always specifying what type of request it is.
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            
            // only fetching the first company in the list
            request.fetchLimit = 1
            
            do {
                
                let companies = try privateContext.fetch(request)
                
                companies.forEach { companyy in
                    
                    print(companyy.name ?? "")
                    
                    companyy.name = "D: \(companyy.name ?? "")"
                }
                
                do {
                    
                    try privateContext.save()
                    
                    // after save succeeds we go to the main thread and reload the tableView so it can show
                    DispatchQueue.main.async {
                        
                        do {
                            
                            let context = CoreDataManager.shared.persistanceContainer.viewContext
                            
                            if context.hasChanges {
                                
                                try context.save()
                            }
                        } catch let finalSaveError {
                            
                            print("failed to save on the main context \(finalSaveError)")
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                } catch let error {
                    
                    print("failed to save on private context \(error)")
                }
                

            } catch let error {
                
                print("DEBUGG: FAILED TO FETCH ON PRIVATE CONTEXT \(error)")
            }
            
            
        }
            
            
        
    }
    
    @objc private func handleUpdates() {
        
        // we dont want to access the company array property we have because they were fetched on the main thread and here we are on a different thread/a background thread.
        CoreDataManager.shared.persistanceContainer.performBackgroundTask { backgroundContext in
            
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            
            do {
                
                let companies = try backgroundContext.fetch(request)
                
                companies.forEach { company in
                    
                    // this is nill corloacing, meaning if the company name is nill we turn it into an empty string
                    print(company.name ?? "")
                    company.name = "C: \(company.name ?? "")"
                }
                
                do {
                    
                    try backgroundContext.save()
                    
                    // lets try to update the UI after the save by accessing the main thread
                    DispatchQueue.main.async {
                        
                        // you dont want to refetch everything if all your doing is updating one or two companies
                        self.companies = CoreDataManager.shared.fetchCompanies()
                        self.tableView.reloadData()
                    }
                    
                } catch let error {
                    
                    print("failed to update on background \(error)")
                }

            } catch let error {
                
                print("failed to do do just that broo so chill \(error) ")
            }
            
        }
        
    }
    
    
    // creates new companies on a background thread so it doesnt disturb the UI
    @objc private func handleWork() {
        
        // helps us create companies on perfom background task on another thread to prevent the UI from glitching, because were not performing the task on the same thread. and we dont need dispatch que on this becuase it auto runs on the background by itself.
        CoreDataManager.shared.persistanceContainer.performBackgroundTask { backgroundContext in
            
            // generates an array then we loop through it
            (0...5).forEach { value in
                print(value)
                
                let company = Company(context: backgroundContext)
                company.name = String(value)
            }
            
            do {
                
                try backgroundContext.save()
                
                // any code i run inside this closure will be executed on the main thread
                DispatchQueue.main.async {
                    
                    // because im calling it on the main thread and fetching the companies and reloading the data here. the companies will apear straight away when called
                    self.companies = CoreDataManager.shared.fetchCompanies()
                    self.tableView.reloadData()
                }
                
            } catch {
                
                print("failed broo ")
            }
        }
        
        // GCD - Grand Central Dispatch
        
        DispatchQueue.global(qos: .background).async {
            
            // creating some company objects on a background thread
            
           // let context = CoreDataManager.shared.persistanceContainer.viewContext
            
        }
        
       
    }
    
    // deletes all of the companies created
    @objc private func handleReset() {
      
        // this context correlates with the main thread, so whenever we call this function we are calling it on the main thread.
        let context = CoreDataManager.shared.persistanceContainer.viewContext
        
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
            
            
            companies.removeAll()
            tableView.deleteRows(at: indexPathsToRemove, with: .left)
//            companies.removeAll()
//            tableView.reloadData()

        } catch {
            
            print("failed to delete everything broo")
        }
        
    }
    
    @objc private func handleAdd() {
        
        let controller = CreateCompanyController()
        
        // we establish a link between the two controllers so we can access their properties 
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
        
    }
    
    // removes data from tableView
    func removeDataFromTableView(indexPath: IndexPath, company: Company) {
        
        self.companies.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
    }
    
//    func didEditCompany(company: Company) {
//
//
//    }
    
    //configures edit company controller with a companys detail
    func configureEditCompany(indexPath: IndexPath) {
        
        let controller = CreateCompanyController()
        controller.company = companies[indexPath.row]
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
        
    }
    
    
    
}


//MARK: - UITableViewDataSource

extension CompaniesController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return companies.count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CompaniesCell
        
        cell.viewModel = CompaniesViewModel(companies: companies[indexPath.row])
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.text = "no companies available"
        label.textColor =  .black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        return label
    }
    
    // if the carray above count is 0 then we return the size of the footer to 150 else its 0
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return companies.count == 0 ? 150 : 0
    }
}

//MARK: - UITableViewDelegate

extension CompaniesController {
    
    // this is how we add swipe functionlity to each cell.
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let company = self.companies[indexPath.row]

        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
                        
            // remove the company from our tableView
            self.removeDataFromTableView(indexPath: indexPath, company: company)
            
            // delete company from core data
            self.deleteData(company: company)
            
            
        }
        
        deleteAction.backgroundColor = .red
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { action, indexPath in
            
            self.configureEditCompany(indexPath: indexPath)
            
        }
        
        editAction.backgroundColor = .blue
        
        return [deleteAction, editAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let company = self.companies[indexPath.row]
        let controller = EmployeesController()
        controller.company = company
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

//MARK: - CreateCompanyControllerDelegate

extension CompaniesController: CreateCompanyControllerDelegate {
    
    // update my tableView somehow

    func didEditCompany(company: Company) {
        
        // returns the first index of a specific company appears in the collection
        guard let row = companies.index(of: company) else {return}
        
        let reloadIndexPath = IndexPath(row: row, section: 0)
        
        tableView.reloadRows(at: [reloadIndexPath], with: .middle)
        
    }
    
    func didConfigureCompany(company: Company) {
        
        // modify our array
        companies.append(company)
        
        // insert a new index path into tableview
        
        let newIndexPath = IndexPath(row: companies.count - 1, section: 0)
        
        // takes in an array of index paths. and adds it to the tableView
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        
    }
}
