//
//  Alert.swift
//  PinMap
//
//  Created by Daniil Aleshchenko on 28.03.2022.
//

import UIKit

extension UIViewController {
	
	// Create alert controller for addPin button
	
	func alertAddPlacemark(title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
		
		let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		
		alertController.addTextField { (textField) in
			textField.placeholder = placeholder
		}
		
		let alertOK = UIAlertAction(title: "OK", style: .default) { (action) in
			let textFieldText = alertController.textFields?.first
			guard let text = textFieldText?.text else { return }
			completionHandler(text)
		}
		
		let alertCancel = UIAlertAction(title: "Cancel", style: .default)
		
		alertController.addAction(alertOK)
		alertController.addAction(alertCancel)
		
		present(alertController, animated: true, completion: nil)
		
	}
	
	// Create alert for errors
	func alertError(title: String, message: String) {
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let alertOK = UIAlertAction(title: "OK", style: .default)
		
		alertController.addAction(alertOK)
		
		present(alertController, animated: true, completion: nil)
		
	}
	
}
