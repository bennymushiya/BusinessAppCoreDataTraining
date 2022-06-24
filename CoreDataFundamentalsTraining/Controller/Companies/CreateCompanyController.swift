//
//  CreateCompanyController.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 06/05/2022.
//

import UIKit
import CoreData


protocol CreateCompanyControllerDelegate: AnyObject {
    
    func didConfigureCompany(company: Company)
    func didEditCompany(company: Company)
    
}

class CreateCompanyController: UITableViewController {
    
    
    //MARK: - PROPERTIES
    
    
    var company: Company? {
        didSet {
            
            nameTextField.text = company?.name
            
            guard let founded = company?.founded else {return}
            datePicker.date = founded
                        
        }
        
    }
    
    weak var delegate: CreateCompanyControllerDelegate?
    
    private lazy var headerView = CreateCompanyHeader(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 200))
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        
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
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        return picker
    }()
    
   private let imagePicker = UIImagePickerController()

    
    
    //MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureUI()
        fetchHeaderImage()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = company == nil ? "Create Company" : "Edit Company"
        configureNavigation(title: "")
    }
    
    //MARK: - HELPERS
    
    func configureUI() {
        
        
        configureNavigation(title: "")
        tableView.backgroundColor = UIColor.darkGray
        
        configureCancelButton()
        navigationItem.title = "Create Company"
        
        let button = UIBarButtonItem(customView: saveButton)
        //let cancel = UIBarButtonItem(customView: cancelButton)
        //navigationItem.leftBarButtonItem = cancel
        navigationItem.rightBarButtonItem = button
        tableView.tableHeaderView = headerView
        headerView.delegate = self
        imagePicker.delegate = self
        
        tableView.addSubview(nameLabel)
        nameLabel.anchor(top: headerView.bottomAnchor, left: tableView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        
        tableView.addSubview(nameTextField)
        nameTextField.anchor(top: headerView.bottomAnchor, left: nameLabel.rightAnchor, right: tableView.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 5)
        
        tableView.addSubview(datePicker)
        datePicker.centerX(inView: tableView)
        datePicker.anchor(top: nameTextField.bottomAnchor, left: tableView.leftAnchor, paddingTop: 10, paddingLeft: 10)
        
        
    }
    
    //MARK: - API

    // upload information to core data
    func uploadData() {
        
        let context = CoreDataManager.shared.persistanceContainer.viewContext
        
        // the entity name needs to match the name of whatever is put on the coreData model entity name
        let company = NSEntityDescription.insertNewObject(forEntityName: "Company", into: context)
        
        // we add self to avoid a retain cycle
        guard let name = nameTextField.text else {return}
        
        // the company object has a property called name, so here we are setting the value of that property.
        company.setValue(name, forKey: "name")
        company.setValue(datePicker.date, forKey: "founded")
        
        
        guard let companyImage = headerView.companyImageView.image else {return}
        
        // becuase core data cant take in uiiImage, we change this property into binary data that core data can take in.
        let imageData =  companyImage.jpegData(compressionQuality: 0.8)

        company.setValue(imageData, forKey: "imageData")
        
            //perform the save
        
        do {
            
            try context.save()
            
            //successs
            
            // it dismisses before the code inside has completed, enabling us to view the animation on the tableView//
            dismiss(animated: true) {
                
                // we have to downcast it because company is an NSobject, whihc is the same as the other company
                self.delegate?.didConfigureCompany(company: company as! Company)
            }
            
            print("successfully saved data")
            
        } catch let error {
            
            print("failed to save company \(error.localizedDescription)")
        }
        
    }
    
    // saves the updates/edits we make on the already created company
    func saveCompanyChanges() {
        
        let context = CoreDataManager.shared.persistanceContainer.viewContext
        
        // by assigning the textField text to the company name property, it means whatever we write on the textfield or edit will be assigned to the company name after we save changes.
        company?.name = nameTextField.text
        company?.founded = datePicker.date
        
        guard let companyImage = headerView.companyImageView.image else {return}
        
        // becuase core data cant take in uiiImage, we change this property into binary data that core data can take in.
        let imageData =  companyImage.jpegData(compressionQuality: 0.8)

        company?.imageData = imageData
        
        
        do {
            
            try context.save()
            
            //save succeeded
            dismiss(animated: true) {
                self.delegate?.didEditCompany(company: self.company!)
                
            }

        } catch let error {
            
            print("failed to save broo \(error)")
        }
        
        
    }
    
    func fetchHeaderImage() {
        
        guard let companies = company else {return}
        headerView.viewModel = CreateCompanyViewModel(companies: companies)
        
    }
    
    
    
    //MARK: - ACTION
    
//    @objc func handleCancel() {
//
//        dismiss(animated: true, completion: nil)
//    }
    
    @objc func handleSave() {
          
        switch company == nil {
    
        case true:
            uploadData()
            
        case false:
            saveCompanyChanges()
        }
            
    }
        
}
    

//MARK: - CreateCompanyHeaderDelegate

extension CreateCompanyController: CreateCompanyHeaderDelegate {
    
    
    func didClickOnImageView() {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}


//MARK: - UICollectionViewDelegateFlowLayout

extension CreateCompanyController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // collects the image the user chose as a key value pair
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        headerView.companyImageView.image = selectedImage
        
        headerView.companyImageView.layer.cornerRadius = 104 / 2
        
        // without this the corner radius wont work
        headerView.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
