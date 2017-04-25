//
//  AddActivityViewController.swift
//  MeetupForFitness
//
//  Created by Mengyang Shi on 3/27/17.
//  Copyright © 2017 TFBOYZ. All rights reserved.
//

import UIKit
import Alamofire
class AddActivityViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var activityNameField: UITextField!
    @IBOutlet weak var personalOrTeamSegmentControl: UISegmentedControl!
    @IBOutlet weak var teamSelections: UIPickerView!
    @IBOutlet weak var sportSelections: UIPickerView!
    @IBOutlet weak var timeSelection: UIDatePicker!
    
    var teamId = -1
    
    var teamData = [(Int, String)]()
    
    let teamPickerData = ["team1","team2","team3"]
    let sportPickerData = ["badminton","basketball","soccer","table tennis"]
    
    var selectedTeam = String()
    var selectedSport = String()
    var dateString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundIamge")!)
        
        personalOrTeamSegmentControl.tintColor = .white
        
        
        timeSelection.setValue(UIColor.white, forKeyPath: "textColor")
        timeSelection.minimumDate = timeSelection.date
        timeSelection.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        teamSelections.isHidden = true
        
        teamSelections.delegate = self
        teamSelections.dataSource = self
        sportSelections.delegate = self
        sportSelections.dataSource = self
        
        activityNameField.delegate = self
        
        getTeamsFromServer()
        
        selectedTeam = teamPickerData[0]
        selectedSport = sportPickerData[0]
        // Do any additional setup after loading the view.
        
        dateString = timeSelection.date.toString(format: "EEE, dd LLL yyyy HH:mm:ss z")
    }

    func dateChanged(_ sender: UIDatePicker) {
        dateString = sender.date.toString(format: "EEE, dd LLL yyyy HH:mm:ss z")
    }
    
    @IBAction func changeAcitivityType(_ sender: Any) {
        switch personalOrTeamSegmentControl.selectedSegmentIndex
        {
        case 0:
            teamSelections.isHidden = true
            teamId = -1
        case 1:
            teamSelections.isHidden = false
            teamId = 0
        default:
            break
        }
    }
    
    func getTeamsFromServer() {
        
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/teams/\(userId)", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    self.teamData.removeAll()
                    
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    let array = result["Team List"] as! [Dictionary<String, Any>]
                    for dict in array {
                        //print("dict ---> \(dict)")
                        let isLeader = dict["isLeader"] as! Bool
                        
                        if isLeader {
                            let teamName = dict["tname"] as! String
                            
                            let teamId = dict["teamId"] as! Int
                            
                            self.teamData.append((teamId, teamName))
                        }
                        
                        
                        
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.teamSelections.reloadAllComponents()
                    })
                }
            case .failure(let error):
                print(error)
                if let httpResponse = response.response {
                    if httpResponse.statusCode == 404 {
                        self.notifyFailure(info: "Currently no teams!")
                    } else if httpResponse.statusCode == 400 {
                        self.notifyFailure(info: "You don't have team now!")
                    } else {
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
    
    // MARK: - pickerview delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count:Int?
        if pickerView == teamSelections {
            count = teamData.count
        } else if pickerView == sportSelections {
            count = sportPickerData.count
        }
        return count!
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title:String?
        if pickerView == teamSelections {
            title = teamData[row].1
        } else if pickerView == sportSelections {
            title = sportPickerData[row]
        }
        let attString = NSAttributedString(string: title!, attributes: [NSForegroundColorAttributeName : UIColor.white])
        return attString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == teamSelections {
            selectedTeam = teamData[row].1
            teamId = teamData[row].0
        } else if pickerView == sportSelections {
            selectedSport = sportPickerData[row]
        }
    }
    
    @IBAction func nextStep(_ sender: Any) {
        if selectedTeam == "" || selectedSport == "" || dateString == "" || activityNameField.text == "" {
            self.sendAlart(info: "Please fill in all info before moving on.")
            return
        }
        self.performSegue(withIdentifier: "addNextNew", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNextNew" {
            let destination = segue.destination as!AddActivitySecondViewController
            destination.teamId = teamId
            destination.teamName = selectedTeam
            destination.sportType = selectedSport
            destination.dateString = dateString
            destination.activityName = activityNameField.text!
        }
    }
    

}

extension Date {
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
