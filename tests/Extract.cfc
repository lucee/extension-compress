component extends="org.lucee.cfml.test.LuceeTestCase" labels="compress" {
	
	function testExtract() {
		loop list="tgz:m,zip:m,tbz:m,tar:m,gzip:s,bzip:s" item="local.format2type" {
			var format = listFirst(format2type, ":");
			var type = listLast(format2type, ":");

			try {
				var curr = getDirectoryFromPath(getCurrentTemplatePath());
				
				// Create source files to compress first
				var srcDir = curr & "srctmp" & format;
				var src = srcDir & "/test.txt";
				if(directoryExists(srcDir)) directoryDelete(srcDir, true);
				directoryCreate(srcDir);
				fileWrite(src, "Test content for extraction of " & format);
				
				// Create additional file for multi-file formats
				if(type == "m") {
					fileWrite(srcDir & "/test2.txt", "Second test file");
				}

				// Create compressed file
				var compressedDir = curr & "compressed" & format;
				var compressedFile = compressedDir & "/test." & format;
				if(directoryExists(compressedDir)) directoryDelete(compressedDir, true);
				directoryCreate(compressedDir);
				
				compress(format:format, source:type=="m"?srcDir:src, target:compressedFile, includeBaseFolder:true);
				assertTrue(fileExists(compressedFile), "Compressed file should exist for " & format);

				// Test extraction
				var extractDir = curr & "extracted" & format;
				var extractTarget = type == "m" ? extractDir : extractDir & "/test.txt";
				if(directoryExists(extractDir)) directoryDelete(extractDir, true);
				directoryCreate(extractDir);
				
				// Call extract function
				var result = extract(format, compressedFile, extractTarget);
				assertTrue(result, "Extract function should return true for " & format);

				// Verify extracted content
				if(type == "m") {
					// For multi-file formats, check if directory structure is preserved
					var extractedFile = extractDir & "/srctmp" & format & "/test.txt";
					assertTrue(fileExists(extractedFile), "Extracted file should exist at " & extractedFile);
					assertEquals("Test content for extraction of " & format, fileRead(extractedFile), "Content should match original for " & format);
					
					// Check second file
					var extractedFile2 = extractDir & "/srctmp" & format & "/test2.txt";
					assertTrue(fileExists(extractedFile2), "Second extracted file should exist");
					assertEquals("Second test file", fileRead(extractedFile2), "Second file content should match");
				} else {
					// For single-file formats
					assertTrue(fileExists(extractTarget), "Extracted file should exist for " & format);
					assertEquals("Test content for extraction of " & format, fileRead(extractTarget), "Content should match original for " & format);
				}

			}
			finally {
				// Cleanup
				if(directoryExists(srcDir)) directoryDelete(srcDir, true);
				if(directoryExists(compressedDir)) directoryDelete(compressedDir, true);
				if(directoryExists(extractDir)) directoryDelete(extractDir, true);
			}
		}
	}

	function testExtractFromDirectory() {
		// Test extracting when source is a directory containing compressed files
		var format = "zip";
		
		try {
			var curr = getDirectoryFromPath(getCurrentTemplatePath());
			
			// Create multiple compressed files in a directory
			var srcDir = curr & "srctmp_multi";
			var compressedDir = curr & "compressed_multi";
			if(directoryExists(srcDir)) directoryDelete(srcDir, true);
			if(directoryExists(compressedDir)) directoryDelete(compressedDir, true);
			directoryCreate(srcDir);
			directoryCreate(compressedDir);
			
			// Create and compress two files
			fileWrite(srcDir & "/file1.txt", "Content 1");
			compress(format:"zip", source:srcDir & "/file1.txt", target:compressedDir & "/test1.zip", includeBaseFolder:false);
			
			fileWrite(srcDir & "/file2.txt", "Content 2");
			compress(format:"zip", source:srcDir & "/file2.txt", target:compressedDir & "/test2.zip", includeBaseFolder:false);
			
			// Extract from directory
			var extractDir = curr & "extracted_multi";
			if(directoryExists(extractDir)) directoryDelete(extractDir, true);
			directoryCreate(extractDir);
			
			var result = extract("zip", compressedDir, extractDir);
			assertTrue(result, "Extract from directory should succeed");
			
		}
		finally {
			if(directoryExists(srcDir)) directoryDelete(srcDir, true);
			if(directoryExists(compressedDir)) directoryDelete(compressedDir, true);
			if(directoryExists(extractDir)) directoryDelete(extractDir, true);
		}
	}
}