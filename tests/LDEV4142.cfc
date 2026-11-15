component extends="org.lucee.cfml.test.LuceeTestCase" labels="compress" {

	function beforeAll() {
		variables.dir = getTempDirectory() & "ldev4142-" & createUUID() & "/";
		directoryCreate( dir & "src" );
		fileWrite( dir & "src/a.txt", "hello" );
		fileWrite( dir & "b.txt", "plain" );
	}

	function afterAll() {
		if ( directoryExists( dir ) ) directoryDelete( dir, true );
	}

	private struct function encryptedEntries( required string zipFile ) {
		zip action="list" file=arguments.zipFile name="local.entries";
		var result = {};
		loop query=entries {
			result[ entries.name ] = entries.encrypted;
		}
		return result;
	}

	function run( testResults, testBox ) {
		describe( "LDEV-4142 cfzipparam password / encryptionalgorithm", function() {

			it( "cfzip password + encryptionalgorithm (works already)", function() {
				var f = dir & "zip1.zip";
				zip action="zip" file=f source=dir & "src" password="LDEV4142" encryptionalgorithm="aes128";
				expect( encryptedEntries( f )[ "a.txt" ] ).toBeTrue();
			});

			it( "cfzipparam source + password + encryptionalgorithm", function() {
				var f = dir & "zip2.zip";
				zip action="zip" file=f {
					zipparam source=dir & "src" password="LDEV4142" encryptionalgorithm="aes128";
				}
				expect( encryptedEntries( f )[ "a.txt" ] ).toBeTrue();
			});

			it( "cfzipparam source + entrypath + password + encryptionalgorithm", function() {
				var f = dir & "zip3.zip";
				zip action="zip" file=f {
					zipparam source=dir & "src/a.txt" entrypath="newdir/a.txt" password="LDEV4142" encryptionalgorithm="aes128";
				}
				expect( encryptedEntries( f )[ "newdir/a.txt" ] ).toBeTrue();
			});

			it( "cfzipparam content + password", function() {
				var f = dir & "zip4.zip";
				zip action="zip" file=f {
					zipparam content="secret" entrypath="c.txt" password="LDEV4142";
				}
				expect( encryptedEntries( f )[ "c.txt" ] ).toBeTrue();
			});

			it( "password only applies to the entries of its cfzipparam, extract works with it", function() {
				var f = dir & "zip5.zip";
				zip action="zip" file=f {
					zipparam source=dir & "src/a.txt" password="LDEV4142" encryptionalgorithm="aes256";
					zipparam source=dir & "b.txt";
				}
				var enc = encryptedEntries( f );
				expect( enc[ "a.txt" ] ).toBeTrue();
				expect( enc[ "b.txt" ] ).toBeFalse();

				var out = dir & "out5/";
				zip action="unzip" file=f destination=out password="LDEV4142";
				expect( fileRead( out & "a.txt" ) ).toBe( "hello" );
				expect( fileRead( out & "b.txt" ) ).toBe( "plain" );
			});
		});
	}
}
