MDBMgr ; M/DB: Mumps Emulation of Amazon SimpleDB: Manager Portal Scripts
 ;
 ; ----------------------------------------------------------------------------
 ; | M/DB                                                                     |
 ; | Copyright (c) 2004-9 M/Gateway Developments Ltd,                         |
 ; | Reigate, Surrey UK.                                                      |
 ; | All rights reserved.                                                     |
 ; |                                                                          |
 ; | http://www.mgateway.com                                                  |
 ; | Email: rtweed@mgateway.com                                               |
 ; |                                                                          |
 ; | This program is free software: you can redistribute it and/or modify     |
 ; | it under the terms of the GNU Affero General Public License as           |
 ; | published by the Free Software Foundation, either version 3 of the       |
 ; | License, or (at your option) any later version.                          |
 ; |                                                                          |
 ; | This program is distributed in the hope that it will be useful,          |
 ; | but WITHOUT ANY WARRANTY; without even the implied warranty of           |
 ; | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            |
 ; | GNU Affero General Public License for more details.                      |
 ; |                                                                          |
 ; | You should have received a copy of the GNU Affero General Public License |
 ; | along with this program.  If not, see <http://www.gnu.org/licenses/>.    |
 ; ----------------------------------------------------------------------------
 ;
 QUIT
 ;
