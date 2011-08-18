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
	import org.as3collections.IList;
	import org.as3coreaddendum.errors.IllegalStateError;
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.events.LoaderErrorEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;

	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;

	/**
	 * @author Flavio
	 * @version 1.0
	 * @created 14-mai-2011 12:02:52
	 */
	public class LoadingMonitor extends EventDispatcher implements ILoadingMonitor
	{
		/**
		 * @private
		 */
		private var _dispatcher:LoadingMonitorDispatcher;
		private var _disposed:Boolean;
		private var _loader:VostokLoader;
		private var _monitoring:LoadingMonitoring;
		
		public function get loader():VostokLoader { return _loader; }
		
		public function get monitoring():LoadingMonitoring { return _monitoring; }
		
		protected function get dispatcher():LoadingMonitorDispatcher { return _dispatcher; }
		//TODO:pensar sobre ao invés de extender EventDispatcher.as, implementar IEventDispatcher.as
		/**
		 * 
		 * @param loader
		 */
		public function LoadingMonitor(loader:VostokLoader, dispatcher:LoadingMonitorDispatcher)
		{
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			
			_loader = loader;
			_dispatcher = dispatcher;
			
			addLoaderListeners();
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function addMonitor(monitor:ILoadingMonitor):void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function addMonitors(monitors:IList):void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function contains(identification:VostokIdentification):Boolean
		{
			return false;
		}
		
		public function dispose():void
		{
			if (_disposed) return;
			
			removeLoaderListeners();
			
			_loader = null;
			_monitoring = null;
			
			doDispose();
			_disposed = true;
		}
		
		public function getMonitor(identification:VostokIdentification):ILoadingMonitor
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		override public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function removeMonitor(identification:VostokIdentification):void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		override public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}
		
		protected function createLoadingMonitoring(latency:int):void
		{
			validateDisposal();
			_monitoring = new LoadingMonitoring(latency);
		}
		
		protected function doDispose():void
		{
			
		}
		
		protected function loadingComplete():void
		{
			
		}
		
		protected function loadingStarted():void
		{
			
		}
		
		protected function updateMonitoring(bytesTotal:int, bytesLoaded:int):void
		{
			validateDisposal();
			_monitoring.update(bytesTotal, bytesLoaded);
		}
		
		/**
		 * @private
		 */
		protected function validateDisposal():void
		{
			if (_disposed) throw new ObjectDisposedError("This object was disposed, therefore no more operations can be performed.");
		}
		
		private function addLoaderListeners():void
		{
			validateDisposal();
			
			_loader.addEventListener(LoaderEvent.CANCELED, loaderCanceledHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(LoaderErrorEvent.FAILED, loaderFailedHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(LoaderEvent.HTTP_STATUS, loaderHttpStatusHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(LoaderEvent.INIT, loaderInitHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(LoaderEvent.OPEN, loaderOpenHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(LoaderEvent.STOPPED, loaderStoppedHandler, false, int.MAX_VALUE, true);
		}
		
		private function removeLoaderListeners():void
		{
			validateDisposal();
			
			_loader.removeEventListener(LoaderEvent.CANCELED, loaderCanceledHandler, false);
			_loader.removeEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false);
			_loader.removeEventListener(LoaderErrorEvent.FAILED, loaderFailedHandler, false);
			_loader.removeEventListener(LoaderEvent.HTTP_STATUS, loaderHttpStatusHandler, false);
			_loader.removeEventListener(LoaderEvent.INIT, loaderInitHandler, false);
			_loader.removeEventListener(LoaderEvent.OPEN, loaderOpenHandler, false);
			_loader.removeEventListener(ProgressEvent.PROGRESS, loaderProgressHandler, false);
			_loader.removeEventListener(LoaderEvent.STOPPED, loaderStoppedHandler, false);
		}
		
		private function loaderCanceledHandler(event:LoaderEvent):void
		{
			validateDisposal();
			_dispatcher.dispatchCanceledEvent(_monitoring);
		}
		
		private function loaderCompleteHandler(event:LoaderEvent):void
		{
			validateDisposal();
			
			if (_monitoring) updateMonitoring(_monitoring.bytesTotal, _monitoring.bytesTotal);
			
			loadingComplete();
			_dispatcher.dispatchProgressEvent(_monitoring);
			_dispatcher.dispatchCompleteEvent(_monitoring, event.data);
		}
		
		private function loaderFailedHandler(event:LoaderErrorEvent):void
		{
			validateDisposal();
			_dispatcher.dispatchFailedEvent(_monitoring, event.errors);
		}
		
		private function loaderHttpStatusHandler(event:LoaderEvent):void
		{
			validateDisposal();
			_dispatcher.dispatchHttpStatusEvent(_monitoring, event.httpStatus);
		}
		
		private function loaderInitHandler(event:LoaderEvent):void
		{
			validateDisposal();
			_dispatcher.dispatchInitEvent(_monitoring, event.data);
		}
		
		private function loaderOpenHandler(event:LoaderEvent):void
		{
			validateDisposal();
			createLoadingMonitoring(event.latency);
			_dispatcher.dispatchOpenEvent(_monitoring, event.data);
			loadingStarted();
		}
		
		private function loaderProgressHandler(event:ProgressEvent):void
		{
			validateDisposal();
			
			if (!_monitoring)
			{
				var errorMessage:String = "Object entered into an illegal state:\n";
				errorMessage += "Event: <ProgressEvent.PROGRESS> must be dispatched after event: <" + LoaderEvent.OPEN + ">";
				
				throw new IllegalStateError(errorMessage);
			}
			
			updateMonitoring(event.bytesTotal, event.bytesLoaded);
			_dispatcher.dispatchProgressEvent(_monitoring);
		}
		
		private function loaderStoppedHandler(event:LoaderEvent):void
		{
			validateDisposal();
			_dispatcher.dispatchStoppedEvent(_monitoring);
		}
		
	}

}