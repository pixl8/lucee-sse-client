/**
 * @singleton false
 */
component {

// CONSTRUCTOR & SETUP
	public any function init( required ILuceeSseClientListener cfcListener ) {
		variables._javaClient  = NullValue();
		variables._response    = {};
		variables._events      = [];
		variables._cfcListener = arguments.cfcListener;

		return this;
	}

	public function setJavaClient( required any javaClient ) {
		variables._javaClient = arguments.javaClient;
	}

// LISTENER PROXIES
	public function onEvent( id, event, data ) {
		ArrayAppend( variables._events, StructCopy( arguments ) );
		variables._cfcListener.onEvent( argumentCollection=arguments, sseClient=this );
	}
	public function onError( throwable ) {
		variables._error = arguments.throwable;
		variables._cfcListener.onError( argumentCollection=arguments, sseClient=this );
	}
	public function onReconnect( response, hasReceivedEvents, lastEventID ) {
		variables._cfcListener.onReconnect( argumentCollection=arguments, sseClient=this );
	}
	public function onClose( response ) {
		variables._response = _parseJavaResponse( arguments.response );
		variables._cfcListener.onClose( argumentCollection=arguments, sseClient=this );
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

	public function getResponse() {
		return variables._response;
	}

// PRIVATE HELPERS
	private function _parseJavaResponse( response ){
		var resp = {
			  statusCode = arguments.response.statusCode()
			, body       = arguments.response.body()
			, uri        = arguments.response.uri().toString()
			, events     = variables._events
			, headers    = {}
		};
		var headerMap = arguments.response.headers().map();
		for( var key in headerMap ) {
			if ( IsArray( headerMap[ key ] ) && ArrayLen( headerMap[ key ]) == 1 ) {
				resp.headers[ key ] = headerMap[ key ][ 1 ];
			} else {
				resp.headers[ key ] = headerMap[ key ];
			}
		}

		if ( StructKeyExists( variables, "_error" ) ) {
			resp.error = variables._error;
		}

		return resp;
	}

}