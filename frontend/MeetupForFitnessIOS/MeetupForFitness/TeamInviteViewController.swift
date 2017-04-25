//
//  TeamInviteViewController.swift
//  MeetupForFitness
//
//  Created by Mengyang Shi on 4/7/17.
//  Copyright © 2017 TFBOYZ. All rights reserved.
//

import UIKit
import Alamofire
class TeamInviteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    var teamData = [(Int, String)]()
    var receiverId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundIamge")!)
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        getTeamFromServer()
    }

    func getTeamFromServer() {
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
                        let teamName = dict["tname"] as! String
                        
                        let teamId = dict["teamId"] as! Int
                        
                        self.teamData.append((teamId, teamName))
                        
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
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
    
    func sendTeamInvitation(_ sender : AddButton) {
        if sender.anotherId == nil {
            print("some errors here")
            return
        }
        
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        
        sender.isEnabled = false
        
        let parameters: Parameters = [
            "senderId": userId,
            "receiverId": receiverId,
            "teamId": sender.anotherId!
        ]
        print("param ---> \(parameters)")
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/notification/add", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
            switch response.result {
            case .success:
                print("Response String: \(response.result.value!)")
                if response.result.value! == "success" {
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "unwindTeamInviteRequest", sender: self)
                    })
                } else {
                    self.notifyFailure(info: "Friend request sent unsuccessfully.")
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
    
    //Mark: Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "teamInviteCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
        var currentData: (Int, String)!
        currentData = teamData[indexPath.row]
        
        nameLabel.text = currentData.1
        nameLabel.textColor = .white
        
        let teamInviteButton = cell.contentView.viewWithTag(2) as! AddButton
        teamInviteButton.addTarget(self, action: #selector(self.sendTeamInvitation(_:)), for: .touchUpInside)
        teamInviteButton.indexPath = indexPath.row
        teamInviteButton.anotherId = currentData.0
        
        cell.selectionStyle = .none // to prevent cells from being "highlighted"
        
        cell.backgroundColor = .clear
        
        return cell
        
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
