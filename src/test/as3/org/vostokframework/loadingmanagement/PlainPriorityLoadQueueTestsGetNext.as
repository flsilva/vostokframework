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

package org.vostokframework.loadingmanagement
{
	import org.flexunit.Assert;
	import org.vostokframework.loadingmanagement.policies.StubLoadingPolicy;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=13)]
	public class PlainPriorityLoadQueueTestsGetNext
	{
		
		public var _queue:PriorityLoadQueue;
		public var policy:StubLoadingPolicy;
		
		public function PlainPriorityLoadQueueTestsGetNext()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			policy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			_queue = getQueue(policy);
			configQueue(_queue);
		}
		
		[After]
		public function tearDown(): void
		{
			_queue = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getQueue(policy:StubLoadingPolicy):PriorityLoadQueue
		{
			return new PlainPriorityLoadQueue(policy);
		}
		
		public function getLoader(id:String, priority:LoadPriority):RefinedLoader
		{
			return new StubRefinedLoader(id, 3, priority);
		}
		
		private function configQueue(queue:PriorityLoadQueue):void
		{
			//purposely added out of order
			//to test if the queue will correctly sort it (by priority)
			queue.addLoader(getLoader("loader-2", LoadPriority.MEDIUM));
			queue.addLoader(getLoader("loader-4", LoadPriority.LOW));
			queue.addLoader(getLoader("loader-1", LoadPriority.HIGH));
			queue.addLoader(getLoader("loader-3", LoadPriority.MEDIUM));
		}
		
		////////////////////////////////////////
		// PlainPriorityLoadQueue().getNext() //
		////////////////////////////////////////
		
		[Test]
		public function getNext_simpleCall_ReturnsValidObject(): void
		{
			var loader:RefinedLoader = _queue.getNext();
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_simpleCall_checkPriorityOrder_ReturnsValidObject(): void
		{
			var loader:RefinedLoader = _queue.getNext();
			Assert.assertEquals("loader-1", loader.id);
		}
		
		[Test]
		public function getNext_doubleCall_checkPriorityOrder_ReturnsValidObject(): void
		{
			_queue.getNext();
			var loader:RefinedLoader = _queue.getNext();
			Assert.assertEquals("loader-2", loader.id);
		}
		
		[Test]
		public function getNext_exceedsLocalMaxConnections_ReturnsNull(): void
		{
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 4;
			policy.totalGlobalConnections = 0;
			
			var loader:RefinedLoader = _queue.getNext();
			loader.load();
			
			loader = _queue.getNext();
			loader.load();
			
			loader = _queue.getNext();
			loader.load();
			
			loader = _queue.getNext();
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_exceedsGlobalMaxConnections_ReturnsNull(): void
		{
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 4;
			policy.totalGlobalConnections = 4;
			
			var loader:RefinedLoader = _queue.getNext();
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_cancelAndCheckNext_RefinedLoader(): void
		{
			var loader:RefinedLoader = _queue.getLoaders().getAt(0);
			loader.cancel();
			
			loader = _queue.getNext();
			Assert.assertEquals("loader-2", loader.id);
		}
		
		[Test]
		public function getNext_stopAndCheckNext_RefinedLoader(): void
		{
			var loader:RefinedLoader = _queue.getLoaders().getAt(0);
			loader.stop();
			
			loader = _queue.getNext();
			Assert.assertEquals("loader-2", loader.id);
		}
		
	}

}