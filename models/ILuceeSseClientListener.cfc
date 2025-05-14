interface {

	public function onEvent( string id, string event, string data, LuceeSseClient sseClient );
	public function onError( any throwable, LuceeSseClient sseClient );
	public function onReconnect( any response, boolean hasReceivedEvents, string lastEventID, LuceeSseClient sseClient );
	public function onClose( any response, LuceeSseClient sseClient );

}