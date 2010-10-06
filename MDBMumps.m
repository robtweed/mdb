MDBMumps ; M/DB:Mumps API methods
 ;
 ; ----------------------------------------------------------------------------
 ; | M/DB:Mumps                                                               |
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
version()	
 QUIT "5"
 ;
buildDate()	
 QUIT "04 October 2010"
 ;
 ;
install
 ;k ^MDBAPI("mdbm")
 s ^MDBAPI("mdbm","BatchSet")="batchSet^MDBMumps"
 s ^MDBAPI("mdbm","Decrement")="increment^MDBMumps"
 s ^MDBAPI("mdbm","Function")="function^MDBMumps"
 s ^MDBAPI("mdbm","Get")="get^MDBMumps"
 s ^MDBAPI("mdbm","GetJSON")="getJSON^MDBMumps"
 s ^MDBAPI("mdbm","GetVersion")="getVersion^MDBMumps"
 s ^MDBAPI("mdbm","Increment")="increment^MDBMumps"
 s ^MDBAPI("mdbm","Kill")="kill^MDBMumps"
 s ^MDBAPI("mdbm","MergeFromGlobal")="mergeFromGlobal^MDBMumps"
 s ^MDBAPI("mdbm","MergeToGlobal")="mergeToGlobal^MDBMumps"
 s ^MDBAPI("mdbm","Order")="order^MDBMumps"
 s ^MDBAPI("mdbm","OrderAll")="orderAll^MDBMumps"
 s ^MDBAPI("mdbm","Set")="set^MDBMumps"
 s ^MDBAPI("mdbm","SetJSON")="setJSON^MDBMumps"
 QUIT
 ;
