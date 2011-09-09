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
package org.vostokframework.application.monitoring
{
	import org.as3utils.StringUtil;
	import org.vostokframework.domain.loading.events.QueueLoadingEvent;

	import flash.events.Event;

	/**
	 * @author Flavio
	 * @version 1.0
	 * @created 14-mai-2011 12:02:52
	 */
	public class QueueLoadingMonitorDispatcher extends LoadingMonitorDispatcher
	{
		/**
		 * @private
		 */
		private var _queueId:String;
		private var _queueLocale:String;
		
		/**
		 * 
		 */
		public function QueueLoadingMonitorDispatcher(queueId:String, queueLocale:String)
		{
			if (StringUtil.isBlank(queueId)) throw new ArgumentError("Argument <queueId> must not be null nor an empty String.");
			if (StringUtil.isBlank(queueLocale)) throw new ArgumentError("Argument <queueLocale> must not be null nor an empty String.");
			
			_queueId = queueId;
			_queueLocale = queueLocale;
		}
		
		override public function dispatchCanceledEvent(monitoring:LoadingMonitoring):void
		{
			dispatchEvent(createEvent(QueueLoadingEvent.CANCELED, monitoring));
		}
		
		override public function dispatchCompleteEvent(monitoring:LoadingMonitoring, data:* = null):void
		{
			data = null;//just to avoid compiler warnings
			dispatchEvent(createEvent(QueueLoadingEvent.COMPLETE, monitoring));
		}
		
		override public function dispatchOpenEvent(monitoring:LoadingMonitoring, data:* = null):void
		{
			data = null;//just to avoid compiler warnings
			dispatchEvent(createEvent(QueueLoadingEvent.OPEN, monitoring));
		}
		
		override public function dispatchProgressEvent(monitoring:LoadingMonitoring):void
		{
			dispatchEvent(createEvent(QueueLoadingEvent.PROGRESS, monitoring));
		}
		
		override public function dispatchStoppedEvent(monitoring:LoadingMonitoring):void
		{
			dispatchEvent(createEvent(QueueLoadingEvent.STOPPED, monitoring));
		}
		
		override public function typeBelongs(type:String):Boolean
		{
			return QueueLoadingEvent.typeBelongs(type);
		}
		
		protected function createEvent(type:String, monitoring:LoadingMonitoring):Event
		{
			return new QueueLoadingEvent(type, _queueId, _queueLocale, monitoring);
		}
		
	}

}