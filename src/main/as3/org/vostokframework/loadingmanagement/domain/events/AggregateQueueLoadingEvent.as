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
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitoring;

	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AggregateQueueLoadingEvent extends Event
	{
		public static const CANCELED:String = "VostokFramework.AggregateQueueLoadingEvent.CANCELED";
		public static const COMPLETE:String = "VostokFramework.AggregateQueueLoadingEvent.COMPLETE";
		public static const OPEN:String = "VostokFramework.AggregateQueueLoadingEvent.OPEN";
		public static const PROGRESS:String = "VostokFramework.AggregateQueueLoadingEvent.PROGRESS";
		public static const STOPPED:String = "VostokFramework.AggregateQueueLoadingEvent.STOPPED";
		
		/**
		 * description
		 */
		private var _monitoring:LoadingMonitoring;
		private var _queueId:String;
		private var _queueLocale:String;
		
		/**
		 * description
		 */
		public function get monitoring(): LoadingMonitoring { return _monitoring; }
		
		/**
		 * description
		 */
		public function get queueId(): String { return _queueId; }
		
		/**
		 * description
		 */
		public function get queueLocale(): String { return _queueLocale; }
		
		/**
		 * description
		 * 
		 * @param assetId
		 * @param assetType
		 * @param monitoring
		 * @param assetData
		 */
		public function AggregateQueueLoadingEvent(type:String, queueId:String, queueLocale:String, monitoring:LoadingMonitoring = null)
		{
			super(type);
			
			_queueId = queueId;
			_queueLocale = queueLocale;
			_monitoring = monitoring;
		}
		
		override public function clone():Event
		{
			return new AggregateQueueLoadingEvent(type, _queueId, _queueLocale, _monitoring);
		}
		
		public static function typeBelongs(type:String):Boolean
		{
			return type == CANCELED ||
			       type == COMPLETE ||
			       type == OPEN ||
			       type == PROGRESS ||
			       type == STOPPED;
		}
		
	}

}