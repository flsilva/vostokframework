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
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;

	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.StubLoadingAlgorithm;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingMonitorTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(inject="false")]
		public var fakeLoader:VostokLoader;
		
		[Mock(inject="false")]
		public var mockDispatcher:LoadingMonitorDispatcher;
		
		[Mock(inject="false")]
		public var fakeMonitor:ILoadingMonitor;//variable used only here to prepare mockolate
		
		public var monitor:ILoadingMonitor;
		
		public function LoadingMonitorTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			fakeLoader = getFakeLoader("loader-id");
			mockDispatcher = getFakeDispatcher();
			
			monitor = getMonitor(fakeLoader, mockDispatcher);
		}
		
		[After]
		public function tearDown(): void
		{
			fakeLoader = null;
			mockDispatcher = null;
			monitor = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		protected function getFakeDispatcher():LoadingMonitorDispatcher
		{
			return nice(LoadingMonitorDispatcher);
		}
		
		protected function getFakeLoader(id:String):VostokLoader
		{
			var loader:VostokLoader = nice(VostokLoader, null, [new VostokIdentification(id, VostokFramework.CROSS_LOCALE_ID), new StubLoadingAlgorithm(), LoadPriority.MEDIUM, 3]);
			stub(loader).asEventDispatcher();
			stub(loader).getter("identification").returns(new VostokIdentification(id, VostokFramework.CROSS_LOCALE_ID));
			
			return loader;
		}
		
		protected function getFakeMonitor():ILoadingMonitor
		{
			var fakeMonitor:ILoadingMonitor = nice(ILoadingMonitor);
			stub(fakeMonitor).getter("loader").returns(getFakeLoader("fake-monitor-loader"));
			
			return fakeMonitor;
		}
		
		protected function getMonitor(loader:VostokLoader, dispatcher:LoadingMonitorDispatcher):ILoadingMonitor
		{
			return new LoadingMonitor(loader, dispatcher);
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
		///////////////////////////////////////////////
		// LoadingMonitor().addEventListener() TESTS //
		///////////////////////////////////////////////
		[Test]
		public function addEventListener_stubLoaderDispatchesCompleteEvent_mustCatchStubLoaderEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.COMPLETE));
			mock(mockDispatcher).method("dispatchCompleteEvent");
			
			fakeLoader.load();
			
			verify(mockDispatcher);
		}
		
		[Test]
		public function addEventListener_stubLoaderDispatchesOpenEvent_mustCatchStubLoaderEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN));
			mock(mockDispatcher).method("dispatchOpenEvent");
			
			fakeLoader.load();
			
			verify(mockDispatcher);
		}
		
		/*
		[Test(async, timeout=2000)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingEvent.OPEN, 1000, asyncTimeoutHandler);
			fakeLoader.load();
		}
		
		[Test(async, timeout=2000)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfAssetIdOfEventMatches(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			monitor.addEventListener(AssetLoadingEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfLatencyIsGreaterThanZero(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN, null, 10), 50);
			monitor.addEventListener(AssetLoadingEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero, 1000,
														null, asyncTimeoutHandler),
									false, 0, true);

			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesInitEvent_mustCatchStubEventAndDispatchOwnInitEvent(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.INIT), 50);
			
			Async.proceedOnEvent(this, monitor, AssetLoadingEvent.INIT, 1000, asyncTimeoutHandler);
			fakeLoader.load();
		}
		
		[Test(async, timeout=1000)]
		public function addEventListener_stubDispatchesProgressEvent_mustCatchStubEventAndDispatchOwnProgressEvent(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50)
				.dispatches(new ProgressEvent(ProgressEvent.PROGRESS), 100);
			
			Async.proceedOnEvent(this, monitor, AssetLoadingEvent.PROGRESS, 1000, asyncTimeoutHandler);
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesProgressEventWithControlledBytes_mustCatchStubEventAndDispatchOwnProgressEvent_checkIfMonitoringPercentMatches(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50)
				.dispatches(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 50, 200), 100);
			
			monitor.addEventListener(AssetLoadingEvent.PROGRESS,
									Async.asyncHandler(this, monitorEventHandlerCheckMonitoringProperty, 1000,
														{propertyName:"percent", propertyValue:25},
														asyncTimeoutHandler),
									false, 0, true);
			
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCompleteEvent_mustCatchStubEventAndDispatchOwnCompleteEvent(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50)
				.dispatches(new LoaderEvent(LoaderEvent.COMPLETE, {}), 100);
			
			Async.proceedOnEvent(this, monitor, AssetLoadingEvent.COMPLETE, 1000, asyncTimeoutHandler);
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCompleteEventWithGenericAssetData_mustCatchStubEventAndDispatchOwnCompleteEvent_checkIfAssetDataIsValidGenericObject(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50)
				.dispatches(new LoaderEvent(LoaderEvent.COMPLETE, {}), 100);
			
			monitor.addEventListener(AssetLoadingEvent.COMPLETE,
									Async.asyncHandler(this, monitorEventHandlerCheckAssetData, 200,
														null, asyncTimeoutHandler),
									false, 0, true);
			
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesHttpStatusEvent_mustCatchStubEventAndDispatchOwnHttpStatusEvent(): void
		{
			stub(fakeLoader).method("load").dispatches(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingEvent.HTTP_STATUS, 1000, asyncTimeoutHandler);
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesHttpStatusEventWithControlledStatusValue_mustCatchStubEventAndDispatchOwnHttpStatusEvent_checkIfStatusValueMatches(): void
		{
			stub(fakeLoader).method("load").dispatches(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS, false, false, 404), 50);
			monitor.addEventListener(AssetLoadingEvent.HTTP_STATUS,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"httpStatus", propertyValue:404},
														asyncTimeoutHandler),
									false, 0, true);
			
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesIoErrorEvent_mustCatchStubEventAndDispatchOwnIoErrorEvent(): void
		{
			stub(fakeLoader).method("load").dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingErrorEvent.IO_ERROR, 1000, asyncTimeoutHandler);
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesIoErrorEventWithControlledMessage_mustCatchStubEventAndDispatchOwnIoErrorEvent_checkIfErrorMessageMatches(): void
		{
			stub(fakeLoader).method("load").dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "IO Error Test Text"), 50);
			monitor.addEventListener(AssetLoadingErrorEvent.IO_ERROR,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"text", propertyValue:"IO Error Test Text"},
														asyncTimeoutHandler),
									false, 0, true);
			
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesSecurityErrorEvent_mustCatchStubEventAndDispatchOwnSecurityErrorEvent(): void
		{
			stub(fakeLoader).method("load").dispatches(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingErrorEvent.SECURITY_ERROR, 1000, asyncTimeoutHandler);
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesSecurityErrorEventWithControlledMessage_mustCatchStubEventAndDispatchOwnSecurityErrorEvent_checkIfErrorMessageMatches(): void
		{
			stub(fakeLoader).method("load").dispatches(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, "Security Error Test Text"), 50);
			monitor.addEventListener(AssetLoadingErrorEvent.SECURITY_ERROR,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"text", propertyValue:"Security Error Test Text"},
														asyncTimeoutHandler),
									false, 0, true);
			
			
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCanceledEvent_mustCatchStubEventAndDispatchOwnCanceledEvent(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.CANCELED), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingEvent.CANCELED, 1000, asyncTimeoutHandler);
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCanceledEvent_mustCatchStubEventAndDispatchOwnCanceledEvent_checkIfAssetIdMatches(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.CANCELED), 50);
			monitor.addEventListener(AssetLoadingEvent.CANCELED,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesStoppedEvent_mustCatchStubEventAndDispatchOwnStoppedEvent(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.STOPPED), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingEvent.STOPPED, 200, asyncTimeoutHandler);
			fakeLoader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesStoppedEvent_mustCatchStubEventAndDispatchOwnStoppedEvent_checkIfAssetIdMatches(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.STOPPED), 50);
			monitor.addEventListener(AssetLoadingEvent.STOPPED,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			fakeLoader.load();
		}
		
		public function monitorEventHandlerCheckEventProperty(event:Event, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event[passThroughData["propertyName"]]);
		}
		
		public function monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero(event:AssetLoadingEvent, passThroughData:Object):void
		{
			Assert.assertTrue(event.monitoring.latency > 0);
			passThroughData = null;
		}
		
		public function monitorEventHandlerCheckMonitoringProperty(event:AssetLoadingEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event.monitoring[passThroughData["propertyName"]]);
		}
		
		public function monitorEventHandlerCheckAssetData(event:AssetLoadingEvent, passThroughData:Object):void
		{
			Assert.assertNotNull(event.assetData);
			passThroughData = null;
		}
		
		public function asyncTimeoutHandler(passThroughData:Object):void
		{
			Assert.fail("Asynchronous Test Failed: Timeout");
			passThroughData = null;
		}
		*/
	}

}