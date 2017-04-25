//
//  TeamMemberViewController.swift
//  MeetupForFitness
//
//  Created by Mengyang Shi on 4/9/17.
//  Copyright © 2017 TFBOYZ. All rights reserved.
//

import UIKit
import Alamofire
class TeamMemberViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var teamId: Int!
    var teamLeaderId = -1
    var teamMemberData = [(Int, String)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundIamge")!)
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        getTeamMembers()
    }

    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getTeamMembers() {
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/teams/member/\(teamId!)", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    self.teamMemberData.removeAll()
                    
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    self.teamLeaderId = (result["Team Leader"] as! [Int]).first!
                    let array = result["Team Member List"] as! [Dictionary<String, Any>]
                    for dict in array {
                        //print("dict ---> \(dict)")
                        let username = dict["username"] as! String
                        
                        let userId = dict["userId"] as! Int
                        
                        self.teamMemberData.append((userId, username))
                        
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            case .failure(let error):
                print(error)
                if let httpResponse = response.response {
                    if httpResponse.statusCode == 404 {
                        self.notifyFailure(info: "Currently no team members!")
                    } else if httpResponse.statusCode == 400 {
                        self.notifyFailure(info: "You don't have team members now!")
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
    
    //Mark: Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return teamMemberData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "teamMemberCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let currentMember = teamMemberData[indexPath.row]
        
        let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
        nameLabel.textColor = .white
        
        nameLabel.text = currentMember.1
        
        if currentMember.0 == teamLeaderId {
            let leaderLabel = cell.contentView.viewWithTag(2) as! UILabel
            leaderLabel.isHidden = false
        } else {
            cell.contentView.viewWithTag(2)?.isHidden = true
        }
        
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
