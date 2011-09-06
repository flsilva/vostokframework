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
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class QueueLoaderStateTestsAddChildren extends QueueLoaderStateTestsSetUp
	{
		
		public function QueueLoaderStateTestsAddChildren()
		{
			
		}
		
		[Test(expects="ArgumentError")]
		public function addChildren_invalidNullArgument_ThrowsError(): void
		{
			state = getState();
			state.addChildren(null);
		}
		
		[Test(expects="org.vostokframework.domain.loading.errors.DuplicateLoaderError")]
		public function addChildren_callTwiceForSameChild_ThrowsError(): void
		{
			state = getState();
			
			var list:IList = new ArrayList();
			list.add(fakeChildLoader1);
			
			state.addChildren(list);
			state.addChildren(list);
		}
		
		[Test]
		public function addChildren_validArgument_Void(): void
		{
			state = getState();
			
			var list:IList = new ArrayList();
			list.add(fakeChildLoader1);
			
			state.addChildren(list);
		}
		
		[Test]
		public function addChildren_callContainsChild_ReturnsTrue(): void
		{
			state = getState();
			
			var list:IList = new ArrayList();
			list.add(fakeChildLoader1);
			list.add(fakeChildLoader2);
			
			state.addChildren(list);
			
			var contains:Boolean = state.containsChild(fakeChildLoader2.identification);
			Assert.assertTrue(contains);
		}
		
	}

}