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
	import org.as3utils.StringUtil;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.loadingmanagement.domain.PlainLoader;
	import org.vostokframework.loadingmanagement.domain.events.AssetLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;

	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.getTimer;

	/**
	 * @author Flavio
	 * @version 1.0
	 * @created 14-mai-2011 12:02:52
	 */
	public class AssetLoadingMonitor extends EventDispatcher implements ILoadingMonitor
	{
		private var _assetId:String;
		private var _assetType:AssetType;
		private var _loader:PlainLoader;
		private var _monitoring:LoadingMonitoring;
		private var _startedTimeConnecting:int;
		
		public function get monitoring():LoadingMonitoring { return _monitoring; }
		
		/**
		 * 
		 * @param assetId
		 * @param assetType
		 * @param loader
		 */
		public function AssetLoadingMonitor(assetId:String, assetType:AssetType, loader:PlainLoader)
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!assetType) throw new ArgumentError("Argument <assetType> must not be null.");
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			
			_assetId = assetId;
			_assetType = assetType;
			_loader = loader;
			
			addLoaderListeners();
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
			_loader.addEventListener(LoaderEvent.CONNECTING, loaderConnectingHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.INIT, loaderInitHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.OPEN, loaderOpenHandler, false, 0, true);
			_loader.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.CANCELED, loaderCanceledHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.STOPPED, loaderStoppedHandler, false, 0, true);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loaderHttpStatusHandler, false, 0, true);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, loaderIoErrorHandler, false, 0, true);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderSecurityErrorHandler, false, 0, true);
		}
		
		private function removeLoaderListeners():void
		{
			_loader.removeEventListener(LoaderEvent.CONNECTING, loaderConnectingHandler, false);
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
			return new AssetLoadingEvent(type, _assetId, _assetType, _monitoring, assetData);
		}
		
		private function loaderConnectingHandler(event:LoaderEvent):void
		{
			_startedTimeConnecting = getTimer();
		}
		
		private function loaderInitHandler(event:LoaderEvent):void
		{
			dispatchEvent(createEvent(AssetLoadingEvent.INIT, event.data));
		}
		
		private function loaderOpenHandler(event:LoaderEvent):void
		{
			var latency:int = getTimer() - _startedTimeConnecting;
			createLoadingMonitoring(latency);
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
			var $event:AssetLoadingEvent = createEvent(AssetLoadingEvent.IO_ERROR);
			$event.ioErrorMessage = event.text;
			dispatchEvent($event);
		}
		
		private function loaderSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			var $event:AssetLoadingEvent = createEvent(AssetLoadingEvent.SECURITY_ERROR);
			$event.securityErrorMessage = event.text;
			dispatchEvent($event);
		}
		
	}

}