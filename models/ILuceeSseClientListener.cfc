interface {

	public function onEvent( required numeric id, required string event, required string data, required LuceeSseClient sseClient );
	public function onError( requried any throwable, required LuceeSseClient sseClient );
	public function onReconnect( requried any response, required boolean hasReceivedEvents, required numeric lastEventID, required LuceeSseClient sseClient );
	public function onClose( requried any response, required LuceeSseClient sseClient );

}