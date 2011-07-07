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

package org.vostokframework.loadingmanagement.domain.loaders
{
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;

	import org.as3collections.lists.ReadOnlyArrayList;
	import org.flexunit.async.Async;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.PriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.StatefulLoader;
	import org.vostokframework.loadingmanagement.domain.StatefulLoaderTests;
	import org.vostokframework.loadingmanagement.domain.events.QueueEvent;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class QueueLoaderTests extends StatefulLoaderTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(inject="false")]
		public var _fakeQueue:PriorityLoadQueue;
		
		[Mock(inject="false")]
		public var _fakeLoader1:StatefulLoader;
		public var _fakeLoader2:StatefulLoader;
		
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
		
		override public function getLoader():StatefulLoader
		{
			_fakeQueue = nice(PriorityLoadQueue);
			stub(_fakeQueue).asEventDispatcher();
			
			_fakeLoader1 = nice(StatefulLoader, null, ["fake-loader-1", LoadPriority.MEDIUM, 3]);
			_fakeLoader2 = nice(StatefulLoader, null, ["fake-loader-2", LoadPriority.LOW, 3]);
			
			stub(_fakeLoader1).getter("id").returns("fake-loader-1");
			stub(_fakeLoader2).getter("id").returns("fake-loader-2");
			
			stub(_fakeQueue).method("find").args("fake-loader-1").returns(_fakeLoader1);
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
		
		/////////////////////////////////////
		// QueueLoader().addLoader() TESTS //
		/////////////////////////////////////
		
		[Test]
		public function addLoader_queuedQueueLoader_validNewLoader_VerifyIfMockQueueWasCalled(): void
		{
			var fakeLoader:StatefulLoader = nice(StatefulLoader, null, ["fake-loader-99", LoadPriority.MEDIUM, 3]);
			stub(fakeLoader).getter("id").returns("fake-loader-99");
			mock(_fakeQueue).method("addLoader").args(fakeLoader);
			
			queueLoader.addLoader(fakeLoader);
			verify(_fakeQueue);
		}
		
		[Test]
		public function addLoader_stoppedQueueLoader_validNewLoader_VerifyIfMockQueueWasCalled(): void
		{
			var fakeLoader:StatefulLoader = nice(StatefulLoader, null, ["fake-loader-99", LoadPriority.MEDIUM, 3]);
			stub(fakeLoader).getter("id").returns("fake-loader-99");
			mock(_fakeQueue).method("addLoader").args(fakeLoader);
			
			queueLoader.stop();
			queueLoader.addLoader(fakeLoader);
			verify(_fakeQueue);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function addLoader_canceledQueueLoader_ThrowsError(): void
		{
			var fakeLoader:StatefulLoader = nice(StatefulLoader, null, ["fake-loader-99", LoadPriority.MEDIUM, 3]);
			stub(fakeLoader).getter("id").returns("fake-loader-99");
			
			queueLoader.cancel();
			queueLoader.addLoader(fakeLoader);
		}
		
		////////////////////////////////////////
		// QueueLoader().cancelLoader() TESTS //
		////////////////////////////////////////
		
		[Test]
		public function cancelLoader_addedLoader_VerifyIfMockWasCalled(): void
		{
			mock(_fakeLoader1).method("cancel");
			queueLoader.cancelLoader("fake-loader-1");
			verify(_fakeLoader1);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function cancelLoader_notAddedLoader_ThrowsError(): void
		{
			queueLoader.cancelLoader("not-added-id");
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
		
		////////////////////////////////////////
		// QueueLoader().resumeLoader() TESTS //
		////////////////////////////////////////
		
		[Test]
		public function resumeLoader_queuedQueueLoader_VerifyIfMockQueueWasCalled(): void
		{
			mock(_fakeQueue).method("resumeLoader").args("fake-loader-1");
			
			queueLoader.resumeLoader("fake-loader-1");
			verify(_fakeQueue);
		}
		
		[Test]
		public function resumeLoader_stoppedQueueLoader_VerifyIfMockQueueWasCalled(): void
		{
			mock(_fakeQueue).method("resumeLoader").args("fake-loader-1");
			
			queueLoader.stop();
			queueLoader.resumeLoader("fake-loader-1");
			verify(_fakeQueue);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function resumeLoader_canceledQueueLoader_ThrowsError(): void
		{
			queueLoader.cancel();
			queueLoader.resumeLoader("fake-loader-1");
		}
		
		//////////////////////////////////////
		// QueueLoader().stopLoader() TESTS //
		//////////////////////////////////////
		
		[Test]
		public function stopLoader_addedLoader_VerifyIfMockWasCalled(): void
		{
			mock(_fakeLoader1).method("stop");
			queueLoader.stopLoader("fake-loader-1");
			verify(_fakeLoader1);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function stopLoader_notAddedLoader_ThrowsError(): void
		{
			queueLoader.stopLoader("not-added-id");
		}
		
	}

}