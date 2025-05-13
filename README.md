# Lucee SSE HTTP Client

This project aims to allow consuming SSE (server-sent events) endpoints from Lucee applications. It is currently in
an ALPHA state and being rapidly developed to allow consuming of the OpenAI streaming chat apis.

It is based on the [java-sse-client](https://github.com/LupCode/java-sse-client/) by [LupCode](https://github.com/LupCode)
which has been chosen for its lightweight implementation without any dependencies other than core Java. This is subject
to change should this project develop.

## Get involved

If you're keen on documentation and testing and have more time than I do right now and would like to develop
this further, pull requests + collaboration are very welcome! Get in touch if you'd like to chat it through.


## Minimum documentation

```cfc
// Get a singleton client factory object for creating instances of a http client
sseClientFactory = CreateObject( "lucee-sse-client.models.LuceeSseClientFactory" ).init(); // or getModel( "LuceeSseClientFactory@lucee-sse-client" ) in Coldbox

// Then, everytime you want to fire an SSE http request/connection
// you get an LuceeSseClient object and invoke the start() method
sseClient = sseClientFactory.newClient(
	  url         = "https://example.sseendpoint.com/streaming/api"
	, listenerCfc = new myListenerCfc( someArguments ) // your own listener implementation
);

sseClient.setHttpMethod( "POST" )
         .setBody( SerializeJson( someBody ) )
         .setHeader( "X-API-KEY", apiKey )
         .start();
```

The key here is that you create a listener CFC that follows the ILuceeSseClientListener interface
(see `models/ILuceeSseClientListener.cfc`). You can then listen for new messages as they come
in and act upon them.

Bare bones example of a listener component:

```cfc
component implements="lucee-sse-client.models.ILuceeSseClientListener" {

	public function onEvent( required numeric id, required string event, required string data, required LuceeSseClient sseClient ){
		SystemOutput( "New event [#arguments.event#][#arguments.id#]: #arguments.data#", true );

		if ( arguments.data == "STOP" ) {
			arguments.sseClient.stop();
		}
	}

	public function onError( requried any throwable, required LuceeSseClient sseClient ){
		SystemOutput( "An error happened", true );
	}

	public function onReconnect( requried any response, required boolean hasReceivedEvents, required numeric lastEventID, required LuceeSseClient sseClient ){
		SystemOutput( "Reconnected", true );
	}

	public function onClose( requried any response, required LuceeSseClient sseClient ){
		SystemOutput( "Connection closed", true );
	}
}
```

This documentation needs work! But hopefully this is enough to get you started and using it.

## License

This project is licensed under the GPLv2 License - see the [LICENSE.txt](https://github.com/pixl8/lucee-sse-client/blob/stable/LICENSE.txt) file for details.

## Code of conduct

We are a small, friendly and professional community. For the eradication of doubt, we publish a simple [code of conduct](https://github.com/pixl8/lucee-sse-client/blob/stable/CODE_OF_CONDUCT.md) and expect all contributors, users and passers-by to observe it.

