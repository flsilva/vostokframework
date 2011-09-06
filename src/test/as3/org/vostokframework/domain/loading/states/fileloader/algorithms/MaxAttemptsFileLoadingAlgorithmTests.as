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
	import mockolate.ingredients.Sequence;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.sequence;
	import mockolate.stub;

	import org.as3collections.IListMap;
	import org.as3collections.maps.ArrayListMap;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.domain.loading.LoadError;
	import org.vostokframework.domain.loading.states.fileloader.FileLoadingAlgorithmErrorEvent;
	import org.vostokframework.domain.loading.states.fileloader.FileLoadingAlgorithmEvent;
	import org.vostokframework.domain.loading.states.fileloader.IFileLoadingAlgorithm;

	import flash.display.MovieClip;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class MaxAttemptsFileLoadingAlgorithmTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		public var algorithm:IFileLoadingAlgorithm;
		
		[Mock(inject="false")]
		public var fakeWrappedAlgorithm:IFileLoadingAlgorithm;
		
		public function MaxAttemptsFileLoadingAlgorithmTests()
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
		
		public function getAlgorithm(maxAttempts:int):IFileLoadingAlgorithm
		{
			return new MaxAttemptsFileLoadingAlgorithm(fakeWrappedAlgorithm, maxAttempts);
		}
		
		///////////
		// TESTS //
		///////////
		
		[Test(async, timeout=200)]
		public function load_stubWrappedAlgorithmDispatchesTwoFailedErrorEventsAndOneCompleteEvent_algorithmWithThreeAttempts_waitForFileLoadingAlgorithmCompleteEvent(): void
		{
			var seq:Sequence = sequence();
			
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN))
				.dispatches(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, new ArrayListMap())).once().ordered(seq);
			
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, new ArrayListMap())).once().ordered(seq);
				
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.COMPLETE)).once().ordered(seq);
			
			algorithm = getAlgorithm(3);
			
			algorithm.addEventListener(FileLoadingAlgorithmErrorEvent.FAILED, 
				function():void
				{
					// only to ensure that this event is not dispatched
					Assert.fail("FileLoadingAlgorithmErrorEvent.FAILED shouldn't be dispatched.");
				}
			, false, 0, true);
			
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmEvent.COMPLETE, 200);
			algorithm.load();
		}
		
		[Test(async, timeout=200)]
		public function load_stubWrappedAlgorithmDispatchesThreeFailedErrorEvents_algorithmWithThreeAttempts_waitForFileLoadingAlgorithmFailedErrorEvent(): void
		{
			var seq:Sequence = sequence();
			
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN))
				.dispatches(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, new ArrayListMap())).once().ordered(seq);
			
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, new ArrayListMap())).once().ordered(seq);
				
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, new ArrayListMap())).once().ordered(seq);
			
			algorithm = getAlgorithm(3);
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmErrorEvent.FAILED, 200);
			algorithm.load();
		}
		
		[Test(async, timeout=200)]
		public function load_stubWrappedAlgorithmDispatchesOneFailedErrorEvent_algorithmWithOneAttempt_waitForFileLoadingAlgorithmFailedErrorEvent(): void
		{
			var seq:Sequence = sequence();
			
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN))
				.dispatches(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, new ArrayListMap())).once().ordered(seq);
			
			algorithm = getAlgorithm(1);
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmErrorEvent.FAILED, 200);
			algorithm.load();
		}
		
		[Test(async, timeout=200)]
		public function load_stubWrappedAlgorithmDispatchesOneFailedErrorEventWithSecurityError_algorithmWithThreeAttempts_waitForFileLoadingAlgorithmFailedErrorEvent(): void
		{
			var errors:IListMap = new ArrayListMap();
			errors.put(LoadError.SECURITY_ERROR, "");
			
			var seq:Sequence = sequence();
			
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN))
				.dispatches(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, errors)).once().ordered(seq);
			
			algorithm = getAlgorithm(3);
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmErrorEvent.FAILED, 200);
			algorithm.load();
		}
	}

}