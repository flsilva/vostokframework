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
	import org.as3collections.lists.ArrayList;
	import org.as3collections.utils.ListUtil;
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.vostokframework.loadingmanagement.domain.StatefulLoader;
	import org.vostokframework.loadingmanagement.domain.errors.DuplicateLoadingMonitorError;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.QueueLoadingEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class QueueLoadingMonitor extends EventDispatcher implements IQueueLoadingMonitor
	{
		private static const TIMER_DELAY:int = 50;
		
		private var _disposed:Boolean;
		private var _isFirstProgressDispatch:Boolean;
		private var _lastPercent:int;
		private var _loader:StatefulLoader;
		private var _monitoring:LoadingMonitoring;
		private var _monitors:IList;
		private var _monitorsListeners:IList;
		private var _timer:Timer;
		
		protected function get loader():StatefulLoader { return _loader; }
		
		public function get id():String { return _loader.id; }
		
		public function get monitoring():LoadingMonitoring { return _monitoring; }
		
		/**
		 * description
		 * 
		 * @param requestId
		 * @param loaders
		 */
		public function QueueLoadingMonitor(loader:StatefulLoader, monitors:IList = null): void
		{
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			if (!monitors) monitors = new ArrayList();
			
			_monitorsListeners = ListUtil.getUniqueTypedList(new ArrayList(), EventListener);
			_loader = loader;
			_monitors = monitors;
			_isFirstProgressDispatch = true;
			
			addLoaderListeners();
			createTimer();
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			validateDisposal();
			
			if (!typeBelongs(type))
			{
				var eventListener:EventListener = new EventListener(type, listener, useCapture, priority, useWeakReference);
				_monitorsListeners.add(eventListener);
				
				addMonitorsListeners();
				return;
			}
			
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function addMonitor(monitor:ILoadingMonitor):void
		{
			validateDisposal();
			if (!monitor) throw new ArgumentError("The <monitor> argument must not be null.");
			
			if (_monitors.contains(monitor))
			{
				var message:String = "There is already an ILoadingMonitor stored with id:\n";
				message += monitor.id;
				
				throw new DuplicateLoadingMonitorError(monitor.id, message);
			}
			
			_monitors.add(monitor);
			addMonitorsListeners();
		}
		
		public function addMonitors(monitors:IList):void
		{
			validateDisposal();
			if (!monitors) throw new ArgumentError("The <monitors> argument must not be null.");
			if (monitors.isEmpty()) return;
			
			var it:IIterator = monitors.iterator();
			var monitor:ILoadingMonitor;
			
			while (it.hasNext())
			{
				monitor = it.next();
				addMonitor(monitor);
			}
		}
		
		public function dispose():void
		{
			if (_disposed) return;
			
			removeMonitorsListeners();
			removeLoaderListeners();
			removeTimerListener();
			_timer.stop();
			_monitors.clear();
			_monitorsListeners.clear();
			
			_disposed = true;
			_monitors = null;
			_monitorsListeners = null;
			_monitoring = null;
			_timer = null;
		}
		
		public function equals(other : *): Boolean
		{
			validateDisposal();
			
			if (this == other) return true;
			if (!(other is ILoadingMonitor)) return false;
			
			var otherMonitor:ILoadingMonitor = other as ILoadingMonitor;
			return id == otherMonitor.id;
		}
		
		override public function hasEventListener(type:String):Boolean
		{
			validateDisposal();
			
			if (!typeBelongs(type))
			{
				return monitorsHasEventListener(type);
			}
			
			return super.hasEventListener(type);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			validateDisposal();
			
			if (!typeBelongs(type))
			{
				removeMonitorsListener(type, listener, useCapture);
				return;
			}
			
			super.removeEventListener(type, listener, useCapture);
		}
		
		override public function willTrigger(type:String):Boolean
		{
			validateDisposal();
			
			if (!typeBelongs(type))
			{
				return monitorsWillTrigger(type);
			}
			
			return super.willTrigger(type);
		}
		
		protected function createEvent(type:String):Event
		{
			validateDisposal();
			return new QueueLoadingEvent(type, _loader.id, _monitoring);
		}
		
		protected function createLoadingMonitoring(latency:int):void
		{
			_monitoring = new LoadingMonitoring(latency);
		}
		
		protected function dispatchCanceledEvent():void
		{
			dispatchEvent(createEvent(QueueLoadingEvent.CANCELED));
		}
		
		protected function dispatchCompleteEvent():void
		{
			dispatchEvent(createEvent(QueueLoadingEvent.COMPLETE));
		}
		
		protected function dispatchOpenEvent():void
		{
			dispatchEvent(createEvent(QueueLoadingEvent.OPEN));
		}
		
		protected function dispatchProgressEvent():void
		{
			dispatchEvent(createEvent(QueueLoadingEvent.PROGRESS));
		}
		
		protected function dispatchStoppedEvent():void
		{
			dispatchEvent(createEvent(QueueLoadingEvent.STOPPED));
		}
		
		protected function typeBelongs(type:String):Boolean
		{
			return QueueLoadingEvent.typeBelongs(type);
		}
		
		private function addLoaderListeners():void
		{
			_loader.addEventListener(LoaderEvent.OPEN, loaderOpenHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.CANCELED, loaderCanceledHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.STOPPED, loaderStoppedHandler, false, 0, true);
		}
		
		private function addMonitorsListeners():void
		{
			//trace("QueueLoadingMonitor#addMonitorsListeners() - id: " + id);
			
			var itMonitors:IIterator = _monitors.iterator();
			var itListeners:IIterator;
			var monitor:ILoadingMonitor;
			var eventListener:EventListener;
			
			while (itMonitors.hasNext())
			{
				monitor = itMonitors.next();
				itListeners = _monitorsListeners.iterator();
				//trace("QueueLoadingMonitor#addMonitorsListeners() - monitor.id: " + monitor.id);
				while (itListeners.hasNext())
				{
					eventListener = itListeners.next();
					//trace("QueueLoadingMonitor#addMonitorsListeners() - eventListener.type: " + eventListener.type);
					monitor.addEventListener(eventListener.type, eventListener.listener, eventListener.useCapture, eventListener.priority, eventListener.useWeakReference);
				}
			}
		}
		
		private function addTimerListener():void
		{
			_timer.addEventListener(TimerEvent.TIMER, timerEventHandler, false, 0, true);
		}
		
		private function createTimer():void
		{
			_timer = new Timer(TIMER_DELAY);
			addTimerListener();
		}
		
		private function loaderOpenHandler(event:LoaderEvent):void
		{
			validateDisposal();
			createLoadingMonitoring(event.latency);
			dispatchOpenEvent();
			_timer.start();
		}
		
		private function loaderCompleteHandler(event:LoaderEvent):void
		{
			validateDisposal();
			_timer.stop();
			dispatchCompleteEvent();
		}
		
		private function loaderCanceledHandler(event:LoaderEvent):void
		{
			validateDisposal();
			dispatchCanceledEvent();
			_timer.stop();
		}
		
		private function loaderStoppedHandler(event:LoaderEvent):void
		{
			validateDisposal();
			dispatchStoppedEvent();
			_timer.stop();
		}
		
		private function monitorsHasEventListener(type:String):Boolean
		{
			if (_monitorsListeners.isEmpty()) return false;
			
			var it:IIterator = _monitorsListeners.iterator();
			var eventListener:EventListener;
			
			while (it.hasNext())
			{
				eventListener = it.next();
				if (eventListener.type == type) return true;
			}
			
			return false;
		}
		
		private function monitorsWillTrigger(type:String):Boolean
		{
			if (_monitors.isEmpty()) return false;
			
			var monitor:ILoadingMonitor = _monitors.getAt(0);
			return monitor.willTrigger(type);
		}
		
		private function progress():void
		{
			validateDisposal();
			
			var it:IIterator = _monitors.iterator();
			var monitor:ILoadingMonitor;
			
			var bytesLoaded:int;
			var bytesTotal:int;
			var totalLoadersHasBytesTotal:int;
			var totalLoadersHasNotBytesTotal:int;
			
			while (it.hasNext())
			{
				monitor = it.next();
				
				if (monitor.monitoring && monitor.monitoring.bytesTotal > 0)
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
			
			if (_monitoring.percent != _lastPercent || _isFirstProgressDispatch) dispatchProgressEvent();
			
			_isFirstProgressDispatch = false;
		}
		
		private function removeLoaderListeners():void
		{
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
			
			var eventListener:EventListener = new EventListener(type, listener, useCapture);
			_monitorsListeners.remove(eventListener);
		}
		
		private function removeMonitorsListeners():void
		{
			var itMonitors:IIterator = _monitors.iterator();
			var itListeners:IIterator;
			var monitor:ILoadingMonitor;
			var eventListener:EventListener;
			
			while (itMonitors.hasNext())
			{
				monitor = itMonitors.next();
				itListeners = _monitorsListeners.iterator();
				
				while (itListeners.hasNext())
				{
					eventListener = itListeners.next();
					monitor.removeEventListener(eventListener.type, eventListener.listener, eventListener.useCapture);
				}
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
		
		/**
		 * @private
		 */
		private function validateDisposal():void
		{
			if (_disposed) throw new ObjectDisposedError("This object was disposed, therefore no more operations can be performed.");
		}

	}

}