MDBConfig ; M/DB: Mumps Emulation of Amazon SimpleDB - Configuration/Administration
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
deleteAccount(AWSAccessKeyId,adminAWSAccessKeyId,adminAWSSecretAccessKey)
 i $g(AWSAccessKeyId)="" QUIT 0
 i $g(adminAWSAccessKeyId)="" QUIT 0
 i $g(adminAWSSecretAccessKey)="" QUIT 0
 i $g(^MDBUAF("administrator"))'=adminAWSAccessKeyId QUIT 0
 i $g(^MDBUAF("keys",adminAWSAccessKeyId,"s"))'=adminAWSSecretAccessKey QUIT 0
 i AWSAccessKeyId=adminAWSAccessKeyId QUIT 0
 k ^MDBUAF("keys",AWSAccessKeyId)
 QUIT 1
 ;
createAccount(AWSAccessKeyId,AWSSecretAccessKey,adminAWSAccessKeyId,adminAWSSecretAccessKey)
 i $g(AWSAccessKeyId)="" QUIT 0
 i $g(AWSSecretAccessKey)="" QUIT 0
 i $g(adminAWSAccessKeyId)="" QUIT 0
 i $g(adminAWSSecretAccessKey)="" QUIT 0
 i $g(^MDBUAF("administrator"))'=adminAWSAccessKeyId QUIT 0
 i $g(^MDBUAF("keys",adminAWSAccessKeyId,"s"))'=adminAWSSecretAccessKey QUIT 0
 i AWSAccessKeyId=adminAWSAccessKeyId QUIT 0
 s ^MDBUAF("keys",AWSAccessKeyId)=AWSSecretAccessKey
 QUIT 1
 ;
reset(AWSAccessKeyId,AWSSecretAccessKey)
 ;
 i $g(AWSAccessKeyId)=""  QUIT 0
 i $g(AWSSecretAccessKey)=""  QUIT 0
 i $g(^MDBUAF("administrator"))'=AWSAccessKeyId  QUIT 0
 i $g(^MDBUAF("keys",AWSAccessKeyId))'=AWSSecretAccessKey QUIT 0
 k ^MDB
 k ^MDBConfig
 k ^MDBErrors
 k ^MDBUAF
 d buildConfigFiles
 s ^MDBUAF("keys",AWSAccessKeyId)=AWSSecretAccessKey
 s ^MDBUAF("administrator")=AWSAccessKeyId
 QUIT 1
 ;
createAdministrator(AWSAccessKeyId,AWSSecretAccessKey)
 i $g(AWSAccessKeyId)="" QUIT 0
 i $g(AWSSecretAccessKey)="" QUIT 0
 i $d(^MDBUAF("administrator")) QUIT 0
 s ^MDBUAF("keys",AWSAccessKeyId)=AWSSecretAccessKey
 s ^MDBUAF("administrator")=AWSAccessKeyId
 QUIT 1
 ;
buildConfigFiles
 ;
 n code,i,line,name,np,param,params,pno,value,x
 ;
 f i=1:1 s line=$t(config+i^MDBConfig) q:line["***END***"  d
 . s line=$p(line,";;",2,200)
 . s name=$p(line,"=",1)
 . s value=$p(line,"=",2,200)
 . i name'["[" s ^MDBConfig(name)=value q
 . s params=$p(name,"[",2)
 . s name=$p(name,"[",1)
 . s params=$p(params,"]",1)
 . s x="s ^MDBConfig("""_name_""""
 . s np=$l(params,",")
 . f pno=1:1:np d
 . . s x=x_","""_$p(params,",",pno)_""""
 . s x=x_")="""_value_""""
 . x x
 f i=1:1 s line=$t(errors+i^MDBConfig) q:line["***END***"  d
 . s line=$p(line,";;",2,200)
 . s code=$p(line,";",1)
 . s value=$p(line,";",2)
 . s ^MDBErrors(code)=value
 QUIT
 ;
config
 ;;GMTOffset=+00:00
 ;;***END***
 ;
errors
 ;;InvalidParameterValue;Value ~xxx~ for parameter ~yyy~ is invalid 
 ;;MissingParameter;The request must contain the parameter ~xxx~
 ;;NumberDomainsExceeded;Number of domains limit exceeded
 ;;***END*** 
