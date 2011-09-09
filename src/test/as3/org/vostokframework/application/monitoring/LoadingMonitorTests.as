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
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;

	import org.as3collections.IMap;
	import org.as3collections.maps.ArrayListMap;
	import org.as3collections.maps.HashMap;
	import org.flexunit.Assert;
	import org.hamcrest.core.anything;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.LoadError;
	import org.vostokframework.domain.loading.events.LoaderErrorEvent;
	import org.vostokframework.domain.loading.events.LoaderEvent;

	import flash.events.ProgressEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingMonitorTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(inject="false")]
		public var fakeLoader:ILoader;
		
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
		
		protected function getFakeLoader(id:String):ILoader
		{
			var loader:ILoader = nice(ILoader);
			stub(loader).asEventDispatcher();
			stub(loader).getter("identification").returns(new VostokIdentification(id, VostokFramework.CROSS_LOCALE_ID));
			
			return loader;
		}
		
		protected function getFakeMonitor(loaderId:String):ILoadingMonitor
		{
			var fakeMonitor:ILoadingMonitor = nice(ILoadingMonitor);
			stub(fakeMonitor).getter("loader").returns(getFakeLoader(loaderId));
			
			return fakeMonitor;
		}
		
		protected function getMonitor(loader:ILoader, dispatcher:LoadingMonitorDispatcher):ILoadingMonitor
		{
			return new LoadingMonitor(loader, dispatcher);
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		//TODO:constructor tests
		///////////////////////////////////////////////
		// LoadingMonitor().addEventListener() TESTS //
		///////////////////////////////////////////////
		
		[Test]
		public function addEventListener_stubLoaderDispatchesCanceledEvent_mustCatchStubLoaderEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("cancel").dispatches(new LoaderEvent(LoaderEvent.CANCELED));
			mock(mockDispatcher).method("dispatchCanceledEvent");
			
			fakeLoader.cancel();
			verify(mockDispatcher);
		}
		
		[Test]
		public function addEventListener_stubLoaderDispatchesCompleteEvent_mustCatchStubLoaderEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.COMPLETE));
			mock(mockDispatcher).method("dispatchCompleteEvent");
			
			fakeLoader.load();
			verify(mockDispatcher);
		}
		
		[Test]
		public function addEventListener_stubLoaderDispatchesCompleteEventWithControlledAssetDataValue_mustCatchStubLoaderEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.COMPLETE, "FakeAssetData"));
			mock(mockDispatcher).method("dispatchCompleteEvent").args(anything(), "FakeAssetData");
			
			fakeLoader.load();
			verify(mockDispatcher);
		}
		
		[Test]
		public function addEventListener_stubLoaderDispatchesFailedEvent_mustCatchStubLoaderEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderErrorEvent(LoaderErrorEvent.FAILED, new HashMap()));
			mock(mockDispatcher).method("dispatchFailedEvent");
			
			fakeLoader.load();
			verify(mockDispatcher);
		}
		
		[Test]
		public function addEventListener_stubLoaderDispatchesFailedEventWithControlledErrorMap_mustCatchStubEventAndCallMockDispatcherWithCorrectStatusValue(): void
		{
			var errors:IMap = new ArrayListMap();
			errors.put(LoadError.ASYNC_ERROR, "LoadError.ASYNC_ERROR");
			errors.put(LoadError.SECURITY_ERROR, "LoadError.SECURITY_ERROR");
			
			stub(fakeLoader).method("load").dispatches(new LoaderErrorEvent(LoaderErrorEvent.FAILED, errors));
			mock(mockDispatcher).method("dispatchFailedEvent").args(anything(), errors);
			
			fakeLoader.load();
			verify(mockDispatcher);
		}
		
		[Test]
		public function addEventListener_stubLoaderDispatchesHttpStatusEvent_mustCatchStubEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.HTTP_STATUS));
			mock(mockDispatcher).method("dispatchHttpStatusEvent");
			
			fakeLoader.load();
			verify(mockDispatcher);
		}
		
		[Test]
		public function addEventListener_stubLoaderDispatchesHttpStatusEventWithControlledStatusValue_mustCatchStubEventAndCallMockDispatcherWithCorrectStatusValue(): void
		{
			var event:LoaderEvent = new LoaderEvent(LoaderEvent.HTTP_STATUS);
			event.httpStatus = 404;
			
			stub(fakeLoader).method("load").dispatches(event);
			mock(mockDispatcher).method("dispatchHttpStatusEvent").args(anything(), 404);
			
			fakeLoader.load();
			verify(mockDispatcher);
		}
		
		[Test]
		public function addEventListener_stubLoaderDispatchesInitEvent_mustCatchStubLoaderEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.INIT));
			mock(mockDispatcher).method("dispatchInitEvent");
			
			fakeLoader.load();
			verify(mockDispatcher);
		}
		
		[Test]
		public function addEventListener_stubLoaderDispatchesInitEventWithControlledAssetDataValue_mustCatchStubLoaderEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.INIT, "FakeAssetData"));
			mock(mockDispatcher).method("dispatchInitEvent").args(anything(), "FakeAssetData");
			
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
		
		[Test]
		public function addEventListener_stubLoaderDispatchesOpenEventWithControlledAssetDataValue_mustCatchStubLoaderEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN, "FakeAssetData"));
			mock(mockDispatcher).method("dispatchOpenEvent").args(anything(), "FakeAssetData");
			
			fakeLoader.load();
			verify(mockDispatcher);
		}
		
		[Test]
		public function addEventListener_stubLoaderDispatchesProgressEvent_mustCatchStubLoaderEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN))
				.dispatches(new ProgressEvent(ProgressEvent.PROGRESS));
			
			mock(mockDispatcher).method("dispatchProgressEvent");
			
			fakeLoader.load();
			verify(mockDispatcher);
		}
		
		[Test]
		public function addEventListener_stubLoaderDispatchesProgressEventWithControlledBytes_checkIfMonitoringPercentMatches(): void
		{
			stub(fakeLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN))
				.dispatches(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 50, 200));
			
			fakeLoader.load();
			
			var percent: int = monitor.monitoring.percent;
			Assert.assertEquals(25, percent);
		}

		[Test]
		public function addEventListener_stubLoaderDispatchesStoppedEvent_mustCatchStubLoaderEventAndCallMockDispatcher(): void
		{
			stub(fakeLoader).method("stop").dispatches(new LoaderEvent(LoaderEvent.STOPPED));
			mock(mockDispatcher).method("dispatchStoppedEvent");
			
			fakeLoader.stop();
			verify(mockDispatcher);
		}
		
	}

}