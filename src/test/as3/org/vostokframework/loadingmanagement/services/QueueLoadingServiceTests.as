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
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.assetmanagement.AssetManagementContext;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetPackage;
	import org.vostokframework.assetmanagement.domain.AssetPackageIdentification;
	import org.vostokframework.assetmanagement.domain.AssetPackageRepository;
	import org.vostokframework.assetmanagement.domain.AssetRepository;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.LoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.loaders.QueueLoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.loaders.StubAssetLoaderFactory;
	import org.vostokframework.loadingmanagement.domain.loaders.StubLoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderConnecting;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderStopped;
	import org.vostokframework.loadingmanagement.domain.monitors.CompositeLoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorRepository;
	import org.vostokframework.loadingmanagement.domain.monitors.QueueLoadingMonitorDispatcher;
	import org.vostokframework.loadingmanagement.domain.policies.ElaborateLoadingPolicy;
	import org.vostokframework.loadingmanagement.domain.policies.ILoadingPolicy;
	import org.vostokframework.loadingmanagement.report.LoadedAssetReport;
	import org.vostokframework.loadingmanagement.report.LoadedAssetRepository;

	import flash.display.MovieClip;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=9999999999999999999)]
	public class QueueLoadingServiceTests
	{
		private static const QUEUE1_ID:String = "queue-1";
		private static const QUEUE2_ID:String = "queue-2";
		private static const QUEUE3_ID:String = "queue-3";
		private static const ASSET_PACKAGE_ID:String = "asset-package-1";
		
		//[Rule]
		//public var mocks:MockolateRule = new MockolateRule();
		
		//[Mock(inject="false")]
		//public var _fakeAsset1:Asset;
		
		public var service:QueueLoadingService;
		public var asset1:Asset;
		public var asset2:Asset;
		public var asset3:Asset;
		public var asset4:Asset;
		
		public function QueueLoadingServiceTests()
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
			
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.openBehaviorSync = false;
			stubAssetLoaderFactory.successBehaviorAsync = false;
			stubAssetLoaderFactory.successBehaviorSync = false;
			
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			LoadingManagementContext.getInstance().setLoaderRepository(new LoaderRepository());
			LoadingManagementContext.getInstance().setLoadedAssetRepository(new LoadedAssetRepository());
			LoadingManagementContext.getInstance().setLoadingMonitorRepository(new LoadingMonitorRepository());
			
			LoadingManagementContext.getInstance().setMaxConcurrentConnections(4);
			LoadingManagementContext.getInstance().setMaxConcurrentQueues(2);
			
			var policy:ILoadingPolicy = new ElaborateLoadingPolicy(LoadingManagementContext.getInstance().loaderRepository);
			policy.globalMaxConnections = LoadingManagementContext.getInstance().maxConcurrentConnections;
			policy.localMaxConnections = LoadingManagementContext.getInstance().maxConcurrentQueues;
			
			var queueLoadingAlgorithm:LoadingAlgorithm = new QueueLoadingAlgorithm(policy);
			var identification:VostokIdentification = new VostokIdentification("GlobalQueueLoader", VostokFramework.CROSS_LOCALE_ID);
			var globalQueueLoader:VostokLoader = new VostokLoader(identification, queueLoadingAlgorithm, LoadPriority.MEDIUM, 1);
			LoadingManagementContext.getInstance().setGlobalQueueLoader(globalQueueLoader);
			
			service = new QueueLoadingService();
			
			var packageIdentification:AssetPackageIdentification = new AssetPackageIdentification(ASSET_PACKAGE_ID, VostokFramework.CROSS_LOCALE_ID);
			var assetPackage:AssetPackage = AssetManagementContext.getInstance().assetPackageFactory.create(packageIdentification);
			asset1 = AssetManagementContext.getInstance().assetFactory.create("QueueLoadingServiceTests/asset/image-01.jpg", assetPackage);
			asset2 = AssetManagementContext.getInstance().assetFactory.create("QueueLoadingServiceTests/asset/image-02.jpg", assetPackage);
			asset3 = AssetManagementContext.getInstance().assetFactory.create("QueueLoadingServiceTests/asset/image-03.jpg", assetPackage);
			asset4 = AssetManagementContext.getInstance().assetFactory.create("QueueLoadingServiceTests/asset/image-04.jpg", assetPackage);
			
			AssetManagementContext.getInstance().assetPackageRepository.add(assetPackage);
			AssetManagementContext.getInstance().assetRepository.add(asset1);
			AssetManagementContext.getInstance().assetRepository.add(asset2);
			AssetManagementContext.getInstance().assetRepository.add(asset3);
			
			//_fakeAsset1 = nice(Asset, null, [new AssetIdentification("QueueLoadingServiceTests/asset/image-01.jpg", VostokFramework.CROSS_LOCALE_ID), "QueueLoadingServiceTests/asset/image-01.jpg", AssetType.IMAGE, LoadPriority.MEDIUM]);
		}
		
		[After]
		public function tearDown(): void
		{
			service = null;
		}
		
		////////////////////////////////////
		// QueueLoadingService().cancel() //
		////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function cancel_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.cancel(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function cancel_notExistingLoader_ThrowsError(): void
		{
			service.cancel(QUEUE1_ID);
		}
		
		[Test]
		public function cancel_loadingLoader_Void(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.cancel(QUEUE1_ID);
		}
		
		[Test]
		public function cancel_loadingLoader_checkIfQueueLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.cancel(QUEUE1_ID);
			
			var exists:Boolean = service.exists(QUEUE1_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancel_loadingLoader_checkIfAssetLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.cancel(QUEUE1_ID);
			
			var exists:Boolean = service.exists(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancel_stoppedLoader_Void(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(QUEUE1_ID);
			service.cancel(QUEUE1_ID);
		}
		
		[Test]
		public function cancel_stoppedLoader_checkIfLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(QUEUE1_ID);
			service.cancel(QUEUE1_ID);
			
			var exists:Boolean = service.exists(QUEUE1_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancel_queuedLoader_checkIfLoaderExists_ReturnsFalse(): void
		{
			var identification:VostokIdentification = new VostokIdentification(QUEUE1_ID, VostokFramework.CROSS_LOCALE_ID);
			var queueLoader:VostokLoader = new VostokLoader(identification, new StubLoadingAlgorithm(), LoadPriority.MEDIUM, 1);
			
			var monitor:ILoadingMonitor = new CompositeLoadingMonitor(queueLoader, new QueueLoadingMonitorDispatcher(identification.id, identification.locale));
			
			LoadingManagementContext.getInstance().globalQueueLoader.addLoader(queueLoader);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addMonitor(monitor);
			
			service.cancel(QUEUE1_ID);
			
			var exists:Boolean = service.exists(QUEUE1_ID);
			Assert.assertFalse(exists);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function cancel_callTwice_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.cancel(QUEUE1_ID);
			service.cancel(QUEUE1_ID);
		}
		
		////////////////////////////////////
		// QueueLoadingService().exists() //
		////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function exists_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.exists(null);
		}
		
		[Test]
		public function exists_notExistingLoaderId_ReturnsFalse(): void
		{
			var exists:Boolean = service.exists(QUEUE1_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function exists_callLoadAndCheckIfQueueLoaderExists_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var exists:Boolean = service.exists(QUEUE1_ID);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function exists_callLoadAndCheckIfAssetLoaderExists_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var exists:Boolean = service.exists(asset1.identification.id, asset1.identification.locale);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function exists_callLoad_queueLoadingCompletes_checkIfQueueLoaderExists_ReturnsFalse(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var exists:Boolean = service.exists(QUEUE1_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function exists_callLoad_queueLoadingCompletes_checkIfAssetLoaderExists_ReturnsFalse(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var exists:Boolean = service.exists(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(exists);
		}
		
		//////////////////////////////////////////
		// QueueLoadingService().getAssetData() //
		//////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function getAssetData_invalidAssetIdArgument_ThrowsError(): void
		{
			service.getAssetData(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function getAssetData_notExistingAsset_ThrowsError(): void
		{
			service.getAssetData(asset1.identification.id);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function getAssetData_notLoadedAsset_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			service.load(QUEUE1_ID, list, null, 1);
			service.getAssetData(asset2.identification.id, asset2.identification.locale);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function getAssetData_loadingAsset_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.getAssetData(asset1.identification.id, asset1.identification.locale);
		}
		
		[Test]
		public function getAssetData_loadedAndCachedAsset_ReturnsValidObject(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			asset1.settings.cache.allowInternalCache = true;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var data:* = service.getAssetData(asset1.identification.id, asset1.identification.locale);
			Assert.assertNotNull(data);
		}
		
		////////////////////////////////////////
		// QueueLoadingService().getMonitor() //
		////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function getMonitor_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.getMonitor(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoadingMonitorNotFoundError")]
		public function getMonitor_notExistingMonitor_ThrowsError(): void
		{
			service.getMonitor(QUEUE1_ID);
		}
		
		[Test]
		public function getMonitor_existingMonitor_ReturnsValidObject(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var monitor:ILoadingMonitor = service.getMonitor(QUEUE1_ID);
			Assert.assertNotNull(monitor);
		}
		
		//////////////////////////////////////
		// QueueLoadingService().isLoaded() //
		//////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function isLoaded_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.isLoaded(null);
		}
		
		[Test]
		public function isLoaded_notExistingLoader_ReturnsFalse(): void
		{
			var isLoaded:Boolean = service.isLoaded(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(isLoaded);
		}
		
		[Test]
		public function isLoaded_queuedLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			service.load(QUEUE1_ID, list, null, 1);
			
			var isLoaded:Boolean = service.isLoaded(asset2.identification.id, asset2.identification.locale);
			Assert.assertFalse(isLoaded);
		}
		
		[Test]
		public function isLoaded_loadingLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var isLoaded:Boolean = service.isLoaded(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(isLoaded);
		}
		
		[Test]
		public function isLoaded_loadedAndCachedAsset_ReturnsTrue(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			asset1.settings.cache.allowInternalCache = true;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var isLoaded:Boolean = service.getAssetData(asset1.identification.id, asset1.identification.locale);
			Assert.assertTrue(isLoaded);
		}
		
		///////////////////////////////////////
		// QueueLoadingService().isLoading() //
		///////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function isLoading_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.isLoading(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function isLoading_notExistingLoader_ThrowsError(): void
		{
			service.isLoading(QUEUE1_ID);
		}
		
		[Test]
		public function isLoading_loadingLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var isLoading:Boolean = service.isLoading(QUEUE1_ID);
			Assert.assertTrue(isLoading);
		}
		
		[Test]
		public function isLoading_stoppedLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(QUEUE1_ID);
			
			var isLoading:Boolean = service.isLoading(QUEUE1_ID);
			Assert.assertFalse(isLoading);
		}
		
		[Test]
		public function isLoading_queuedLoader_ReturnsFalse(): void
		{
			var identification:VostokIdentification = new VostokIdentification(QUEUE1_ID, VostokFramework.CROSS_LOCALE_ID);
			var queueLoader:VostokLoader = new VostokLoader(identification, new StubLoadingAlgorithm(), LoadPriority.MEDIUM, 1);
			
			LoadingManagementContext.getInstance().globalQueueLoader.addLoader(queueLoader);
			
			var isLoading:Boolean = service.isLoading(QUEUE1_ID);
			Assert.assertFalse(isLoading);
		}
		
		//////////////////////////////////////
		// QueueLoadingService().isQueued() //
		//////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function isQueued_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.isQueued(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function isQueued_notExistingLoader_ThrowsError(): void
		{
			service.isQueued(QUEUE1_ID);
		}
		
		[Test]
		public function isQueued_queuedLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			service.load(QUEUE1_ID, list, null, 1);
			
			var isQueued:Boolean = service.isQueued(asset2.identification.id, asset2.identification.locale);
			Assert.assertTrue(isQueued);
		}
		
		[Test]
		public function isQueued_loadingLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var isQueued:Boolean = service.isQueued(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(isQueued);
		}
		
		//////////////////////////////////
		// QueueLoadingService().load() //
		//////////////////////////////////
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError")]
		public function load_duplicateQueueId_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.load(QUEUE1_ID, list);
		}
		
		[Test(expects="ArgumentError")]
		public function load_duplicateAssetInSameQueue_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError")]
		public function load_duplicateAssetInDifferentQueues_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.load("another-queue-id", list);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.DuplicateLoadedAssetError")]
		public function load_assetAlreadyLoadedAndCached_ThrowsError(): void
		{
			var queueIdentification:VostokIdentification = new VostokIdentification(QUEUE1_ID, VostokFramework.CROSS_LOCALE_ID);
			var report:LoadedAssetReport = new LoadedAssetReport(asset1.identification, queueIdentification, new MovieClip(), AssetType.SWF, asset1.src);
			LoadingManagementContext.getInstance().loadedAssetRepository.add(report);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
		}
		
		[Test(expects="org.as3coreaddendum.errors.ClassCastError")]
		public function load_assetsArgumentWithIncorrectType_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add("INVALID TYPE");
			
			service.load(QUEUE1_ID, list);
		}
		
		[Test(expects="ArgumentError")]
		public function load_invalidNullLoaderIdArgument_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(null, list);
		}
		
		[Test(expects="ArgumentError")]
		public function load_invalidNullAssetsArgument_ThrowsError(): void
		{
			service.load(QUEUE1_ID, null);
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
			
			service.load(QUEUE1_ID, list, LoadPriority.MEDIUM, 0);
		}
		
		[Test]
		public function load_validArguments_oneAsset_ReturnsILoadingMonitor(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			var monitor:ILoadingMonitor = service.load(QUEUE1_ID, list);
			
			Assert.assertNotNull(monitor);
		}
		
		[Test]
		public function load_validArguments_twoAssets_ReturnsILoadingMonitor(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			var monitor:ILoadingMonitor = service.load(QUEUE1_ID, list);
			Assert.assertNotNull(monitor);
		}
		
		[Test]
		public function load_validArguments_checkIfQueueLoaderIsLoading_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var isLoading:Boolean = service.isLoading(QUEUE1_ID);
			Assert.assertTrue(isLoading);
		}
		
		[Test]
		public function load_validArguments_checkIfAssetLoaderIsLoading_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var isLoading:Boolean = service.isLoading(asset1.identification.id, asset1.identification.locale);
			Assert.assertTrue(isLoading);
		}
		
		[Test]
		public function load_validArguments_callGetMonitorForQueueLoader_ReturnsILoadingMonitor(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var monitor:ILoadingMonitor = service.getMonitor(QUEUE1_ID);
			Assert.assertNotNull(monitor);
		}
		
		[Test]
		public function load_validArguments_callGetMonitorForAssetLoader_ReturnsILoadingMonitor(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var monitor:ILoadingMonitor = service.getMonitor(asset1.identification.id, asset1.identification.locale);
			Assert.assertNotNull(monitor);
		}
		
		[Test]
		public function load_validArguments_callLoadOnceThenCallCancelAndThenCallLoadAgain_checkIfQueueLoaderIsLoading_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.cancel(QUEUE1_ID);
			service.load(QUEUE1_ID, list);
			
			var isLoading:Boolean = service.isLoading(QUEUE1_ID);
			Assert.assertTrue(isLoading);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoadingMonitorNotFoundError")]
		public function load_validArguments_queueLoadingCompletes_callGetMonitorForQueueLoader_ThrowsError(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.getMonitor(QUEUE1_ID);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoadingMonitorNotFoundError")]
		public function load_validArguments_queueLoadingCompletes_callGetMonitorForAssetLoader_ThrowsError(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.getMonitor(asset1.identification.id, asset1.identification.locale);
		}
		
		[Test]
		public function load_validArguments_queueLoadingCompletesButNotCacheLoadedAsset_callLoadAgain_ReturnsILoadingMonitor(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			asset1.settings.cache.allowInternalCache = false;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var monitor:ILoadingMonitor = service.load(QUEUE1_ID, list);
			Assert.assertNotNull(monitor);
		}
		
		[Test]
		public function load_validArguments_queueLoadingCompletesButNotCacheLoadedAsset_callIsLoaded_ReturnsFalse(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			asset1.settings.cache.allowInternalCache = false;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var isLoaded:Boolean = service.isLoaded(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(isLoaded);
		}
		
		[Test]
		public function load_validArguments_queueLoadingCompletesAndCacheLoadedAsset_callIsLoaded_ReturnsTrue(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			asset1.settings.cache.allowInternalCache = true;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var isLoaded:Boolean = service.isLoaded(asset1.identification.id, asset1.identification.locale);
			Assert.assertTrue(isLoaded);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function load_validArguments_queueLoadingCompletesButNotCacheLoadedAsset_callGetAssetData_ThrowsError(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			asset1.settings.cache.allowInternalCache = false;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);			
			service.getAssetData(asset1.identification.id, asset1.identification.locale);
		}
		
		[Test]
		public function load_validArguments_queueLoadingCompletesAndCacheLoadedAsset_callGetAssetData_ReturnsValidObject(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			asset1.settings.cache.allowInternalCache = true;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var assetData:* = service.getAssetData(asset1.identification.id, asset1.identification.locale);
			Assert.assertNotNull(assetData);
		}
		
		[Test(order=99999999999999999999)]
		public function load_callsThriceForDifferentLoaders_onlyTwoConcurrentQueues_checkIfSecondQueueLoaderIsLoading_ReturnsTrue(): void
		{
			trace("#############################################################################");
			trace("load_callsThriceForDifferentLoaders_onlyTwoConcurrentQueues_checkIfSecondQueueLoaderIsLoading_ReturnsTrue()");
			
			var list1:IList = new ArrayList();
			list1.add(asset1);
			list1.add(asset2);
			
			service.load(QUEUE1_ID, list1, null, 3);
			
			var list2:IList = new ArrayList();
			list2.add(asset3);
			
			service.load(QUEUE2_ID, list2);
			
			var list3:IList = new ArrayList();
			list3.add(asset4);
			
			service.load(QUEUE3_ID, list3);
			
			var isLoading:Boolean = service.isLoading(QUEUE2_ID);
			Assert.assertTrue(isLoading);
		}
		
		[Test]
		public function load_callsThriceForDifferentLoaders_onlyTwoConcurrentQueues_checkIfThirdQueueLoaderIsQueued_ReturnsTrue(): void
		{
			var list1:IList = new ArrayList();
			list1.add(asset1);
			list1.add(asset2);
			
			service.load(QUEUE1_ID, list1, null, 2);
			
			var list2:IList = new ArrayList();
			list2.add(asset3);
			
			service.load(QUEUE2_ID, list2);
			
			var list3:IList = new ArrayList();
			list3.add(asset4);
			
			service.load(QUEUE3_ID, list3);
			
			var isQueued:Boolean = service.isQueued(QUEUE3_ID);
			Assert.assertTrue(isQueued);
		}
		
		////////////////////////////////////////
		// QueueLoadingService().loadSingle() //
		////////////////////////////////////////
		
		[Test]
		public function loadSingle_validArguments_ReturnsILoadingMonitor(): void
		{
			var monitor:ILoadingMonitor = service.loadSingle(QUEUE1_ID, asset1);
			Assert.assertNotNull(monitor);
		}
		
		/////////////////////////////////////////
		// QueueLoadingService().mergeAssets() //
		/////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function mergeAssets_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.mergeAssets(null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function mergeAssets_invalidIListArgument_ThrowsError(): void
		{
			service.mergeAssets(QUEUE1_ID, null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function mergeAssets_notExistingLoader_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.mergeAssets(QUEUE1_ID, list);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError")]
		public function mergeAssets_dupplicateAsset_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.mergeAssets(QUEUE1_ID, list);
		}
		
		[Test]
		public function mergeAssets_loadingLoader_Void(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.mergeAssets(QUEUE1_ID, list2);
		}
		
		[Test]
		public function mergeAssets_loadingLoader_checkIfAssetLoaderForAddedAssetExists_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.mergeAssets(QUEUE1_ID, list2);
			
			var exists:Boolean = service.exists(asset2.identification.id, asset2.identification.locale);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function mergeAssets_loadingLoader_checkIfMonitorForAddedAssetExists_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.mergeAssets(QUEUE1_ID, list2);
			
			var monitor:ILoadingMonitor = service.getMonitor(asset2.identification.id, asset2.identification.locale);
			Assert.assertNotNull(monitor);
		}
		
		[Test]
		public function mergeAssets_loadingLoader_checkIfAssetLoaderForAddedAssetIsLoading_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list, null, 2);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.mergeAssets(QUEUE1_ID, list2);
			
			var isLoading:Boolean = service.isLoading(asset2.identification.id, asset2.identification.locale);
			Assert.assertTrue(isLoading);
		}
		
		/////////////////////////////////////////////
		// QueueLoadingService().removeAssetData() //
		/////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function removeAssetData_invalidAssetIdArgument_ThrowsError(): void
		{
			service.removeAssetData(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function removeAssetData_notLoadedAsset_ThrowsError(): void
		{
			service.removeAssetData(asset1.identification.id);
		}
		
		[Test]
		public function removeAssetData_loadedAsset_callsGetAssetData_ReturnsNull(): void
		{
			var stubAssetLoaderFactory:StubAssetLoaderFactory = new StubAssetLoaderFactory();
			stubAssetLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubAssetLoaderFactory);
			
			asset1.settings.cache.allowInternalCache = true;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var data:* = service.getAssetData(asset1.identification.id, asset1.identification.locale);
			Assert.assertNotNull(data);
		}
		
		////////////////////////////////////
		// QueueLoadingService().resume() //
		////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function resume_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.resume(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function resume_notExistingLoader_ThrowsError(): void
		{
			service.resume(QUEUE1_ID);
		}
		
		[Test]
		public function resume_stoppedLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(QUEUE1_ID);
			
			var resumed:Boolean = service.resume(QUEUE1_ID);
			Assert.assertTrue(resumed);
		}
		
		[Test]
		public function resume_loadingLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var resumed:Boolean = service.resume(QUEUE1_ID);
			Assert.assertFalse(resumed);
		}
		
		[Test]
		public function resume_stoppedLoader_CheckIfQueueLoaderStateIsConnecting_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(QUEUE1_ID);
			service.resume(QUEUE1_ID);
			
			var identification:VostokIdentification = new VostokIdentification(QUEUE1_ID, VostokFramework.CROSS_LOCALE_ID);
			var queueLoader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(identification);
			Assert.assertEquals(LoaderConnecting.INSTANCE, queueLoader.state);
		}
		
		//////////////////////////////////
		// QueueLoadingService().stop() //
		//////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function stop_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.stop(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function stop_notExistingLoader_ThrowsError(): void
		{
			service.stop(QUEUE1_ID);
		}
		
		[Test]
		public function stop_loadingLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var stopped:Boolean = service.stop(QUEUE1_ID);
			Assert.assertTrue(stopped);
		}
		
		[Test]
		public function stop_notLoadingLoader_ReturnsTrue(): void
		{
			var identification:VostokIdentification = new VostokIdentification(QUEUE1_ID, VostokFramework.CROSS_LOCALE_ID);
			var queueLoader:VostokLoader = new VostokLoader(identification, new StubLoadingAlgorithm(), LoadPriority.MEDIUM, 1);
			
			LoadingManagementContext.getInstance().globalQueueLoader.addLoader(queueLoader);
			
			var stopped:Boolean = service.stop(QUEUE1_ID);
			Assert.assertTrue(stopped);
		}
		
		[Test]
		public function stop_stoppedLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(QUEUE1_ID);
			
			var stopped:Boolean = service.stop(QUEUE1_ID);
			Assert.assertFalse(stopped);
		}
		
		[Test]
		public function stop_loadingLoader_CheckIfLoaderStateIsStopped_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(QUEUE1_ID);
			
			var identification:VostokIdentification = new VostokIdentification(QUEUE1_ID, VostokFramework.CROSS_LOCALE_ID);
			var queueLoader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(identification);
			Assert.assertEquals(LoaderStopped.INSTANCE, queueLoader.state);
		}
		
	}

}