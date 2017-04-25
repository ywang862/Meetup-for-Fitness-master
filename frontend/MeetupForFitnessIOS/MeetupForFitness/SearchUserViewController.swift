//
//  SearchUserViewController.swift
//  Pods
//
//  Created by Mengyang Shi on 4/6/17.
//
//

import UIKit
import Alamofire
class SearchUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResult = [(Int, String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundIamge")!)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        searchField.delegate = self
    }

    
    
    @IBAction func searchForUser(_ sender: Any) {
        self.view.endEditing(true)
        
        if searchField.text! == ""  {
            sendAlart(info: "Please fill in search field before searching!")
            return
        }
        
        let parameters: Parameters = [
            "uName": searchField.text ?? " "
        ]
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/friends/search", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    self.searchResult.removeAll()
                    
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    let array = result["userNameList"] as! [Dictionary<String, Any>]
                    for dict in array {
                        //print("dict ---> \(dict)")
                        let userName = dict["username"] as! String
                        
                        let userId = dict["userId"] as! Int
                        
                        self.searchResult.append((userId, userName))
                        
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            case .failure(let error):
                print(error)
                self.notifyFailure(info: "Username doesn't exist!")
            }
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendFriendRequest(_ sender : AddButton) {
        if sender.anotherId == nil {
            print("some errors here")
            return
        }
        
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        
        sender.isEnabled = false
        
        let parameters: Parameters = [
            "senderId": userId,
            "receiverId": sender.anotherId!,
            "teamId": -1
        ]
        print("param ---> \(parameters)")
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/notification/add", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
            switch response.result {
            case .success:
                print("Response String: \(response.result.value!)")
                if response.result.value! == "success" {
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "unwindSentFriendRequest", sender: self)
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
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "searchUserCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let currentUser = searchResult[indexPath.row]
        let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
        nameLabel.text = currentUser.1
        
        nameLabel.textColor = .white
        
        let addFriendButton = cell.contentView.viewWithTag(2) as! AddButton
        addFriendButton.addTarget(self, action: #selector(self.sendFriendRequest(_:)), for: .touchUpInside)
        addFriendButton.indexPath = indexPath.row
        addFriendButton.anotherId = currentUser.0
        
        
        cell.selectionStyle = .none // to prevent cells from being "highlighted"
        
        cell.backgroundColor = .clear
        
        return cell
        
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
