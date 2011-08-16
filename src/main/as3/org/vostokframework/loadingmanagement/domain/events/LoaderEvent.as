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
package org.vostokframework.loadingmanagement.domain.events
{
	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoaderEvent extends Event
	{
		public static const CANCELED:String = "VostokFramework.LoaderEvent.CANCELED";
		public static const COMPLETE:String = "VostokFramework.LoaderEvent.COMPLETE";
		public static const CONNECTING:String = "VostokFramework.LoaderEvent.CONNECTING";
		public static const HTTP_STATUS:String = "VostokFramework.LoaderEvent.HTTP_STATUS";
		public static const INIT:String = "VostokFramework.LoaderEvent.INIT";
		public static const OPEN:String = "VostokFramework.LoaderEvent.OPEN";
		public static const STOPPED:String = "VostokFramework.LoaderEvent.STOPPED";
		
		/**
		 * @private
 		 */
		private var _data:*;
		private var _httpStatus:int;
		private var _latency:int;
		
		public function get data():* { return _data; }
		
		public function get httpStatus():int { return _httpStatus; }
		public function set httpStatus(value:int):void { _httpStatus = value; }
		
		public function get latency():int { return _latency; }
		
		/**
		 * description
		 * 
		 * @param type
		 * @param loadedAssetData
		 */
		public function LoaderEvent(type:String, data:* = null, latency:int = 0)
		{
			super(type, true);
			_data = data;
			_latency = latency;
		}
		
		override public function clone():Event
		{
			var event:LoaderEvent = new LoaderEvent(type, _data, _latency);
			event.httpStatus = httpStatus;
			
			return event;
		}
		
	}

}