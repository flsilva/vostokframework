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
package org.vostokframework.domain.loading.states.fileloader
{
	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class FileLoadingAlgorithmMediaEvent extends Event
	{
		public static const BUFFER_COMPLETE:String = "VostokFramework.FileLoadingAlgorithmMediaEvent.BUFFER_COMPLETE";
		public static const CUE_POINT:String = "VostokFramework.FileLoadingAlgorithmMediaEvent.CUE_POINT";
		public static const META_DATA:String = "VostokFramework.FileLoadingAlgorithmMediaEvent.META_DATA";
		public static const NET_STATUS:String = "VostokFramework.FileLoadingAlgorithmMediaEvent.NET_STATUS";
		
		/**
		 * description
		 */
		private var _cuePointData:Object;
		private var _metadata:Object;
		private var _netStatusInfo:Object;
		
		public function get cuePointData(): Object { return _cuePointData; }
		public function set cuePointData(value:Object): void { _cuePointData = value; }
		
		public function get metadata(): Object { return _metadata; }
		public function set metadata(value:Object): void { _metadata = value; }
		
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
		public function FileLoadingAlgorithmMediaEvent(type:String)
		{
			super(type);
		}
		
		override public function clone():Event
		{
			var event:FileLoadingAlgorithmMediaEvent = new FileLoadingAlgorithmMediaEvent(type);
			event.cuePointData = _cuePointData;
			event.metadata = _metadata;
			event.netStatusInfo = _netStatusInfo;
			
			return event;
		}
		
	}

}