//
//  EmployeesController.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 09/05/2022.
//

import UIKit
import CoreData

private let reuseIdentifier = "cell"


// creates a uilabel subclass for custom text drawing
class IndentedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
       // let customRect = UIEdgeInsetsInsetRect(rect: insets)
        //super.drawText(in: customRect)
        
    }
}

class EmployeesController: UITableViewController {
    
    
    //MARK: - PROPERTIES
    
    var company: Company?

    var employees = [Employee]()
    
    
    // putting multiple arrays into one array. known as twoDimensional array
    var allEmployees = [[Employee]]()
    
    // an array filled with the enum cases, we dont need to check anything we let this do all the work for us.
    var employeeType = [EmployeeType.executive.rawValue, EmployeeType.senoirManagement.rawValue, EmployeeType.staff.rawValue]
    
    //MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchEmployees()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = company?.name
        configureNavigation(title: "")
        
    }
    
    //MARK: - HELPERS
    
    func configureUI() {
        
        tableView.backgroundColor = .gray
        
        tableView.register(EmployeesCell.self, forCellReuseIdentifier: reuseIdentifier)
        configurePlussButtonInNavigationBar(selector: #selector(handleAdd))
    }
    
    
    //MARK: - API
    
    private func fetchEmployees() {
        
        // here we go into company and grab the whole nsset/array of employees and downcast it as an array of employees
        guard let companyEmployees = company?.employees?.allObjects as? [Employee] else {return}
        
    
        allEmployees = []
        
        // lets use my array and loop to filter instead
        employeeType.forEach { employeeType in
            
            //somehow construct my all employees array here and by appending it we put the saved employees inside.
            allEmployees.append(
            
                companyEmployees.filter({ $0.type == employeeType })
            
            )
        }
        
        tableView.reloadData()
        // lets filtier employees for executives
//        let executive = companyEmployees.filter { employee -> Bool in
//
//            return employee.type == EmployeeType.executive.rawValue
//        }
//
//        let senoirManagement = companyEmployees.filter { $0.type == EmployeeType.senoirManagement.rawValue }
//
//        let staff = companyEmployees.filter { $0.type == EmployeeType.staff.rawValue }
//
//
//        allEmployees = [executive, senoirManagement, staff]

    }

    //MARK: - ACTION
    
    @objc private func handleAdd() {
        
        let controller = CreateEmployeeController()
        controller.delegate = self
        
        // we pass in the company from this controller to that one, so we can save the company the emplpoyee belongs too.
        controller.company = company
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
        
    }
    
    func configureSectionHeaders(section: Int, label: UILabel) {
        
        label.backgroundColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        if section == 0 {
            
            label.text = EmployeeType.executive.rawValue
            
        } else if section == 1 {
            
            label.text = EmployeeType.senoirManagement.rawValue
            
        } else {
            
            label.text = EmployeeType.staff.rawValue
        }
        
    }
    
}

//MARK: - UITableViewDataSource

extension EmployeesController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return allEmployees.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allEmployees[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EmployeesCell
        
        // if we are section 0 then were gonna use shortname employees array because its the first array inside allEmployees array and onwards.
        cell.viewModel = EmployeesViewModel(employees: allEmployees[indexPath.section][indexPath.row])
        
        return cell
    }
    
}

//MARK: - UITableViewHeader

extension EmployeesController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        configureSectionHeaders(section: section, label: label)
       
        return label
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    
}

//MARK: - CreateEmployeeControllerDelegate

extension EmployeesController: CreateEmployeeControllerDelegate {
    
    func didAddEmployee(employee: Employee) {
        
        // we get which section we want to insert the row, so based on the employee type which index are we on
        guard let section = employeeType.index(of: employee.type!) else {return}
        
        // figure out what my row is, where i will be inserting the new employee.
        let row = allEmployees[section].count
        
        // we store the indexPath with its section and row here
        let insertionIndexPath = IndexPath(row: row, section: section)
        
        // we add the employee at a specific section
        allEmployees[section].append(employee)
        
        // inserts the employee at specific index
        tableView.insertRows(at: [insertionIndexPath], with: .middle)
        
    }
    
}
