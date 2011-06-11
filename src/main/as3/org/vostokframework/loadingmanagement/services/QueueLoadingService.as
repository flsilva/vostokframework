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
	import org.vostokframework.loadingmanagement.report.LoadedAssetReport;
	import org.vostokframework.loadingmanagement.report.errors.DuplicateLoadedAssetError;
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.as3utils.StringUtil;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.PlainPriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.PriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError;
	import org.vostokframework.loadingmanagement.domain.loaders.AssetLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.AssetLoaderFactory;
	import org.vostokframework.loadingmanagement.domain.loaders.QueueLoader;
	import org.vostokframework.loadingmanagement.domain.monitors.AssetLoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.QueueLoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicy;
	import org.vostokframework.loadingmanagement.report.LoadedAssetRepository;

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
		public function addAssetsOnQueue(queueId:String, assets:IList): ILoadingMonitor
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
		 * @param requestId
		 * @return
		 */
		public function isQueueLoading(requestId:String): Boolean
		{
			return false;
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
			
			if (!priority) priority = LoadPriority.MEDIUM;
			
			var errorMessage:String;
			var asset:Asset;
			var assetLoader:AssetLoader;
			var assetLoadingMonitor:AssetLoadingMonitor;
			var assetLoaders:IList = new ArrayList();
			var assetLoadingMonitors:IList = new ArrayList();
			var it:IIterator = assets.iterator();
			
			while (it.hasNext())
			{
				asset = it.next();
				
				if (loadedAssetRepository.exists(asset.identification))
				{
					var report:LoadedAssetReport = loadedAssetRepository.find(asset.identification);
					
					errorMessage = "The Asset object with identification:\n";
					errorMessage += "<" + asset.identification + ">\n";
					errorMessage += "Is already loaded and cached internally.\n";
					errorMessage += "It was loaded by a queue with id:\n";
					errorMessage += "<" + report.queueId + ">\n";
					errorMessage += "Use the method <AssetLoadingService().isAssetLoaded()> to find it out.\n";
					errorMessage += "Also, the cached asset data can be retrieved using <AssetLoadingService().getAssetData()>.";
					
					throw new DuplicateLoadedAssetError(asset.identification, errorMessage);
				}
				
				assetLoader = assetLoaderFactory.create(asset);
				assetLoaders.add(assetLoader);
				
				try
				{
					loaderRepository.add(assetLoader);
				}
				catch(error:DuplicateLoaderError)
				{
					errorMessage = "There is already an AssetLoader object stored with id:\n";
					errorMessage += "<" + assetLoader.id + ">\n";
					errorMessage += "Use the method <AssetLoadingService().isAssetQueued() AND AssetLoadingService().isAssetLoading()> to check if an AssetLoader object already exists.\n";
					errorMessage += "For further information please read the documentation section about the AssetLoader object.";
					//TODO: dizer em qual queue o AssetLoader está
					throw new DuplicateLoaderError(queueId, errorMessage);
				}
				
				assetLoadingMonitor = new AssetLoadingMonitor(asset.identification.id, asset.type, assetLoader);
				assetLoadingMonitors.add(assetLoadingMonitor);
			}
			
			var policy:LoadingPolicy = new LoadingPolicy(loaderRepository);
			policy.globalMaxConnections = LoadingManagementContext.getInstance().maxConcurrentConnections;
			policy.localMaxConnections = concurrentConnections;
			
			var queue:PriorityLoadQueue = new PlainPriorityLoadQueue(policy);
			queue.addLoaders(assetLoaders);
			
			var queueLoader:QueueLoader = new QueueLoader(queueId, priority, queue);
			
			try
			{
				loaderRepository.add(queueLoader);
			}
			catch(error:DuplicateLoaderError)
			{
				errorMessage = "There is already a QueueLoader object stored with id:\n";
				errorMessage += "<" + queueLoader.id + ">\n";
				errorMessage += "Use the method <QueueLoadingService().queueExists()> to check if a QueueLoader object already exists.\n";
				errorMessage += "For further information please read the documentation section about the QueueLoader object.";
				
				throw new DuplicateLoaderError(queueId, errorMessage);
			}
			
			globalQueueLoader.addLoader(queueLoader);
			globalQueueLoader.load();
			
			var monitor:QueueLoadingMonitor = new QueueLoadingMonitor(queueLoader, assetLoadingMonitors);
			
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
			return false;
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
			return false
		}

	}

}