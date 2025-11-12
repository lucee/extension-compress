<!--- 
 *
 * Copyright (c) 2015, Lucee Assosication Switzerland. All rights reserved.
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
component extends="org.lucee.cfml.test.LuceeTestCase" labels="compress"	{
	
	function run( testResults , testBox ) {
		describe( title="Test suite for TGZ virtual file system", body=function() {
			
			it(title="test TGZ file operations - fileWrite, fileRead, fileAppend", body = function( currentSpec ) {
				testTGZFileOperations();
			});
			
			it(title="test TGZ directory operations - directoryList, directoryCreate", body = function( currentSpec ) {
				testTGZDirectoryOperations();
			});
			
			it(title="test TGZ fileExists and fileDelete", body = function( currentSpec ) {
				testTGZFileExistsAndDelete();
			});
			
			it(title="test TGZ nested directory structure", body = function( currentSpec ) {
				testTGZNestedStructure();
			});

		});
	}

	private function testTGZFileOperations() localMode=true {
		var tempDir = getTempDirectory() & "tgz_test_" & getTickCount() & "/";
		var tgzFile = tempDir & "test.tgz";
		var phrase1 = "Just some content.";
		var phrase2 = " Some more content.";
		
		try {
			// Create temp directory
			directoryCreate(tempDir);
			
			// Create initial file to compress
			var initialFile = tempDir & "initial.txt";
			fileWrite(initialFile, "initial");
			
			// Create TGZ archive
			zip action="zip" file="#tgzFile#" source="#tempDir#" overwrite="true" format="tgz";
			
			// Test file write inside TGZ
			var pathInTGZ = "tgz://#tgzFile#!/testfile.txt";
			fileWrite(pathInTGZ, phrase1);
			assertTrue(fileExists(pathInTGZ));
			
			// Test file read
			var content = fileRead(pathInTGZ);
			assertEquals(content, phrase1);
			
			// Test file append
			fileAppend(pathInTGZ, phrase2);
			content = fileRead(pathInTGZ);
			assertEquals(content, phrase1 & phrase2);
		}
		finally {
			if (directoryExists(tempDir)) {
				directoryDelete(tempDir, true);
			}
		}
	}

	private function testTGZDirectoryOperations() localMode=true {
		var tempDir = getTempDirectory() & "tgz_test_" & getTickCount() & "/";
		var tgzFile = tempDir & "test.tgz";
		
		try {
			// Create temp directory with some structure
			directoryCreate(tempDir);
			directoryCreate(tempDir & "subfolder/");
			fileWrite(tempDir & "file1.txt", "content1");
			fileWrite(tempDir & "subfolder/file2.txt", "content2");
			
			// Create TGZ archive
			zip action="zip" file="#tgzFile#" source="#tempDir#" overwrite="true" format="tgz";
			
			// Test directory list at root
			var pathInTGZ = "tgz://#tgzFile#!/";
			var dirList = directoryList(pathInTGZ);
			assertTrue(arrayLen(dirList) > 0);
			
			// Test directory list in subfolder
			var subfolderPath = "tgz://#tgzFile#!/subfolder/";
			var subDirList = directoryList(subfolderPath);
			assertTrue(arrayLen(subDirList) > 0);
			
			// Test directory creation inside TGZ
			var newDirPath = "tgz://#tgzFile#!/newdir/";
			directoryCreate(newDirPath);
			assertTrue(directoryExists(newDirPath));
		}
		finally {
			if (directoryExists(tempDir)) {
				directoryDelete(tempDir, true);
			}
		}
	}

	private function testTGZFileExistsAndDelete() localMode=true {
		var tempDir = getTempDirectory() & "tgz_test_" & getTickCount() & "/";
		var tgzFile = tempDir & "test.tgz";
		
		try {
			// Create temp directory and file
			directoryCreate(tempDir);
			fileWrite(tempDir & "test.txt", "test content");
			
			// Create TGZ archive
			zip action="zip" file="#tgzFile#" source="#tempDir#" overwrite="true" format="tgz";
			
			// Test fileExists
			var pathInTGZ = "tgz://#tgzFile#!/test.txt";
			assertTrue(fileExists(pathInTGZ));
			
			// Test for non-existent file
			var nonExistentPath = "tgz://#tgzFile#!/nonexistent.txt";
			assertFalse(fileExists(nonExistentPath));
			
			// Test file delete
			fileDelete(pathInTGZ);
			assertFalse(fileExists(pathInTGZ));
		}
		finally {
			if (directoryExists(tempDir)) {
				directoryDelete(tempDir, true);
			}
		}
	}

	private function testTGZNestedStructure() localMode=true {
		var tempDir = getTempDirectory() & "tgz_test_" & getTickCount() & "/";
		var tgzFile = tempDir & "test.tgz";
		
		try {
			// Create nested directory structure
			directoryCreate(tempDir);
			directoryCreate(tempDir & "level1/level2/level3/");
			fileWrite(tempDir & "level1/level2/level3/deep.txt", "deep content");
			
			// Create TGZ archive
			zip action="zip" file="#tgzFile#" source="#tempDir#" overwrite="true" format="tgz";
			
			// Test reading from nested path
			var deepPath = "tgz://#tgzFile#!/level1/level2/level3/deep.txt";
			assertTrue(fileExists(deepPath));
			var content = fileRead(deepPath);
			assertEquals(content, "deep content");
			
			// Test writing to nested path
			var newDeepPath = "tgz://#tgzFile#!/level1/level2/level3/newfile.txt";
			fileWrite(newDeepPath, "new deep content");
			assertTrue(fileExists(newDeepPath));
		}
		finally {
			if (directoryExists(tempDir)) {
				directoryDelete(tempDir, true);
			}
		}
	}
} 
</cfscript>