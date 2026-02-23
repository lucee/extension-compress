component extends="org.lucee.cfml.test.LuceeTestCase" labels="compressX"{
	private function dumpLogs(dir) {
	loop array=directoryList(dir) item="local.filename" {
		if (findNoCase(".log", filename)) {
			systemOutput("--- #filename# ---",1,1);
			systemOutput(fileRead(filename),1,1);
		}
	}
	}

	 
	function afterAll(){
		var pc=getPageContext();
		var c=pc.getConfig();
		
		dumpLogs(c.getConfigServerDir().getRealResource("logs/"));
		dumpLogs(c.getConfigDir().getRealResource("logs/"));
	}

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