checkBrowser(sessid)
 ;
 n browser
 s browser=$$getServerValue^%zewdAPI("HTTP_USER_AGENT",sessid)
 s browser=$$zcvt^%zewdAPI(browser,"l")
 i browser["ipod"!(browser["ipad")!(browser["iphone") d
 . d setSessionValue^%zewdAPI("ewd_appName","imdb",sessid)
 . d setRedirect^%zewdAPI("index",sessid)
 QUIT ""
 ;
isMDBConfigured(sessid)
 n isConfigured
 s isConfigured=$d(^MDBUAF("administrator"))
 d setSessionValue^%zewdAPI("isConfigured",isConfigured,sessid)
 QUIT ""
 ;
initialise(sessid)
 ;
 i '$d(^MDBUAF("administrator")) d setRedirect^%zewdAPI("initialise",sessid) QUIT ""
 d setRedirect^%zewdAPI("login",sessid) QUIT ""
 QUIT ""
 ;
aboutAppliance(sessid)	
	;
	d setSessionValue^%zewdAPI("mdbva_version",$$version^MDB(),sessid)
	d setSessionValue^%zewdAPI("mdbva_os",$$getLinuxBuild^%zewdGTM(),sessid)
	d setSessionValue^%zewdAPI("mdbva_date",$$buildDate^MDB(),sessid)
	d setSessionValue^%zewdAPI("gtm_version",$zv,sessid)
	d setSessionValue^%zewdAPI("mgwsi_version","2.0.49",sessid)
	d setSessionValue^%zewdAPI("gtm_dateTime",$$inetDate^%zewdAPI($h),sessid)
	d setSessionValue^%zewdAPI("ewdVersion",$$version^%zewdAPI(),sessid)
	d setSessionValue^%zewdAPI("ewd_ip",$$getIP^%zewdGTM(),sessid)
	;
	QUIT ""
	;
login(sessid)
 n username,password
 s username=$$getSessionValue^%zewdAPI("username",sessid)
 s password=$$getSessionValue^%zewdAPI("password",sessid)
 i $$getSessionValue^%zewdAPI("ewd_appName",sessid)'="imdb" d
 . d deleteFromSession^%zewdAPI("username",sessid)
 . d deleteFromSession^%zewdAPI("password",sessid)
 i username="" QUIT "You must enter a username"
 i $g(^MDBUAF("administrator"))'=username QUIT "Invalid login attempt"
 i password="" QUIT "You must enter the secret key"
 i $g(^MDBUAF("keys",username))'=password QUIT "Invalid login attempt"
 QUIT ""
 ;
addUser(sessid)
 n username,password
 s username=$$getSessionValue^%zewdAPI("username",sessid)
 s password=$$getSessionValue^%zewdAPI("password",sessid)
 d deleteFromSession^%zewdAPI("username",sessid)
 d deleteFromSession^%zewdAPI("password",sessid)
 i username="" QUIT "You must enter a username"
 i password="" QUIT "You must enter the secret key"
 s ^MDBUAF("keys",username)=password
 QUIT ""
 ;
getUsers(sessid)
 n users
 m users=^MDBUAF("keys")
 d mergeArrayToSession^%zewdAPI(.users,"tmp.users",sessid)
 QUIT ""
 ;
getUserInfo(sessid)
 n secret,user
 s user=$$getRequestValue^%zewdAPI("user",sessid)
 i user="" QUIT ""
 s secret=$g(^MDBUAF("keys",user))
 d setSessionValue^%zewdAPI("tmp.secret",secret,sessid)
 QUIT ""
 ;
getUserList(sessid)
 n user
 d clearList^%zewdAPI("users",sessid)
 d appendToList^%zewdAPI("users","Select a user..",0,sessid)
 s user=""
 f  s user=$o(^MDBUAF("keys",user)) q:user=""  d
 . d appendToList^%zewdAPI("users",user,user,sessid)
 QUIT ""
 ;
getDomainList(sessid)
 n domain,domainId,user
 s user=$$getRequestValue^%zewdAPI("user",sessid)
 d setSessionValue^%zewdAPI("user",user,sessid)
 d clearList^%zewdAPI("domains",sessid)
 d appendToList^%zewdAPI("domains","Select a domain..",0,sessid)
 s domainId=""
 f  s domainId=$o(^MDB(user,"domains",domainId)) q:domainId=""  d
 . s domain=^MDB(user,"domains",domainId,"name")
 . d appendToList^%zewdAPI("domains",domain,domain,sessid)
 QUIT ""
 ;
getDomainTable(sessid)
 n attrId,attributeNames,d,no,user,domain,domainId,itemId,itemName,attribs,attrs,namex,value,nrows,valueId
 s user=$$getSessionValue^%zewdAPI("user",sessid)
 s domain=$$getRequestValue^%zewdAPI("domain",sessid)
 s domainId=$$getDomainId^MDB(user,domain)
 s namex="",no=0
 f  s namex=$o(^MDB(user,"domains",domainId,"attribsIndex",namex)) q:namex=""  d
 . s attrId=""
 . f  s attrId=$o(^MDB(user,"domains",domainId,"attribsIndex",namex,attrId)) q:attrId=""  d
 . . s no=no+1
 . . s attributeNames(no)=attrId_"^"_^MDB(user,"domains",domainId,"attribs",attrId)
 ;
 s nrows=0
 s itemId=""
 f  s itemId=$o(^MDB(user,"domains",domainId,"items",itemId)) q:itemId=""  d
 . s itemName=^MDB(user,"domains",domainId,"items",itemId)
 . s nrows=nrows+1
 . i nrows>500 q
 . s attrs(itemId,0)=itemName
 . s no=""
 . f  s no=$o(attributeNames(no)) q:no=""  d
 . . s d=attributeNames(no)
 . . s attrId=$p(d,"^",1)
 . . i '$d(^MDB(user,"domains",domainId,"items",itemId,"attribs",attrId)) d
 . . . s cell="&nbsp;"
 . . e  d
 . . . n value,valueId
 . . . s valueId="",cell=""
 . . . f  s valueId=$o(^MDB(user,"domains",domainId,"items",itemId,"attribs",attrId,"value",valueId)) q:valueId=""  d
 . . . . s value=^MDB(user,"domains",domainId,"items",itemId,"attribs",attrId,"value",valueId)
 . . . . i cell'="" s cell=cell_"<br/>"
 . . . . s cell=cell_value
 . . s attrs(itemId,no)=cell
 s attributeNames(0)="^ItemName"
 d mergeArrayToSession^%zewdAPI(.attributeNames,"attributeNames",sessid)
 d mergeArrayToSession^%zewdAPI(.attrs,"attrs",sessid)
 QUIT ""
 ;
getTimeZones(sessid)
 n i,tz
 d clearList^%zewdAPI("timezone",sessid)
 f i=11:-1:1 d
 . s tz="-"
 . i i<10 s tz=tz_0
 . s tz=tz_i_":00"
 . d appendToList^%zewdAPI("timezone",tz,tz,sessid)
 f i=0:1:12 d
 . s tz="+"
 . i i<10 s tz=tz_0
 . s tz=tz_i_":00"
 . d appendToList^%zewdAPI("timezone",tz,tz,sessid)
 s tz=$g(^MDBConfig("GMTOffset"))
 d setSessionValue^%zewdAPI("timezone",tz,sessid)
 QUIT ""
 ;
setTimeZone(sessid)
 s tz=$$getSessionValue^%zewdAPI("timezone",sessid)
 s ^MDBConfig("GMTOffset")=tz
 QUIT ""
 ;
createAttrList(listName,sessionName,sessid)
 ;
 n array,ix,name,no,list
 ;
 d mergeArrayFromSession^%zewdAPI(.array,sessionName,sessid)
 s name="",no=0
 f  s name=$o(array(name)) q:name=""  d
 . i $d(array(name))=1 d
 . . s no=no+1
 . . s list(no,"text")="Name: <span style='color:green'>"_name_"</span><br />Value: <span style='color:orange'>"_array(name)_"</span>"
 . . s list(no,"name")=name
 . . s list(no,"value")=array(name)
 . e  d
 . . s ix=""
 . . f  s ix=$o(array(name,ix)) q:ix=""  d
 . . . s no=no+1
 . . . s list(no,"text")="Name: <span style='color:green'>"_name_"</span><br />Value: <span style='color:orange'>"_array(name,ix)_"</span>"
 . . . s list(no,"name")=name
 . . . s list(no,"value")=array(name,ix)
 d mergeArrayToSession^%zewdAPI(.list,listName,sessid)
 QUIT ""
 ;

