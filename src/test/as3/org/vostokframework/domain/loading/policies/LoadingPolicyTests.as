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

package org.vostokframework.domain.loading.policies
{
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.as3collections.IQueue;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.queues.IndexablePriorityQueue;
	import org.flexunit.Assert;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.ILoaderState;
	import org.vostokframework.domain.loading.LoadPriority;
	import org.vostokframework.domain.loading.StubLoaderRepository;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingPolicyTests
	{
		private static const LOADER_LOCALE:String = VostokFramework.CROSS_LOCALE_ID;
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(inject="false")]
		public var fakeState:ILoaderState;
		
		[Mock(inject="false")]
		public var _fakeLoader1:ILoader;
		
		[Mock(inject="false")]
		public var _fakeLoader2:ILoader;
		
		[Mock(inject="false")]
		public var _fakeLoader3:ILoader;
		
		public var queue:IQueue;
		
		public function LoadingPolicyTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			fakeState = nice(ILoaderState);
			
			_fakeLoader1 = nice(ILoader);
			_fakeLoader2 = nice(ILoader);
			_fakeLoader3 = nice(ILoader);
			
			stub(_fakeLoader1).getter("identification").returns(new VostokIdentification("fake-loader-1", LOADER_LOCALE));
			stub(_fakeLoader2).getter("identification").returns(new VostokIdentification("fake-loader-2", LOADER_LOCALE));
			stub(_fakeLoader3).getter("identification").returns(new VostokIdentification("fake-loader-3", LOADER_LOCALE));
			
			stub(_fakeLoader1).getter("priority").returns(LoadPriority.MEDIUM.ordinal);
			stub(_fakeLoader2).getter("priority").returns(LoadPriority.LOW.ordinal);
			stub(_fakeLoader3).getter("priority").returns(LoadPriority.LOW.ordinal);
			
			stub(_fakeLoader1).method("toString").noArgs().returns("[MOCKOLATE ILoader <fake-loader-1> ]");
			stub(_fakeLoader2).method("toString").noArgs().returns("[MOCKOLATE ILoader <fake-loader-2> ]");
			stub(_fakeLoader3).method("toString").noArgs().returns("[MOCKOLATE ILoader <fake-loader-3> ]");
			
			queue = new IndexablePriorityQueue();
			queue.add(_fakeLoader2);
			queue.add(_fakeLoader1);
		}
		
		[After]
		public function tearDown(): void
		{
			queue = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		protected function getPolicy(totalGlobalConnections:int):ILoadingPolicy
		{
			var repository:StubLoaderRepository = new StubLoaderRepository();
			repository.$openedConnections = totalGlobalConnections;
			
			var policy:ILoadingPolicy = new LoadingPolicy(repository);
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			
			return policy;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		
		
		/////////////////////////////////////
		// LoadingPolicy().getNext() TESTS //
		/////////////////////////////////////
		
		[Test]
		public function getNext_withinLocalAndGlobalMaxConnections_ReturnsValidLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loader:ILoader = policy.getNext(fakeState, queue, new ArrayList());
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_withinLocalAndGlobalMaxConnections_checkIfReturnedCorrectLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loader:ILoader = policy.getNext(fakeState, queue, new ArrayList());
			Assert.assertEquals(_fakeLoader1, loader);
		}
		
		[Test]
		public function getNext_withinLocalAndGlobalMaxConnections_maxLocalConnectionsBoundaryTesting_ReturnsValidLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loader:ILoader = policy.getNext(fakeState, queue, new ArrayList([_fakeLoader1, _fakeLoader2]));
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_exceedsLocalMaxConnections_ReturnsNull(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loader:ILoader = policy.getNext(fakeState, queue, new ArrayList([_fakeLoader1, _fakeLoader2, _fakeLoader3]));
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_withinLocalAndGlobalMaxConnections_maxGlobalConnectionsBoundaryTesting_ReturnsValidLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(5);
			
			var loader:ILoader = policy.getNext(fakeState, queue, new ArrayList());
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_exceedsGlobalMaxConnections_ReturnsNull(): void
		{
			var policy:ILoadingPolicy = getPolicy(6);
			
			var loader:ILoader = policy.getNext(fakeState, queue, new ArrayList());
			Assert.assertNull(loader);
		}
		
	}

}