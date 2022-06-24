//
//  CreateCompanyHeader.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 06/05/2022.
//

import UIKit

protocol CreateCompanyHeaderDelegate: AnyObject {
    
    func didClickOnImageView()
    
}

class CreateCompanyHeader: UIView {
    
    
    //MARK: - PROPERTIES
    
    var viewModel: CreateCompanyViewModel? {
        
        didSet{configureCreateViewModel()}
    }
    
    weak var delegate: CreateCompanyHeaderDelegate?
    
     lazy var companyImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo.circle")
        iv.tintColor = .black
        iv.setDimensions(height: 104, width: 104)
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFit
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto))
        iv.addGestureRecognizer(tapGesture)
        
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    
    //MARK: - LIFECYCLE
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - HELPERS
    
    func configureUI() {
        
        backgroundColor = .green
        
        addSubview(companyImageView)
        companyImageView.centerX(inView: self)
        companyImageView.anchor(top: topAnchor, paddingTop: 20)
    }
    
    
    //MARK: - ACTION
    
    func configureCreateViewModel() {
        
        guard let viewmodels = viewModel else {return}
        
        
        guard let imageData = viewmodels.logoImage else {return}
        companyImageView.image = UIImage(data: imageData)
    }
    
    @objc func handleSelectPhoto() {
        
        delegate?.didClickOnImageView()
    }
}
