//
//  UserProfileViewController.swift
//  MeetupForFitness
//
//  Created by Mengyang Shi on 4/9/17.
//  Copyright © 2017 TFBOYZ. All rights reserved.
//

import UIKit
import Alamofire
class UserProfileViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var editProfileView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundIamge")!)
        
        notificationView.backgroundColor = .clear
        editProfileView.backgroundColor = .clear
        logoutView.backgroundColor = .clear
        profileView.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = notificationView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        notificationView.addSubview(blurEffectView)
        notificationView.bringSubview(toFront: notificationButton)
        
        let blurEffectView2 = UIVisualEffectView(effect: blurEffect)
        blurEffectView2.frame = editProfileView.bounds
        blurEffectView2.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        editProfileView.addSubview(blurEffectView2)
        editProfileView.bringSubview(toFront: editProfileButton)
        
        let blurEffectView3 = UIVisualEffectView(effect: blurEffect)
        blurEffectView3.frame = logoutView.bounds
        blurEffectView3.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        logoutView.addSubview(blurEffectView3)
        logoutView.bringSubview(toFront: logoutButton)
        
        let blurEffectView4 = UIVisualEffectView(effect: blurEffect)
        blurEffectView4.frame = profileView.bounds
        blurEffectView4.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        profileView.addSubview(blurEffectView4)
        profileView.sendSubview(toBack: blurEffectView4)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserInfo()
    }

    func getUserInfo() {
        let ud = UserDefaults.standard
        let userId = ud.integer(forKey: "currentUserId")
        
        Alamofire.request("http://@ec2-52-7-74-13.compute-1.amazonaws.com/user/info/\(userId)", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    let dict = result["Info"] as! Dictionary<String, Any>
                    
                    DispatchQueue.main.async(execute: {
                        self.usernameLabel.text = "\(dict["username"] as! String)"
                        self.emailLabel.text = "\(dict["email"] as! String)"
                        self.genderLabel.text = "\(dict["gender"] as! String)"
                        self.descriptionLabel.text = "\(dict["description"] as! String)"
                        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
