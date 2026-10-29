component extends="org.lucee.cfml.test.LuceeTestCase" labels="compress" {

	function beforeAll() {
		variables.dir = getTempDirectory() & "LDEV1566zip/";
		if ( directoryExists( variables.dir ) ) directoryDelete( variables.dir, true );
		directoryCreate( variables.dir );
		fileWrite( variables.dir & "a.txt", "file a" );
		fileWrite( variables.dir & "b.txt", "file b" );
		variables.zipFile = variables.dir & "test.zip";
		cfzip( action="zip", file=variables.zipFile, source=variables.dir, filter="*.txt" );
	}

	function afterAll() {
		if ( directoryExists( variables.dir ) ) directoryDelete( variables.dir, true );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-1566 cfzip action=list returntype", function() {

			it( "default is a query", function() {
				cfzip( action="list", file=variables.zipFile, name="local.res" );
				expect( isQuery( local.res ) ).toBeTrue();
				expect( local.res.recordCount ).toBe( 2 );
			});

			it( "returntype=array returns an array of structs", function() {
				cfzip( action="list", file=variables.zipFile, name="local.res", returntype="array" );
				expect( isArray( local.res ) ).toBeTrue();
				expect( arrayLen( local.res ) ).toBe( 2 );
				expect( local.res[ 1 ] ).toHaveKey( "name" );
			});

			it( "returntype=struct with columnKey returns a struct keyed by that column", function() {
				cfzip( action="list", file=variables.zipFile, name="local.res", returntype="struct", columnKey="name" );
				expect( isStruct( local.res ) ).toBeTrue();
				expect( structCount( local.res ) ).toBe( 2 );
				expect( local.res ).toHaveKey( "a.txt" );
				expect( local.res[ "a.txt" ].name ).toBe( "a.txt" );
			});

			it( "returntype=struct without columnKey and more than one row throws", function() {
				expect( function() {
					cfzip( action="list", file=variables.zipFile, name="local.res", returntype="struct" );
				}).toThrow();
			});

			it( "invalid returntype throws", function() {
				expect( function() {
					cfzip( action="list", file=variables.zipFile, name="local.res", returntype="xml" );
				}).toThrow();
			});
		});
	}
}
