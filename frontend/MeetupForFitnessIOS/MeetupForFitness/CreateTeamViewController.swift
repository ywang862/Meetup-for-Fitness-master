//
//  CreateTeamViewController.swift
//  MeetupForFitness
//
//  Created by Mengyang Shi on 4/7/17.
//  Copyright © 2017 TFBOYZ. All rights reserved.
//

import UIKit
import Alamofire

class CreateTeamViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var teamNameField: UITextField!
    @IBOutlet weak var teamInfoField: UITextField!
    @IBOutlet weak var sportSelections: UIPickerView!
    
    let sportPickerData = ["badminton","basketball","soccer","table tennis"]

    var selectedSport = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundIamge")!)
        
        teamNameField.delegate = self
        teamInfoField.delegate = self
        
        sportSelections.delegate = self
        sportSelections.dataSource = self
        
        selectedSport = sportPickerData[0]
        
    }

    @IBAction func createTeam(_ sender: Any) {
        self.view.endEditing(true)
        
        if teamNameField.text! == "" || teamInfoField.text! == "" {
            sendAlart(info: "Please fill in search field before searching!")
            return
        }
        
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        (sender as! UIButton).isEnabled = false
        
        let parameters: Parameters = [
            "tName": teamNameField.text!,
            "tInfo": teamInfoField.text!,
            "sportsType": selectedSport
        ]
        
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/teams/add/allInfo/\(userId)", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
            switch response.result {
            case .success:
                print("Response String: \(response.result.value!)")
                if response.result.value! == "success" {
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "unwindCreatedTeam", sender: self)
                    })
                } else {
                    self.notifyFailure(info: "Team \(self.teamNameField.text!) created unsuccessfully.")
                    (sender as! UIButton).isEnabled = true
                }
            case .failure(let error):
                print(error)
                self.notifyFailure(info: "Cannot connect to server!")
                (sender as! UIButton).isEnabled = true
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
    
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - pickerview delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sportPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: sportPickerData[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSport = sportPickerData[row]
    }
    
    //Mark: other delegates delegate
    
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
