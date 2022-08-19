component extends = "org.lucee.cfml.test.LuceeTestCase" {
	
	function beforeAll() {
		variables.path = "#getDirectoryFromPath(getCurrenttemplatepath())#LDEV4142\";
		if(!directoryExists(path)) directoryCreate(path)
		fileWrite("#path#testfile.txt","test");
	}

	function run ( testResults , testBox ) {
		describe("Testcase for LDEV-4142", function() {	
			it( title="checking encryptionalgorithm and password attribute in cfzipparam without entrypath attribute", body=function( currentSpec ) {

				zip action="zip" file="#path#ziptest.zip" source="#path#testfile.txt"  password="LDEV4142" encryptionalgorithm="aes128" entrypath="newdir\testfile.txt";
				zip action="unzip", file="#path#ziptest.zip", destination="#path#" {
					zipparam  password="LDEV4142", encryptionalgorithm="aes128";
				}

				expect(fileExists("#path#\newdir\testfile.txt")).tobeTrue();
			})
 
			it( title="checking encryptionalgorithm and password attribute in cfzipparam with entrypath attribute", body=function( currentSpec ) {
				zip action="zip" file="#path#zip-test.zip" source="#path#testfile.txt"  password="LDEV4142" encryptionalgorithm="aes128" entrypath="newdir\file.txt";

				try {
					zip action="unzip", file="#path#zip-test.zip", destination="#path#" {
						zipparam entrypath="newdir\file.txt", password="LDEV4142", encryptionalgorithm="aes128";
					}
				}
				catch(any e) {
					var result = e.message;
				}

				expect(fileExists("#path#\newdir\file.txt")).tobeTrue();
			})

			it( title="checking encryptionalgorithm and password attribute in cfzipparam with using wrong password and entrypath attribute", body=function( currentSpec ) {
				zip action="zip" file="#path#zip_test.zip" source="#path#testfile.txt"  password="LDEV4142" encryptionalgorithm="aes128" entrypath="newdir\zipfile.txt";

				try {
					zip action="unzip", file="#path#zip_test.zip", destination="#path#dir" {
						zipparam entrypath="newdir\zipfile.txt", password="wrong_password", encryptionalgorithm="aes128";
					}
				}
				catch(any e) {
					var result = e.message;
				}

				expect(result).toInclude("wrong password");
			})

		});
	}

	function afterAll() {
		if(directoryExists(path)) directoryDelete(path,true);
	}

}