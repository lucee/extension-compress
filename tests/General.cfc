component extends="org.lucee.cfml.test.LuceeTestCase" labels="compress"{
	
	function run( testResults , testBox ) {
		describe( "Test suitegenarry looks if the enviroment is loaded", function() {
			it( title='are the tags listed', body=function( currentSpec ) {
				var tags=getTagList().cf;
				expect( structKeyExists(tags,"zip") ).toBeTrue();
				expect( structKeyExists(tags,"zipparam") ).toBeTrue();
			});
			it( title='do we have tag data', body=function( currentSpec ) {
				var data=getTagData("cf","zip");
				expect( structKeyExists(data,"name") ).toBeTrue();
			});
			it( title='load zip class', body=function( currentSpec ) {
				// is jakarta environment 
				if( isInstanceOf(getPageContext().getHTTPServletRequest(),"jakarta.servlet.http.HttpServletRequest") ) {
					java=createObject("java", "org.lucee.extension.zip.tag.jakarta.Zip","org.lucee.compress.extension");
				}
				else {
					java=createObject("java", "org.lucee.extension.zip.tag.javax.Zip","org.lucee.compress.extension");
				}
				
			});

			
		});
	}


} 