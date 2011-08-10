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

package org.vostokframework.loadingmanagement.domain.policies
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
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.StubLoaderRepository;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.LoadingAlgorithm;

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
		public var fakeAlgorithm:LoadingAlgorithm;
		
		[Mock(inject="false")]
		public var _fakeLoader1:VostokLoader;
		
		[Mock(inject="false")]
		public var _fakeLoader2:VostokLoader;
		
		[Mock(inject="false")]
		public var _fakeLoader3:VostokLoader;
		
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
			fakeAlgorithm = nice(LoadingAlgorithm);
			
			_fakeLoader1 = nice(VostokLoader, null, [new VostokIdentification("fake-loader-1", LOADER_LOCALE), fakeAlgorithm, LoadPriority.MEDIUM, 3]);
			_fakeLoader2 = nice(VostokLoader, null, [new VostokIdentification("fake-loader-2", LOADER_LOCALE), fakeAlgorithm, LoadPriority.LOW, 3]);
			_fakeLoader3 = nice(VostokLoader, null, [new VostokIdentification("fake-loader-3", LOADER_LOCALE), fakeAlgorithm, LoadPriority.LOW, 3]);
			
			stub(_fakeLoader1).getter("identification").returns(new VostokIdentification("fake-loader-1", LOADER_LOCALE));
			stub(_fakeLoader2).getter("identification").returns(new VostokIdentification("fake-loader-2", LOADER_LOCALE));
			stub(_fakeLoader3).getter("identification").returns(new VostokIdentification("fake-loader-3", LOADER_LOCALE));
			
			stub(_fakeLoader1).getter("priority").returns(LoadPriority.MEDIUM.ordinal);
			stub(_fakeLoader2).getter("priority").returns(LoadPriority.LOW.ordinal);
			stub(_fakeLoader3).getter("priority").returns(LoadPriority.LOW.ordinal);
			
			stub(_fakeLoader1).method("toString").noArgs().returns("[VostokLoader <fake-loader-1>]");
			stub(_fakeLoader2).method("toString").noArgs().returns("[VostokLoader <fake-loader-2>]");
			stub(_fakeLoader3).method("toString").noArgs().returns("[VostokLoader <fake-loader-3>]");
			
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
			
			//stub(fakeAlgorithm).getter("openedConnections").returns(0);
			
			var loader:VostokLoader = policy.getNext(fakeAlgorithm, queue, new ArrayList());
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_withinLocalAndGlobalMaxConnections_checkIfReturnedCorrectLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			//stub(fakeAlgorithm).getter("openedConnections").returns(0);
			
			var loader:VostokLoader = policy.getNext(fakeAlgorithm, queue, new ArrayList());
			Assert.assertEquals(_fakeLoader1, loader);
		}
		
		[Test]
		public function getNext_withinLocalAndGlobalMaxConnections_maxLocalConnectionsBoundaryTesting_ReturnsValidLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			//stub(fakeAlgorithm).getter("openedConnections").returns(2);
			
			var loader:VostokLoader = policy.getNext(fakeAlgorithm, queue, new ArrayList([_fakeLoader1, _fakeLoader2]));
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_exceedsLocalMaxConnections_ReturnsNull(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			//stub(fakeAlgorithm).getter("openedConnections").returns(3);
			
			var loader:VostokLoader = policy.getNext(fakeAlgorithm, queue, new ArrayList([_fakeLoader1, _fakeLoader2, _fakeLoader3]));
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_withinLocalAndGlobalMaxConnections_maxGlobalConnectionsBoundaryTesting_ReturnsValidLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(5);
			
			//stub(fakeAlgorithm).getter("openedConnections").returns(0);
			
			var loader:VostokLoader = policy.getNext(fakeAlgorithm, queue, new ArrayList());
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_exceedsGlobalMaxConnections_ReturnsNull(): void
		{
			var policy:ILoadingPolicy = getPolicy(6);
			
			//stub(fakeAlgorithm).getter("openedConnections").returns(0);
			
			var loader:VostokLoader = policy.getNext(fakeAlgorithm, queue, new ArrayList());
			Assert.assertNull(loader);
		}
		
	}

}