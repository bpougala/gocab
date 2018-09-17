//
//  VerifyNumberController.swift
//  goCab3
//
//  Created by Biko Pougala on 22/07/2018.
//  Copyright © 2018 Tomahawk. All rights reserved.
//

import UIKit

class VerifyNumberController: UIViewController, UITextFieldDelegate {
    
    var originAddress: String? 
    var destinationAddress: String? 
    var taxiType: String? 
    var firstName: String? 
    var lastName: String? 
    var emailAddress: String? 
    var password: String? 
    var affiliation_code: String? 
    var newsletterConsent: Bool? 
    
    @IBOutlet var codeField: UITextField! = UITextField() 
    @IBOutlet var errorLabel: UILabel! = UILabel() 
    @IBOutlet weak var codeResentInfo: UILabel!
    
    var countryCode: String? 
    var phoneNumber: String? 
    var resultMessage: String? 
    
    @IBAction func validateCode() {
        self.errorLabel.text = nil // reset 
        if let code = codeField.text {
            VerifyAPI.validateVerificationCode(self.countryCode!, self.phoneNumber!, code) { checked in 
                if (checked.success) {
                    self.resultMessage = checked.message 
                    self.performSegue(withIdentifier: "checkResultSegue", sender: nil)
                } else {
                    self.errorLabel.text = checked.message 
                }
            }
        }
    }
    
    @IBAction func resendCode(_ sender: UIButton) {
        if let telephoneNumber = phoneNumber {
            VerifyAPI.sendVerificationCode(countryCode ?? "33", telephoneNumber)
            codeResentInfo.text = "Code resent!"
            codeResentInfo.textColor = UIColor.red
        } else {
            return
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkResultSegue", 
            let dest = segue.destination as? PhoneVerificationResult {
            dest.message = resultMessage
            dest.email = emailAddress
            dest.phone = phoneNumber
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        codeField.delegate = self 


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
