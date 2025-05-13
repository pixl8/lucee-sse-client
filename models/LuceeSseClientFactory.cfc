/**
 * @singleton true
 */
component {

// CONSTRUCTOR
	public any function init() {
		_registerOsgiBundle();

		return this;
	}

// PUBLIC API METHODS
	public function newClient( required string url, required ILuceeSseClientListener listenerCfc ) {
		var luceeClient = new LuceeSseClient( listenerCfc );
		var javaClient  = CreateObject( "java", "org.pixl8.luceesseclient.LuceeSseClientFactory", "org.pixl8.luceesseclient", "1.0.0" ).getClient( arguments.url, luceeClient, ExpandPath( "/" ) );

		javaClient.setAutoStopThreshold( 0 ); // default to finishing when the connection is closed rather than reconnecting

		luceeClient.setJavaClient( javaClient );

		return luceeClient;
	}

// PRIVATE HELPERS
	private function _registerOsgiBundle() {
		var cfmlEngine = CreateObject( "java", "lucee.loader.engine.CFMLEngineFactory" ).getInstance();
		var osgiUtil   = CreateObject( "java", "lucee.runtime.osgi.OSGiUtil" );
		var lib        = GetDirectoryFromPath( GetCurrentTemplatePath() ) & "../lib/luceesseclient-1.0.0.jar";
		var resource   = cfmlEngine.getResourceUtil().toResourceExisting( getPageContext(), lib );

		osgiUtil.installBundle( cfmlEngine.getBundleContext(), resource, true );
	}

}