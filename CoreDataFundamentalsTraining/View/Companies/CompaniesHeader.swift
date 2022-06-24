//
//  MainHeader.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 06/05/2022.
//

import UIKit


class CompaniesHeader: UIView {
    
    //MARK: - PROPERTIES
    
    private let image: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.2.fill")
        iv.setDimensions(height: 34, width: 34)
        iv.tintColor = .black
        
        return iv
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
        
        return label
    }()
    
    
    //MARK: - LIFECYCLE
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - HERLPERS
    
    func configureUI() {
        
        backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [image, headerLabel])
        stack.axis = .horizontal
        stack.spacing = 20
        
        addSubview(stack)
        stack.centerY(inView: self)
        stack.anchor(left: leftAnchor, paddingLeft: 10)
        
    }
    
    
    //MARK: - ACTION
    
    
}

    
    

