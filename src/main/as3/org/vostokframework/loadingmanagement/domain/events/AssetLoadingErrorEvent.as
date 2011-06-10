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
package org.vostokframework.loadingmanagement.domain.events
{
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitoring;

	import flash.events.ErrorEvent;
	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoadingErrorEvent extends ErrorEvent
	{
		public static const IO_ERROR:String = "VostokFramework.AssetLoadingErrorEvent.IO_ERROR";
		public static const SECURITY_ERROR:String = "VostokFramework.AssetLoadingErrorEvent.SECURITY_ERROR";
		
		/**
		 * description
		 */
		private var _assetId:String;
		private var _assetType:AssetType;
		private var _httpStatus:int;
		private var _monitoring:LoadingMonitoring;
		
		/**
		 * description
		 */
		public function get assetId(): String { return _assetId; }
		
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
		 * @param message
		 */
		public function AssetLoadingErrorEvent(type:String, assetId:String, assetType:AssetType, monitoring:LoadingMonitoring = null, message:String = null)
		{
			super(type, false, false, message);
			
			_assetId = assetId;
			_assetType = assetType;
			_monitoring = monitoring;
		}
		
		override public function clone():Event
		{
			return new AssetLoadingEvent(type, _assetId, _assetType, _monitoring, text);
		}
		
	}

}