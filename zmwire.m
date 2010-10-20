zmwire ; M/Wire Protocol for M Systems (eg GT.M, Cache)
 ;
 ; ----------------------------------------------------------------------------
 ; | M/Wire                                                                   |
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
 ; By default this server code runs on port 6330
 ;
 ; For GT.M systems it is invoked via xinetd:
 ;   Edit /etc/services and add the line:
 ; 
 ;    mwire  6330/tcp  # Service for M/Wire Protocol
 ;
 ;   Copy the file mwire to /etc/xinetd.d/mwire
 ;   Copy the file zmwire to /usr/local/gtm/zmwire and change 
 ;    its permissions to executable (eg 755)
 ;
 ;   These files may be edited to change the paths or port number
 ;   Restart xinetd using: sudo /etc/init.d/xinetd restart
 ;
 ;   On GT.M systems you must also have installed MGWSI or m_apache
 ;     in order to provide the MD5 hashing function for passwords
 ;     Alternatively substitute the MD5 callout to the MD5 function of your choice
 ;
 ; For Cache systems, it is invoked via the M/Wire Daemon routine
 ;   which should be running as a jobbed process:
 ;
 ;     job start^zmwireDaemon
 ;
 ;   You can change the port number by simply editing the line
 ; 
 ;      port+1^zmwireDaemon
 ;
 ;    Stop the Daemon process using ^RESJOB and restart it.
 ;
mwireVersion
 ;;Build 6 Beta
 ;
mwireDate
 ;;15 October 2010
 ;
version
 ;
 w "+M/Wire "_$p($t(mwireVersion+1),";;",2,2000)_$c(13,10)
 QUIT
 ;
build
 ;
 n response
 ;
 s response="*3"_$c(13,10)
 w response
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("build: "_response_" sent")
 ;
 s response=$p($t(mwireVersion+1),";;",2,2000)
 s response="$"_$l(response)_$c(13,10)_response_$c(13,10)
 w response
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("build: "_response_" sent")
 ;
 s response=$p($t(mwireDate+1),";;",2,2000)
 s response="$"_$l(response)_$c(13,10)_response_$c(13,10)
 w response
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("build: "_response_" sent")
 ;
 s response=$zv
 s response="$"_$l(response)_$c(13,10)_response_$c(13,10)
 w response
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("build: "_response_" sent")
 QUIT
 ;
