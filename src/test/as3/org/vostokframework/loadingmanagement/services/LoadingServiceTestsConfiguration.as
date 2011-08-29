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

package org.vostokframework.loadingmanagement.services
{
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.assetmanagement.AssetManagementContext;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetPackage;
	import org.vostokframework.assetmanagement.domain.AssetPackageIdentification;
	import org.vostokframework.assetmanagement.domain.AssetPackageRepository;
	import org.vostokframework.assetmanagement.domain.AssetRepository;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.ILoader;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.loaders.StubVostokLoaderFactory;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorRepository;
	import org.vostokframework.loadingmanagement.report.LoadedAssetRepository;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsConfiguration
	{
		private static const ASSET_PACKAGE_ID:String = "asset-package-1";
		
		public var service:LoadingService;
		public var asset1:Asset;
		public var asset2:Asset;
		public var asset3:Asset;
		public var asset4:Asset;
		
		public function LoadingServiceTestsConfiguration()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			AssetManagementContext.getInstance().setAssetPackageRepository(new AssetPackageRepository());
			AssetManagementContext.getInstance().setAssetRepository(new AssetRepository());
			
			LoadingManagementContext.getInstance().setAssetLoaderFactory(new StubVostokLoaderFactory());
			LoadingManagementContext.getInstance().setLoaderRepository(new LoaderRepository());
			LoadingManagementContext.getInstance().setLoadedAssetRepository(new LoadedAssetRepository());
			LoadingManagementContext.getInstance().setLoadingMonitorRepository(new LoadingMonitorRepository());
			
			LoadingManagementContext.getInstance().setMaxConcurrentConnections(4);
			LoadingManagementContext.getInstance().setMaxConcurrentQueues(2);
			
			/*var policy:ILoadingPolicy = new ElaborateLoadingPolicy(LoadingManagementContext.getInstance().loaderRepository);
			policy.globalMaxConnections = LoadingManagementContext.getInstance().maxConcurrentConnections;
			policy.localMaxConnections = LoadingManagementContext.getInstance().maxConcurrentQueues;
			
			var queueLoadingAlgorithm:LoadingAlgorithm = new QueueLoadingAlgorithm(policy);
			var identification:VostokIdentification = new VostokIdentification("GlobalQueueLoader", VostokFramework.CROSS_LOCALE_ID);
			var globalQueueLoader:ILoader = new VostokLoader(identification, queueLoadingAlgorithm, LoadPriority.MEDIUM);*/
			var identification:VostokIdentification = new VostokIdentification("GlobalQueueLoader", VostokFramework.CROSS_LOCALE_ID);
			var globalQueueLoader:ILoader = LoadingManagementContext.getInstance().loaderFactory.createComposite(identification, LoadingManagementContext.getInstance().loaderRepository, LoadPriority.MEDIUM, LoadingManagementContext.getInstance().maxConcurrentConnections, LoadingManagementContext.getInstance().maxConcurrentQueues);//TODO:refactor this line
			LoadingManagementContext.getInstance().setGlobalQueueLoader(globalQueueLoader);
			
			service = new LoadingService();
			
			var packageIdentification:AssetPackageIdentification = new AssetPackageIdentification(ASSET_PACKAGE_ID, VostokFramework.CROSS_LOCALE_ID);
			var assetPackage:AssetPackage = AssetManagementContext.getInstance().assetPackageFactory.create(packageIdentification);
			asset1 = AssetManagementContext.getInstance().assetFactory.create("LoadingServiceTestsConfiguration/asset/image-01.jpg", assetPackage);
			asset2 = AssetManagementContext.getInstance().assetFactory.create("LoadingServiceTestsConfiguration/asset/image-02.jpg", assetPackage);
			asset3 = AssetManagementContext.getInstance().assetFactory.create("LoadingServiceTestsConfiguration/asset/image-03.jpg", assetPackage);
			asset4 = AssetManagementContext.getInstance().assetFactory.create("LoadingServiceTestsConfiguration/asset/image-04.jpg", assetPackage);
			
			AssetManagementContext.getInstance().assetPackageRepository.add(assetPackage);
			AssetManagementContext.getInstance().assetRepository.add(asset1);
			AssetManagementContext.getInstance().assetRepository.add(asset2);
			AssetManagementContext.getInstance().assetRepository.add(asset3);
			AssetManagementContext.getInstance().assetRepository.add(asset4);
		}
		
		[After]
		public function tearDown(): void
		{
			service = null;
			asset1 = null;
			asset2 = null;
			asset3 = null;
			asset4 = null;
		}
		
	}

}