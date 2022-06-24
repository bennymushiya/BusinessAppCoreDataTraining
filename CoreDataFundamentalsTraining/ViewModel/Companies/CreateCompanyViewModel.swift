//
//  CreateCompanyViewModel.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 09/05/2022.
//

import UIKit


struct CreateCompanyViewModel {
    
    
    
    var companies: Company
    
    
    var logoImage: Data? {
        
        return companies.imageData
    }
    
    
    init(companies: Company) {
        self.companies = companies
        
    }
    
    
}
