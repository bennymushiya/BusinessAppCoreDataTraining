//
//  CreateEmployeeController.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 09/05/2022.
//

import UIKit

protocol CreateEmployeeControllerDelegate: AnyObject {
    
    func didAddEmployee(employee: Employee)
    
}

class CreateEmployeeController: UIViewController {
    
    
    //MARK: - PROPERTIES

    var company: Company?
    
    weak var delegate: CreateEmployeeControllerDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        
        // enables autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "enter name"
        textfield.textColor = .white
        
        textfield.translatesAutoresizingMaskIntoConstraints = false
        
        return textfield
    }()
    
    private let birthdayLabel: UILabel = {
        let label = UILabel()
        label.text = "birthday"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        
        // enables autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let birthdayTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "MM/dd/yyyy"
        textfield.textColor = .white
        
        textfield.translatesAutoresizingMaskIntoConstraints = false
        
        return textfield
    }()
    
    private let employeeSegmentedControl: UISegmentedControl = {        
        let types = [EmployeeType.executive.rawValue, EmployeeType.senoirManagement.rawValue, EmployeeType.staff.rawValue]
        let sc = UISegmentedControl(items: types)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.backgroundColor = .green
        sc.tintColor = .blue
        
        // makes the index start at 0
        sc.selectedSegmentIndex = 0
        
        
        return sc
    }()
    
    //MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Create Employee"
        configureNavigation()
        
    }
    
    //MARK: - HELPERS
    
    func configureUI() {
        
        view.backgroundColor = .orange
    
        configureCancelButton()
        configureSaveButton(selector: #selector(handleSave))
        
        view.addSubview(nameLabel)
        nameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 10)
        
        view.addSubview(nameTextField)
        nameTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nameLabel.rightAnchor, paddingTop: 20, paddingLeft: 30)
        
        view.addSubview(birthdayLabel)
        birthdayLabel.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, paddingTop: 50, paddingLeft: 10)
        
        view.addSubview(birthdayTextfield)
        birthdayTextfield.anchor(top: nameTextField.bottomAnchor, left: birthdayLabel.rightAnchor, paddingTop: 55, paddingLeft: 30)
        
        view.addSubview(employeeSegmentedControl)
        employeeSegmentedControl.centerX(inView: view)
        employeeSegmentedControl.anchor(top: birthdayTextfield.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 10, paddingRight: 10)
    }
    
    
    
    //MARK: - ACTION
    
    // saving employees
    @objc private func handleSave() {
        
        guard let name = nameTextField.text else {return}
        
        guard let company = self.company else {return}
        
        // turn birthdayTextfield.text into date object
        
        guard let birthdayText = birthdayTextfield.text else {return}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        // if user enters the birthday format wrong we show an alert
        guard let birthdayDate = dateFormatter.date(from: birthdayText) else {
            
            showMessage(withTitle: "bade date", message: "enter the correct birthday format")
            return
        }
        
        // lets perform the validation step here
        if birthdayText.isEmpty {
            
            showMessage(withTitle: "empty birthday", message: "you have not entered a birthday")
            
        }
        
        // get the segmentedControl value
        guard let employeeType = employeeSegmentedControl.titleForSegment(at: employeeSegmentedControl.selectedSegmentIndex) else {return}
        
        
        // everytime we create an employee we set/assign them to specific company.
        let tuple = CoreDataManager.shared.createEmployee(employeeName: name, birthday: birthdayDate, employeType: employeeType, company: company)
        
        if let error = tuple.1 {
            
            // show error message
            
            showMessage(withTitle: "error", message: "\(error)")
            print(error)
        } else {
            
            //creation successs
            
            dismiss(animated: true) {
                
                // we'll call the delegate somehow
                self.delegate?.didAddEmployee(employee: tuple.0! )
                
            }
            

        }
    
    }
    
    
}
