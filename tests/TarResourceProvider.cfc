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
		describe( title="Test suite for TAR virtual file system", body=function() {

			it(title="check if the tar resource provider is installed", body = function( currentSpec ) {
				expect(	getClassFor("tar") ).toBe( "org.lucee.extension.compress.resource.TarResourceProvider" );
			});

			it(title="test TAR file operations - fileWrite, fileRead, fileAppend", body = function( currentSpec ) {
				testTARFileOperations();
			});
			
			it(title="test TAR directory operations - directoryList, directoryCreate", body = function( currentSpec ) {
				testTARDirectoryOperations();
			});
			
			it(title="test TAR fileExists and fileDelete", body = function( currentSpec ) {
				testTARFileExistsAndDelete();
			});
			
			it(title="test TAR nested directory structure", body = function( currentSpec ) {
				testTARNestedStructure();
			});

		});
	}

	private function testTARFileOperations() localMode=true {
		var tempDir = getTempDirectory() & "tar_test_" & getTickCount() & "/";
		var tarFile = tempDir & "test.tar";
		var phrase1 = "Just some content.";
		var phrase2 = " Some more content.";
		
		try {
			// Create temp directory
			directoryCreate(tempDir);
			
			// Create initial file to compress
			var initialFile = tempDir & "initial.txt";
			fileWrite(initialFile, "initial");
			
			// Create TAR archive using compress function
			compress("tar", tempDir, tarFile);
			
			// Test file write inside TAR
			var pathInTAR = "tar://#tarFile#!/testfile.txt";
			fileWrite(pathInTAR, phrase1);
			assertTrue(fileExists(pathInTAR));
			
			// Test file read
			var content = fileRead(pathInTAR);
			assertEquals(content, phrase1);
			
			// Test file append
			fileAppend(pathInTAR, phrase2);
			content = fileRead(pathInTAR);
			assertEquals(content, phrase1 & phrase2);
		}
		finally {
			if (directoryExists(tempDir)) {
				directoryDelete(tempDir, true);
			}
		}
	}

	private function testTARDirectoryOperations() localMode=true {
		var tempDir = getTempDirectory() & "tar_test_" & getTickCount() & "/";
		var tarFile = tempDir & "test.tar";
		
		try {
			// Create temp directory with some structure
			directoryCreate(tempDir);
			directoryCreate(tempDir & "subfolder/");
			fileWrite(tempDir & "file1.txt", "content1");
			fileWrite(tempDir & "subfolder/file2.txt", "content2");
			
			// Create TAR archive using compress function
			compress("tar", tempDir, tarFile);
			
			// Test directory list at root
			var pathInTAR = "tar://#tarFile#!/";
			var dirList = directoryList(pathInTAR);
			assertTrue(arrayLen(dirList) > 0);
			
			// Test directory list in subfolder
			var subfolderPath = "tar://#tarFile#!/subfolder/";
			var subDirList = directoryList(subfolderPath);
			assertTrue(arrayLen(subDirList) > 0);
			
			// Test directory creation inside TAR
			var newDirPath = "tar://#tarFile#!/newdir/";
			directoryCreate(newDirPath);
			assertTrue(directoryExists(newDirPath));
		}
		finally {
			if (directoryExists(tempDir)) {
				directoryDelete(tempDir, true);
			}
		}
	}

	private function testTARFileExistsAndDelete() localMode=true {
		var tempDir = getTempDirectory() & "tar_test_" & getTickCount() & "/";
		var tarFile = tempDir & "test.tar";
		
		try {
			// Create temp directory and file
			directoryCreate(tempDir);
			fileWrite(tempDir & "test.txt", "test content");
			
			// Create TAR archive using compress function
			compress("tar", tempDir, tarFile);
			
			// Test fileExists
			var pathInTAR = "tar://#tarFile#!/test.txt";
			assertTrue(fileExists(pathInTAR));
			
			// Test for non-existent file
			var nonExistentPath = "tar://#tarFile#!/nonexistent.txt";
			assertFalse(fileExists(nonExistentPath));
			
			// Test file delete
			fileDelete(pathInTAR);
			assertFalse(fileExists(pathInTAR));
		}
		finally {
			if (directoryExists(tempDir)) {
				directoryDelete(tempDir, true);
			}
		}
	}

	private function testTARNestedStructure() localMode=true {
		var tempDir = getTempDirectory() & "tar_test_" & getTickCount() & "/";
		var tarFile = tempDir & "test.tar";
		
		try {
			// Create nested directory structure
			directoryCreate(tempDir);
			directoryCreate(tempDir & "level1/level2/level3/");
			fileWrite(tempDir & "level1/level2/level3/deep.txt", "deep content");
			
			// Create TAR archive using compress function
			compress("tar", tempDir, tarFile);
			
			// Test reading from nested path
			var deepPath = "tar://#tarFile#!/level1/level2/level3/deep.txt";
			assertTrue(fileExists(deepPath));
			var content = fileRead(deepPath);
			assertEquals(content, "deep content");
			
			// Test writing to nested path
			var newDeepPath = "tar://#tarFile#!/level1/level2/level3/newfile.txt";
			fileWrite(newDeepPath, "new deep content");
			assertTrue(fileExists(newDeepPath));
		}
		finally {
			if (directoryExists(tempDir)) {
				directoryDelete(tempDir, true);
			}
		}
	}

	private function getClassFor(scheme) {
		var pc=getPageContext();
		var config=pc.getConfig();
		var schemes={};
		loop array=config.getResourceProviders()	item="local.provider" {
			if(provider.scheme==arguments.scheme) return provider.class.name;
			schemes[provider.scheme]=provider.class.name;
		}
		throw "scheme [#arguments.scheme#] not found, only the following schemes are available [#serializeJson(schemes)#]"
		dump(config);
	}
} 
</cfscript>