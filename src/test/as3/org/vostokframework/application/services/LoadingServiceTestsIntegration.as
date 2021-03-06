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

package org.vostokframework.application.services
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
	import org.vostokframework.application.LoadingContext;
	import org.vostokframework.application.events.AssetLoadingEvent;
	import org.vostokframework.application.events.GlobalLoadingEvent;
	import org.vostokframework.application.events.QueueLoadingEvent;

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
			
			LoadingContext.getInstance().globalQueueLoadingMonitor.removeEventListener(AssetLoadingEvent.OPEN, assetLoadingCompleteHandler, false);
			LoadingContext.getInstance().globalQueueLoadingMonitor.removeEventListener(QueueLoadingEvent.OPEN, queueLoadingCompleteHandler, false);
			LoadingContext.getInstance().globalQueueLoadingMonitor.removeEventListener(GlobalLoadingEvent.OPEN, globalQueueLoadingCompleteHandler, false);
			
			LoadingContext.getInstance().globalQueueLoadingMonitor.removeEventListener(AssetLoadingEvent.COMPLETE, assetLoadingCompleteHandler, false);
			LoadingContext.getInstance().globalQueueLoadingMonitor.removeEventListener(QueueLoadingEvent.COMPLETE, queueLoadingCompleteHandler, false);
			LoadingContext.getInstance().globalQueueLoadingMonitor.removeEventListener(GlobalLoadingEvent.COMPLETE, globalQueueLoadingCompleteHandler, false);
			
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
		
		private function globalQueueLoadingCompleteHandler(event:GlobalLoadingEvent):void
		{
			helperTestObject.test(GlobalLoadingEvent);
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
			turnOnDataLoaderSuccessBehaviorAsync();
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingContext.getInstance().globalQueueLoadingMonitor, GlobalLoadingEvent.OPEN, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesQueueOpenEvent(): void
		{
			turnOnDataLoaderSuccessBehaviorAsync();
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingContext.getInstance().globalQueueLoadingMonitor, QueueLoadingEvent.OPEN, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesAssetOpenEvent(): void
		{
			turnOnDataLoaderSuccessBehaviorAsync();
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingContext.getInstance().globalQueueLoadingMonitor, AssetLoadingEvent.OPEN, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		///////////////////////////////////////////////
		// globalQueueLoadingMonitor PROGRESS events //
		///////////////////////////////////////////////
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesGlobalProgressEvent(): void
		{
			turnOnDataLoaderSuccessBehaviorAsync();
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingContext.getInstance().globalQueueLoadingMonitor, GlobalLoadingEvent.PROGRESS, 1000, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesQueueProgressEvent(): void
		{
			turnOnDataLoaderSuccessBehaviorAsync();
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingContext.getInstance().globalQueueLoadingMonitor, QueueLoadingEvent.PROGRESS, 1000, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesAssetProgressEvent(): void
		{
			turnOnDataLoaderSuccessBehaviorAsync();
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingContext.getInstance().globalQueueLoadingMonitor, AssetLoadingEvent.PROGRESS, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		///////////////////////////////////////////////
		// globalQueueLoadingMonitor COMPLETE events //
		///////////////////////////////////////////////
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesGlobalCompleteEvent(): void
		{
			turnOnDataLoaderSuccessBehaviorAsync();
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingContext.getInstance().globalQueueLoadingMonitor, GlobalLoadingEvent.COMPLETE, 1000, asyncTimeoutHandler);
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesQueueCompleteEvent(): void
		{
			turnOnDataLoaderSuccessBehaviorAsync();
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingContext.getInstance().globalQueueLoadingMonitor, QueueLoadingEvent.COMPLETE, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesAssetCompleteEvent(): void
		{
			turnOnDataLoaderSuccessBehaviorAsync();
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingContext.getInstance().globalQueueLoadingMonitor, AssetLoadingEvent.COMPLETE, 500, asyncTimeoutHandler);
			
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
			turnOnDataLoaderSuccessBehaviorAsync();
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			helperTestObject = nice(HelperTestObject);
			
			var seq:Sequence = sequence();
			mock(helperTestObject).method("test").args(AssetLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(QueueLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(GlobalLoadingEvent).once().ordered(seq);
			
			LoadingContext.getInstance().globalQueueLoadingMonitor.addEventListener(AssetLoadingEvent.OPEN, assetLoadingCompleteHandler, false, 0, true);
			LoadingContext.getInstance().globalQueueLoadingMonitor.addEventListener(QueueLoadingEvent.OPEN, queueLoadingCompleteHandler, false, 0, true);
			LoadingContext.getInstance().globalQueueLoadingMonitor.addEventListener(GlobalLoadingEvent.OPEN, globalQueueLoadingCompleteHandler, false, 0, true);
			
			var asyncHandler:Function = Async.asyncHandler(this, verifyHelperTestObject, 1000);
			timer.addEventListener(TimerEvent.TIMER, asyncHandler, false, 0, true);
			
			timer.delay = 500;
			timer.start();
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesCompleteEventsInCorrectOrder(): void
		{
			turnOnDataLoaderSuccessBehaviorAsync();
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			helperTestObject = nice(HelperTestObject);
			
			var seq:Sequence = sequence();
			mock(helperTestObject).method("test").args(AssetLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(QueueLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(GlobalLoadingEvent).once().ordered(seq);
			
			LoadingContext.getInstance().globalQueueLoadingMonitor.addEventListener(AssetLoadingEvent.COMPLETE, assetLoadingCompleteHandler, false, 0, true);
			LoadingContext.getInstance().globalQueueLoadingMonitor.addEventListener(QueueLoadingEvent.COMPLETE, queueLoadingCompleteHandler, false, 0, true);
			LoadingContext.getInstance().globalQueueLoadingMonitor.addEventListener(GlobalLoadingEvent.COMPLETE, globalQueueLoadingCompleteHandler, false, 0, true);
			
			var asyncHandler:Function = Async.asyncHandler(this, verifyHelperTestObject, 1000);
			timer.addEventListener(TimerEvent.TIMER, asyncHandler, false, 0, true);
			
			timer.delay = 900;
			timer.start();
			
			service.load(QUEUE_ID, list);
		}
		
	}

}