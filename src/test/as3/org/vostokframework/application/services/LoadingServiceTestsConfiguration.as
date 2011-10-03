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

package org.vostokframework.application.services
{
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.application.AssetsContext;
	import org.vostokframework.application.LoadingContext;
	import org.vostokframework.application.LoadingSettingsRepository;
	import org.vostokframework.application.cache.CachedAssetDataRepository;
	import org.vostokframework.application.monitoring.LoadingMonitorRepository;
	import org.vostokframework.domain.assets.Asset;
	import org.vostokframework.domain.assets.AssetPackage;
	import org.vostokframework.domain.assets.AssetPackageRepository;
	import org.vostokframework.domain.assets.AssetRepository;
	import org.vostokframework.domain.loading.GlobalLoadingSettings;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.LoadPriority;
	import org.vostokframework.domain.loading.LoaderRepository;
	import org.vostokframework.domain.loading.states.fileloader.adapters.StubDataLoaderFactory;

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
			AssetsContext.getInstance().setAssetPackageRepository(new AssetPackageRepository());
			AssetsContext.getInstance().setAssetRepository(new AssetRepository());
			
			LoadingContext.getInstance().loaderFactory.fileLoadingAlgorithmFactory.setDataLoaderFactory(new StubDataLoaderFactory());
			
			LoadingContext.getInstance().setLoadingSettingsRepository(new LoadingSettingsRepository());
			LoadingContext.getInstance().setCachedAssetDataRepository(new CachedAssetDataRepository());
			LoadingContext.getInstance().setLoaderRepository(new LoaderRepository());
			LoadingContext.getInstance().setLoadingMonitorRepository(new LoadingMonitorRepository());
			LoadingContext.getInstance().globalLoadingSettings.maxConcurrentConnections = 4;
			LoadingContext.getInstance().setMaxConcurrentQueues(2);
			
			var identification:VostokIdentification = new VostokIdentification("GlobalQueueLoader", VostokFramework.CROSS_LOCALE_ID);
			var loaderRepository:LoaderRepository = LoadingContext.getInstance().loaderRepository;
			var globalLoadingSettings:GlobalLoadingSettings = LoadingContext.getInstance().globalLoadingSettings;
			var maxConcurrentQueues:int = LoadingContext.getInstance().maxConcurrentQueues;
			var globalQueueLoader:ILoader = LoadingContext.getInstance().loaderFactory.createComposite(identification, loaderRepository, globalLoadingSettings, LoadPriority.MEDIUM, maxConcurrentQueues);
			LoadingContext.getInstance().setGlobalQueueLoader(globalQueueLoader);
			
			service = new LoadingService();
			
			var assetPackageService:AssetPackageService = new AssetPackageService();
			var assetPackage:AssetPackage = assetPackageService.createAssetPackage(ASSET_PACKAGE_ID);
			
			var assetService:AssetService = new AssetService();
			asset1 = assetService.createAsset("LoadingServiceTestsConfiguration/asset/image-01.jpg", assetPackage);
			asset2 = assetService.createAsset("LoadingServiceTestsConfiguration/asset/image-02.jpg", assetPackage);
			asset3 = assetService.createAsset("LoadingServiceTestsConfiguration/asset/image-03.jpg", assetPackage);
			asset4 = assetService.createAsset("LoadingServiceTestsConfiguration/asset/image-04.jpg", assetPackage);
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
		
		public function turnOnDataLoaderSuccessBehaviorAsync():void
		{
			var stubDataLoaderFactory:StubDataLoaderFactory = new StubDataLoaderFactory();
			stubDataLoaderFactory.successBehaviorAsync = true;
			LoadingContext.getInstance().loaderFactory.fileLoadingAlgorithmFactory.setDataLoaderFactory(stubDataLoaderFactory);
		}
		
	}

}