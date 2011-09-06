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
	import mockolate.stub;
	import mockolate.verify;

	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.ILoaderState;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingQueueLoaderTestsAddChildren extends QueueLoaderStateTestsAddChildren
	{
		
		public var fakeChildLoader3:ILoader;
		
		public function LoadingQueueLoaderTestsAddChildren()
		{
			
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		override public function getState():ILoaderState
		{
			//these lines are required otherwise LoadingQueueLoader will dispatch
			//LoaderEvent.COMPLETE because its queue is empty
			fakeChildLoader3 = getFakeLoader("fake-loader-3", 3);
			fakeLoadingStatus.allLoaders.put(fakeChildLoader3.identification.toString(), fakeChildLoader3);
			fakeLoadingStatus.queuedLoaders.add(fakeChildLoader3);
			//
			
			return new LoadingQueueLoader(fakeQueueLoader, fakeLoadingStatus, fakePolicy);
		}
		
		[Test]
		public function addChildren_validArgument_checkIfMockPolicyWasCalled(): void
		{
			mock(fakePolicy).method("getNext").anyArgs().once();
			
			state = getState();
			
			var list:IList = new ArrayList();
			list.add(fakeChildLoader1);
			
			state.addChildren(list);
			
			verify(fakePolicy);
		}
		
		[Test]
		public function addChildren_validArgument_checkIfMockChildWasCalled(): void
		{
			stub(fakePolicy).method("getNext").anyArgs().returns(fakeChildLoader1);
			mock(fakeChildLoader1).method("load").once();
			
			state = getState();
			
			var list:IList = new ArrayList();
			list.add(fakeChildLoader1);
			
			state.addChildren(list);
			
			verify(fakeChildLoader1);
		}
		
	}

}