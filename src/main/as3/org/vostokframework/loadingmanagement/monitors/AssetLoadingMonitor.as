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
	import org.as3utils.StringUtil;
	import org.vostokframework.assetmanagement.AssetType;
	import org.vostokframework.loadingmanagement.assetloaders.IFileLoader;
	import org.vostokframework.loadingmanagement.events.AssetLoadingMonitorEvent;
	import org.vostokframework.loadingmanagement.events.FileLoaderEvent;

	import flash.events.Event;
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
		private var _latency:int;
		private var _loader:IFileLoader;
		private var _monitoring:LoadingMonitoring;
		private var _startedTimeTryingToConnect:int;

		/**
		 * 
		 * @param assetId
		 * @param assetType
		 * @param loader
		 */
		public function AssetLoadingMonitor(assetId:String, assetType:AssetType, loader:IFileLoader)
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!assetType) throw new ArgumentError("Argument <assetType> must not be null.");
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			
			_assetId = assetId;
			_assetType = assetType;
			_loader = loader;
			
			addLoaderEvents();
		}
		
		protected function createLoadingMonitoring():void
		{
			_monitoring = new LoadingMonitoring(_latency);
		}
		
		private function addLoaderEvents():void
		{
			_loader.addEventListener(FileLoaderEvent.TRYING_TO_CONNECT, loaderTryingToConnectHandler, false, 0, true);
			_loader.addEventListener(Event.INIT, loaderInitHandler, false, 0, true);
			_loader.addEventListener(Event.OPEN, loaderOpenHandler, false, 0, true);
			_loader.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler, false, 0, true);
			_loader.addEventListener(FileLoaderEvent.COMPLETE, loaderCompleteHandler, false, 0, true);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loaderHttpStatusHandler, false, 0, true);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, loaderIoErrorHandler, false, 0, true);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderSecurityErrorHandler, false, 0, true);
		}
		
		private function createEvent(type:String, assetId:String, assetType:AssetType, monitoring:LoadingMonitoring = null, assetData:* = null):AssetLoadingMonitorEvent
		{
			return new AssetLoadingMonitorEvent(type, assetId, assetType, monitoring, assetData);
		}
		
		private function loaderTryingToConnectHandler(event:FileLoaderEvent):void
		{
			_startedTimeTryingToConnect = getTimer();
		}
		
		private function loaderInitHandler(event:Event):void
		{
			dispatchEvent(createEvent(AssetLoadingMonitorEvent.INIT, _assetId, _assetType));
		}
		
		private function loaderOpenHandler(event:Event):void
		{
			_latency = getTimer() - _startedTimeTryingToConnect;
			createLoadingMonitoring();
			dispatchEvent(createEvent(AssetLoadingMonitorEvent.OPEN, _assetId, _assetType, _monitoring));
		}
		
		private function loaderProgressHandler(event:ProgressEvent):void
		{
			loaderProgress(event.bytesTotal, event.bytesLoaded);
		}
		
		private function loaderProgress(bytesTotal:int, bytesLoaded:int):void
		{
			_monitoring.update(bytesTotal, bytesLoaded);
			dispatchEvent(createEvent(AssetLoadingMonitorEvent.PROGRESS, _assetId, _assetType, _monitoring));
			
		}
		
		private function loaderCompleteHandler(event:FileLoaderEvent):void
		{
			loaderProgress(_monitoring.bytesTotal, _monitoring.bytesTotal);
			dispatchEvent(createEvent(AssetLoadingMonitorEvent.COMPLETE, _assetId, _assetType, _monitoring, event.assetData));
		}
		
		private function loaderHttpStatusHandler(event:HTTPStatusEvent):void
		{
			var $event:AssetLoadingMonitorEvent = createEvent(AssetLoadingMonitorEvent.HTTP_STATUS, _assetId, _assetType, _monitoring);
			$event.httpStatus = event.status;
			dispatchEvent($event);
		}
		
		private function loaderIoErrorHandler(event:IOErrorEvent):void
		{
			var $event:AssetLoadingMonitorEvent = createEvent(AssetLoadingMonitorEvent.IO_ERROR, _assetId, _assetType, _monitoring);
			$event.ioErrorMessage = event.text;
			dispatchEvent($event);
		}
		
		private function loaderSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			var $event:AssetLoadingMonitorEvent = createEvent(AssetLoadingMonitorEvent.SECURITY_ERROR, _assetId, _assetType, _monitoring);
			$event.securityErrorMessage = event.text;
			dispatchEvent($event);
		}
		
	}

}