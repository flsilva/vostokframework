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
	import org.vostokframework.loadingmanagement.domain.LoaderStatus;
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
	import org.vostokframework.loadingmanagement.domain.loaders.StubQueueLoader;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorRepository;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicy;
	import org.vostokframework.loadingmanagement.report.LoadedAssetReport;
	import org.vostokframework.loadingmanagement.report.LoadedAssetRepository;

	import flash.display.MovieClip;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=999999)]
	public class QueueLoadingServiceTests
	{
		private static const QUEUE_ID:String = "queue-1";
		private static const ASSET_PACKAGE_ID:String = "asset-package-1";
		
		//[Rule]
		//public var mocks:MockolateRule = new MockolateRule();
		
		//[Mock(inject="false")]
		//public var _fakeAsset:Asset;
		
		public var service:QueueLoadingService;
		public var asset1:Asset;
		public var asset2:Asset;
		
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
			asset1 = AssetManagementContext.getInstance().assetFactory.create("QueueLoadingServiceTests/asset/image-01.jpg", assetPackage);
			asset2 = AssetManagementContext.getInstance().assetFactory.create("QueueLoadingServiceTests/asset/image-02.jpg", assetPackage);
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
		
		public function getLoader():StatefulLoader
		{
			return null;
		}
		
		//////////////////////////////////////////////
		// QueueLoadingService().addAssetsInQueue() //
		//////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function addAssetsInQueue_invalidQueueIdArgument_ThrowsError(): void
		{
			service.addAssetsInQueue(null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function addAssetsInQueue_invalidIListArgument_ThrowsError(): void
		{
			service.addAssetsInQueue(QUEUE_ID, null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function addAssetsInQueue_notExistingQueue_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.addAssetsInQueue(QUEUE_ID, list);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError")]
		public function addAssetsInQueue_dupplicateAsset_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.addAssetsInQueue(QUEUE_ID, list);
		}
		
		[Test]
		public function addAssetsInQueue_loadingQueue_Void(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.addAssetsInQueue(QUEUE_ID, list2);
		}
		
		[Test]
		public function addAssetsInQueue_loadingQueue_checkIfAddedAssetLoaderExistsInRepository_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.addAssetsInQueue(QUEUE_ID, list2);
			
			var exists:Boolean = LoadingManagementContext.getInstance().loaderRepository.exists(asset2.identification.toString());
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function addAssetsInQueue_loadingQueue_checkIfAssetLoadingMonitorExistsInRepository_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.addAssetsInQueue(QUEUE_ID, list2);
			
			var exists:Boolean = LoadingManagementContext.getInstance().loadingMonitorRepository.exists(asset2.identification.toString());
			Assert.assertTrue(exists);
		}
		
		////////////////////////////////////////////////
		// QueueLoadingService().cancelQueueLoading() //
		////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function cancelQueueLoading_invalidQueueIdArgument_ThrowsError(): void
		{
			service.cancelQueueLoading(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function cancelQueueLoading_notExistingQueue_ThrowsError(): void
		{
			service.cancelQueueLoading(QUEUE_ID);
		}
		
		[Test]
		public function cancelQueueLoading_loadingQueue_Void(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.cancelQueueLoading(QUEUE_ID);
		}
		
		[Test]
		public function cancelQueueLoading_loadingQueue_checkIfQueueExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.cancelQueueLoading(QUEUE_ID);
			
			var exists:Boolean = service.queueExists(QUEUE_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancelQueueLoading_loadingQueue_callLoadOnceThenCallCancelAndThenCallLoadAgain_checkIfQueueLoaderExistsInRepository_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.cancelQueueLoading(QUEUE_ID);
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = LoadingManagementContext.getInstance().loaderRepository.exists(QUEUE_ID);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function cancelQueueLoading_stoppedQueue_Void(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stopQueueLoading(QUEUE_ID);
			service.cancelQueueLoading(QUEUE_ID);
		}
		
		[Test]
		public function cancelQueueLoading_stoppedQueue_checkIfQueueExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stopQueueLoading(QUEUE_ID);
			service.cancelQueueLoading(QUEUE_ID);
			
			var exists:Boolean = service.queueExists(QUEUE_ID);
			Assert.assertFalse(exists);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function cancelQueueLoading_canceledQueue_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.cancelQueueLoading(QUEUE_ID);
			service.cancelQueueLoading(QUEUE_ID);
		}
		
		////////////////////////////////////////////////////
		// QueueLoadingService().getQueueLoadingMonitor() //
		////////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function getQueueLoadingMonitor_invalidQueueIdArgument_ThrowsError(): void
		{
			service.getQueueLoadingMonitor(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoadingMonitorNotFoundError")]
		public function getQueueLoadingMonitor_notExistingMonitor_ThrowsError(): void
		{
			service.getQueueLoadingMonitor(QUEUE_ID);
		}
		
		[Test]
		public function getQueueLoadingMonitor_existingMonitor_ReturnsValidObject(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var monitor:ILoadingMonitor = service.getQueueLoadingMonitor(QUEUE_ID);
			Assert.assertNotNull(monitor);
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
		
		[Test]
		public function isQueueLoading_loadingQueue_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var isLoading:Boolean = service.isQueueLoading(QUEUE_ID);
			Assert.assertTrue(isLoading);
		}
		
		[Test]
		public function isQueueLoading_notLoadingQueue_ReturnsFalse(): void
		{
			var queueLoader:QueueLoader = new StubQueueLoader(QUEUE_ID);
			LoadingManagementContext.getInstance().loaderRepository.add(queueLoader);
			//TODO: pensar em substituir hard coded stubs por mockolate stubs
			var isLoading:Boolean = service.isQueueLoading(QUEUE_ID);
			Assert.assertFalse(isLoading);
		}
		
		//////////////////////////////////
		// QueueLoadingService().load() //
		//////////////////////////////////
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError")]
		public function load_duplicateQueueId_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.load(QUEUE_ID, list);
		}
		
		[Test(expects="ArgumentError")]
		public function load_duplicateAssetInSameQueue_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError")]
		public function load_duplicateAssetInDifferentQueues_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.load("another-queue-id", list);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.DuplicateLoadedAssetError")]
		public function load_assetAlreadyLoadedAndCached_ThrowsError(): void
		{
			var report:LoadedAssetReport = new LoadedAssetReport(asset1.identification, QUEUE_ID, new MovieClip(), AssetType.SWF, asset1.src);
			LoadingManagementContext.getInstance().loadedAssetRepository.add(report);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
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
			list.add(asset1);
			
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
			list.add(asset1);
			
			service.load(QUEUE_ID, list, LoadPriority.MEDIUM, 0);
		}
		
		[Test]
		public function load_validArguments_ReturnsILoadingMonitor(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			var monitor:ILoadingMonitor = service.load(QUEUE_ID, list);
			Assert.assertNotNull(monitor);
		}
		
		[Test]
		public function load_validArguments_CheckIfQueueLoaderStatusIsConnecting_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var queueLoader:StatefulLoader = LoadingManagementContext.getInstance().loaderRepository.find(QUEUE_ID);
			
			Assert.assertEquals(LoaderStatus.CONNECTING, queueLoader.status);
		}
		
		[Test]
		public function load_validArguments_checkIfQueueLoaderExistsInRepository_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = LoadingManagementContext.getInstance().loaderRepository.exists(QUEUE_ID);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function load_validArguments_checkIfAssetLoaderExistsInRepository_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = LoadingManagementContext.getInstance().loaderRepository.exists(asset1.identification.toString());
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function load_validArguments_checkIfQueueLoadingMonitorExistsInRepository_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = LoadingManagementContext.getInstance().loadingMonitorRepository.exists(QUEUE_ID);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function load_validArguments_checkIfAssetLoadingMonitorExistsInRepository_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = LoadingManagementContext.getInstance().loadingMonitorRepository.exists(asset1.identification.toString());
			Assert.assertTrue(exists);
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
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = service.queueExists(QUEUE_ID);
			Assert.assertTrue(exists);
		}
		
		////////////////////////////////////////////////
		// QueueLoadingService().resumeQueueLoading() //
		////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function resumeQueueLoading_invalidQueueIdArgument_ThrowsError(): void
		{
			service.resumeQueueLoading(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function resumeQueueLoading_notExistingQueue_ThrowsError(): void
		{
			service.resumeQueueLoading(QUEUE_ID);
		}
		
		[Test]
		public function resumeQueueLoading_stoppedQueue_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stopQueueLoading(QUEUE_ID);
			
			var resumed:Boolean = service.resumeQueueLoading(QUEUE_ID);
			Assert.assertTrue(resumed);
		}
		
		[Test]
		public function resumeQueueLoading_loadingQueue_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var resumed:Boolean = service.resumeQueueLoading(QUEUE_ID);
			Assert.assertFalse(resumed);
		}
		
		[Test]
		public function resumeQueueLoading_stoppedQueue_CheckIfQueueLoaderStatusIsConnecting_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stopQueueLoading(QUEUE_ID);
			service.resumeQueueLoading(QUEUE_ID);
			
			var queueLoader:StatefulLoader = LoadingManagementContext.getInstance().loaderRepository.find(QUEUE_ID);
			
			Assert.assertEquals(LoaderStatus.CONNECTING, queueLoader.status);
		}
		
		//////////////////////////////////////////////
		// QueueLoadingService().stopQueueLoading() //
		//////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function stopQueueLoading_invalidQueueIdArgument_ThrowsError(): void
		{
			service.stopQueueLoading(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function stopQueueLoading_notExistingQueue_ThrowsError(): void
		{
			service.stopQueueLoading(QUEUE_ID);
		}
		
		[Test]
		public function stopQueueLoading_loadingQueue_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var stopped:Boolean = service.stopQueueLoading(QUEUE_ID);
			Assert.assertTrue(stopped);
		}
		
		[Test]
		public function stopQueueLoading_notLoadingQueue_ReturnsFalse(): void
		{
			var queueLoader:QueueLoader = new StubQueueLoader(QUEUE_ID);
			LoadingManagementContext.getInstance().loaderRepository.add(queueLoader);
			//TODO: pensar em substituir hard coded stubs por mockolate stubs
			var stopped:Boolean = service.stopQueueLoading(QUEUE_ID);
			Assert.assertFalse(stopped);
		}
		
		[Test]
		public function stopQueueLoading_loadingQueue_CheckIfQueueLoaderStatusIsStopped_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stopQueueLoading(QUEUE_ID);
			
			var queueLoader:StatefulLoader = LoadingManagementContext.getInstance().loaderRepository.find(QUEUE_ID);
			
			Assert.assertEquals(LoaderStatus.STOPPED, queueLoader.status);
		}
		
	}

}