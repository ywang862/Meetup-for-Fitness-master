//
//  DemoCell.swift
//  FoldingCell
//
//  Created by Alex K. on 25/12/15.
//  Modified by Mengyang Shi on 3/28/17
//  Copyright © 2015 Alex K. All rights reserved.
//

import UIKit

class DemoCell: FoldingCell {
  
    @IBOutlet weak var closeNumberLabel: UILabel!
    @IBOutlet weak var openNumberLabel: UILabel!
    
    @IBOutlet weak var activityNameField: UILabel!
    
    @IBOutlet weak var closeSportsTypeField: UILabel!
    @IBOutlet weak var openSportsTypeField: UILabel!
  
    @IBOutlet weak var infoField: UILabel!
    
    @IBOutlet weak var maxAttendanceField: UILabel!
    
    @IBOutlet weak var usernameField: UILabel!
    
    @IBOutlet weak var locationField: UILabel!
    
    @IBOutlet weak var attendedField: UILabel!
    
    @IBOutlet weak var postTimeField: UILabel!
    
    @IBOutlet weak var postDateField: UILabel!
    
    @IBOutlet weak var activityTimeField: UILabel!
    
    @IBOutlet weak var activityDateField: UILabel!
    
    @IBOutlet weak var statusField: UILabel!
    
    @IBOutlet weak var sportsImageView: UIImageView!
    
    var aid: Int = 0 {
        didSet {
            closeNumberLabel.text = "#\(aid)"
            openNumberLabel.text = "#\(aid)"
        }
    }
    
    var activityName = " " {
        didSet {
            activityNameField.text = activityName
        }
    }
    
    var sportsType = " " {
        didSet {
            closeSportsTypeField.text = sportsType
            openSportsTypeField.text = sportsType
        }
    }
    
    var info = " " {
        didSet {
            infoField.text = info
        }
    }
    
    var maxAttendance = 0 {
        didSet {
            maxAttendanceField.text = "\(maxAttendance)"
        }
    }
    
    var ownerName = " " {
        didSet {
            usernameField.text = ownerName
        }
    }
    
    var location = " " {
        didSet {
            locationField.text = location
        }
    }
    
    var attended = 0 {
        didSet {
            attendedField.text = "\(attended)"
        }
    }
    
    var postTime = " " {
        didSet {
            postTimeField.text = postTime
        }
    }
    var postDate = " " {
        didSet {
            postDateField.text = postDate
        }
    }
    
    var activityTime = " " {
        didSet {
            activityTimeField.text = activityTime
        }
    }
    var activityDate = " " {
        didSet {
            activityDateField.text = activityDate
        }
    }
    
    var status = " " {
        didSet {
            statusField.text = status
        }
    }
    
    var sportImage = "background" {
        didSet {
            sportsImageView.image = UIImage(named: "\(sportImage)_background")
        }
    }

    override func awakeFromNib() {

        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true

        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {

        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
}

// MARK: Actions
extension DemoCell {

    @IBAction func buttonHandler(_ sender: AnyObject) {
        print("tap")
    }
}
