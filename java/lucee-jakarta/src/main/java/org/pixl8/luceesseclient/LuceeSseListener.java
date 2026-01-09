package org.pixl8.luceesseclient;

import java.io.File;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import java.net.http.HttpResponse;
import java.util.HashMap;

import com.lupcode.HTTP.sse.EventStreamListener;
import com.lupcode.HTTP.sse.HttpEventStreamClient;
import com.lupcode.HTTP.sse.HttpEventStreamClient.Event;

import lucee.loader.engine.*;
import lucee.runtime.Component;
import lucee.runtime.type.Struct;
import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;


public class LuceeSseListener implements EventStreamListener {

	private CFMLEngine lucee;
	private Component  listenerCfc;
	private File       contextRoot;


	public LuceeSseListener( Component cfcListener, String contextRoot ) {
		this.lucee       = CFMLEngineFactory.getInstance();
		this.listenerCfc = cfcListener;
		this.contextRoot = new File( contextRoot );
	}

	public void onEvent(HttpEventStreamClient client, Event event) {
		Struct args = lucee.getCreationUtil().createStruct();

		args.put( "id"   , event.getID()    );
		args.put( "event", event.getEvent() );
		args.put( "data" , event.getData()  );


		callListenerCfc( "onEvent", args );
	}

	public void onError(HttpEventStreamClient client, Throwable throwable) {
		Struct args = lucee.getCreationUtil().createStruct();

		args.put( "e", throwable  );

		callListenerCfc( "onError", args );
	}

	public void onReconnect(HttpEventStreamClient client, HttpResponse<Void> response, boolean hasReceivedEvents, long lastEventID) {
		Struct args = lucee.getCreationUtil().createStruct();
		args.put( "response"         , response          );
		args.put( "hasReceivedEvents", hasReceivedEvents );
		args.put( "lastEventID"      , lastEventID       );

		callListenerCfc( "onReconnect", args );
	}

	public void onClose(HttpEventStreamClient client, HttpResponse<Void> response) {
		Struct args = lucee.getCreationUtil().createStruct();

		args.put( "response", response  );

		callListenerCfc( "onClose", args );
	}

// PRIVATE UTILITY
	private void callListenerCfc( String method, Struct args ) {
		try {
			listenerCfc.callWithNamedValues( getPageContext(), method, args );
		} catch ( PageException e ) {
			e.printStackTrace( System.out );
		} catch( ServletException e ) {
			e.printStackTrace( System.out );
		}
	}

	private PageContext getPageContext() throws ServletException {
		PageContext pc = lucee.getThreadPageContext();

		if ( pc != null ) {
			return pc;
		}

		jakarta.servlet.http.Cookie[] cookies = new Cookie[]{};

		pc = lucee.createPageContext(
			  contextRoot
			, "localhost"    // host
			, "/"            // script name
			, ""             // query string
			, cookies		 // cookies
			, null           // headers
			, new HashMap()  // parameters
			, new HashMap()  // attributes
			, System.out     // response stream where the output is written to
			, 50000          // timeout for the simulated request in milli seconds
			, true           // register the pc to the thread
		);

		return pc;
	}


}
