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
package org.vostokframework.domain.loading.events
{
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.domain.loading.monitors.LoadingMonitoring;

	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoadingEvent extends Event
	{
		public static const CANCELED:String = "VostokFramework.AssetLoadingEvent.CANCELED";
		public static const COMPLETE:String = "VostokFramework.AssetLoadingEvent.COMPLETE";
		public static const HTTP_STATUS:String = "VostokFramework.AssetLoadingEvent.HTTP_STATUS";
		public static const INIT:String = "VostokFramework.AssetLoadingEvent.INIT";
		public static const OPEN:String = "VostokFramework.AssetLoadingEvent.OPEN";
		public static const PROGRESS:String = "VostokFramework.AssetLoadingEvent.PROGRESS";
		public static const STOPPED:String = "VostokFramework.AssetLoadingEvent.STOPPED";
		
		/**
		 * description
		 */
		private var _assetData:*;
		private var _assetId:String;
		private var _assetLocale:String;
		private var _assetType:AssetType;
		private var _httpStatus:int;
		private var _monitoring:LoadingMonitoring;
		
		/**
		 * description
		 */
		public function get assetData(): * { return _assetData; }

		/**
		 * description
		 */
		public function get assetId(): String { return _assetId; }
		
		/**
		 * description
		 */
		public function get assetLocale(): String { return _assetLocale; }
		
		/**
		 * description
		 */
		public function get assetType(): AssetType { return _assetType; }
		
		/**
		 * description
		 */
		public function get httpStatus(): int { return _httpStatus; }
		
		public function set httpStatus(value:int): void { _httpStatus = value; }
		
		/**
		 * description
		 */
		public function get monitoring(): LoadingMonitoring { return _monitoring; }
		
		/**
		 * description
		 * 
		 * @param assetId
		 * @param assetType
		 * @param monitoring
		 * @param assetData
		 */
		public function AssetLoadingEvent(type:String, assetId:String, assetLocale:String, assetType:AssetType, monitoring:LoadingMonitoring = null, assetData:* = null)
		{
			super(type);
			
			_assetId = assetId;
			_assetLocale = assetLocale;
			_assetType = assetType;
			_monitoring = monitoring;
			_assetData = assetData;
		}
		
		override public function clone():Event
		{
			return new AssetLoadingEvent(type, _assetId, _assetLocale, _assetType, _monitoring, _assetData);
		}
		
		public static function typeBelongs(type:String):Boolean
		{
			return type == CANCELED ||
			       type == COMPLETE ||
			       type == HTTP_STATUS ||
			       type == INIT ||
			       type == OPEN ||
			       type == PROGRESS ||
			       type == STOPPED;
		}
		
	}

}