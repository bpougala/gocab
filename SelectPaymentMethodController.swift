////
////  SelectPaymentMethodController.swift
////  goCab3
////
////  Created by Biko Pougala on 05/08/2018.
////  Copyright © 2018 Tomahawk. All rights reserved.
////
//
//import UIKit
//import Stripe 
//
//struct Headline {
//    
//    var id: Int 
//    var title: String 
//    var text: String 
//    var image: String 
//}
//
//class SelectPaymentMethodController: UITableViewController, STPPaymentContextDelegate {
//    
//    var selected: String? 
//    
//    var headlines = [
//        Headline(id: 1, title: "Credit/Debit Card", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", image: "credit"),
//        Headline(id: 2, title: "Apple Pay", text: "Aenean condimentum", image: "apple_pay"), 
//        Headline(id: 3, title: "Bancontact (Belgium only)", text: "Aliquam egestas ultricies dapibus. Nam molestie nunc.", image: "bancontact"),
//        Headline(id: 4, title: "PayPal", text: "haha", image: "paypal"),
//        Headline(id: 5, title: "Cash", text: "blabla", image: "cash")
//    ]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//        
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    // MARK: - Table view data source
//    
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return headlines.count 
//    }
//    
//    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
//        
//        let scale = newWidth / image.size.width
//        let newHeight = image.size.height * scale
//        let rect = CGSize(width: newWidth, height: newHeight)
//        let newRect = CGRect(origin: .zero, size: CGSize(width: newWidth, height: newHeight))
//        UIGraphicsBeginImageContext(rect)
//        image.draw(in: newRect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage!
//    }
//    
//    
//    
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
//        
//        let headline = headlines[indexPath.row]
//        cell.textLabel?.text = headlines[indexPath.row].title 
//        let image = UIImage(named: headline.image)
//        if let image = image {
//            cell.imageView?.image = resizeImage(image: image, newWidth: 38)
//            
//        }
//        
//        
//        return cell
//    }
//    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Select a payment method"
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let headline = headlines[indexPath.row]
//        selected = headline.title
//        dismissVC(self)
//}
//    
//    @IBAction func dismissVC(_ sender: Any?) {
//        if let senderVC = sender as? ConfirmBookingController {
//            senderVC.paymentMethod = selected! 
//        }
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
//        // this function gets called whenever the payment context changes (e.g. when the user selects a new payment method) 
//    }
//    
//    // this function gets called when the user has successfully selected a payment method and completed their purchase
//    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
//        
//        ProcessPayments.createCharge(paymentResult.source.stripeID, completion: { (error: Error?) in 
//            if let error = error {
//                completion(error)
//            } else {
//                completion(nil)
//            }
//        })
//    }
//    
//
//}
