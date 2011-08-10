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
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.assetmanagement.AssetManagementContext;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetPackage;
	import org.vostokframework.assetmanagement.domain.AssetPackageIdentification;
	import org.vostokframework.assetmanagement.domain.AssetPackageRepository;
	import org.vostokframework.assetmanagement.domain.AssetRepository;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.events.AggregateQueueLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.AssetLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.QueueLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.LoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.loaders.QueueLoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.loaders.StubAssetLoaderFactory;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorRepository;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicy;
	import org.vostokframework.loadingmanagement.report.LoadedAssetRepository;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=999)]
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
		
		public var timer:Timer;
		
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
			
			LoadingManagementContext.getInstance().setMaxConcurrentConnections(6);
			LoadingManagementContext.getInstance().setMaxConcurrentQueues(3);
			
			var policy:LoadingPolicy = new LoadingPolicy(LoadingManagementContext.getInstance().loaderRepository);
			policy.globalMaxConnections = LoadingManagementContext.getInstance().maxConcurrentConnections;
			policy.localMaxConnections = LoadingManagementContext.getInstance().maxConcurrentQueues;
			
			var queueLoadingAlgorithm:LoadingAlgorithm = new QueueLoadingAlgorithm(policy);
			var identification:VostokIdentification = new VostokIdentification("GlobalQueueLoader", VostokFramework.CROSS_LOCALE_ID);
			var globalQueueLoader:VostokLoader = new VostokLoader(identification, queueLoadingAlgorithm, LoadPriority.MEDIUM, 1);
			LoadingManagementContext.getInstance().setGlobalQueueLoader(globalQueueLoader);
			
			service = new QueueLoadingService();
			
			var assetIdentification:AssetPackageIdentification = new AssetPackageIdentification(ASSET_PACKAGE_ID, VostokFramework.CROSS_LOCALE_ID);
			var assetPackage:AssetPackage = AssetManagementContext.getInstance().assetPackageFactory.create(assetIdentification);
			asset1 = AssetManagementContext.getInstance().assetFactory.create("QueueLoadingServiceTests/asset/image-01.jpg", assetPackage);
			asset2 = AssetManagementContext.getInstance().assetFactory.create("QueueLoadingServiceTests/asset/image-02.jpg", assetPackage);
			
			AssetManagementContext.getInstance().assetPackageRepository.add(assetPackage);
			AssetManagementContext.getInstance().assetRepository.add(asset1);
			AssetManagementContext.getInstance().assetRepository.add(asset2);
			
			timer = new Timer(500);
		}
		
		[After]
		public function tearDown(): void
		{
			timer.stop();
			
			helperTestObject = null;
			service = null;
			timer = null;
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
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesGlobalOpenEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AggregateQueueLoadingEvent.OPEN, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			//var loader:VostokLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString());
			//var loader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(asset1.identification.toString());
			//loader.status = LoaderStatus.CONNECTING;TODO:deletar codigo comentado
			//loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesQueueOpenEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, QueueLoadingEvent.OPEN, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			//var loader:VostokLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString());
			//var loader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(asset1.identification.toString());
			//loader.status = LoaderStatus.CONNECTING;TODO:deletar codigo comentado
			//loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesAssetOpenEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AssetLoadingEvent.OPEN, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			//var loader:VostokLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString());
			//var loader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(asset1.identification.toString());
			//loader.status = LoaderStatus.CONNECTING;TODO:deletar codigo comentado
			//loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
		}
		
		///////////////////////////////////////////////
		// globalQueueLoadingMonitor PROGRESS events //
		///////////////////////////////////////////////
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesGlobalProgressEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AggregateQueueLoadingEvent.PROGRESS, 1000, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			//var loader:VostokLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString());
			//var loader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(asset1.identification.toString());
			//loader.status = LoaderStatus.LOADING;TODO:deletar codigo comentado
			//loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			//loader.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
		}
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesQueueProgressEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, QueueLoadingEvent.PROGRESS, 1000, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			//var loader:VostokLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString());
			//var loader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(asset1.identification.toString());
			//loader.status = LoaderStatus.LOADING;TODO:deletar codigo comentado
			//loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			//loader.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesAssetProgressEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AssetLoadingEvent.PROGRESS, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			
			//var loader:VostokLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString());
			//var loader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(asset1.identification.toString());
			//loader.status = LoaderStatus.LOADING;TODO:deletar codigo comentado
			//loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			//loader.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
		}
		
		///////////////////////////////////////////////
		// globalQueueLoadingMonitor COMPLETE events //
		///////////////////////////////////////////////
		
		[Test(async, timeout=1000, order=999)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesGlobalCompleteEvent(): void
		{
			trace("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
			trace("QueueLoadingServiceTestsIntegration::load_validArguments_verifyIfGlobalMonitorDispatchesGlobalCompleteEvent");
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AggregateQueueLoadingEvent.COMPLETE, 1000, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			/*
			var loader:StubVostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(asset1.identification.toString()) as StubVostokLoader;
			loader.asyncDispatchEvent(new LoaderEvent(LoaderEvent.OPEN), LoaderConnecting.INSTANCE, 50);
			loader.asyncDispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE), LoaderComplete.INSTANCE, 100);*/
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesQueueCompleteEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, QueueLoadingEvent.COMPLETE, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			/*
			//var loader:VostokLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString());
			var loader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(asset1.identification.toString());
			//loader.status = LoaderStatus.CONNECTING;TODO:deletar codigo comentado
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE));*/
		}
		
		[Test(async, timeout=500)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesAssetCompleteEvent(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			Async.proceedOnEvent(this, LoadingManagementContext.getInstance().globalQueueLoadingMonitor, AssetLoadingEvent.COMPLETE, 500, asyncTimeoutHandler);
			
			service.load(QUEUE_ID, list);
			/*
			//var loader:VostokLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString());
			var loader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(asset1.identification.toString());
			//loader.status = LoaderStatus.CONNECTING;TODO:deletar codigo comentado
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE));*/
		}
		
		/////////////////////////////////////////////
		// globalQueueLoadingMonitor other events ///
		/////////////////////////////////////////////
		
		private function verifyHelperTestObject(event:Event, passThroughData:Object):void
		{
			trace("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
			trace("verifyHelperTestObject()");
			
			verify(helperTestObject);
		}
		
		[Test(async, timeout=1000, order=999)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesOpenEventsInCorrectOrder(): void
		{
			trace("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
			trace("load_validArguments_verifyIfGlobalMonitorDispatchesOpenEventsInCorrectOrder");
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			helperTestObject = nice(HelperTestObject);
			
			var seq:Sequence = sequence();
			mock(helperTestObject).method("test").args(AssetLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(QueueLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(AggregateQueueLoadingEvent).once().ordered(seq);
			
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AssetLoadingEvent.OPEN, assetLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(QueueLoadingEvent.OPEN, queueLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AggregateQueueLoadingEvent.OPEN, globalQueueLoadingCompleteHandler, false, 0, true);
			
			var asyncHandler:Function = Async.asyncHandler(this, verifyHelperTestObject, 1000);
			timer.addEventListener(TimerEvent.TIMER, asyncHandler, false, 0, true);
			
			timer.delay = 500;
			timer.start();
			
			service.load(QUEUE_ID, list);
			
			/*
			//var loader:VostokLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString());
			var loader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(asset1.identification.toString());
			//loader.status = LoaderStatus.LOADING;TODO:deletar codigo comentado
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			*/
			//verify(helperTestObject);
		}
		
		[Test(async, timeout=1000)]
		public function load_validArguments_verifyIfGlobalMonitorDispatchesCompleteEventsInCorrectOrder(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			helperTestObject = nice(HelperTestObject);
			
			var seq:Sequence = sequence();
			mock(helperTestObject).method("test").args(AssetLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(QueueLoadingEvent).once().ordered(seq);
			mock(helperTestObject).method("test").args(AggregateQueueLoadingEvent).once().ordered(seq);
			
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AssetLoadingEvent.COMPLETE, assetLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(QueueLoadingEvent.COMPLETE, queueLoadingCompleteHandler, false, 0, true);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addEventListener(AggregateQueueLoadingEvent.COMPLETE, globalQueueLoadingCompleteHandler, false, 0, true);
			
			var asyncHandler:Function = Async.asyncHandler(this, verifyHelperTestObject, 1000);
			timer.addEventListener(TimerEvent.TIMER, asyncHandler, false, 0, true);
			
			timer.delay = 500;
			timer.start();
			
			service.load(QUEUE_ID, list);
			/*
			//var loader:VostokLoader = LoadingManagementContext.getInstance().loaderRepository.find(asset1.identification.toString());
			var loader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(asset1.identification.toString());
			//loader.status = LoaderStatus.COMPLETE;TODO:deletar codigo comentado
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, new MovieClip()));
			
			verify(helperTestObject);*/
		}
		
	}

}