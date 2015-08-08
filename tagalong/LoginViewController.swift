//
//  LoginViewController.swift
//  testing
//
//  Created by Camron Godbout on 2/21/15.
//  Copyright (c) 2015 Camron Godbout. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    
    let managedObjectContext =
    (UIApplication.sharedApplication().delegate
        as! AppDelegate).managedObjectContext

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var apiresponse : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonClick(sender: UIButton) {
        if usernameField.text.isEmpty || passwordField.text.isEmpty
        {
            let alert = UIAlertController(title: "Error", message: "All fields are required.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
//        let url =
        let url = "http://tagalongapp.co/lusr/"
        let parameters =
        [
            "username" : usernameField.text,
            "password" : passwordField.text
        ]
        request(.POST, url, parameters: parameters).responseString{ (_, _, string, _) in
            println(url)
            println(parameters)
            if let loginString = string
            {
                var tempArray = split(loginString) {$0 == " "}
                self.apiresponse = tempArray[0]
                println(loginString)
            }
            
            if (self.apiresponse == "failed login" || self.apiresponse == "disabled" || self.apiresponse == "") {
                return
            }
            let entityDescription =
            NSEntityDescription.entityForName("Account",
                inManagedObjectContext: self.managedObjectContext!)
            
            let account = Account(entity: entityDescription!,
                insertIntoManagedObjectContext: self.managedObjectContext)
            
            account.username = self.usernameField.text
            account.password = self.passwordField.text
            account.apikey = self.apiresponse
            
            var error : NSError?
            
            self.managedObjectContext?.save(&error)
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let cameraViewController = mainStoryboard.instantiateViewControllerWithIdentifier("cameraviewcontroller") as! ViewController
            self.presentViewController(cameraViewController, animated:true, completion:nil)
            
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    @IBAction func doneButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
