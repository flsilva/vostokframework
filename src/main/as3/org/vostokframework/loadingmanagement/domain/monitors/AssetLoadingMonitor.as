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
	import org.vostokframework.assetmanagement.domain.AssetIdentification;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.loadingmanagement.domain.PlainLoader;
	import org.vostokframework.loadingmanagement.domain.events.AssetLoadingErrorEvent;
	import org.vostokframework.loadingmanagement.domain.events.AssetLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;

	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * @author Flavio
	 * @version 1.0
	 * @created 14-mai-2011 12:02:52
	 */
	public class AssetLoadingMonitor extends EventDispatcher implements ILoadingMonitor
	{
		private var _allowInternalCache:Boolean;
		private var _assetIdentification:AssetIdentification;
		private var _assetType:AssetType;
		private var _loader:PlainLoader;
		private var _monitoring:LoadingMonitoring;
		
		public function get id():String { return _assetIdentification.toString(); }
		
		public function get monitoring():LoadingMonitoring { return _monitoring; }
		
		/**
		 * 
		 * @param assetId
		 * @param assetType
		 * @param loader
		 */
		public function AssetLoadingMonitor(identification:AssetIdentification, assetType:AssetType, loader:PlainLoader, allowInternalCache:Boolean = false)
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			if (!assetType) throw new ArgumentError("Argument <assetType> must not be null.");
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			
			_assetIdentification = identification;
			_assetType = assetType;
			_loader = loader;
			_allowInternalCache = allowInternalCache;
			
			addLoaderListeners();
		}
		
		public function equals(other : *): Boolean
		{
			if (this == other) return true;
			if (!(other is ILoadingMonitor)) return false;
			
			var otherMonitor:ILoadingMonitor = other as ILoadingMonitor;
			return id == otherMonitor.id;
		}
		
		public function dispose():void
		{
			removeLoaderListeners();
			
			_assetType = null;
			_loader = null;
			_monitoring = null;
		}
		
		protected function createLoadingMonitoring(latency:int):void
		{
			_monitoring = new LoadingMonitoring(latency);
		}
		
		private function addLoaderListeners():void
		{
			_loader.addEventListener(LoaderEvent.INIT, loaderInitHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(LoaderEvent.OPEN, loaderOpenHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(LoaderEvent.CANCELED, loaderCanceledHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(LoaderEvent.STOPPED, loaderStoppedHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loaderHttpStatusHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, loaderIoErrorHandler, false, int.MAX_VALUE, true);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderSecurityErrorHandler, false, int.MAX_VALUE, true);
		}
		
		private function removeLoaderListeners():void
		{
			_loader.removeEventListener(LoaderEvent.INIT, loaderInitHandler, false);
			_loader.removeEventListener(LoaderEvent.OPEN, loaderOpenHandler, false);
			_loader.removeEventListener(ProgressEvent.PROGRESS, loaderProgressHandler, false);
			_loader.removeEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false);
			_loader.removeEventListener(LoaderEvent.CANCELED, loaderCanceledHandler, false);
			_loader.removeEventListener(LoaderEvent.STOPPED, loaderStoppedHandler, false);
			_loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, loaderHttpStatusHandler, false);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, loaderIoErrorHandler, false);
			_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderSecurityErrorHandler, false);
		}
		
		private function createEvent(type:String, assetData:* = null):AssetLoadingEvent
		{
			return new AssetLoadingEvent(type, _assetIdentification.id, _assetIdentification.locale, _assetType, _monitoring, assetData, _allowInternalCache);
		}
		
		private function createErrorEvent(type:String, message:String = null):AssetLoadingErrorEvent
		{
			return new AssetLoadingErrorEvent(type, _assetIdentification.id, _assetIdentification.locale, _assetType, _monitoring, message);
		}
		
		private function loaderInitHandler(event:LoaderEvent):void
		{
			dispatchEvent(createEvent(AssetLoadingEvent.INIT, event.data));
		}
		
		private function loaderOpenHandler(event:LoaderEvent):void
		{
			createLoadingMonitoring(event.latency);
			dispatchEvent(createEvent(AssetLoadingEvent.OPEN, event.data));
		}
		
		private function loaderProgressHandler(event:ProgressEvent):void
		{
			loaderProgress(event.bytesTotal, event.bytesLoaded);
		}
		
		private function loaderProgress(bytesTotal:int, bytesLoaded:int):void
		{
			_monitoring.update(bytesTotal, bytesLoaded);
			dispatchEvent(createEvent(AssetLoadingEvent.PROGRESS));
			
		}
		
		private function loaderCompleteHandler(event:LoaderEvent):void
		{
			loaderProgress(_monitoring.bytesTotal, _monitoring.bytesTotal);
			dispatchEvent(createEvent(AssetLoadingEvent.COMPLETE, event.data));
		}
		
		private function loaderCanceledHandler(event:LoaderEvent):void
		{
			dispatchEvent(createEvent(AssetLoadingEvent.CANCELED, _monitoring));
		}
		
		private function loaderStoppedHandler(event:LoaderEvent):void
		{
			dispatchEvent(createEvent(AssetLoadingEvent.STOPPED));
		}
		
		private function loaderHttpStatusHandler(event:HTTPStatusEvent):void
		{
			var $event:AssetLoadingEvent = createEvent(AssetLoadingEvent.HTTP_STATUS);
			$event.httpStatus = event.status;
			dispatchEvent($event);
		}
		
		private function loaderIoErrorHandler(event:IOErrorEvent):void
		{
			dispatchEvent(createErrorEvent(AssetLoadingErrorEvent.IO_ERROR, event.text));
		}
		
		private function loaderSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			dispatchEvent(createErrorEvent(AssetLoadingErrorEvent.SECURITY_ERROR, event.text));
		}
		
	}

}