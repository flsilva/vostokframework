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
package org.vostokframework.application.events
{
	import org.as3collections.IList;
	import org.vostokframework.application.monitoring.LoadingMonitoring;
	import org.vostokframework.domain.assets.AssetType;

	import flash.events.ErrorEvent;
	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoadingErrorEvent extends ErrorEvent
	{
		public static const FAILED:String = "VostokFramework.AssetLoadingErrorEvent.FAILED";
		
		/**
		 * description
		 */
		private var _assetId:String;
		private var _assetLocale:String;
		private var _assetType:AssetType;
		private var _errors:IList;
		private var _httpStatus:int;
		private var _monitoring:LoadingMonitoring;
		
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
		public function get errors(): IList { return _errors; }
		
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
		public function AssetLoadingErrorEvent(type:String, assetId:String, assetLocale:String, assetType:AssetType, errors:IList, monitoring:LoadingMonitoring = null)
		{
			super(type);
			
			_assetId = assetId;
			_assetLocale = assetLocale;
			_assetType = assetType;
			_errors = errors;
			_monitoring = monitoring;
		}
		
		override public function clone():Event
		{
			return new AssetLoadingErrorEvent(type, _assetId, _assetLocale, _assetType, _errors, _monitoring);
		}
		
	}

}