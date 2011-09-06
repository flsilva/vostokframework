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

package org.vostokframework.domain.loading.states.queueloader
{
	import mockolate.mock;
	import mockolate.verify;

	import org.vostokframework.VostokIdentification;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class QueueLoaderStateTestsStopChild extends QueueLoaderStateTestsSetUp
	{
		
		public function QueueLoaderStateTestsStopChild()
		{
			
		}
		
		[Test(expects="ArgumentError")]
		public function stopChild_invalidNullArgument_ThrowsError(): void
		{
			state = getState();
			state.stopChild(null);
		}
		
		[Test(expects="org.vostokframework.domain.loading.errors.LoaderNotFoundError")]
		public function stopChild_notAddedChild_ThrowsError(): void
		{
			state = getState();
			state.stopChild(new VostokIdentification("not-added-id", "any-locale"));
		}
		
		[Test]
		public function stopChild_addedChild_verifyIfMockChildWasCalled(): void
		{
			mock(fakeChildLoader2).method("stop");
			
			state = getState();
			state.addChild(fakeChildLoader1);
			state.addChild(fakeChildLoader2);
			state.stopChild(fakeChildLoader2.identification);
			
			verify(fakeChildLoader2);
		}
		
	}

}