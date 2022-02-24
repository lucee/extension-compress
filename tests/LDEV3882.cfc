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
        variables.path = getDirectoryFromPath(getCurrentTemplatePath()) & "LDEV3882/";

        variables.dir = path & "a/b/c/";
        variables.file1 = dir & "a.txt"
        variables.dir1 = path & "a/";
        variables.file2 = path & "a/b.txt";
        variables.target = path & "test.zip";

        if ( directoryExists( path ) ) directoryDelete( path, true );

        directoryCreate( dir );
        fileWrite( file1, "file 1" );
        fileWrite( file2, "file 2" );
    }

    function run( testResults, testBox ) {
        describe( "Testcase for LDEV-3882",function() {
            it( title="Checking zip action = delete wildcard filter", body=function( currentSpec ) {
                createTestZip();
                zip action="delete" file=target filter="*.cfm"; // delete cfm file

                zip action="list" file=target name="local.qry"; 
                expect(len(qry)).toBe(5);

                createTestZip(); // recreate zip file 
                zip action="delete" file=target filter="*.txt"; // delete txt files

                zip action="list" file=target name="local.qry"; 
                expect(len(qry)).toBe(1);
            });

            it( title="Checking zip action = delete UDF filter", body=function( currentSpec ) {  
                createTestZip(); // recreate zip file

                var deletedZipEntries = [];
                var zipListFilter = function ( zipEntryPath ) {
                    if ( replace( zipEntryPath, "\", "/", "all" ) contains "n/m" ) {
                        ArrayAppend( deletedZipEntries, replace( zipEntryPath, "\", "/", "all" ) );
                        return true;
                    }
                    return false;
                };
                
                zip action="delete" file=target filter=zipListFilter; // delete file have "n/m" in path
                expect( listSort( ArrayToList( deletedZipEntries ), 'textnocase' ) ).toBe( 'n/m/b.txt,n/m/b/c/a.txt' );

                zip action="list" file=target name="local.qry";
                expect(len(qry)).toBe(4);
            });
        });
    }

    function afterAll() {
        if ( directoryExists(variables.path) ) directoryDelete( variables.path, true );
    }

    private function createTestZip() {
        if ( fileExists( target ) ) fileDelete( target );

        // creates zip file with 5 .txt file and 1 .cfm file

        zip action="zip" file=target {
            zipparam entryPath = "/1/2.cfm" source=variables.file1;
            zipparam source = variables.file1;
            zipparam source = variables.dir1;
            zipparam prefix="n/m" source = variables.dir1;
        }
    }
}
</cfscript>