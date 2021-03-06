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
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.domain.loading.ILoaderState;
	import org.vostokframework.domain.loading.ILoaderStateTransition;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class FileLoaderStateTestsSetUp
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(inject="false")]
		public var fakeAlgorithm:IFileLoadingAlgorithm;
		
		[Mock(inject="false")]
		public var fakeFileLoader:ILoaderStateTransition;
		
		public var state:ILoaderState;
		
		public function FileLoaderStateTestsSetUp()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			fakeAlgorithm = nice(IFileLoadingAlgorithm);
			stub(fakeAlgorithm).asEventDispatcher();
			
			fakeFileLoader = nice(ILoaderStateTransition);
			stub(fakeFileLoader).asEventDispatcher();
		}
		
		[After]
		public function tearDown(): void
		{
			fakeAlgorithm = null;
			state = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getState():ILoaderState
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
	}

}