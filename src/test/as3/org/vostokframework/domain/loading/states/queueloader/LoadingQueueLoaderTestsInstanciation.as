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
	import mockolate.mock;
	import mockolate.stub;
	import mockolate.verify;

	import org.as3collections.lists.ArrayList;
	import org.flexunit.async.Async;
	import org.hamcrest.object.instanceOf;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.ILoaderState;
	import org.vostokframework.domain.loading.LoadPriority;
	import org.vostokframework.domain.loading.events.LoaderErrorEvent;
	import org.vostokframework.domain.loading.events.LoaderEvent;

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
			return new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, fakePolicy, 3);
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
			
			mock(fakePolicy).method("process").anyArgs().once();
			
			state = getState();
			verify(fakePolicy);
		}
		
		[Test(async, timeout=200)]
		public function integrationTesting_stubChildDispatchesOpenEvent_waitForStateToDispatchOpenEventOnItsLoader(): void
		{
			// INTEGRATION TESTING USING REAL LoadingPolicy DEPENDENCY
			// NOT USING getState() HELPER METHOD
			
			fakeLoadingStatus.allLoaders.put(fakeChildLoader1.identification.toString(), fakeChildLoader1);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader1);
			
			Async.proceedOnEvent(this, fakeQueueLoader, LoaderEvent.OPEN, 200);
			
			stub(fakeChildLoader1).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING))
				.dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			
			var policy:IQueueLoadingPolicy = getLoadingPolicy(6);
			
			new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, policy, 3);
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
			
			var policy:IQueueLoadingPolicy = getLoadingPolicy(6);
			
			new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, policy, 3);
			
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
				.dispatches(new LoaderErrorEvent(LoaderErrorEvent.FAILED, new ArrayList()));
			
			var policy:IQueueLoadingPolicy = getLoadingPolicy(6);
			
			new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, policy, 3);
			
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
			
			var policy:IQueueLoadingPolicy = getLoadingPolicy(6);
			
			new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, policy, 3);
			
			verify(fakeChildLoader2);
		}
		
		[Test]
		public function integrationTesting_usingRealSpecialHighestLowestQueueLoadingPolicy_stateWithOneHighPriorityChild_addHighestPriorityLoader_shouldStopHighPriorityLoader_highestPriorityLoaderDispatchesCompleteEvent_verifyIfHighPriorityLoaderWasCalled(): void
		{
			// INTEGRATION TESTING USING REAL SpecialHighestLowestQueueLoadingPolicy DEPENDENCY
			// NOT USING getState() HELPER METHOD
			
			var highLoader:ILoader = getFakeLoader("high-loader", 1, LoadPriority.HIGH);
			
			fakeLoadingStatus.allLoaders.put(highLoader.identification.toString(), highLoader);
			fakeLoadingStatus.queuedLoaders.add(highLoader);
			
			stub(highLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING));
			
			var policy:IQueueLoadingPolicy = getSpecialHighestLowestQueueLoadingPolicy(6);
			
			var state:ILoaderState = new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, policy, 3);
			
			var highestLoader:ILoader = getFakeLoader("highest-loader", 1, LoadPriority.HIGHEST);
			stub(highestLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING))
				.dispatches(new LoaderEvent(LoaderEvent.OPEN))
				.dispatches(new LoaderEvent(LoaderEvent.COMPLETE));
			
			mock(highLoader).method("load").once();
			
			state.addChild(highestLoader);
			
			verify(highLoader);
		}
		
		[Test]
		public function integrationTesting_usingRealSpecialHighestLowestQueueLoadingPolicy_stateWithOneLowestPriorityChild_addLowPriorityLoader_shouldStopLowestPriorityLoader_lowPriorityLoaderDispatchesCompleteEvent_verifyIfLowestPriorityLoaderWasCalled(): void
		{
			// INTEGRATION TESTING USING REAL SpecialHighestLowestQueueLoadingPolicy DEPENDENCY
			// NOT USING getState() HELPER METHOD
			
			var lowestLoader:ILoader = getFakeLoader("lowest-loader", 1, LoadPriority.LOWEST);
			
			fakeLoadingStatus.allLoaders.put(lowestLoader.identification.toString(), lowestLoader);
			fakeLoadingStatus.queuedLoaders.add(lowestLoader);
			
			stub(lowestLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING));
			
			var policy:IQueueLoadingPolicy = getSpecialHighestLowestQueueLoadingPolicy(6);
			
			var state:ILoaderState = new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, policy, 3);
			
			var lowLoader:ILoader = getFakeLoader("low-loader", 1, LoadPriority.LOW);
			stub(lowLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING))
				.dispatches(new LoaderEvent(LoaderEvent.OPEN))
				.dispatches(new LoaderEvent(LoaderEvent.COMPLETE));
			
			mock(lowestLoader).method("load").once();
			
			state.addChild(lowLoader);
			
			verify(lowestLoader);
		}
		
	}

}