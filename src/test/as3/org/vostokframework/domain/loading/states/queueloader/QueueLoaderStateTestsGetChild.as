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

package org.vostokframework.loadingmanagement.domain.states.queueloader
{
	import org.flexunit.Assert;
	import org.vostokframework.loadingmanagement.domain.ILoader;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class QueueLoaderStateTestsGetChild extends QueueLoaderStateTestsSetUp
	{
		
		public function QueueLoaderStateTestsGetChild()
		{
			
		}
		
		[Test(expects="ArgumentError")]
		public function getChild_invalidNullArgument_ThrowsError(): void
		{
			state = getState();
			state.getChild(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function getChild_notAddedChild_ThrowsError(): void
		{
			state = getState();
			state.getChild(fakeChildLoader1.identification);
		}
		
		[Test]
		public function getChild_addedChild_ReturnsValidObject(): void
		{
			state = getState();
			
			fakeLoadingStatus.allLoaders.put(fakeChildLoader1.identification.toString(), fakeChildLoader1);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader1);
			
			var child:ILoader = state.getChild(fakeChildLoader1.identification);
			Assert.assertNotNull(child);
		}
		
	}

}