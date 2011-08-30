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

package org.vostokframework.loadingmanagement.services
{
	import mockolate.ingredients.Sequence;
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.sequence;
	import mockolate.verify;

	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.HelperTestObject;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.events.AggregateQueueLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.AssetLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.QueueLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.StubVostokLoaderFactory;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsIntegration extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE_ID:String = "queue-1";
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(inject="false")]
		public var helperTestObject:HelperTestObject;
		
		public var timer:Timer;
		
		public function LoadingServiceTestsIntegration()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		override public function setUp(): void
		{
			super.setUp();
			
			timer = new Timer(500);
			
		}
		
		[After]
		override public function tearDown(): void
		{
			super.tearDown();
			
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.removeEventListener(AssetLoadingEvent.OPEN, assetLoadingCompleteHandler, false);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.removeEventListener(QueueLoadingEvent.OPEN, queueLoadingCompleteHandler, false);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.removeEventListener(AggregateQueueLoadingEvent.OPEN, globalQueueLoadingCompleteHandler, false);
			
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.removeEventListener(AssetLoadingEvent.COMPLETE, assetLoadingCompleteHandler, false);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.removeEventListener(QueueLoadingEvent.COMPLETE, queueLoadingCompleteHandler, false);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.removeEventListener(AggregateQueueLoadingEvent.COMPLETE, globalQueueLoadingCompleteHandler, false);
			
			timer.stop();
			
			helperTestObject = null;
			timer = null;
		}
		
		/////////////////////
		// EVENT LISTENERS //
		/////////////////////
		
		private function assetLoadingCompleteHandler(event:AssetLoadingEvent):void
		{
			helperTestObject.test(AssetLoadingEvent);
		}
		
		private function queueLoadingCompleteHandler(event:QueueLoadingEvent):void
		{
			helperTestObject.test(QueueLoadingEvent);
		}
		
		private function globalQueueLoadingCompleteHandler(event:AggregateQueueLoadingEvent):void
		{
			helperTestObject.test(AggregateQueueLoadingEvent);
		}
		
		private function asyncTimeoutHandler(passThroughData:Object):void
		{
			Assert.fail("Asynchronous Test Failed: Timeout");
			passThroughData = null;
		}
		
		///////////////////////////////////////////
		// globalQueueLoadingMonitor OPEN events //
		///////////////////////////////////////////
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesGlobalOpenEvent(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AggregateQueueLoadingEvent.OPEN, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesQueueOpenEvent(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, QueueLoadingEvent.OPEN, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesAssetOpenEvent(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AssetLoadingEvent.OPEN, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		///////////////////////////////////////////////
		// globalQueueLoadingMonitor PROGRESS events //
		///////////////////////////////////////////////
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesGlobalProgressEvent(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AggregateQueueLoadingEvent.PROGRESS, 1000, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesQueueProgressEvent(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, QueueLoadingEvent.PROGRESS, 1000, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesAssetProgressEvent(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AssetLoadingEvent.PROGRESS, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		///////////////////////////////////////////////
		// globalQueueLoadingMonitor COMPLETE events //
		///////////////////////////////////////////////
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesGlobalCompleteEvent(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AggregateQueueLoadingEvent.COMPLETE, 1000, asyncTimeoutHandler);
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesQueueCompleteEvent(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, QueueLoadingEvent.COMPLETE, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesAssetCompleteEvent(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AssetLoadingEvent.COMPLETE, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		/////////////////////////////////////////////
		// globalQueueLoadingMonitor other events ///
		/////////////////////////////////////////////
		
		private function verifyHelperTestObject(event:Event, passThroughData:Object):void
		{
			passThroughData = null;
			verify(helperTestObject);
		}
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesOpenEventsInCorrectOrder(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			helperTestObject = nice(HelperTestObject);
			
			var seq:Sequence = sequence();
			mock(helperTestObject).method("test").args(AssetLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(QueueLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(AggregateQueueLoadingEvent).once().ordered(seq);
			
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AssetLoadingEvent.OPEN, assetLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(QueueLoadingEvent.OPEN, queueLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AggregateQueueLoadingEvent.OPEN, globalQueueLoadingCompleteHandler, false, 0, true);
			
			var asyncHandler:Function = Async.asyncHandler(this, verifyHelperTestObject, 1000);
			timer.addEventListener(TimerEvent.TIMER, asyncHandler, false, 0, true);
			
			timer.delay = 500;
			timer.start();
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesCompleteEventsInCorrectOrder(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			helperTestObject = nice(HelperTestObject);
			
			var seq:Sequence = sequence();
			mock(helperTestObject).method("test").args(AssetLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(QueueLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(AggregateQueueLoadingEvent).once().ordered(seq);
			
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AssetLoadingEvent.COMPLETE, assetLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(QueueLoadingEvent.COMPLETE, queueLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AggregateQueueLoadingEvent.COMPLETE, globalQueueLoadingCompleteHandler, false, 0, true);
			
			var asyncHandler:Function = Async.asyncHandler(this, verifyHelperTestObject, 1000);
			timer.addEventListener(TimerEvent.TIMER, asyncHandler, false, 0, true);
			
			timer.delay = 900;
			timer.start();
			
			service.load(QUEUE_ID, list);
		}
		
	}

}