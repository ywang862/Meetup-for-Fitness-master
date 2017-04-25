from flask import Flask, jsonify, request, abort
from flask.ext.mysql import MySQL
import json, codecs
import boto3
from werkzeug.utils import secure_filename
import datetime

config = json.load(codecs.open('config.json', encoding='utf-8'))
app = Flask(__name__)
mysql = MySQL()
client = boto3.client('s3')

app.config['MYSQL_DATABASE_USER'] = config['db_user']
app.config['MYSQL_DATABASE_PASSWORD'] = config['db_passwd']
app.config['MYSQL_DATABASE_DB'] = config['db_db']
app.config['MYSQL_DATABASE_HOST'] = config['db_host']
mysql.init_app(app)

@app.route('/auth/login',methods=['POST'])
def auth_login():
	if not request.json or not 'username' in request.json or not 'password' in request.json:
		abort(400, '{"message":"false"}')
	username = request.json['username']
	password = request.json['password']
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT * FROM User WHERE username = %s AND password = %s",[username,password])
	if cursor.rowcount == 1:
			results = cursor.fetchall()
			userId = results[0][0]
			db.close()
			return json.dumps({'existing user':True,'userId':userId})
	else: 
		db.rollback()
		db.close()
		return json.dumps({'existing user':False}) 

@app.route('/auth/signup', methods=['POST'])
def auth_signup():
	if not request.json or not 'username' in request.json or not 'password' in request.json or not 'gender' in request.json or not 'email' in request.json or not 'avatarURL' in request.json or not 'description' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	username = request.json['username']
	password = request.json['password']
	gender = request.json['gender']
	email = request.json['email']
	avatarURL = request.json['avatarURL']
	description = request.json['description']
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT * FROM User WHERE username = '%s'"%username)
	if cursor.rowcount == 0:
		try:
			cursor.execute("INSERT INTO User(username,password,gender,email,avatarURL,description) values (%s,%s,%s,%s,%s,%s)",[username,password,gender,email,avatarURL,description])
			userId = cursor.lastrowid
			db.commit()
			db.close()
			return json.dumps({'insert successful':True,'userId':userId})
		except:
			db.rollback()
			db.close()
	   		abort(400, '{Insert unsuccessful!!!"}')
	else:
		db.rollback()
		db.close()
		abort(404, '{fail: user exists!!!}')

@app.route('/auth/update/<userId>', methods=['POST'])
def auth_update(userId):
	if not request.json or not 'gender' in request.json or not 'email' in request.json or not 'description' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	gender = request.json['gender']
	email = request.json['email']
	description = request.json['description']
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT * FROM User WHERE userId = '%s'"%userId)
	if cursor.rowcount == 1:
		cursor.execute("UPDATE User SET gender = %s,email = %s,description = %s WHERE userId = %s", [gender,email,description,userId])
		db.commit()
		db.close()
		return("Success") 
	else:
		db.rollback()
		db.close()
		abort(400, 'fail')


@app.route('/activity', methods=['GET'])
def get_all_activity():	
	activityList = []
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT * FROM Activity ORDER BY postTime;")
	if cursor.rowcount > 0:
		aList = cursor.fetchall()
		for aRow in aList:
			userId = aRow[0]
			aid = aRow[1]
			aName = aRow[2]
			aInfo = aRow[3]
			location = aRow[4]
			aTime = aRow[5]
			postTime = aRow[6]
			sportsId = aRow[7]
			maxPeople = aRow[8]
			teamId = aRow[9]
			attended=aRow[10]
			sportsCur = db.cursor()
 			sportsCur.execute("SELECT username FROM User WHERE userId ='%s'"%userId)
			username = [item[0] for item in sportsCur.fetchall()]
			sportsCur.execute("SELECT sportsType FROM SportsType WHERE sportsId = '%s'" %sportsId)
			sportsType = [item[0] for item in sportsCur.fetchall()]
			sportsCur.execute("SELECT userId FROM AttendActivity WHERE aid = '%s'"%aid)
			attendList = []
			if sportsCur.rowcount > 0:
				attendR = sportsCur.fetchall()
				for a in attendR:
					attendList.append(a[0])
			if teamId == -1:
				currentActivity = {}
				currentActivity['username'] = username
				currentActivity['userId'] = userId
				currentActivity['aid'] = aid
				currentActivity['aName'] = aName
				currentActivity['aInfo'] = aInfo
				currentActivity['location'] = location
				currentActivity['aTime'] = aTime
				currentActivity['postTime'] = postTime
				currentActivity['sportsType'] = sportsType
				currentActivity['maxPeople'] = maxPeople
				currentActivity['attended'] = attendList
				activityList.append(currentActivity)
			else:
				teamCur = db.cursor()
				teamCur.execute("SELECT tName FROM TeamInfo WHERE teamId = '%s'" %teamId)
				tName = [item[0] for item in teamCur.fetchall()]
				currentActivity = {}
				currentActivity['userId'] = userId
				currentActivity['username'] = username
				currentActivity['aid'] = aid
				currentActivity['aName'] = aName
				currentActivity['aInfo'] = aInfo
				currentActivity['location'] = location
				currentActivity['aTime'] = aTime
				currentActivity['postTime'] = postTime
				currentActivity['sportsType'] = sportsType
				currentActivity['maxPeople'] = maxPeople
				currentActivity['attended'] = attendList
				currentActivity['teamId'] = teamId
				currentActivity['teamName'] = tName
				activityList.append(currentActivity)
		db.close()
		return jsonify({'activities':activityList})
	else:
		db.close()
		abort(404, '{"message":"no activity"}')

