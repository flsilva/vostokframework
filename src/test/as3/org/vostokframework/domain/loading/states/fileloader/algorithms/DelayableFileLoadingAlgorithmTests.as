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

package org.vostokframework.domain.loading.states.fileloader.algorithms
{
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;

	import org.as3collections.maps.ArrayListMap;
	import org.flexunit.async.Async;
	import org.vostokframework.domain.loading.states.fileloader.FileLoadingAlgorithmErrorEvent;
	import org.vostokframework.domain.loading.states.fileloader.IFileLoadingAlgorithm;

	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class DelayableFileLoadingAlgorithmTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		public var algorithm:IFileLoadingAlgorithm;
		
		[Mock(inject="false")]
		public var fakeWrappedAlgorithm:IFileLoadingAlgorithm;
		
		public function DelayableFileLoadingAlgorithmTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			fakeWrappedAlgorithm = nice(IFileLoadingAlgorithm);
			stub(fakeWrappedAlgorithm).asEventDispatcher();
			stub(fakeWrappedAlgorithm).method("getData").returns(new MovieClip());
		}
		
		[After]
		public function tearDown(): void
		{
			algorithm = null;
			fakeWrappedAlgorithm = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getAlgorithm(initialDelay:Number, delayAfterError:Number):IFileLoadingAlgorithm
		{
			return new DelayableFileLoadingAlgorithm(fakeWrappedAlgorithm, initialDelay, delayAfterError);
		}
		
		///////////
		// TESTS //
		///////////
		
		[Test(async, timeout=600)]
		public function load_initialDelayOf300Milliseconds_stopTestWith500Milliseconds_verifyMockWrappedAlgorithmWasCalled(): void
		{
			mock(fakeWrappedAlgorithm).method("load").once();
			
			algorithm = getAlgorithm(300, 500);
			algorithm.load();
			
			var asyncHandler:Function = Async.asyncHandler(this,
				function():void
				{
					verify(fakeWrappedAlgorithm);
				}
			, 600);
			
			var timer:Timer = new Timer(500, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler, false, 0, true);
			timer.start();
		}
		
		[Test(async, timeout=300)]
		public function load_initialDelayOf300Milliseconds_stopTestWith200Milliseconds_verifyMockWrappedAlgorithmWasNotCalled(): void
		{
			mock(fakeWrappedAlgorithm).method("load").never();
			
			algorithm = getAlgorithm(300, 500);
			algorithm.load();
			
			var asyncHandler:Function = Async.asyncHandler(this,
				function():void
				{
					verify(fakeWrappedAlgorithm);
					
					// the line below is needed, otherwise mockolate will dispatch
					// Error: Unexpected invocation for IFileLoadingAlgorithm.load()
					// because internally the timer of DelayableFileLoadingAlgorithm
					// keeps running and will call wrappedAlgorithm.load()
					algorithm.stop();
				}
			, 300);
			
			var timer:Timer = new Timer(200, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler, false, 0, true);
			timer.start();
		}
		
		[Test(async, timeout=700)]
		public function load_initialDelayOf400Milliseconds_stubWrappedAlgorithmDispatchFailedErrorEvent_delayAfterError100Milliseconds_callLoadAgain_stopTestWith600Milliseconds_verifyMockWrappedAlgorithmWasCalledTwice(): void
		{
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, new ArrayListMap()), 50).once();
			
			// it is needed to do it here because DelayableFileLoadingAlgorithm
			// do not call wrappedAlgorithm again
			// it is the role of MaxAttemptsFileLoadingAlgorithmTests
			// in the real scenario
			fakeWrappedAlgorithm.addEventListener(FileLoadingAlgorithmErrorEvent.FAILED,
				function():void
				{
					mock(fakeWrappedAlgorithm).method("load").once();
					algorithm.load();
				}
			, false, int.MIN_VALUE, true);
			
			algorithm = getAlgorithm(400, 100);
			algorithm.load();
			
			var asyncHandler:Function = Async.asyncHandler(this,
				function():void
				{
					verify(fakeWrappedAlgorithm);
				}
			, 700);
			
			var timer:Timer = new Timer(600, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler, false, 0, true);
			timer.start();
		}
		
		[Test(async, timeout=500)]
		public function load_initialDelayOf100Milliseconds_stubWrappedAlgorithmDispatchFailedErrorEvent_delayAfterError300Milliseconds_callLoadAgain_stopTestWith400Milliseconds_verifyMockWrappedAlgorithmWasNotCalledAgain(): void
		{
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, new ArrayListMap()), 50).once();
			
			// it is needed to do it here because DelayableFileLoadingAlgorithm
			// do not call wrappedAlgorithm again
			// it is the role of MaxAttemptsFileLoadingAlgorithmTests
			// in the real scenario
			fakeWrappedAlgorithm.addEventListener(FileLoadingAlgorithmErrorEvent.FAILED,
				function():void
				{
					mock(fakeWrappedAlgorithm).method("load").never();
					algorithm.load();
				}
			, false, int.MIN_VALUE, true);
			
			algorithm = getAlgorithm(100, 300);
			algorithm.load();
			
			var asyncHandler:Function = Async.asyncHandler(this,
				function():void
				{
					verify(fakeWrappedAlgorithm);
					
					// the line below is needed, otherwise mockolate will dispatch
					// Error: Unexpected invocation for IFileLoadingAlgorithm.load()
					// because internally the timer of DelayableFileLoadingAlgorithm
					// keeps running and will call wrappedAlgorithm.load()
					algorithm.stop();
				}
			, 500);
			
			var timer:Timer = new Timer(400, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler, false, 0, true);
			timer.start();
		}
		
	}

}