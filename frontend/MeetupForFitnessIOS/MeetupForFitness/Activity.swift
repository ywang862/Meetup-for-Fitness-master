//
//  Activity.swift
//  MeetupForFitness
//
//  Created by Mengyang Shi on 3/27/17.
//  Copyright © 2017 TFBOYZ. All rights reserved.
//

import UIKit

class Activity: NSObject, NSCoding {
    let location: String!
    let name: String!
    let sportsType: String!
    let teamName: String!
    let username: String!
    let info: String!
    let aid: Int!
    let postTime: String!
    let activityTime: String!
    let userId: Int!
    let teamId: Int!
    let maxAttendance: Int!
    var attendedIds: [Int]!
    
    init(name: String, sportsType: String, teamName: String, username: String, info: String, aid: Int, postTime: String, activityTime: String, userId: Int, teamId: Int, maxAttendance: Int, attendedIds: [Int], location: String) {
        self.name = name
        self.sportsType = sportsType
        self.teamName = teamName
        self.username = username
        self.info = info
        self.aid = aid
        self.postTime = postTime
        self.activityTime = activityTime
        self.userId = userId
        self.teamId = teamId
        self.maxAttendance = maxAttendance
        self.attendedIds = attendedIds
        self.location = location
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.sportsType = decoder.decodeObject(forKey: "sportsType") as! String
        self.teamName = decoder.decodeObject(forKey: "teamName") as! String
        self.username = decoder.decodeObject(forKey: "username") as! String
        self.info = decoder.decodeObject(forKey: "info") as! String
        self.aid = decoder.decodeInteger(forKey: "aid")
        self.postTime = decoder.decodeObject(forKey: "postTime") as! String
        self.activityTime = decoder.decodeObject(forKey: "activityTime") as! String
        self.userId = decoder.decodeInteger(forKey: "userId")
        self.teamId = decoder.decodeInteger(forKey: "teamId")
        self.maxAttendance = decoder.decodeInteger(forKey: "maxAttendance")
        self.attendedIds = decoder.decodeObject(forKey: "attendedIds") as! [Int]
        self.location = decoder.decodeObject(forKey: "location") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(sportsType, forKey: "sportsType")
        aCoder.encode(teamName, forKey: "teamName")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(info, forKey: "info")
        if let aid = aid {
            aCoder.encode(aid, forKey: "aid")
        }
        aCoder.encode(postTime, forKey: "postTime")
        aCoder.encode(activityTime, forKey: "activityTime")
        if let userId = userId {
            aCoder.encode(userId, forKey: "userId")
        }
        if let teamId = teamId {
            aCoder.encode(teamId, forKey: "teamId")
        }
        if let maxAttendance = maxAttendance {
            aCoder.encode(maxAttendance, forKey: "maxAttendance")
        }
        aCoder.encode(attendedIds, forKey: "attendedIds")
        aCoder.encode(location, forKey: "location")
        
    }
    
    func getAttendedAmount() -> Int {
        return self.attendedIds.count
    }
    
    func isPersonal() -> Bool {
        return self.teamId <= -1
    }
    
    func getOwnerName() -> String {
        if self.isPersonal() {
            return username
        }
        return teamName
    }
    
    func isFull() -> Bool {
        return self.getAttendedAmount() >= self.maxAttendance
    }
    
    func hasAttended(uid: Int) -> Bool {
        return attendedIds.contains(uid)
    }
    
    func newUserAttended(uid: Int) {
        attendedIds.append(uid)
    }
    

}
