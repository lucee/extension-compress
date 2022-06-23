component extends="org.lucee.cfml.test.LuceeTestCase" labels="zip" {

	function testAddNonFileSystemResourceToZip() {
		var sampleFilename = "test_LDEV-2890.txt";
		var sampleResource = "ram://#sampleFilename#";
		fileWrite( sampleResource, "non file resource stream test" );
		var tempFile = getTempFile( getTempDirectory() , "zip" );

		cfzip( action="zip", file="#tempFile#.zip", source="#sampleResource#" );
		cfzip( action="list", file="#tempFile#.zip", name="local.zipFiles" );

		expect( zipfiles.recordCount).toBe( 1 );
		expect( zipfiles.name[1]).toBe( sampleFilename );

		if ( fileExists( "#tempFile#.zip" ) )
			fileDelete( "#tempFile#.zip" );
		fileDelete( sampleResource );
	}

	function testAddFileToNonFileSystemZip() {

		var tempFile = getTempFile( getTempDirectory() , "zip" );
		var tempFileName = listLast( tempFile, "/\");
		var zipFilename = "test_LDEV-2890.zip";
		var zipFile = "ram://#zipFilename#";

		fileWrite( tempFile, "file resource stream test" );

		cfzip( action="zip", file="#zipFile#", source="#tempFile#" );
		cfzip( action="list", file="#zipFile#", name="local.zipFiles" );

		expect( zipfiles.recordCount).toBe( 1 );
		expect( zipfiles.name[1]).toBe( tempFilename );

		if ( fileExists( tempFile ) )
			fileDelete( tempFilew );
		if ( fileExists( zipFile ) )
			fileDelete( zipFile );
	}

}

