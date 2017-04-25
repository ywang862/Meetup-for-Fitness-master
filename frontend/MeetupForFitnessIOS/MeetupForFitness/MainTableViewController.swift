//
//  MainTableViewController.swift
//
// Copyright (c) 21/12/15. Ramotion Inc. (http://ramotion.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Alamofire

class MainTableViewController: UITableViewController {
    
    let kCloseCellHeight: CGFloat = 179
    let kOpenCellHeight: CGFloat = 415

    var kRowsCount = 10
    
    var cellHeights = [CGFloat]()
    
    var myActivities = [Activity]()
    var shownActivities = [Activity]()
    var userId:Int!

    @IBOutlet weak var teamActivitySegmentControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCellHeightsArray()
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "backgroundIamge"))
        
        userId = UserDefaults.standard.integer(forKey: "currentUserId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.downloadMyActivities()
        
        
    }
    
    
    @IBAction func teamActivityShown(_ sender: Any) {
        switch teamActivitySegmentControl.selectedSegmentIndex {
        case 0:
            shownActivities = myActivities
            self.createCellHeightsArray()
            self.tableView.reloadData()
        case 1:
            filterOutPersonalInShownData()
            self.createCellHeightsArray()
            self.tableView.reloadData()
        default:
            break
        }
    }
    
    func downloadMyActivities() {
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/activity/\(userId!)", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    self.myActivities.removeAll()
                    self.shownActivities.removeAll()
                    
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    let array = result["activities"] as! [Dictionary<String, Any>]
                    for dict in array {
                        //print("dict ---> \(dict)")
                        let activityName = dict["aName"] as! String
                        let sportsType = (dict["sportsType"] as! [String]).first
                        let teamNameArr = dict["teamName"] as? [String]
                        let info = dict["aInfo"] as! String
                        let aid = dict["aid"] as! Int
                        let postTime = dict["postTime"] as! String
                        let activityTime = dict["aTime"] as! String
                        let userId = dict["userId"] as! Int
                        var teamId = dict["teamId"] as? Int
                        let maxAttendance = dict["maxPeople"] as! Int
                        let attendedIds = dict["attended"] as! [Int]
                        let location = dict["location"] as! String
                        let username = (dict["username"] as! [String]).first
                        
                        var teamName:String!
                        if teamId == nil {
                            teamId = -1
                            teamName = ""
                        } else {
                            if teamNameArr != nil && (teamNameArr?.count)! > 0 {
                                teamName = teamNameArr!.first
                            } else {
                                teamName = "Unknown"
                            }
                        }
                        
                        let newActivity = Activity(name: activityName, sportsType: sportsType!, teamName: teamName!, username: username!, info: info, aid: aid, postTime: postTime, activityTime: activityTime, userId: userId, teamId: teamId!, maxAttendance: maxAttendance, attendedIds: attendedIds, location: location)
                        
                        self.myActivities.append(newActivity)
                        
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.sortByDate()
                        self.storeActivitiesToLocal()
                        self.shownActivities = self.myActivities
                        self.createCellHeightsArray()
                        self.tableView.reloadData()
                        self.teamActivityShown(self)
                    })
                }
            case .failure(let error):
                print(error)
                if let httpResponse = response.response {
                    if httpResponse.statusCode == 404 {
                        self.notifyFailure(info: "Currently no activities!")
                    } else {
                        self.notifyFailure(info: "Cannot connect to server!")
                    }
                } else {
                    self.notifyFailure(info: "Cannot connect to server!")
                }
                
            }
        }
    }
    
    func sortByDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        self.myActivities.sort(by: {dateFormatter.date(from: $0.postTime)! > dateFormatter.date(from: $1.postTime)!})
    }
    
    func storeActivitiesToLocal() {
        let activitiesToSave = myActivities.sorted(by: {$0.aid! < $1.aid!})
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: activitiesToSave)
        UserDefaults.standard.set(encodedData, forKey: "activities")
        UserDefaults.standard.synchronize()
    }
    
    func filterOutPersonalInShownData() {
        var filtered = [Activity]()
        for activity in shownActivities {
            if activity.teamId != -1 {
                filtered.append(activity)
            }
        }
        shownActivities = filtered
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
    
    // MARK: configure
    func createCellHeightsArray() {
        cellHeights.removeAll()
        kRowsCount = shownActivities.count
        if kRowsCount <= 0 {
            return
        }
        for _ in 0...kRowsCount-1 {
            cellHeights.append(kCloseCellHeight)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownActivities.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        guard case let cell as DemoCell = cell else {
            return
        }

        cell.backgroundColor = UIColor.clear

        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        
        let currentActivity = shownActivities[indexPath.row]
      
        cell.aid = currentActivity.aid
        cell.activityName = currentActivity.name
        cell.sportsType = currentActivity.sportsType
        cell.info = currentActivity.info
        cell.maxAttendance = currentActivity.maxAttendance
        cell.ownerName = currentActivity.getOwnerName()
        cell.location = currentActivity.location
        cell.attended = currentActivity.getAttendedAmount()
        
        let isPersonalOrTeamLabel = cell.contentView.viewWithTag(4) as! UILabel
        let organizorLabel = cell.contentView.viewWithTag(5) as! UILabel
        if currentActivity.isPersonal() {
            isPersonalOrTeamLabel.text = "Personal"
            organizorLabel.text = "Organizor"
            cell.contentView.viewWithTag(6)?.isHidden = true
        } else {
            isPersonalOrTeamLabel.text = "Team"
            organizorLabel.text = "Leading team"
            cell.contentView.viewWithTag(6)?.isHidden = false
            let leaderLabel = cell.contentView.viewWithTag(6) as! UILabel
            leaderLabel.text = "led by \(currentActivity.username!)"
        }
        
        if currentActivity.isFull() {
            cell.status = "Full"
        } else {
            cell.status = "Attended"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        
        let postTime = dateFormatter.date(from: currentActivity.postTime)
        let activityTime = dateFormatter.date(from: currentActivity.activityTime)
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        cell.postDate = dateFormatter.string(from: postTime!)
        cell.activityDate = dateFormatter.string(from: activityTime!)
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        cell.postTime = dateFormatter.string(from: postTime!)
        cell.activityTime = dateFormatter.string(from: activityTime!)
        
        
        cell.sportImage = currentActivity.sportsType
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    // MARK: Table vie delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight { // open cell
            cellHeights[(indexPath as NSIndexPath).row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[(indexPath as NSIndexPath).row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)

        
    }
}
