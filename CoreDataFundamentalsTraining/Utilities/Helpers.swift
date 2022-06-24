//
//  Helpers.swift
//  CoreDataFundamentalsTraining
//
//  Created by Beni Mushiya on 09/05/2022.
//

import UIKit


extension UIViewController {
    
    // my extension and helper methods
    
    func configurePlussButtonInNavigationBar(selector: Selector) {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.bubble.fill"), style: .plain, target: self, action: selector)
        
    }
    
    func configureSaveButton(selector: Selector) {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: selector)
        
    }
    
    
    func configureCancelButton() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    @objc func handleCancel() {
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