getVersion(%KEY,response)
 d install
 i $g(%KEY("OutputFormat"))="JSON" d  QUIT ""
 . s response(1)="{""Name"":""M/DB:Mumps"",""Build"":"_$$version()_",""Date"":"""_$$buildDate()_"""}"
 ;
 s response(0)="<GetVersionResult>"
 s response(1)="<Build>"_$$version()_"</Build>"
 s response(2)="<Date>"_$$buildDate()_"</Date>"
 s response(3)="</GetVersionResult>"
 QUIT ""
 ;
setJSON(%KEY,response)
 ;
 n error,globalName,props,ref,subscripts
 ;
 k response
 ;
 s error="No JSON input was supplied"
 i $g(%KEY("JSON"))'="" s error=$$parseJSON^%zewdJSON(%KEY("JSON"),.props,1)
 i error'="" s error=action_"Error~"_error q
 ;
 s subscripts=$g(%KEY("Subscripts"))
 i $e(subscripts,1)="[",$e(subscripts,$l(subscripts))="]" s subscripts=$e(subscripts,2,$l(subscripts)-1)
 ;
 i $g(%KEY("Reference"))="" QUIT "missingGlobalName~Reference (Global Name) was not specified"
 s globalName=%KEY("Reference")
 i $e(globalName,1)'="^" s globalName="^"_globalName
 i subscripts'="" s globalName=globalName_"("_subscripts_")"
 i $g(%KEY("DeleteBeforeSave"))=1 d
 . s ref="k "_globalName
 . x ref
 s ref="m "_globalName_"=props"
 x ref
 s response(1)="{""ok"":true}"
 ;
 QUIT ""
 ;
set(%KEY,response)
 ;
 n comma,error,globalName,i,name,ref,start,stop,subscript,subscripts,value
 ;
 k response
 ;
 i $g(%KEY("JSON"))'="" d
 . n name,no,props,value
 . s error=$$parseJSON^%zewdJSON(%KEY("JSON"),.props,1)
 . i error'="" s error=action_"Error~"_error q
 . s %KEY("GlobalName")=$g(props("GlobalName"))
 . s %KEY("DataValue")=$g(props("DataValue"))
 . f no=1:1 q:'$d(props("Subscripts",no))  d
 . . s value=$g(props("Subscripts",no))
 . . s %KEY("Subscript."_no_".Value")=value
 ;
 s globalName=$g(%KEY("GlobalName"))
 i globalName="" s globalName=$g(%KEY("Reference"))
 i globalName="" QUIT "missingGlobalName~GlobalName was not specified"
 s stop=0
 s name=$o(%KEY("Subscript."))
 s start=$p(name,".",2)
 i start'="",start'=1 QUIT "BadSubscriptReference~Subscript numbers must start from 1"
 s error=""
 f i=start:1 d  q:stop
 . s subscript="Subscript."_i_".Value"
 . i '$d(%KEY(subscript)) s stop=1 q
 . i %KEY(subscript)="" s error="BadSubscriptReference~Subscript values cannot be null",stop=1 q
 . s subscripts(i)=%KEY(subscript)
 i error'="" QUIT error
 s value=$g(%KEY("DataValue"))
 i value="" QUIT "missingDataValue~Data Value was not specified"
 s ref="s ^"_globalName
 i $d(subscripts) d
 . s ref=ref_"("
 . s comma=""
 . s i=""
 . f  s i=$o(subscripts(i)) q:i=""  d
 . . s ref=ref_comma_""""_subscripts(i)_""""
 . . s comma=","
 . s ref=ref_")"
 s ref=ref_"="""_value_""""
 x ref
 i $g(%KEY("OutputFormat"))="JSON" s response(1)="{""ok"":true}"
 QUIT ""
 ;
getJSON(%KEY,response)
 ;
 n arr,error,globalName,json,props,ref,subscripts
 ;
 k response
 ;
 s json=$g(%KEY("JSON"))
 s subscripts=""
 i $e(json,1)="[",$e(json,$l(json))="]" s subscripts=$e(json,2,$l(json)-1)
 ;
 i $g(%KEY("Reference"))="" QUIT "missingGlobalName~Reference (Global Name) was not specified"
 s globalName=%KEY("Reference")
 i $e(globalName,1)'="^" s globalName="^"_globalName
 s ref="m arr="_globalName
 i subscripts'="" s ref=ref_"("_subscripts_")"
 x ref
 s json=$$arrayToJSON^%zewdJSON("arr")
 s response(1)=json
 ;
 QUIT ""
 ;
get(%KEY,response)
 ;
 n comma,data,error,exists,globalName,i,name,ref,start,stop,subscript,subscripts,value
 ;
 k response
 i $g(%KEY("JSON"))'="" d
 . n json,name,no,props,value
 . s json=%KEY("JSON")
 . i $e(json,1)="[",$e(json,$l(json))="]" s %KEY("JSON")="{Subscripts:"_json_"}"
 . s error=$$parseJSON^%zewdJSON(%KEY("JSON"),.props,1)
 . i error'="" s error=action_"Error~"_error q
 . s %KEY("GlobalName")=$g(props("GlobalName"))
 . f no=1:1 q:'$d(props("Subscripts",no))  d
 . . s value=$g(props("Subscripts",no))
 . . s %KEY("Subscript."_no_".Value")=value
 ;
 s globalName=$g(%KEY("GlobalName"))
 i globalName="" s globalName=$g(%KEY("Reference"))
 i globalName="" QUIT "missingGlobalName~GlobalName was not specified"
 s stop=0
 s name=$o(%KEY("Subscript."))
 s start=$p(name,".",2)
 i start'="",start'=1 QUIT "BadSubscriptReference~Subscript numbers must start from 1"
 s error=""
 f i=start:1 d  q:stop
 . s subscript="Subscript."_i_".Value"
 . i '$d(%KEY(subscript)) s stop=1 q
 . i %KEY(subscript)="" s error="BadSubscriptReference~Subscript values cannot be null",stop=1 q
 . s subscripts(i)=%KEY(subscript)
 i error'="" QUIT error
 s ref="^"_globalName
 i $d(subscripts) d
 . s ref=ref_"("
 . s comma=""
 . s i=""
 . f  s i=$o(subscripts(i)) q:i=""  d
 . . s ref=ref_comma_""""_subscripts(i)_""""
 . . s comma=","
 . s ref=ref_")"
 s exists="s data=$d("_ref_")"
 x exists
 s ref="s value=$g("_ref_")"
 x ref
 ;
 i $g(%KEY("OutputFormat"))="JSON" d  QUIT ""
 . s response(1)="{""dataStatus"":"_data_",""value"":"""_value_"""}"
 ;
 s response(0)="<GetResult>"
 s response(1)="<DataStatus>"_data_"</DataStatus>"
 s response(2)="<DataValue>"_value_"</DataValue>"
 s response(3)="</GetResult>"
 QUIT ""
 ;
kill(%KEY,response)
 ;
 n comma,error,globalName,i,name,ref,start,stop,subscript,subscripts,value
 ;
 k response
 ;
 i $g(%KEY("JSON"))'="" d
 . n json,name,no,props,value
 . s json=%KEY("JSON")
 . i $e(json,1)="[",$e(json,$l(json))="]" s %KEY("JSON")="{Subscripts:"_json_"}"
 . s error=$$parseJSON^%zewdJSON(%KEY("JSON"),.props,1)
 . i error'="" s error=action_"Error~"_error q
 . s %KEY("GlobalName")=$g(props("GlobalName"))
 . f no=1:1 q:'$d(props("Subscripts",no))  d
 . . s value=$g(props("Subscripts",no))
 . . s %KEY("Subscript."_no_".Value")=value
 ;
 s globalName=$g(%KEY("GlobalName"))
 i globalName="" s globalName=$g(%KEY("Reference"))
 i globalName="" QUIT "missingGlobalName~GlobalName was not specified"
 s stop=0
 s name=$o(%KEY("Subscript."))
 s start=$p(name,".",2)
 i start'="",start'=1 QUIT "BadSubscriptReference~Subscript numbers must start from 1"
 s error=""
 f i=start:1 d  q:stop
 . s subscript="Subscript."_i_".Value"
 . i '$d(%KEY(subscript)) s stop=1 q
 . i %KEY(subscript)="" s error="BadSubscriptReference~Subscript values cannot be null",stop=1 q
 . s subscripts(i)=%KEY(subscript)
 i error'="" QUIT error
 s ref="k ^"_globalName
 i $d(subscripts) d
 . s ref=ref_"("
 . s comma=""
 . s i=""
 . f  s i=$o(subscripts(i)) q:i=""  d
 . . s ref=ref_comma_""""_subscripts(i)_""""
 . . s comma=","
 . s ref=ref_")"
 x ref
 i $g(%KEY("OutputFormat"))="JSON" s response(1)="{""ok"":true}"
 QUIT ""
 ;
order(%KEY,response)
 ;
 n comma,data,direction,error,globalName,i,name,next,ref,refx,seedValue,start,stop,subscript,subscripts,value
 ;
 k response
 i $g(%KEY("JSON"))'="" d
 . n json,name,no,props,value
 . s json=%KEY("JSON")
 . i $e(json,1)="[",$e(json,$l(json))="]" d
 . . s %KEY("JSON")="{Subscripts:"_json_"}"
 . s error=$$parseJSON^%zewdJSON(%KEY("JSON"),.props,1)
 . i error'="" s error=action_"Error~"_error q
 . s %KEY("GlobalName")=$g(props("GlobalName"))
 . f no=1:1 q:'$d(props("Subscripts",no))  d
 . . s value=$g(props("Subscripts",no))
 . . s %KEY("Subscript."_no_".Value")=value
 . s %KEY("SeedValue")=value
 . k %KEY("Subscript."_(no-1)_".Value")
 ;
 s globalName=$g(%KEY("GlobalName"))
 i globalName="" s globalName=$g(%KEY("Reference"))
 i globalName="" QUIT "missingGlobalName~GlobalName was not specified"
 s direction=$g(%KEY("Direction"))
 i direction="" s direction="forwards"
 s direction=$$zcvt^%zewdAPI(direction,"l")
 s stop=0
 s name=$o(%KEY("Subscript."))
 s start=$p(name,".",2)
 i start'="",start'=1 QUIT "BadSubscriptReference~Subscript numbers must start from 1"
 s error=""
 f i=start:1 d  q:stop
 . s subscript="Subscript."_i_".Value"
 . i '$d(%KEY(subscript)) s stop=1 q
 . i %KEY(subscript)="" s error="BadSubscriptReference~Subscript values cannot be null",stop=1 q
 . s subscripts(i)=%KEY(subscript)
 i error'="" QUIT error
 ;i '$d(subscripts) QUIT "MissingSubscripts~No subscripts were specified"
 i '$d(%KEY("SeedValue")) QUIT "missingSeedValue~Seed Value was not specified"
 s seedValue=$g(%KEY("SeedValue"))
 s ref="^"_globalName_"("
 i $d(subscripts) d
 . s comma=""
 . s i=""
 . f  s i=$o(subscripts(i)) q:i=""  d
 . . s ref=ref_comma_""""_subscripts(i)_""""
 . . s comma=","
 . s ref=ref_comma
 s refx=ref
 s ref=ref_""""_seedValue_""")"
 s ref="s next=$o("_ref
 i direction="backwards"!(direction="back")!(direction<0) s ref=ref_",-1"
 s ref=ref_")"
 x ref
 ;
 i next="" d
 . s data=0
 . s value=""
 e  d
 . s refx=refx_""""_next_""")"
 . s ref="s data=$d("_refx_")"
 . x ref
 . s ref="s value=$g("_refx_")"
 . x ref
 ;
 i $g(%KEY("OutputFormat"))="JSON" s response(1)="{""subscriptValue"":"""_next_""",""dataStatus"":"""_data_""",""dataValue"":"""_value_"""}" QUIT ""
 s response(0)="<OrderResult>"
 s response(1)="<NextValue>"_next_"</NextValue>"
 s response(2)="</OrderResult>"
 QUIT ""
 ;
orderAll(%KEY,response)
 ;
 n comma,data,direction,error,globalName,i,name,next,ref,refx,seedValue,start,stop,subscript,subscripts,value
 ;
 k response
 i $g(%KEY("JSON"))'="" d
 . n json,name,no,props,value
 . s json=%KEY("JSON")
 . i $e(json,1)="[",$e(json,$l(json))="]" d
 . . s %KEY("JSON")="{Subscripts:"_json_"}"
 . s error=$$parseJSON^%zewdJSON(%KEY("JSON"),.props,1)
 . i error'="" s error=action_"Error~"_error q
 . s %KEY("GlobalName")=$g(props("GlobalName"))
 . f no=1:1 q:'$d(props("Subscripts",no))  d
 . . s value=$g(props("Subscripts",no))
 . . s %KEY("Subscript."_no_".Value")=value
 . s %KEY("SeedValue")=""
 ;
 s globalName=$g(%KEY("GlobalName"))
 i globalName="" s globalName=$g(%KEY("Reference"))
 i globalName="" QUIT "missingGlobalName~GlobalName was not specified"
 s stop=0
 s name=$o(%KEY("Subscript."))
 s start=$p(name,".",2)
 i start'="",start'=1 QUIT "BadSubscriptReference~Subscript numbers must start from 1"
 s error=""
 f i=start:1 d  q:stop
 . s subscript="Subscript."_i_".Value"
 . i '$d(%KEY(subscript)) s stop=1 q
 . i %KEY(subscript)="" s error="BadSubscriptReference~Subscript values cannot be null",stop=1 q
 . s subscripts(i)=%KEY(subscript)
 i error'="" QUIT error
 ;i '$d(subscripts) QUIT "MissingSubscripts~No subscripts were specified"
 i '$d(%KEY("SeedValue")) QUIT "missingSeedValue~Seed Value was not specified"
 s seedValue=$g(%KEY("SeedValue"))
 s ref="^"_globalName_"("
 i $d(subscripts) d
 . s comma=""
 . s i=""
 . f  s i=$o(subscripts(i)) q:i=""  d
 . . s ref=ref_comma_""""_subscripts(i)_""""
 . . s comma=","
 . s ref=ref_comma
 s refx=ref
 s ref=ref_""""_seedValue_""")"
 s ref="s next=$o("_ref_")"
 x ref
 s next(1)=next
 f i=2:1 s next=$o(^(next)) q:next=""  s next(i)=next
 ;
 i '$d(next(2)) d
 . s json="[]"
 e  d
 . s json="[",comma=""
 . f i=1:1 q:'$d(next(i))  s json=json_comma_""""_next(i)_"""",comma=","
 . s json=json_"]"
 ;
 i $g(%KEY("OutputFormat"))="JSON" s response(1)=json QUIT ""
 QUIT ""
 ;
