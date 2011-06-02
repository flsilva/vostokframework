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
	import org.vostokframework.loadingmanagement.policies.StubRequestLoadingPolicy;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=13)]
	public class RequestLoaderQueueManagerTestsGetNextSimplePriority
	{
		private var _queueManager:RequestLoaderQueueManager;
		private var _policy:StubRequestLoadingPolicy;
		
		public function RequestLoaderQueueManagerTestsGetNextSimplePriority()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_policy = new StubRequestLoadingPolicy();
			_policy.containsOnlyLowest = false;
			_policy.globalMaxConnections = 6;
			_policy.localMaxConnections = 3;
			_policy.totalGlobalConnections = 0;
			
			_queueManager = new RequestLoaderQueueManager(_policy);
			
			//added without order purposely
			//to test if the queue will correctly sort it (by priority)
			_queueManager.addLoader(new StubRequestLoader("request-loader-2", LoadPriority.MEDIUM));
			_queueManager.addLoader(new StubRequestLoader("request-loader-3", LoadPriority.LOW));
			_queueManager.addLoader(new StubRequestLoader("request-loader-1", LoadPriority.HIGH));
		}
		
		[After]
		public function tearDown(): void
		{
			_queueManager = null;
			_policy = null;
		}
		
		///////////////////////////////////////////
		// RequestLoaderQueueManager().getNext() //
		///////////////////////////////////////////
		
		[Test]
		public function getNext_validCall_ReturnsValidObject(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_validCall_checkIfReturnedObjectCorrespondsToPriorityOrder(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			Assert.assertEquals("request-loader-1", loader.id);
		}
		
		[Test]
		public function getNext_validDoubleCall_checkIfReturnedObjectCorrespondsToPriorityOrder(): void
		{
			_queueManager.getNext();
			
			var loader:RequestLoader = _queueManager.getNext();
			Assert.assertEquals("request-loader-2", loader.id);
		}
		
		[Test]
		public function getNext_exceedsConcurrentRequests_ReturnsNull(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_exceedsGlobalConcurrentConnections_ReturnsNull(): void
		{
			_policy.totalGlobalConnections = 6;
			
			var loader:RequestLoader = _queueManager.getNext();
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_cancelAndCheckNext_AssetLoader(): void
		{
			var loader:RequestLoader = _queueManager.getRequestLoaders().getAt(0);
			loader.cancel();
			
			loader = _queueManager.getNext();
			Assert.assertEquals("request-loader-2", loader.id);
		}
		
		[Test]
		public function getNext_stopAndCheckNext_AssetLoader(): void
		{
			var loader:RequestLoader = _queueManager.getRequestLoaders().getAt(0);
			loader.stop();
			
			loader = _queueManager.getNext();
			Assert.assertEquals("request-loader-2", loader.id);
		}
		
	}

}