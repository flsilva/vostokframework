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
	import org.vostokframework.loadingmanagement.domain.ElaboratePriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.PriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.loaders.AssetLoaderFactory;
	import org.vostokframework.loadingmanagement.domain.loaders.QueueLoader;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorRepository;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicy;
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
		
		private var _assetLoaderFactory:AssetLoaderFactory;
		private var _globalQueueLoader:QueueLoader;
		private var _loadedAssetRepository:LoadedAssetRepository;
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
		
		public function get assetLoaderFactory(): AssetLoaderFactory { return _assetLoaderFactory; }
		
		public function get globalQueueLoader(): QueueLoader { return _globalQueueLoader; }
		
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
		
		/**
		 * description
		 */
		public function LoadingManagementContext(): void
		{
			if (_created) throw new IllegalOperationError("<LoadingManagementContext> is a singleton class and should be accessed only by its <getInstance> method.");
			
			_maxConcurrentConnections = 6;
			_maxConcurrentQueues = 3;
			
			_assetLoaderFactory = new AssetLoaderFactory();
			_loadedAssetRepository = new LoadedAssetRepository();
			_loaderRepository = new LoaderRepository();
			_loadingMonitorRepository = new LoadingMonitorRepository();
			
			var policy:LoadingPolicy = new LoadingPolicy(_loaderRepository);
			policy.globalMaxConnections = _maxConcurrentConnections;
			policy.localMaxConnections = _maxConcurrentQueues;
			
			var queue:PriorityLoadQueue = new ElaboratePriorityLoadQueue(policy);
			_globalQueueLoader = new QueueLoader(GLOBAL_QUEUE_LOADER_ID, LoadPriority.MEDIUM, queue);
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
		public function setAssetLoaderFactory(factory:AssetLoaderFactory): void
		{
			if (!factory) throw new ArgumentError("Argument <factory> must not be null.");
			_assetLoaderFactory = factory;
		}

		/**
		 * description
		 * 
		 * @param queueLoader
		 */
		public function setGlobalQueueLoader(queueLoader:QueueLoader): void
		{
			if (!queueLoader) throw new ArgumentError("Argument <queueLoader> must not be null.");
			_globalQueueLoader = queueLoader;//TODO:validate if already exists an queueLoader and if yes stop() and dispose() it
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

	}

}