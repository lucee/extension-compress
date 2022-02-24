<!--- 
*
* Copyright (c) 2016, Lucee Assosication Switzerland. All rights reserved.
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either 
* version 2.1 of the License, or (at your option) any later version.
* 
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
* 
* You should have received a copy of the GNU Lesser General Public 
* License along with this library.  If not, see <http://www.gnu.org/licenses/>.
* 
---><cfscript>
component extends="org.lucee.cfml.test.LuceeTestCase" labels="zip" {

    function beforeAll() {
        variables.path = getDirectoryFromPath(getCurrentTemplatePath()) & "LDEV3880/";

        variables.dir = path & "a/b/c/";
        variables.file1 = dir & "a.js"
        variables.dir1 = path & "a/";
        variables.file2 = path & "a/b.txt";
        variables.target = path & "test.zip";

        if ( directoryExists( path ) ) directoryDelete( path, true );

        directoryCreate( dir );
        fileWrite( file1, "file 1" );
        fileWrite( file2, "file 2" );

         if ( fileExists( target ) ) fileDelete( target );

        zip action="zip" file=target {
            zipparam entryPath = "/1/2.cfm" source=variables.file1;
            zipparam source = variables.file1;
            zipparam source = variables.dir1;
            zipparam prefix="n/m" source = variables.dir1;
        }
    }

    function run( testResults, testBox ) {
        describe( "Testcase for LDEV-3880",function() {
            it( title="Checking cfzip filter delimiters", body=function( currentSpec ) {
                zip action="list" name="local.qry" file=target filter="*.txt,*.js"; // comma(,) as delimeter
                expect(len(qry)).toBe(5);

                zip action="list" name="local.qry" file=target filter="*.txt|*.js"; // pipe(|) as delimeter
                expect(len(qry)).toBe(5);

                zip action="list" name="local.qry" file=target filter="*.txt,*.js|*.cfm"; // Both comma(,) & pipe(|) as delimeter
                expect(len(qry)).toBe(6);

                zip action="list" name="local.qry" file=target filter="*.txt$*.js$*.cfm" filterdelimiters="$"; // Using filterdelimiters argument
                expect(len(qry)).toBe(6);
            });
        });
    }

    function afterAll() {
        if ( directoryExists(variables.path) ) directoryDelete( variables.path, true );
    }
} 
</cfscript>
