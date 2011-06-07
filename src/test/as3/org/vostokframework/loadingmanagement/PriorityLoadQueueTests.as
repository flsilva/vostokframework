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
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3utils.ReflectionUtil;
	import org.flexunit.Assert;
	import org.vostokframework.loadingmanagement.events.LoaderEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=13)]
	public class PriorityLoadQueueTests
	{
		
		public var _queue:PriorityLoadQueue;
		
		public function PriorityLoadQueueTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_queue = getQueue();
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
		
		public function getQueue():PriorityLoadQueue
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		private function configQueue(queue:PriorityLoadQueue):void
		{
			queue.addLoader(getLoader("loader-2", LoadPriority.MEDIUM));
			queue.addLoader(getLoader("loader-4", LoadPriority.LOW));
			queue.addLoader(getLoader("loader-1", LoadPriority.HIGH));
			queue.addLoader(getLoader("loader-3", LoadPriority.MEDIUM));
		}
		
		public function getLoader(id:String, priority:LoadPriority):RefinedLoader
		{
			return new StubRefinedLoader(id, 3, priority);
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		/////////////////////////////////////
		// PriorityLoadQueue().addLoader() //
		/////////////////////////////////////
		
		//TODO:test dupplication element
		
		///////////////////////////////////////
		// PriorityLoadQueue().totalCanceled //
		///////////////////////////////////////
		
		[Test]
		public function totalCanceled_freshObject_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queue.totalCanceled);
		}
		
		[Test]
		public function totalCanceled_callGetNextOnceAndCallCancelOnLoader_checkTotalCancelled_ReturnsOne(): void
		{
			var loader:RefinedLoader = _queue.getNext();
			loader.cancel();
			
			Assert.assertEquals(1, _queue.totalCanceled);
		}
		
		///////////////////////////////////////
		// PriorityLoadQueue().totalComplete //
		///////////////////////////////////////
		
		[Test]
		public function totalComplete_freshObject_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queue.totalComplete);
		}
		
		[Test]
		public function totalComplete_callGetNextOnceAndCallLoadOnLoaderAndMakeItDispatchesCompleteLoaderEvent_checkTotalComplete_ReturnsOne(): void
		{
			var loader:RefinedLoader = _queue.getNext();
			loader.load();
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, LoaderStatus.COMPLETE));
			
			Assert.assertEquals(1, _queue.totalComplete);
		}
		
		//////////////////////////////////////
		// PriorityLoadQueue().totalLoading //
		//////////////////////////////////////
		
		[Test]
		public function totalLoading_freshObject_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queue.totalLoading);
		}
		
		[Test]
		public function totalLoading_callGetNextTwiceAndCallLoadOnLoaders_checkTotalLoading_ReturnsTwo(): void
		{
			var loader:RefinedLoader = _queue.getNext();
			loader.load();
			
			loader = _queue.getNext();
			loader.load();
			
			Assert.assertEquals(2, _queue.totalLoading);
		}
		
		/////////////////////////////////////
		// PriorityLoadQueue().totalQueued //
		/////////////////////////////////////
		
		[Test]
		public function totalQueued_objectWithFourLoaders_ReturnsFour(): void
		{
			Assert.assertEquals(4, _queue.totalQueued);
		}
		
		[Test]
		public function totalQueued_objectWithThreeLoaders_callGetNextOnceAndCheckTotalQueued_ReturnsTwo(): void
		{
			_queue.getNext();
			Assert.assertEquals(3, _queue.totalQueued);
		}
		
		//////////////////////////////////////
		// PriorityLoadQueue().totalStopped //
		//////////////////////////////////////
		
		[Test]
		public function totalStopped_freshObject_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queue.totalStopped);
		}
		
		[Test]
		public function totalStopped_callGetNextOnceAndCallStopOnLoaderAndCheckTotalStopped_ReturnsOne(): void
		{
			var loader:RefinedLoader = _queue.getNext();
			loader.stop();
			
			Assert.assertEquals(1, _queue.totalStopped);
		}
		
	}

}