mergeToGlobal(%KEY,response)
 ;
 n comma,error,globalName,i,name,ref,start,stop,subscript,subscriptName,subscripts,subscriptValue,value
 ;
 k response
 s globalName=$g(%KEY("GlobalName"))
 i globalName="" QUIT "missingGlobalName~GlobalName was not specified"
 s stop=0
 s name=$o(%KEY("GlobalSubscript."))
 s start=$p(name,".",2)
 i start'="",start'=1 QUIT "BadGlobalSubscriptReference~Global Subscript numbers must start from 1"
 s error=""
 f i=start:1 d  q:stop
 . s subscript="GlobalSubscript."_i_".Value"
 . i '$d(%KEY(subscript)) s stop=1 q
 . i %KEY(subscript)="" s error="BadGlobalSubscriptReference~Global Subscript values cannot be null",stop=1 q
 . s subscripts(i)=%KEY(subscript)
 i error'="" QUIT error
 ;
 s stop=0
 k ^CacheTempEWD($j)
 s name=$o(%KEY("ArraySubscript."))
 s start=$p(name,".",2)
 s error=""
 f i=start:1 d  q:stop
 . s subscriptName="ArraySubscript."_i_".Name"
 . s subscriptValue="ArraySubscript."_i_".Value"
 . i '$d(%KEY(subscriptName)) s stop=1 q
 . i '$d(%KEY(subscriptValue)) s stop=1,error="MissingArrayValue~Value not specified for Array Subscript "_i q
 . i %KEY(subscriptName)="" s error="BadArraySubscriptReference~Array Subscript values cannot be null",stop=1 q
 . s ^CacheTempEWD($j,%KEY(subscriptName))=%KEY(subscriptValue)
 i error'="" QUIT error
 s ref="m ^"_globalName
 i $d(subscripts) d
 . s ref=ref_"("
 . s comma=""
 . s i=""
 . f  s i=$o(subscripts(i)) q:i=""  d
 . . s ref=ref_comma_""""_subscripts(i)_""""
 . . s comma=","
 . s ref=ref_")"
 s ref=ref_"=^CacheTempEWD($j)"
 x ref
 k ^CacheTempEWD($j)
 QUIT ""
 ;
