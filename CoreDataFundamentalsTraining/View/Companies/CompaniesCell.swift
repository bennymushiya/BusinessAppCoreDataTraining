//
//  MainCell.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 06/05/2022.
//

import UIKit


class CompaniesCell: UITableViewCell {
    
    //MARK: - PROPERTIES
    
    var viewModel: CompaniesViewModel? {
        didSet{configureViewModel()}
        
    }
    
     let logoImage: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.setDimensions(height: 37, width: 37)
        iv.layer.cornerRadius = 37 / 2
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "company name"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        
        
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
    
    
    //MARK: - HERLPERS
    
    func configureUI() {
        
        backgroundColor = .orange
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        stack.axis = .horizontal
        stack.spacing = 30
        
        addSubview(logoImage)
        logoImage.centerY(inView: self)
        logoImage.anchor(left: leftAnchor, paddingLeft: 20)

        addSubview(stack)
        stack.centerY(inView: self)
        stack.anchor(left: logoImage.rightAnchor, paddingLeft: 20)
        
    }
    
    
    //MARK: - ACTION
    
    func configureViewModel() {
        
        guard let viewModels = viewModel else {return}
        
        titleLabel.text = viewModels.name
        dateLabel.text = viewModels.date
        
        guard let imageData = viewModels.logo else {return}
        
        logoImage.image = UIImage(data: imageData)
    }
    
}
