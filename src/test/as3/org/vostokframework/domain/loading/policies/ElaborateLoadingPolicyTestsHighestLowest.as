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
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;

	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.loading.GlobalLoadingSettings;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.LoadPriority;
	import org.vostokframework.domain.loading.StubLoaderRepository;
	import org.vostokframework.domain.loading.states.queueloader.QueueLoadingStatus;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class ElaborateLoadingPolicyTestsHighestLowest
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		//[Mock(inject="false")]
		//public var fakeState:ILoaderState;
		
		[Mock(inject="false")]
		public var _fakeLoader1:ILoader;
		
		[Mock(inject="false")]
		public var _fakeLoader2:ILoader;
		
		public var queueLoadingStatus:QueueLoadingStatus;
		
		public function ElaborateLoadingPolicyTestsHighestLowest()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			//fakeState = nice(ILoaderState);
			queueLoadingStatus = new QueueLoadingStatus();
		}
		
		[After]
		public function tearDown(): void
		{
			queueLoadingStatus = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		protected function getPolicy(totalGlobalConnections:int):ILoadingPolicy
		{
			var repository:StubLoaderRepository = new StubLoaderRepository();
			repository.$openedConnections = totalGlobalConnections;
			
			var globalLoadingSettings:GlobalLoadingSettings = GlobalLoadingSettings.getInstance();
			globalLoadingSettings.maxConcurrentConnections = 6;
			
			var policy:ILoadingPolicy = new ElaborateLoadingPolicy(repository, globalLoadingSettings);
			//policy.localMaxConnections = 2;
			//policy.globalMaxConnections = 6;
			
			return policy;
		}
		
		public function getLoader(id:String, priority:LoadPriority):ILoader
		{
			var loader:ILoader = nice(ILoader);
			stub(loader).getter("identification").returns(new VostokIdentification(id, VostokFramework.CROSS_LOCALE_ID));
			stub(loader).getter("priority").returns(priority.ordinal);
			stub(loader).method("toString").noArgs().returns("[MOCKOLATE ILoader <" + id + "> ]");
			
			return loader;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		
		
		//////////////////////////////////////////////
		// ElaborateLoadingPolicy().process() TESTS //
		//////////////////////////////////////////////
		
		[Test]
		public function process_highAndHighestInQueue_verifyLoadWasCalledOnHighestLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderHigh:ILoader = getLoader("loader-high", LoadPriority.HIGH);
			var loaderHighest:ILoader = getLoader("loader-highest", LoadPriority.HIGHEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderHigh);
			queueLoadingStatus.queuedLoaders.add(loaderHighest);
			
			mock(loaderHighest).method("load").once();
			policy.process(queueLoadingStatus, 3);
			verify(loaderHighest);
		}
		
		[Test]
		public function process_highAndHighestInQueue_verifyLoadWasNotCalledOnHighLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderHigh:ILoader = getLoader("loader-high", LoadPriority.HIGH);
			var loaderHighest:ILoader = getLoader("loader-highest", LoadPriority.HIGHEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderHigh);
			queueLoadingStatus.queuedLoaders.add(loaderHighest);
			
			mock(loaderHigh).method("load").never();
			policy.process(queueLoadingStatus, 3);
			verify(loaderHigh);
		}
		
		[Test]
		public function process_onlyOneHighInQueue_highestInLoadings_verifyLoadWasNotCalledOnHighLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderHigh:ILoader = getLoader("loader-high", LoadPriority.HIGH);
			var loaderHighest:ILoader = getLoader("loader-highest", LoadPriority.HIGHEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderHigh);
			queueLoadingStatus.loadingLoaders.add(loaderHighest);
			
			mock(loaderHigh).method("load").never();
			policy.process(queueLoadingStatus, 3);
			verify(loaderHigh);
		}
		
		[Test]
		public function process_onlyOneHighestInQueue_highInLoadings_verifyLoadWasCalledOnHighestLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderHigh:ILoader = getLoader("loader-high", LoadPriority.HIGH);
			var loaderHighest:ILoader = getLoader("loader-highest", LoadPriority.HIGHEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderHighest);
			queueLoadingStatus.loadingLoaders.add(loaderHigh);
			
			mock(loaderHighest).method("load").once();
			policy.process(queueLoadingStatus, 3);
			verify(loaderHighest);
		}
		
		[Test]
		public function process_onlyOneHighestInQueue_highInLoadings_verifyStopWasCalledOnHighLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderHigh:ILoader = getLoader("loader-high", LoadPriority.HIGH);
			var loaderHighest:ILoader = getLoader("loader-highest", LoadPriority.HIGHEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderHighest);
			queueLoadingStatus.loadingLoaders.add(loaderHigh);
			
			mock(loaderHigh).method("stop").once();
			policy.process(queueLoadingStatus, 3);
			verify(loaderHigh);
		}
		
		[Test]
		public function process_lowAndLowestInQueue_verifyLoadWasCalledOnLowLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLow:ILoader = getLoader("loader-low", LoadPriority.LOW);
			var loaderLowest:ILoader = getLoader("loader-lowest", LoadPriority.LOWEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderLow);
			queueLoadingStatus.queuedLoaders.add(loaderLowest);
			
			mock(loaderLow).method("load").once();
			policy.process(queueLoadingStatus, 3);
			verify(loaderLow);
		}
		
		[Test]
		public function process_lowAndLowestInQueue_verifyLoadWasNotCalledOnLowestLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLow:ILoader = getLoader("loader-low", LoadPriority.LOW);
			var loaderLowest:ILoader = getLoader("loader-lowest", LoadPriority.LOWEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderLow);
			queueLoadingStatus.queuedLoaders.add(loaderLowest);
			
			mock(loaderLowest).method("load").never();
			policy.process(queueLoadingStatus, 3);
			verify(loaderLowest);
		}
		
		[Test]
		public function process_onlyOneLowestInQueue_lowInLoadings_verifyLoadWasNotCalledOnLowestLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLow:ILoader = getLoader("loader-low", LoadPriority.LOW);
			var loaderLowest:ILoader = getLoader("loader-lowest", LoadPriority.LOWEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderLowest);
			queueLoadingStatus.loadingLoaders.add(loaderLow);
			
			mock(loaderLowest).method("load").never();
			policy.process(queueLoadingStatus, 3);
			verify(loaderLowest);
		}
		
		[Test]
		public function process_onlyOneLowestInQueue_noneLoading_verifyLoadWasCalledOnLowestLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLowest:ILoader = getLoader("loader-lowest", LoadPriority.LOWEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderLowest);
			
			mock(loaderLowest).method("load").once();
			policy.process(queueLoadingStatus, 3);
			verify(loaderLowest);
		}
		
		[Test]
		public function process_onlyOneLowestInQueue_anotherLowestInLoadings_verifyLoadWasCalledOnQueuedLowestLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLowest1:ILoader = getLoader("loader-lowest-1", LoadPriority.LOWEST);
			var loaderLowest2:ILoader = getLoader("loader-lowest-2", LoadPriority.LOWEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderLowest2);
			queueLoadingStatus.loadingLoaders.add(loaderLowest1);
			
			mock(loaderLowest2).method("load").once();
			policy.process(queueLoadingStatus, 3);
			verify(loaderLowest2);
		}
		
		[Test]
		public function process_onlyOneLowInQueue_lowestInLoadings_verifyLoadWasCalledOnLowLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLow:ILoader = getLoader("loader-low", LoadPriority.LOW);
			var loaderLowest:ILoader = getLoader("loader-lowest", LoadPriority.LOWEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderLow);
			queueLoadingStatus.loadingLoaders.add(loaderLowest);
			
			mock(loaderLow).method("load").once();
			policy.process(queueLoadingStatus, 3);
			verify(loaderLow);
		}
		
		[Test]
		public function process_onlyOneLowInQueue_lowestInLoadings_verifyStopWasCalledOnLowestLoader(): void
		{
			var policy:ILoadingPolicy = getPolicy(0);
			
			var loaderLow:ILoader = getLoader("loader-low", LoadPriority.LOW);
			var loaderLowest:ILoader = getLoader("loader-lowest", LoadPriority.LOWEST);
			
			queueLoadingStatus.queuedLoaders.add(loaderLow);
			queueLoadingStatus.loadingLoaders.add(loaderLowest);
			
			mock(loaderLowest).method("stop").once();
			policy.process(queueLoadingStatus, 3);
			verify(loaderLowest);
		}
		
	}

}