command ;
 n authNeeded,c,crlf,input
 ;
 d cleardown
 i $zv["GT.M" s $zint="d monitoroutput"
 s ^zmwire("connected",$j)=""
 l +^zmwire("connected",$j)
 s crlf=$c(13,10)
 s authNeeded=0
 s role="user"
 i $d(^zmwire("auth")) s authNeeded=1
loop
 r *c 
 i $c(c)="*" d
 . s input=$$multiBulkRequest()
 . d log(input)
 . i $g(^zewd("trace"))=1 d trace^%zewdAPI($h_": mb mwire input: "_input)
 e  d
 . r input s input=$c(c)_input 
 . d log(input)
 . i $g(^zewd("trace"))=1 d trace^%zewdAPI($h_": mwire input: "_input)
 . i input'="" d
 . . i $zv["GT.M" s input=$e(input,1,$l(input)-2)
 . . i $zv["Cache" s input=$e(input,1,$l(input)-1)
 i input="" g loop
 i input="EXIT" g halt
 i input="QUIT" g quit
 i input="HALT" g halt
 ;
 i authNeeded,$e(input,1,4)'="AUTH" w "-Authentication required"_$c(13,10) g loop
 i 'authNeeded,$e(input,1,4)="AUTH" w "-Authentication ignored"_$c(13,10) g loop
 i $e(input,1,5)="AUTH " d auth($e(input,6,$l(input))) g loop
 i 'authNeeded!(role="admin"),$e(input,1,12)="SETPASSWORD " d setpassword($e(input,13,$l(input))) g loop
 ;
 i $e(input,1,8)="GETBUILD" d build g loop
 i $e(input,1,4)="SET " d set($e(input,5,$l(input))) g loop
 i $e(input,1,4)="GET " d get($e(input,5,$l(input))) g loop
 i $e(input,1,5)="KILL " d kill($e(input,6,$l(input))) g loop
 i $e(input,1,4)="DEL " d kill($e(input,5,$l(input))) g loop
 i $e(input,1,5)="DATA " d data($e(input,6,$l(input))) g loop
 i $e(input,1,7)="EXISTS " d data($e(input,8,$l(input))) g loop
 i $e(input,1,5)="INCR " d incr($e(input,6,$l(input))) g loop
 i $e(input,1,7)="INCRBY " d incrby($e(input,8,$l(input))) g loop
 i $e(input,1,5)="DECR " d decr($e(input,6,$l(input))) g loop
 i $e(input,1,7)="DECRBY " d decrby($e(input,8,$l(input))) g loop
 i $e(input,1,5)="LOCK " d lock($e(input,6,$l(input))) g loop
 i $e(input,1,7)="UNLOCK " d unlock($e(input,8,$l(input))) g loop
 i $e(input,1,6)="ORDER " d order($e(input,7,$l(input))) g loop
 i $e(input,1,5)="NEXT " d order($e(input,6,$l(input))) g loop
 i $e(input,1,14)="NEXTSUBSCRIPT " d nextSubscript($e(input,15,$l(input)),1) g loop
 i $e(input,1,18)="PREVIOUSSUBSCRIPT " d nextSubscript($e(input,19,$l(input)),-1) g loop
 i $e(input,1,9)="ORDERALL " d orderall($e(input,10,$l(input))) g loop
 i $e(input,1,10)="GETGLOBAL " d getGlobal($e(input,11,$l(input))) g loop
 i $e(input,1,11)="GETGLOBALS2" d getGlobals() g loop
 i $e(input,1,10)="GETGLOBALS" d getGlobalList() g loop
 i $e(input,1,11)="GETALLSUBS " d orderall($e(input,12,$l(input))) g loop
 i $e(input,1,14)="GETSUBSCRIPTS " d getAllSubscripts($e(input,15,$l(input))) g loop
 i $e(input,1,9)="REVORDER " d reverseorder($e(input,10,$l(input))) g loop
 i $e(input,1,9)="PREVIOUS " d reverseorder($e(input,10,$l(input))) g loop
 i $e(input,1,6)="QUERY " d query($e(input,7,$l(input))) g loop
 i $e(input,1,9)="QUERYGET " d queryget($e(input,10,$l(input))) g loop
 i $e(input,1,14)="GETJSONSTRING " d getJSON($e(input,15,$l(input))) g loop
 i $e(input,1,14)="SETJSONSTRING " d setJSON($e(input,15,$l(input))) g loop
 i $e(input,1,10)="MERGEFROM " d mergefrom($e(input,11,$l(input))) g loop
 i $e(input,1,11)="GETSUBTREE " d mergefrom($e(input,12,$l(input))) g loop
 i $e(input,1,8)="MERGETO " d mergeto($e(input,9,$l(input))) g loop
 i $e(input,1,11)="SETSUBTREE " d mergeto($e(input,12,$l(input))) g loop
 i $e(input,1,9)="FUNCTION " d function($e(input,10,$l(input))) g loop
 i $e(input,1,8)="EXECUTE " d function($e(input,9,$l(input))) g loop
 i $e(input,1,6)="TSTART" d tstart g loop
 i $e(input,1,7)="TCOMMIT" d tcommit g loop
 i $e(input,1,9)="TROLLBACK" d trollback g loop
 i $e(input,1,5)="MDATE" d mdate g loop
 i $e(input,1,9)="PROCESSID" d processid g loop
 i $e(input,1,7)="VERSION" d version g loop
 i $e(input,1,8)="MVERSION" d zv g loop
 i $e(input,1,4)="PING" d ping g loop
 i $e(input,1,4)="INFO" d info g loop
 i $e(input,1,7)="MONITOR" d monitor g loop
 w "-"_input_" not recognized",crlf
 g loop
 ;
multiBulkRequest()
 ;
 n buff,c,command,i,input,j,len,noOfCommands,param,space,stop
 ;
 s stop=0,buff=""
 f  q:stop  d
 . r *c i c=13 s stop=1 q
 . s buff=buff_$c(c)
 ;
 s noOfCommands=buff
 s buff=""
 r *c i c'=10 s buff=buff_$c(c)
 f i=1:1:noOfCommands d
 . s stop=0
 . f  q:stop  d
 . . r *c
 . . i $c(c)="$",buff="" q
 . . i c=13 s stop=1 q
 . . s buff=buff_$c(c)
 . s len=buff
 . ;
 . s buff=""
 . r *c i c'=10 s buff=buff_$c(c)
 . f j=1:1:len r *c s buff=buff_$c(c)
 . s param(i)=buff
 . s buff=""
 . r *c r *c ; terminating CRLF
 s space="",input=""
 s param(1)=$$zcvt^%zewdAPI(param(1),"U")
 i param(1)="SET" d  QUIT input
 . s input=param(1)_" "_param(2)_" "_$l(param(3))_$c(13,10)_param(3)
 i param(1)="SETJSONSTRING" d  QUIT input
 . s input=param(1)_" "_param(2)_$c(13,10)_param(3)_$c(13,10)_param(4)
 i param(1)="EXECUTE" d  QUIT input
 . i $e(param(3),1)="[" d
 . . s input=param(1)_" "_param(2)_"("_$e(param(3),2,$l(param(3))-1)_")"
 . e  d
 . . s input=param(1)_" "_param(2)
 ;
 f i=1:1:noOfCommands d
 . s input=input_space_param(i)
 . s space=" " 
 ;
 QUIT input
 ;
halt
 k ^zmwire("connected",$j)
 HALT
 ;
quit
 ;
 i '$d(^zmwire("monitor","listener",$j)) g halt
 k ^zmwire("monitor","listener",$j)
 g loop
 ;
cleardown
 ;
 n ignore,pid
 ;
 s pid=""
 f  s pid=$o(^zmwire("connected",pid)) q:pid=""  d
 . i pid=$j q
 . s ignore=1
 . l +^zmwire("connected",pid):0 e  s ignore=0
 . i ignore d
 . . l -^zmwire("connected",pid)
 . . k ^zmwire("connected",pid)
 . . k ^zmwire("monitor","listener",pid)
 . . k ^zmwire("monitor","output",pid)
 s pid=""
 f  s pid=$o(^zmwire("monitor","output",pid)) q:pid=""  d
 . i pid=$j q
 . s ignore=1
 . l +^zmwire("connected",pid):0 e  s ignore=0
 . l -^zmwire("connected",pid)
 . i ignore d
 . . k ^zmwire("monitor","output",pid)
 QUIT
 ;
monitor
 ;
 i $zv'["GT.M" w "-Command unavailable"_$c(13,10) QUIT
 n quit
 ;
 s ^zmwire("monitor","listener",$j)=""
 w "+OK"_$c(13,10)
 f  h 1 r quit:0  i $e(quit,1,4)="QUIT" q
 k ^zmwire("monitor","listener",$j)
 w "+OK"_$c(13,10)
 QUIT
 ;
log(input)
 ;
 i $zv'["GT.M" QUIT
 ;
 n dev,inputr,io,lineNo,pid
 ;
 i input["AUTH" QUIT
 i input["QUIT" QUIT
 i input["EXIT" QUIT
 i input["HALT" QUIT
 s inputr=$re(input)
 i $e(inputr,1,2)'=$c(10,13) s input=input_$c(13,10)
 s pid=""
 f  s pid=$o(^zmwire("monitor","listener",pid)) q:pid=""  d
 . i pid=$j q
 . s lineNo=$o(^zmwire("monitor","output",pid,""),-1)+1
 . s ^zmwire("monitor","output",pid,lineNo)=input
 . ;zsy "mupip intrpt "_pid_" >/dev/null"
 . zsy "kill -USR1 "_pid
 ;
 QUIT
 ;
monitoroutput
 ;
 n lineNo
 ;
 s lineNo=""
 f  s lineNo=$o(^zmwire("monitor","output",$j,lineNo)) q:lineNo=""  d
 . w ^zmwire("monitor","output",$j,lineNo)
 . k ^zmwire("monitor","output",$j,lineNo)
 QUIT
 ;
info
 ;
 n count,ignore,pid,response
 ;
 s response="m_wire_version:"_$p($t(mwireVersion+1),";;",2,2000)_$c(13,10)
 s pid="",count=0
 f  s pid=$o(^zmwire("connected",pid)) q:pid=""  d
 . s ignore=1
 . i pid=$j d
 . . s ignore=0
 . e  d
 . . l +^zmwire("connected",pid):0 e  s ignore=0
 . i ignore d
 . . l -^zmwire("connected",pid)
 . . k ^zmwire("connected",pid)
 . . k ^zmwire("monitor","listener",pid)
 . e  d
 . . s count=count+1
 s response=response_"connected_clients:"_count ;_$c(13,10)
 w "$"_$l(response)_$c(13,10)_response_$c(13,10)
 QUIT
 ;
auth(input)
 ;
 n pass
 s pass=$$MD5(input)
 i $d(^zmwire("auth",pass)) d
 . s authNeeded=0
 . s role=^zmwire("auth",pass)
 . w "+OK"_$c(13,10)
 e  d
 . w "-Invalid password"_$c(13,10)
 QUIT
 ;
setpassword(input)
 ;
 ; SETPASSWORD secret
 ; +OK <set as role=user>
 ;
 ; SETPASSWORD secret admin
 ; +OK
 ;
 n pass,newrole
 ;
 i $d(^zmwire("auth")),role'="admin" w "-Invalid command"_$c(13,10) QUIT
 i $$stripSpaces(input)="" w "-Invalid command"_$c(13,10) QUIT
 s newrole="user"
 i input[" " d
 . s newrole=$p(input," ",2)
 . s input=$p(input," ",1)
 i '$d(^zmwire("auth")) s newrole="admin"
 i newrole'="user",newrole'="admin" w "-Invalid role"_$c(13,10) QUIT
 ;
 s pass=$$MD5(input)
 s ^zmwire("auth",pass)=newrole
 w "+OK"_$c(13,10)
 QUIT
 ;
getGloRef(input)
 ;
 n gloName,gloRef,nb,subs
 ;
 s gloRef=input
 i $e(gloRef,1)'="^" s gloRef="^"_gloRef
 i $e(gloRef,$l(gloRef))="]" s gloRef=$e(gloRef,1,$l(gloRef)-1)
 s gloName=$p(gloRef,"[",1)
 s nb=$l(gloRef,"[")+2
 s subs=$p(gloRef,"[",2,nb)
 i subs="" QUIT gloName
 QUIT gloName_"("_subs_")"
 ;
set(input)
 ;
 n data,gloName,gloRef,inputr,len,nb,nsp,ok,subs,x
 ;
 ; SET myglobal["1","xx yy",3] 5
 ; hello
 ; +OK
 ; SET myGlo 5
 ; hello
 ; +OK
 ;
 i input[$c(13,10) d
 . s data=$p(input,$c(13,10),2,1000)
 . s input=$p(input,$c(13,10),1)
 s inputr=$re(input)
 s len=$re($p(inputr," ",1))
 i len'=0,+len=0 w "-Data length was not specified"_$c(13,10) QUIT
 s nsp=$l(input," ")+2
 s gloRef=$p(inputr," ",2,nsp)
 s gloRef=$re(gloRef)
 i $e(gloRef,1)'="^" s gloRef="^"_gloRef
 i $e(gloRef,$l(gloRef))="]" s gloRef=$e(gloRef,1,$l(gloRef)-1)
 s gloName=$p(gloRef,"[",1)
 s nb=$l(gloRef,"[")+2
 s subs=$p(gloRef,"[",2,nb)
 s gloRef=gloName
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 i subs'="" s gloRef=gloRef_"("_subs_")"
 i '$d(data)  d
 . s data=$$readChars(len)
 . ;r data#len
 . r ok 
 d log(data)
 i data["""" s data=$$replaceAll(data,"""","""""")
 s x="s "_gloRef_"="""_data_""""
 s $zt=$$zt()
 x x
 s $zt=""
 s response="+ok"_$c(13,10)
 w response
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("set: "_response_" sent")
 QUIT
 ;
getGlobalList()
 ;
 n arrString,comma,count,crlf,glo,gloRef,list,response,x
 ;
 s crlf=$c(13,10)
 i $zv["GT.M" d
 . s x="^%"
 . i $d(@x) s list(x)=""
 . f  s x=$order(@x) q:x=""  s list(x)=""
 . ;
 e  d
 . d getGlobalList^MDBMCache(.list)
 ;
 ;s count=0,glo=""
 ;f  s glo=$o(list(glo)) q:glo=""  s count=count+1
 ;s response="*"_count_crlf
 ;w response
 ;i $g(^zewd("trace"))=1 d trace^%zewdAPI("getGlobalList: "_response_" sent") 
 ;s glo=""
 ;f  s glo=$o(list(glo)) q:glo=""  d
 ;. s gloRef=$e(glo,2,$l(glo))
 ;. s response="$"_$l(gloRef)_crlf_gloRef_crlf
 ;. w response
 ;. i $g(^zewd("trace"))=1 d trace^%zewdAPI("getGlobalList: "_response_" sent") 
 s arrString="["
 s glo="",comma=""
 f  s glo=$o(list(glo)) q:glo=""  d
 . s gloRef=$e(glo,2,$l(glo))
 . s arrString=arrString_comma_""""_gloRef_""""
 . s comma=","
 s arrString=arrString_"]"
 s response="$"_$l(arrString)_crlf_arrString_crlf
 w response
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("getGlobalList: "_response_" sent")  ;
 QUIT
 ;
getGlobals()
 ;
 n arrString,comma,count,crlf,glo,gloRef,list,response,x
 ;
 s crlf=$c(13,10)
 i $zv["GT.M" d
 . s x="^%"
 . i $d(@x) s list(x)=""
 . f  s x=$order(@x) q:x=""  s list(x)=""
 . ;
 e  d
 . d getGlobalList^MDBMCache(.list)
 ;
 s count=0,glo=""
 f  s glo=$o(list(glo)) q:glo=""  s count=count+1
 s response="*"_count_crlf
 w response
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("getGlobalList: "_response_" sent") 
 s glo=""
 f  s glo=$o(list(glo)) q:glo=""  d
 . s gloRef=$e(glo,2,$l(glo))
 . s response="$"_$l(gloRef)_crlf_gloRef_crlf
 . w response
 . i $g(^zewd("trace"))=1 d trace^%zewdAPI("getGlobalList: "_response_" sent") 
 QUIT
 ;
get(input)
 ;
 n data,exists,gloRef,response,x
 ;
 ; GET myglobal["1","xx yy",3]
 ; $6
 ; foobar
 ;
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s x="s exists=$d("_gloRef_")"
 s $zt=$$zt()
 x x
 s $zt=""
 i exists'=1,exists'=11 w "$-1"_$c(13,10) QUIT
 s x="s data="_gloRef
 s $zt=$$zt()
 x x
 s $zt=""
 ;
 s response="$"_$l(data)_$c(13,10)_data_$c(13,10)
 ;
 w response
 QUIT
 ;
getGlobal(input)
 ;
 n data,exists,gloRef,json,response,x
 ;
 ; GET myglobal["1","xx yy",3]
 ; $6
 ; foobar
 ;
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s x="s exists=$d("_gloRef_")"
 s $zt=$$zt()
 x x
 s x="s data=$g("_gloRef_")"
 x x
 s $zt=""
 s json="{""value"":"""_data_""",""dataStatus"":"_exists_"}"
 ;
 s response="$"_$l(json)_$c(13,10)_json_$c(13,10)
 ;
 w response
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("getGlobal: response="_response)
 QUIT
 ;
kill(input)
 ;
 n i,glo,gloRef,nsp,p1,p2,x
 ;
 ; KILL myglobal["1","xx yy",3]
 ; +OK
 ;
 s nsp=$l(input," ")
 f i=1:1:nsp d
 . s glo=$p(input," ",i)
 . q:glo=""
 . s p1=$p(glo,"[",1)
 . s p2=$p(glo,"[",2,2000)
 . s p2=$e(p2,1,$l(p2)-1)
 . s glo=p1_"("_p2_")"
 . i glo'["zmwire" s glo(glo)=""
 s glo=""
 f  s glo=$o(glo(glo)) q:glo=""  d
 . s x="k ^"_glo
 . s $zt=$$zt()
 . x x
 . s $zt=""
 s response="+ok"_$c(13,10)
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("kill: response="_response)
 w response
 QUIT
 ;
data(input)
 ;
 n data,gloRef,x
 ;
 ; DATA myglobal["1","xx yy",3]
 ; :10
 ;
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s x="s data=$d("_gloRef_")"
 s $zt=$$zt()
 x x
 s $zt=""
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("input="_input_"; data="_data)
 w ":"_data_$c(13,10)
 QUIT
 ;
setJSON(input)
 ;
 n arr,crlf,del,error,flrc,inputr,gloRef,inputr,json,nb,nsp,props,ref,response,subs
 ;
 ; SETJSONSTRING myglobal["1","xx yy",3] CRLF {"a":123} CRLF 1
 ; +ok
 ;
 s crlf=$c(13,10),flrc=$c(10,13)
 s gloRef=$p(input,crlf,1)
 s input=$p(input,crlf,2,10000)
 s inputr=$re(input)
 s del=$p(inputr,flrc,1),del=$re(del)
 s inputr=$p(inputr,flrc,2,10000) ; in case it contains crlfs
 s json=$re(inputr)
 ;
 i $e(gloRef,1)'="^" s gloRef="^"_gloRef
 i $e(gloRef,$l(gloRef))="]" s gloRef=$e(gloRef,1,$l(gloRef)-1)
 s gloName=$p(gloRef,"[",1)
 s nb=$l(gloRef,"[")+2
 s subs=$p(gloRef,"[",2,nb)
 s gloRef=gloName
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 i subs'="" s gloRef=gloRef_"("_subs_")"
 s error=$$parseJSON^%zewdJSON(json,.props,1)
 i error'="" w "-Invalid JSON in setJSON: "_json_$c(13,10) QUIT
 ;
 i del d
 . s ref="k "_gloRef
 . x ref
 ;
 s ref="m "_gloRef_"=props"
 x ref
 s response="+ok"_$c(13,10)
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("setJSON: response="_response)
 ;
 w response
 ;
 QUIT
 ;
getJSON(input)
 ;
 n arr,inputr,gloRef,json,nb,nsp,ref,response,subs
 ;
 ; GETJSONSTRING myglobal["1","xx yy",3]
 ; $5
 ; {x:1}
 ;
 s gloRef=input
 i $e(gloRef,1)'="^" s gloRef="^"_gloRef
 i $e(gloRef,$l(gloRef))="]" s gloRef=$e(gloRef,1,$l(gloRef)-1)
 s gloName=$p(gloRef,"[",1)
 s nb=$l(gloRef,"[")+2
 s subs=$p(gloRef,"[",2,nb)
 s gloRef=gloName
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 i subs'="" s gloRef=gloRef_"("_subs_")"
 s ref="m arr="_gloRef
 x ref
 s json=$$arrayToJSON^%zewdJSON("arr")
 s response="$"_$l(json)_$c(13,10)_json_$c(13,10)
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("getJSON: response="_response)
 ;
 w response
 ;
 QUIT
 ;
incr(input)
 ;
 n data,gloRef,x
 ;
 ; INCR myglobal["1","xx yy",3]
 ; :4
 ;
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s x="s data=$increment("_gloRef_")"
 s $zt=$$zt()
 x x
 s $zt=""
 w ":"_data_$c(13,10)
 QUIT
 ;
incrby(input)
 ;
 n by,data,gloName,gloRef,inputr,len,nb,nsp,ok,subs,x
 ;
 ; INCRBY myglobal["1","xx yy",3] 3
 ; :7
 ;
 s inputr=$re(input)
 s by=$re($p(inputr," ",1))
 s nsp=$l(input," ")+2
 s gloRef=$p(inputr," ",2,nsp)
 s gloRef=$re(gloRef)
 i $e(gloRef,1)'="^" s gloRef="^"_gloRef
 i $e(gloRef,$l(gloRef))="]" s gloRef=$e(gloRef,1,$l(gloRef)-1)
 s gloName=$p(gloRef,"[",1)
 s nb=$l(gloRef,"[")+2
 s subs=$p(gloRef,"[",2,nb)
 s gloRef=gloName
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 i subs'="" s gloRef=gloRef_"("_subs_")"
 s x="s data=$increment("_gloRef_","_by_")"
 s $zt=$$zt() x x
 s $zt=""
 w ":"_data_$c(13,10)
 QUIT
 ;
function(input)
 ;
 n data,func,x
 ;
 ; FUNCTION label^rou("1","xx yy")
 ; $5
 ; hello
 ;
 s func=input
 i func["^",$e(func,1,2)'="$$" s func="$$"_func
 i func["class(",$e(func,1,2)'="##" s func="##"_func
 s x="s data="_func
 s $zt=$$zt()
 x x
 s $zt=""
 w "$"_$l(data)_$c(13,10)_data_$c(13,10)
 QUIT
 ;
decr(input)
 ;
 n data,gloRef,x
 ;
 ; DECR myglobal["1","xx yy",3]
 ; :3
 ;
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s x="s data=$increment("_gloRef_",-1)"
 s $zt=$$zt() x x
 s $zt=""
 w ":"_data_$c(13,10)
 QUIT
 ;
decrby(input)
 ;
 n by,data,gloName,gloRef,inputr,nb,nsp,ok,subs,x
 ;
 ; DECRBY myglobal["1","xx yy",3] 3
 ; :4
 ;
 s inputr=$re(input)
 s by=$re($p(inputr," ",1))
 s nsp=$l(input," ")+2
 s gloRef=$p(inputr," ",2,nsp)
 s gloRef=$re(gloRef)
 i $e(gloRef,1)'="^" s gloRef="^"_gloRef
 i $e(gloRef,$l(gloRef))="]" s gloRef=$e(gloRef,1,$l(gloRef)-1)
 s gloName=$p(gloRef,"[",1)
 s nb=$l(gloRef,"[")+2
 s subs=$p(gloRef,"[",2,nb)
 s gloRef=gloName
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 i subs'="" s gloRef=gloRef_"("_subs_")"
 s x="s data=$increment("_gloRef_",-"_by_")"
 s $zt=$$zt()
 x x
 s $zt=""
 w ":"_data_$c(13,10)
 QUIT
 ;
nextSubscript(input,direction)
 ;
 n crlf,data,gloRef,response,subscript,x,value
 ;
 ; NEXTSUBSCRIPT myglobal["1","xx yy",""]
 ; +abc
 ;
 s crlf=$c(13,10)
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s x="s subscript=$o("_gloRef_",direction)"
 s $zt=$$zt()
 x x
 s $zt=""
 s value=$g(^(subscript))
 s data=$d(^(subscript))
 ;
 s response="{""subscriptValue"":"""_subscript_""","
 s response=response_"""dataStatus"":"_data_","
 s response=response_"""dataValue"":"""_value_"""}"
 ;
 s response="$"_$l(response)_crlf_response_crlf
 i $g(^zewd("trace"))=1 d trace^%zewdAPI("nextsubscript: response="_response)
 w response
 ;
 QUIT
 ;
order(input)
 ;
 n data,gloRef,x
 ;
 ; ORDER myglobal["1","xx yy",""]
 ; +abc
 ;
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s x="s data=$o("_gloRef_")"
 s $zt=$$zt()
 x x
 s $zt=""
 i data="" w "$-1"_$c(13,10) QUIT
 w "$"_$l(data)_$c(13,10),data_$c(13,10)
 QUIT
 ;
reverseorder(input)
 ;
 n data,gloRef,x
 ;
 ; REVORDER myglobal["1","xx yy",""]
 ; +abc
 ;
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s x="s data=$o("_gloRef_",-1)"
 s $zt=$$zt()
 x x
 s $zt=""
 i data="" w "$-1"_$c(13,10) QUIT
 w "$"_$l(data)_$c(13,10),data_$c(13,10)
 QUIT
 ;
query(input)
 ;
 n data,gloRef,nb,p1,p2,x
 ;
 ; QUERY myglobal["1","xx yy"]
 ;
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s x="s data=$q("_gloRef_")"
 s $zt=$$zt()
 x x
 i data="" w "$-1"_$c(13,10) QUIT
 s data=$e(data,2,$l(data))
 s p1=$p(data,"(",1)
 s nb=$p(data,"(")+2
 s p2=$p(data,"(",2,nb)
 s p2=$e(p2,1,$l(p2)-1)
 s data=p1_"["_p2_"]"
 w "$"_$l(data)_$c(13,10),data_$c(13,10)
 s $zt=""
 QUIT
 ;
queryget(input)
 ;
 n data,gloRef,nb,odata,p1,p2,value,x
 ;
 ; QUERYGET myglobal["1","xx yy"]
 ;
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s x="s data=$q("_gloRef_")"
 s $zt=$$zt()
 x x
 i data="" w "$-1"_$c(13,10) QUIT
 s odata=data
 w "*2"_$c(13,10)
 s data=$e(data,2,$l(data))
 s p1=$p(data,"(",1)
 s nb=$p(data,"(")+2
 s p2=$p(data,"(",2,nb)
 s p2=$e(p2,1,$l(p2)-1)
 s data=p1_"["_p2_"]"
 w "$"_$l(data)_$c(13,10),data_$c(13,10)
 s value=@odata
 w "$"_$l(value)_$c(13,10)_value_$c(13,10)
 s $zt=""
 QUIT
 ;
lock(input)
 ;
 n gloName,gloRef,inputr,nb,nsp,ok,subs,time,x
 ;
 ; LOCK myglobal["1","xxyy"] 5
 ; +OK
 ;
 s inputr=$re(input)
 s time=$re($p(inputr," ",1))
 i time?1N.N d
 . s nsp=$l(input," ")+2
 . s gloRef=$p(inputr," ",2,nsp)
 e  d
 . s time=5
 . s gloRef=inputr
 s gloRef=$re(gloRef)
 i $e(gloRef,1)'="^" s gloRef="^"_gloRef
 i $e(gloRef,$l(gloRef))="]" s gloRef=$e(gloRef,1,$l(gloRef)-1)
 s gloName=$p(gloRef,"[",1)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s nb=$l(gloRef,"[")+2
 s subs=$p(gloRef,"[",2,nb)
 s gloRef=gloName
 i subs'="" s gloRef=gloRef_"("_subs_")"
 s x="s ok=1 l +"_gloRef_":"_time_" e  s ok=0"
 s $zt=$$zt()
 x x
 s $zt=""
 w ":"_ok_$c(13,10)
 QUIT
 ;
unlock(input)
 ;
 n gloRef,x
 ;
 ; UNLOCK myglobal["1","xxyy"]
 ; +OK
 ;
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 s x="l -"_gloRef
 s $zt=$$zt()
 x x
 s $zt=""
 w "+OK"_$c(13,10)
 QUIT
 ;
getAllSubscripts(input)
 ;
 n comma,data,exists,i,gloRef,len,rec,ref,subscripts,subs,subs1,x
 ;
 ; GETSUBSCRIPTS myglobal["1","xx yy"] 
 ; 
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 i $e(gloRef,$l(gloRef))=")" d
 . s x="s exists=$d("_gloRef_")"
 . s gloRef=$e(gloRef,1,$l(gloRef)-1)_","
 e  d
 . s x="s exists=$d("_gloRef_")"
 . s gloRef=gloRef_"("
 s $zt=$$zt()
 x x
 s $zt=""
 i 'exists w "$-1"_$c(13,10) QUIT
 ;
 s subs=""
 s subs1=subs i subs1["""" s subs1=$$replaceAll(subs1,"""","""""")
 s x="s subs=$o("_gloRef_""""_subs1_"""))"
 x x
 s len=3+$l(subs)
 s comma=","
 i subs'="" d
 . f  s subs=$o(^(subs)) q:subs=""  d
 . . s len=len+$l(comma)+2+$l(subs)
 s len=len+1
 s response="$"_len_$c(13,10)
 w response
 ;
 s x="s subs=$o("_gloRef_""""_subs1_"""))"
 x x
 s response="["""_subs_""""
 w response
 i subs'="" d
 . f  s subs=$o(^(subs)) q:subs=""  d
 . . s response=comma_""""_subs_""""
 . . w response
 s response="]"_$c(13,10)
 w response
 ;
 QUIT
 ;
orderall(input)
 ;
 n data,exists,i,gloRef,rec,subs,subs1,x
 ;
 ; ORDERALL myglobal["1","xx yy"] 
 ; *6
 ; $2
 ; aa
 ; $5
 ; hello
 ; $2
 ; bb
 ; $5
 ; world
 ; $3
 ; bba
 ; $-1
 ; 
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 i $e(gloRef,$l(gloRef))=")" d
 . s x="s exists=$d("_gloRef_")"
 . s gloRef=$e(gloRef,1,$l(gloRef)-1)_","
 e  d
 . s x="s exists=$d("_gloRef_")"
 . s gloRef=gloRef_"("
 s $zt=$$zt()
 x x
 i 'exists w "$-1"_$c(13,10) QUIT
 ;
 s subs="",rec=0
 k ^CacheTempEWD($j)
 f  d  q:subs=""
 . s subs1=subs i subs1["""" s subs1=$$replaceAll(subs1,"""","""""")
 . s x="s subs=$o("_gloRef_""""_subs1_"""))"
 . x x
 . i subs="" q
 . s rec=rec+1
 . s ^CacheTempEWD($j,rec)="$"_$l(subs)_$c(13,10)_subs_$c(13,10)
 . s x="s exists=$d("_gloRef_""""_subs_"""))"
 . x x
 . i exists=1!(exists=11) d
 . . s x="s data="_gloRef_""""_subs_""")"
 . . x x
 . . s rec=rec+1
 . . s ^CacheTempEWD($j,rec)="$"_$l(data)_$c(13,10)_data_$c(13,10)
 . e  d
 . . s rec=rec+1
 . . s ^CacheTempEWD($j,rec)="$-1"_$c(13,10)
 s $zt=""
 w "*"_rec_$c(13,10)
 f i=1:1:rec w ^CacheTempEWD($j,i)
 k ^CacheTempEWD($j)
 QUIT
 ;
mergefrom(input)
 ;
 n data,gloRef,i,params,resp,start,x
 ;
 ; MERGEFROM myglobal["1","a"]
 ; *6
 ; $1
 ; 1  <keys>
 ; $5
 ; hello  <data>
 ; $9
 ; 1,"a\"aa"  <keys> note escaping
 ; $5
 ; world
 ; $8
 ; 2,"cccc"
 ; $3
 ; foo
 ;
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 k ^CacheTempEWD($j)
 s x="m ^CacheTempEWD($j)="_gloRef
 s $zt=$$zt()
 x x
 s $zt=""
 s x=$q(^CacheTempEWD($j,""))
 i x="" w "*-1"_$c(13,10) k ^CacheTempEWD($j) QUIT
 f i=1:1 s x=$q(@x) q:x=""
 i $d(^CacheTempEWD($j))=1!($d(^CacheTempEWD($j))=11) s i=i+1
 w "*"_(i*2)_$c(13,10)
 i $d(^CacheTempEWD($j))=1!($d(^CacheTempEWD($j))=11) d
 . w "$-1"_$c(13,10)
 . w "$"_$l(^CacheTempEWD($j))_$c(13,10)_^CacheTempEWD($j)_$c(13,10)
 s x=$q(^CacheTempEWD($j,""))
 s start="^CacheTempEWD("_$j_","
 s params=$p(x,start,2,2000)
 s params=$e(params,1,$l(params)-1)
 s resp=params
 w "$"_$l(resp)_$c(13,10)_resp_$c(13,10)
 s data=@x
 w "$"_$l(data)_$c(13,10)_data_$c(13,10)  
 f i=1:1 s x=$q(@x) q:x=""  d
 . s params=$p(x,start,2,2000)
 . s params=$e(params,1,$l(params)-1)
 . s resp=params
 . w "$"_$l(resp)_$c(13,10)_resp_$c(13,10)  
 . s data=@x
 . i data="" d
 . . w "$-1"_$c(13,10)
 . e  d
 . . w "$"_$l(data)_$c(13,10)_data_$c(13,10)  
 k ^CacheTempEWD($j)
 QUIT
 ;
mergeto(input)
 ;
 n data,dataLength,error,gloRef,i,key,keyLength,noOfRecs,x
 ;
 ; MERGETO myglobal["1","a"]
 ; *6
 ; $1
 ; 1   <keys>
 ; $5
 ; hello  <data>
 ; $7
 ; 1,"aaa"  <keys>
 ; $5
 ; world   <data>
 ; $8
 ; 2,"cccc"
 ; $3
 ; foo
 ; +OK
 ;   note $-1 for key length means no key - data put at top level
 ;
 s $zt=$$zt()
 s gloRef=$$getGloRef(input)
 i gloRef["^zmwire" w "-No access allowed to this global"_$c(13,10) QUIT
 i $e(gloRef,$l(gloRef))=")" s gloRef=$e(gloRef,1,$l(gloRef)-1)
 ;
 r noOfRecs
 i $e(noOfRecs,1)'="*" w "-Invalid: expected number of records"_$c(13,10) QUIT
 s noOfRecs=+$e(noOfRecs,2,$l(noOfRecs))
 i noOfRecs'?1N.N w "-Invalid format for number of records"_$c(13,10) QUIT
 i noOfRecs=0 QUIT "+OK"_$c(13,10) QUIT
 i (noOfRecs#2)=1 w "-Invalid: no of records must be an even number"_$c(13,10) QUIT
 s noOfRecs=noOfRecs/2
 k ^CacheTempEWD($j)
 s error=""
 k ^CacheTempEWD($j)
 f i=1:1:noOfRecs d  q:error'=""
 . r keyLength
 . i $e(keyLength,1)'="$" s error="Invalid record "_i_": record length" q
 . s keyLength=+$e(keyLength,2,$l(keyLength))
 . i keyLength=-1 d
 . . s key=""
 . e  d
 . . i keyLength'?1N.N s error="Invalid record "_i_": bad format for record length" q
 . . i keyLength=0 s error="Invalid record "_i_": record length cannot be zero" q
 . . s key=$$readChars(keyLength)
 . . r ok d log(key)
 . . ;r key#keyLength,ok d log(key)
 . . i key["\""" s key=$$replaceAll(key,"\""","""""")
 . i error'="" q
 . r dataLength
 . i $e(dataLength,1)'="$" s error="Invalid record "_i_": expected data length" q
 . s dataLength=+$e(dataLength,2,$l(dataLength))
 . i dataLength'=-1,dataLength'?1N.N s error="Invalid record "_i_": bad format for data length" q
 . i dataLength=-1 d
 . . s data=""
 . e  d
 . . s data=$$readChars(dataLength)
 . . r ok
 . . d log(data)
 . . ;r data#dataLength,ok d log(data)
 . . i data["""" s data=$$replaceAll(data,"""","""""")
 . i key="" d
 . . n gloRef1
 . . s gloRef1=gloRef
 . . i gloRef["(" s gloRef1=gloRef1_")"
 . . s x="s "_gloRef1_"="""_data_""""
 . e  d
 . . n gloRef1
 . . s gloRef1=gloRef
 . . i gloRef'["(" d
 . . . s gloRef1=gloRef1_"("
 . . e  d
 . . . s gloRef1=gloRef1_","
 . . s x="s "_gloRef1_key_")="""_data_""""
 . s ^CacheTempEWD($j,i)=x
 i error'="" w "-"_error_$c(13,10) QUIT
 f i=1:1:noOfRecs d
 . s x=^CacheTempEWD($j,i)
 . x x
 k ^CacheTempEWD($j)
 w "+OK"_$c(13,10)
 s $zt=""
 QUIT
 ;
mdate
 ;
 n date,day,time
 ;
 s date=$h
 s day=+date
 w "*2"_$c(13,10)_"$"_$l(day)_$c(13,10)_day_$c(13,10)
 s time=$p(date,",",2)
 w "$"_$l(time)_$c(13,10)_time_$c(13,10)
 QUIT
 ;
tstart
 s $zt=$$zt()
 TSTART
 w "+OK"_$c(13,10)
 s $zt=""
 QUIT
 ;
tcommit
 s $zt=$$zt()
 TCOMMIT
 w "+OK"_$c(13,10)
 s $zt=""
 QUIT
 ;
trollback
 s $zt=$$zt()
 TROLLBACK
 w "+OK"_$c(13,10)
 s $zt=""
 QUIT
 ;
zv
 w "+"_$zv_$c(13,10)
 QUIT
 ;
zt()
 i $zv["GT.M" QUIT "g executeError^zmwire"
 QUIT "executeError^zmwire"
 ;
processid
 w ":"_$j_$c(13,10)
 QUIT
 ;
ping
 n response
 s response="+PONG"_$c(13,10)
 i $g(^zewd("trace"))=1 d trace^%zewdAPI(response_" about to be written")
 w response
 i $g(^zewd("trace"))=1 d trace^%zewdAPI(response_" written")
 QUIT
 ;
executeError
 w "-Invalid Command"_$c(13,10)
 g loop
 ;
replaceAll(InText,FromStr,ToStr) ; Replace all occurrences of a substring
 ;
 n p
 ;
 s p=InText
 i ToStr[FromStr d  QUIT p
 . n i,stop,tempText,tempTo
 . s stop=0
 . f i=0:1:255 d  q:stop
 . . q:InText[$c(i)
 . . q:FromStr[$c(i)
 . . q:ToStr[$c(i)
 . . s stop=1
 . s tempTo=$c(i)
 . s tempText=$$replaceAll(InText,FromStr,tempTo)
 . s p=$$replaceAll(tempText,tempTo,ToStr)
 f  q:p'[FromStr  S p=$$replace(p,FromStr,ToStr)
 QUIT p
 ;
replace(InText,FromStr,ToStr) ; replace old with new in string
 ;
 n np,p1,p2
 ;
 i InText'[FromStr q InText
 s np=$l(InText,FromStr)+1
 s p1=$p(InText,FromStr,1),p2=$p(InText,FromStr,2,np)
 QUIT p1_ToStr_p2
 ;
readChars(length)
 ;
 n data,i,x
 ;
 s data=""
 f i=1:1:length r *x s data=data_$c(x)
 QUIT data
 ;
stripSpaces(string)
 i $zv["Cache" QUIT $$stripSpaces^MDBMCache(string)
 ;
 s string=$$stripLeadingSpaces(string)
 QUIT $$stripTrailingSpaces(string)
 ;
stripLeadingSpaces(string)
 ;
 n i
 ;
 f i=1:1:$l(string) QUIT:$e(string,i)'=" "
 QUIT $e(string,i,$l(string))
 ;
stripTrailingSpaces(string)
 ;
 n i,spaces,new
 ;
 s spaces=$$makeString(" ",100)
 s new=string_spaces
 QUIT $p(new,spaces,1)
 ;
makeString(char,len) ; create a string of len characters
 ;
 n str
 ;
 s str="",$p(str,char,len+1)=""
 QUIT str
 ;
MD5(string)
 ;
 ; n hash
 ;
 i $zv["Cache" QUIT $$MD5^MDBMCache(string)
 ;
 QUIT $$MD5^%ZMGWSIS(string,1,1)
 ;