@app.route('/activity/<userId>', methods=['GET'])
def get_user_activity(userId):	
	activityList = []
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT aid FROM AttendActivity WHERE userId = '%s'"%userId)
	if cursor.rowcount > 0:
		aidList = cursor.fetchall()
		for a in aidList:
			aCur = db.cursor()
			aCur.execute("SELECT * FROM Activity WHERE aid = '%s'"%a)
			aList = aCur.fetchall()
			for aRow in aList:
				uid = aRow[0]
				aid = aRow[1]
				aName = aRow[2]
				aInfo = aRow[3]
				location = aRow[4]
				aTime = aRow[5]
				postTime = aRow[6]
				sportsId = aRow[7]
				maxPeople = aRow[8]
				teamId = aRow[9]
				attended = aRow[10]
				sportsCur = db.cursor()
				sportsCur.execute("SELECT username FROM User WHERE userId ='%s'"%userId)
				username = [item[0] for item in sportsCur.fetchall()]
				sportsCur.execute("SELECT sportsType FROM SportsType WHERE sportsId = '%s'" %sportsId)
				sportsType = [item[0] for item in sportsCur.fetchall()]
				sportsCur.execute("SELECT userId FROM AttendActivity WHERE aid = '%s'"%aid)
				attendList = []
				if sportsCur.rowcount > 0:
					attendR = sportsCur.fetchall()
					for a in attendR:
						attendList.append(a[0])
				if teamId == -1:
					currentActivity = {}
					currentActivity['username'] = username
					currentActivity['userId'] = uid
					currentActivity['aid'] = aid
					currentActivity['aName'] = aName
					currentActivity['aInfo'] = aInfo
					currentActivity['location'] = location
					currentActivity['aTime'] = aTime
					currentActivity['postTime'] = postTime
					currentActivity['sportsType'] = sportsType
					currentActivity['maxPeople'] = maxPeople
					currentActivity['attended'] = attendList
					activityList.append(currentActivity)
				else:
					teamCur = db.cursor()
					teamCur.execute("SELECT tName FROM TeamInfo WHERE teamId = '%s'" %teamId)
					tName = [item[0] for item in teamCur.fetchall()]
					currentActivity = {}
					currentActivity['username'] = username
					currentActivity['userId'] = uid
					currentActivity['aid'] = aid
					currentActivity['aName'] = aName
					currentActivity['aInfo'] = aInfo
					currentActivity['location'] = location
					currentActivity['aTime'] = aTime
					currentActivity['postTime'] = postTime
					currentActivity['sportsType'] = sportsType
					currentActivity['maxPeople'] = maxPeople
					currentActivity['attended'] = attendList
					currentActivity['teamId'] = teamId
					currentActivity['teamName'] = tName
					activityList.append(currentActivity)
		db.close()
		return jsonify({'activities':activityList})
	else:
		db.close()
		abort(404, '{"message":"no activity"}')

