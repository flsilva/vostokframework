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
	import org.as3utils.StringUtil;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.assetmanagement.domain.AssetIdentification;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.StatefulLoader;
	import org.vostokframework.loadingmanagement.domain.events.AggregateQueueLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.AssetLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.QueueLoadingEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class AggregateQueueLoadingMonitorTests
	{
		private static const AGGREGATE_QUEUE_ID:String = "aggregate-queue-id";
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(inject="false")]
		public var _aggregateQueueLoader:StatefulLoader;
		
		private var _monitor:ILoadingMonitor;
		
		public var _queueLoader1:StatefulLoader;
		public var _queueLoader2:StatefulLoader;
		
		private var _queueLoadingMonitor1:ILoadingMonitor;
		private var _queueLoadingMonitor2:ILoadingMonitor;
		
		private var _stubAssetLoadingMonitor1:StubAssetLoadingMonitor;
		private var _stubAssetLoadingMonitor2:StubAssetLoadingMonitor;
		
		public function AggregateQueueLoadingMonitorTests()
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
			
			_queueLoader1 = getQueueLoader("queue-1", LoadPriority.MEDIUM, 3);
			_queueLoader2 = getQueueLoader("queue-2", LoadPriority.LOW, 3);
			
			_queueLoadingMonitor1 = getQueueLoadingMonitor(_queueLoader1, new ArrayList([_stubAssetLoadingMonitor1]));
			_queueLoadingMonitor2 = getQueueLoadingMonitor(_queueLoader2, new ArrayList([_stubAssetLoadingMonitor2]));
			
			//_queueLoadingMonitor1 = getQueueLoadingMonitor("queue-1");
			//_queueLoadingMonitor2 = getQueueLoadingMonitor("queue-2");
			
			var monitors:IList = new ArrayList();
			monitors.add(_queueLoadingMonitor1);
			monitors.add(_queueLoadingMonitor2);
			
			_aggregateQueueLoader = getQueueLoader(AGGREGATE_QUEUE_ID, LoadPriority.MEDIUM, 3);
			_monitor = getAggregateQueueLoadingMonitor(_aggregateQueueLoader, monitors);
		}
		
		[After]
		public function tearDown(): void
		{
			_aggregateQueueLoader = null;
			_monitor = null;
			
			_stubAssetLoadingMonitor1 = null;
			_stubAssetLoadingMonitor2 = null;
			
			_queueLoadingMonitor1 = null;
			_queueLoadingMonitor2 = null;
			
			_queueLoader1 = null;
			_queueLoader2 = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		protected function getAssetLoadingMonitor(id:String, locale:String = null):StubAssetLoadingMonitor
		{
			if (StringUtil.isEmpty(locale)) locale = VostokFramework.CROSS_LOCALE_ID;
			
			var identification:AssetIdentification = new AssetIdentification(id, locale);
			return new StubAssetLoadingMonitor(identification);
		}
		
		protected function getAggregateQueueLoadingMonitor(loader:StatefulLoader, monitors:IList):QueueLoadingMonitor
		{
			return new AggregateQueueLoadingMonitor(loader, monitors);
		}
		
		protected function getQueueLoadingMonitor(loader:StatefulLoader, monitors:IList):QueueLoadingMonitor
		//protected function getQueueLoadingMonitor(id:String):StubQueueLoadingMonitor
		{
			return new QueueLoadingMonitor(loader, monitors);
			//return new StubQueueLoadingMonitor(id);
		}
		
		protected function getQueueLoader(id:String, priority:LoadPriority, maxAttempts:int):StatefulLoader
		{
			var queueLoader:StatefulLoader = nice(StatefulLoader, null, [id, priority, maxAttempts]);
			stub(queueLoader).getter("id").returns(id);
			stub(queueLoader).asEventDispatcher();
			
			return queueLoader;
		}
		
		protected function createAssetLoadingEvent(type:String, fake:StubAssetLoadingMonitor):AssetLoadingEvent
		{
			return new AssetLoadingEvent(type, fake.assetId, fake.assetLocale, AssetType.XML, fake.monitoring);
		}
		
		protected function createQueueLoadingEvent(type:String, fake:ILoadingMonitor):QueueLoadingEvent
		{
			return new QueueLoadingEvent(type, fake.id, fake.monitoring);
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidNullLoaderArgument_ThrowsError(): void
		{
			new AggregateQueueLoadingMonitor(null, null);
		}
		
		/////////////////////////////////////////////////////////////
		// AggregateQueueLoadingMonitor().addEventListener() TESTS //
		/////////////////////////////////////////////////////////////
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent(): void
		{
			stub(_aggregateQueueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			Async.proceedOnEvent(this, _monitor, AggregateQueueLoadingEvent.OPEN, 200, asyncTimeoutHandler);
			_aggregateQueueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfQueueIdOfEventMatches(): void
		{
			stub(_aggregateQueueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			_monitor.addEventListener(AggregateQueueLoadingEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 200,
														{propertyName:"queueId", propertyValue:AGGREGATE_QUEUE_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			_aggregateQueueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfLatencyIsGreaterThanZero(): void
		{
			stub(_aggregateQueueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN, null, 10), 50);
			_monitor.addEventListener(AggregateQueueLoadingEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero, 200,
														null, asyncTimeoutHandler),
									false, 0, true);
			
			_aggregateQueueLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubQueueMonitorDispatchesOpenEvent_mustBeAbleToCatchStubEventThroughMonitorListener(): void
		{
			Async.proceedOnEvent(this, _monitor, QueueLoadingEvent.OPEN, 200, asyncTimeoutHandler);
			
			var event:QueueLoadingEvent = createQueueLoadingEvent(QueueLoadingEvent.OPEN, _queueLoadingMonitor1);
			_queueLoadingMonitor1.dispatchEvent(event);
		}
		
		[Test(async)]
		public function addEventListener_stubAssetMonitorDispatchesOpenEvent_mustBeAbleToCatchStubEventThroughMonitorListener(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingEvent.OPEN, 200, asyncTimeoutHandler);
			
			var event:AssetLoadingEvent = createAssetLoadingEvent(AssetLoadingEvent.OPEN, _stubAssetLoadingMonitor1);
			_stubAssetLoadingMonitor1.asyncDispatchEvent(event, 50);
		}
		
		[Test(async)]
		public function addEventListener_stubAssetMonitorDispatchesInitEvent_mustBeAbleToCatchStubEventThroughMonitorListener(): void
		{
			Async.proceedOnEvent(this, _monitor, AssetLoadingEvent.INIT, 200, asyncTimeoutHandler);
			
			var event:AssetLoadingEvent = createAssetLoadingEvent(AssetLoadingEvent.INIT, _stubAssetLoadingMonitor2);
			_stubAssetLoadingMonitor2.asyncDispatchEvent(event, 50);
		}
		
		[Test(async, timeout=2000)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent(): void
		{
			stub(_aggregateQueueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			Async.proceedOnEvent(this, _monitor, AggregateQueueLoadingEvent.PROGRESS, 1000, asyncTimeoutHandler);
			_aggregateQueueLoader.load();
		}
		/*
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_fakeControlledMonitoringBytes_mustCatchStubEventAndStartTimerDispatchesOwnProgressEvent_checkIfMonitoringPercentIs100(): void
		{
			_monitor.addEventListener(AggregateQueueLoadingEvent.PROGRESS,
									Async.asyncHandler(this, monitorEventHandlerCheckMonitoringProperty, 200,
														{propertyName:"percent", propertyValue:100},
														asyncTimeoutHandler),
									false, 0, true);
			
			stub(_queueLoader1).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			stub(_queueLoader2).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			
			_queueLoader1.load();
			_queueLoader2.load();
			
			_queueLoadingMonitor1.monitoring.update(1260, 1260);
			_queueLoadingMonitor2.monitoring.update(395, 395);
			
			stub(_aggregateQueueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			_aggregateQueueLoader.load();
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
		*/
		public function monitorEventHandlerCheckEventProperty(event:AggregateQueueLoadingEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event[passThroughData["propertyName"]]);
		}
		
		public function monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero(event:AggregateQueueLoadingEvent, passThroughData:Object):void
		{
			Assert.assertTrue(event.monitoring.latency > 0);
			passThroughData = null;
		}
		
		public function monitorEventHandlerCheckMonitoringProperty(event:AggregateQueueLoadingEvent, passThroughData:Object):void
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