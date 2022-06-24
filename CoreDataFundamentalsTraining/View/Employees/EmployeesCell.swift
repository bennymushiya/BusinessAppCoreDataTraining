//
//  EmployeesCell.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 09/05/2022.
//

import UIKit


class EmployeesCell: UITableViewCell {
    
    //MARK: - PROPERTIES
    
    var viewModel: EmployeesViewModel? {
        didSet{configureEmployeesViewModel()}
        
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "company name"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
        
        return label
    }()
    
    //MARK: - LIFECYCLE
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - HELPERS
    
    func configureUI() {
        
        backgroundColor = .blue
        
        addSubview(nameLabel)
        nameLabel.centerY(inView: self)
        nameLabel.anchor(left: leftAnchor, paddingLeft: 20)
        
    }
    
    
    
    //MARK: - ACTION
    
    
    func configureEmployeesViewModel() {
        
        guard let viewModels = viewModel else {return}
        
        nameLabel.text = "\(viewModels.name)     \(viewModels.birthday)"
    }
  
}
