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
	import org.vostokframework.loadingmanagement.domain.RefinedLoader;
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
	[TestCase(order=99999)]
	public class QueueLoadingServiceTests
	{
		private static const QUEUE_ID:String = "queue-1";
		private static const ASSET_PACKAGE_ID:String = "asset-package-1";
		
		//[Rule]
		//public var mocks:MockolateRule = new MockolateRule();
		
		//[Mock(inject="false")]
		//public var _fakeAsset:Asset;
		
		public var service:QueueLoadingService;
		public var asset:Asset;
		
		public function QueueLoadingServiceTests()
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
			
			service = new QueueLoadingService();
			
			var identification:AssetPackageIdentification = new AssetPackageIdentification(ASSET_PACKAGE_ID, VostokFramework.CROSS_LOCALE_ID);
			var assetPackage:AssetPackage = AssetManagementContext.getInstance().assetPackageFactory.create(identification);
			asset = AssetManagementContext.getInstance().assetFactory.create("QueueLoadingServiceTests/asset/image-01.jpg", assetPackage);
			//_fakeAsset = nice(Asset, null, [ASSET_ID, "QueueLoadingServiceTests/asset/image-01.jpg", AssetType.IMAGE, LoadPriority.MEDIUM]);
		}
		
		[After]
		public function tearDown(): void
		{
			service = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getLoader():RefinedLoader
		{
			return null;
		}
		
		////////////////////////////////////////////
		// QueueLoadingService().isQueueLoading() //
		////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function isQueueLoading_invalidQueueIdArgument_ThrowsError(): void
		{
			service.isQueueLoading(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function isQueueLoading_notExistingQueue_ThrowsError(): void
		{
			service.isQueueLoading(QUEUE_ID);
		}
		
		[Test(order=999999)]
		public function isQueueLoading_loadingQueue_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset);
			
			service.load(QUEUE_ID, list);
			trace("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
			trace("globalQueueLoader.status: " + LoadingManagementContext.getInstance().globalQueueLoader.status);
			
			var isLoading:Boolean = service.isQueueLoading(QUEUE_ID);
			Assert.assertTrue(isLoading);
		}
		
		//////////////////////////////////
		// QueueLoadingService().load() //
		//////////////////////////////////
		
		[Test]
		public function load_validArguments_ReturnsILoadingMonitor(): void
		{
			var list:IList = new ArrayList();
			list.add(asset);
			
			var monitor:ILoadingMonitor = service.load(QUEUE_ID, list);
			Assert.assertNotNull(monitor);
		}
		
		[Test]
		public function load_validArguments_checkIfQueueLoadingMonitorExistsInRepository_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = LoadingManagementContext.getInstance().loadingMonitorRepository.exists(QUEUE_ID);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function load_validArguments_checkIfAssetLoadingMonitorExistsInRepository_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = LoadingManagementContext.getInstance().loadingMonitorRepository.exists(asset.identification.toString());
			Assert.assertTrue(exists);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError")]
		public function load_duplicateQueueId_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset);
			
			service.load(QUEUE_ID, list);
			service.load(QUEUE_ID, list);
		}
		
		[Test(expects="ArgumentError")]
		public function load_duplicateAssetInSameQueue_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset);
			list.add(asset);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError")]
		public function load_duplicateAssetInDifferentQueues_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset);
			
			service.load(QUEUE_ID, list);
			service.load("another-queue-id", list);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.DuplicateLoadedAssetError")]
		public function load_assetAlreadyLoadedAndCached_ThrowsError(): void
		{
			var report:LoadedAssetReport = new LoadedAssetReport(asset.identification, QUEUE_ID, new MovieClip(), AssetType.SWF, asset.src);
			LoadingManagementContext.getInstance().loadedAssetRepository.add(report);
			
			var list:IList = new ArrayList();
			list.add(asset);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(expects="org.as3coreaddendum.errors.ClassCastError")]
		public function load_assetsArgumentWithIncorrectType_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add("INVALID TYPE");
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(expects="ArgumentError")]
		public function load_invalidNullQueueIdArgument_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset);
			
			service.load(null, list);
		}
		
		[Test(expects="ArgumentError")]
		public function load_invalidNullAssetsArgument_ThrowsError(): void
		{
			service.load(QUEUE_ID, null);
		}
		
		[Test(expects="ArgumentError")]
		public function load_invalidEmptyAssetsArgument_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			
			service.load(null, list);
		}
		
		[Test(expects="ArgumentError")]
		public function load_invalidConcurrentConnectionsArgument_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset);
			
			service.load(QUEUE_ID, list, LoadPriority.MEDIUM, 0);
		}
		
		/////////////////////////////////////////
		// QueueLoadingService().queueExists() //
		/////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function queueExists_invalidQueueIdArgument_ThrowsError(): void
		{
			service.queueExists(null);
		}
		
		[Test]
		public function queueExists_notExistingQueue_ReturnsFalse(): void
		{
			var exists:Boolean = service.queueExists(QUEUE_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function queueExists_existingQueue_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = service.queueExists(QUEUE_ID);
			Assert.assertTrue(exists);
		}
		
	}

}