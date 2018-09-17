//
//  SignUpView.swift
//  goCab3
//
//  Created by Biko Pougala on 07/07/2018.
//  Copyright © 2018 Tomahawk. All rights reserved.
//

import UIKit
import FacebookLogin 
import FBSDKLoginKit
import GoogleSignIn
import CTKFlagPhoneNumber
import CoreLocation 

class SignUpView: UIViewController, GIDSignInDelegate {
    var firstName: String? 
    var lastName: String? 
    var email: String? 
    var password: String? 
    var postalAddress: String? 
    var phoneNumber: String? 
    var userIdNumber: String? 
    var profilePicture: NSDictionary? 
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var wrongCredentialsLabel: UILabel!
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            self.userIdNumber = user.userID
            // let idToken = user.authentication.idToken // Safe to send to the server
            self.firstName = user.profile.name
            self.lastName = user.profile.familyName
            self.email = user.profile.email
            
        }
    }
    
    @IBAction func signInButton(_ sender: UIButton) {
        
    }
    
    var readyForLogin = false 
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let emailAddress = emailField.text, let passwordText = passwordField.text {
            
            createAccount.checkUserAccount(emailAddress, passwordText) {
                (response, error) in 
                if error != nil {
                    let alert = UIAlertController(title: "An error occured", message: "Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in 
                        NSLog("The \"error\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if let response = response {
                        if response == "true" {
                            NSLog("Segue was performed")
                            self.readyForLogin = true  
                            self.performSegue(withIdentifier: "goBackBooking", sender: self)
                        } else {
                            print("i'm here")
                            let alert = UIAlertController(title: "Wrong Credentials", message: "The input password and/or email address was wrong.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in 
                                NSLog("The \"OK\" alert occured.")
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                    }
                    
                }
            }
            
            
        }
        return readyForLogin 
        
    }
    
    
    
    var taxiType: String? 
    var originAddress: String?
    var destinationAddress: String? 
    var originCoordinate: CLLocationCoordinate2D?
    var destinationCoordinate: CLLocationCoordinate2D?
    
    @IBOutlet weak var newLabel: UILabel!
    
    @IBOutlet weak var signInButton: UIButton! 
    
    func fetchFacebookProfile() {
        let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, picture.width(480).height(480)"])
        
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in 
            if ((error) != nil) {
                let alert = UIAlertController(title: "An error occured", message: "Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in 
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                
            } else if let data = result as? [String:Any] {
                print("Print entire fetched result: \(result)")
                
                self.firstName = data["first_name"] as? String 
                self.lastName = data["last_name"] as? String 
                self.email = data["email"] as? String 
                
                if let profilePictureObj = data["picture"] as? NSDictionary {
                    self.profilePicture = profilePictureObj["data"] as? NSDictionary
                    let pictureUrlString = profilePictureObj["url"] as! String 
                    let pictureUrl = URL(string: pictureUrlString)
                    
                    DispatchQueue.global(qos: .background).async{
                        //let imageData = NSData(contentsofURL: pictureUrl)
                    }
                }
                
                
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wrongCredentialsLabel.isHidden = true 
        
        if (FBSDKAccessToken.currentAccessTokenIsActive()) {
            // user is already logged in, go to ConfirmBookingController 
            performSegue(withIdentifier: "goBackBooking", sender: nil)
        }
        
        let facebookButton = LoginButton(readPermissions: [ .publicProfile, .email, .userBirthday])
        
        view.addSubview(facebookButton)
        facebookButton.frame = CGRect(x: 16, y: (view.frame.height/2)+30, width: 128, height: 30)
        
        let googleButton = GIDSignInButton() 
        
        view.addSubview(googleButton)
        googleButton.frame = CGRect(x: 16, y: (view.frame.height/2)+80, width: 128, height: 20)
        
        if let accessToken = FBSDKAccessToken.current() {
            // use the access token here to check if the user was already logged in 
            self.userIdNumber = accessToken.userID 
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goBackBooking" {
            let vc:ConfirmBookingController = segue.destination as! ConfirmBookingController
            vc.originAddress = originAddress
            vc.destinationAddress = destinationAddress 
            vc.taxiType = taxiType 
            vc.originCoordinate = self.originCoordinate! 
            vc.destinationCoordinate = self.destinationCoordinate!
        } else {
            let destVC: CreateAccountView = segue.destination as! CreateAccountView
            destVC.originAddress = originAddress
            destVC.destinationAddress = destinationAddress
            destVC.taxiType = taxiType
        }
        
        
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
