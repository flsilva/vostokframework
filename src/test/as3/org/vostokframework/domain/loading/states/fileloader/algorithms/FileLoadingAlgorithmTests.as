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
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.flexunit.async.Async;
	import org.vostokframework.domain.loading.states.fileloader.IDataLoader;
	import org.vostokframework.domain.loading.states.fileloader.IFileLoadingAlgorithm;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.events.FileLoadingAlgorithmErrorEvent;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.events.FileLoadingAlgorithmEvent;

	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class FileLoadingAlgorithmTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		public var algorithm:IFileLoadingAlgorithm;
		
		[Mock(inject="false")]
		public var fakeDataLoader:IDataLoader;
		
		public function FileLoadingAlgorithmTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			fakeDataLoader = nice(IDataLoader);
			stub(fakeDataLoader).asEventDispatcher();
			stub(fakeDataLoader).method("getData").returns(new MovieClip());
			
			algorithm = new FileLoadingAlgorithm(fakeDataLoader);
		}
		
		[After]
		public function tearDown(): void
		{
			
		}
		
		///////////
		// TESTS //
		///////////
		
		[Test(async, timeout=200)]
		public function stubDataLoaderDispatchesOpenEvent_waitForFileLoadingAlgorithmOpenEvent(): void
		{
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmEvent.OPEN, 200);
			stub(fakeDataLoader).method("load").dispatches(new Event(Event.OPEN), 50);
			algorithm.load();
		}
		
		[Test(async, timeout=200)]
		public function stubDataLoaderDispatchesCompleteEvent_waitForFileLoadingAlgorithmCompleteEvent(): void
		{
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmEvent.COMPLETE, 200);
			
			stub(fakeDataLoader).method("load").dispatches(new Event(Event.OPEN), 50)
				.dispatches(new Event(Event.COMPLETE), 100);
			
			algorithm.load();
		}
		
		[Test(async, timeout=200)]
		public function stubDataLoaderDispatchesHttpStatusEvent_waitForFileLoadingAlgorithmHttpStatusEvent(): void
		{
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmEvent.HTTP_STATUS, 200);
			
			stub(fakeDataLoader).method("load").dispatches(new Event(Event.OPEN), 50)
				.dispatches(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS), 100);
			
			algorithm.load();
		}
		
		[Test(async, timeout=200)]
		public function stubDataLoaderDispatchesInitEvent_waitForFileLoadingAlgorithmInitEvent(): void
		{
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmEvent.INIT, 200);
			
			stub(fakeDataLoader).method("load").dispatches(new Event(Event.OPEN), 50)
				.dispatches(new Event(Event.INIT), 100);
			
			algorithm.load();
		}
		
		[Test(async, timeout=200)]
		public function stubDataLoaderDispatchesSecurityErrorEvent_waitForFileLoadingAlgorithmFailedErrorEvent(): void
		{
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmErrorEvent.FAILED, 200);
			
			stub(fakeDataLoader).method("load").dispatches(new Event(Event.OPEN), 50)
				.dispatches(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR), 100);
			
			algorithm.load();
		}
		
		[Test(async, timeout=200)]
		public function stubDataLoaderDispatchesIOErrorEvent_waitForFileLoadingAlgorithmFailedErrorEvent(): void
		{
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmErrorEvent.FAILED, 200);
			
			stub(fakeDataLoader).method("load").dispatches(new Event(Event.OPEN), 50)
				.dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR), 100);
			
			algorithm.load();
		}
		
		[Test(async, timeout=200)]
		public function stubDataLoaderDispatchesErrorEvent_waitForFileLoadingAlgorithmFailedErrorEvent(): void
		{
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmErrorEvent.FAILED, 200);
			
			stub(fakeDataLoader).method("load").dispatches(new Event(Event.OPEN), 50)
				.dispatches(new ErrorEvent(ErrorEvent.ERROR), 100);
			
			algorithm.load();
		}
	}

}