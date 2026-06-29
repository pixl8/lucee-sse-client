package org.pixl8.luceesseclient;

import java.io.File;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.InvocationTargetException;
import java.net.http.HttpResponse;
import java.util.HashMap;
import java.util.concurrent.ExecutionException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;

import com.lupcode.HTTP.sse.EventStreamListener;
import com.lupcode.HTTP.sse.HttpEventStreamClient;
import com.lupcode.HTTP.sse.HttpEventStreamClient.Event;

import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.exp.IPageException;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Struct;


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

		args.put( "throwable", throwableToStruct( throwable ) );

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
	private Struct throwableToStruct( Throwable throwable ) {
		Struct error = lucee.getCreationUtil().createStruct();

		if ( throwable == null ) {
			error.put( "message"   , "Unknown SSE client error" );
			error.put( "errorCode" , Double.valueOf( 500 ) );
			error.put( "retryable" , Boolean.FALSE );
			return error;
		}

		Throwable relevant = unwrapThrowable( throwable );

		if ( relevant instanceof IPageException ) {
			IPageException pageException = (IPageException) relevant;

			error.put( "message"   , messageFor( relevant ) );
			error.put( "errorCode" , parseErrorCode( pageException.getErrorCode() ) );
			error.put( "retryable" , Boolean.FALSE );

			try {
				error.put( "detail", pageException.getCatchBlock( getPageContext() ) );
			} catch ( ServletException e ) {
				error.put( "detail", pageExceptionDetail( pageException ) );
			}

			return error;
		}

		error.put( "message"   , messageFor( relevant ) );
		error.put( "errorCode" , Double.valueOf( 500 ) );
		error.put( "detail"    , javaThrowableDetail( relevant ) );
		error.put( "retryable" , isStreamResetError( relevant ) ? Boolean.TRUE : Boolean.FALSE );

		applyStreamResetMessage( error, relevant );

		return error;
	}

	private void applyStreamResetMessage( Struct error, Throwable throwable ) {
		if ( !isStreamResetError( throwable ) ) {
			return;
		}

		error.put( "message"   , "Connection interrupted during long processing. The stream was reset, often due to a proxy idle timeout." );
		error.put( "errorCode" , Double.valueOf( 504 ) );
		error.put( "retryable" , Boolean.TRUE );
	}

	private boolean isStreamResetError( Throwable throwable ) {
		String message = messageFor( throwable );

		if ( message.contains( "RST_STREAM" ) ) {
			return true;
		}

		Throwable cause = throwable.getCause();
		if ( cause != null && cause != throwable ) {
			String causeMessage = cause.getMessage();
			if ( causeMessage != null && causeMessage.contains( "RST_STREAM" ) ) {
				return true;
			}
		}

		return false;
	}

	private Struct pageExceptionDetail( IPageException pageException ) {
		Struct detail = lucee.getCreationUtil().createStruct();

		detail.put( "type"         , pageException.getTypeAsString() );
		detail.put( "detail"       , pageException.getDetail() );
		detail.put( "extendedInfo" , pageException.getExtendedInfo() );
		detail.put( "stackTrace"   , pageException.getStackTraceAsString() );

		return detail;
	}

	private Struct javaThrowableDetail( Throwable throwable ) {
		Struct detail = lucee.getCreationUtil().createStruct();

		detail.put( "type"       , throwable.getClass().getName() );
		detail.put( "stackTrace" , stackTraceToString( throwable ) );

		if ( throwable.getCause() != null && throwable.getCause() != throwable ) {
			detail.put( "cause", throwable.getCause().getMessage() );
		}

		return detail;
	}

	private Throwable unwrapThrowable( Throwable throwable ) {
		Throwable current = throwable;

		while ( current instanceof ExecutionException || current instanceof InvocationTargetException ) {
			if ( current.getCause() == null || current.getCause() == current ) {
				break;
			}

			current = current.getCause();
		}

		return current;
	}

	private String messageFor( Throwable throwable ) {
		String message = throwable.getMessage();

		if ( message == null || message.isEmpty() ) {
			return throwable.getClass().getSimpleName();
		}

		return message;
	}

	private Double parseErrorCode( String errorCode ) {
		if ( errorCode == null || errorCode.isEmpty() ) {
			return Double.valueOf( 500 );
		}

		try {
			return Double.valueOf( Integer.parseInt( errorCode.trim() ) );
		} catch ( NumberFormatException e ) {
			return Double.valueOf( 500 );
		}
	}

	private String stackTraceToString( Throwable throwable ) {
		StringWriter writer = new StringWriter();
		PrintWriter  print  = new PrintWriter( writer );

		throwable.printStackTrace( print );

		return writer.toString();
	}

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
