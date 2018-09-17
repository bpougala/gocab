//
//  StartPhoneValidation.swift
//  goCab3
//
//  Created by Biko Pougala on 22/07/2018.
//  Copyright © 2018 Tomahawk. All rights reserved.
//

import UIKit
import CTKFlagPhoneNumber

extension String {
    func replace(string:String, replacement:String) -> String {
        
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhiteSpace() -> String {
        return self.replace(string: " ", replacement: "")
    }
}

class StartPhoneValidation: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneNumberField: CTKFlagPhoneNumberTextField!
    var countryCode: String? 
    var phoneNumber: String? 
    var originAddress: String? 
    var destinationAddress: String? 
    var taxiType: String? 
    var firstName: String? 
    var lastName: String? 
    var password: String? 
    var emailAddress: String? 
    var newsletterConsent: Bool? 
    var affiliation_code: String? 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberField.setFlag(with: "FR")
        phoneNumberField.placeholder = "6 00 00 00 00"
        self.phoneNumberField.delegate = self 
        

        // Do any additional setup after loading the view.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        countryCode = phoneNumberField.getCountryPhoneCode()
        phoneNumber = phoneNumberField.text?.removeWhiteSpace()
        // print(phoneNumber ?? "Nothing, mate")
        
    }
    
   
    @IBAction func sendVerification() {
        if let telephoneNumber = phoneNumberField.text {
            countryCode = phoneNumberField.getCountryPhoneCode()
            print(telephoneNumber.removeWhiteSpace())
            print(countryCode ?? "")
            VerifyAPI.sendVerificationCode(countryCode ?? "33", telephoneNumber.removeWhiteSpace())
        } else {
            print("there was a problem with the segue")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? VerifyNumberController {
            dest.countryCode = phoneNumberField.getCountryPhoneCode()
            dest.phoneNumber = phoneNumberField.text?.removeWhiteSpace()
            dest.emailAddress = emailAddress
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // close keyboard when return key is hit 
        textField.resignFirstResponder()
        
        return true 
    }
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
