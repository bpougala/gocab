//
//  CreateAccountView.swift
//  goCab3
//
//  Created by Biko Pougala on 09/07/2018.
//  Copyright © 2018 Tomahawk. All rights reserved.
//

import UIKit
import CTKFlagPhoneNumber
import DLRadioButton
import Navajo_Swift





class CreateAccountView: UIViewController, UITextFieldDelegate {
    
    var originAddress: String? 
    var destinationAddress: String? 
    var taxiType: String? 
    var timeOrder: String? // the booking is for either "Now" (default) or a later time, which needs to be specified 
    var firstName: String? 
    var lastName: String? 
    var email: String? 
    var password: String? 
    var birthDate: String? 
    var postalAddress: String? 
    var phoneNumber: String? 
    var userIdNumber: String? 
    var gender = "M"
    var acceptPromotion: Bool?
    var countryCode: String? 

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var controllerView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var affiliation_code: UITextField!
    
   
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var birthDateField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordStrength: UILabel!
    @IBOutlet weak var passwordMismatch: UILabel!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var responseMessage: UILabel! 
    @IBOutlet weak var emailAddressField: UITextField!
    
    @IBAction func genderBox(_ sender: DLRadioButton) {
        if sender.tag == 1 {
            gender = "M"
            print(gender)
        } else if sender.tag == 2 {
            gender = "F"
            print(gender)
        } else if sender.tag == 3 {
            gender = "NB"
            print(gender)
        }
    }
    
    
    func officiallyCreateAccount() {
        let url = NSURL(string: "https://gocab.app/post_new_user.php")
        
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "POST"
        
        // POST string has entries separated by &
        var dataString = "secretWord=M,5Z$Tjj3y57bL)$4&firstName=\(firstName as String?)"
        dataString = dataString + "&surname=\(lastName as String?)&birth=\(birthDate as String?)&gender=\(gender as String?)&email=\(email as String?)&password=\(password as String?)&mobile=\(phoneNumber as String?)"
        
        // convert the POST string to utf8 format 
        let dataD = dataString.data(using: .utf8)!
        
        // the upload task, uploadTask, is defined here
        let uploadTask = URLSession.shared.uploadTask(with: request, from: dataD) {
            data, response, error in 
            if error != nil {
                // display an alert if there is an error
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Upload Didn't Work?", message: "Looks like the connection to the server didn't work.  Do you have Internet access?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                if let unwrappedData = data {
                    let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                    
                    if returnedData == "1" {
                        DispatchQueue.main.async
                            {
                                let alert = UIAlertController(title: "Upload OK?", message: "Looks like the upload and insert into the database worked.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        // display an alert if an error and database insert didn't worked (return != 1) inside the DispatchQueue.main.async
                        
                        DispatchQueue.main.async
                            {
                                
                                let alert = UIAlertController(title: "Upload Didn't Work", message: "Looks like the insert into the database did not work.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }            
        }
        uploadTask.resume()
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.delegate = self 
        firstNameField.delegate = self 
        lastNameField.delegate = self 
        repeatPasswordField.delegate = self
        responseMessage.text = ""

       
        // should probably be checked 
        let checkbox = Checkbox() 
        
        if checkbox.didCheckBox() == true {
            self.acceptPromotion = true 
            
        } else {
            self.acceptPromotion = false 
        }
        
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // close keyboard when return key is hit 
        textField.resignFirstResponder()
        
        return true 
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        if textField.tag == 1 { // if the user changes the original password after "Passwords match" is printed, the repeat password should be check again 
            if let text = repeatPasswordField.text {
                if newString != text {
                    self.passwordMismatch.text = "The passwords mismatch"
                    self.passwordMismatch.textColor = UIColor.red 
                    self.repeatPasswordField.layer.borderColor = UIColor.red.cgColor
                } else {
                    passwordMismatch.text = "The passwords do match"
                    passwordMismatch.textColor = #colorLiteral(red: 0.3084011078, green: 0.5618229508, blue: 0, alpha: 1)
                    passwordMismatch.layer.borderColor = UIColor.green.cgColor
                }

            } 
            let password = passwordField.text ?? ""
            let strength = Navajo.strength(ofPassword: password)
            passwordStrength.text = Navajo.localizedString(forStrength: strength)
            if passwordStrength.text! == "Very Weak" {
                passwordStrength.textColor = UIColor.red
            } else if passwordStrength.text! == "Weak" {
                passwordStrength.textColor = UIColor.orange
            } else if passwordStrength.text! == "Reasonable" {
                passwordStrength.textColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
            } else if passwordStrength.text! == "Strong" {
                passwordStrength.textColor = UIColor.green
            } else {
                passwordStrength.textColor = #colorLiteral(red: 0.3084011078, green: 0.5618229508, blue: 0, alpha: 1)
            }
        } else if textField.tag == 2 {
            if self.passwordField.text != newString {
                self.passwordMismatch.text = "The passwords mismatch"
                self.passwordMismatch.textColor = UIColor.red 
                self.repeatPasswordField.layer.borderColor = UIColor.red.cgColor
            } else {
                passwordMismatch.text = "The passwords do match"
                passwordMismatch.textColor = #colorLiteral(red: 0.3084011078, green: 0.5618229508, blue: 0, alpha: 1)
                passwordMismatch.layer.borderColor = UIColor.green.cgColor
            }
            
        } else if textField.tag == 3 {
            
        }
        return true 
    }
    
    
    
    
    
    private static let baseURLString = "https://api.authy.com/protected/json"
    
    static let path = Bundle.main.path(forResource: "keys", ofType: "plist")
    static let keys = NSDictionary(contentsOfFile: path!)
    static let apiKey = keys!["apiKey"] as! String 
    
    
    @IBAction func createAccountPressed(_ sender: UIButton) {
        firstName = firstNameField.text 
        lastName = lastNameField.text
        email = emailAddressField.text 
        password = passwordField.text 
        
        if (firstName != "" && lastName != "" && email != "" && password != "" && phoneNumber != "") {
        let accountCreated = createAccount.createNewAccount(self.firstName ?? "John", self.lastName ?? "Smith", self.email ?? "johnsmith@gmail.com", self.password ?? "Tarabiscotta1", 0, 0, self.responseMessage)
        if accountCreated == true {
            performSegue(withIdentifier: "createAccount", sender: nil)
        } else {
            responseMessage.text = "Account could not be created"
        }
//        if let numberPhone = phoneNumber {
//            CreateAccountView.sendVerificationCode(countryCode ?? "33", numberPhone)
//        } else {
//            NSLog("Could not find a valid phone number")
//        }
        } else {
            responseMessage.text = "Please fill all the required fields"
        }
    }
    
//    static func sendVerificationCode(_ countryCode: String, _ phoneNumber: String) {
//        let parameters = [
//            "api_key": apiKey, 
//            "via": "sms", 
//            "country_code": countryCode, 
//            "phone_number": phoneNumber
//        ]
//        
//        let path = "phones/verification/start"
//        let method = "POST"
//        
//        let urlPath = "\(baseURLString)/\(path)"
//        var components = URLComponents(string: urlPath)! 
//        
//        var queryItems = [URLQueryItem]() 
//        
//        for (key, value) in parameters {
//            let item = URLQueryItem(name: key, value: value)
//            queryItems.append(item)
//        }
//        
//        components.queryItems = queryItems
//        
//        let url = components.url! 
//        
//        var request = URLRequest(url: url)
//        request.addValue(apiKey, forHTTPHeaderField: "X-Authy-API-Key")
//        request.httpMethod = method 
//        
//        let session: URLSession = {
//            let config = URLSessionConfiguration.default 
//            return URLSession(configuration: config)
//        }() 
//        
//        let task = session.dataTask(with: request) {
//            (data, response, error) in 
//            if let data = data {
//                do {
//                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                    
//                    print(jsonSerialized!)
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//            } else if let error = error {
//                print(error.localizedDescription)
//            }
//        }
//        task.resume()
//        
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC: StartPhoneValidation = segue.destination as! StartPhoneValidation
        destVC.originAddress = originAddress 
        destVC.destinationAddress = destinationAddress
        destVC.taxiType = taxiType
        destVC.firstName = firstName
        destVC.lastName = lastName
        destVC.password = password
        destVC.newsletterConsent = acceptPromotion
        destVC.affiliation_code = affiliation_code.text ?? "" 
        destVC.emailAddress = emailAddressField.text 
        
       
        
    }
    
    
    
    
    
    
}
