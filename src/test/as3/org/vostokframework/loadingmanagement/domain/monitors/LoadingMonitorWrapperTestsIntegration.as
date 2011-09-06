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

	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.loadingmanagement.domain.ILoader;
	import org.vostokframework.loadingmanagement.domain.events.GlobalLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.AssetLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.QueueLoadingEvent;

	import flash.events.Event;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingMonitorWrapperTestsIntegration
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(inject="false")]
		public var globalLoader:ILoader;
		
		[Mock(inject="false")]
		public var queueLoader:ILoader;
		
		[Mock(inject="false")]
		public var assetLoader:ILoader;
		
		public var wrapper:ILoadingMonitor;
		public var globalMonitor:ILoadingMonitor;
		public var queueMonitor:ILoadingMonitor;
		public var assetMonitor:ILoadingMonitor;
		
		public function LoadingMonitorWrapperTestsIntegration()
		{
			
		}
		
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			globalMonitor = getGlobalMonitor("global-loader-1");
			wrapper = new LoadingMonitorWrapper(globalMonitor);
		}
		
		[After]
		public function tearDown(): void
		{
			globalMonitor = null;
			queueMonitor = null;
			assetMonitor = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		protected function getFakeLoader(id:String):ILoader
		{
			var loader:ILoader = nice(ILoader);
			stub(loader).asEventDispatcher();
			stub(loader).getter("identification").returns(new VostokIdentification(id, VostokFramework.CROSS_LOCALE_ID));
			
			return loader;
		}
		
		protected function getGlobalMonitor(loaderId:String):ILoadingMonitor
		{
			globalLoader = getFakeLoader(loaderId);
			queueLoader = getFakeLoader("queue-id");
			assetLoader = getFakeLoader("asset-id");
			
			var globalDispatcher:LoadingMonitorDispatcher = new GlobalLoadingMonitorDispatcher(loaderId, VostokFramework.CROSS_LOCALE_ID);
			var queueDispatcher:LoadingMonitorDispatcher = new QueueLoadingMonitorDispatcher("queue-id", VostokFramework.CROSS_LOCALE_ID);
			var assetDispatcher:LoadingMonitorDispatcher = new AssetLoadingMonitorDispatcher("asset-id", VostokFramework.CROSS_LOCALE_ID, AssetType.SWF);
			
			var globalMonitor:ILoadingMonitor = new CompositeLoadingMonitor(globalLoader, globalDispatcher);
			queueMonitor = new CompositeLoadingMonitor(queueLoader, queueDispatcher);
			assetMonitor = new LoadingMonitor(assetLoader, assetDispatcher);
			
			queueMonitor.addChild(assetMonitor);
			globalMonitor.addChild(queueMonitor);
			
			return globalMonitor;
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
		
		[Test(async, timeout=200)]
		public function addEventListener_stubAssetLoaderDispatchesCompleteEvent_mustBeAbleToCatchAssetLoadingMonitorEvent(): void
		{
			stub(assetLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.COMPLETE));
			
			Async.proceedOnEvent(this, wrapper, AssetLoadingEvent.COMPLETE, 200);
			
			assetLoader.load();
		}
		
		[Test(async, timeout=200)]
		public function addEventListener_stubQueueLoaderDispatchesCompleteEvent_mustBeAbleToCatchQueueLoadingMonitorEvent(): void
		{
			stub(queueLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.COMPLETE));
			
			Async.proceedOnEvent(this, wrapper, QueueLoadingEvent.COMPLETE, 200);
			
			queueLoader.load();
		}
		
		[Test(async, timeout=200)]
		public function addEventListener_stubGlobalLoaderDispatchesCompleteEvent_mustBeAbleToCatchGlobalLoadingMonitorEvent(): void
		{
			stub(globalLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.COMPLETE));
			
			Async.proceedOnEvent(this, wrapper, GlobalLoadingEvent.COMPLETE, 200);
			
			globalLoader.load();
		}
		
		///////////////////////////////////////////////
		// LoadingMonitor().changeMonitor() TESTS //
		///////////////////////////////////////////////
		
		[Test]
		public function changeMonitor_callsAddEventListenerThenChangesMonitorThenCallsHasEventListener_ReturnsTrue(): void
		{
			var eventType:String = AssetLoadingEvent.COMPLETE;
			var eventListener:Function = helperListener;
			var useCapture:Boolean = false;
			var priority:int = 0;
			var weakReference:Boolean = true;
			
			wrapper.addEventListener(eventType, eventListener, useCapture, priority, weakReference);
			
			var globalMonitor2:ILoadingMonitor = getGlobalMonitor("global-loader-2");
			(wrapper as LoadingMonitorWrapper).changeMonitor(globalMonitor2);
			
			var hasEventListener:Boolean = wrapper.hasEventListener(eventType);
			Assert.assertTrue(hasEventListener);
		}
		
		[Test]
		public function changeMonitor_callsAddEventListenerThenCallRemoveEventListenerThenChangesMonitorThenCallsHasEventListener_ReturnsFalse(): void
		{
			var eventType:String = AssetLoadingEvent.COMPLETE;
			var eventListener:Function = helperListener;
			var useCapture:Boolean = false;
			var priority:int = 0;
			var weakReference:Boolean = true;
			
			wrapper.addEventListener(eventType, eventListener, useCapture, priority, weakReference);
			wrapper.removeEventListener(eventType, eventListener, useCapture);
			
			var globalMonitor2:ILoadingMonitor = getGlobalMonitor("global-loader-2");
			(wrapper as LoadingMonitorWrapper).changeMonitor(globalMonitor2);
			
			var hasEventListener:Boolean = wrapper.hasEventListener(eventType);
			Assert.assertFalse(hasEventListener);
		}
		
		///////////////////////////////////////////////
		// LoadingMonitor().hasEventListener() TESTS //
		///////////////////////////////////////////////
		
		[Test]
		public function hasEventListener_notAddedListener_ReturnsFalse(): void
		{
			var hasEventListener:Boolean = wrapper.hasEventListener(AssetLoadingEvent.COMPLETE);
			Assert.assertFalse(hasEventListener);
		}
		
		[Test]
		public function hasEventListener_notAddedListener_ReturnsTrue(): void
		{
			var eventType:String = AssetLoadingEvent.COMPLETE;
			var eventListener:Function = helperListener;
			var useCapture:Boolean = false;
			var priority:int = 0;
			var weakReference:Boolean = true;
			
			wrapper.addEventListener(eventType, eventListener, useCapture, priority, weakReference);
			
			var hasEventListener:Boolean = wrapper.hasEventListener(eventType);
			Assert.assertTrue(hasEventListener);
		}
		
		[Test]
		public function hasEventListener_addedButRemovedListener_ReturnsFalse(): void
		{
			var eventType:String = AssetLoadingEvent.COMPLETE;
			var eventListener:Function = helperListener;
			var useCapture:Boolean = false;
			var priority:int = 0;
			var weakReference:Boolean = true;
			
			wrapper.addEventListener(eventType, eventListener, useCapture, priority, weakReference);
			wrapper.removeEventListener(eventType, eventListener, useCapture);
			
			var hasEventListener:Boolean = wrapper.hasEventListener(eventType);
			Assert.assertFalse(hasEventListener);
		}

		private function helperListener(event:Event):void
		{
			
		}
		
	}

}