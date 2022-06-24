//
//  EmployeesViewModel.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 09/05/2022.
//

import UIKit


struct EmployeesViewModel {
    
    var employees: Employee
    
    var name: String? {
        
        return employees.name
    }
    
    var taxId: String? {
        
        return employees.employeeInformation?.taxId
    }
    
    var birthday: Date? {
        
        return employees.employeeInformation?.birthday
    }
    
    init(employees: Employee) {
        self.employees = employees
        
    }
    
}
