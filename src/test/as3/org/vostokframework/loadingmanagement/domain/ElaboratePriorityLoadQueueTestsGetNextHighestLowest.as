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

package org.vostokframework.loadingmanagement.domain
{
	import org.flexunit.Assert;
	import org.vostokframework.loadingmanagement.domain.policies.StubLoadingPolicy;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class ElaboratePriorityLoadQueueTestsGetNextHighestLowest
	{
		
		public function ElaboratePriorityLoadQueueTestsGetNextHighestLowest()
		{
			
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getLoader(id:String, priority:LoadPriority):RefinedLoader
		{
			return new StubRefinedLoader(id, 3, priority);
		}
		
		////////////////////////////////////////
		// PlainPriorityLoadQueue().getNext() //
		////////////////////////////////////////
		
		[Test]
		public function getNext_highAndHighestOnQueue_ReturnsHighest(): void
		{
			var policy:StubLoadingPolicy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			var queue:ElaboratePriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			queue.addLoader(getLoader("loader-high", LoadPriority.HIGH));
			queue.addLoader(getLoader("loader-highest", LoadPriority.HIGHEST));
			
			var loader:RefinedLoader = queue.getNext();
			Assert.assertEquals("loader-highest", loader.id);
		}
		
		[Test]
		public function getNext_highAndHighestOnQueue_ReturnsHighestAndMakeItDispatchesComplete_callGetNextAgainMustReturnsHigh(): void
		{
			var policy:StubLoadingPolicy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			var queue:ElaboratePriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			queue.addLoader(getLoader("loader-high", LoadPriority.HIGH));
			queue.addLoader(getLoader("loader-highest", LoadPriority.HIGHEST));
			
			var loader:RefinedLoader = queue.getNext();
			loader.load();
			(loader as StubRefinedLoader).$loadingComplete();
			
			loader = queue.getNext();
			Assert.assertEquals("loader-high", loader.id);
		}
		
		[Test]
		public function getNext_oneHighOnQueue_getNextAndMakeItLoad_thenAddsHighest_getNextMustReturnHighestAndStopHigh_checkIfHighestLoaderWasReturned(): void
		{
			var policy:StubLoadingPolicy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			var queue:ElaboratePriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			queue.addLoader(getLoader("loader-high", LoadPriority.HIGH));
			
			var loader:RefinedLoader = queue.getNext();
			loader.load();
			
			queue.addLoader(getLoader("loader-highest", LoadPriority.HIGHEST));
			loader = queue.getNext();
			
			Assert.assertEquals("loader-highest", loader.id);
		}
		
		[Test]
		public function getNext_oneHighOnQueue_getNextAndMakeItLoad_thenAddsHighest_getNextMustReturnHighestAndStopHigh_checkIfHighLoaderWasStopped(): void
		{
			var policy:StubLoadingPolicy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			var queue:ElaboratePriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			queue.addLoader(getLoader("loader-high", LoadPriority.HIGH));
			
			var loaderHigh:RefinedLoader = queue.getNext();
			loaderHigh.load();
			
			queue.addLoader(getLoader("loader-highest", LoadPriority.HIGHEST));
			queue.getNext();
			
			Assert.assertEquals(LoaderStatus.STOPPED, loaderHigh.status);
		}
		
		[Test]
		public function getNext_oneHighOnQueue_getNextAndMakeItLoad_thenAddsHighestWhileHighIsLoading_highLoaderMustBeStopped_thenHighestDispatchesComplete_getNextMustReturnHighAgain(): void
		{
			var policy:StubLoadingPolicy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			var queue:ElaboratePriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			queue.addLoader(getLoader("loader-high", LoadPriority.HIGH));
			
			var loaderHigh:RefinedLoader = queue.getNext();
			loaderHigh.load();
			
			queue.addLoader(getLoader("loader-highest", LoadPriority.HIGHEST));
			var loaderHighest:RefinedLoader = queue.getNext();
			loaderHighest.load();
			(loaderHighest as StubRefinedLoader).$loadingComplete();
			
			loaderHigh = queue.getNext();
			Assert.assertEquals("loader-high", loaderHigh.id);
		}
		
		[Test]
		public function getNext_lowAndLowestOnQueue_getNextAndMakeItLoad_getNextAgainMustReturnNull(): void
		{
			var policy:StubLoadingPolicy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			var queue:ElaboratePriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			queue.addLoader(getLoader("loader-low", LoadPriority.LOW));
			queue.addLoader(getLoader("loader-lowest", LoadPriority.LOWEST));
			
			var loader:RefinedLoader = queue.getNext();
			loader.load();
			
			loader = queue.getNext();
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_lowAndLowestOnQueue_getNextAndMakeItLoadAndComplete_getNextAgainMustReturnLowest(): void
		{
			var policy:StubLoadingPolicy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			var queue:ElaboratePriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			queue.addLoader(getLoader("loader-low", LoadPriority.LOW));
			queue.addLoader(getLoader("loader-lowest", LoadPriority.LOWEST));
			
			var loader:RefinedLoader = queue.getNext();
			loader.load();
			(loader as StubRefinedLoader).$loadingComplete();
			
			loader = queue.getNext();
			Assert.assertEquals("loader-lowest", loader.id);
		}
		
		[Test]
		public function getNext_twoLowestOnQueue_ReturnsLowestAndMakeItLoad_thenCallGetNextAgainMustReturnOtherLowest(): void
		{
			var policy:StubLoadingPolicy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			var queue:ElaboratePriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			queue.addLoader(getLoader("loader-lowest-1", LoadPriority.LOWEST));
			queue.addLoader(getLoader("loader-lowest-2", LoadPriority.LOWEST));
			
			var loader:RefinedLoader = queue.getNext();
			loader.load();
			
			loader = queue.getNext();
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_oneLowestOnQueue_getNextAndMakeItLoad_thenAddsLow_getNextMustReturnLowAndStopLowest_checkIfLowLoaderWasReturned(): void
		{
			var policy:StubLoadingPolicy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			var queue:ElaboratePriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			queue.addLoader(getLoader("loader-lowest", LoadPriority.LOWEST));
			
			var loader:RefinedLoader = queue.getNext();
			loader.load();
			
			queue.addLoader(getLoader("loader-low", LoadPriority.LOW));
			loader = queue.getNext();
			
			Assert.assertEquals("loader-low", loader.id);
		}
		
		[Test]
		public function getNext_oneLowestOnQueue_getNextAndMakeItLoad_thenAddsLow_getNextMustReturnLowAndStopLowest_checkIfLowestLoaderWasStopped(): void
		{
			var policy:StubLoadingPolicy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			var queue:ElaboratePriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			queue.addLoader(getLoader("loader-lowest", LoadPriority.LOWEST));
			
			var loaderLowest:RefinedLoader = queue.getNext();
			loaderLowest.load();
			
			queue.addLoader(getLoader("loader-low", LoadPriority.LOW));
			queue.getNext();
			
			Assert.assertEquals(LoaderStatus.STOPPED, loaderLowest.status);
		}
		
		[Test]
		public function getNext_oneLowestOnQueue_getNextAndMakeItLoad_thenAddsLowWhileLowestIsLoading_lowestLoaderMustBeStopped_thenLowDispatchesComplete_getNextMustReturnLowestAgain(): void
		{
			var policy:StubLoadingPolicy = new StubLoadingPolicy();
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			policy.totalGlobalConnections = 0;
			
			var queue:ElaboratePriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			queue.addLoader(getLoader("loader-lowest", LoadPriority.LOWEST));
			
			var loaderLowest:RefinedLoader = queue.getNext();
			loaderLowest.load();
			
			queue.addLoader(getLoader("loader-low", LoadPriority.LOW));
			var loaderLow:RefinedLoader = queue.getNext();
			loaderLow.load();
			(loaderLow as StubRefinedLoader).$loadingComplete();
			
			loaderLowest = queue.getNext();
			Assert.assertEquals("loader-lowest", loaderLowest.id);
		}
		
	}

}