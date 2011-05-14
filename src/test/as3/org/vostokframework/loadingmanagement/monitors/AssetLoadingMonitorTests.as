/*
 * Licensed under the MIT License
 * 
 * Copyright 2010 (c) Flávio Silva, http://flsilva.com
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
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.assetmanagement.AssetType;
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoaderStatus;
	import org.vostokframework.loadingmanagement.assetloaders.VostokLoaderStub;
	import org.vostokframework.loadingmanagement.events.AssetLoadingMonitorEvent;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=12)]
	public class AssetLoadingMonitorTests
	{
		
		private static const ASSET_ID:String = "asset-id";
		private static const ASSET_TYPE:AssetType = AssetType.IMAGE;

		private var _fileLoader:VostokLoaderStub;
		private var _monitor:ILoadingMonitor;
		private var _timer:Timer;
		
		public function AssetLoadingMonitorTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_timer = new Timer(100, 1);
			
			_fileLoader = new VostokLoaderStub();
			_monitor = new AssetLoadingMonitor(ASSET_ID, ASSET_TYPE, _fileLoader);
		}
		
		[After]
		public function tearDown(): void
		{
			_timer.stop();
			_timer = null;
			_fileLoader = null;
			_monitor = null;
			//_event = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidArguments1_ThrowsError(): void
		{
			var monitor:ILoadingMonitor = new AssetLoadingMonitor(null, null, null);
			monitor = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidArguments2_ThrowsError(): void
		{
			var monitor:ILoadingMonitor = new AssetLoadingMonitor("id", null, null);
			monitor = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidArguments3_ThrowsError(): void
		{
			var monitor:ILoadingMonitor = new AssetLoadingMonitor(null, AssetType.SWF, null);
			monitor = null;
		}
		
		/////////////////////////////////////
		// AssetLoadingMonitor Events TESTS//
		/////////////////////////////////////
		
		[Test(async)]
		public function dispatchEvent_stubDispatchOpen_OPEN(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.OPEN,
									Async.asyncHandler(this, timerCompleteHandler, 100,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														timerTimeoutHandler),
									false, 0, true);
			
			_fileLoader.dispatchEvent(new Event(Event.OPEN));
		}
		
		public function timerCompleteHandler(event:AssetLoadingMonitorEvent, passThroughData:Object):void
		{
			Assert.assertEquals(event[passThroughData["propertyName"]], passThroughData["propertyValue"]);
		}
		
		public function timerTimeoutHandler(passThroughData:Object):void
		{
			Assert.fail("Asynchronous Test Failed: Timeout Handler");
			passThroughData = null;
		}
		
	}

}