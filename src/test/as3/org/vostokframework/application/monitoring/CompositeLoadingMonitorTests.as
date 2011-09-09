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

package org.vostokframework.application.monitoring
{
	import mockolate.mock;
	import mockolate.stub;
	import mockolate.verify;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.events.LoaderEvent;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class CompositeLoadingMonitorTests extends LoadingMonitorTests
	{
		
		public function CompositeLoadingMonitorTests()
		{
			
		}
		
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		override protected function getMonitor(loader:ILoader, dispatcher:LoadingMonitorDispatcher):ILoadingMonitor
		{
			return new CompositeLoadingMonitor(loader, dispatcher);
		}
		
		////////////////////////
		// ASYNC TEST HELPERS //
		////////////////////////
		
		private function verifyMockDispatcher(event:Event = null, passThroughData:Object = null):void
		{
			passThroughData = null;
			verify(mockDispatcher);
		}
		
		private function assertMonitoringPercent(event:Event = null, passThroughData:Object = null):void
		{
			//using * here in case that "percent" is sent incorrect
			//so it will prevent casting to 0 (zero)
			//and passing tests that in fact wait for zero
			var expectedPercent:* = passThroughData["percent"];
			Assert.assertEquals(expectedPercent, monitor.monitoring.percent);
		}
		
		///////////////////////////////////////////////
		// LoadingMonitor().addEventListener() TESTS //
		///////////////////////////////////////////////
		
		private function helperListener(event:Event):void
		{
			
		}
		
		[Test]
		public function addEventListener_loadingDispatcherReturnsFalseForTypeBelongs_shouldForwardsCallToChildMonitor(): void
		{
			stub(mockDispatcher).method("typeBelongs").anyArgs().returns(false);
			
			var eventType:String = "EVENT_NAME";
			var eventListener:Function = helperListener;
			var useCapture:Boolean = false;
			var priority:int = 0;
			var weakReference:Boolean = true;
			
			var mockChild:ILoadingMonitor = getFakeMonitor("loader-1");
			mock(mockChild).method("addEventListener").args(eventType, eventListener, useCapture, priority, weakReference);
			
			monitor.addChild(mockChild);
			monitor.addEventListener(eventType, eventListener, useCapture, priority, weakReference);
			
			verify(mockChild);
		}
		
		[Test(async, timeout=500)]
		public function addEventListener_stubLoaderDispatchesOpenEvent_mustCallMockDispatcher(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN));
			mock(mockDispatcher).method("dispatchProgressEvent");
			
			fakeLoader.load();
			
			var timer:Timer = new Timer(300, 1);
			
			var asyncHandler:Function = Async.asyncHandler(this, verifyMockDispatcher, 500);
			timer.addEventListener(TimerEvent.TIMER, asyncHandler, false, 0, true);
			
			timer.start();
		}
		
		[Test(async, timeout=500)]
		public function addEventListener_monitorWithOneChild_stubLoaderDispatchesOpenEvent_mustCallMockDispatcher_checkIfMonitoringPercentIs25(): void
		{
			var fakeMonitoring:LoadingMonitoring = new LoadingMonitoring(50);
			fakeMonitoring.update(200, 50);
			
			var fakeChild:ILoadingMonitor = getFakeMonitor("loader-1");
			stub(fakeChild).getter("monitoring").returns(fakeMonitoring);
			monitor.addChild(fakeChild);
			
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN));
			fakeLoader.load();
			
			var timer:Timer = new Timer(300, 1);
			
			var asyncHandler:Function = Async.asyncHandler(this, assertMonitoringPercent, 500, {percent:25});
			timer.addEventListener(TimerEvent.TIMER, asyncHandler, false, 0, true);
			
			timer.start();
		}
		
		[Test(async, timeout=500)]
		public function addEventListener_monitorWithThreeChild_stubLoaderDispatchesOpenEvent_mustCallMockDispatcher_checkIfMonitoringPercentIs100(): void
		{
			var fakeMonitoring1:LoadingMonitoring = new LoadingMonitoring(50);
			var fakeMonitoring2:LoadingMonitoring = new LoadingMonitoring(50);
			var fakeMonitoring3:LoadingMonitoring = new LoadingMonitoring(50);
			
			fakeMonitoring1.update(1260, 1260);
			fakeMonitoring2.update(395, 395);
			fakeMonitoring3.update(900, 900);
			
			var fakeChild1:ILoadingMonitor = getFakeMonitor("loader-1");
			var fakeChild2:ILoadingMonitor = getFakeMonitor("loader-2");
			var fakeChild3:ILoadingMonitor = getFakeMonitor("loader-3");
			
			stub(fakeChild1).getter("monitoring").returns(fakeMonitoring1);
			stub(fakeChild2).getter("monitoring").returns(fakeMonitoring2);
			stub(fakeChild3).getter("monitoring").returns(fakeMonitoring3);
			
			monitor.addChild(fakeChild1);
			monitor.addChild(fakeChild2);
			monitor.addChild(fakeChild3);
			
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN));
			fakeLoader.load();
			
			var timer:Timer = new Timer(300, 1);
			
			var asyncHandler:Function = Async.asyncHandler(this, assertMonitoringPercent, 500, {percent:100});
			timer.addEventListener(TimerEvent.TIMER, asyncHandler, false, 0, true);
			
			timer.start();
		}
		
		[Test(async, timeout=500)]
		public function addEventListener_monitorWithThreeChild_stubLoaderDispatchesOpenEvent_mustCallMockDispatcher_checkIfMonitoringPercentIsZero(): void
		{
			var fakeMonitoring1:LoadingMonitoring = new LoadingMonitoring(50);
			var fakeMonitoring2:LoadingMonitoring = new LoadingMonitoring(50);
			var fakeMonitoring3:LoadingMonitoring = new LoadingMonitoring(50);
			
			fakeMonitoring1.update(0, 0);
			fakeMonitoring2.update(395, 0);
			fakeMonitoring3.update(900, 0);
			
			var fakeChild1:ILoadingMonitor = getFakeMonitor("loader-1");
			var fakeChild2:ILoadingMonitor = getFakeMonitor("loader-2");
			var fakeChild3:ILoadingMonitor = getFakeMonitor("loader-3");
			
			stub(fakeChild1).getter("monitoring").returns(fakeMonitoring1);
			stub(fakeChild2).getter("monitoring").returns(fakeMonitoring2);
			stub(fakeChild3).getter("monitoring").returns(fakeMonitoring3);
			
			monitor.addChild(fakeChild1);
			monitor.addChild(fakeChild2);
			monitor.addChild(fakeChild3);
			
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN));
			fakeLoader.load();
			
			var timer:Timer = new Timer(300, 1);
			
			var asyncHandler:Function = Async.asyncHandler(this, assertMonitoringPercent, 500, {percent:0});
			timer.addEventListener(TimerEvent.TIMER, asyncHandler, false, 0, true);
			
			timer.start();
		}
		
		[Test(async, timeout=500)]
		public function addEventListener_monitorWithThreeChild_stubLoaderDispatchesOpenEvent_mustCallMockDispatcher_checkIfMonitoringPercentIs72(): void
		{
			var fakeMonitoring1:LoadingMonitoring = new LoadingMonitoring(50);
			var fakeMonitoring2:LoadingMonitoring = new LoadingMonitoring(50);
			var fakeMonitoring3:LoadingMonitoring = new LoadingMonitoring(50);
			
			fakeMonitoring1.update(2365, 1909);
			fakeMonitoring2.update(860, 0);
			fakeMonitoring3.update(1475, 1475);
			
			var fakeChild1:ILoadingMonitor = getFakeMonitor("loader-1");
			var fakeChild2:ILoadingMonitor = getFakeMonitor("loader-2");
			var fakeChild3:ILoadingMonitor = getFakeMonitor("loader-3");
			
			stub(fakeChild1).getter("monitoring").returns(fakeMonitoring1);
			stub(fakeChild2).getter("monitoring").returns(fakeMonitoring2);
			stub(fakeChild3).getter("monitoring").returns(fakeMonitoring3);
			
			monitor.addChild(fakeChild1);
			monitor.addChild(fakeChild2);
			monitor.addChild(fakeChild3);
			
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN));
			fakeLoader.load();
			
			var timer:Timer = new Timer(300, 1);
			
			var asyncHandler:Function = Async.asyncHandler(this, assertMonitoringPercent, 500, {percent:72});
			timer.addEventListener(TimerEvent.TIMER, asyncHandler, false, 0, true);
			
			timer.start();
		}
		
	}

}