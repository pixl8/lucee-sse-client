component {
	this.name = "lucee-sse-client Test Suite";

	this.mappings[ '/tests'            ] = ExpandPath( "/" );
	this.mappings[ '/testbox'          ] = ExpandPath( "/testbox" );
	this.mappings[ '/luceessclient' ] = ExpandPath( "../" );

	setting requesttimeout=60000;
}

