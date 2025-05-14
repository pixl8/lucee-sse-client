/**
 * @singleton false
 */
component {

// CONSTRUCTOR & SETUP
	public any function init( required ILuceeSseClientListener cfcListener ) {
		variables._javaClient = NullValue();
		variables.cfcListener = arguments.cfcListener;

		return this;
	}

	public function setJavaClient( required any javaClient ) {
		variables._javaClient = arguments.javaClient;
	}

// LISTENER PROXIES
	public function onEvent( id, event, data ) {
		variables.cfcListener.onEvent( argumentCollection=arguments, sseClient=this );
	}
	public function onError( throwable ) {
		variables.cfcListener.onError( argumentCollection=arguments, sseClient=this );
	}
	public function onReconnect( response, hasReceivedEvents, lastEventID ) {
		variables.cfcListener.onReconnect( argumentCollection=arguments, sseClient=this );
	}
	public function onClose( response ) {
		variables.cfcListener.onClose( argumentCollection=arguments, sseClient=this );
	}

// REQUEST PREPARATION
	public function setHeader( required string name, required string value ) {
		variables._javaClient.setHeader( arguments.name, arguments.value );

		return this;
	}
	public function setHeaders( required struct headers ) {
		for( var key in arguments.headers ) {
			setHeader( key, arguments.headers[ key ] );
		}
		return this;
	}

	public function setHttpMethod( required string method ) {
		var methodEnum = variables._javaClient.getHttpMethod();
		variables._javaClient.setHttpMethod( methodEnum[ arguments.method ] );

		return this;
	}

	public function setBody( required string body ) {
		variables._javaClient.setHttpRequestBody( CreateObject( "java", "java.net.http.HttpRequest$BodyPublishers" ).ofString( body ) );

		return this;
	}

	/**
	 * Sets how often the client can reconnect without receiving events in between
	 * before it automatically stops.
	 * If zero then client will not reconnect after a connection loss.
	 * If negative then client will keep reconnecting for ever.
	 */
	public function setAutoStopThreshold( required numeric maxReconnectsWithoutEvents ) {
		variables._javaClient.setAutoStopThreshold( JavaCast( "int", arguments.maxReconnectsWithoutEvents ) );

		return this;
	}

// REQUEST CONTROL
	public function start( boolean wait=true ) {
		variables._javaClient.start();
		if ( arguments.wait ) {
			while( isRunning() ) {
				sleep( 5 );
			}
		}
		return this;
	}
	public function stop() {
		variables._javaClient.stop();
		variables._javaClient.removeAllListeners();
		return this;
	}
	public function isRunning() {
		return variables._javaClient.isRunning();
	}

}