batchSet(%KEY,response)
 ;
 n comma,error,globalName,i,name,ref,start,start2,stop,stop2,subscript,subscripts,value
 ;
 k response
 s stop=0
 s name=$o(%KEY("Item."))
 s start=$p(name,".",2)
 s error=""
 f i=start:1 d  q:stop
 . i $g(^MDBMumps("stop"))=1 s stop=1 k ^MDBMumps("stop") q
 . k subscripts
 . s ref="Item."_i_".GlobalName"
 . s globalName=$g(%KEY(ref))
 . i globalName="" d  s stop=1 q
 . . i i=1 s error="MissingGlobalName~Item 1: Global Name missing"
 . s stop2=0
 . s name=$o(%KEY("Item."_i_".Subscript."))
 . s start2=$p(name,".",4)
 . i start2'="",start2'=1 s error="BadSubscriptReference~Item "_i_": Subscript numbers must start from 1",stop=1 q
 . f j=start2:1 d  q:stop2
 . . s subscript="Item."_i_".Subscript."_j_".Value"
 . . i '$d(%KEY(subscript)) s stop2=1 q
 . . i %KEY(subscript)="" s error="BadSubscriptReference~Item "_i_": Subscript values cannot be null",stop=1 q
 . . s subscripts(j)=%KEY(subscript)
 . i error'="" s stop=1 q
 . s value=$g(%KEY("Item."_i_".DataValue"))
 . i value="" QUIT "missingDataValue~Item "_i_": Data Value was not specified"
 . s ref="s ^"_globalName
 . i $d(subscripts) d
 . . s ref=ref_"("
 . . s comma=""
 . . s j=""
 . . f  s j=$o(subscripts(j)) q:j=""  d
 . . . s ref=ref_comma_""""_subscripts(j)_""""
 . . . s comma=","
 . . s ref=ref_")"
 . s ref=ref_"="""_value_""""
 . x ref
 QUIT error
 ;
parseSubscripts(string,subs)
 n c,inquotes,len,nsub,stop,str
 ;
 s len=$l(string)
 s inquotes=0,str="",nsub=0,stop=0
 k subs
 f i=1:1:len d  q:stop
 . s c=$e(string,i)
 . i c="""" d  q
 . . i $e(string,i+1)="""" s str=str_"""""",i=i+1 q
 . . s inquotes='inquotes
 . i c=",",'inquotes d  q
 . . s nsub=nsub+1
 . . s subs(nsub)=str
 . . s str=""
 . i c=")" i 'inquotes s stop=1 q
 . s str=str_c
 i str'="" s subs(nsub+1)=str
 QUIT
 ;
mergeFromGlobal(%KEY,response)
 ;
 n comma,data,error,exists,globalName,i,lineNo,name,recNo,ref,start,stop
 n string,subs,subscript,subscripts,value
 ;
 k response
 s globalName=$g(%KEY("GlobalName"))
 i globalName="" QUIT "missingGlobalName~GlobalName was not specified"
 s stop=0
 s name=$o(%KEY("Subscript."))
 s start=$p(name,".",2)
 i start'="",start'=1 QUIT "BadSubscriptReference~Subscript numbers must start from 1"
 s error=""
 f i=start:1 d  q:stop
 . s subscript="Subscript."_i_".Value"
 . i '$d(%KEY(subscript)) s stop=1 q
 . i %KEY(subscript)="" s error="BadSubscriptReference~Subscript values cannot be null",stop=1 q
 . s subscripts(i)=%KEY(subscript)
 i error'="" QUIT error
 s ref="^"_globalName
 i $d(subscripts) d
 . s ref=ref_"("
 . s comma=""
 . s i=""
 . f  s i=$o(subscripts(i)) q:i=""  d
 . . s ref=ref_comma_""""_subscripts(i)_""""
 . . s comma=","
 . s ref=ref_")"
 k array
 s ref="m array="_ref
 x ref
 i '$d(array) s response(0)="<MergeFromGlobalResult />" QUIT
 s response(0)="<MergeFromGlobalResult>",lineNo=1
 s recNo=0
 i $d(array)=11 d
 . s response(lineNo)="<Record>",lineNo=lineNo+1
 . s response(lineNo)="<DataValue>"_array_"</DataValue>",lineNo=lineNo+1
 . s response(lineNo)="</Record>",lineNo=lineNo+1
 s ref="array("""")"
 s stop=0
 f  d  q:stop
 . s ref=$q(@ref)
 . i ref="" s stop=1 q
 . s recNo=recNo+1
 . s response(lineNo)="<Record>",lineNo=lineNo+1
 . s string=$p(ref,"(",2,5000)
 . k subs
 . d parseSubscripts(string,.subs)
 . s i=""
 . f  s i=$o(subs(i)) q:i=""  d
 . . s response(lineNo)="<Subscript no='"_i_"'>"_subs(i)_"</Subscript>",lineNo=lineNo+1
 . s data=@ref
 . s response(lineNo)="<DataValue>"_data_"</DataValue>",lineNo=lineNo+1
 . s response(lineNo)="</Record>",lineNo=lineNo+1
 s response(lineNo)="</MergeFromGlobalResult>"
 QUIT ""
 ;
