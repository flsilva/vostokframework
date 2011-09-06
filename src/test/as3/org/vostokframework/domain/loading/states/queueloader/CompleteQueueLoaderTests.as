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
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.vostokframework.loadingmanagement.domain.ILoaderState;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class CompleteQueueLoaderTests extends QueueLoaderStateTestsSetUp
	{
		
		public function CompleteQueueLoaderTests()
		{
			
		}
		
		override public function getState():ILoaderState
		{
			return new CompleteQueueLoader(fakeQueueLoader, fakeLoadingStatus, fakePolicy);
		}
		
		[Test]
		public function isLoading_simpleCall_ReturnsFalse(): void
		{
			state = getState();
			Assert.assertFalse(state.isLoading);
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
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function addChild_illegalOperation_ThrowsError(): void
		{
			state = getState();
			state.addChild(fakeChildLoader1);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function addChildren_illegalOperation_ThrowsError(): void
		{
			state = getState();
			
			var list:IList = new ArrayList();
			list.add(fakeChildLoader1);
			
			state.addChildren(list);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function cancel_illegalOperation_ThrowsError(): void
		{
			state = getState();
			state.cancel();
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function cancelChild_illegalOperation_ThrowsError(): void
		{
			state = getState();
			state.cancelChild(fakeChildLoader1.identification);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function load_illegalOperation_ThrowsError(): void
		{
			state = getState();
			state.load();
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function removeChild_illegalOperation_ThrowsError(): void
		{
			state = getState();
			state.removeChild(fakeChildLoader1.identification);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function resumeChild_illegalOperation_ThrowsError(): void
		{
			state = getState();
			state.resumeChild(fakeChildLoader1.identification);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function stop_illegalOperation_ThrowsError(): void
		{
			state = getState();
			state.stop();
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function stopChild_illegalOperation_ThrowsError(): void
		{
			state = getState();
			state.stopChild(fakeChildLoader1.identification);
		}
		
	}

}