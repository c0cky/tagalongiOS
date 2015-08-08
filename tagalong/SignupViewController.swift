//
//  SignupViewController.swift
//  testing
//
//  Created by Camron Godbout on 2/21/15.
//  Copyright (c) 2015 Camron Godbout. All rights reserved.
//

import UIKit
import CoreData

class SignupViewController: UIViewController {
    
    let managedObjectContext =
    (UIApplication.sharedApplication().delegate
        as! AppDelegate).managedObjectContext

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var response : String = ""
    var apiresponse : String = ""
    
    @IBAction func submitButtonClick(sender: UIButton) {
        if usernameField.text.isEmpty || emailField.text.isEmpty || passwordField.text.isEmpty
        {
            //alert that you need to fill in all fields
            let alert = UIAlertController(title: "Error", message: "All fields are required.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            let parameters =
            [
                "username":usernameField.text,
                "email"   :emailField.text,
                "password":passwordField.text
            ]
            request(.POST, "http://tagalongapp.co/cusr/",parameters: parameters, encoding: .JSON).responseString { (_, _, stringresponse, _) in
                println("RESPONSE")
                if let actualString = stringresponse{
                    self.response = actualString
                } else
                {
                    let alert = UIAlertController(title: "Error", message: "Error in login server", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            let loginparam =
            [
                "username":usernameField.text,
                "password":passwordField.text
            ]
            
            request(.POST, "http://tagalongapp.co/lusr/", parameters: loginparam, encoding: .JSON).responseString { (_,_,loginresponse, _) in
            
                if let loginString = loginresponse
                {
                    var tempArray = split(loginString) {$0 == " "}
                    self.apiresponse = tempArray[0]
                }
                let entityDescription =
                NSEntityDescription.entityForName("Account",
                    inManagedObjectContext: self.managedObjectContext!)
                
                let account = Account(entity: entityDescription!,
                    insertIntoManagedObjectContext: self.managedObjectContext)
                
                account.username = self.usernameField.text
                account.password = self.passwordField.text
                account.apikey = self.apiresponse
                
            }
            var error : NSError?
            
            managedObjectContext?.save(&error)
            
            if let err = error {
                println(err.localizedFailureReason)
            }
            println(self.response)
            
            if self.response != ""
            {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let cameraViewController = mainStoryboard.instantiateViewControllerWithIdentifier("cameraviewcontroller") as! ViewController
                self.presentViewController(cameraViewController, animated:true, completion:nil)
            }
            else
            {
                let alert = UIAlertController(title: "Error", message: "Login Failed. Either your username or password was incorrect.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            

        }
        
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent){
        self.view.endEditing(true);
    }
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
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
