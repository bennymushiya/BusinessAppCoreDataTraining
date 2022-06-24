//
//  APIServices.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 13/05/2022.
//

import UIKit
import CoreData

class APIServices {
    
    
    static let shared = APIServices()
    
    func getRequest() {
        
        guard let url = URL(string: "https://api.letsbuildthatapp.com/intermediate_training/companies") else {return}
        
        // reaches out to the api and is called in a existing background thread
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                
                print("failed to download companies \(error.localizedDescription) and \(response)")
                return
            }
            
            guard let data = data else {return}
            
            // lets you see the whole information you are recieving
            let string = String(data: data, encoding: .utf8)
            
            print(" the data is \(string)")
            
            let jsonDecoder = JSONDecoder()
            
            do {
                
                // this is how you decode data
                let JSONCompanies = try jsonDecoder.decode([JSONCompany].self, from: data)
                
                let privateContext = CoreDataManager.shared.persistanceContainer.viewContext
                
                JSONCompanies.forEach ({ (comp) in
                    print(comp.name)
                    
                    
                    let company = Company(context: privateContext)
                    company.name = comp.name
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    let foundedDate = formatter.date(from: comp.founded)
                    
                    company.founded = foundedDate
                    
                    comp.employees?.forEach({ jsonEmployees in
                        
                        let employee = Employee(context: privateContext)
                        employee.name = jsonEmployees.name
                    })
                    
                    do {
                        
                        try privateContext.save()
                        try privateContext.parent?.save()
                    } catch let error {
                        
                        print("failed tp save companies ")
                    }
            
                })

            } catch let error {
                
                print("failing your broo \(error)")
            }
            
            
        }.resume() // please do not forget to make this call.
        
    }
    
}


struct JSONCompany: Decodable {
    
    let name: String
    let founded: String
    let employees: [JSONEmployee]?
}


struct JSONEmployee: Decodable {
    
    let name: String
    let type: String
    let birthday: String
    
}

