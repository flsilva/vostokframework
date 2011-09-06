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

package org.vostokframework.domain.loading.states.queueloader
{
	import mockolate.ingredients.Sequence;
	import mockolate.mock;
	import mockolate.sequence;
	import mockolate.stub;
	import mockolate.verify;

	import org.as3collections.maps.HashMap;
	import org.flexunit.async.Async;
	import org.hamcrest.object.instanceOf;
	import org.vostokframework.application.LoadingContext;
	import org.vostokframework.domain.loading.ILoaderState;
	import org.vostokframework.domain.loading.events.LoaderErrorEvent;
	import org.vostokframework.domain.loading.events.LoaderEvent;
	import org.vostokframework.domain.loading.policies.ILoadingPolicy;
	import org.vostokframework.domain.loading.policies.LoadingPolicy;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingQueueLoaderTestsInstanciation extends QueueLoaderStateTestsSetUp
	{
		
		//LoadingQueueLoader.as starts its logic as soon as it is instanciated
		public function LoadingQueueLoaderTestsInstanciation()
		{
			
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		override public function getState():ILoaderState
		{
			return new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, fakePolicy);;
		}
		
		///////////
		// TESTS //
		///////////
		
		[Test(expects="ArgumentError")]
		public function stateWithNoLoader_ThrowsError(): void
		{
			state = getState();
		}
		
		[Test]
		public function stateWithOneChild_verifyIfMockPolicyWasCalled(): void
		{
			fakeLoadingStatus.allLoaders.put(fakeChildLoader1.identification.toString(), fakeChildLoader1);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader1);
			
			mock(fakePolicy).method("getNext").anyArgs().once();
			
			state = getState();
			verify(fakePolicy);
		}
		
		[Test]
		public function fakePolicyReturnsMockChild_verifyIfMockChildWasCalled(): void
		{
			fakeLoadingStatus.allLoaders.put(fakeChildLoader1.identification.toString(), fakeChildLoader1);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader1);
			
			stub(fakePolicy).method("getNext").returns(fakeChildLoader1).once();
			mock(fakeChildLoader1).method("load").noArgs().once();
			
			state = getState();
			
			verify(fakeChildLoader1);
		}
		
		[Test]
		public function fakePolicyReturnsTwoMockChildren_firstMockChildDispatchesConnectingEvent_verifyIfLoadMethodWasCalledOnSecondMockChild(): void
		{
			fakeLoadingStatus.allLoaders.put(fakeChildLoader1.identification.toString(), fakeChildLoader1);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader1);
			
			var seq:Sequence = sequence();
			stub(fakePolicy).method("getNext").returns(fakeChildLoader1).once().ordered(seq);
			stub(fakePolicy).method("getNext").returns(fakeChildLoader2).once().ordered(seq);
			
			stub(fakeChildLoader1).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING));
			mock(fakeChildLoader2).method("load");
			
			state = getState();
			
			verify(fakeChildLoader2);
		}
		
		[Test(async, timeout=200)]
		public function fakePolicyReturnsStubChild_stubChildDispatchesOpenEvent_waitForStateToDispatchOpenEventOnItsLoader(): void
		{
			fakeLoadingStatus.allLoaders.put(fakeChildLoader1.identification.toString(), fakeChildLoader1);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader1);
			
			Async.proceedOnEvent(this, fakeQueueLoader, LoaderEvent.OPEN, 200);
			
			stub(fakePolicy).method("getNext").returns(fakeChildLoader1).once();
			
			stub(fakeChildLoader1).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING))
				.dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			
			state = getState();
		}
		
		[Test]
		public function integrationTesting_stateWithTwoChildren_stubChildrenDispatchesCompleteEvent_verifyIfStateTransitionWasCalled(): void
		{
			// INTEGRATION TESTING USING REAL LoadingPolicy DEPENDENCY
			// NOT USING getState() HELPER METHOD
			
			fakeLoadingStatus.allLoaders.put(fakeChildLoader1.identification.toString(), fakeChildLoader1);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader1);
			
			fakeLoadingStatus.allLoaders.put(fakeChildLoader2.identification.toString(), fakeChildLoader2);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader2);
			
			mock(fakeQueueLoader).method("setState").args(instanceOf(CompleteQueueLoader)).once();
			
			stub(fakeChildLoader1).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING))
				.dispatches(new LoaderEvent(LoaderEvent.OPEN))
				.dispatches(new LoaderEvent(LoaderEvent.COMPLETE));
			
			stub(fakeChildLoader2).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING))
				.dispatches(new LoaderEvent(LoaderEvent.OPEN))
				.dispatches(new LoaderEvent(LoaderEvent.COMPLETE));
			
			var policy:ILoadingPolicy = new LoadingPolicy(LoadingContext.getInstance().loaderRepository);
			policy.globalMaxConnections = 6;
			policy.localMaxConnections = 3;
			
			new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, policy);
			
			verify(fakeQueueLoader);
		}
		
		[Test]
		public function integrationTesting_stateWithTwoChildren_firstStubChildDispatchesCompleteEventAndSecondDispatchesFailedErrorEvent_verifyIfStateTransitionWasCalled(): void
		{
			// INTEGRATION TESTING USING REAL LoadingPolicy DEPENDENCY
			// NOT USING getState() HELPER METHOD
			
			fakeLoadingStatus.allLoaders.put(fakeChildLoader1.identification.toString(), fakeChildLoader1);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader1);
			
			fakeLoadingStatus.allLoaders.put(fakeChildLoader2.identification.toString(), fakeChildLoader2);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader2);
			
			mock(fakeQueueLoader).method("setState").args(instanceOf(CompleteQueueLoader)).once();
			
			stub(fakeChildLoader1).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING))
				.dispatches(new LoaderEvent(LoaderEvent.OPEN))
				.dispatches(new LoaderEvent(LoaderEvent.COMPLETE));
			
			stub(fakeChildLoader2).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING))
				.dispatches(new LoaderErrorEvent(LoaderErrorEvent.FAILED, new HashMap()));
			
			var policy:ILoadingPolicy = new LoadingPolicy(LoadingContext.getInstance().loaderRepository);
			policy.globalMaxConnections = 6;
			policy.localMaxConnections = 3;
			
			new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, policy);
			
			verify(fakeQueueLoader);
		}
		
		[Test]
		public function integrationTesting_stateWithTwoChildren_firstChildLoaderDispacthesConnectingEvent_verifyIfSecondChildLoaderWasCalled(): void
		{
			// INTEGRATION TESTING USING REAL LoadingPolicy DEPENDENCY
			// NOT USING getState() HELPER METHOD
			
			fakeLoadingStatus.allLoaders.put(fakeChildLoader1.identification.toString(), fakeChildLoader1);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader1);
			
			fakeLoadingStatus.allLoaders.put(fakeChildLoader2.identification.toString(), fakeChildLoader2);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader2);
			
			stub(fakeChildLoader1).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING));
			
			mock(fakeChildLoader2).method("load").once();
			
			var policy:ILoadingPolicy = new LoadingPolicy(LoadingContext.getInstance().loaderRepository);
			policy.globalMaxConnections = 6;
			policy.localMaxConnections = 3;
			
			new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, policy);
			
			verify(fakeChildLoader2);
		}
		
	}

}