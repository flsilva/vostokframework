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

	import org.vostokframework.application.LoadingContext;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.ILoaderState;
	import org.vostokframework.domain.loading.events.LoaderEvent;
	import org.vostokframework.domain.loading.policies.ILoadingPolicy;
	import org.vostokframework.domain.loading.policies.LoadingPolicy;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingQueueLoaderTestsResumeChild extends QueueLoaderStateTestsResumeChild
	{
		
		public var fakeChildLoader3:ILoader;
		
		public function LoadingQueueLoaderTestsResumeChild()
		{
			
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		override public function getState():ILoaderState
		{
			//these lines are required otherwise LoadingQueueLoader will dispatch
			//LoaderEvent.COMPLETE because its queue is empty
			fakeChildLoader3 = getFakeLoader("fake-loader-3", 3);
			fakeLoadingStatus.allLoaders.put(fakeChildLoader3.identification.toString(), fakeChildLoader3);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader3);
			//
			
			return new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, fakePolicy, 3);
		}
		
		[Test]
		public function integrationTesting_stateWithTwoChildren_callStopChildThenCallResumeChild_verifyIfMockChildWasCalled(): void
		{
			// INTEGRATION TESTING USING REAL LoadingPolicy DEPENDENCY
			
			fakeLoadingStatus.allLoaders.put(fakeChildLoader1.identification.toString(), fakeChildLoader1);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader1);
			
			fakeLoadingStatus.allLoaders.put(fakeChildLoader2.identification.toString(), fakeChildLoader2);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader2);
			
			stub(fakeChildLoader1).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING));
			
			var policy:ILoadingPolicy = new LoadingPolicy(LoadingContext.getInstance().loaderRepository);
			policy.globalMaxConnections = 6;
			
			state = new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, policy, 2);
			state.stopChild(fakeChildLoader2.identification);
			
			mock(fakeChildLoader2).method("load").once();
			
			state.resumeChild(fakeChildLoader2.identification);
			
			verify(fakeChildLoader2);
		}
		
	}

}