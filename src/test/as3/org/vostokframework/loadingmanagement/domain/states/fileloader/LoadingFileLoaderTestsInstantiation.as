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

package org.vostokframework.loadingmanagement.domain.states.fileloader
{
	import mockolate.ingredients.Sequence;
	import mockolate.mock;
	import mockolate.sequence;
	import mockolate.stub;
	import mockolate.verify;

	import org.flexunit.async.Async;
	import org.hamcrest.object.instanceOf;
	import org.vostokframework.loadingmanagement.domain.ILoaderState;
	import org.vostokframework.loadingmanagement.domain.events.LoaderErrorEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingFileLoaderTestsInstantiation extends FileLoaderStateTestsSetUp
	{
		
		public function LoadingFileLoaderTestsInstantiation()
		{
			
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		override public function getState():ILoaderState
		{
			return new LoadingFileLoader(fakeFileLoader, fakeAlgorithm, 3);
		}
		
		[Test]
		public function verifyIfMockAlgorithmWasCalled(): void
		{
			mock(fakeAlgorithm).method("load").once();
			
			state = getState();
			verify(fakeAlgorithm);
		}
		
		[Test]
		public function stubAlgorithmDispatchesCompleteEvent_verifyIfStateTransitionWasCalled(): void
		{
			stub(fakeAlgorithm).method("load").dispatches(new Event(Event.OPEN))
				.dispatches(new Event(Event.COMPLETE));
			
			mock(fakeFileLoader).method("setState").args(instanceOf(CompleteFileLoader)).once();
			
			state = getState();
			
			verify(fakeFileLoader);
		}
		
		[Test]
		public function stubAlgorithmDispatchesTwoErrorEventsAndOneCompleteEvent_stateWithThreeAttempts_verifyIfStateTransitionWasCalled(): void
		{
			var seq:Sequence = sequence();
			
			stub(fakeAlgorithm).method("load").dispatches(new Event(Event.OPEN))
				.dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR)).once().ordered(seq);
			
			stub(fakeAlgorithm).method("load").dispatches(new ErrorEvent(ErrorEvent.ERROR)).once().ordered(seq);
				
			stub(fakeAlgorithm).method("load").dispatches(new Event(Event.COMPLETE)).once().ordered(seq);
			
			mock(fakeFileLoader).method("setState").args(instanceOf(CompleteFileLoader)).once();
			state = getState();
			verify(fakeFileLoader);
		}
		
		[Test]
		public function stubAlgorithmDispatchesThreeErrorEvents_stateWithThreeAttempts_verifyIfStateTransitionWasCalled(): void
		{
			var seq:Sequence = sequence();
			
			stub(fakeAlgorithm).method("load").dispatches(new Event(Event.OPEN))
				.dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR)).once().ordered(seq);
			
			stub(fakeAlgorithm).method("load").dispatches(new ErrorEvent(ErrorEvent.ERROR)).once().ordered(seq);
				
			stub(fakeAlgorithm).method("load").dispatches(new ErrorEvent(ErrorEvent.ERROR)).once().ordered(seq);
			
			fakeFileLoader.addEventListener(LoaderErrorEvent.FAILED, 
				function(event:LoaderErrorEvent):void
				{
					//listener only to not popup flash player error window
				}
			, false, 0, true);
			
			mock(fakeFileLoader).method("setState").args(instanceOf(FailedFileLoader)).once();
			state = getState();
			verify(fakeFileLoader);
		}
		
		[Test]
		public function stubAlgorithmDispatchesSecurityErrorEvent_verifyIfStateTransitionWasCalled(): void
		{
			stub(fakeAlgorithm).method("load").dispatches(new Event(Event.OPEN))
				.dispatches(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR));
			
			fakeFileLoader.addEventListener(LoaderErrorEvent.FAILED, 
				function(event:LoaderErrorEvent):void
				{
					//listener only to not popup flash player error window
				}
			, false, 0, true);
			
			mock(fakeFileLoader).method("setState").args(instanceOf(FailedFileLoader)).once();
			
			state = getState();
			
			verify(fakeFileLoader);
		}
		
		[Test(async, timeout=200)]
		public function stubAlgorithmDispatchesOpenEvent_waitForStateToDispatchOpenEventOnItsLoader(): void
		{
			Async.proceedOnEvent(this, fakeFileLoader, LoaderEvent.OPEN, 200);
			
			stub(fakeAlgorithm).method("load").dispatches(new Event(Event.OPEN));
			
			state = getState();
		}
		
		[Test(async, timeout=200)]
		public function stubAlgorithmDispatchesCompleteEvent_waitForStateToDispatchCompleteEventOnItsLoader(): void
		{
			Async.proceedOnEvent(this, fakeFileLoader, LoaderEvent.COMPLETE, 200);
			
			stub(fakeAlgorithm).method("load").dispatches(new Event(Event.OPEN), 50)
				.dispatches(new Event(Event.COMPLETE), 100);
			
			state = getState();
		}
		
		[Test(async, timeout=200)]
		public function stubAlgorithmDispatchesHttpStatusEvent_waitForStateToDispatchHttpStatusEventOnItsLoader(): void
		{
			Async.proceedOnEvent(this, fakeFileLoader, LoaderEvent.HTTP_STATUS, 200);
			
			stub(fakeAlgorithm).method("load").dispatches(new Event(Event.OPEN), 50)
				.dispatches(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS), 100);
			
			state = getState();
		}
		
		[Test(async, timeout=200)]
		public function stubAlgorithmDispatchesInitEvent_waitForStateToDispatchInitEventOnItsLoader(): void
		{
			Async.proceedOnEvent(this, fakeFileLoader, LoaderEvent.INIT, 200);
			
			stub(fakeAlgorithm).method("load").dispatches(new Event(Event.OPEN), 50)
				.dispatches(new Event(Event.INIT), 100);
			
			state = getState();
		}
		
		[Test(async, timeout=200)]
		public function stubAlgorithmDispatchesSecurityErrorEvent_waitForStateToDispatchFailedErrorEventOnItsLoader(): void
		{
			Async.proceedOnEvent(this, fakeFileLoader, LoaderErrorEvent.FAILED, 200);
			
			stub(fakeAlgorithm).method("load").dispatches(new Event(Event.OPEN), 50)
				.dispatches(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR), 100);
			
			state = getState();
		}
		
	}

}