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

package org.vostokframework.loadingmanagement.domain.states.queueloader
{
	import mockolate.stub;

	import org.flexunit.Assert;
	import org.vostokframework.loadingmanagement.domain.ILoaderState;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingQueueLoaderTests extends QueueLoaderStateTestsSetUp
	{
		
		//LoadingQueueLoader.as starts its logic as soon as it is instanciated
		public function LoadingQueueLoaderTests()
		{
			
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		override public function getState():ILoaderState
		{
			fakeLoadingStatus.allLoaders.put(fakeChildLoader1.identification.toString(), fakeChildLoader1);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader1);
			
			return new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, fakePolicy);;
		}
		
		///////////
		// TESTS //
		///////////
		
		[Test]
		public function isLoading_simpleCall_ReturnsTrue(): void
		{
			state = getState();
			Assert.assertTrue(state.isLoading);
		}
		
		[Test]
		public function isQueued_simpleCall_ReturnsFalse(): void
		{
			state = getState();
			Assert.assertFalse(state.isQueued);
		}
		
		[Test]
		public function isStopped_simpleCall_ReturnsFalse(): void
		{
			state = getState();
			Assert.assertFalse(state.isStopped);
		}
		
		[Test]
		public function openedConnections_simpleCall_ReturnsZero(): void
		{
			state = getState();
			Assert.assertEquals(0, state.openedConnections);
		}
		
		[Test]
		public function openedConnections_fakeChildReturnsOne_ReturnsOne(): void
		{
			stub(fakeChildLoader1).getter("openedConnections").returns(1);
			
			state = getState();
			Assert.assertEquals(1, state.openedConnections);
		}
		
		[Test]
		public function openedConnections_fakeTwoChildrenReturnsOneEachOne_ReturnsTwo(): void
		{
			fakeLoadingStatus.allLoaders.put(fakeChildLoader2.identification.toString(), fakeChildLoader2);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader2);
			
			stub(fakeChildLoader1).getter("openedConnections").returns(1);
			stub(fakeChildLoader2).getter("openedConnections").returns(1);
			
			state = getState();
			Assert.assertEquals(2, state.openedConnections);
		}
		
	}

}