component extends="org.lucee.cfml.test.LuceeTestCase" labels="zip"{
	function beforeAll(){
		variables.uri = createURI("LDEV1989");
	}
	function run( testResults , testBox ) {
		describe( "Test suite for LDEV-1989", function() {
			it( title='Checking password and empty encryptionAlgorithm in CFZIP', body=function( currentSpec ) {
				local.result = _InternalRequest(
					template:"#variables.uri#/zip-password-test.cfm",
					url: {
						encryptionAlgorithm: ""
					}
				);
				validateResult(result);
			});

			it( title='Checking password and encryptionAlgorithm=standard in CFZIP', body=function( currentSpec ) {
				local.result = _InternalRequest(
					template:"#variables.uri#/zip-password-test.cfm",
					url: {
						encryptionAlgorithm: "standard"
					}
				);
				validateResult(result);
			});

			it( title='Checking password and encryptionAlgorithm=aes in CFZIP', body=function( currentSpec ) {
				local.result = _InternalRequest(
					template:"#variables.uri#/zip-password-test.cfm",
					url: {
						encryptionAlgorithm: "aes"
					}
				);
				validateResult(result);
			});

			it( title='Checking password and encryptionAlgorithm=aes128 in CFZIP', body=function( currentSpec ) {
				local.result = _InternalRequest(
					template:"#variables.uri#/zip-password-test.cfm",
					url: {
						encryptionAlgorithm: "aes128"
					}
				);
				validateResult(result);
			});
		});
	}

	private function validateResult(result){
		expect ( isJson( result.fileContent ) ).toBeTrue();
		var r = deserializeJson( result.fileContent, false );
		expect ( r.matches ).toBeTrue("file content was different");
		for ( local.f in r.files ){
			expect ( f.encryptionAlgorithm ).toBe( r.expectedAlgorithm ) ;
		}
	}

	private string function createURI(string calledName){
		var folder = getDirectoryFromPath(getCurrentTemplatePath());
		var baseURI="/testAdditional/" & ListRest(listLast(folder,"/\"),"/\") & "/";
		return baseURI&""&calledName;
	}
} 