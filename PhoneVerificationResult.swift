//
//  PhoneVerificationResult.swift
//  goCab3
//
//  Created by Biko Pougala on 22/07/2018.
//  Copyright © 2018 Tomahawk. All rights reserved.
//

import UIKit

class PhoneVerificationResult: UIViewController {
    
    var email: String? 
    var phone: String?

    @IBOutlet weak var checkOrCross: UIImageView!
    @IBOutlet weak var resultMessage: UILabel!
   
    @IBAction func returnToBookingButton(_ sender: UIButton) {
    }
    
    var message: String? 

    
    override func viewDidLoad() {
        
        if let resultToDisplay = message {
            resultMessage.text = resultToDisplay
            let info = createAccount.updatePhone(email ?? "emacron@elysee.fr", phone ?? "+33651986247")
            if info == true {
                print("Phone verified")
                print(phone ?? "No phone")
                print(email ?? "No email")
            } else {
                print("Phone could not be verified")
            }
            
        } else {
            resultMessage.text = "Something went wrong!"
        }
        
        super.viewDidLoad()


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
