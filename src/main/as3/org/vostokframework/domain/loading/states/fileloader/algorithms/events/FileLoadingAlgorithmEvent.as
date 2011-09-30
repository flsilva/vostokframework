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
package org.vostokframework.domain.loading.states.fileloader.algorithms.events
{
	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class FileLoadingAlgorithmEvent extends Event
	{
		public static const COMPLETE:String = "VostokFramework.FileLoadingAlgorithmEvent.COMPLETE";
		public static const HTTP_STATUS:String = "VostokFramework.FileLoadingAlgorithmEvent.HTTP_STATUS";
		public static const INIT:String = "VostokFramework.FileLoadingAlgorithmEvent.INIT";
		public static const OPEN:String = "VostokFramework.FileLoadingAlgorithmEvent.OPEN";
		
		/**
		 * description
		 */
		private var _data:*;
		private var _httpStatus:int;
		private var _latency:int;
		private var _netStatusInfo:Object;
		
		/**
		 * description
		 */
		public function get data(): * { return _data; }
		
		public function get httpStatus(): int { return _httpStatus; }
		public function set httpStatus(value:int): void { _httpStatus = value; }
		
		public function get latency(): int { return _latency; }
		
		public function get netStatusInfo(): Object { return _netStatusInfo; }
		public function set netStatusInfo(value:Object): void { _netStatusInfo = value; }

		/**
		 * description
		 * 
		 * @param assetId
		 * @param assetType
		 * @param monitoring
		 * @param assetData
		 */
		public function FileLoadingAlgorithmEvent(type:String, data:* = null, latency:int = 0)
		{
			super(type);
			
			_data = data;
			_latency = latency;
		}
		
		override public function clone():Event
		{
			var event:FileLoadingAlgorithmEvent = new FileLoadingAlgorithmEvent(type, _data, _latency);
			event.httpStatus = _httpStatus;
			event.netStatusInfo = _netStatusInfo;
			
			return event;
		}
		/*
		public static function typeBelongs(type:String):Boolean
		{
			return type == COMPLETE ||
			       type == HTTP_STATUS || 
			       type == INIT ||
			       type == OPEN;
		}
		*/
	}

}