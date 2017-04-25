//
//  UpdateUserInfoViewController.swift
//  MeetupForFitness
//
//  Created by Mengyang Shi on 4/9/17.
//  Copyright © 2017 TFBOYZ. All rights reserved.
//

import UIKit
import Alamofire

class UpdateUserInfoViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var userDescription: UITextField!
    @IBOutlet weak var genderSelections: UIPickerView!
    
    let genderData = ["male", "female", "other"]
    var selectedGender: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundIamge")!)
        
        emailField.delegate = self
        userDescription.delegate = self
        
        selectedGender = genderData.first
        
        genderSelections.delegate = self
        genderSelections.dataSource = self
    }

    
    
    @IBAction func save(_ sender: UIButton) {
        if emailField.text == "" || userDescription.text == "" {
            self.sendAlart(info: "Please enter your email and description to update.")
            return
        }
        
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        
        sender.isEnabled = false
        
        let parameters: Parameters = [
            "gender": selectedGender,
            "email" : emailField.text!,
            "description": userDescription.text!
        ]
        print("param ---> \(parameters)")
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/auth/update/\(userId)", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
            switch response.result {
            case .success:
                print("Response String: \(response.result.value!)")
                if response.result.value! == "Success" {
                    DispatchQueue.main.async(execute: {
                        self.back(self)
                    })
                } else {
                    self.notifyFailure(info: "Update failed for unknown reason!")
                    sender.isEnabled = true
                }
            case .failure(let error):
                print(error)
                self.notifyFailure(info: "Cannot connect to server!")
                sender.isEnabled = true
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
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
    
    // MARK: - pickerview delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: genderData[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGender = genderData[row]
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
