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
package org.vostokframework.loadingmanagement.monitors
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.vostokframework.loadingmanagement.RequestLoader;
	import org.vostokframework.loadingmanagement.RequestLoaderStatus;
	import org.vostokframework.loadingmanagement.events.RequestLoaderEvent;
	import org.vostokframework.loadingmanagement.events.RequestLoadingMonitorEvent;

	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class RequestLoadingMonitor extends EventDispatcher implements ILoadingMonitor
	{
		private static const TIMER_DELAY:int = 50;
		
		private var _assetLoadingMonitors:IList;
		private var _loader:RequestLoader;
		private var _monitoring:LoadingMonitoring;
		private var _startedTimeTryingToConnect:int;
		private var _timer:Timer;
		
		public function get monitoring():LoadingMonitoring { return _monitoring; }
		
		/**
		 * description
		 * 
		 * @param requestId
		 * @param loaders
		 */
		public function RequestLoadingMonitor(loader:RequestLoader, assetLoadingMonitors:IList): void
		{
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			if (!assetLoadingMonitors || assetLoadingMonitors.isEmpty()) throw new ArgumentError("Argument <assetLoadingMonitors> must not be null nor empty.");
			
			_loader = loader;
			_assetLoadingMonitors = assetLoadingMonitors;
			
			addLoaderListeners();
			createTimer();
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if (isAssetLoadingMonitorEvent(type))
			{
				addMonitorsListener(type, listener, useCapture, priority, useWeakReference);
				return;
			}
			
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function dispose():void
		{
			_assetLoadingMonitors.clear();
			removeLoaderListeners();
			removeTimerListener();
			_timer.stop();
			
			_assetLoadingMonitors = null;
			_monitoring = null;
			_timer = null;
		}
		
		override public function hasEventListener(type:String):Boolean
		{
			if (isAssetLoadingMonitorEvent(type))
			{
				return monitorsHasEventListener(type);
			}
			
			return super.hasEventListener(type);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			if (isAssetLoadingMonitorEvent(type))
			{
				removeMonitorsListener(type, listener, useCapture);
				return;
			}
			
			super.removeEventListener(type, listener, useCapture);
		}
		
		override public function willTrigger(type:String):Boolean
		{
			if (isAssetLoadingMonitorEvent(type))
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
			_loader.addEventListener(RequestLoaderEvent.STATUS_CHANGED, loaderStatusChangedHandler, false, 0, true);
		}
		
		private function addMonitorsListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			var it:IIterator = _assetLoadingMonitors.iterator();
			var assetLoadingMonitor:ILoadingMonitor;
			
			while (it.hasNext())
			{
				assetLoadingMonitor = it.next();
				assetLoadingMonitor.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		
		private function addTimerListener():void
		{
			_timer.addEventListener(TimerEvent.TIMER, timerEventHandler, false, 0, true);
		}
		
		private function createEvent(type:String, requestId:String, monitoring:LoadingMonitoring = null):RequestLoadingMonitorEvent
		{
			return new RequestLoadingMonitorEvent(type, requestId, monitoring);
		}
		
		private function createTimer():void
		{
			_timer = new Timer(TIMER_DELAY);
			addTimerListener();
		}
		
		private function isAssetLoadingMonitorEvent(type:String):Boolean
		{
			//TODO:refatorar e referenciar uma constate estática: AssetLoadingMonitorEvent.EVENT_NAME_PREFIX
			return type.indexOf("AssetLoadingMonitorEvent") != -1;
		}
		
		private function loaderStatusChangedHandler(event:RequestLoaderEvent):void
		{
			if (event.status.equals(RequestLoaderStatus.TRYING_TO_CONNECT))
			{
				_startedTimeTryingToConnect = getTimer();
			}
			else if (event.status.equals(RequestLoaderStatus.LOADING))
			{
				var latency:int = getTimer() - _startedTimeTryingToConnect;
				createLoadingMonitoring(latency);
				dispatchEvent(createEvent(RequestLoadingMonitorEvent.OPEN, _loader.id, _monitoring));
				_timer.start();
			}
			else if (event.status.equals(RequestLoaderStatus.CANCELED))
			{
				dispatchEvent(createEvent(RequestLoadingMonitorEvent.CANCELED, _loader.id, _monitoring));
				_timer.stop();
			}
			else if (event.status.equals(RequestLoaderStatus.COMPLETE) || event.status.equals(RequestLoaderStatus.COMPLETE_WITH_FAILURES))
			{
				dispatchEvent(createEvent(RequestLoadingMonitorEvent.COMPLETE, _loader.id, _monitoring));
				_timer.stop();
			}
			else if (event.status.equals(RequestLoaderStatus.STOPPED) || event.status.equals(RequestLoaderStatus.COMPLETE_WITH_FAILURES))
			{
				dispatchEvent(createEvent(RequestLoadingMonitorEvent.STOPPED, _loader.id, _monitoring));
				_timer.stop();
			}
		}
		
		private function monitorsHasEventListener(type:String):Boolean
		{
			var assetLoadingMonitor:ILoadingMonitor = _assetLoadingMonitors.getAt(0);
			return assetLoadingMonitor.hasEventListener(type);
		}
		
		private function monitorsWillTrigger(type:String):Boolean
		{
			var assetLoadingMonitor:ILoadingMonitor = _assetLoadingMonitors.getAt(0);
			return assetLoadingMonitor.willTrigger(type);
		}
		
		private function progress():void
		{
			var it:IIterator = _assetLoadingMonitors.iterator();
			var assetLoadingMonitor:ILoadingMonitor;
			
			var bytesLoaded:int;
			var bytesTotal:int;
			var totalLoadersHasBytesTotal:int;
			var totalLoadersHasNotBytesTotal:int;
			
			while (it.hasNext())
			{
				assetLoadingMonitor = it.next();
				
				if (assetLoadingMonitor.monitoring.bytesTotal > 0)
				{
					 totalLoadersHasBytesTotal++;
					 bytesTotal += assetLoadingMonitor.monitoring.bytesTotal;
					 bytesLoaded += assetLoadingMonitor.monitoring.bytesLoaded;
				}
			}
			
			totalLoadersHasNotBytesTotal = _assetLoadingMonitors.size() - totalLoadersHasBytesTotal;
			
			if (totalLoadersHasNotBytesTotal > 0)
			{
				var fakeBytes:int = bytesTotal / totalLoadersHasBytesTotal;
				bytesTotal += fakeBytes * totalLoadersHasNotBytesTotal;
			}
			
			_monitoring.update(bytesTotal, bytesLoaded);
			dispatchEvent(createEvent(RequestLoadingMonitorEvent.PROGRESS, _loader.id, _monitoring));
		}
		
		private function removeLoaderListeners():void
		{
			_loader.removeEventListener(RequestLoaderEvent.STATUS_CHANGED, loaderStatusChangedHandler, false);
		}
		
		private function removeMonitorsListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			var it:IIterator = _assetLoadingMonitors.iterator();
			var assetLoadingMonitor:ILoadingMonitor;
			
			while (it.hasNext())
			{
				assetLoadingMonitor = it.next();
				assetLoadingMonitor.removeEventListener(type, listener, useCapture);
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