component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "LuceeSseClientFactory", function() {
			it( "should be instantiable", function() {
				new luceessclient.models.LuceeSseClientFactory();
				expect( function() {
					new luceessclient.models.LuceeSseClientFactory();
				} ).notToThrow();
			} );

			it( "should register OSGi bundle on initialization", function() {
				var factory = new luceessclient.models.LuceeSseClientFactory();

				// If _registerOsgiBundle() worked, we should be able to create the Java object
				expect( function() {
					CreateObject( "java", "org.pixl8.luceesseclient.LuceeSseClientFactory", "org.pixl8.luceesseclient", "1.0.0" );
				} ).notToThrow();
			} );

			it( "should have a newClient method", function() {
				var factory = new luceessclient.models.LuceeSseClientFactory();

				expect( factory ).toHaveKey( "newClient" );
			} );
		} );
	}

}

