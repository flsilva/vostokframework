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
	import org.vostokframework.loadingmanagement.RequestLoaderStatus;
	import org.vostokframework.loadingmanagement.StubRequestLoader;
	import org.vostokframework.loadingmanagement.events.AssetLoadingMonitorEvent;
	import org.vostokframework.loadingmanagement.events.RequestLoaderEvent;
	import org.vostokframework.loadingmanagement.events.RequestLoadingMonitorEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=12)]
	public class RequestLoadingMonitorTests
	{
		
		private static const REQUEST_ID:String = "request-id";

		private var _monitor:ILoadingMonitor;
		private var _requestLoader:StubRequestLoader;
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
			
			_requestLoader = new StubRequestLoader(REQUEST_ID);
			_monitor = new RequestLoadingMonitor(_requestLoader, assetLoadingMonitors);
		}
		
		[After]
		public function tearDown(): void
		{
			_monitor = null;
			_requestLoader = null;
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
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.LOADING);
			_requestLoader.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfRequestIdOfEventMatches(): void
		{
			_monitor.addEventListener(RequestLoadingMonitorEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"requestId", propertyValue:REQUEST_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.LOADING);
			_requestLoader.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfLatencyIsGreaterThanZero(): void
		{
			_monitor.addEventListener(RequestLoadingMonitorEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero, 200,
														null, asyncTimeoutHandler),
									false, 0, true);
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.LOADING);
			_requestLoader.asyncDispatchEvent(event, 50);
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
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.LOADING);
			_requestLoader.asyncDispatchEvent(event, 50);
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
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.LOADING);
			_requestLoader.asyncDispatchEvent(event, 50);
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
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.LOADING);
			_requestLoader.asyncDispatchEvent(event, 50);
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
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.LOADING);
			_requestLoader.asyncDispatchEvent(event, 50);
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
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.LOADING);
			_requestLoader.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesProgressEvent_mustBeAbleToCatchStubEventThroughMonitorListener(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingMonitorEvent.PROGRESS, 200, asyncTimeoutHandler);
			
			var event:AssetLoadingMonitorEvent = createAssetLoadingMonitorEvent(AssetLoadingMonitorEvent.PROGRESS, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubsDispatchStatusChangedCompleteEvent_mustCatchStubEventsAndDispatchOwnCompleteEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, RequestLoadingMonitorEvent.COMPLETE, 200, asyncTimeoutHandler);
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.COMPLETE);
			_requestLoader.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubsDispatchStatusChangedCanceledEvent_mustCatchStubEventAndDispatchOwnCanceledEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, RequestLoadingMonitorEvent.CANCELED, 200, asyncTimeoutHandler);
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.CANCELED);
			_requestLoader.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubsDispatchStatusChangedCanceledEvent_mustCatchStubEventAndDispatchOwnCanceledEvent_checkIfRequestIdOfEventMatches(): void
		{
			_monitor.addEventListener(RequestLoadingMonitorEvent.CANCELED,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"requestId", propertyValue:REQUEST_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.CANCELED);
			_requestLoader.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubsDispatchStatusChangedStoppedEvent_mustCatchStubEventAndDispatchOwnStoppedEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, RequestLoadingMonitorEvent.STOPPED, 200, asyncTimeoutHandler);
			
			var event:RequestLoaderEvent = new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.STOPPED);
			_requestLoader.asyncDispatchEvent(event, 50);
		}
		
		
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
		
		public function asyncTimeoutHandler(passThroughData:Object):void
		{
			Assert.fail("Asynchronous Test Failed: Timeout");
			passThroughData = null;
		}
		
	}

}