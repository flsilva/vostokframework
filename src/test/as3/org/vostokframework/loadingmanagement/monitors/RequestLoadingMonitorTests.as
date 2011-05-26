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
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.assetmanagement.AssetType;
	import org.vostokframework.loadingmanagement.events.AssetLoadingMonitorEvent;
	import org.vostokframework.loadingmanagement.events.RequestLoadingMonitorEvent;

	import flash.events.Event;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=12)]
	public class RequestLoadingMonitorTests
	{
		
		private static const REQUEST_ID:String = "request-id";

		private var _monitor:ILoadingMonitor;
		private var _stubAssetLoadingMonitor1:StubAssetLoadingMonitor;
		private var _stubAssetLoadingMonitor2:StubAssetLoadingMonitor;
		private var _stubAssetLoadingMonitor3:StubAssetLoadingMonitor;
		
		public function RequestLoadingMonitorTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_stubAssetLoadingMonitor1 = getAssetLoadingMonitor("asset-1");
			_stubAssetLoadingMonitor2 = getAssetLoadingMonitor("asset-2");
			_stubAssetLoadingMonitor3 = getAssetLoadingMonitor("asset-3");
			
			var assetLoadingMonitors:IList = new ArrayList();
			assetLoadingMonitors.add(_stubAssetLoadingMonitor1);
			assetLoadingMonitors.add(_stubAssetLoadingMonitor2);
			assetLoadingMonitors.add(_stubAssetLoadingMonitor3);
			
			_monitor = new RequestLoadingMonitor(REQUEST_ID, assetLoadingMonitors);
		}
		
		[After]
		public function tearDown(): void
		{
			_monitor = null;
			_stubAssetLoadingMonitor1 = null;
			_stubAssetLoadingMonitor2 = null;
			_stubAssetLoadingMonitor3 = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		private function getAssetLoadingMonitor(id:String):StubAssetLoadingMonitor
		{
			return new StubAssetLoadingMonitor(id);
		}
		
		private function createAssetLoadingMonitorEvent(type:String, stub:StubAssetLoadingMonitor):AssetLoadingMonitorEvent
		{
			return new AssetLoadingMonitorEvent(type, stub.assetId, AssetType.XML, stub.monitoring);
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		/*
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
		*/
		////////////////////////////////////////////////////
		// AssetLoadingMonitor().addEventListener() TESTS //
		////////////////////////////////////////////////////
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, RequestLoadingMonitorEvent.OPEN, 200, asyncTimeoutHandler);
			
			var event:AssetLoadingMonitorEvent = createAssetLoadingMonitorEvent(AssetLoadingMonitorEvent.OPEN, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfAssetIdOfEventMatches(): void
		{
			_monitor.addEventListener(RequestLoadingMonitorEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"requestId", propertyValue:REQUEST_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			var event:AssetLoadingMonitorEvent = createAssetLoadingMonitorEvent(AssetLoadingMonitorEvent.OPEN, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfLatencyIsGreaterThanZero(): void
		{
			_monitor.addEventListener(RequestLoadingMonitorEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero, 200,
														null, asyncTimeoutHandler),
									false, 0, true);
			
			var event:AssetLoadingMonitorEvent = createAssetLoadingMonitorEvent(AssetLoadingMonitorEvent.OPEN, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustBeAbleToCatchStubEventThroughMonitorListener(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.OPEN, 200, asyncTimeoutHandler);
			
			var event:AssetLoadingMonitorEvent = createAssetLoadingMonitorEvent(AssetLoadingMonitorEvent.OPEN, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesInitEvent_mustBeAbleToCatchStubEventThroughMonitorListener(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.INIT, 200, asyncTimeoutHandler);
			
			var event:AssetLoadingMonitorEvent = createAssetLoadingMonitorEvent(AssetLoadingMonitorEvent.INIT, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, RequestLoadingMonitorEvent.PROGRESS, 200, asyncTimeoutHandler);
			
			var event:AssetLoadingMonitorEvent = createAssetLoadingMonitorEvent(AssetLoadingMonitorEvent.OPEN, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_fakeControlledMonitoringBytes_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent_checkIfMonitoringPercentIs100(): void
		{
			_monitor.addEventListener(RequestLoadingMonitorEvent.PROGRESS,
									Async.asyncHandler(this, monitorEventHandlerCheckMonitoringProperty, 200,
														{propertyName:"percent", propertyValue:100},
														asyncTimeoutHandler),
									false, 0, true);
			
			_stubAssetLoadingMonitor1.monitoring.update(1260, 1260);
			_stubAssetLoadingMonitor2.monitoring.update(395, 395);
			_stubAssetLoadingMonitor3.monitoring.update(900, 900);
			
			var event:AssetLoadingMonitorEvent = createAssetLoadingMonitorEvent(AssetLoadingMonitorEvent.OPEN, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_fakeControlledMonitoringBytes_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent_checkIfMonitoringPercentIsZero(): void
		{
			_monitor.addEventListener(RequestLoadingMonitorEvent.PROGRESS,
									Async.asyncHandler(this, monitorEventHandlerCheckMonitoringProperty, 200,
														{propertyName:"percent", propertyValue:0},
														asyncTimeoutHandler),
									false, 0, true);
			
			_stubAssetLoadingMonitor1.monitoring.update(0, 0);
			_stubAssetLoadingMonitor2.monitoring.update(395, 0);
			_stubAssetLoadingMonitor3.monitoring.update(900, 0);
			
			var event:AssetLoadingMonitorEvent = createAssetLoadingMonitorEvent(AssetLoadingMonitorEvent.OPEN, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_fakeControlledMonitoringBytes_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent_checkIfMonitoringPercentIs72(): void
		{
			_monitor.addEventListener(RequestLoadingMonitorEvent.PROGRESS,
									Async.asyncHandler(this, monitorEventHandlerCheckMonitoringProperty, 200,
														{propertyName:"percent", propertyValue:72},
														asyncTimeoutHandler),
									false, 0, true);
			
			//general bytesTotal: 4700
			//general bytesLoaded: 3384
			//general percent: 72%
			_stubAssetLoadingMonitor1.monitoring.update(2365, 1909);
			_stubAssetLoadingMonitor2.monitoring.update(860, 0);
			_stubAssetLoadingMonitor3.monitoring.update(1475, 1475);
			
			var event:AssetLoadingMonitorEvent = createAssetLoadingMonitorEvent(AssetLoadingMonitorEvent.OPEN, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_fakeControlledMonitoringBytes_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent_checkIfMonitoringPercentIs75(): void
		{
			_monitor.addEventListener(RequestLoadingMonitorEvent.PROGRESS,
									Async.asyncHandler(this, monitorEventHandlerCheckMonitoringProperty, 200,
														{propertyName:"percent", propertyValue:31},
														asyncTimeoutHandler),
									false, 0, true);
			
			//general bytesTotal: 1.089312 (with fake calculation for bytesTotal=0)
			//general bytesLoaded: 342929
			//general percent: 31%
			_stubAssetLoadingMonitor1.monitoring.update(725361, 342698);
			_stubAssetLoadingMonitor2.monitoring.update(0, 0);
			_stubAssetLoadingMonitor3.monitoring.update(847, 231);
			
			var event:AssetLoadingMonitorEvent = createAssetLoadingMonitorEvent(AssetLoadingMonitorEvent.OPEN, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		/*
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
		*/
		public function monitorEventHandlerCheckEventProperty(event:RequestLoadingMonitorEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event[passThroughData["propertyName"]]);
		}
		
		public function monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero(event:RequestLoadingMonitorEvent, passThroughData:Object):void
		{
			Assert.assertTrue(event.monitoring.latency > 0);
			passThroughData = null;
		}
		
		public function monitorEventHandlerCheckMonitoringProperty(event:RequestLoadingMonitorEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event.monitoring[passThroughData["propertyName"]]);
		}
		/*
		public function monitorEventHandlerCheckAssetData(event:RequestLoadingMonitorEvent, passThroughData:Object):void
		{
			Assert.assertNotNull(event.assetData);
			passThroughData = null;
		}
		*/
		public function asyncTimeoutHandler(passThroughData:Object):void
		{
			Assert.fail("Asynchronous Test Failed: Timeout");
			passThroughData = null;
		}
		
	}

}