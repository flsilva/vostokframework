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
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.assetmanagement.AssetType;
	import org.vostokframework.loadingmanagement.LoadPriority;
	import org.vostokframework.loadingmanagement.PlainLoader;
	import org.vostokframework.loadingmanagement.RefinedLoader;
	import org.vostokframework.loadingmanagement.events.AssetLoadingMonitorEvent;
	import org.vostokframework.loadingmanagement.events.LoaderEvent;

	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=999999)]
	public class AssetLoadingMonitorTests
	{
		private static const ASSET_ID:String = "asset-id";
		private static const ASSET_TYPE:AssetType = AssetType.IMAGE;
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(inject="false")]
		public var loader:RefinedLoader;
		
		public var monitor:AssetLoadingMonitor;
		
		public function AssetLoadingMonitorTests()
		{
			
		}
		
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			loader = getNiceLoader();
			monitor = getMonitor(loader);
		}
		
		[After]
		public function tearDown(): void
		{
			loader = null;
			monitor = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getMonitor(loader:PlainLoader): AssetLoadingMonitor
		{
			return new AssetLoadingMonitor(ASSET_ID, ASSET_TYPE, loader);
		}
		
		public function getNiceLoader():RefinedLoader
		{
			var loader:RefinedLoader = nice(RefinedLoader, null, ["loader-id", LoadPriority.MEDIUM, 3]);
			stub(loader).asEventDispatcher();
			return loader;
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
		
		[Test(async, timeout=2000)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingMonitorEvent.OPEN, 1000, asyncTimeoutHandler);
			loader.load();
		}
		
		[Test(async, timeout=2000)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfAssetIdOfEventMatches(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			monitor.addEventListener(AssetLoadingMonitorEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent_checkIfLatencyIsGreaterThanZero(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			monitor.addEventListener(AssetLoadingMonitorEvent.OPEN,
									Async.asyncHandler(this, monitorEventHandlerCheckIfMonitoringLatencyGreaterThanZero, 1000,
														null, asyncTimeoutHandler),
									false, 0, true);
			
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesInitEvent_mustCatchStubEventAndDispatchOwnInitEvent(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.INIT), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingMonitorEvent.INIT, 1000, asyncTimeoutHandler);
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesProgressEvent_mustCatchStubEventAndDispatchOwnProgressEvent(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50)
				.dispatches(new ProgressEvent(ProgressEvent.PROGRESS), 100);
			
			Async.proceedOnEvent(this, monitor, AssetLoadingMonitorEvent.PROGRESS, 1000, asyncTimeoutHandler);
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesProgressEventWithControlledBytes_mustCatchStubEventAndDispatchOwnProgressEvent_checkIfMonitoringPercentMatches(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50)
				.dispatches(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 50, 200), 100);
			
			monitor.addEventListener(AssetLoadingMonitorEvent.PROGRESS,
									Async.asyncHandler(this, monitorEventHandlerCheckMonitoringProperty, 1000,
														{propertyName:"percent", propertyValue:25},
														asyncTimeoutHandler),
									false, 0, true);
			
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCompleteEvent_mustCatchStubEventAndDispatchOwnCompleteEvent(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50)
				.dispatches(new LoaderEvent(LoaderEvent.COMPLETE, {}), 100);
			
			Async.proceedOnEvent(this, monitor, AssetLoadingMonitorEvent.COMPLETE, 1000, asyncTimeoutHandler);
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCompleteEventWithGenericAssetData_mustCatchStubEventAndDispatchOwnCompleteEvent_checkIfAssetDataIsValidGenericObject(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50)
				.dispatches(new LoaderEvent(LoaderEvent.COMPLETE, {}), 100);
			
			monitor.addEventListener(AssetLoadingMonitorEvent.COMPLETE,
									Async.asyncHandler(this, monitorEventHandlerCheckAssetData, 200,
														null, asyncTimeoutHandler),
									false, 0, true);
			
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesHttpStatusEvent_mustCatchStubEventAndDispatchOwnHttpStatusEvent(): void
		{
			stub(loader).method("load").dispatches(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingMonitorEvent.HTTP_STATUS, 1000, asyncTimeoutHandler);
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesHttpStatusEventWithControlledStatusValue_mustCatchStubEventAndDispatchOwnHttpStatusEvent_checkIfStatusValueMatches(): void
		{
			stub(loader).method("load").dispatches(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS, false, false, 404), 50);
			monitor.addEventListener(AssetLoadingMonitorEvent.HTTP_STATUS,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"httpStatus", propertyValue:404},
														asyncTimeoutHandler),
									false, 0, true);
			
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesIoErrorEvent_mustCatchStubEventAndDispatchOwnIoErrorEvent(): void
		{
			stub(loader).method("load").dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingMonitorEvent.IO_ERROR, 1000, asyncTimeoutHandler);
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesIoErrorEventWithControlledMessage_mustCatchStubEventAndDispatchOwnIoErrorEvent_checkIfErrorMessageMatches(): void
		{
			stub(loader).method("load").dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "IO Error Test Text"), 50);
			monitor.addEventListener(AssetLoadingMonitorEvent.IO_ERROR,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"ioErrorMessage", propertyValue:"IO Error Test Text"},
														asyncTimeoutHandler),
									false, 0, true);
			
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesSecurityErrorEvent_mustCatchStubEventAndDispatchOwnSecurityErrorEvent(): void
		{
			stub(loader).method("load").dispatches(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingMonitorEvent.SECURITY_ERROR, 1000, asyncTimeoutHandler);
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesSecurityErrorEventWithControlledMessage_mustCatchStubEventAndDispatchOwnSecurityErrorEvent_checkIfErrorMessageMatches(): void
		{
			stub(loader).method("load").dispatches(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, "Security Error Test Text"), 50);
			monitor.addEventListener(AssetLoadingMonitorEvent.SECURITY_ERROR,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"securityErrorMessage", propertyValue:"Security Error Test Text"},
														asyncTimeoutHandler),
									false, 0, true);
			
			
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCanceledEvent_mustCatchStubEventAndDispatchOwnCanceledEvent(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.CANCELED), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingMonitorEvent.CANCELED, 1000, asyncTimeoutHandler);
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesCanceledEvent_mustCatchStubEventAndDispatchOwnCanceledEvent_checkIfAssetIdMatches(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.CANCELED), 50);
			monitor.addEventListener(AssetLoadingMonitorEvent.CANCELED,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesStoppedEvent_mustCatchStubEventAndDispatchOwnStoppedEvent(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.STOPPED), 50);
			Async.proceedOnEvent(this, monitor, AssetLoadingMonitorEvent.STOPPED, 200, asyncTimeoutHandler);
			loader.load();
		}
		
		[Test(async)]
		public function addEventListener_stubDispatchesStoppedEvent_mustCatchStubEventAndDispatchOwnStoppedEvent_checkIfAssetIdMatches(): void
		{
			stub(loader).method("load").dispatches(new LoaderEvent(LoaderEvent.STOPPED), 50);
			monitor.addEventListener(AssetLoadingMonitorEvent.STOPPED,
									Async.asyncHandler(this, monitorEventHandlerCheckEventProperty, 1000,
														{propertyName:"assetId", propertyValue:ASSET_ID},
														asyncTimeoutHandler),
									false, 0, true);
			
			loader.load();
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