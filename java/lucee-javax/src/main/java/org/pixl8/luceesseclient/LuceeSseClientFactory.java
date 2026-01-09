package org.pixl8.luceesseclient;

import com.lupcode.HTTP.sse.HttpEventStreamClient;
import lucee.runtime.Component;

public class LuceeSseClientFactory {

	public static HttpEventStreamClient getClient( String url, Component listener, String contextRoot ) {
		return new HttpEventStreamClient( url, new LuceeSseListener( listener, contextRoot ) );
	}

}