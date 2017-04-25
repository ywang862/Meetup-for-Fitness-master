//
//  ViewController.swift
//  MeetupForFitness
//
//  Created by Mengyang Shi on 3/5/17.
//  Copyright © 2017 TFBOYZ. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundIamge")!)
        userNameField.delegate = self
        passwordField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: Any) {
        if userNameField.text! == "" || passwordField.text! == ""  {
            sendAlart(info: "Please fill in all blank fields before login!")
            return
        }
        
        let parameters: Parameters = [
            "username": userNameField.text ?? " ",
            "password": passwordField.text ?? " "
        ]
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/auth/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    let existUser = result["existing user"] as! Bool
                    if existUser {
                        //go to main page
                        print("login success")
                        let ud = UserDefaults.standard
                        ud.set(result["userId"] as! Int, forKey: "currentUserId")
                        ud.synchronize()
                        
                        self.performSegue(withIdentifier: "loginToMain", sender: self)
                    } else {
                        self.notifyFailure(info: "Username doesn't exist or password is not correct!")
                    }
                }
            case .failure(let error):
                print(error)
                self.notifyFailure(info: "Cannot connect to server!")
            }
        }
    }
    
    func sendAlart(info: String) {
        let alertController = UIAlertController(title: "Hey!", message: info, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func notifyFailure(info: String) {
        self.sendAlart(info: info)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    


}

