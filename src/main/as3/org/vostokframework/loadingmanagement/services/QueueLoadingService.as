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
	import org.as3utils.StringUtil;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.PlainPriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.PriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.loaders.AssetLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.QueueLoader;
	import org.vostokframework.loadingmanagement.domain.monitors.AssetLoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.QueueLoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicy;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class QueueLoadingService
	{
		private static var _context:LoadingManagementContext;

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
			
			var policy:LoadingPolicy = new LoadingPolicy(LoadingManagementContext.getInstance().loaderRepository);
			policy.globalMaxConnections = LoadingManagementContext.getInstance().maxConcurrentConnections;
			policy.localMaxConnections = concurrentConnections;
			
			var asset:Asset;
			var assetLoader:AssetLoader;
			var assetLoadingMonitor:AssetLoadingMonitor;
			var assetLoaders:IList = new ArrayList();
			var assetLoadingMonitors:IList = new ArrayList();
			var it:IIterator = assets.iterator();
			
			while (it.hasNext())
			{
				asset = it.next();
				assetLoader = LoadingManagementContext.getInstance().assetLoaderFactory.create(asset);
				assetLoaders.add(assetLoader);
				
				assetLoadingMonitor = new AssetLoadingMonitor(asset.id, asset.type, assetLoader);
				assetLoadingMonitors.add(assetLoadingMonitor);
			}
			
			var queue:PriorityLoadQueue = new PlainPriorityLoadQueue(policy);
			queue.addLoaders(assetLoaders);
			
			var queueLoader:QueueLoader = new QueueLoader(queueId, priority, queue);
			LoadingManagementContext.getInstance().globalQueueLoader.addLoader(queueLoader);
			
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
		 */
		public function QueueLoadingService(): void
		{
			
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