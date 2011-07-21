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
	import mockolate.ingredients.Sequence;
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.sequence;
	import mockolate.verify;

	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.HelperTestObject;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.assetmanagement.AssetManagementContext;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetPackage;
	import org.vostokframework.assetmanagement.domain.AssetPackageIdentification;
	import org.vostokframework.assetmanagement.domain.AssetPackageRepository;
	import org.vostokframework.assetmanagement.domain.AssetRepository;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.ElaboratePriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.LoaderStatus;
	import org.vostokframework.loadingmanagement.domain.PriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.events.AggregateQueueLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.AssetLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.QueueLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.QueueLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.StubAssetLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.StubAssetLoaderFactory;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorRepository;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicy;
	import org.vostokframework.loadingmanagement.report.LoadedAssetRepository;

	import flash.display.MovieClip;
	import flash.events.ProgressEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class QueueLoadingServiceTestsIntegration
	{
		private static const QUEUE_ID:String = "queue-1";
		private static const ASSET_PACKAGE_ID:String = "asset-package-1";
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		public var service:QueueLoadingService;
		public var asset1:Asset;
		public var asset2:Asset;
		
		[Mock(inject="false")]
		public var helperTestObject:HelperTestObject;
		
		public function QueueLoadingServiceTestsIntegration()
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
			
			AssetManagementContext.getInstance().assetPackageRepository.add(assetPackage);
			AssetManagementContext.getInstance().assetRepository.add(asset1);
			AssetManagementContext.getInstance().assetRepository.add(asset2);
		}
		
		[After]
		public function tearDown(): void
		{
			service = null;
		}
		
		/////////////////////
		// EVENT LISTENERS //
		/////////////////////
		
		private function assetLoadingCompleteHandler(event:AssetLoadingEvent):void
		{
			helperTestObject.test(AssetLoadingEvent);
		}
		
		private function queueLoadingCompleteHandler(event:QueueLoadingEvent):void
		{
			helperTestObject.test(QueueLoadingEvent);
		}
		
		private function globalQueueLoadingCompleteHandler(event:AggregateQueueLoadingEvent):void
		{
			helperTestObject.test(AggregateQueueLoadingEvent);
		}
		
		private function asyncTimeoutHandler(passThroughData:Object):void
		{
			Assert.fail("Asynchronous Test Failed: Timeout");
			passThroughData = null;
		}
		
		///////////////////////////////////////////
		// globalQueueLoadingMonitor OPEN events //
		///////////////////////////////////////////
		
		[Test(async, timeout=50)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesGlobalOpenEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AggregateQueueLoadingEvent.OPEN, 50, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			var assetLoader:StubAssetLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString()) as StubAssetLoader;
			assetLoader.status = LoaderStatus.CONNECTING;
			assetLoader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
		}
		
		[Test(async, timeout=50)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesQueueOpenEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, QueueLoadingEvent.OPEN, 50, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			var assetLoader:StubAssetLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString()) as StubAssetLoader;
			assetLoader.status = LoaderStatus.CONNECTING;
			assetLoader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
		}
		
		[Test(async, timeout=50)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesAssetOpenEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AssetLoadingEvent.OPEN, 50, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			var assetLoader:StubAssetLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString()) as StubAssetLoader;
			assetLoader.status = LoaderStatus.CONNECTING;
			assetLoader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
		}
		
		///////////////////////////////////////////////
		// globalQueueLoadingMonitor PROGRESS events //
		///////////////////////////////////////////////
		
		[Test(async, timeout=200)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesGlobalProgressEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AggregateQueueLoadingEvent.PROGRESS, 200, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			var assetLoader:StubAssetLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString()) as StubAssetLoader;
			assetLoader.status = LoaderStatus.LOADING;
			assetLoader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			assetLoader.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
		}
		
		[Test(async, timeout=200)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesQueueProgressEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, QueueLoadingEvent.PROGRESS, 200, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			var assetLoader:StubAssetLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString()) as StubAssetLoader;
			assetLoader.status = LoaderStatus.LOADING;
			assetLoader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			assetLoader.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
		}
		
		[Test(async, timeout=200)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesAssetProgressEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AssetLoadingEvent.PROGRESS, 200, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			var assetLoader:StubAssetLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString()) as StubAssetLoader;
			assetLoader.status = LoaderStatus.LOADING;
			assetLoader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			assetLoader.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
		}
		
		/////////////////////////////////////////////
		// globalQueueLoadingMonitor other events ///
		/////////////////////////////////////////////
		
		[Test]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesOpenEventsInCorrectOrder(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			helperTestObject = nice(HelperTestObject);
			
			var seq:Sequence = sequence();
			mock(helperTestObject).method("test").args(AssetLoadingEvent).once().ordered(seq);;
			mock(helperTestObject).method("test").args(QueueLoadingEvent).once().ordered(seq);;
			mock(helperTestObject).method("test").args(AggregateQueueLoadingEvent).once().ordered(seq);;
			
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AssetLoadingEvent.OPEN, assetLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(QueueLoadingEvent.OPEN, queueLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AggregateQueueLoadingEvent.OPEN, globalQueueLoadingCompleteHandler, false, 0, true);
			
			service.load(QUEUE_ID, list);
			
			var assetLoader:StubAssetLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString()) as StubAssetLoader;
			assetLoader.status = LoaderStatus.LOADING;
			assetLoader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			
			verify(helperTestObject);
		}
		
		[Test]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesCompleteEventsInCorrectOrder(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			helperTestObject = nice(HelperTestObject);
			
			var seq:Sequence = sequence();
			mock(helperTestObject).method("test").args(AssetLoadingEvent).once().ordered(seq);;
			mock(helperTestObject).method("test").args(QueueLoadingEvent).once().ordered(seq);;
			mock(helperTestObject).method("test").args(AggregateQueueLoadingEvent).once().ordered(seq);;
			
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AssetLoadingEvent.COMPLETE, assetLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(QueueLoadingEvent.COMPLETE, queueLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AggregateQueueLoadingEvent.COMPLETE, globalQueueLoadingCompleteHandler, false, 0, true);
			
			service.load(QUEUE_ID, list);
			
			var assetLoader:StubAssetLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString()) as StubAssetLoader;
			assetLoader.status = LoaderStatus.COMPLETE;
			assetLoader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			assetLoader.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, new MovieClip()));
			
			verify(helperTestObject);
		}
		
	}

}