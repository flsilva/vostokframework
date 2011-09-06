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

package org.vostokframework.loadingmanagement.domain.loaders
{
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.verify;

	import org.flexunit.Assert;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.ILoader;
	import org.vostokframework.loadingmanagement.domain.ILoaderState;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class VostokLoaderTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(inject="false")]
		public var stubState:ILoaderState;
		
		public var loader:ILoader;
		
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
		
		public function getLoader():ILoader
		{
			stubState = nice(ILoaderState);
			
			var identification:VostokIdentification = new VostokIdentification("id", VostokFramework.CROSS_LOCALE_ID);
			return new VostokLoader(identification, stubState, LoadPriority.MEDIUM);
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
		
		///////////////////////////////////
		// VostokLoader().identification //
		///////////////////////////////////
		
		[Test]
		public function identification_checkIfIdentificationMatches_ReturnsTrue(): void
		{
			var identification:VostokIdentification = new VostokIdentification("id", VostokFramework.CROSS_LOCALE_ID);
			var $loader:ILoader = new VostokLoader(identification, stubState, LoadPriority.MEDIUM);
			
			Assert.assertEquals(identification, $loader.identification);
		}
		
		//////////////////////////
		// VostokLoader().index //
		//////////////////////////
		
		[Test]
		public function index_setValidIndex_checkIfIndexMatches_ReturnsTrue(): void
		{
			loader.index = 3;
			Assert.assertEquals(3, loader.index);
		}
		
		//////////////////////////////
		// VostokLoader().isLoading //
		//////////////////////////////
		
		[Test]
		public function isLoading_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).getter("isLoading").once();
			loader.isLoading;
			verify(stubState);
		}
		
		//////////////////////////////
		// VostokLoader().isQueued //
		//////////////////////////////
		
		[Test]
		public function isQueued_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).getter("isQueued").once();
			loader.isQueued;
			verify(stubState);
		}
		
		//////////////////////////////
		// VostokLoader().isStopped //
		//////////////////////////////
		
		[Test]
		public function isStopped_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).getter("isStopped").once();
			loader.isStopped;
			verify(stubState);
		}
		
		//////////////////////////////////////
		// VostokLoader().openedConnections //
		//////////////////////////////////////
		
		[Test]
		public function openedConnections_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).getter("openedConnections").once();
			loader.openedConnections;
			verify(stubState);
		}
		
		/////////////////////////////
		// VostokLoader().priority //
		/////////////////////////////
		
		[Test]
		public function priority_setValidPriorityOne_checkIfPriorityMatches_ReturnsTrue(): void
		{
			loader.priority = 1;
			Assert.assertEquals(1, loader.priority);
		}
		
		[Test]
		public function priority_setValidPriorityFour_checkIfPriorityMatches_ReturnsTrue(): void
		{
			loader.priority = 4;
			Assert.assertEquals(4, loader.priority);
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
		//TODO: teste do evento disparado pelo loader
		//////////////////////////
		// VostokLoader().state //
		//////////////////////////
		/*
		[Test]
		public function state_freshObject_checkIfStateIsQueued_ReturnsTrue(): void
		{
			Assert.assertEquals(LoaderQueued.INSTANCE, loader.state);
		}
		*/
		/////////////////////////////////
		// VostokLoader().stateHistory //
		/////////////////////////////////
		/*
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
		*/
		///////////////////////////////////////
		// VostokLoader().addEventListener() //
		///////////////////////////////////////
		/*
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
		public function addEventListener_stubAlgorithmDispatchesHttpStateEvent_mustCatchStubEventAndDispatchOwnHttpStateEvent(): void
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
		*/
		
		///////////////////////////////
		// VostokLoader().addChild() //
		///////////////////////////////
		
		[Test]
		public function addChild_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("addChild").once();
			loader.addChild(null);
			verify(stubState);
		}
		
		//////////////////////////////////
		// VostokLoader().addChildren() //
		//////////////////////////////////
		
		[Test]
		public function addChildren_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("addChildren").once();
			loader.addChildren(null);
			verify(stubState);
		}
		
		
		
		/////////////////////////////
		// VostokLoader().cancel() //
		/////////////////////////////
		/*
		[Test]
		public function cancel_simpleCall_checkIfStateIsCanceled_ReturnsTrue(): void
		{
			loader.cancel();
			Assert.assertEquals(LoaderCanceled.INSTANCE, loader.state);
		}
		
		[Test]
		public function cancel_doubleCall_checkIfStateIsCanceled_ReturnsTrue(): void
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
		*/
		[Test]
		public function cancel_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("cancel").once();
			loader.cancel();
			verify(stubState);
		}
		
		[Test]
		public function cancel_doubleCall_verifyIfStubStateWasCalledTwice(): void
		{
			mock(stubState).method("cancel").twice();
			loader.cancel();
			loader.cancel();
			verify(stubState);
		}
		
		//////////////////////////////////
		// VostokLoader().cancelChild() //
		//////////////////////////////////
		
		[Test]
		public function cancelChild_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("cancelChild").once();
			loader.cancelChild(null);
			verify(stubState);
		}
		
		////////////////////////////////////
		// VostokLoader().containsChild() //
		////////////////////////////////////
		
		[Test]
		public function containsChild_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("containsChild").once();
			loader.containsChild(null);
			verify(stubState);
		}
		
		//////////////////////////////
		// VostokLoader().dispose() //
		//////////////////////////////
		
		[Test]
		public function dispose_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("dispose").once();
			loader.dispose();
			verify(stubState);
		}
		
		[Test(expects="org.as3coreaddendum.errors.ObjectDisposedError")]
		public function dispose_simpleCall_tryToCallAnotherMethodAfterCallDispose_ThrowsError(): void
		{
			loader.dispose();
			loader.load();
		}
		
		/////////////////////////////
		// VostokLoader().equals() //
		/////////////////////////////
		
		[Test]
		public function equals_sameObject_ReturnsTrue(): void
		{
			var equals:Boolean = loader.equals(loader);
			Assert.assertTrue(equals);
		}
		
		[Test]
		public function equals_differentObjectsWithSameIdentification_ReturnsTrue(): void
		{
			var identification:VostokIdentification = new VostokIdentification(loader.identification.id, loader.identification.locale);
			var otherLoader:ILoader = new VostokLoader(identification, stubState, LoadPriority.MEDIUM);
			
			var equals:Boolean = loader.equals(otherLoader);
			Assert.assertTrue(equals);
		}
		
		[Test]
		public function equals_differentObjectsWithDifferentIdentification_ReturnsFalse(): void
		{
			var identification:VostokIdentification = new VostokIdentification(loader.identification.id, "other-locale");
			var otherLoader:ILoader = new VostokLoader(identification, stubState, LoadPriority.MEDIUM);
			
			var equals:Boolean = loader.equals(otherLoader);
			Assert.assertFalse(equals);
		}
		
		///////////////////////////////
		// VostokLoader().getChild() //
		///////////////////////////////
		
		[Test]
		public function getChild_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("getChild").once();
			loader.getChild(null);
			verify(stubState);
		}
		
		////////////////////////////////
		// VostokLoader().getParent() //
		////////////////////////////////
		
		[Test]
		public function getParent_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("getParent").once();
			loader.getParent(null);
			verify(stubState);
		}
		
		///////////////////////////
		// VostokLoader().load() //
		///////////////////////////
		/*
		[Test]
		public function load_simpleCall_checkIfStateIsTryingToConnect_ReturnsTrue(): void
		{
			stub(stubLoadingAlgorithm).method("load").dispatches(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING));
			loader.load();
			Assert.assertEquals(LoaderConnecting.INSTANCE, loader.state);
		}
		
		[Test]
		public function load_doubleCall_checkIfStateIsTryingToConnect_ReturnsTrue(): void
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
		*/
		[Test]
		public function load_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("load").once();
			loader.load();
			verify(stubState);
		}
		
		[Test]
		public function load_doubleCall_verifyIfStubStateWasCalledTwice(): void
		{
			mock(stubState).method("load").twice();
			loader.load();
			loader.load();
			verify(stubState);
		}
		
		//////////////////////////////////
		// VostokLoader().removeChild() //
		//////////////////////////////////
		
		[Test]
		public function removeChild_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("removeChild").once();
			loader.removeChild(null);
			verify(stubState);
		}
		
		//////////////////////////////////
		// VostokLoader().resumeChild() //
		//////////////////////////////////
		
		[Test]
		public function resumeChild_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("resumeChild").once();
			loader.resumeChild(null);
			verify(stubState);
		}
		
		///////////////////////////
		// VostokLoader().stop() //
		///////////////////////////
		/*
		[Test]
		public function stop_simpleCall_checkIfStateIsStopped_ReturnsTrue(): void
		{
			loader.stop();
			Assert.assertEquals(LoaderStopped.INSTANCE, loader.state);
		}
		
		[Test]
		public function stop_doubleCall_checkIfStateIsStopped_ReturnsTrue(): void
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
		*/
		[Test]
		public function stop_simpleCall_verifyIfStubStateWasCalledOnce(): void
		{
			mock(stubState).method("stop").once();
			loader.stop();
			verify(stubState);
		}
		
		[Test]
		public function stop_doubleCall_verifyIfStubStateWasCalledTwice(): void
		{
			mock(stubState).method("stop").twice();
			loader.stop();
			loader.stop();
			verify(stubState);
		}
		
	}

}