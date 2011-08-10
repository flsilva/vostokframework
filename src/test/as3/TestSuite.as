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

package 
{
	import org.vostokframework.assetmanagement.domain.AssetFactoryTests;
	import org.vostokframework.assetmanagement.domain.AssetPackageFactoryTests;
	import org.vostokframework.assetmanagement.domain.AssetPackageRepositoryTests;
	import org.vostokframework.assetmanagement.domain.AssetPackageTests;
	import org.vostokframework.assetmanagement.domain.AssetRepositoryTests;
	import org.vostokframework.assetmanagement.domain.AssetTests;
	import org.vostokframework.assetmanagement.domain.UrlAssetParserTests;
	import org.vostokframework.assetmanagement.services.AssetPackageServiceTests;
	import org.vostokframework.assetmanagement.services.AssetServiceTests;
	import org.vostokframework.loadingmanagement.domain.VostokLoaderTests;
	import org.vostokframework.loadingmanagement.domain.loaders.LoaderAlgorithmTests;
	import org.vostokframework.loadingmanagement.domain.loaders.QueueLoadingAlgorithmTests;
	import org.vostokframework.loadingmanagement.domain.monitors.CompositeLoadingMonitorTests;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorTests;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorTestsIntegration;
	import org.vostokframework.loadingmanagement.domain.policies.ElaborateLoadingPolicyTests;
	import org.vostokframework.loadingmanagement.domain.policies.ElaborateLoadingPolicyTestsHighestLowest;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicyTests;
	import org.vostokframework.loadingmanagement.services.QueueLoadingServiceTests;

	/**
	 * @author Flávio Silva
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuite
	{
		
		//org.vostokframework.assetmanagement.domain
		public var assetTests:AssetTests;
		public var assetFactoryTests:AssetFactoryTests;
		public var assetPackageTests:AssetPackageTests;
		public var assetPackageFactoryTests:AssetPackageFactoryTests;
		public var assetRepositoryTests:AssetRepositoryTests;
		public var assetPackageRepositoryTests:AssetPackageRepositoryTests;
		public var urlAssetParserTests:UrlAssetParserTests;
		
		//org.vostokframework.assetmanagement.services
		public var assetServiceTests:AssetServiceTests;
		public var assetPackageServiceTests:AssetPackageServiceTests;
		
		//org.vostokframework.loadingmanagement.domain
		public var vostokLoaderTests:VostokLoaderTests;
		
		//org.vostokframework.loadingmanagement.domain.loaders
		public var loaderAlgorithmTests:LoaderAlgorithmTests;
		public var queueLoadingAlgorithmTests:QueueLoadingAlgorithmTests;
		
		//org.vostokframework.loadingmanagement.domain.monitors
		public var compositeLoadingMonitorTests:CompositeLoadingMonitorTests;
		public var loadingMonitorTests:LoadingMonitorTests;
		public var loadingMonitorTestsIntegration:LoadingMonitorTestsIntegration;
		
		//org.vostokframework.loadingmanagement.domain.policies
		public var loadingPolicyTests:LoadingPolicyTests;
		public var elaborateLoadingPolicyTests:ElaborateLoadingPolicyTests;
		public var elaborateLoadingPolicyTestsHighestLowest:ElaborateLoadingPolicyTestsHighestLowest;
		
		//org.vostokframework.loadingmanagement.services
		//public var assetLoadingServiceTests:AssetLoadingServiceTests;
		public var queueLoadingServiceTests:QueueLoadingServiceTests;
		//public var queueLoadingServiceTestsIntegration:QueueLoadingServiceTestsIntegration;
		
		public function TestSuite()
		{
			
		}

	}

}