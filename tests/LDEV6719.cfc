component extends="org.lucee.cfml.test.LuceeTestCase" labels="compress" {

	function beforeAll() {
		variables.base = getTempDirectory() & "ldev6719-" & createUUID() & "/";
		directoryCreate( variables.base );
		variables.srcDir = variables.base & "src/";
		directoryCreate( variables.srcDir & "sub/deeper", true );
		fileWrite( variables.srcDir & "root.txt", "root file " & repeatString( "Susi Sorglos foehnte Ihr Haar. ", 200 ) );
		fileWrite( variables.srcDir & "sub/nested.txt", "nested file" );
		fileWrite( variables.srcDir & "sub/deeper/deep.txt", "deep file" );
		// binary content, so the round trip has to be byte exact
		var bytes = [];
		loop from=0 to=255 index="local.i" {
			arrayAppend( bytes, i > 127 ? i - 256 : i );
		}
		fileWrite( variables.srcDir & "sub/binary.bin", javaCast( "byte[]", bytes ) );
	}

	function afterAll() {
		if ( directoryExists( variables.base ) ) directoryDelete( variables.base, true );
	}

	function run( testResults, testBox ) {
		describe( title="LDEV-6719 compress extension with Maven based dependencies", body=function() {

			loop list="zip,tar,tgz,tbz" item="local.fmt" {
				it( title="compress() and extract() round trip with format [#fmt#]", data={ format: fmt }, body=function( data ) {
					var archive = variables.base & "roundtrip." & data.format;
					var target = variables.base & "extract-" & data.format & "/";
					directoryCreate( target );
					compress( format=data.format, source=variables.srcDir, target=archive, includeBaseFolder=false );
					expect( fileExists( archive ) ).toBeTrue();
					expect( getFileInfo( archive ).size ).toBeGT( 0 );
					extract( data.format, archive, target );
					assertSameTree( variables.srcDir, target );
				});
			}

			it( title="cfzip creates and extracts a zip", body=function() {
				var archive = variables.base & "tag.zip";
				var target = variables.base & "extract-tag/";
				zip action="zip" file=archive source=variables.srcDir recurse=true;
				zip action="list" file=archive name="local.entries";
				expect( entries.recordCount ).toBeGTE( 4 );
				zip action="unzip" file=archive destination=target;
				assertSameTree( variables.srcDir, target );
			});

			it( title="read tar and tgz archives through the tar:// and tgz:// resources", body=function() {
				loop list="tar,tgz" item="local.scheme" {
					var archive = variables.base & "resource." & scheme;
					compress( format=scheme, source=variables.srcDir, target=archive, includeBaseFolder=false );
					expect( fileRead( scheme & "://" & archive & "!/sub/nested.txt" ) ).toBe( "nested file" );
					expect( fileRead( scheme & "://" & archive & "!/sub/deeper/deep.txt" ) ).toBe( "deep file" );
				}
			});

			// commons-compress 1.26 needs commons-io 2.12 or newer (org.apache.commons.io.build),
			// the extension has to bring that itself instead of relying on the commons-io of the core
			it( title="the extension classloader has commons-io 2.12 or newer for commons-compress", body=function() {
				var cl = getProviderClass( "tar" ).getClassLoader();
				expect( cl.loadClass( "org.apache.commons.io.build.AbstractOrigin" ).getName() )
					.toBe( "org.apache.commons.io.build.AbstractOrigin" );

				// ZipFile.builder() is built on org.apache.commons.io.build.AbstractStreamBuilder
				var archive = variables.base & "builder.zip";
				compress( format="zip", source=variables.srcDir, target=archive, includeBaseFolder=false );
				var zipFileClass = cl.loadClass( "org.apache.commons.compress.archivers.zip.ZipFile" );
				var builder = zipFileClass.getMethod( "builder", javaCast( "java.lang.Class[]", [] ) )
					.invoke( javaCast( "null", "" ), javaCast( "java.lang.Object[]", [] ) );
				builder.setFile( createObject( "java", "java.io.File" ).init( archive ) );
				var zipFile = builder.get();
				try {
					var names = [];
					var entries = zipFile.getEntries();
					while ( entries.hasMoreElements() ) {
						arrayAppend( names, replace( entries.nextElement().getName(), "\", "/", "all" ) );
					}
					expect( names ).toInclude( "root.txt" );
					expect( names ).toInclude( "sub/deeper/deep.txt" );
				}
				finally {
					zipFile.close();
				}
			});
		});
	}

	private function assertSameTree( required string expectedDir, required string actualDir ) {
		var expected = directoryList( arguments.expectedDir, true, "path", "", "", "file" );
		var actual = directoryList( arguments.actualDir, true, "path", "", "", "file" );
		expect( arrayLen( actual ) ).toBe( arrayLen( expected ), "number of files in [#arguments.actualDir#]" );
		loop array=expected item="local.file" {
			var rel = mid( file, len( arguments.expectedDir ) + 1 );
			var other = arguments.actualDir & rel;
			expect( fileExists( other ) ).toBeTrue( "[#rel#] is missing in [#arguments.actualDir#]" );
			expect( hash( fileReadBinary( other ), "SHA-256" ) ).toBe( hash( fileReadBinary( file ), "SHA-256" ), "content of [#rel#]" );
		}
	}

	private function getProviderClass( required string scheme ) {
		loop array=getPageContext().getConfig().getResourceProviders() item="local.provider" {
			if ( provider.getScheme() == arguments.scheme ) return provider.getClass();
		}
		throw( message="resource provider [#arguments.scheme#] not found" );
	}
}