@app.route('/activity/invite/<userId>',methods=['GET'])
def get_user_invite(userId):
	inviteList = []
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT aid FROM FriendInvite Where friendId = '%s'"%userId)
	if cursor.rowcount > 0:
		aList = [item[0] for item in cursor.fetchall()]
		for a in aList:
			aCur = db.cursor()
			aCur.execute("SELECT userId FROM AttendActivity WHERE aid = %s AND userId = %s",[a,userId])
			if aCur.rowcount == 0:
				aCur.execute("SELECT maxPeople,attended From Activity WHERE aid = '%s'"%a)
				aRow = aCur.fetchall()[0]
				maxPeople = int(aRow[0])
				attended = int(aRow[1])
				if attended < maxPeople:
					inviteList.append(a)
				else:
					aCur.execute("DELETE FROM FriendInvite WHERE aid = %s AND friendId = %s",[a,userId])
					db.commit()
					
			else:
				aCur.execute("DELETE FROM FriendInvite WHERE aid = %s AND friendId = %s",[a,userId])
				db.commit()
		db.close()
		return jsonify({'Activities Invited':inviteList})
	else:
		db.close()
		abort(400,"fail")

@app.route('/activity/attend',methods=['POST'])
def attend_activity():
	if not request.json or not 'userId' in request.json or not "aid" in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	aid = request.json['aid']
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT maxPeople,attended FROM Activity WHERE aid = '%s'"%aid)
	aRow = cursor.fetchall()[0]
	maxPeople = int(aRow[0])
	attended = int(aRow[1])
	attended = attended + 1
	if attended <= maxPeople:
		cursor.execute("UPDATE Activity SET attended = '%s' WHERE aid = %s",[attended,aid])
		cursor.execute("INSERT INTO AttendActivity(aid,userId) values(%s,%s)",[aid,userId])
		db.commit()
		db.close()
		return'success'
	else:
		db.rollback()
		db.close()
		return 'fail'


@app.route('/activity/add/allInfo/<userId>', methods=['POST'])
def add_activity(userId):
	if not request.json or not 'aName' in request.json or not 'aInfo' in request.json \
	or not 'location' in request.json or not 'aTime' in request.json or not 'sportsType' in request.json \
	or not 'maxPeople' in request.json or not 'teamId' in request.json or not 'friendList' in request.json: 
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	aName = request.json['aName']
	aInfo = request.json['aInfo']
	location = request.json['location']
	aTime = request.json['aTime']
	sportsType = request.json['sportsType']
	maxPeople = request.json['maxPeople']
	teamId = request.json['teamId']
	friendList = request.json['friendList']
	postTime = datetime.datetime.now()
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT sportsId FROM SportsType WHERE sportsType = '%s'"%sportsType)
	sportsId = [item[0] for item in cursor.fetchall()]
	try:
		cursor.execute("INSERT INTO Activity(userId,aName,aInfo,location,aTime,postTime,sportsId,maxPeople,teamId,attended) values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", \
			[userId,aName,aInfo,location,aTime,postTime,sportsId,maxPeople,teamId,0])
		aid = cursor.lastrowid
		cursor.execute("INSERT INTO FriendInvite(aid,friendId) values (%s,%s)",[aid,userId])
		for friend in friendList:
			friendCur = db.cursor()
			friendCur.execute("INSERT INTO FriendInvite(aid,friendId) values (%s,%s)",[aid,friend])
		db.commit()
		db.close()
		return("success")
	except:	
		db.rollback()
		db.close()
		abort(400,"fail")

@app.route('/activity/sportsType', methods=['GET'])
def get_sportsType():
	sportsList = []
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT sportsType FROM SportsType") 
	if cursor.rowcount > 0:
		sportsList = [item[0] for item in cursor.fetchall()]
		db.close()
		return jsonify({'SportsType':sportsList})
	else :
		db.close()
		abort(400,"fail")

@app.route('/friends/<userId>', methods=['GET'])
def get_user_friends(userId):
	friendList = []
	result =[]
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT friendId FROM Friends WHERE userId = '%s'"%userId) 
	if cursor.rowcount > 0:
		friendList = [item[0] for item in cursor.fetchall()]
		friendList = map(int, friendList)
		for f in friendList:
 			friendCur = db.cursor()
 			friendCur.execute("SELECT userId,username FROM User WHERE userId ='%s'"%f)
			temp = friendCur.fetchall()[0]
			temp1 = {}
			temp1["userId"] = temp[0]
			temp1["username"] = temp[1]
			result.append(temp1)
		db.close()
		return jsonify({'Friends List':result})
	else :
		db.close()
		abort(400,"fail")


@app.route('/friends/search',methods=['POST'])
def search_friends():
	nameList = []
	result = []
	if not request.json or not 'uName' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	uName = request.json['uName']
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT username FROM User")
	nameList = [item[0] for item in cursor.fetchall()]
	for n in nameList:
		if uName.lower() in n.lower():
			friendCur = db.cursor()
			friendCur.execute("SELECT userId,username FROM User WHERE username ='%s'"%n)
			temp = friendCur.fetchall()[0]
			temp1 = {}
			temp1["userId"] = temp[0]
			temp1["username"] = temp[1]
			result.append(temp1)
	db.close()
	return jsonify({'userNameList':result})

