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
	import org.vostokframework.domain.loading.states.fileloader.IDataLoader;

	import flash.events.NetStatusEvent;
	import flash.net.NetStream;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AutoStopNetStream extends DataLoaderBehavior
	{
		/**
		 * @private
 		 */
		private var _netStream:NetStream;
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function AutoStopNetStream(wrappedDataLoader:IDataLoader, netStream:NetStream)
		{
			super(wrappedDataLoader);
			
			if (!netStream) throw new ArgumentError("Argument <netStream> must not be null.");
			
			_netStream = netStream;
			addNetStreamListener();
		}
		
		override protected function doDispose():void
		{
			removeNetStreamListener();
			_netStream = null;
		}
		
		private function addNetStreamListener():void
		{
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, int.MAX_VALUE, true);
		}
		
		private function netStatusHandler(event:NetStatusEvent):void
		{
			if (event.info["code"] == "NetStream.Play.Start")
			{
				_netStream.pause();
				removeNetStreamListener();
			}
		}
		
		private function removeNetStreamListener():void
		{
			_netStream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false);
		}
		
	}

}