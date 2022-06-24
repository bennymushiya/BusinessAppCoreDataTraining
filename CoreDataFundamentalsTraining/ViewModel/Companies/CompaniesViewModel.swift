//
//  CompaniesViewModel.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 06/05/2022.
//

import UIKit


struct CompaniesViewModel {
    
    var companies: Company
    
    var name: String? {
        
        return companies.name
    }
    
    var date: String? {
        
         if let name = companies.name, let founded = companies.founded {
            
             let dateFormatter = DateFormatter()
             dateFormatter.dateFormat = "MM dd, yyyy"
             
             let foundedDateString = dateFormatter.string(from: founded)
             
//             let locale = Locale(identifier: "EN")
             
             let dateString = "\(name) - founded: \(foundedDateString)"
            
         } else {
             
             companies.name
         }
        
        return "\(companies.founded)"
    }
    
    var logo: Data? {
        
        return companies.imageData
    }
    
    
    init(companies: Company) {
        self.companies = companies
        
    }
    
    
    
}
