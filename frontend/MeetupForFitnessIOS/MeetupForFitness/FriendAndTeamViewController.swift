//
//  FriendAndTeamViewController.swift
//  Pods
//
//  Created by Mengyang Shi on 4/6/17.
//
//

import UIKit
import Alamofire

class FriendAndTeamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendOrTeamSegment: UISegmentedControl!
    
    var isFriend = true
    
    var friendData = [(Int, String)]()
    var teamData = [(Int, String)]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundIamge")!)
        self.tableView.backgroundColor = .clear
        self.friendOrTeamSegment.tintColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let searchUserBtn = UIBarButtonItem(title: "search user", style: .plain, target: self, action: #selector(FriendAndTeamViewController.searchUser))
        self.navigationItem.rightBarButtonItem = searchUserBtn
        self.navigationItem.title = "Friends"
        isFriend = true
        getFriendFromServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        friendOrTeamSegmentControl(self)
    }
    
    func searchUser() {
        print("search User")
        self.performSegue(withIdentifier: "searchUser", sender: self)
    }
    
    func createTeam() {
        print("create team")
        self.performSegue(withIdentifier: "createTeam", sender: self)
    }

    
    @IBAction func friendOrTeamSegmentControl(_ sender: Any) {
        switch friendOrTeamSegment.selectedSegmentIndex
        {
        case 0:
            let searchUserBtn = UIBarButtonItem(title: "search user", style: .plain, target: self, action: #selector(FriendAndTeamViewController.searchUser))
            self.navigationItem.rightBarButtonItem = searchUserBtn
            self.navigationItem.title = "Friends"
            isFriend = true
            tableView.reloadData()
            getFriendFromServer()
        case 1:
            let createTeamBtn = UIBarButtonItem(title: "create team", style: .plain, target: self, action: #selector(FriendAndTeamViewController.createTeam))
            self.navigationItem.rightBarButtonItem = createTeamBtn
            self.navigationItem.title = "Teams"
            isFriend = false
            tableView.reloadData()
            getTeamFromServer()
        default:
            break
        }
    }
    
    func getFriendFromServer() {
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/friends/\(userId)", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    self.friendData.removeAll()
                    
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    let array = result["Friends List"] as! [Dictionary<String, Any>]
                    for dict in array {
                        //print("dict ---> \(dict)")
                        let teamName = dict["username"] as! String
                        
                        let teamId = dict["userId"] as! Int
                        
                        self.friendData.append((teamId, teamName))
                        
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            case .failure(let error):
                print(error)
                if let httpResponse = response.response {
                    if httpResponse.statusCode == 404 {
                        self.notifyFailure(info: "Currently no friends!")
                    } else if httpResponse.statusCode == 400 {
                        self.notifyFailure(info: "You don't have friend now!")
                    } else {
                        self.notifyFailure(info: "Cannot connect to server!")
                    }
                } else {
                    self.notifyFailure(info: "Cannot connect to server!")
                }
                
            }
        }
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
                        self.notifyFailure(info: "Currently no activities!")
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
        self.performSegue(withIdentifier: "sendTeamInvite", sender: sender)
    }
    
    @IBAction func unwindFromSendFriendRequest(segue: UIStoryboardSegue) {
        if segue.source is SearchUserViewController {
            print("friend request sent!!!")
            DispatchQueue.main.async(execute: {
                self.sendAlart(info: "Friend request has been sent!")
            })
        }
        
    }
    
    @IBAction func unwindFromCreateTeam(segue: UIStoryboardSegue) {
        if segue.source is CreateTeamViewController {
            DispatchQueue.main.async(execute: {
                self.sendAlart(info: "New team has been created!")
            })
            
        }
    }
    
    @IBAction func unwindFromTeamInvite(segue: UIStoryboardSegue) {
        if segue.source is TeamInviteViewController {
            DispatchQueue.main.async(execute: {
                self.sendAlart(info: "Your friend has been invited to join your team!")
            })
            
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
        if isFriend {
            return friendData.count
        }
        return teamData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "friendOrTeamCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let addToTeamButton = cell.contentView.viewWithTag(2) as! AddButton
        
        nameLabel.textColor = .white
        
        var currentData: (Int, String)!
        if isFriend {
            currentData = friendData[indexPath.row]
            addToTeamButton.isHidden = false
            addToTeamButton.addTarget(self, action: #selector(self.sendTeamInvitation(_:)), for: .touchUpInside)
            addToTeamButton.indexPath = indexPath.row
            addToTeamButton.anotherId = currentData.0
            
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
        } else {
            currentData = teamData[indexPath.row]
            addToTeamButton.isHidden = true
            
            cell.selectionStyle = .default // to prevent cells from being "highlighted"
        }
        
        nameLabel.text = currentData.1
        
        cell.backgroundColor = .clear
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isFriend {
            self.performSegue(withIdentifier: "showTeamMember", sender: teamData[indexPath.row].0)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "sendTeamInvite" {
            let destination = segue.destination as! TeamInviteViewController
            destination.receiverId = (sender as! AddButton).anotherId!
        } else if segue.identifier == "showTeamMember" {
            let destination = segue.destination as! TeamMemberViewController
            destination.teamId = sender as! Int
        }
        
    }
    

}
