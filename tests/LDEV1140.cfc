component extends="org.lucee.cfml.test.LuceeTestCase" labels="compress" {

	function beforeAll() {
		variables.fixtures = getDirectoryFromPath( getCurrentTemplatePath() ) & "LDEV1140/";
		variables.dir = getTempDirectory() & "ldev1140-" & createUUID() & "/";
		directoryCreate( dir );
	}

	function afterAll() {
		if ( directoryExists( dir ) ) directoryDelete( dir, true );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-1140 unzip entry names", function() {

			it( "extracts a nested folder structure identically with extract() and cfzip", function() {
				var src = fixtures & "nested-utf8.zip";
				var outExtract = dir & "nested-extract/";
				var outZip = dir & "nested-cfzip/";
				directoryCreate( outExtract );
				directoryCreate( outZip );

				extract( "zip", src, outExtract );
				zip action="unzip" file=src destination=outZip;

				expect( fileRead( outExtract & "photos/2024/a.txt" ) ).toBe( "hello nested" );
				expect( fileRead( outZip & "photos/2024/a.txt" ) ).toBe( "hello nested" );

				var srcTar = fixtures & "nested.tar";
				var outTar = dir & "nested-tar/";
				directoryCreate( outTar );
				extract( "tar", srcTar, outTar );
				expect( fileRead( outTar & "photos/2024/a.txt" ) ).toBe( "hello nested" );
			});

			it( "extracts a zip whose entry names are not UTF-8 with extract()", function() {
				var out = dir & "cp437-extract/";
				directoryCreate( out );
				extract( "zip", fixtures & "cp437-kase.zip", out );
				expect( fileExists( out & "käse.txt" ) ).toBeTrue();
				expect( fileRead( out & "käse.txt" ) ).toBe( "LDEV-1140" );
			});

			it( "extracts a zip whose entry names are not UTF-8 with cfzip action=unzip", function() {
				var out = dir & "cp437-cfzip/";
				directoryCreate( out );
				zip action="unzip" file=fixtures & "cp437-kase.zip" destination=out;
				expect( fileExists( out & "käse.txt" ) ).toBeTrue();
				expect( fileRead( out & "käse.txt" ) ).toBe( "LDEV-1140" );
			});

			it( "extracts a nested non-UTF-8 entry name", function() {
				var out = dir & "cp437-nested/";
				directoryCreate( out );
				extract( "zip", fixtures & "cp437-nested.zip", out );
				expect( fileRead( out & "photos/2024/käse.txt" ) ).toBe( "LDEV-1140" );

				var out2 = dir & "cp437-nested-cfzip/";
				directoryCreate( out2 );
				zip action="unzip" file=fixtures & "cp437-nested.zip" destination=out2;
				expect( fileRead( out2 & "photos/2024/käse.txt" ) ).toBe( "LDEV-1140" );
			});

			it( "rejects an entry name that resolves outside the target directory", function() {
				assertRejected( "zip", fixtures & "outside-parent.zip", "parent", "outside.txt" );
				assertRejected( "tar", fixtures & "outside-parent.tar", "parent-tar", "outside.txt" );
			});

			it( "rejects an absolute entry name", function() {
				assertRejected( "zip", fixtures & "outside-abs.zip", "abs", "abs.txt" );
				assertRejected( "tar", fixtures & "outside-abs.tar", "abs-tar", "abs.txt" );
			});

			it( "rejects an entry name that would resolve to a sibling of the target directory", function() {
				assertRejectedSibling( "zip", fixtures & "outside-sibling.zip", "sib" );
				assertRejectedSibling( "tar", fixtures & "outside-sibling.tar", "sib-tar" );
			});

		});
	}

	private void function assertRejected( required string format, required string archive, required string label, required string outsideName ) {
		doReject( format, archive, label, outsideName, format != "zip" );
		if ( format == "zip" ) doReject( format, archive, label & "-extract", outsideName, true );
	}

	private void function doReject( required string format, required string archive, required string label, required string outsideName, required boolean useExtract ) {
		var work = dir & label & "/";
		var dest = work & "dest/";
		directoryCreate( dest );
		var failed = false;
		try {
			if ( useExtract ) {
				extract( format, archive, dest );
			}
			else {
				zip action="unzip" file=archive destination=dest;
			}
		}
		catch ( any e ) {
			failed = true;
			expect( e.message contains "outside the target directory" || e.detail contains "outside the target directory" || e.message contains "archive entry" )
				.toBeTrue( "unexpected error for #label#: #e.message# #e.detail#" );
		}
		expect( failed ).toBeTrue( "#label# should reject the entry name" );
		expect( fileExists( work & outsideName ) ).toBeFalse();
	}

	private void function assertRejectedSibling( required string format, required string archive, required string label ) {
		doRejectSibling( format, archive, label, format != "zip" );
		if ( format == "zip" ) doRejectSibling( format, archive, label & "-extract", true );
	}

	private void function doRejectSibling( required string format, required string archive, required string label, required boolean useExtract ) {
		var work = dir & label & "/";
		var dest = work & "target/";
		var sibling = work & "target2/";
		directoryCreate( dest );
		directoryCreate( sibling );
		var failed = false;
		try {
			if ( useExtract ) {
				extract( format, archive, dest );
			}
			else {
				zip action="unzip" file=archive destination=dest;
			}
		}
		catch ( any e ) {
			failed = true;
			expect( e.message contains "outside the target directory" || e.detail contains "outside the target directory" || e.message contains "archive entry" )
				.toBeTrue( "unexpected error for #label#: #e.message# #e.detail#" );
		}
		expect( failed ).toBeTrue( "#label# should reject the sibling entry name" );
		expect( fileExists( sibling & "x.txt" ) ).toBeFalse();
		expect( directoryList( sibling, true ).len() ).toBe( 0 );
	}

}
