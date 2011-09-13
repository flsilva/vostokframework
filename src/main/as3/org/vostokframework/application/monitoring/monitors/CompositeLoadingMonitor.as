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
package org.vostokframework.application.monitoring.monitors
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.IMap;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.TypedList;
	import org.as3collections.maps.HashMap;
	import org.as3collections.maps.TypedMap;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.application.monitoring.ILoadingMonitor;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.errors.DuplicateLoadingMonitorError;
	import org.vostokframework.domain.loading.errors.LoadingMonitorNotFoundError;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flavio
	 * @version 1.0
	 * @created 14-mai-2011 12:02:52
	 */
	public class CompositeLoadingMonitor extends LoadingMonitor
	{
		/**
		 * @private
		 */
		private var _isFirstProgressDispatch:Boolean;
		private var _lastPercent:int;
		private var _monitors:IMap;
		private var _monitorsListeners:IList;
		private var _progressTimer:Timer;
		private var _progressTimerDelay:int;
		
		/**
		 * 
		 * @param loader
		 */
		public function CompositeLoadingMonitor(loader:ILoader, dispatcher:LoadingMonitorDispatcher)
		{
			super(loader, dispatcher);
			
			_monitors = new TypedMap(new HashMap(), String, ILoadingMonitor);
			_monitorsListeners = new TypedList(new ArrayList(), EventListener);
			_progressTimerDelay = 50;
			_progressTimer = new Timer(_progressTimerDelay);
			_isFirstProgressDispatch = true;
			
			addTimerListener();
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			validateDisposal();
			
			if (!dispatcher.typeBelongs(type))
			{
				var eventListener:EventListener = new EventListener(type, listener, useCapture, priority, useWeakReference);
				_monitorsListeners.add(eventListener);
				
				addListenersOnMonitors();
				return;
			}
			
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function addChild(child:ILoadingMonitor):void
		{
			validateDisposal();
			
			if (!child) throw new ArgumentError("Argument <child> must not be null.");
			if (containsChild(child.loader.identification)) throw new DuplicateLoadingMonitorError("There is already an ILoadingMonitor object stored for a ILoader object with identification:\n<" + child.loader.identification + ">");
			
			_monitors.put(child.loader.identification.toString(), child);
			addListenersOnMonitors();
		}
		
		override public function addChildren(children:IList):void
		{
			validateDisposal();
			
			if (!children) throw new ArgumentError("Argument <children> must not be null.");
			if (children.isEmpty()) return;
			
			var it:IIterator = children.iterator();
			var child:ILoadingMonitor;
			
			while (it.hasNext())
			{
				child = it.next();
				addChild(child);
			}
		}
		
		override public function containsChild(identification:VostokIdentification):Boolean
		{
			if (_monitors.isEmpty()) return false;
			
			if (_monitors.containsKey(identification.toString()))
			{
				return true;
			}
			
			var it:IIterator = _monitors.iterator();
			var child:ILoadingMonitor;
			
			while (it.hasNext())
			{
				child = it.next();
				if (child.containsChild(identification)) return true;
			}
			
			return false;
		}
		
		override public function getChild(identification:VostokIdentification):ILoadingMonitor
		{
			validateDisposal();
			
			if (_monitors.containsKey(identification.toString()))
			{
				return _monitors.getValue(identification.toString());
			}
			else
			{
				var it:IIterator = _monitors.iterator();
				var child:ILoadingMonitor;
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsChild(identification)) return child.getChild(identification);
				}
				
				var message:String = "There is no ILoadingMonitor object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoadingMonitorNotFoundError(message);
			}
		}
		
		override public function hasEventListener(type:String):Boolean
		{
			validateDisposal();
			
			if (!dispatcher.typeBelongs(type))
			{
				return monitorsHasEventListener(type);
			}
			
			return super.hasEventListener(type);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			validateDisposal();
			
			if (!dispatcher.typeBelongs(type))
			{
				removeListenerOnMonitors(type, listener, useCapture);
				return;
			}
			
			super.removeEventListener(type, listener, useCapture);
		}
		
		override public function removeChild(identification:VostokIdentification):void
		{
			validateDisposal();
			
			if (_monitors.containsKey(identification.toString()))
			{
				var monitor:ILoadingMonitor = _monitors.getValue(identification.toString());
				monitor.dispose();
				
				_monitors.remove(identification.toString());
			}
			else
			{
				var it:IIterator = _monitors.iterator();
				var child:ILoadingMonitor;
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsChild(identification))
					{
						child.removeChild(identification);
						return;
					}
				}
				
				var message:String = "There is no ILoadingMonitor object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoadingMonitorNotFoundError(message);
			}
		}
		
		override public function willTrigger(type:String):Boolean
		{
			validateDisposal();
			
			if (!dispatcher.typeBelongs(type))
			{
				return monitorsWillTrigger(type);
			}
			
			return super.willTrigger(type);
		}
		
		override protected function doDispose():void
		{
			removeListenersOnMonitors();
			removeTimerListener();
			_progressTimer.stop();
			_monitors.clear();
			_monitorsListeners.clear();
			
			_monitors = null;
			_monitorsListeners = null;
			_progressTimer = null;
		}
		
		override protected function loadingComplete():void
		{
			_progressTimer.stop();
			_progressTimer.reset();
		}
		
		override protected function loadingStarted():void
		{
			_progressTimer.start();
		}
		
		private function addListenersOnMonitors():void
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
					monitor.addEventListener(eventListener.type, eventListener.listener, eventListener.useCapture, eventListener.priority, eventListener.useWeakReference);
				}
			}
		}
		
		private function addTimerListener():void
		{
			_progressTimer.addEventListener(TimerEvent.TIMER, progressTimerEventHandler, false, 0, true);
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
			
			var monitor:ILoadingMonitor = _monitors.iterator().next();
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
			
			_lastPercent = monitoring.percent;
			updateMonitoring(bytesTotal, bytesLoaded);
			
			if (monitoring.percent != _lastPercent || _isFirstProgressDispatch) dispatcher.dispatchProgressEvent(monitoring);
			
			_isFirstProgressDispatch = false;
		}
		
		private function removeListenerOnMonitors(type:String, listener:Function, useCapture:Boolean = false):void
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
		
		private function removeListenersOnMonitors():void
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
			_progressTimer.removeEventListener(TimerEvent.TIMER, progressTimerEventHandler, false);
		}
		
		private function progressTimerEventHandler(event:TimerEvent):void
		{
			progress();
		}
		
	}

}