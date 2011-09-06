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
	import org.flexunit.Assert;
	import org.vostokframework.domain.loading.ILoaderState;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class StoppedQueueLoaderTests extends QueueLoaderStateTestsSetUp
	{
		
		public function StoppedQueueLoaderTests()
		{
			
		}
		
		override public function getState():ILoaderState
		{
			return new StoppedQueueLoader(fakeQueueLoader, fakeLoadingStatus, fakePolicy);
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
		public function isStopped_simpleCall_ReturnsTrue(): void
		{
			state = getState();
			Assert.assertTrue(state.isStopped);
		}
		
		[Test]
		public function openedConnections_simpleCall_ReturnsZero(): void
		{
			state = getState();
			Assert.assertEquals(0, state.openedConnections);
		}
		
		[Test]
		public function stop_simpleCall_Void(): void
		{
			state = getState();
			state.stop();
		}
		
		[Test]
		public function stopChild_simpleCall_Void(): void
		{
			state = getState();
			state.stopChild(fakeChildLoader1.identification);
		}
		
	}

}