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
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.ILoader;

	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingMonitorWrapper implements ILoadingMonitor
	{
		
		private var _listeners:IList;
		private var _monitor:ILoadingMonitor;
		
		public function get id():String { return "test"; }
		
		public function get loader():ILoader { return _monitor.loader; }
		
		public function get monitoring():LoadingMonitoring { return _monitor.monitoring; }
		
		/**
		 * description
		 * 
		 * @param requestId
		 * @param loaders
		 */
		public function LoadingMonitorWrapper(monitor:ILoadingMonitor = null)
		{
			_listeners = ListUtil.getUniqueTypedList(new ArrayList(), EventListener);
			if (monitor) changeMonitor(monitor);
		}
		
		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			var eventListener:EventListener = new EventListener(type, listener, useCapture, priority, useWeakReference);
			_listeners.add(eventListener);
			
			_monitor.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function addChild(child:ILoadingMonitor):void
		{
			_monitor.addChild(child);
		}
		
		public function addChildren(children:IList):void
		{
			_monitor.addChildren(children);
		}
		
		public function changeMonitor(monitor:ILoadingMonitor):void
		{
			if (!monitor) throw new ArgumentError("Argument <monitor> must not be null.");
			
			if (_monitor) removeListenersFromMonitor(_monitor);//TODO:repensar se nao deve descomentar
			
			_monitor = monitor;
			
			addListenersOnMonitor();
		}
		
		public function containsChild(identification:VostokIdentification):Boolean
		{
			return _monitor.containsChild(identification);
		}
		
		public function dispatchEvent(event: Event) : Boolean
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
		
		public function getChild(identification:VostokIdentification):ILoadingMonitor
		{
			return _monitor.getChild(identification);
		}
		
		public function hasEventListener(type : String) : Boolean
		{
			return _monitor.hasEventListener(type);
		}
		
		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			_monitor.removeEventListener(type, listener, useCapture);
			
			var eventListener:EventListener = new EventListener(type, listener, useCapture);
			_listeners.remove(eventListener);
		}
		
		public function removeChild(identification:VostokIdentification):void
		{
			_monitor.removeChild(identification);
		}
		
		public function willTrigger(type : String) : Boolean
		{
			return _monitor.willTrigger(type);
		}
		
		private function addListenersOnMonitor():void
		{
			if (_listeners.isEmpty()) return;
			
			var it:IIterator = _listeners.iterator();
			var eventListener:EventListener;
			
			while (it.hasNext())
			{
				eventListener = it.next();
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