@app.route('/friends/add/<userId>', methods=['POST'])
def add_friends(userId):
	if not request.json or not 'friendId' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	friendId = request.json['friendId']
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT friendId FROM Friends WHERE userId = %s AND friendId = %s",[userId,friendId]) 
	if cursor.rowcount == 0:
		cursor.execute("INSERT INTO Friends(userId, friendId) values (%s,%s)",[userId,friendId])
		cursor.execute("INSERT INTO Friends(userId, friendId) values (%s,%s)",[friendId,userId])
		db.commit()
		db.close()
		return("success")
	else:
		db.rollback()
		db.close()
		return("fail")

@app.route('/teams/<userId>', methods=['GET'])
def get_user_teams(userId):
	teamList = []
	result =[]
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT teamId FROM TeamPlayer WHERE userId = '%s'"%userId) 
	if cursor.rowcount > 0:
		teamList = [item[0] for item in cursor.fetchall()]
		teamList = map(int, teamList)
		for t in teamList:
 			teamCur = db.cursor()
 			teamCur.execute("SELECT teamId,tName FROM TeamInfo WHERE teamId ='%s'"%t)
			temp = teamCur.fetchall()[0]
			temp1 = {}
			temp1["teamId"] = temp[0]
			temp1["tname"] = temp[1]
			teamCur.execute("SELECT tName FROM TeamInfo WHERE userId = %s AND teamId = %s",[userId,t])
			if teamCur.rowcount == 1:
				temp1["isLeader"] = True
			else:
				temp1["isLeader"] = False
			result.append(temp1)
		db.close()
		return jsonify({'Team List':result})
	else :
		db.close()
		abort(400,"fail")

@app.route('/teams/member/<teamId>', methods=['GET'])
def get_team_member(teamId):
	result = []
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT userId FROM TeamInfo WHERE teamId = '%s'"%teamId)
	if cursor.rowcount == 1:
		owner = [item[0] for item in cursor.fetchall()]
	cursor.execute("SELECT userId FROM TeamPlayer WHERE teamId = '%s'"%teamId)
	if cursor.rowcount > 0:
		memberList = [item[0] for item in cursor.fetchall()]
		for m in memberList:
			mCur = db.cursor()
 			mCur.execute("SELECT userId,username FROM User WHERE userId ='%s'"%m)
			temp = mCur.fetchall()[0]
			temp2 = {}
			temp2["userId"] = temp[0]
			temp2["username"] = temp[1]
			result.append(temp2)
		db.close()
		return jsonify({'Team Member List':result,'Team Leader':owner})
	else:
		db.close()
		abort(400,"fail")

@app.route('/teams/search',methods=['POST'])
def search_team():
	nameList = []
	result = []
	if not request.json or not 'tName' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	tName = request.json['tName']
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT tName FROM TeamInfo")
	nameList = [item[0] for item in cursor.fetchall()]
	for n in nameList:
		if tName.lower() in n.lower():
			friendCur = db.cursor()
			friendCur.execute("SELECT teamId,tName FROM TeamInfo WHERE tName ='%s'"%n)
			temp = friendCur.fetchall()[0]
			temp1 = {}
			temp1["teamId"] = temp[0]
			temp1["tName"] = temp[1]
			result.append(temp1)
	db.close()
	return jsonify({'userNameList':result})

@app.route('/teams/add/allInfo/<userId>', methods=['POST'])
def add_team(userId):
	if not request.json or not 'tName' in request.json or not 'tInfo' in request.json or not 'sportsType' in request.json: 
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	tName = request.json['tName']
	tInfo = request.json['tInfo']
	sportsType = request.json['sportsType']
	postTime = datetime.datetime.now()
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT sportsId FROM SportsType WHERE sportsType = '%s'"%sportsType)
	sportsId = [item[0] for item in cursor.fetchall()]
	try:
		cursor.execute("INSERT INTO TeamInfo(userId,tName,tInfo,postTime,sportsId) values (%s,%s,%s,%s,%s)",[userId,tName,tInfo,postTime,sportsId])
		teamId = cursor.lastrowid
		cursor.execute("INSERT INTO TeamPlayer(userId,teamId) values (%s,%s)",[userId, teamId])
		db.commit()
		db.close()
		return("success")
	except:
		db.rollback()
		db.close()
		return("fail")

