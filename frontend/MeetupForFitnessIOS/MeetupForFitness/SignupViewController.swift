//
//  SignupViewController.swift
//  MeetupForFitness
//
//  Created by Mengyang Shi on 3/26/17.
//  Copyright © 2017 TFBOYZ. All rights reserved.
//

import UIKit
import Alamofire

class SignupViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reenterPasswordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundIamge")!)
        userNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        reenterPasswordField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signup(_ sender: Any) {
        if userNameField.text! == "" || passwordField.text! == "" || emailField.text! == "" || reenterPasswordField.text! == "" || (passwordField.text! != reenterPasswordField.text!) {
            sendAlart(info: "Please fill in all blank fields before login!")
            return
        }
        
        let parameters: Parameters = [
            "username": userNameField.text ?? " ",
            "email": emailField.text ?? " ",
            "password": passwordField.text ?? " ",
            "gender": " ",
            "avatarURL": " ",
            "description": " "
        ]
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/auth/signup", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    let userId = result["userId"] as? Int
                    if userId != nil {
                        //go to main page
                        print("login success")
                        let ud = UserDefaults.standard
                        ud.set(userId, forKey: "currentUserId")
                        ud.synchronize()
                        
                        self.performSegue(withIdentifier: "signupToMain", sender: self)
                    } else {
                        self.notifyFailure(info: "Unknown error when signing up!")
                    }
                }
            case .failure(let error):
                print(error)
                if let httpResponse = response.response {
                    if httpResponse.statusCode == 404 {
                        self.notifyFailure(info: "This username already exists!")
                    }else {
                        self.notifyFailure(info: "Cannot connect to server!")
                    }
                } else {
                    self.notifyFailure(info: "Cannot connect to server!")
                }
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
