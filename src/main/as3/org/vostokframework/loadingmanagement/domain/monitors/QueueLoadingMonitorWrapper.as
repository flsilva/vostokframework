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

	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class QueueLoadingMonitorWrapper extends EventDispatcher  implements IQueueLoadingMonitor
	{
		
		private var _listeners:IList;
		private var _monitor:IQueueLoadingMonitor;
		
		public function get id():String { return "test"; }
		
		public function get monitoring():LoadingMonitoring { return _monitor.monitoring; }
		
		/**
		 * description
		 * 
		 * @param requestId
		 * @param loaders
		 */
		public function QueueLoadingMonitorWrapper(monitor:IQueueLoadingMonitor = null): void
		{
			_listeners = ListUtil.getUniqueTypedList(new ArrayList(), EventListener);
			if (monitor) changeMonitor(monitor);
		}
		
		public function addMonitor(monitor:ILoadingMonitor):void
		{
			_monitor.addMonitor(monitor);
		}
		
		public function addMonitors(monitors:IList):void
		{
			_monitor.addMonitors(monitors);
		}
		
		public function changeMonitor(monitor:IQueueLoadingMonitor):void
		{
			trace("GlobalQueueLoadingMonitorWrapper#changeMonitor()");
			
			if (!monitor) throw new ArgumentError("Argument <monitor> must not be null.");
			
			//if (_monitor) removeListenersFromMonitor();
			
			_monitor = monitor;
			
			addListenersOnMonitor();
		}
		
		override public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			var eventListener:EventListener = new EventListener(type, listener, useCapture, priority, useWeakReference);
			
			_listeners.add(eventListener);
			_monitor.addEventListener(type, listener, useCapture, priority, useWeakReference);
			
			/*
			if (_listeners.add(eventListener))
			{
				_monitor.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}*/
		}
		
		override public function dispatchEvent(event: Event) : Boolean
		{
			return _monitor.dispatchEvent(event);
		}
		
		public function dispose():void
		{
			if (_monitor)
			{
				removeListenersFromMonitor(_monitor);
				_monitor.dispose();
			}
			
			_listeners.clear();
			_listeners = null;
		}
		
		public function equals(other : *): Boolean
		{
			if (this == other) return true;
			if (!(other is ILoadingMonitor)) return false;
			
			var otherMonitor:ILoadingMonitor = other as ILoadingMonitor;
			return id == otherMonitor.id;
		}
		
		override public function hasEventListener(type : String) : Boolean
		{
			return _monitor.hasEventListener(type);
		}
		
		override public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			_monitor.removeEventListener(type, listener, useCapture);
			
			var eventListener:EventListener = new EventListener(type, listener, useCapture);
			_listeners.remove(eventListener);
		}
		
		override public function willTrigger(type : String) : Boolean
		{
			return _monitor.willTrigger(type);
		}
		
		private function addListenersOnMonitor():void
		{
			trace("GlobalQueueLoadingMonitorWrapper#addListenersOnMonitor()");
			
			if (_listeners.isEmpty()) return;
			
			var it:IIterator = _listeners.iterator();
			var eventListener:EventListener;
			
			while (it.hasNext())
			{
				eventListener = it.next();
				trace("GlobalQueueLoadingMonitorWrapper#addListenersOnMonitor() - _monitor.id: " + _monitor.id + " | eventListener.type: " + eventListener.type);
				_monitor.addEventListener(eventListener.type, eventListener.listener, eventListener.useCapture, eventListener.priority, eventListener.useWeakReference);
			}
		}
		
		private function removeListenersFromMonitor(monitor:ILoadingMonitor):void
		{
			if (_listeners.isEmpty()) return;
			
			var it:IIterator = _listeners.iterator();
			var eventListener:EventListener;
			
			while (it.hasNext())
			{
				eventListener = it.next();
				monitor.removeEventListener(eventListener.type, eventListener.listener, eventListener.useCapture);
			}
		}
	}

}