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
package org.vostokframework.loadingmanagement.domain.monitors
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.vostokframework.loadingmanagement.domain.RefinedLoader;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.QueueLoadingEvent;

	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class QueueLoadingMonitor extends EventDispatcher implements ILoadingMonitor
	{
		private static const TIMER_DELAY:int = 50;
		
		private var _isFirstProgressDispatch:Boolean;
		private var _lastPercent:int;
		private var _loader:RefinedLoader;
		private var _monitoring:LoadingMonitoring;
		private var _monitors:IList;
		private var _startedTimeConnecting:int;
		private var _timer:Timer;
		
		public function get monitoring():LoadingMonitoring { return _monitoring; }
		
		/**
		 * description
		 * 
		 * @param requestId
		 * @param loaders
		 */
		public function QueueLoadingMonitor(loader:RefinedLoader, monitors:IList): void
		{
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			if (!monitors || monitors.isEmpty()) throw new ArgumentError("Argument <monitors> must not be null nor empty.");
			
			_loader = loader;
			_monitors = monitors;
			_isFirstProgressDispatch = true;
			
			addLoaderListeners();
			createTimer();
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if (!QueueLoadingEvent.typeBelongs(type))
			{
				addMonitorsListener(type, listener, useCapture, priority, useWeakReference);
				return;
			}
			
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function dispose():void
		{
			_monitors.clear();
			removeLoaderListeners();
			removeTimerListener();
			_timer.stop();
			
			_monitors = null;
			_monitoring = null;
			_timer = null;
		}
		
		override public function hasEventListener(type:String):Boolean
		{
			if (!QueueLoadingEvent.typeBelongs(type))
			{
				return monitorsHasEventListener(type);
			}
			
			return super.hasEventListener(type);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			if (!QueueLoadingEvent.typeBelongs(type))
			{
				removeMonitorsListener(type, listener, useCapture);
				return;
			}
			
			super.removeEventListener(type, listener, useCapture);
		}
		
		override public function willTrigger(type:String):Boolean
		{
			if (!QueueLoadingEvent.typeBelongs(type))
			{
				return monitorsWillTrigger(type);
			}
			
			return super.willTrigger(type);
		}
		
		protected function createLoadingMonitoring(latency:int):void
		{
			_monitoring = new LoadingMonitoring(latency);
		}
		
		private function addLoaderListeners():void
		{
			_loader.addEventListener(LoaderEvent.CONNECTING, loaderConnectingHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.OPEN, loaderOpenHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.CANCELED, loaderCanceledHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.STOPPED, loaderStoppedHandler, false, 0, true);
		}
		
		private function addMonitorsListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			var it:IIterator = _monitors.iterator();
			var monitor:ILoadingMonitor;
			
			while (it.hasNext())
			{
				monitor = it.next();
				monitor.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		
		private function addTimerListener():void
		{
			_timer.addEventListener(TimerEvent.TIMER, timerEventHandler, false, 0, true);
		}
		
		private function createEvent(type:String):QueueLoadingEvent
		{
			return new QueueLoadingEvent(type, _loader.id, _monitoring);
		}
		
		private function createTimer():void
		{
			_timer = new Timer(TIMER_DELAY);
			addTimerListener();
		}
		
		private function loaderConnectingHandler(event:LoaderEvent):void
		{
			_startedTimeConnecting = getTimer();
		}
		
		private function loaderOpenHandler(event:LoaderEvent):void
		{
			var latency:int = getTimer() - _startedTimeConnecting;
			createLoadingMonitoring(latency);
			dispatchEvent(createEvent(QueueLoadingEvent.OPEN));
			_timer.start();
		}
		
		private function loaderCompleteHandler(event:LoaderEvent):void
		{
			dispatchEvent(createEvent(QueueLoadingEvent.COMPLETE));
			_timer.stop();
		}
		
		private function loaderCanceledHandler(event:LoaderEvent):void
		{
			dispatchEvent(createEvent(QueueLoadingEvent.CANCELED));
			_timer.stop();
		}
		
		private function loaderStoppedHandler(event:LoaderEvent):void
		{
			dispatchEvent(createEvent(QueueLoadingEvent.STOPPED));
			_timer.stop();
		}
		
		private function monitorsHasEventListener(type:String):Boolean
		{
			var monitor:ILoadingMonitor = _monitors.getAt(0);
			return monitor.hasEventListener(type);
		}
		
		private function monitorsWillTrigger(type:String):Boolean
		{
			var monitor:ILoadingMonitor = _monitors.getAt(0);
			return monitor.willTrigger(type);
		}
		
		private function progress():void
		{
			var it:IIterator = _monitors.iterator();
			var monitor:ILoadingMonitor;
			
			var bytesLoaded:int;
			var bytesTotal:int;
			var totalLoadersHasBytesTotal:int;
			var totalLoadersHasNotBytesTotal:int;
			
			while (it.hasNext())
			{
				monitor = it.next();
				
				if (monitor.monitoring.bytesTotal > 0)
				{
					 totalLoadersHasBytesTotal++;
					 bytesTotal += monitor.monitoring.bytesTotal;
					 bytesLoaded += monitor.monitoring.bytesLoaded;
				}
			}
			
			totalLoadersHasNotBytesTotal = _monitors.size() - totalLoadersHasBytesTotal;
			
			if (totalLoadersHasNotBytesTotal > 0)
			{
				var fakeBytes:int = bytesTotal / totalLoadersHasBytesTotal;
				bytesTotal += fakeBytes * totalLoadersHasNotBytesTotal;
			}
			
			_lastPercent = _monitoring.percent;
			_monitoring.update(bytesTotal, bytesLoaded);
			
			if (_monitoring.percent != _lastPercent || _isFirstProgressDispatch) dispatchEvent(createEvent(QueueLoadingEvent.PROGRESS));
			
			_isFirstProgressDispatch = false;
		}
		
		private function removeLoaderListeners():void
		{
			_loader.removeEventListener(LoaderEvent.CONNECTING, loaderConnectingHandler, false);
			_loader.removeEventListener(LoaderEvent.OPEN, loaderOpenHandler, false);
			_loader.removeEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false);
			_loader.removeEventListener(LoaderEvent.CANCELED, loaderCanceledHandler, false);
			_loader.removeEventListener(LoaderEvent.STOPPED, loaderStoppedHandler, false);
		}
		
		private function removeMonitorsListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			var it:IIterator = _monitors.iterator();
			var monitor:ILoadingMonitor;
			
			while (it.hasNext())
			{
				monitor = it.next();
				monitor.removeEventListener(type, listener, useCapture);
			}
		}
		
		private function removeTimerListener():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, timerEventHandler, false);
		}
		
		private function timerEventHandler(event:TimerEvent):void
		{
			progress();
		}

	}

}