increment(%KEY,response)
 ;
 n comma,delta,error,globalName,i,name,next,ref,start,stop,subscript,subscripts
 ;
 k response
 i $g(%KEY("JSON"))'="" d
 . n json,name,no,props,value
 . s json=%KEY("JSON")
 . i $e(json,1)="[",$e(json,$l(json))="]" s %KEY("JSON")="{Subscripts:"_json_"}"
 . s error=$$parseJSON^%zewdJSON(%KEY("JSON"),.props,1)
 . i error'="" s error=action_"Error~"_error q
 . s %KEY("GlobalName")=$g(props("GlobalName"))
 . f no=1:1 q:'$d(props("Subscripts",no))  d
 . . s value=$g(props("Subscripts",no))
 . . s %KEY("Subscript."_no_".Value")=value
 ;
 s globalName=$g(%KEY("GlobalName"))
 i globalName="" s globalName=$g(%KEY("Reference"))
 i globalName="" QUIT "missingGlobalName~GlobalName was not specified"
 s stop=0
 s name=$o(%KEY("Subscript."))
 s start=$p(name,".",2)
 i start'="",start'=1 QUIT "BadSubscriptReference~Subscript numbers must start from 1"
 s error=""
 f i=start:1 d  q:stop
 . s subscript="Subscript."_i_".Value"
 . i '$d(%KEY(subscript)) s stop=1 q
 . i %KEY(subscript)="" s error="BadSubscriptReference~Subscript values cannot be null",stop=1 q
 . s subscripts(i)=%KEY(subscript)
 i error'="" QUIT error
 s ref="^"_globalName
 i $d(subscripts) d
 . s ref=ref_"("
 . s comma=""
 . s i=""
 . f  s i=$o(subscripts(i)) q:i=""  d
 . . s ref=ref_comma_""""_subscripts(i)_""""
 . . s comma=","
 . s ref=ref_")"
 s delta=$g(%KEY("Delta")) i delta="" s delta=1
 i $g(%KEY("Action"))="Decrement" s delta=-delta
 s ref="s next=$increment("_ref_","_delta_")"
 x ref
 i $g(%KEY("OutputFormat"))="JSON" s response(1)="{""value"":"_next_"}" QUIT ""
 s response(0)="<IncrementResult>"
 s response(1)="<NextValue>"_next_"</NextValue>"
 s response(2)="</IncrementResult>"
 QUIT ""
 ;
function(%KEY,response)
 ;
 n func,functionName,json,paramList,result
 ;
 k response
 s json=$g(%KEY("JSON"))
 s paramList=""
 i $e(json,1)="[",$e(json,$l(json))="]" s paramList=$e(json,2,$l(json)-1)
 ;
 i $g(%KEY("Reference"))="" QUIT "missingFunctionName~Reference (Function Name) was not specified"
 s functionName=%KEY("Reference")
 i $e(functionName,1,2)="##"!($e(functionName,1,2)="$$") d
 . s func=functionName_"("
 e  d
 . s func="$$"_functionName_"("
 s func="s result="_func_paramList_")"
 d
 . n (func,result)
 . x func
 s response(1)="{""value"":"""_result_"""}"
 ;
 QUIT ""
 ;