@app.route('/teams/add/member/<teamId>', methods=['POST'])
def add_team_member(teamId):
	if not request.json or not 'userId' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT userId FROM TeamPlayer WHERE userId = %s AND teamId = %s",[userId,teamId]) 
	if cursor.rowcount == 0:
		cursor.execute("INSERT INTO TeamPlayer(userId, teamId) values (%s,%s)",[userId,teamId])
		db.commit()
		db.close()
		return("success")
	else:
		db.rollback()
		db.close()
		return("fail")

@app.route('/notification/add', methods=['POST'])
def add_notification():
	if not request.json or not 'senderId' in request.json \
	or not 'receiverId' in request.json or not 'teamId' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	senderId = request.json['senderId']
	receiverId = request.json['receiverId']
	teamId = request.json['teamId']
	postTime = datetime.datetime.now()
	db = mysql.connect()
	cursor = db.cursor()
	try:
		cursor.execute("SELECT * FROM Notification WHERE senderId = %s AND receiverId = %s",[senderId,receiverId])
		if cursor.rowcount == 0:
			cursor.execute("INSERT INTO Notification(senderId,receiverId,teamId,postTime) values(%s,%s,%s,%s)",[senderId,receiverId,teamId,postTime])
			ntfyId = cursor.lastrowid
			db.commit()
			db.close()
			return("success")
		else:
			db.close()
			return("success")
	except:
		db.rollback()
		db.close()
		return("fail")


@app.route('/notification/<receiverId>', methods=['GET'])
def get_notification(receiverId):
	notifyList = []
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT ntfyId FROM Notification WHERE receiverId = '%s'"%receiverId)
	if cursor.rowcount > 0:
		noList = cursor.fetchall()
		for n in noList:
			nCur = db.cursor()
			nCur.execute("SELECT * FROM Notification WHERE ntfyId = '%s'"%n)
			nList = nCur.fetchall() 
			for nRow in nList:
				ntfyId = nRow[0]
				senderId = nRow[1]
				receiverId = nRow[2]
				teamId = nRow[3]
				postTime = nRow[4]
				nameCur = db.cursor()
				nameCur.execute("SELECT username FROM User WHERE userId = '%s'" %senderId)
				username = [item[0] for item in nameCur.fetchall()]
				result = []
				if teamId == -1:
					mCur = db.cursor()
					mCur.execute("SELECT * FROM Friends WHERE userId = %s AND friendId = %s",[senderId,receiverId])
					if mCur.rowcount > 0:
						pCur = db.cursor()
						pCur.execute("DELETE FROM Notification WHERE ntfyId = '%s'"%ntfyId)
						db.commit()
					else: 
						currentN = {}
						currentN['ntfyId'] = ntfyId
						currentN['senderId'] = senderId
						currentN['username'] = username
						currentN['postTime'] = postTime
						notifyList.append(currentN)

				else:
					mCur = db.cursor()
					mCur.execute("SELECT * FROM TeamPlayer WHERE userId = %s AND teamId = %s",[receiverId,teamId])
					if mCur.rowcount == 0:
						mCur.execute("SELECT tName FROM TeamInfo WHERE teamId = '%s'"%teamId)
						tName = [item[0] for item in mCur.fetchall()]
						currentN = {}
						currentN['ntfyId'] = ntfyId
						currentN['senderId'] = senderId
						currentN['username'] = username
						currentN['teamId'] = teamId
						currentN['tName'] = tName
						currentN['postTime'] = postTime
						notifyList.append(currentN)
					else:
						mCur.execute("DELETE FROM Notification WHERE ntfyId = %s"%ntfyId)
						db.commit()
		db.close()
		return jsonify({'notifications':notifyList})	
	else: 
		db.close()
		abort(404, '{"message":"no notification"}')

@app.route('/user/info/<userId>', methods=['GET'])
def get_user_info(userId):
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT username,gender,email,description FROM User WHERE userId = '%s'"%userId)
	if cursor.rowcount == 1:
		infoList = cursor.fetchall()[0]
		temp = {}
		temp["username"] = infoList[0]
		temp["gender"] = infoList[1]
		temp["email"] = infoList[2]
		temp["description"] = infoList[3]
		db.close()
		return jsonify({'Info':temp})
	else:
		db.close()
		abort(404, 'no user exists')

if __name__ == '__main__':
	app.run(host='0.0.0.0',port='80')
	#app.run()