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

package org.vostokframework.loadingmanagement.policies
{
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.vostokframework.loadingmanagement.LoadingRequestPriority;
	import org.vostokframework.loadingmanagement.StubRequestLoader;
	import org.vostokframework.loadingmanagement.assetloaders.StubAssetLoaderRepository;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=12)]
	public class RequestLoadingPolicyTests
	{
		
		public function RequestLoadingPolicyTests()
		{
			
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		
		
		//////////////////////////////////////////
		// RequestLoadingPolicy().allow() TESTS //
		//////////////////////////////////////////
		
		[Test]
		public function allow_withinLocalAndGlobalMaxConnections_ReturnsTrue(): void
		{
			var repository:StubAssetLoaderRepository = new StubAssetLoaderRepository();
			repository.$totalLoading = 0;
			
			var policy:RequestLoadingPolicy = new RequestLoadingPolicy(repository);
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			
			var allowed:Boolean = policy.allow(0, new ArrayList(), new StubRequestLoader("request-loader-id"));
			Assert.assertTrue(allowed);
		}
		
		[Test]
		public function allow_withinLocalAndGlobalMaxConnections_maxLocalConnectionsBoundaryTesting_ReturnsTrue(): void
		{
			var repository:StubAssetLoaderRepository = new StubAssetLoaderRepository();
			repository.$totalLoading = 0;
			
			var policy:RequestLoadingPolicy = new RequestLoadingPolicy(repository);
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			
			var allowed:Boolean = policy.allow(2, new ArrayList(), new StubRequestLoader("request-loader-id"));
			Assert.assertTrue(allowed);
		}
		
		[Test]
		public function allow_exceedsLocalMaxConnections_ReturnsFalse(): void
		{
			var repository:StubAssetLoaderRepository = new StubAssetLoaderRepository();
			repository.$totalLoading = 0;
			
			var policy:RequestLoadingPolicy = new RequestLoadingPolicy(repository);
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			
			var allowed:Boolean = policy.allow(3, new ArrayList(), new StubRequestLoader("request-loader-id"));
			Assert.assertFalse(allowed);
		}
		
		[Test]
		public function allow_withinLocalAndGlobalMaxConnections_maxGlobalConnectionsBoundaryTesting_ReturnsTrue(): void
		{
			var repository:StubAssetLoaderRepository = new StubAssetLoaderRepository();
			repository.$totalLoading = 5;
			
			var policy:RequestLoadingPolicy = new RequestLoadingPolicy(repository);
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			
			var allowed:Boolean = policy.allow(0, new ArrayList(), new StubRequestLoader("request-loader-id"));
			Assert.assertTrue(allowed);
		}
		
		[Test]
		public function allow_exceedsGlobalMaxConnections_ReturnsFalse(): void
		{
			var repository:StubAssetLoaderRepository = new StubAssetLoaderRepository();
			repository.$totalLoading = 6;
			
			var policy:RequestLoadingPolicy = new RequestLoadingPolicy(repository);
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			
			var allowed:Boolean = policy.allow(0, new ArrayList(), new StubRequestLoader("request-loader-id"));
			Assert.assertFalse(allowed);
		}
		
		[Test]
		public function allow_withinLocalAndGlobalMaxConnections_sendingLoaderLowestPriorityWithLoadingListNotContainingOnlyLowestPriority_ReturnsFalse(): void
		{
			var repository:StubAssetLoaderRepository = new StubAssetLoaderRepository();
			repository.$totalLoading = 0;
			
			var policy:RequestLoadingPolicy = new RequestLoadingPolicy(repository);
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			
			var loading:IList = new ArrayList();
			loading.add(new StubRequestLoader("request-loader-id", LoadingRequestPriority.HIGH));
			
			var allowed:Boolean = policy.allow(0, loading, new StubRequestLoader("request-loader-id", LoadingRequestPriority.LOWEST));
			Assert.assertFalse(allowed);
		}
		
		[Test]
		public function allow_withinLocalAndGlobalMaxConnections_sendingLoaderLowestPriorityWithLoadingListContainingOnlyLowestPriority_ReturnsTrue(): void
		{
			var repository:StubAssetLoaderRepository = new StubAssetLoaderRepository();
			repository.$totalLoading = 5;
			
			var policy:RequestLoadingPolicy = new RequestLoadingPolicy(repository);
			policy.localMaxConnections = 3;
			policy.globalMaxConnections = 6;
			
			var loading:IList = new ArrayList();
			loading.add(new StubRequestLoader("request-loader-id", LoadingRequestPriority.LOWEST));
			
			var allowed:Boolean = policy.allow(0, loading, new StubRequestLoader("request-loader-id", LoadingRequestPriority.LOWEST));
			Assert.assertTrue(allowed);
		}
		
	}

}