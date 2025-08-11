component extends="org.lucee.cfml.test.LuceeTestCase" labels="compress" {

	function beforeAll() {
		variables.path = getTempDirectory() & "LDEV3882/";

		variables.dir = path & "a/b/c/";
		variables.file1 = dir & "a.txt"
		variables.dir1 = path & "a/";
		variables.file2 = path & "a/b.txt";
		variables.target = path & "test.zip";

		if ( directoryExists( path ) ) directoryDelete( path, true );

		directoryCreate( dir );
		fileWrite( file1, getFunctionList().toJson() );
		fileWrite( file2, getFunctionList().toJson() ); // need some content!
	}

	function run( testResults, testBox ) {
		describe( "Testcase for LDEV-5540",function() {
			it( title="Checking zip compressionMethod", body=function( currentSpec ) {
				systemOutput("", true );
				var compressionTypes = "deflate,deflateNormal,deflateFast,deflateFastest,deflateMaximum,deflateUltra,store";
				listAppend( compressionTypes, "deflateUtra" ); // backwards compat for old typo LDEV-5540

				loop list="#compressionTypes#" item="local.level"{
					systemOutput(" testing compressionMethod [#local.level#]", true );
					var tmpZip = getTempFile(getTempDirectory(), "zipCompression-#level#", "zip");
					createTestZip( tmpZip, level );
					systemOutput(" file was #numberFormat(fileInfo(tmpZip).size)#", true );
					zip action="list" file="#tmpZip#" name="local.qry"; 
					expect( len( qry ) ).toBe( 6 );
				}
			});
		});
	}
	
	private function createTestZip( target, compressionMethod) {
		if ( fileExists( arguments.target ) ) fileDelete( arguments.target );

		// creates zip file with 5 .txt file and 1 .cfm file

		zip action="zip" file="#arguments.target#" compressionMethod="#arguments.compressionMethod#" {
			zipparam entryPath = "/1/2.cfm" source=variables.file1;
			zipparam source = variables.file1;
			zipparam source = variables.dir1;
			zipparam prefix="n/m" source = variables.dir1;
		}
	}
}