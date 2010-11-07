# M/DB
 
M/DB is an Open Source clone of SimpleDB

For convenience, this repository also includes the M/Wire back-end routines for GT.M and Cache.

#Acknowledgements

07 November 2010: Thanks to Richard Miller for identifying several performance issues in zmwire.m

## License

Copyright (c) 2004-10 M/Gateway Developments Ltd,
Reigate, Surrey UK.
All rights reserved.

http://www.mgateway.com
Email: rtweed@mgateway.com

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Installation

This Free Open Source version of M/DB is designed for use with the GT.M database [http://fisglobal.com/Products/TechnologyPlatforms/GTM/index.htm](http://fisglobal.com/Products/TechnologyPlatforms/GTM/index.htm).  It also requires the Apache Web Server to be configured with our m_apache gateway. 

See [http://www.mgateway.com/mdb.html](http://www.mgateway.com/mdb.html) for full details about M/DB.

- download the files MDB.m and MDBMumps.m, eg

    git clone git://github.com/robtweed/mdb.git

 The destination directory in which you'll find the files is determined by the path in which you ran the above command.
	
Then copy all the files with a *.m* extension to your working GT.M directory (eg, on the M/DB Appliance, */usr/local/gtm/ewd*)

If you are installing on a Cach&#233; system, import the contents of the file */lib/mdb.xml* using *$system.OBJ.Load(filepath)*.

## Background

M/DB is an Open Source clone of SimpleDB that uses the Open Source GT.M Mumps database as the storage engine.  M/DB behaves identically to SimpleDB, sharing its APIs.

The *mdb* repository also include M/DB:Mumps which provides an HTTP-based interface to the standard Mumps database.  The interface makes use of the same security mechanism as SimpleDB to protect access to the back-end Mumps database.

M/DB:Mumps requires M/DB to be in place and initialised before it can be used.

The Node.js module *node-mdbm* makes use of M/DB:Mumps to provide the HTTP interface to/from the Mumps database.


    


