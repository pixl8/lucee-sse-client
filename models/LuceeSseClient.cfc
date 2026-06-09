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
		variables._finished    = false;

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
		try {
			variables._response = _parseJavaResponse( argumentCollection=arguments );
			variables._cfcListener.onClose( argumentCollection=arguments, sseClient=this );
		} catch( any e ) {
			// This runs on a background java thread whose exceptions are swallowed by the
			// listener bridge. Never let a parsing/listener error leave the waiting start()
			// loop hanging - capture what we can and always flag completion below.
			variables._response = {
				  statusCode = 0
				, body       = variables._javaClient.getRawResponse()
				, uri        = ""
				, events     = variables._events
				, headers    = {}
				, error      = e
			};
		} finally {
			variables._finished = true;
		}
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
			// Block until the underlying request is no longer running. This always
			// terminates once the request completes.
			while( isRunning() ) {
				sleep( 5 );
			}

			// isRunning() flips to false _before_ onClose() has parsed and stored the
			// response, so give the close handler a brief, bounded window to finish to
			// avoid getResponse() racing back an empty struct. Bounded so a close handler
			// that never completes can never hang the caller indefinitely.
			var graceMs = 0;
			while( !variables._finished && graceMs < 2000 ) {
				sleep( 5 );
				graceMs += 5;
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
		// When the request completes exceptionally (e.g. a connection reset on an error
		// response) there is no java HttpResponse object. Return what we do have rather
		// than throwing an NPE that would be swallowed and leave an empty response.
		if ( IsNull( arguments.response ) ) {
			var errResp = {
				  statusCode = 0
				, body       = variables._javaClient.getRawResponse()
				, uri        = ""
				, events     = variables._events
				, headers    = {}
			};

			if ( StructKeyExists( variables, "_error" ) ) {
				errResp.error = variables._error;
			}

			return errResp;
		}

		// The runtime type of the response is jdk.internal.net.http.HttpResponseImpl,
		// which lucee cannot reflect on under JPMS (the java.net.http module does not
		// open its internal package). Invoke the methods via the public HttpResponse
		// interface instead so no module needs to be opened. The body is always read
		// from the raw response because this client uses a Void body handler.
		var resp = {
			  statusCode = _httpResponseValue( arguments.response, "statusCode" )
			, uri        = _httpResponseValue( arguments.response, "uri" ).toString()
			, events     = variables._events
			, headers    = {}
			, body       = variables._javaClient.getRawResponse()
		};

		var headerMap = _httpResponseValue( arguments.response, "headers" ).map();
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

	private function _httpResponseValue( required any response, required string methodName ) {
		var httpResponseClass = CreateObject( "java", "java.lang.Class" ).forName( "java.net.http.HttpResponse" );

		for( var method in httpResponseClass.getMethods() ) {
			if ( method.getName() == arguments.methodName && ArrayLen( method.getParameterTypes() ) == 0 ) {
				// Second arg is the (empty) varargs array for Method.invoke( obj, args... );
				// lucee will not match the varargs signature without it.
				return method.invoke( arguments.response, [] );
			}
		}

		throw( type="luceeSseClient.reflection", message="No zero-arg method [#arguments.methodName#] found on java.net.http.HttpResponse" );
	}

}