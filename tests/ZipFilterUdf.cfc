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

	public function setUp() {
		
		variables.currFile = getCurrentTemplatePath();
		variables.currDir = getDirectoryFromPath( currFile );
		variables.testSubFolder = "zipUDFtest";
		variables.root = currDir & "#variables.testSubFolder#/";

		variables.dir = root & "a/b/c/";
		variables.file1 = dir & "a.txt"
		variables.dir1 = root & "a/";
		variables.file2 = root & "a/b.txt";
		variables.target = root & "test.zip";
		
		if ( directoryExists( root ) ) directoryDelete( root, true );

		directoryCreate( dir );
		fileWrite( file1, "file 1" );
		fileWrite( file2, "file 2" );
	}

	// ensure the paths passed to the filter UDF are relative
	public function testZipFilterUdfPaths() {
		try {
			if ( fileExists( target ) ) fileDelete( target );
			// zip
			zip action="zip" file=target {
				zipparam entryPath = "/1/2.cfm" source=variables.file1;
				zipparam source = variables.file1;
				zipparam source = variables.dir1;
				zipparam prefix="n/m" source =variables.dir1;
			}

			// first test normal filter wildcards
			zip action="list" file=target name="local.qry" filter="*.zip"; 
			expect( qry.recordcount ).toBe( 0 ); // there are no zips
			
			zip action="list" file=target name="local.qry" filter="#variables.testSubFolder#/*";
			expect( qry.recordcount ).toBe( 0 ); // shouldn't match parent folder

			zip action="list" file=target name="local.qry" filter="*.txt";
			expect( qry.recordcount ).toBe( 5 );

			zip action="list" file=target name="local.qry" filter="*.cfm";
			expect( qry.recordcount ).toBe( 1 );
			
			// then test udf filters
			var zipEntryPaths = [];
			var zipListFilter = function ( zipEntryPath ) {
				ArrayAppend( zipEntryPaths, replace( zipEntryPath, "\", "/", "all" ) );
				return true;
			};

			// list
			zip action="list" file=target name="local.qry" filter=zipListFilter;

			expect( qry.recordcount ).toBe( 6 );
			expect( listSort( ArrayToList( zipEntryPaths ), 'textnocase' ) ).toBe( '1/2.cfm,a.txt,b.txt,b/c/a.txt,n/m/b.txt,n/m/b/c/a.txt' );


		}
		finally {
			if ( directoryExists(root) ) directoryDelete( root, true );
		}
	}
} 
</cfscript>
