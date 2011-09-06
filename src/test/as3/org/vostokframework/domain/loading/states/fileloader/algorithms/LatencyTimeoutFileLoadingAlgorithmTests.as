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

package org.vostokframework.loadingmanagement.domain.states.fileloader.algorithms
{
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;

	import org.flexunit.async.Async;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.FileLoadingAlgorithmErrorEvent;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.FileLoadingAlgorithmEvent;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.IFileLoadingAlgorithm;

	import flash.display.MovieClip;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LatencyTimeoutFileLoadingAlgorithmTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		public var algorithm:IFileLoadingAlgorithm;
		
		[Mock(inject="false")]
		public var fakeWrappedAlgorithm:IFileLoadingAlgorithm;
		
		public function LatencyTimeoutFileLoadingAlgorithmTests()
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
		
		public function getAlgorithm(latencyTimeout:Number):IFileLoadingAlgorithm
		{
			return new LatencyTimeoutFileLoadingAlgorithm(fakeWrappedAlgorithm, latencyTimeout);
		}
		
		///////////
		// TESTS //
		///////////
		
		[Test]
		public function load_verifyIfMockWrappedAlgorithmWasCalled(): void
		{
			mock(fakeWrappedAlgorithm).method("load").once();
			
			algorithm = getAlgorithm(1000);
			algorithm.load();
			
			verify(fakeWrappedAlgorithm);
		}
		
		[Test(async, timeout=2000)]
		public function load_latencyTimeoutOneSecond_stubWrappedAlgorithmDelaysTwoSecondsToDispatchOpenEvent_waitForFileLoadingAlgorithmFailedErrorEvent(): void
		{
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN), 2000);
			
			algorithm = getAlgorithm(1000);
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmErrorEvent.FAILED, 2000);
			algorithm.load();
		}
		
		[Test(async, timeout=2000)]
		public function load_latencyTimeoutTwoSeconds_stubWrappedAlgorithmDelaysOneSecondToDispatchOpenEvent_waitForFileLoadingAlgorithmOpenEvent(): void
		{
			stub(fakeWrappedAlgorithm).method("load").dispatches(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN), 1000);
			
			algorithm = getAlgorithm(2000);
			Async.proceedOnEvent(this, algorithm, FileLoadingAlgorithmEvent.OPEN, 2000);
			algorithm.load();
		}
		
	}

}