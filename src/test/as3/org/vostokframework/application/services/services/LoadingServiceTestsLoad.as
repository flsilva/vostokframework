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
	import org.flexunit.async.Async;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.domain.assets.settings.AssetLoadingSettings;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.loaders.StubVostokLoaderFactory;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;
	import org.vostokframework.loadingmanagement.report.LoadedAssetReport;

	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsLoad extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE1_ID:String = "queue-1";
		private static const QUEUE2_ID:String = "queue-2";
		private static const QUEUE3_ID:String = "queue-3";
		
		public function LoadingServiceTestsLoad()
		{
			
		}
		
		/////////////////////////////
		// LoadingService().load() //
		/////////////////////////////
		
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
		
		[Test(async, timeout=1000, expects="org.vostokframework.loadingmanagement.domain.errors.LoadingMonitorNotFoundError")]
		public function load_validArguments_queueLoadingCompletes_callGetMonitorForQueueLoader_ThrowsError(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			//service.getMonitor(QUEUE1_ID);
			
			var timer:Timer = new Timer(400, 1);
			
			var listener:Function = Async.asyncHandler(this, 
				function():void
				{
					service.getMonitor(QUEUE1_ID);
				}
			, 1000);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, listener, false, 0, true);
			timer.start();
		}
		
		[Test(async, timeout=1000, expects="org.vostokframework.loadingmanagement.domain.errors.LoadingMonitorNotFoundError")]
		public function load_validArguments_queueLoadingCompletes_callGetMonitorForAssetLoader_ThrowsError(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			//service.getMonitor(asset1.identification.id, asset1.identification.locale);
			
			var timer:Timer = new Timer(400, 1);
			
			var listener:Function = Async.asyncHandler(this, 
				function():void
				{
					service.getMonitor(asset1.identification.id, asset1.identification.locale);
				}
			, 1000);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, listener, false, 0, true);
			timer.start();
		}
		
		[Test(async, timeout=1000)]
		public function load_validArguments_queueLoadingCompletesButNotCacheLoadedAsset_callLoadAgain_ReturnsILoadingMonitor(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setLoaderFactory(stubVostokLoaderFactory);
			
			var settings:AssetLoadingSettings = LoadingManagementContext.getInstance().assetLoadingSettingsRepository.find(asset1);
			settings.cache.allowInternalCache = false;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			//var monitor:ILoadingMonitor = service.load(QUEUE1_ID, list);
			//Assert.assertNotNull(monitor);
			
			var timer:Timer = new Timer(400, 1);
			
			var listener:Function = Async.asyncHandler(this, 
				function():void
				{
					var monitor:ILoadingMonitor = service.load(QUEUE1_ID, list);
					Assert.assertNotNull(monitor);
				}
			, 1000);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, listener, false, 0, true);
			timer.start();
		}
		
		[Test(async, timeout=1000)]
		public function load_validArguments_queueLoadingCompletesButNotCacheLoadedAsset_callContainsAssetData_ReturnsFalse(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setLoaderFactory(stubVostokLoaderFactory);
			
			var settings:AssetLoadingSettings = LoadingManagementContext.getInstance().assetLoadingSettingsRepository.find(asset1);
			settings.cache.allowInternalCache = false;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var timer:Timer = new Timer(400, 1);
			
			var listener:Function = Async.asyncHandler(this, 
				function():void
				{
					var contains:Boolean = service.containsAssetData(asset1.identification.id, asset1.identification.locale);
					Assert.assertFalse(contains);
				}
			, 1000);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, listener, false, 0, true);
			timer.start();
		}
		
		[Test(async, timeout=1000)]
		public function load_validArguments_queueLoadingCompletesAndCacheLoadedAsset_callContainsAssetData_ReturnsTrue(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setLoaderFactory(stubVostokLoaderFactory);
			
			var settings:AssetLoadingSettings = LoadingManagementContext.getInstance().assetLoadingSettingsRepository.find(asset1);
			settings.cache.allowInternalCache = true;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var timer:Timer = new Timer(400, 1);
			
			var listener:Function = Async.asyncHandler(this, 
				function():void
				{
					var contains:Boolean = service.containsAssetData(asset1.identification.id, asset1.identification.locale);
					Assert.assertTrue(contains);
				}
			, 1000);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, listener, false, 0, true);
			timer.start();
		}
		
		[Test(async, timeout=1000, expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function load_validArguments_queueLoadingCompletesButNotCacheLoadedAsset_callGetAssetData_ThrowsError(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setLoaderFactory(stubVostokLoaderFactory);
			
			var settings:AssetLoadingSettings = LoadingManagementContext.getInstance().assetLoadingSettingsRepository.find(asset1);
			settings.cache.allowInternalCache = false;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);			
			
			var timer:Timer = new Timer(400, 1);
			
			var listener:Function = Async.asyncHandler(this, 
				function():void
				{
					service.getAssetData(asset1.identification.id, asset1.identification.locale);
				}
			, 1000);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, listener, false, 0, true);
			timer.start();
		}
		
		[Test(async, timeout=1000)]
		public function load_validArguments_queueLoadingCompletesAndCacheLoadedAsset_callGetAssetData_ReturnsValidObject(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setLoaderFactory(stubVostokLoaderFactory);
			
			var settings:AssetLoadingSettings = LoadingManagementContext.getInstance().assetLoadingSettingsRepository.find(asset1);
			settings.cache.allowInternalCache = true;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var listener:Function = Async.asyncHandler(this, 
				function():void
				{
					var assetData:* = service.getAssetData(asset1.identification.id, asset1.identification.locale);
					Assert.assertNotNull(assetData);
				}
			, 1000);
			
			var timer:Timer = new Timer(400, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, listener, false, 0, true);
			timer.start();
		}
		
		[Test]
		public function load_callsThriceForDifferentLoaders_onlyTwoConcurrentQueues_checkIfSecondQueueLoaderIsLoading_ReturnsTrue(): void
		{
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
		
		///////////////////////////////////
		// LoadingService().loadSingle() //
		///////////////////////////////////
		
		[Test]
		public function loadSingle_validArguments_ReturnsILoadingMonitor(): void
		{
			var monitor:ILoadingMonitor = service.loadSingle(QUEUE1_ID, asset1);
			Assert.assertNotNull(monitor);
		}
		
	}

}