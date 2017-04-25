//
//  NotificationViewController.swift
//  MeetupForFitness
//
//  Created by Mengyang Shi on 4/7/17.
//  Copyright © 2017 TFBOYZ. All rights reserved.
//

import UIKit
import Alamofire
class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var friendOrTeamOrActivitySegmentControl: UISegmentedControl!
    
    
    let FRIEND_CODE = 1
    let TEAM_CODE = 2
    let ACTIVITY_CODE = 3
    
    var segmentCode: Int!
    
    var friendRequestData = [(Int, String, String)]()
    var teamInvitationsData = [(Int, String, Int, String, String)]()
    var invitedActivities = [Activity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundIamge")!)
        self.tableView.backgroundColor = .clear
        self.friendOrTeamOrActivitySegmentControl.tintColor = .white
        
        segmentCode = FRIEND_CODE
        tableView.delegate = self
        tableView.dataSource = self
        
        getFriendRequestsAndTeamInvitations()
    }

    
    @IBAction func segmentControlValueChanged(_ sender: Any) {
        switch friendOrTeamOrActivitySegmentControl.selectedSegmentIndex {
        case 0:
            segmentCode = FRIEND_CODE
            tableView.reloadData()
            getFriendRequestsAndTeamInvitations()
        case 1:
            segmentCode = TEAM_CODE
            tableView.reloadData()
            getFriendRequestsAndTeamInvitations()
        case 2:
            segmentCode = ACTIVITY_CODE
            tableView.reloadData()
            getActivityInvitations()
        default:
            break
        }
        
    }
    
    func getFriendRequestsAndTeamInvitations() {
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/notification/\(userId)", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    self.friendRequestData.removeAll()
                    self.teamInvitationsData.removeAll()
                    
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    let array = result["notifications"] as! [Dictionary<String, Any>]
                    for dict in array {
                        //print("dict ---> \(dict)")
                        let senderName = (dict["username"] as! [String]).first!
                        let senderId = dict["senderId"] as! Int
                        let postTime = dict["postTime"] as! String
                        
                        if let teamId = dict["teamId"] as? Int {
                            let teamName = (dict["tName"] as! [String]).first!
                            self.teamInvitationsData.append((senderId, senderName, teamId, teamName, postTime))
                        } else {
                            self.friendRequestData.append((senderId, senderName, postTime))
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.sortFriendRequestsByDate()
                        self.sortTeamInvitationsByDate()
                        self.tableView.reloadData()
                    })
                }
            case .failure(let error):
                print(error)
                if let httpResponse = response.response {
                    if httpResponse.statusCode == 404 {
                        self.notifyFailure(info: "You don't have notifications now!")
                    } else if httpResponse.statusCode == 400 {
                        self.notifyFailure(info: "You don't have notifications now!")
                    } else {
                        self.notifyFailure(info: "Cannot connect to server!")
                    }
                } else {
                    self.notifyFailure(info: "Cannot connect to server!")
                }
                
            }
        }
    }
    
    
    func getActivityInvitations() {
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        let activitiesData = ud.data(forKey: "activities")
        let allActivities = NSKeyedUnarchiver.unarchiveObject(with: activitiesData!) as! [Activity]
        
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/activity/invite/\(userId)", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    self.invitedActivities.removeAll()
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    if let array = result["Activities Invited"] as? [Int] {
                        for aid in array {
                            for activity in allActivities {
                                if activity.aid == aid {
                                    self.invitedActivities.append(activity)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.sortActivitiesByDate()
                        self.tableView.reloadData()
                    })
                }
            case .failure(let error):
                print(error)
                if let httpResponse = response.response {
                    if httpResponse.statusCode == 404 {
                        self.notifyFailure(info: "You don't have activity invitations now!")
                    } else if httpResponse.statusCode == 400 {
                        self.notifyFailure(info: "You don't have activity invitations now!")
                    } else {
                        self.notifyFailure(info: "Cannot connect to server!")
                    }
                } else {
                    self.notifyFailure(info: "Cannot connect to server!")
                }
                
            }
        }
    }
    
    func addFriend(_ sender : AddButton) {
        if sender.anotherId == nil {
            print("some errors here")
            return
        }
        
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        
        sender.isEnabled = false
        
        let parameters: Parameters = [
            "friendId": sender.anotherId!
        ]
        print("param ---> \(parameters)")
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/friends/add/\(userId)", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
            switch response.result {
            case .success:
                print("Response String: \(response.result.value!)")
                if response.result.value! == "success" {
                    DispatchQueue.main.async(execute: {
                        sender.setTitle("Accepted", for: .normal)
                        sender.backgroundColor = .clear
                        sender.setTitleColor(.blue, for: .normal)
                    })
                } else {
                    self.notifyFailure(info: "Add friend unsuccessfully.")
                    sender.isEnabled = true
                }
            case .failure(let error):
                print(error)
                self.notifyFailure(info: "Cannot connect to server!")
                sender.isEnabled = true
            }
        }
    }
    
    func addTeam(_ sender : AddButton) {
        if sender.anotherId == nil {
            print("some errors here")
            return
        }
        
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        
        sender.isEnabled = false
        
        print(sender.anotherId!)
        
        let parameters: Parameters = [
            "userId": userId
            ]
        print("param ---> \(parameters)")
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/teams/add/member/\(sender.anotherId!)", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
            switch response.result {
            case .success:
                print("Response String: \(response.result.value!)")
                if response.result.value! == "success" {
                    DispatchQueue.main.async(execute: {
                        sender.setTitle("Accepted", for: .normal)
                        sender.backgroundColor = .clear
                        sender.setTitleColor(.blue, for: .normal)
                    })
                } else {
                    self.notifyFailure(info: "Attend team unsuccessfully.")
                    sender.isEnabled = true
                }
            case .failure(let error):
                print(error)
                self.notifyFailure(info: "Cannot connect to server!")
                sender.isEnabled = true
            }
        }
    }
    
    func attendActivity(_ sender : AddButton) {
        if sender.anotherId == nil {
            print("some errors here")
            return
        }
        
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        
        sender.isEnabled = false
        
        let parameters: Parameters = [
            "userId": userId,
            "aid": sender.anotherId!
        ]
        print("param ---> \(parameters)")
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/activity/attend", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
            switch response.result {
            case .success:
                print("Response String: \(response.result.value!)")
                if response.result.value! == "success" {
                    DispatchQueue.main.async(execute: {
                        self.invitedActivities[sender.indexPath!].newUserAttended(uid: userId)
                        self.tableView.reloadData()
                    })
                } else {
                    self.notifyFailure(info: "The activity is already full! Reload this  page to update!")
                    sender.isEnabled = true
                }
            case .failure(let error):
                print(error)
                self.notifyFailure(info: "Cannot connect to server!")
                sender.isEnabled = true
            }
        }
    }
    
    func sortFriendRequestsByDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        friendRequestData.sort(by: {dateFormatter.date(from: $0.2)! > dateFormatter.date(from: $1.2)!})
    }
    
    func sortTeamInvitationsByDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        teamInvitationsData.sort(by: {dateFormatter.date(from: $0.4)! > dateFormatter.date(from: $1.4)!})
    }
    
    func sortActivitiesByDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        invitedActivities.sort(by: {dateFormatter.date(from: $0.postTime)! > dateFormatter.date(from: $1.postTime)!})
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
    
    
    
    //Mark: Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentCode == FRIEND_CODE  {
            return 150
        } else if segmentCode == TEAM_CODE {
            return 180
        }
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentCode == FRIEND_CODE  {
            return friendRequestData.count
        } else if segmentCode == TEAM_CODE {
            return teamInvitationsData.count
        }
        return invitedActivities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "notificationCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        
        if segmentCode == FRIEND_CODE  {
            let currentFriendRequest = friendRequestData[indexPath.row]
            let senderNameLabel = cell.contentView.viewWithTag(3) as! UILabel
            let secondLineLabel = cell.contentView.viewWithTag(2) as! UILabel
            let firstLineLabel = cell.contentView.viewWithTag(1) as! UILabel
            let postTimeLabel = cell.contentView.viewWithTag(8) as! UILabel
            let acceptButton = cell.contentView.viewWithTag(7) as! AddButton
            acceptButton.removeTarget(nil, action: nil, for: .allEvents)
            
            cell.contentView.viewWithTag(4)?.isHidden = true
            cell.contentView.viewWithTag(5)?.isHidden = true
            cell.contentView.viewWithTag(6)?.isHidden = true
            
            firstLineLabel.text = "A friend request"
            secondLineLabel.text = "from"
            senderNameLabel.text = currentFriendRequest.1
            
            firstLineLabel.textColor = .white
            secondLineLabel.textColor = .lightGray
            senderNameLabel.textColor = .white
            
            let postTime = dateFormatter.date(from: currentFriendRequest.2)
            
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            postTimeLabel.text = "Post at: \(dateFormatter.string(from: postTime!))"
            
            acceptButton.setTitle("Accept", for: .normal)
            acceptButton.backgroundColor = .blue
            acceptButton.isEnabled = true
            acceptButton.addTarget(self, action: #selector(self.addFriend(_:)), for: .touchUpInside)
            acceptButton.anotherId = currentFriendRequest.0
            acceptButton.indexPath = indexPath.row
            
        } else if segmentCode == TEAM_CODE {
            cell.contentView.viewWithTag(4)?.isHidden = false
            let currentTeamInvitation = teamInvitationsData[indexPath.row]
            let senderTeamLabel = cell.contentView.viewWithTag(3) as! UILabel
            let secondLineLabel = cell.contentView.viewWithTag(2) as! UILabel
            let firstLineLabel = cell.contentView.viewWithTag(1) as! UILabel
            let postTimeLabel = cell.contentView.viewWithTag(8) as! UILabel
            let teamLeaderLabel = cell.contentView.viewWithTag(4) as! UILabel
            let acceptButton = cell.contentView.viewWithTag(7) as! AddButton
            acceptButton.removeTarget(nil, action: nil, for: .allEvents)
            
            cell.contentView.viewWithTag(5)?.isHidden = true
            cell.contentView.viewWithTag(6)?.isHidden = true
            
            firstLineLabel.text = "A team invitation"
            secondLineLabel.text = "from"
            senderTeamLabel.text = "team \(currentTeamInvitation.3)"
            teamLeaderLabel.text = "led by: \(currentTeamInvitation.1)"
            
            firstLineLabel.textColor = .white
            secondLineLabel.textColor = .lightGray
            senderTeamLabel.textColor = .white
            teamLeaderLabel.textColor = .lightGray
            
            let postTime = dateFormatter.date(from: currentTeamInvitation.4)
            
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            postTimeLabel.text = "Post at: \(dateFormatter.string(from: postTime!))"
            
            acceptButton.setTitle("Accept", for: .normal)
            acceptButton.backgroundColor = .blue
            acceptButton.isEnabled = true
            acceptButton.addTarget(self, action: #selector(self.addTeam(_:)), for: .touchUpInside)
            acceptButton.anotherId = currentTeamInvitation.2
            acceptButton.indexPath = indexPath.row
            
        } else {
            cell.contentView.viewWithTag(4)?.isHidden = false
            cell.contentView.viewWithTag(5)?.isHidden = false
            cell.contentView.viewWithTag(6)?.isHidden = false
            
            let currentActivity = self.invitedActivities[indexPath.row]
            
            let activityNameLabel = cell.contentView.viewWithTag(1) as! UILabel
            let sportTypeLabel = cell.contentView.viewWithTag(2) as! UILabel
            let ownerLabel = cell.contentView.viewWithTag(3) as! UILabel
            let activityTimeLabel = cell.contentView.viewWithTag(4) as! UILabel
            let locationLabel = cell.contentView.viewWithTag(5) as! UILabel
            let attendanceLabel = cell.contentView.viewWithTag(6) as! UILabel
            let attendButton = cell.contentView.viewWithTag(7) as! AddButton
            let postTimeLabel = cell.contentView.viewWithTag(8) as! UILabel
            
            attendButton.removeTarget(nil, action: nil, for: .allEvents)
            
            activityNameLabel.textColor = .white
            sportTypeLabel.textColor = .lightGray
            ownerLabel.textColor = .white
            activityTimeLabel.textColor = .lightGray
            locationLabel.textColor = .lightGray
            attendanceLabel.textColor = .white
            
            activityNameLabel.text = currentActivity.name
            sportTypeLabel.text = currentActivity.sportsType
            ownerLabel.text = "By: \(currentActivity.getOwnerName())"
            
            let activityTime = dateFormatter.date(from: currentActivity.activityTime)
            let postTime = dateFormatter.date(from: currentActivity.postTime)
            
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            activityTimeLabel.text = dateFormatter.string(from: activityTime!)
            postTimeLabel.text = "Post at: \(dateFormatter.string(from: postTime!))"
            
            locationLabel.text = currentActivity.location
            attendanceLabel.text = "\(currentActivity.getAttendedAmount())/\(currentActivity.maxAttendance!)"
            
            if currentActivity.hasAttended(uid: userId) {
                attendButton.setTitle("Attended", for: .normal)
                attendButton.backgroundColor = .green
                attendButton.isEnabled = false
            } else {
                if currentActivity.isFull() {
                    attendButton.setTitle("Full", for: .normal)
                    attendButton.backgroundColor = .red
                    attendButton.isEnabled = false
                } else {
                    attendButton.setTitle("Attend", for: .normal)
                    attendButton.backgroundColor = .blue
                    attendButton.isEnabled = true
                    attendButton.addTarget(self, action: #selector(self.attendActivity(_:)), for: .touchUpInside)
                    attendButton.anotherId = currentActivity.aid!
                    attendButton.indexPath = indexPath.row
                }
            }
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
