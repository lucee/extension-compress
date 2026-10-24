component extends="org.lucee.cfml.test.LuceeTestCase" labels="compress"{
	
	function run( testResults , testBox ) {
		describe( "Test suite for loading tags", function() {
			it( title='are the tags listed', body=function( currentSpec ) {
				var tags=getTagList().cf;
				expect( structKeyExists(tags,"zipparam") ).toBeTrue();
				expect( structKeyExists(tags,"zip") ).toBeTrue();
			});
			it( title='do we have tag data', body=function( currentSpec ) {
				var data=getTagData("cf","zip");
				expect( structKeyExists(data,"name") ).toBeTrue();
			});
			it( title='load zip class', body=function( currentSpec ) {
				// the classes come from the Maven artifact org.lucee:compress of the installed extension
				var maven = [ "org.lucee:compress:" & getInstalledVersion() ];
				// is jakarta environment 
				var className = isInstanceOf(getPageContext().getHTTPServletRequest(),"jakarta.servlet.http.HttpServletRequest")
					? "org.lucee.extension.zip.tag.jakarta.Zip"
					: "org.lucee.extension.zip.tag.javax.Zip";
				var java=createObject("java", className, { maven: maven });
				expect( isObject( java ) ).toBeTrue();
			});
			
		});
	}

	private function getInstalledVersion() {
		var ext = extensionList().filter( function( row ) {
			return row.id == "8D7FB0DF-08BB-1589-FE3975678F07DB17";
		});
		expect( ext.recordCount ).toBe( 1, "compress extension is not installed" );
		return ext.version;
	}
} 