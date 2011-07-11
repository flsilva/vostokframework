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
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.assetmanagement.AssetManagementContext;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetPackage;
	import org.vostokframework.assetmanagement.domain.AssetPackageIdentification;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.ElaboratePriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.PriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.StatefulLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.QueueLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.StubAssetLoaderFactory;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorRepository;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicy;
	import org.vostokframework.loadingmanagement.report.LoadedAssetReport;
	import org.vostokframework.loadingmanagement.report.LoadedAssetRepository;

	import flash.display.MovieClip;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class AssetLoadingServiceTests
	{
		private static const ASSET_PACKAGE_ID:String = "asset-package-1";
		private static const QUEUE_ID:String = "queue-1";
		
		public var assetLoadingService:AssetLoadingService;
		public var queueLoadingService:QueueLoadingService;
		public var asset1:Asset;
		public var asset2:Asset;
		
		public function AssetLoadingServiceTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			LoadingManagementContext.getInstance().setAssetLoaderFactory(new StubAssetLoaderFactory());
			LoadingManagementContext.getInstance().setLoaderRepository(new LoaderRepository());
			LoadingManagementContext.getInstance().setLoadedAssetRepository(new LoadedAssetRepository());
			LoadingManagementContext.getInstance().setLoadingMonitorRepository(new LoadingMonitorRepository());
			
			var policy:LoadingPolicy = new LoadingPolicy(LoadingManagementContext.getInstance().loaderRepository);
			policy.globalMaxConnections = LoadingManagementContext.getInstance().maxConcurrentConnections;
			policy.localMaxConnections = LoadingManagementContext.getInstance().maxConcurrentQueues;
			
			var queue:PriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			var globalQueueLoader:QueueLoader = new QueueLoader("GlobalQueueLoader", LoadPriority.MEDIUM, queue);
			LoadingManagementContext.getInstance().setGlobalQueueLoader(globalQueueLoader);
			
			assetLoadingService = new AssetLoadingService();
			queueLoadingService = new QueueLoadingService();
			
			var identification:AssetPackageIdentification = new AssetPackageIdentification(ASSET_PACKAGE_ID, VostokFramework.CROSS_LOCALE_ID);
			var assetPackage:AssetPackage = AssetManagementContext.getInstance().assetPackageFactory.create(identification);
			asset1 = AssetManagementContext.getInstance().assetFactory.create("QueueLoadingServiceTests/asset/image-01.jpg", assetPackage);
			asset2 = AssetManagementContext.getInstance().assetFactory.create("QueueLoadingServiceTests/asset/image-02.jpg", assetPackage);
		}
		
		[After]
		public function tearDown(): void
		{
			assetLoadingService = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getLoader():StatefulLoader
		{
			return null;
		}
		
		//////////////////////////////////////////
		// AssetLoadingService().getAssetData() //
		//////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function getAssetData_invalidAssetIdArgument_ThrowsError(): void
		{
			assetLoadingService.getAssetData(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function getAssetData_notExistingAsset_ThrowsError(): void
		{
			assetLoadingService.getAssetData(asset1.identification.id);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function getAssetData_notLoadedAsset_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			queueLoadingService.load(QUEUE_ID, list, null, 1);
			assetLoadingService.getAssetData(asset2.identification.id);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function getAssetData_loadingAsset_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			queueLoadingService.load(QUEUE_ID, list);
			assetLoadingService.getAssetData(asset1.identification.id);
		}
		
		[Test]
		public function getAssetData_loadedAsset_ReturnsValidObject(): void
		{
			var report:LoadedAssetReport = new LoadedAssetReport(asset1.identification, QUEUE_ID, new MovieClip(), AssetType.SWF, asset1.src);
			LoadingManagementContext.getInstance().loadedAssetRepository.add(report);
			
			var data:* = assetLoadingService.getAssetData(asset1.identification.id);
			Assert.assertNotNull(data);
		}
		
		////////////////////////////////////////////////////
		// AssetLoadingService().getAssetLoadingMonitor() //
		////////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function getAssetLoadingMonitor_invalidAssetIdArgument_ThrowsError(): void
		{
			assetLoadingService.getAssetLoadingMonitor(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoadingMonitorNotFoundError")]
		public function getAssetLoadingMonitor_notExistingMonitor_ThrowsError(): void
		{
			assetLoadingService.getAssetLoadingMonitor(asset1.identification.id);
		}
		
		[Test]
		public function getAssetLoadingMonitor_existingMonitor_ReturnsValidObject(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			queueLoadingService.load(QUEUE_ID, list);
			
			var monitor:ILoadingMonitor = assetLoadingService.getAssetLoadingMonitor(asset1.identification.id);
			Assert.assertNotNull(monitor);
		}
		
		//////////////////////////////////////
		// AssetLoadingService().isLoaded() //
		//////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function isLoaded_invalidAssetIdArgument_ThrowsError(): void
		{
			assetLoadingService.isLoaded(null);
		}
		
		[Test]
		public function isLoaded_notExistingAsset_ReturnsFalse(): void
		{
			var isLoaded:Boolean = assetLoadingService.isLoaded(asset1.identification.id);
			Assert.assertFalse(isLoaded);
		}
		
		[Test]
		public function isLoaded_queuedAsset_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			queueLoadingService.load(QUEUE_ID, list, null, 1);
			
			var isLoaded:Boolean = assetLoadingService.isLoaded(asset2.identification.id);
			Assert.assertFalse(isLoaded);
		}
		
		[Test]
		public function isLoaded_loadingAsset_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			queueLoadingService.load(QUEUE_ID, list);
			
			var isLoaded:Boolean = assetLoadingService.isLoaded(asset1.identification.id);
			Assert.assertFalse(isLoaded);
		}
		
		[Test]
		public function isLoaded_loadedAsset_ReturnsTrue(): void
		{
			var report:LoadedAssetReport = new LoadedAssetReport(asset1.identification, QUEUE_ID, new MovieClip(), AssetType.SWF, asset1.src);
			LoadingManagementContext.getInstance().loadedAssetRepository.add(report);
			
			var isLoaded:Boolean = assetLoadingService.isLoaded(asset1.identification.id);
			Assert.assertTrue(isLoaded);
		}
		
		///////////////////////////////////////
		// AssetLoadingService().isLoading() //
		///////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function isLoading_invalidAssetIdArgument_ThrowsError(): void
		{
			assetLoadingService.isLoading(null);
		}
		
		[Test]
		public function isLoading_notExistingAsset_ReturnsFalse(): void
		{
			var isLoading:Boolean = assetLoadingService.isLoading(asset1.identification.id);
			Assert.assertFalse(isLoading);
		}
		
		[Test]
		public function isLoading_loadingAsset_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			queueLoadingService.load(QUEUE_ID, list);
			
			var isLoading:Boolean = assetLoadingService.isLoading(asset1.identification.id);
			Assert.assertTrue(isLoading);
		}
		
		[Test]
		public function isLoading_notLoadingAsset_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			queueLoadingService.load(QUEUE_ID, list, null, 1);
			
			var isLoading:Boolean = assetLoadingService.isLoading(asset2.identification.id);
			Assert.assertFalse(isLoading);
		}
		
		//////////////////////////////////////
		// AssetLoadingService().isQueued() //
		//////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function isQueued_invalidAssetIdArgument_ThrowsError(): void
		{
			assetLoadingService.isQueued(null);
		}
		
		[Test]
		public function isQueued_notExistingAsset_ReturnsFalse(): void
		{
			var isQueued:Boolean = assetLoadingService.isQueued(asset1.identification.id);
			Assert.assertFalse(isQueued);
		}
		
		[Test]
		public function isQueued_queuedAsset_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			queueLoadingService.load(QUEUE_ID, list, null, 1);
			
			var isQueued:Boolean = assetLoadingService.isQueued(asset2.identification.id);
			Assert.assertTrue(isQueued);
		}
		
		[Test]
		public function isQueued_loadingAsset_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			queueLoadingService.load(QUEUE_ID, list);
			
			var isQueued:Boolean = assetLoadingService.isQueued(asset1.identification.id);
			Assert.assertFalse(isQueued);
		}
		
	}

}