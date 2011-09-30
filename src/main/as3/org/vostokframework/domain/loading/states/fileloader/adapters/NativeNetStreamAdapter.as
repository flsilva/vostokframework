/*
 * Licensed under the MIT License
 * 
 * Copyright 2011 (c) Flávio Silva, flsilva.com
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.vostokframework.domain.loading.states.fileloader.adapters
{
	import org.vostokframework.domain.loading.states.fileloader.algorithms.events.FileLoadingAlgorithmMediaEvent;

	import flash.events.IEventDispatcher;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class NativeNetStreamAdapter extends DataLoaderAdapter
	{
		/**
		 * @private
 		 */
		private var _clientCallback:Object;
		private var _netStream:NetStream;
		private var _netConnection:NetConnection;
		private var _request:URLRequest;
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function NativeNetStreamAdapter(netStream:NetStream, netConnection:NetConnection, request:URLRequest)
		{
			if (!netStream) throw new ArgumentError("Argument <netStream> must not be null.");
			if (!netConnection) throw new ArgumentError("Argument <netConnection> must not be null.");
			if (!request) throw new ArgumentError("Argument <request> must not be null.");
			
			_netStream = netStream;
			_netConnection = netConnection;
			_request = request;
			
			_clientCallback = { };
			_clientCallback["onMetaData"] = metaDataHandler;
			_clientCallback["onCuePoint"] = cuePointHandler;
			
			_netStream.client = _clientCallback;
		}
		
		override protected function doCancel(): void
		{
			close();
		}
		
		override protected function doDispose():void
		{
			close();
			
			_netStream = null;
			_request = null;
		}
		
		override protected function doGetData():*
		{
			return _netStream;
		}
		
		/**
		 * description
		 */
		override protected function doLoad(): void
		{
			_netStream.play(_request.url);
		}
		
		/**
		 * description
		 */
		override protected function doStop():void
		{
			close();
		}
		
		override protected function getLoadingDispatcher():IEventDispatcher
		{
			return _netStream;
		}
		
		private function close():void
		{
			try
			{
				_netStream.pause();
				_netStream.close();
			}
			catch (error:Error)
			{
				//do nothing
			}
		}
		
		private function metaDataHandler(info:Object):void
		{
			var event:FileLoadingAlgorithmMediaEvent = new FileLoadingAlgorithmMediaEvent(FileLoadingAlgorithmMediaEvent.META_DATA);
			event.metadata = info;
			dispatchEvent(event);
		}
		
		private function cuePointHandler(info:Object):void
		{
			var event:FileLoadingAlgorithmMediaEvent = new FileLoadingAlgorithmMediaEvent(FileLoadingAlgorithmMediaEvent.CUE_POINT);
			event.cuePointData = info;
			dispatchEvent(event);
		}

	}

}