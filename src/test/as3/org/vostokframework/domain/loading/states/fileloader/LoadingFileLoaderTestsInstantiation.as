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

package org.vostokframework.domain.loading.states.fileloader
{
	import mockolate.mock;
	import mockolate.stub;
	import mockolate.verify;

	import org.as3collections.lists.ArrayList;
	import org.flexunit.async.Async;
	import org.hamcrest.object.instanceOf;
	import org.vostokframework.domain.loading.ILoaderState;
	import org.vostokframework.domain.loading.events.LoaderErrorEvent;
	import org.vostokframework.domain.loading.events.LoaderEvent;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.events.FileLoadingAlgorithmErrorEvent;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.events.FileLoadingAlgorithmEvent;

	import flash.events.Event;

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
			return new LoadingFileLoader(fakeFileLoader, fakeAlgorithm);
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
			stub(fakeAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN))
				.dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.COMPLETE));
			
			mock(fakeFileLoader).method("setState").args(instanceOf(CompleteFileLoader)).once();
			
			state = getState();
			
			verify(fakeFileLoader);
		}
		
		[Test]
		public function stubAlgorithmDispatchesFailedErrorEvent_verifyIfStateTransitionWasCalled(): void
		{
			stub(fakeAlgorithm).method("load").dispatches(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, new ArrayList()));
			
			fakeFileLoader.addEventListener(LoaderErrorEvent.FAILED, 
				function(event:LoaderErrorEvent):void
				{
					// must catch this error event here
					// to not popup flash player error window
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
			
			stub(fakeAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN));
			
			state = getState();
		}
		
		[Test(async, timeout=200)]
		public function stubAlgorithmDispatchesCompleteEvent_waitForStateToDispatchCompleteEventOnItsLoader(): void
		{
			Async.proceedOnEvent(this, fakeFileLoader, LoaderEvent.COMPLETE, 200);
			
			stub(fakeAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN), 50)
				.dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.COMPLETE), 100);
			
			state = getState();
		}
		
		[Test(async, timeout=200)]
		public function stubAlgorithmDispatchesHttpStatusEvent_waitForStateToDispatchHttpStatusEventOnItsLoader(): void
		{
			Async.proceedOnEvent(this, fakeFileLoader, LoaderEvent.HTTP_STATUS, 200);
			
			stub(fakeAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN), 50)
				.dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.HTTP_STATUS), 100);
			
			state = getState();
		}
		
		[Test(async, timeout=200)]
		public function stubAlgorithmDispatchesInitEvent_waitForStateToDispatchInitEventOnItsLoader(): void
		{
			Async.proceedOnEvent(this, fakeFileLoader, LoaderEvent.INIT, 200);
			
			stub(fakeAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN), 50)
				.dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.INIT), 100);
			
			state = getState();
		}
		
		[Test(async, timeout=200)]
		public function stubAlgorithmDispatchesFailedErrorEvent_waitForStateToDispatchFailedErrorEventOnItsLoader(): void
		{
			Async.proceedOnEvent(this, fakeFileLoader, LoaderErrorEvent.FAILED, 200);
			
			stub(fakeAlgorithm).method("load").dispatches(new Event(Event.OPEN), 50)
				.dispatches(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, new ArrayList()), 100);
			
			state = getState();
		}
		
	}

}