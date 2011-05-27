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
	import org.vostokframework.loadingmanagement.events.RequestLoaderEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=13)]
	public class RequestLoaderQueueManagerTests
	{
		
		private var _queueManager:RequestLoaderQueueManager;
		
		public function RequestLoaderQueueManagerTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_queueManager = new RequestLoaderQueueManager();
			_queueManager.addLoader(new StubRequestLoader("request-loader-1"));
			_queueManager.addLoader(new StubRequestLoader("request-loader-2"));
			_queueManager.addLoader(new StubRequestLoader("request-loader-3"));
		}
		
		[After]
		public function tearDown(): void
		{
			_queueManager = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		/////////////////////////////////////////////
		// RequestLoaderQueueManager().addLoader() //
		/////////////////////////////////////////////
		
		//TODO:test dupplication element
		
		///////////////////////////////////////////////////
		// RequestLoaderQueueManager().activeConnections //
		///////////////////////////////////////////////////
		
		[Test]
		public function activeConnections_noLoadingCheckTotal_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queueManager.activeConnections);
		}
		
		[Test]
		public function activeConnections_twoLoadCall_checkTotal_ReturnsTwo(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.load();
			loader = _queueManager.getNext();
			loader.load();
			
			Assert.assertEquals(2, _queueManager.activeConnections);
		}
		
		///////////////////////////////////////////////
		// RequestLoaderQueueManager().totalCanceled //
		///////////////////////////////////////////////
		
		[Test]
		public function totalCanceled_noCanceledCheckTotal_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queueManager.totalCanceled);
		}
		
		[Test]
		public function totalCanceled_cancelAndCheckTotal_ReturnsOne(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.cancel();
			
			Assert.assertEquals(1, _queueManager.totalCanceled);
		}
		
		///////////////////////////////////////////////
		// RequestLoaderQueueManager().totalComplete //
		///////////////////////////////////////////////
		
		[Test]
		public function totalComplete_noCompleteCheckTotal_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queueManager.totalComplete);
		}
		
		[Test]
		public function totalComplete_loadDispatchesCompleteAndCheckTotal_ReturnsOne(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.load();
			loader.dispatchEvent(new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.COMPLETE));
			
			Assert.assertEquals(1, _queueManager.totalComplete);
		}
		
		//////////////////////////////////////////////
		// RequestLoaderQueueManager().totalLoading //
		//////////////////////////////////////////////
		
		[Test]
		public function totalLoading_noLoadingCheckTotal_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queueManager.totalLoading);
		}
		
		[Test]
		public function totalLoading_twoLoadCall_checkTotal_ReturnsTwo(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			loader.load();
			
			Assert.assertEquals(2, _queueManager.totalLoading);
		}
		
		/////////////////////////////////////////////
		// RequestLoaderQueueManager().totalQueued //
		/////////////////////////////////////////////
		
		[Test]
		public function totalQueued_checkTotal_ReturnsTwo(): void
		{
			Assert.assertEquals(3, _queueManager.totalQueued);
		}
		
		[Test]
		public function totalQueued_getNextAndCheckTotal_ReturnsOne(): void
		{
			_queueManager.getNext();
			Assert.assertEquals(2, _queueManager.totalQueued);
		}
		
		//////////////////////////////////////////////
		// RequestLoaderQueueManager().totalStopped //
		//////////////////////////////////////////////
		
		[Test]
		public function totalStopped_noStoppedCheckTotal_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queueManager.totalStopped);
		}
		
		[Test]
		public function totalStopped_stopAndCheckTotal_ReturnsOne(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.stop();
			
			Assert.assertEquals(1, _queueManager.totalStopped);
		}
		
	}

}