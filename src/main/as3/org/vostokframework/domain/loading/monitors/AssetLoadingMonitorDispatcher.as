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
package org.vostokframework.domain.loading.monitors
{
	import org.as3collections.IMap;
	import org.as3utils.StringUtil;
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.domain.loading.events.AssetLoadingErrorEvent;
	import org.vostokframework.domain.loading.events.AssetLoadingEvent;

	/**
	 * @author Flavio
	 * @version 1.0
	 * @created 14-mai-2011 12:02:52
	 */
	public class AssetLoadingMonitorDispatcher extends LoadingMonitorDispatcher
	{
		/**
		 * @private
		 */
		private var _assetId:String;
		private var _assetLocale:String;
		private var _assetType:AssetType;
		
		/**
		 * 
		 */
		public function AssetLoadingMonitorDispatcher(assetId:String, assetLocale:String, assetType:AssetType)
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (StringUtil.isBlank(assetLocale)) throw new ArgumentError("Argument <assetLocale> must not be null nor an empty String.");
			if (!assetType) throw new ArgumentError("Argument <assetType> must not be null.");
			
			_assetId = assetId;
			_assetLocale = assetLocale;
			_assetType = assetType;
		}
		
		override public function dispatchCanceledEvent(monitoring:LoadingMonitoring):void
		{
			dispatchEvent(createEvent(AssetLoadingEvent.CANCELED, monitoring));
		}
		
		override public function dispatchCompleteEvent(monitoring:LoadingMonitoring, data:* = null):void
		{
			dispatchEvent(createEvent(AssetLoadingEvent.COMPLETE, monitoring, data));
		}
		
		override public function dispatchFailedEvent(monitoring:LoadingMonitoring, errors:IMap):void
		{
			dispatchEvent(createErrorEvent(AssetLoadingErrorEvent.FAILED, monitoring, errors));
		}
		
		override public function dispatchHttpStatusEvent(monitoring:LoadingMonitoring, status:int):void
		{
			var event:AssetLoadingEvent = createEvent(AssetLoadingEvent.HTTP_STATUS, monitoring);
			event.httpStatus = status;
			dispatchEvent(event);
		}
		
		override public function dispatchInitEvent(monitoring:LoadingMonitoring, data:* = null):void
		{
			dispatchEvent(createEvent(AssetLoadingEvent.INIT, monitoring, data));
		}
		
		override public function dispatchOpenEvent(monitoring:LoadingMonitoring, data:* = null):void
		{
			dispatchEvent(createEvent(AssetLoadingEvent.OPEN, monitoring, data));
		}
		
		override public function dispatchProgressEvent(monitoring:LoadingMonitoring):void
		{
			dispatchEvent(createEvent(AssetLoadingEvent.PROGRESS, monitoring));
		}
		
		override public function dispatchStoppedEvent(monitoring:LoadingMonitoring):void
		{
			dispatchEvent(createEvent(AssetLoadingEvent.STOPPED, monitoring));
		}
		
		override public function typeBelongs(type:String):Boolean
		{
			return AssetLoadingEvent.typeBelongs(type);
		}
		
		private function createEvent(type:String, monitoring:LoadingMonitoring, data:* = null):AssetLoadingEvent
		{
			return new AssetLoadingEvent(type, _assetId, _assetLocale, _assetType, monitoring, data);
		}
		
		private function createErrorEvent(type:String, monitoring:LoadingMonitoring, errors:IMap):AssetLoadingErrorEvent
		{
			return new AssetLoadingErrorEvent(type, _assetId, _assetLocale, _assetType, errors, monitoring);
		}
		
	}

}