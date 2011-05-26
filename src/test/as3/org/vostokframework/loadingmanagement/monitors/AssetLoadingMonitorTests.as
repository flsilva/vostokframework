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
		public function constructor_invalidAssetId_ThrowsError(): void
		{
			new AssetLoadingMonitor(null, null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidAssetType_ThrowsError(): void
		{
			new AssetLoadingMonitor("id", null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidLoader_ThrowsError(): void
		{
			new AssetLoadingMonitor("id", AssetType.SWF, null);
		}
		
		////////////////////////////////////////////////////
		// AssetLoadingMonitor().addEventListener() TESTS //
		////////////////////////////////////////////////////
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.OPEN, 200, asyncTimeoutHandler);
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfAssetIdOfEventMatches(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfLatencyIsGreaterThanZero(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero, 200,
														null, asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesInitEvent_mustCatchStubEventAndDispatchOwnInitEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.INIT, 200, asyncTimeoutHandler);
			_fileLoader.asyncDispatchEvent(new Event(Event.INIT), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesProgressEvent_mustCatchStubEventAndDispatchOwnProgressEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.PROGRESS, 200, asyncTimeoutHandler);
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
			_fileLoader.asyncDispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS), 100);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesProgressEventWithControlledBytes_mustCatchStubEventAndDispatchOwnProgressEvent_checkIfMonitoringPercentMatches(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.PROGRESS,
									Async.asyncHandler(this, monitorEventHandlerCheckMonitoringProperty, 200,
														{propertyName:"percent", propertyValue:25},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
			_fileLoader.asyncDispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 50, 200), 100);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCompleteEvent_mustCatchStubEventAndDispatchOwnCompleteEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.COMPLETE, 200, asyncTimeoutHandler);
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
			_fileLoader.asyncDispatchEvent(new FileLoaderEvent(FileLoaderEvent.COMPLETE, {}), 100);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCompleteEventWithGenericAssetData_mustCatchStubEventAndDispatchOwnCompleteEvent_checkIfAssetDataIsValidGenericObject(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.COMPLETE,
									Async.asyncHandler(this, monitorEventHandlerCheckAssetData, 200,
														null, asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
			_fileLoader.asyncDispatchEvent(new FileLoaderEvent(FileLoaderEvent.COMPLETE, {}), 100);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesHttpStatusEvent_mustCatchStubEventAndDispatchOwnHttpStatusEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.HTTP_STATUS, 200, asyncTimeoutHandler);
			_fileLoader.asyncDispatchEvent(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesHttpStatusEventWithControlledStatusValue_mustCatchStubEventAndDispatchOwnHttpStatusEvent_checkIfStatusValueMatches(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.HTTP_STATUS,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"httpStatus", propertyValue:404},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS, false, false, 404), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesIoErrorEvent_mustCatchStubEventAndDispatchOwnIoErrorEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.IO_ERROR, 200, asyncTimeoutHandler);
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesIoErrorEventWithControlledMessage_mustCatchStubEventAndDispatchOwnIoErrorEvent_checkIfErrorMessageMatches(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.IO_ERROR,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"ioErrorMessage", propertyValue:"IO Error Test Text"},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "IO Error Test Text"), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesSecurityErrorEvent_mustCatchStubEventAndDispatchOwnSecurityErrorEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.SECURITY_ERROR, 200, asyncTimeoutHandler);
			_fileLoader.asyncDispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesSecurityErrorEventWithControlledMessage_mustCatchStubEventAndDispatchOwnSecurityErrorEvent_checkIfErrorMessageMatches(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.SECURITY_ERROR,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"securityErrorMessage", propertyValue:"Security Error Test Text"},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, "Security Error Test Text"), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCanceledEvent_mustCatchStubEventAndDispatchOwnCanceledEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.CANCELED, 200, asyncTimeoutHandler);
			_fileLoader.asyncDispatchEvent(new FileLoaderEvent(FileLoaderEvent.CANCELED), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCanceledEvent_mustCatchStubEventAndDispatchOwnCanceledEvent_checkIfAssetIdMatches(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.CANCELED,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new FileLoaderEvent(FileLoaderEvent.CANCELED), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesStoppedEvent_mustCatchStubEventAndDispatchOwnStoppedEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.STOPPED, 200, asyncTimeoutHandler);
			_fileLoader.asyncDispatchEvent(new FileLoaderEvent(FileLoaderEvent.STOPPED), 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesStoppedEvent_mustCatchStubEventAndDispatchOwnStoppedEvent_checkIfAssetIdMatches(): void
		{
			_monitor.addEventListener(AssetLoadingMonitorEvent.STOPPED,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			_fileLoader.asyncDispatchEvent(new FileLoaderEvent(FileLoaderEvent.STOPPED), 50);
		}

		public function monitorEventHandlerCheckEventProperty(event:AssetLoadingMonitorEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event[passThroughData["propertyName"]]);
		}
		
		public function monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero(event:AssetLoadingMonitorEvent, passThroughData:Object):void
		{
			Assert.assertTrue(event.monitoring.latency > 0);
			passThroughData = null;
		}
		
		public function monitorEventHandlerCheckMonitoringProperty(event:AssetLoadingMonitorEvent, passThroughData:Object):void
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