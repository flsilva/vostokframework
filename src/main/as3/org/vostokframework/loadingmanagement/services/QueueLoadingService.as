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
	import org.vostokframework.loadingmanagement.domain.StatefulLoader;
	import org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError;
	import org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError;
	import org.vostokframework.loadingmanagement.domain.errors.LoadingMonitorNotFoundError;
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
		public function addAssetsInQueue(queueId:String, assets:IList): void
		{
			if (StringUtil.isBlank(queueId)) throw new ArgumentError("Argument <queueId> must not be null nor an empty String.");
			if (!assets || assets.isEmpty()) throw new ArgumentError("Argument <assets> must not be null nor empty.");
			
			if (!queueExists(queueId))
			{
				var message:String = "There is no QueueLoader object stored with id:\n";
				message += "<" + queueId + ">\n";
				message += "Use the method <QueueLoadingService().queueExists()> to check if a QueueLoader object exists.\n";
				
				throw new LoaderNotFoundError(queueId, message);
			}
			
			//throws org.as3coreaddendum.ClassCastError
			//if there's any type other than Asset in <assets>
			assets = new TypedList(assets, Asset);
			
			//throws org.vostokframework.loadingmanagement.report.errors.DuplicateLoadedAssetError
			//if some Asset object is already loaded and cached internally
			checkIfSomeAssetIsAlreadyLoadedAndCached(assets);
			
			//throws org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError
			//if <loaderRepository> contains an AssetLoader object with any Asset id inside <assets>
			//AND throws ArgumentError if <assets> argument contains any duplicate Asset object
			var assetLoaders:IList = createAssetLoadersAndPutInRepository(assets);
			
			//may throw DuplicateLoadingMonitorError
			var assetLoadingMonitors:IList = createAssetLoadingMonitorsAndPutInRepository(assets);
			
			var queueLoader:QueueLoader = loaderRepository.find(queueId) as QueueLoader;
			queueLoader.addLoaders(assetLoaders);
			
			var monitor:QueueLoadingMonitor = loadingMonitorRepository.find(queueLoader.id) as QueueLoadingMonitor;//TODO:concrete implementation referenced, change to abstraction
			monitor.addMonitors(assetLoadingMonitors);
		}
		
		/**
		 * description
		 * 
		 * @param queueId
		 */
		public function cancelQueueLoading(queueId:String): void
		{
			if (StringUtil.isBlank(queueId)) throw new ArgumentError("Argument <queueId> must not be null nor an empty String.");
			
			if (!queueExists(queueId))
			{
				var message:String = "There is no QueueLoader object stored with id:\n";
				message += "<" + queueId + ">\n";
				message += "Use the method <QueueLoadingService().queueExists()> to check if a QueueLoader object exists.\n";
				
				throw new LoaderNotFoundError(queueId, message);
			}
			
			var queueLoader:QueueLoader = loaderRepository.find(queueId) as QueueLoader;
			
			removeMonitorsOfLoaders(queueLoader.getLoaders());
			loadingMonitorRepository.remove(queueLoader.id);
			loaderRepository.removeAll(queueLoader.getLoaders());
			loaderRepository.remove(queueId);
			
			// if queueId is the only loader in globalQueueLoader
			// then after call to globalQueueLoader.cancelLoader(queueId)
			// globalQueueLoader state will be COMPLETE
			// and LoadingManagementContext object will dispose and replace it
			// with a new QueueLoader object.
			// therefore the subsequent call to globalQueueLoader.removeLoader()
			// will be performed on the new object producing no effect.
			globalQueueLoader.cancelLoader(queueId);//TODO:repassar API: esta estranho, hora recebe id:String hora recebe objeto
			globalQueueLoader.removeLoader(queueLoader);
			
			queueLoader.dispose();
		}

		/**
		 * description
		 * 
		 * @param queueId
		 * @return
		 */
		public function getQueueLoadingMonitor(queueId:String): ILoadingMonitor
		{
			if (StringUtil.isBlank(queueId)) throw new ArgumentError("Argument <queueId> must not be null nor an empty String.");
			
			var monitor:ILoadingMonitor = loadingMonitorRepository.find(queueId);
			if (!monitor)
			{
				var message:String = "There is no ILoadingMonitor object stored with id:\n";
				message += "<" + queueId + ">\n";
				message += "Use the method <QueueLoadingService().queueExists()> to check if an ILoadingMonitor object exists for a QueueLoader object with the specified <queueId> argument.\n";
				
				throw new LoadingMonitorNotFoundError(queueId, message);
			}
			
			return monitor;
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
			
			var loader:StatefulLoader = loaderRepository.find(queueId);
			if (!loader)
			{
				var message:String = "There is no QueueLoader object stored with id:\n";
				message += "<" + queueId + ">\n";
				message += "Use the method <QueueLoadingService().queueExists()> to check if a QueueLoader object exists.\n";
				
				throw new LoaderNotFoundError(queueId, message);
			}
			
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
			
			queueLoader.addLoaders(assetLoaders);
			
			//may throw DuplicateLoadingMonitorError
			var assetLoadingMonitors:IList = createAssetLoadingMonitorsAndPutInRepository(assets);
			
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
		public function resumeQueueLoading(queueId:String): Boolean
		{
			if (StringUtil.isBlank(queueId)) throw new ArgumentError("Argument <queueId> must not be null nor an empty String.");
			
			if (isQueueLoading(queueId)) return false;
			
			globalQueueLoader.resumeLoader(queueId);
			
			return true;
		}

		/**
		 * description
		 * 
		 * @param requestId
		 * @return
		 */
		public function stopQueueLoading(queueId:String): Boolean
		{
			if (StringUtil.isBlank(queueId)) throw new ArgumentError("Argument <queueId> must not be null nor an empty String.");
			
			if (!isQueueLoading(queueId)) return false;
			
			globalQueueLoader.stopLoader(queueId);
			
			return true;
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
			var assetLoader:StatefulLoader;
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
			var statefulLoader:StatefulLoader;
			var queueLoader:QueueLoader;
			
			while (it.hasNext())
			{
				statefulLoader = it.next();
				if (!(statefulLoader is QueueLoader)) continue;
				
				if ((statefulLoader as QueueLoader).containsLoader(loaderId))
				{
					queueLoader = statefulLoader as QueueLoader;
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
				var $assetLoader:StatefulLoader = loaderRepository.find(assetLoader.id);
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
		
		private function removeMonitorsOfLoaders(loaders:IList):void
		{
			var it:IIterator = loaders.iterator();
			var loader:StatefulLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				loadingMonitorRepository.remove(loader.id);
			}
		}

	}

}