component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "LuceeSseClient", function() {
			it( "should be instantiable with required listener", function() {
				var mockListener = CreateStub( implements="luceessclient.models.ILuceeSseClientListener" );
				mockListener.$( "onEvent" );
				mockListener.$( "onError" );
				mockListener.$( "onReconnect" );
				mockListener.$( "onClose" );

				expect( function() {
					new luceessclient.models.LuceeSseClient( mockListener );
				} ).notToThrow();
			} );

			it( "should have a setJavaClient method", function() {
				var sseClient = _getServiceUnderTest();

				expect( sseClient ).toHaveKey( "setJavaClient" );
			} );

			it( "should have a setHeader method", function() {
				var sseClient = _getServiceUnderTest();

				expect( sseClient ).toHaveKey( "setHeader" );
			} );

			it( "should have a setHeaders method", function() {
				var sseClient = _getServiceUnderTest();

				expect( sseClient ).toHaveKey( "setHeaders" );
			} );

			it( "should have a setHttpMethod method", function() {
				var sseClient = _getServiceUnderTest();

				expect( sseClient ).toHaveKey( "setHttpMethod" );
			} );

			it( "should have a setBody method", function() {
				var sseClient = _getServiceUnderTest();

				expect( sseClient ).toHaveKey( "setBody" );
			} );

			it( "should have a setAutoStopThreshold method", function() {
				var sseClient = _getServiceUnderTest();

				expect( sseClient ).toHaveKey( "setAutoStopThreshold" );
			} );

			it( "should have a start method", function() {
				var sseClient = _getServiceUnderTest();

				expect( sseClient ).toHaveKey( "start" );
			} );

			it( "should have a stop method", function() {
				var sseClient = _getServiceUnderTest();

				expect( sseClient ).toHaveKey( "stop" );
			} );

			it( "should have an isRunning method", function() {
				var sseClient = _getServiceUnderTest();

				expect( sseClient ).toHaveKey( "isRunning" );
			} );

			it( "should have a getResponse method", function() {
				var sseClient = _getServiceUnderTest();

				expect( sseClient ).toHaveKey( "getResponse" );
			} );

			it( "should have listener proxy methods", function() {
				var sseClient = _getServiceUnderTest();

				expect( sseClient ).toHaveKey( "onEvent" );
				expect( sseClient ).toHaveKey( "onError" );
				expect( sseClient ).toHaveKey( "onReconnect" );
				expect( sseClient ).toHaveKey( "onClose" );
			} );
		} );
	}

	private function _getServiceUnderTest() {
		var mockListener = CreateStub( implements="luceessclient.models.ILuceeSseClientListener" );
		mockListener.$( "onEvent" );
		mockListener.$( "onError" );
		mockListener.$( "onReconnect" );
		mockListener.$( "onClose" );

		return new luceessclient.models.LuceeSseClient( mockListener );
	}

}

