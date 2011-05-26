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
package org.vostokframework.loadingmanagement.events
{
	import org.vostokframework.loadingmanagement.monitors.LoadingMonitoring;

	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class RequestLoadingMonitorEvent extends Event
	{
		public static const CANCELED:String = "VostokFramework.RequestLoadingMonitorEvent.CANCELED";
		public static const COMPLETE:String = "VostokFramework.RequestLoadingMonitorEvent.COMPLETE";
		public static const OPEN:String = "VostokFramework.RequestLoadingMonitorEvent.OPEN";
		public static const PROGRESS:String = "VostokFramework.RequestLoadingMonitorEvent.PROGRESS";
		public static const STOPPED:String = "VostokFramework.RequestLoadingMonitorEvent.STOPPED";
		
		/**
		 * description
		 */
		private var _monitoring:LoadingMonitoring;
		private var _requestId:String;
		
		/**
		 * description
		 */
		public function get monitoring(): LoadingMonitoring { return _monitoring; }
		
		/**
		 * description
		 */
		public function get requestId(): String { return _requestId; }
		
		/**
		 * description
		 * 
		 * @param assetId
		 * @param assetType
		 * @param monitoring
		 * @param assetData
		 */
		public function RequestLoadingMonitorEvent(type:String, requestId:String, monitoring:LoadingMonitoring = null)
		{
			super(type);
			
			_requestId = requestId;
			_monitoring = monitoring;
		}
		
		override public function clone():Event
		{
			return new RequestLoadingMonitorEvent(type, _requestId, _monitoring);
		}
		
	}

}