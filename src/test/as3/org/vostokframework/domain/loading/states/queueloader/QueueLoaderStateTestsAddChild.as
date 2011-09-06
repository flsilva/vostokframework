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
	import org.flexunit.Assert;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class QueueLoaderStateTestsAddChild extends QueueLoaderStateTestsSetUp
	{
		
		public function QueueLoaderStateTestsAddChild()
		{
			
		}
		
		[Test(expects="ArgumentError")]
		public function addChild_invalidNullArgument_ThrowsError(): void
		{
			state = getState();
			state.addChild(null);
		}
		
		[Test(expects="org.vostokframework.domain.loading.errors.DuplicateLoaderError")]
		public function addChild_callTwiceForSameChild_ThrowsError(): void
		{
			state = getState();
			state.addChild(fakeChildLoader1);
			state.addChild(fakeChildLoader1);
		}
		
		[Test]
		public function addChild_validArgument_Void(): void
		{
			state = getState();
			state.addChild(fakeChildLoader1);
		}
		
		[Test]
		public function addChild_callContainsChild_ReturnsTrue(): void
		{
			state = getState();
			state.addChild(fakeChildLoader1);
			
			var contains:Boolean = state.containsChild(fakeChildLoader1.identification);
			Assert.assertTrue(contains);
		}
		
	}

}