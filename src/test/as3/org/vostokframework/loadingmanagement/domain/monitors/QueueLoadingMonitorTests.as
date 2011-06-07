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

package org.vostokframework.loadingmanagement.domain.monitors
{
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.RefinedLoader;
	import org.vostokframework.loadingmanagement.domain.events.AssetLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.QueueLoadingEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=12)]
	public class QueueLoadingMonitorTests
	{
		private static const QUEUE_ID:String = "queue-id";
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(inject="false")]
		public var _queueLoader:RefinedLoader;
		
		private var _monitor:ILoadingMonitor;
		
		private var _stubAssetLoadingMonitor1:StubAssetLoadingMonitor;
		private var _stubAssetLoadingMonitor2:StubAssetLoadingMonitor;
		private var _stubAssetLoadingMonitor3:StubAssetLoadingMonitor;
		
		public function QueueLoadingMonitorTests()
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
			
			var monitors:IList = new ArrayList();
			monitors.add(_stubAssetLoadingMonitor1);
			monitors.add(_stubAssetLoadingMonitor2);
			monitors.add(_stubAssetLoadingMonitor3);
			
			_queueLoader = nice(RefinedLoader, null, [QUEUE_ID, LoadPriority.MEDIUM, 3]);
			stub(_queueLoader).getter("id").returns(QUEUE_ID);
			stub(_queueLoader).asEventDispatcher();
			_monitor = new QueueLoadingMonitor(_queueLoader, monitors);
		}
		
		[After]
		public function tearDown(): void
		{
			_monitor = null;
			_queueLoader = null;
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
		
		private function createLoadingEvent(type:String, fake:StubAssetLoadingMonitor):AssetLoadingEvent
		{
			return new AssetLoadingEvent(type, fake.assetId, AssetType.XML, fake.monitoring);
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
			stub(_queueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			Async.proceedOnEvent(this, _monitor, QueueLoadingEvent.OPEN, 200, asyncTimeoutHandler);
			_queueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfQueueIdOfEventMatches(): void
		{
			stub(_queueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			_monitor.addEventListener(QueueLoadingEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"queueId", propertyValue:QUEUE_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			_queueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfLatencyIsGreaterThanZero(): void
		{
			stub(_queueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			_monitor.addEventListener(QueueLoadingEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero, 200,
														null, asyncTimeoutHandler),
									false, 0, true);
			
			_queueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustBeAbleToCatchStubEventThroughMonitorListener(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingEvent.OPEN, 200, asyncTimeoutHandler);
			
			var event:AssetLoadingEvent = createLoadingEvent(AssetLoadingEvent.OPEN, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesInitEvent_mustBeAbleToCatchStubEventThroughMonitorListener(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingEvent.INIT, 200, asyncTimeoutHandler);
			
			var event:AssetLoadingEvent = createLoadingEvent(AssetLoadingEvent.INIT, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async, timeout=2000)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent(): void
		{
			stub(_queueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			Async.proceedOnEvent(this, _monitor, QueueLoadingEvent.PROGRESS, 1000, asyncTimeoutHandler);
			_queueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_fakeControlledMonitoringBytes_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent_checkIfMonitoringPercentIs100(): void
		{
			_monitor.addEventListener(QueueLoadingEvent.PROGRESS,
									Async.asyncHandler(this, monitorEventHandlerCheckMonitoringProperty, 200,
														{propertyName:"percent", propertyValue:100},
														asyncTimeoutHandler),
									false, 0, true);
			
			_stubAssetLoadingMonitor1.monitoring.update(1260, 1260);
			_stubAssetLoadingMonitor2.monitoring.update(395, 395);
			_stubAssetLoadingMonitor3.monitoring.update(900, 900);
			
			stub(_queueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			_queueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_fakeControlledMonitoringBytes_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent_checkIfMonitoringPercentIsZero(): void
		{
			_monitor.addEventListener(QueueLoadingEvent.PROGRESS,
									Async.asyncHandler(this, monitorEventHandlerCheckMonitoringProperty, 200,
														{propertyName:"percent", propertyValue:0},
														asyncTimeoutHandler),
									false, 0, true);
			
			_stubAssetLoadingMonitor1.monitoring.update(0, 0);
			_stubAssetLoadingMonitor2.monitoring.update(395, 0);
			_stubAssetLoadingMonitor3.monitoring.update(900, 0);
			
			stub(_queueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			_queueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_fakeControlledMonitoringBytes_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent_checkIfMonitoringPercentIs72(): void
		{
			_monitor.addEventListener(QueueLoadingEvent.PROGRESS,
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
			
			stub(_queueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			_queueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_fakeControlledMonitoringBytes_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent_checkIfMonitoringPercentIs75(): void
		{
			_monitor.addEventListener(QueueLoadingEvent.PROGRESS,
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
			
			stub(_queueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			_queueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesProgressEvent_mustBeAbleToCatchStubEventThroughMonitorListener(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingEvent.PROGRESS, 200, asyncTimeoutHandler);
			
			var event:AssetLoadingEvent = createLoadingEvent(AssetLoadingEvent.PROGRESS, _stubAssetLoadingMonitor3);
			_stubAssetLoadingMonitor3.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubsDispatchStatusChangedCompleteEvent_mustCatchStubEventsAndDispatchOwnCompleteEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, QueueLoadingEvent.COMPLETE, 200, asyncTimeoutHandler);
			
			stub(_queueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.COMPLETE), 50);
			_queueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubsDispatchStatusChangedCanceledEvent_mustCatchStubEventAndDispatchOwnCanceledEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, QueueLoadingEvent.CANCELED, 200, asyncTimeoutHandler);
			
			stub(_queueLoader).method("cancel").dispatches(new LoaderEvent(LoaderEvent.CANCELED), 50);
			_queueLoader.cancel();
		}
		
		[Test(async)]
		public function addEventListener_stubsDispatchStatusChangedCanceledEvent_mustCatchStubEventAndDispatchOwnCanceledEvent_checkIfRequestIdOfEventMatches(): void
		{
			_monitor.addEventListener(QueueLoadingEvent.CANCELED,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"queueId", propertyValue:QUEUE_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			stub(_queueLoader).method("cancel").dispatches(new LoaderEvent(LoaderEvent.CANCELED), 50);
			_queueLoader.cancel();
		}
		
		[Test(async)]
		public function addEventListener_stubsDispatchStatusChangedStoppedEvent_mustCatchStubEventAndDispatchOwnStoppedEvent(): void
		{
			Async.proceedOnEvent(this, _monitor, QueueLoadingEvent.STOPPED, 200, asyncTimeoutHandler);
			
			stub(_queueLoader).method("stop").dispatches(new LoaderEvent(LoaderEvent.STOPPED), 50);
			_queueLoader.stop();
		}
		
		public function monitorEventHandlerCheckEventProperty(event:QueueLoadingEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event[passThroughData["propertyName"]]);
		}
		
		public function monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero(event:QueueLoadingEvent, passThroughData:Object):void
		{
			Assert.assertTrue(event.monitoring.latency > 0);
			passThroughData = null;
		}
		
		public function monitorEventHandlerCheckMonitoringProperty(event:QueueLoadingEvent, passThroughData:Object):void
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