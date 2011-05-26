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
	import org.vostokframework.loadingmanagement.assetloaders.VostokLoaderStub;
	import org.vostokframework.loadingmanagement.events.AssetLoadingMonitorEvent;
	import org.vostokframework.loadingmanagement.events.FileLoaderEvent;

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;

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
		
		public function AssetLoadingMonitorTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_fileLoader = new VostokLoaderStub();
			_monitor = new AssetLoadingMonitor(ASSET_ID, ASSET_TYPE, _fileLoader);
		}
		
		[After]
		public function tearDown(): void
		{
			_fileLoader = null;
			_monitor = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidArguments1_ThrowsError(): void
		{
			new AssetLoadingMonitor(null, null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidArguments2_ThrowsError(): void
		{
			new AssetLoadingMonitor("id", null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidArguments3_ThrowsError(): void
		{
			new AssetLoadingMonitor(null, AssetType.SWF, null);
		}
		
		//////////////////////////////////////
		// AssetLoadingMonitor Events TESTS //
		//////////////////////////////////////
		
		[Test(async)]
		public function dispatchEvent_stubDispatchOpen_OPEN(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandler, 200,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.load();
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
		}
		
		[Test(async)]
		public function dispatchEvent_stubDispatchInit_INIT(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.INIT, 200, asyncTimeoutHandler);
			_fileLoader.load();
			_fileLoader.asyncDispatchEvent(new Event(Event.INIT), 50);
		}

		[Test(async)]
		public function dispatchEvent_stubDispatchOpenCheckLatency_GreaterThanZero(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckLatency, 200,
														null, asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.load();
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
		}
		
		[Test(async)]
		public function dispatchEvent_stubDispatchProgress_PROGRESS(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.PROGRESS,
									Async.asyncHandler(this, monitorEventHandlerCheckMonitoring, 200,
														{propertyName:"percent", propertyValue:25},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.load();
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
			_fileLoader.asyncDispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 50, 200), 100);
		}
		
		[Test(async)]
		public function dispatchEvent_stubDispatchOpen_COMPLETE(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.COMPLETE,
									Async.asyncHandler(this, monitorEventHandlerCheckAssetData, 200,
														null, asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.load();
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
			_fileLoader.asyncDispatchEvent(new FileLoaderEvent(FileLoaderEvent.COMPLETE, {}), 100);
		}
		
		[Test(async)]
		public function dispatchEvent_stubDispatchHttpStatus_HTTP_STATUS(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.HTTP_STATUS,
									Async.asyncHandler(this, monitorEventHandler, 200,
														{propertyName:"httpStatus", propertyValue:404},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS, false, false, 404), 50);
		}
		
		[Test(async)]
		public function dispatchEvent_stubDispatchIoError_IO_ERROR(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.IO_ERROR,
									Async.asyncHandler(this, monitorEventHandler, 200,
														{propertyName:"ioErrorMessage", propertyValue:"IO Error Test Text"},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "IO Error Test Text"), 50);
		}
		
		[Test(async)]
		public function dispatchEvent_stubDispatchSecurityError_SECURITY_ERROR(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.SECURITY_ERROR,
									Async.asyncHandler(this, monitorEventHandler, 200,
														{propertyName:"securityErrorMessage", propertyValue:"Security Error Test Text"},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, "Security Error Test Text"), 50);
		}
		
		[Test(async)]
		public function dispatchEvent_stubDispatchCancel_CANCELED(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.CANCELED,
									Async.asyncHandler(this, monitorEventHandler, 200,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.cancel();
		}
		
		[Test(async)]
		public function dispatchEvent_stubDispatchCancel_STOPPED(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.STOPPED,
									Async.asyncHandler(this, monitorEventHandler, 200,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.stop();
		}

		public function monitorEventHandler(event:AssetLoadingMonitorEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event[passThroughData["propertyName"]]);
		}
		
		public function monitorEventHandlerCheckLatency(event:AssetLoadingMonitorEvent, passThroughData:Object):void
		{
			Assert.assertTrue(event.monitoring.latency > 0);
			passThroughData = null;
		}
		
		public function monitorEventHandlerCheckMonitoring(event:AssetLoadingMonitorEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event.monitoring[passThroughData["propertyName"]]);
		}
		
		public function monitorEventHandlerCheckAssetData(event:AssetLoadingMonitorEvent, passThroughData:Object):void
		{
			Assert.assertNotNull(event.assetData);
			passThroughData = null;
		}
		
		public function asyncTimeoutHandler(passThroughData:Object):void
		{
			Assert.fail("Asynchronous Test Failed: Timeout");
			passThroughData = null;
		}
		
	}

}