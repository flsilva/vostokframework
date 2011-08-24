/*
 * Licensed under the MIT License
 * 
 * Copyright 2011 (c) Flávio Silva, flsilva.com
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
package org.vostokframework.loadingmanagement
{
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetIdentification;
	import org.vostokframework.assetmanagement.services.AssetService;
	import org.vostokframework.loadingmanagement.domain.ILoader;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.events.AggregateQueueLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.AssetLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.events.QueueLoadingEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.VostokLoaderFactory;
	import org.vostokframework.loadingmanagement.domain.monitors.CompositeLoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.GlobalLoadingMonitorDispatcher;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorDispatcher;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorRepository;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorWrapper;
	import org.vostokframework.loadingmanagement.domain.policies.ElaborateLoadingPolicy;
	import org.vostokframework.loadingmanagement.domain.policies.ILoadingPolicy;
	import org.vostokframework.loadingmanagement.report.LoadedAssetReport;
	import org.vostokframework.loadingmanagement.report.LoadedAssetRepository;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingManagementContext
	{
		/**
		 * @private
		 */
		private static const GLOBAL_QUEUE_LOADER_ID:String = "GlobalQueueLoader";
		private static var _instance:LoadingManagementContext = new LoadingManagementContext();
		
		private var _globalQueueLoader:ILoader;
		private var _globalQueueLoadingMonitor:ILoadingMonitor;
		private var _globalQueueLoadingMonitorWrapper:LoadingMonitorWrapper;
		private var _loadedAssetRepository:LoadedAssetRepository;
		private var _loaderFactory:VostokLoaderFactory;
		private var _loaderRepository:LoaderRepository;
		private var _loadingMonitorRepository:LoadingMonitorRepository;
		private var _maxConcurrentConnections:int;
		private var _maxConcurrentQueues:int;
		
		/**
		 * @private
		 */
		private static var _created :Boolean = false;
		
		{
			_created = true;
		}
		
		public function get globalQueueLoader(): ILoader { return _globalQueueLoader; }
		
		//public function get globalQueueLoadingMonitor(): QueueLoadingMonitor { return _globalQueueLoadingMonitor; }
		
		public function get globalQueueLoadingMonitor(): ILoadingMonitor { return _globalQueueLoadingMonitorWrapper; }
		
		public function get loadedAssetRepository(): LoadedAssetRepository { return _loadedAssetRepository; }
		
		public function get loaderRepository(): LoaderRepository { return _loaderRepository; }
		
		public function get loadingMonitorRepository(): LoadingMonitorRepository { return _loadingMonitorRepository; }
		
		/**
		 * description
		 */
		public function get maxConcurrentConnections(): int { return _maxConcurrentConnections; }

		/**
		 * description
		 */
		public function get maxConcurrentQueues(): int { return _maxConcurrentQueues; }
		
		public function get loaderFactory(): VostokLoaderFactory { return _loaderFactory; }
		
		/**
		 * description
		 */
		public function LoadingManagementContext()
		{
			if (_created) throw new IllegalOperationError("<LoadingManagementContext> is a singleton class and should be accessed only by its <getInstance> method.");
			
			_maxConcurrentConnections = 6;
			_maxConcurrentQueues = 3;
			
			_loaderFactory = new VostokLoaderFactory();
			_loadedAssetRepository = new LoadedAssetRepository();
			_loaderRepository = new LoaderRepository();
			_loadingMonitorRepository = new LoadingMonitorRepository();
			
			_globalQueueLoadingMonitorWrapper = new LoadingMonitorWrapper();
			
			createGlobalQueueLoader();
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public static function getInstance(): LoadingManagementContext
		{
			return _instance;
		}
		
		/**
		 * description
		 * 
		 * @param factory
		 */
		public function setAssetLoaderFactory(factory:VostokLoaderFactory): void
		{
			if (!factory) throw new ArgumentError("Argument <factory> must not be null.");
			_loaderFactory = factory;
		}

		/**
		 * description
		 * 
		 * @param queueLoader
		 */
		public function setGlobalQueueLoader(queueLoader:ILoader): void
		{
			if (!queueLoader) throw new ArgumentError("Argument <queueLoader> must not be null.");
			
			var oldGlobalMonitor:ILoadingMonitor = _globalQueueLoadingMonitor;
			var oldGlobalLoader:ILoader = _globalQueueLoader;
			
			if (oldGlobalLoader) loaderRepository.remove(oldGlobalLoader.identification);
			
			/*
			if (_globalQueueLoadingMonitor) _globalQueueLoadingMonitor.dispose();
			
			if (_globalQueueLoader)
			{
				loaderRepository.remove(_globalQueueLoader.identification);
				
				try
				{
					_globalQueueLoader.cancel();
				}
				catch(error:Error)
				{
					// do nothing
				}
				finally
				{
					_globalQueueLoader.dispose();
				}
			}
			*/
			_globalQueueLoader = queueLoader;
			loaderRepository.add(_globalQueueLoader);
			
			//var globalQueueLoadingMonitor:AggregateQueueLoadingMonitor = new AggregateQueueLoadingMonitor(_globalQueueLoader);
			var globalQueueLoadingMonitorDispatcher:LoadingMonitorDispatcher = new GlobalLoadingMonitorDispatcher(_globalQueueLoader.identification.id, _globalQueueLoader.identification.locale);
			var globalQueueLoadingMonitor:ILoadingMonitor = new CompositeLoadingMonitor(_globalQueueLoader, globalQueueLoadingMonitorDispatcher);
			
			_globalQueueLoadingMonitorWrapper.changeMonitor(globalQueueLoadingMonitor);
			_globalQueueLoadingMonitorWrapper.addEventListener(AggregateQueueLoadingEvent.COMPLETE, globalQueueLoaderCompleteHandler, false, int.MIN_VALUE, true);
			_globalQueueLoadingMonitorWrapper.addEventListener(QueueLoadingEvent.COMPLETE, queueLoaderCompleteHandler, false, int.MIN_VALUE, true);
			_globalQueueLoadingMonitorWrapper.addEventListener(QueueLoadingEvent.CANCELED, queueLoaderCanceledHandler, false, int.MIN_VALUE, true);
			_globalQueueLoadingMonitorWrapper.addEventListener(AssetLoadingEvent.COMPLETE, assetCompleteHandler, false, int.MAX_VALUE, true);
			
			//if (_globalQueueLoadingMonitor) _globalQueueLoadingMonitor.dispose();
			_globalQueueLoadingMonitor = globalQueueLoadingMonitor;
			
			if (oldGlobalMonitor) oldGlobalMonitor.dispose();
			
			if (oldGlobalLoader)
			{
				//loaderRepository.remove(oldGlobalLoader.identification);
				
				try
				{
					oldGlobalLoader.cancel();
				}
				catch(error:Error)
				{
					// do nothing
				}
				finally
				{
					oldGlobalLoader.dispose();
				}
			}
		}
		
		/**
		 * description
		 * 
		 * @param repository
		 */
		public function setLoadedAssetRepository(repository:LoadedAssetRepository): void
		{
			if (!repository) throw new ArgumentError("Argument <repository> must not be null.");
			_loadedAssetRepository = repository;//TODO:validate if already exists an queueLoader and if yes stop() and dispose() it
		}
		
		/**
		 * description
		 * 
		 * @param loaderRepository
		 */
		public function setLoaderRepository(loaderRepository:LoaderRepository): void
		{
			if (!loaderRepository) throw new ArgumentError("Argument <loaderRepository> must not be null.");
			_loaderRepository = loaderRepository;//TODO:validate if already exists an loaderRepository and dispose() it
		}
		
		/**
		 * description
		 * 
		 * @param loaderRepository
		 */
		public function setLoadingMonitorRepository(loadingMonitorRepository:LoadingMonitorRepository): void
		{
			if (!loadingMonitorRepository) throw new ArgumentError("Argument <loadingMonitorRepository> must not be null.");
			_loadingMonitorRepository = loadingMonitorRepository;//TODO:validate if already exists an loaderRepository and dispose() it
		}

		/**
		 * description
		 * 
		 * @param value
		 */
		public function setMaxConcurrentConnections(value:int): void
		{
			if (value < 1) throw new ArgumentError("Argument <value> must be greater than zero.");
			_maxConcurrentConnections = value;
		}

		/**
		 * description
		 * 
		 * @param value
		 */
		public function setMaxConcurrentQueues(value:int): void
		{
			if (value < 1) throw new ArgumentError("Argument <value> must be greater than zero.");
			_maxConcurrentQueues = value;
		}
		
		/**
		 * @private
		 */
		private function createGlobalQueueLoader(): void
		{
			var policy:ILoadingPolicy = new ElaborateLoadingPolicy(_loaderRepository);
			policy.globalMaxConnections = _maxConcurrentConnections;
			policy.localMaxConnections = _maxConcurrentQueues;
			
			//var queue:PriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			//var queueLoader:QueueLoader = new QueueLoader(GLOBAL_QUEUE_LOADER_ID, LoadPriority.MEDIUM, queue);
			
			var queueLoadingAlgorithm:LoadingAlgorithm = new QueueLoadingAlgorithm(policy);
			var identification:VostokIdentification = new VostokIdentification(GLOBAL_QUEUE_LOADER_ID, VostokFramework.CROSS_LOCALE_ID);
			var queueLoader:ILoader = new VostokLoader(identification, queueLoadingAlgorithm, LoadPriority.MEDIUM);
			
			setGlobalQueueLoader(queueLoader);
		}
		
		/**
		 * @private
		 */
		private function globalQueueLoaderCompleteHandler(event:AggregateQueueLoadingEvent):void
		{
			trace("#####################################################");
			trace("LoadingManagementContext::globalQueueLoaderCompleteHandler() - event.queueId: " + event.queueId);
			
			createGlobalQueueLoader();
		}
		
		private function queueLoaderCanceledHandler(event:QueueLoadingEvent):void
		{
			trace("#####################################################");
			trace("LoadingManagementContext::queueLoaderCanceledHandler() - event.queueId: " + event.queueId);
			
			var identification:VostokIdentification = new VostokIdentification(event.queueId, VostokFramework.CROSS_LOCALE_ID);//TODO:inserir locale
			
			globalQueueLoadingMonitor.removeMonitor(identification);
			//globalQueueLoader.removeLoader(identification);
		}
		
		private function queueLoaderCompleteHandler(event:QueueLoadingEvent):void
		{
			trace("#####################################################");
			trace("LoadingManagementContext::queueLoaderCompleteHandler() - event.queueId: " + event.queueId);
			
			var identification:VostokIdentification = new VostokIdentification(event.queueId, VostokFramework.CROSS_LOCALE_ID);//TODO:inserir locale
			
			globalQueueLoadingMonitor.removeMonitor(identification);
			globalQueueLoader.removeLoader(identification);
		}
		
		private function assetCompleteHandler(event:AssetLoadingEvent):void
		{
			trace("#####################################################");
			trace("LoadingManagementContext::assetCompleteHandler() - event.assetId: " + event.assetId);
			
			var errorMessage:String;
			
			var assetService:AssetService = new AssetService();
			if (!assetService.assetExists(event.assetId, event.assetLocale))
			{
				errorMessage = "It was expected that the Asset object was found:\n";
				errorMessage += "<assetId>: " + event.assetId + "\n";
				errorMessage += "<assetLocale>: " + event.assetLocale;
				
				throw new IllegalOperationError(errorMessage); 
			}
			
			var asset:Asset = assetService.getAsset(event.assetId, event.assetLocale);
			if (!asset.settings.cache.allowInternalCache) return;
			
			var src:String = asset.src;
			
			var identification:AssetIdentification = new AssetIdentification(event.assetId, event.assetLocale);
			
			var queueLoader:ILoader = globalQueueLoader.getParent(new VostokIdentification(identification.id, identification.locale));//TODO:refactor identification
			if (!queueLoader)
			{
				errorMessage = "It was expected that the parent ILoader object for the child ILoader object was found.\n";
				errorMessage += "child ILoader id: " + identification.toString();
				
				throw new IllegalOperationError(errorMessage); 
			}
			
			var loadedAssetReport:LoadedAssetReport = new LoadedAssetReport(identification, queueLoader.identification, event.assetData, event.assetType, src);
			loadedAssetRepository.add(loadedAssetReport); 
		}

	}

}