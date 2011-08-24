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
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;

	import org.as3collections.IList;
	import org.as3collections.IQueue;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.queues.IndexablePriorityQueue;
	import org.flexunit.Assert;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.StubLoaderRepository;
	import org.vostokframework.loadingmanagement.domain.ILoader;
	import org.vostokframework.loadingmanagement.domain.loaders.LoadingAlgorithm;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class ElaborateLoadingPolicyTestsHighestLowest
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(inject="false")]
		public var fakeAlgorithm:LoadingAlgorithm;
		
		[Mock(inject="false")]
		public var _fakeLoader1:ILoader;
		
		[Mock(inject="false")]
		public var _fakeLoader2:ILoader;
		
		public var queue:IQueue;
		
		public function ElaborateLoadingPolicyTestsHighestLowest()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			fakeAlgorithm = nice(LoadingAlgorithm, null, [1]);
			
			//_fakeLoader1 = nice(ILoader, null, ["fake-loader-1", fakeAlgorithm, LoadPriority.MEDIUM, 3]);
			//_fakeLoader2 = nice(ILoader, null, ["fake-loader-2", fakeAlgorithm, LoadPriority.LOW, 3]);
			
			//stub(_fakeLoader1).getter("id").returns("fake-loader-1");
			//stub(_fakeLoader2).getter("id").returns("fake-loader-2");
			
			queue = new IndexablePriorityQueue();
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
			
			var policy:ILoadingPolicy = new ElaborateLoadingPolicy(repository);
			policy.localMaxConnections = 2;
			policy.globalMaxConnections = 6;
			
			return policy;
		}
		
		public function getLoader(id:String, priority:LoadPriority):ILoader
		{
			var loader:ILoader = nice(ILoader, null, [new VostokIdentification(id, VostokFramework.CROSS_LOCALE_ID), fakeAlgorithm, priority, 3]);
			stub(loader).getter("identification").returns(new VostokIdentification(id, VostokFramework.CROSS_LOCALE_ID));
			stub(loader).getter("priority").returns(priority.ordinal);
			stub(loader).method("toString").noArgs().returns("[ILoader <" + new VostokIdentification(id, VostokFramework.CROSS_LOCALE_ID) + ">]");
			
			return loader;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		
		
		//////////////////////////////////////////////
		// ElaborateLoadingPolicy().getNext() TESTS //
		//////////////////////////////////////////////
		
		[Test]
		public function getNext_highAndHighestInQueue_ReturnsHighest(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderHigh:ILoader = getLoader("loader-high", LoadPriority.HIGH);
			var loaderHighest:ILoader = getLoader("loader-highest", LoadPriority.HIGHEST);
			
			queue.add(loaderHigh);
			queue.add(loaderHighest);
			
			var loadings:IList = new ArrayList();
			
			var loader:ILoader = policy.getNext(fakeAlgorithm, queue, loadings);
			Assert.assertEquals(loaderHighest, loader);
		}
		
		[Test]
		public function getNext_onlyOneHighInQueue_highestInLoadings_ReturnsNull(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderHigh:ILoader = getLoader("loader-high", LoadPriority.HIGH);
			var loaderHighest:ILoader = getLoader("loader-highest", LoadPriority.HIGHEST);
			
			queue.add(loaderHigh);
			
			var loadings:IList = new ArrayList();
			loadings.add(loaderHighest);
			
			var loader:ILoader = policy.getNext(fakeAlgorithm, queue, loadings);
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_onlyOneHighestInQueue_highInLoadings_ReturnsHighestLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderHigh:ILoader = getLoader("loader-high", LoadPriority.HIGH);
			var loaderHighest:ILoader = getLoader("loader-highest", LoadPriority.HIGHEST);
			
			queue.add(loaderHighest);
			
			var loadings:IList = new ArrayList();
			loadings.add(loaderHigh);
			
			var loader:ILoader = policy.getNext(fakeAlgorithm, queue, loadings);
			Assert.assertEquals(loaderHighest, loader);
		}
		
		[Test]
		public function getNext_onlyOneHighestInQueue_highInLoadings_checkIfCalledStopHighLoaderOnAlgorithm(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderHigh:ILoader = getLoader("loader-high", LoadPriority.HIGH);
			var loaderHighest:ILoader = getLoader("loader-highest", LoadPriority.HIGHEST);
			mock(fakeAlgorithm).method("stopLoader").args(loaderHigh.identification);
			
			queue.add(loaderHighest);
			
			var loadings:IList = new ArrayList();
			loadings.add(loaderHigh);
			
			policy.getNext(fakeAlgorithm, queue, loadings);
			verify(fakeAlgorithm);
		}
		
		[Test]
		public function getNext_onlyOneHighestInQueue_oneHighestAndOneHighInLoadings_ReturnsHighestLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderHigh:ILoader = getLoader("loader-high", LoadPriority.HIGH);
			var loaderHighest1:ILoader = getLoader("loader-highest-1", LoadPriority.HIGHEST);
			var loaderHighest2:ILoader = getLoader("loader-highest-2", LoadPriority.HIGHEST);
			
			queue.add(loaderHighest2);
			
			var loadings:IList = new ArrayList();
			loadings.add(loaderHighest1);
			loadings.add(loaderHigh);
			
			var loader:ILoader = policy.getNext(fakeAlgorithm, queue, loadings);
			Assert.assertEquals(loaderHighest2, loader);
		}
		
		[Test]
		public function getNext_lowAndLowestInQueue_ReturnsLow(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLow:ILoader = getLoader("loader-low", LoadPriority.LOW);
			var loaderLowest:ILoader = getLoader("loader-lowest", LoadPriority.LOWEST);
			
			queue.add(loaderLow);
			queue.add(loaderLowest);
			
			var loadings:IList = new ArrayList();
			
			var loader:ILoader = policy.getNext(fakeAlgorithm, queue, loadings);
			Assert.assertEquals(loaderLow, loader);
		}
		
		[Test]
		public function getNext_onlyOneLowestInQueue_lowInLoadings_ReturnsNull(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLow:ILoader = getLoader("loader-low", LoadPriority.LOW);
			var loaderLowest:ILoader = getLoader("loader-lowest", LoadPriority.LOWEST);
			
			queue.add(loaderLowest);
			
			var loadings:IList = new ArrayList();
			loadings.add(loaderLow);
			
			var loader:ILoader = policy.getNext(fakeAlgorithm, queue, loadings);
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_onlyOneLowestInQueue_noneLoading_ReturnsLowest(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLowest:ILoader = getLoader("loader-lowest", LoadPriority.LOWEST);
			
			queue.add(loaderLowest);
			
			var loadings:IList = new ArrayList();
			
			var loader:ILoader = policy.getNext(fakeAlgorithm, queue, loadings);
			Assert.assertEquals(loaderLowest, loader);
		}
		
		[Test]
		public function getNext_onlyOneLowestInQueue_anotherLowestInLoadings_ReturnsOtherLowest(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLowest1:ILoader = getLoader("loader-lowest-1", LoadPriority.LOWEST);
			var loaderLowest2:ILoader = getLoader("loader-lowest-2", LoadPriority.LOWEST);
			
			queue.add(loaderLowest2);
			
			var loadings:IList = new ArrayList();
			loadings.add(loaderLowest1);
			
			var loader:ILoader = policy.getNext(fakeAlgorithm, queue, loadings);
			Assert.assertEquals(loaderLowest2, loader);
		}
		
		[Test]
		public function getNext_onlyOneLowInQueue_lowestInLoadings_ReturnsLowLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLow:ILoader = getLoader("loader-low", LoadPriority.LOW);
			var loaderLowest:ILoader = getLoader("loader-lowest", LoadPriority.LOWEST);
			
			queue.add(loaderLow);
			
			var loadings:IList = new ArrayList();
			loadings.add(loaderLowest);
			
			var loader:ILoader = policy.getNext(fakeAlgorithm, queue, loadings);
			Assert.assertEquals(loaderLow, loader);
		}
		
		[Test]
		public function getNext_onlyOneLowInQueue_lowestInLoadings_checkIfCalledStopLowestLoaderOnAlgorithm(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLow:ILoader = getLoader("loader-low", LoadPriority.LOW);
			var loaderLowest:ILoader = getLoader("loader-lowest", LoadPriority.LOWEST);
			mock(fakeAlgorithm).method("stopLoader").args(loaderLowest.identification);
			
			queue.add(loaderLow);
			
			var loadings:IList = new ArrayList();
			loadings.add(loaderLowest);
			
			policy.getNext(fakeAlgorithm, queue, loadings);
			verify(fakeAlgorithm);
		}
		
	}

}