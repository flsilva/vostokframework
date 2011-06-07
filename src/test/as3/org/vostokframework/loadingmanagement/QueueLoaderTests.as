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
	import mockolate.ingredients.Sequence;
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.sequence;
	import mockolate.stub;
	import mockolate.verify;

	import org.as3collections.lists.ReadOnlyArrayList;
	import org.flexunit.async.Async;
	import org.vostokframework.loadingmanagement.events.QueueEvent;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=9999999)]
	public class QueueLoaderTests extends RefinedLoaderTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(inject="false")]
		public var _fakeQueue:PriorityLoadQueue;
		
		[Mock(inject="false")]
		public var _fakeLoader1:RefinedLoader;
		public var _fakeLoader2:RefinedLoader;
		
		private var _timer:Timer;
		
		private function get queueLoader():QueueLoader { return _loader as QueueLoader; }
		
		public function QueueLoaderTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		override public function setUp(): void
		{
			_timer = new Timer(500, 1);
			
			super.setUp();
		}
		
		[After]
		override public function tearDown(): void
		{
			_timer.stop();
			
			_fakeQueue = null;
			_fakeLoader1 = null;
			_fakeLoader2 = null;
			_timer = null;
			
			super.tearDown();
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		override public function getLoader():RefinedLoader
		{
			_fakeQueue = nice(PriorityLoadQueue);
			stub(_fakeQueue).asEventDispatcher();
			
			_fakeLoader1 = nice(RefinedLoader, null, ["fake-loader-1", LoadPriority.MEDIUM, 3]);
			stub(_fakeLoader1).getter("id").returns("fake-loader-1");
			
			_fakeLoader2 = nice(RefinedLoader, null, ["fake-loader-2", LoadPriority.LOW, 3]);
			stub(_fakeLoader2).getter("id").returns("fake-loader-2");
			
			stub(_fakeQueue).method("getLoaders").returns(new ReadOnlyArrayList([_fakeLoader1,_fakeLoader2]));
			
			return new QueueLoader("queue-loader", LoadPriority.MEDIUM, _fakeQueue);
		}
		
		///////////////////////////////
		// ASYNC TESTS CONFIGURATION //
		///////////////////////////////
		
		private function verifyMockTimerHandler(event:TimerEvent, passThroughData:Object):void
		{
			verify(passThroughData["mock"]);
		}
		
		//////////////////////////////
		// QueueLoader().load TESTS //
		//////////////////////////////
		
		[Test(async, timeout=2000)]
		public function load_fakeQueueReturnsOneMockLoader_verifyIfLoadWasCalledOnMock(): void
		{
			stub(_fakeQueue).method("getNext").returns(_fakeLoader1);
			mock(_fakeLoader1).method("load");
			
			_loader.load();
			
			_timer.delay = 300;
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, verifyMockTimerHandler, 2000,
														{mock:_fakeLoader1},
														asyncTimeoutHandler),
									false, 0, true);
			
			_timer.start();
		}
		
		[Test]
		public function load_fakeQueueReturnsTwoMockLoaders_verifyIfWasCalledLoadOnSecondMock(): void
		{
			mock(_fakeQueue).method("getNext");
			_fakeQueue.dispatchEvent(new QueueEvent(QueueEvent.QUEUE_CHANGED, 1));
			verify(_fakeQueue);
		}
		
		////////////////////////////////////
		// QueueLoader().stopLoader TESTS //
		////////////////////////////////////
		
		[Test]
		public function stopLoader_fakeQueueReturnsTwoMockLoaders_verifyIfWasCalledLoadOnSecondMock(): void
		{
			mock(_fakeLoader1).method("stop");
			queueLoader.stopLoader("fake-loader-1");
			verify(_fakeLoader1);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.errors.AssetLoaderNotFoundError")]
		public function stopLoader_notAddedLoader_ThrowsError(): void
		{
			queueLoader.stopLoader("not-added-id");
		}
		
	}

}