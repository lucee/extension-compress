<cfscript>

	workingDir = getTempDirectory() & "zip-1989\#createGUID()#\";
	
	if ( directoryExists( workingDir ) )
		directoryDelete( workingDir, true );
	directoryCreate( workingDir );
		
	zipPassword = "safePassword";

	zipfile = "#workingDir#/passwordWithEncryptionAlgorithm-#url.encryptionAlgorithm#.zip";

	tempFile = getTempFile(getTempDirectory(), "txt");
	fileWrite( tempFile, serializeJSON( extensionList() ) );
	
	zip action="zip" file="#zipFile#"  overwrite="true" password="#zipPassword#" encryptionAlgorithm="#url.encryptionAlgorithm#" {
		zipparam encryptionAlgorithm="#url.encryptionAlgorithm#" source="#tempFile#";  // encryptionAlgorithm="#url.encryptionAlgorithm#" doesn't work
	}

	zip action="list" file="#zipfile#" name="res";

	switch (url.encryptionAlgorithm){
		case "aes128":
			expectedAlgorithm = "aes";	
			break;
		case "aes192":
			expectedAlgorithm = "aes";	
			break;
		case "aes":
			expectedAlgorithm = "aes";	
			break;
		case "standardStrong":
			expectedAlgorithm = "ZIP_STANDARD_VARIANT_STRONG";
		default:
			expectedAlgorithm = "ZIP_STANDARD";	
	}
	
	// systemOutput( res, true );

	unZipDir = workingDir & "/unzipped-#url.encryptionAlgorithm#/";
	if ( !directoryExists( unZipDir ) )
		directoryCreate( unZipDir );
	
	zip action="unzip" file="#zipFile#" destination="#unzipDir#" password="#zipPassword#";

	// systemOutput( directoryList( unzipDir ), true );

	origFileContent = FileRead( tempFile );
	outFileContent = FileRead( unzipDir & GetFileFromPath( tempFile) );

	fileDelete( tempFile );
	directoryDelete( workingDir, true );

	// test that the contents of this script are the same after zip and unzip with a password and encryptionAlgorithm
	result = {
		expectedAlgorithm: expectedAlgorithm,
		encryptionAlgorithm: url.encryptionAlgorithm,
		files: res,
		matches: ( len(origFileContent) gt 0 && origFileContent eq outFileContent )
	}
	echo( result.toJson() );
</cfscript>
