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

package org.vostokframework.loadingmanagement.domain
{
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;

	import org.as3collections.maps.HashMap;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.events.LoaderErrorEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoadingAlgorithmErrorEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoadingAlgorithmEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.LoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderCanceled;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderConnecting;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderQueued;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderStopped;

	import flash.events.ProgressEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class VostokLoaderTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(inject="false")]
		public var stubLoadingAlgorithm:LoadingAlgorithm;
		
		public var loader:VostokLoader;
		
		public function VostokLoaderTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			loader = getLoader();
		}
		
		[After]
		public function tearDown(): void
		{
			loader = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getLoader():VostokLoader
		{
			stubLoadingAlgorithm = nice(LoadingAlgorithm, null, [1]);
			stub(stubLoadingAlgorithm).asEventDispatcher();
			
			var identification:VostokIdentification = new VostokIdentification("id", VostokFramework.CROSS_LOCALE_ID);
			return new VostokLoader(identification, stubLoadingAlgorithm, LoadPriority.MEDIUM);
		}
		
		///////////////////////////////
		// ASYNC TESTS CONFIGURATION //
		///////////////////////////////
		
		public function asyncTimeoutHandler(passThroughData:Object):void
		{
			Assert.fail("Asynchronous Test Failed: Timeout");
			passThroughData = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		/////////////////////////////
		// VostokLoader().priority //
		/////////////////////////////
		
		[Test]
		public function priority_setValidPriority_checkIfPriorityMatches_ReturnsTrue(): void
		{
			loader.priority = 1;
			Assert.assertEquals(1, loader.priority);
		}
		
		[Test(expects="ArgumentError")]
		public function priority_setInvalidLessPriority_ThrowsError(): void
		{
			loader.priority = -1;
		}
		
		[Test(expects="ArgumentError")]
		public function priority_setInvalidGreaterPriority_ThrowsError(): void
		{
			loader.priority = 5;
		}
		
		//////////////////////////
		// VostokLoader().state //
		//////////////////////////
		
		[Test]
		public function state_freshObject_checkIfStatusIsQueued_ReturnsTrue(): void
		{
			Assert.assertEquals(LoaderQueued.INSTANCE, loader.state);
		}
		
		/////////////////////////////////
		// VostokLoader().stateHistory //
		/////////////////////////////////
		
		[Test]
		public function stateHistory_freshObject_checkIfFirstElementIsQueued_ReturnsTrue(): void
		{
			Assert.assertEquals(LoaderQueued.INSTANCE, loader.stateHistory.getAt(0));
		}
		
		[Test]
		public function stateHistory_afterCallLoad_checkIfSecondElementIsTryingToConnect_ReturnsTrue(): void
		{
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING));
			loader.load();
			Assert.assertEquals(LoaderConnecting.INSTANCE, loader.stateHistory.getAt(1));
		}
		
		///////////////////////////////////////
		// VostokLoader().addEventListener() //
		///////////////////////////////////////
		
		[Test(async, timeout=200)]
		public function addEventListener_stubAlgorithmDispatchesCompleteEvent_mustCatchStubEventAndDispatchOwnCompleteEvent(): void
		{
			Async.proceedOnEvent(this, loader, LoaderEvent.COMPLETE, 200);
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.COMPLETE), 50);
			
			loader.load();
		}
		
		[Test(async, timeout=200)]
		public function addEventListener_stubAlgorithmDispatchesConnectingEvent_mustCatchStubEventAndDispatchOwnConnectingEvent(): void
		{
			Async.proceedOnEvent(this, loader, LoaderEvent.CONNECTING, 200);
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING), 50);
			
			loader.load();
		}
		
		[Test(async, timeout=200)]
		public function addEventListener_stubAlgorithmDispatchesHttpStatusEvent_mustCatchStubEventAndDispatchOwnHttpStatusEvent(): void
		{
			Async.proceedOnEvent(this, loader, LoaderEvent.HTTP_STATUS, 200);
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.HTTP_STATUS), 50);
			
			loader.load();
		}
		
		[Test(async, timeout=200)]
		public function addEventListener_stubAlgorithmDispatchesInitEvent_mustCatchStubEventAndDispatchOwnInitEvent(): void
		{
			Async.proceedOnEvent(this, loader, LoaderEvent.INIT, 200);
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.INIT), 50);
			
			loader.load();
		}
		
		[Test(async, timeout=200)]
		public function addEventListener_stubAlgorithmDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent(): void
		{
			Async.proceedOnEvent(this, loader, LoaderEvent.OPEN, 200);
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.OPEN), 50);
			
			loader.load();
		}
		
		[Test(async, timeout=200)]
		public function addEventListener_stubAlgorithmDispatchesProgressEvent_mustCatchStubEventAndDispatchOwnProgressEvent(): void
		{
			Async.proceedOnEvent(this, loader, ProgressEvent.PROGRESS, 200);
			
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.OPEN), 25)
				.dispatches(new ProgressEvent(ProgressEvent.PROGRESS), 50);
			
			loader.load();
		}
		
		[Test(async, timeout=200)]
		public function addEventListener_stubAlgorithmDispatchesFailedErrorEvent_mustCatchStubEventAndDispatchOwnFailedErrorEvent(): void
		{
			Async.proceedOnEvent(this, loader, LoaderErrorEvent.FAILED, 200);
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmErrorEvent(LoadingAlgorithmErrorEvent.FAILED, new HashMap()), 50);
			
			loader.load();
		}
		
		/////////////////////////////
		// VostokLoader().cancel() //
		/////////////////////////////
		
		[Test]
		public function cancel_simpleCall_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			loader.cancel();
			Assert.assertEquals(LoaderCanceled.INSTANCE, loader.state);
		}
		
		[Test]
		public function cancel_doubleCall_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			loader.cancel();
			loader.cancel();
			Assert.assertEquals(LoaderCanceled.INSTANCE, loader.state);
		}
		
		[Test(async)]
		public function cancel_simpleCall_waitCanceledLoaderEvent(): void
		{
			Async.proceedOnEvent(this, loader, LoaderEvent.CANCELED, 50, asyncTimeoutHandler);
			loader.cancel();
		}
		
		[Test]
		public function cancel_simpleCall_verifyIfStrategyWasCalled(): void
		{
			mock(stubLoadingAlgorithm).method("cancel");
			loader.cancel();
			verify(stubLoadingAlgorithm);
		}
		
		///////////////////////////
		// VostokLoader().load() //
		///////////////////////////
		
		[Test]
		public function load_simpleCall_checkIfStatusIsTryingToConnect_ReturnsTrue(): void
		{
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING));
			loader.load();
			Assert.assertEquals(LoaderConnecting.INSTANCE, loader.state);
		}
		
		[Test]
		public function load_doubleCall_checkIfStatusIsTryingToConnect_ReturnsTrue(): void
		{
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING));
			
			loader.load();
			loader.load();
			Assert.assertEquals(LoaderConnecting.INSTANCE, loader.state);
		}
		
		[Test(async)]
		public function load_simpleCall_waitTryingToConnectLoaderEvent(): void
		{
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING));
			Async.proceedOnEvent(this, loader, LoaderEvent.CONNECTING, 50, asyncTimeoutHandler);
			loader.load();
		}
		
		[Test]
		public function load_simpleCall_verifyIfStrategyWasCalled(): void
		{
			mock(stubLoadingAlgorithm).method("load");
			loader.load();
			verify(stubLoadingAlgorithm);
		}
		
		///////////////////////////
		// VostokLoader().stop() //
		///////////////////////////
		
		[Test]
		public function stop_simpleCall_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			loader.stop();
			Assert.assertEquals(LoaderStopped.INSTANCE, loader.state);
		}
		
		[Test]
		public function stop_doubleCall_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			loader.stop();
			loader.stop();
			Assert.assertEquals(LoaderStopped.INSTANCE, loader.state);
		}
		
		[Test(async)]
		public function stop_simpleCall_waitStoppedLoaderEvent(): void
		{
			Async.proceedOnEvent(this, loader, LoaderEvent.STOPPED, 50, asyncTimeoutHandler);
			loader.stop();
		}
		
		[Test]
		public function stop_simpleCall_verifyIfStrategyWasCalled(): void
		{
			mock(stubLoadingAlgorithm).method("stop");
			loader.stop();
			verify(stubLoadingAlgorithm);
		}
		
		/////////////////////////////////////////////////////////
		// VostokLoader().stop()-load()-cancel() - MIXED TESTS //
		/////////////////////////////////////////////////////////
		
		[Test]
		public function loadAndStop_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			loader.load();
			loader.stop();
			Assert.assertEquals(LoaderStopped.INSTANCE, loader.state);
		}
		
		[Test]
		public function stopAndLoad_checkIfStatusIsTryingToConnect_ReturnsTrue(): void
		{
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING));
			
			loader.stop();
			loader.load();
			Assert.assertEquals(LoaderConnecting.INSTANCE, loader.state);
		}
		
		[Test]
		public function loadAndCancel_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			loader.load();
			loader.cancel();
			Assert.assertEquals(LoaderCanceled.INSTANCE, loader.state);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function loadAndCancelAndLoad_illegalOperation_ThrowsError(): void
		{
			loader.load();
			loader.cancel();
			loader.load();
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function cancelAndLoad_illegalOperation_ThrowsError(): void
		{
			loader.cancel();
			loader.load();
		}
		
		[Test]
		public function loadAndStopAndLoad_checkIfStatusIsTryingToConnect_ReturnsTrue(): void
		{
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING));
			
			loader.load();
			loader.stop();
			loader.load();
			Assert.assertEquals(LoaderConnecting.INSTANCE, loader.state);
		}
		
		[Test]
		public function stopAndLoadAndStop_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			loader.stop();
			loader.load();
			loader.stop();
			Assert.assertEquals(LoaderStopped.INSTANCE, loader.state);
		}
		
		[Test]
		public function loadAndStopAndLoadAndStop_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			loader.load();
			loader.stop();
			loader.load();
			loader.stop();
			Assert.assertEquals(LoaderStopped.INSTANCE, loader.state);
		}
		
		[Test]
		public function loadAndStopAndCancel_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			loader.load();
			loader.stop();
			loader.cancel();
			Assert.assertEquals(LoaderCanceled.INSTANCE, loader.state);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function loadAndStopAndCancelAndLoad_illegalOperation_ThrowsError(): void
		{
			loader.load();
			loader.stop();
			loader.cancel();
			loader.load();
		}
		
	}

}