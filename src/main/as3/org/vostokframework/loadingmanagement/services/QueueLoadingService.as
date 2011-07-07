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
package org.vostokframework.loadingmanagement.services
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.TypedList;
	import org.as3utils.StringUtil;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.LoaderStatus;
	import org.vostokframework.loadingmanagement.domain.PlainPriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.PriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.RefinedLoader;
	import org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError;
	import org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError;
	import org.vostokframework.loadingmanagement.domain.loaders.AssetLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.AssetLoaderFactory;
	import org.vostokframework.loadingmanagement.domain.loaders.QueueLoader;
	import org.vostokframework.loadingmanagement.domain.monitors.AssetLoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorRepository;
	import org.vostokframework.loadingmanagement.domain.monitors.QueueLoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicy;
	import org.vostokframework.loadingmanagement.report.LoadedAssetReport;
	import org.vostokframework.loadingmanagement.report.LoadedAssetRepository;
	import org.vostokframework.loadingmanagement.report.errors.DuplicateLoadedAssetError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class QueueLoadingService
	{
		private var _context:LoadingManagementContext;
		
		private function get assetLoaderFactory():AssetLoaderFactory { return _context.assetLoaderFactory; }
		
		private function get globalQueueLoader():QueueLoader { return _context.globalQueueLoader; }
		
		private function get loadedAssetRepository():LoadedAssetRepository { return _context.loadedAssetRepository; }
		
		private function get loaderRepository():LoaderRepository { return _context.loaderRepository; }
		
		private function get loadingMonitorRepository():LoadingMonitorRepository { return _context.loadingMonitorRepository; }
		
		/**
		 * description
		 */
		public function QueueLoadingService(): void
		{
			_context = LoadingManagementContext.getInstance();
		}
		
		/**
		 * description
		 * 
		 * @param queueId
		 * @param assets
		 * @return
		 */
		public function addAssetsInQueue(queueId:String, assets:IList): ILoadingMonitor
		{
			return null;
		}

		/**
		 * description
		 * 
		 * @param queueId
		 * @return
		 */
		public function cancelQueueLoading(queueId:String): Boolean
		{
			return false;
		}

		/**
		 * description
		 * 
		 * @param queueId
		 * @return
		 */
		public function getQueueLoadingMonitor(queueId:String): ILoadingMonitor
		{
			return null;
		}

		/**
		 * description
		 * 
		 * @param queueId
		 * @return
		 */
		public function isQueueLoading(queueId:String): Boolean
		{
			if (StringUtil.isBlank(queueId)) throw new ArgumentError("Argument <queueId> must not be null nor an empty String.");
			
			var loader:RefinedLoader = loaderRepository.find(queueId);
			if (!loader)
			{
				var message:String = "There is no QueueLoader object stored with id:\n";
				message += "<" + queueId + ">\n";
				message += "Use the method <QueueLoadingService().queueExists()> to check if a QueueLoader object exists.\n";
				
				throw new LoaderNotFoundError(queueId, message);
			}
			trace("##########################################################################################");
			trace("loader.status: " + loader.status + " | loader.status.equals(LoaderStatus.CONNECTING): " + loader.status.equals(LoaderStatus.CONNECTING) + " | loader.status.equals(LoaderStatus.LOADING): " + loader.status.equals(LoaderStatus.LOADING));
			return loader.status.equals(LoaderStatus.CONNECTING) || loader.status.equals(LoaderStatus.LOADING);
		}

		/**
		 * description
		 * 
		 * @param queueId
		 * @param assets
		 * @param priority
		 * @param concurrentConnections
		 * @return
		 */
		public function load(queueId:String, assets:IList, priority:LoadPriority = null, concurrentConnections:int = 1): ILoadingMonitor
		{
			if (StringUtil.isBlank(queueId)) throw new ArgumentError("Argument <queueId> must not be null nor an empty String.");
			if (!assets || assets.isEmpty()) throw new ArgumentError("Argument <assets> must not be null nor empty.");
			if (concurrentConnections < 1) throw new ArgumentError("Argument <concurrentConnections> must be greater than zero. Received: <" + concurrentConnections + ">");
			
			//throws org.as3coreaddendum.ClassCastError
			//if there's any type other than Asset in <assets>
			assets = new TypedList(assets, Asset);
			
			if (!priority) priority = LoadPriority.MEDIUM;
			
			//throws org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError
			//if <loaderRepository> already contains a QueueLoader object with <queueId>
			var queueLoader:QueueLoader = createQueueLoaderAndPutInRepository(queueId, priority, concurrentConnections);
			
			//throws org.vostokframework.loadingmanagement.report.errors.DuplicateLoadedAssetError
			//if some Asset object is already loaded and cached internally
			checkIfSomeAssetIsAlreadyLoadedAndCached(assets);
			
			//throws org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError
			//if <loaderRepository> contains an AssetLoader object with any Asset id inside <assets>
			//AND throws ArgumentError if <assets> argument contains any duplicate Asset object
			var assetLoaders:IList = createAssetLoadersAndPutInRepository(assets);
			
			//may throw DuplicateLoadingMonitorError
			var assetLoadingMonitors:IList = createAssetLoadingMonitorsAndPutInRepository(assets);
			
			queueLoader.addLoaders(assetLoaders);
			
			var monitor:QueueLoadingMonitor = new QueueLoadingMonitor(queueLoader, assetLoadingMonitors);
			loadingMonitorRepository.add(monitor);
			
			globalQueueLoader.addLoader(queueLoader);
			globalQueueLoader.load();
			
			return monitor;
		}

		/**
		 * description
		 * 
		 * @param queueId
		 * @return
		 */
		public function queueExists(queueId:String): Boolean
		{
			if (StringUtil.isBlank(queueId)) throw new ArgumentError("Argument <queueId> must not be null nor an empty String.");
			
			return loaderRepository.exists(queueId);
		}

		/**
		 * description
		 * 
		 * @param requestId
		 * @return
		 */
		public function resumeRequest(requestId:String): Boolean
		{
			return false
		}

		/**
		 * description
		 * 
		 * @param requestId
		 * @return
		 */
		public function stopRequest(requestId:String): Boolean
		{
			return false;
		}
		
		private function checkIfSomeAssetIsAlreadyLoadedAndCached(assets:IList):void
		{
			var asset:Asset;
			var it:IIterator = assets.iterator();
			
			while (it.hasNext())
			{
				asset = it.next();
				
				if (loadedAssetRepository.exists(asset.identification))
				{
					var report:LoadedAssetReport = loadedAssetRepository.find(asset.identification);
					
					var errorMessage:String = "The Asset object with identification:\n";
					errorMessage += "<" + asset.identification + ">\n";
					errorMessage += "Is already loaded and cached internally.\n";
					errorMessage += "It was loaded by a QueueLoader object with id:\n";
					errorMessage += "<" + report.queueId + ">\n";
					errorMessage += "Use the method <AssetLoadingService().isAssetLoaded()> to find it out.\n";
					errorMessage += "Also, the cached asset data can be retrieved using <AssetLoadingService().getAssetData()>.";
					
					throw new DuplicateLoadedAssetError(asset.identification, errorMessage);
				}
			}
		}
		
		private function createAssetLoadersAndPutInRepository(assets:IList):IList
		{
			var asset:Asset;
			var assetLoader:AssetLoader;
			var assetLoaders:IList = new ArrayList();
			var it:IIterator = assets.iterator();
			
			while (it.hasNext())
			{
				asset = it.next();
				assetLoader = assetLoaderFactory.create(asset);
				
				if (assetLoaders.contains(assetLoader))
				{
					var errorMessage:String = "Argument <assets> must not contain duplicate elements.\n";
					errorMessage += "Found duplicate Asset object:\n";
					errorMessage += "<" + asset.identification + ">\n";
					
					throw new ArgumentError(errorMessage);
				}
				
				//dispatches org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError
				//if <loaderRepository> already contains AssetLoader object with its id
				putAssetLoaderInRepository(assetLoader);
				
				assetLoaders.add(assetLoader);
			}
			
			return assetLoaders;
		}
		
		private function createAssetLoadingMonitorsAndPutInRepository(assets:IList):IList
		{
			var asset:Asset;
			var assetLoader:RefinedLoader;
			var assetLoadingMonitor:AssetLoadingMonitor;
			var assetLoadingMonitors:IList = new ArrayList();
			var it:IIterator = assets.iterator();
			
			while (it.hasNext())
			{
				asset = it.next();
				assetLoader = loaderRepository.find(asset.identification.toString());
				
				assetLoadingMonitor = new AssetLoadingMonitor(asset.identification, asset.type, assetLoader);
				assetLoadingMonitors.add(assetLoadingMonitor);
				
				//may throw DuplicateLoadingMonitorError
				loadingMonitorRepository.add(assetLoadingMonitor);
			}
			
			return assetLoadingMonitors;
		}
		
		private function createQueueLoaderAndPutInRepository(queueId:String, priority:LoadPriority, concurrentConnections:int):QueueLoader
		{
			var policy:LoadingPolicy = new LoadingPolicy(loaderRepository);
			policy.globalMaxConnections = LoadingManagementContext.getInstance().maxConcurrentConnections;
			policy.localMaxConnections = concurrentConnections;
			
			var queue:PriorityLoadQueue = new PlainPriorityLoadQueue(policy);
			var queueLoader:QueueLoader = new QueueLoader(queueId, priority, queue);
			
			try
			{
				loaderRepository.add(queueLoader);
			}
			catch(error:DuplicateLoaderError)
			{
				var errorMessage:String = "There is already a QueueLoader object stored with id:\n";
				errorMessage += "<" + queueLoader.id + ">\n";
				errorMessage += "Use the method <QueueLoadingService().queueExists()> to check if a QueueLoader object already exists.\n";
				errorMessage += "For further information please read the documentation section about the QueueLoader object.";
				
				throw new DuplicateLoaderError(queueId, errorMessage);
			}
			
			return queueLoader;
		}
		
		private function getQueueLoaderThatContainsLoader(loaderId:String):QueueLoader
		{
			var it:IIterator = loaderRepository.findAll().iterator();
			var refinedLoader:RefinedLoader;
			var queueLoader:QueueLoader;
			
			while (it.hasNext())
			{
				refinedLoader = it.next();
				if (!(refinedLoader is QueueLoader)) continue;
				
				if ((refinedLoader as QueueLoader).containsLoader(loaderId))
				{
					queueLoader = refinedLoader as QueueLoader;
					break;
				}
			}
			
			return queueLoader;
		}
		
		private function putAssetLoaderInRepository(assetLoader:AssetLoader):void
		{
			try
			{
				loaderRepository.add(assetLoader);
			}
			catch(error:DuplicateLoaderError)
			{
				var $assetLoader:RefinedLoader = loaderRepository.find(assetLoader.id);
				var $queueLoader:QueueLoader = getQueueLoaderThatContainsLoader(assetLoader.id);
				
				var errorMessage:String = "There is already an AssetLoader object stored with id:\n";
				errorMessage += "<" + assetLoader.id + ">\n";
				errorMessage += "Its current status is: <" + $assetLoader.status + ">\n";
				errorMessage += "And it belongs to QueueLoader object with id: <" + $queueLoader.id + ">\n";
				errorMessage += "Use the method <AssetLoadingService().isAssetQueued() AND AssetLoadingService().isAssetLoading()> to check if an AssetLoader object already exists.\n";
				errorMessage += "For further information please read the documentation section about the AssetLoader object.";
				
				throw new DuplicateLoaderError(assetLoader.id, errorMessage);
			}
		}

	}

}