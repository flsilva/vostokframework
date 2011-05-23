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
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.IQueue;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3collections.queues.PriorityQueue;
	import org.as3coreaddendum.system.IDisposable;
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoader;
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoaderStatus;
	import org.vostokframework.loadingmanagement.events.AssetLoaderEvent;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoaderQueueManager implements IDisposable
	{
		/**
		 * @private
		 */
		private var _assetLoaders:IList;
		private var _canceledLoaders:IList;
		private var _completeLoaders:IList;
		private var _concurrentConnections:int;
		private var _failedLoaders:IList;
		private var _loadingLoaders:IList;
		private var _queuedLoaders:IQueue;
		private var _stoppedLoaders:IList;
		
		/**
		 * description
		 */
		public function get activeConnections(): int { return _loadingLoaders.size(); }
		
		/**
		 * description
		 */
		public function get totalCanceled(): int { return _canceledLoaders.size(); }
		
		/**
		 * description
		 */
		public function get totalComplete(): int { return _completeLoaders.size(); }
		
		/**
		 * description
		 */
		public function get totalFailed(): int { return _failedLoaders.size(); }
		
		/**
		 * description
		 */
		public function get totalLoading(): int { return _loadingLoaders.size(); }
		
		/**
		 * description
		 */
		public function get totalQueued(): int { return _queuedLoaders.size(); }
		
		/**
		 * description
		 */
		public function get totalStopped(): int { return _stoppedLoaders.size(); }

		/**
		 * description
		 * 
		 * @param assetLoaders
		 * @param concurrentConnections
		 */
		public function AssetLoaderQueueManager(assetLoaders:IList, concurrentConnections:int)
		{
			if (!assetLoaders || assetLoaders.isEmpty()) throw new ArgumentError("Argument <assetLoaders> must not be null nor empty.");
			if (concurrentConnections < 1) throw new ArgumentError("Argument <concurrentConnections> must be greater than zero.");
			
			_concurrentConnections = concurrentConnections;
			_queuedLoaders = new PriorityQueue(assetLoaders.toArray());
			_assetLoaders = new ArrayList(_queuedLoaders.toArray());
			_canceledLoaders = new ArrayList();
			_completeLoaders = new ArrayList();
			_loadingLoaders = new ArrayList();
			_failedLoaders = new ArrayList();
			_stoppedLoaders = new ArrayList();
			
			addLoaderListeners();
		}
		
		public function dispose():void
		{
			removeLoaderListeners();
			_assetLoaders.clear();
			_canceledLoaders.clear();
			_completeLoaders.clear();
			_loadingLoaders.clear();
			_queuedLoaders.clear();
			_failedLoaders.clear();
			_stoppedLoaders.clear();
			
			_assetLoaders = null;
			_canceledLoaders = null;
			_completeLoaders = null;
			_loadingLoaders = null;
			_queuedLoaders = null;
			_failedLoaders = null;
			_stoppedLoaders = null;
		}
		
		/**
		 * description
		 */
		public function getAssetLoaders(): IList
		{
			return new ReadOnlyArrayList(_assetLoaders.toArray());
		}
		
		/**
		 * description
		 */
		public function getAllCanceled(): void
		{
			
		}

		/**
		 * description
		 */
		public function getAllFailed(): void
		{
			
		}

		/**
		 * description
		 */
		public function getAllLoaded(): void
		{
			
		}

		/**
		 * description
		 */
		public function getAllLoading(): void
		{
			
		}

		/**
		 * description
		 */
		public function getAllQueued(): void
		{
			
		}

		/**
		 * description
		 */
		public function getAllStopped(): void
		{
			
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function getNext(): AssetLoader
		{
			if (activeConnections >= _concurrentConnections) return null;
			
			return _queuedLoaders.poll();
		}
		
		private function addLoaderListeners():void
		{
			var it:IIterator = _assetLoaders.iterator();
			var loader:AssetLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				loader.addEventListener(AssetLoaderEvent.STATUS_CHANGED, loaderStatusChangedHandler, false, 0, true);
			}
		}
		
		private function removeLoaderListeners():void
		{
			var it:IIterator = _assetLoaders.iterator();
			var loader:AssetLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				loader.removeEventListener(AssetLoaderEvent.STATUS_CHANGED, loaderStatusChangedHandler, false);
			}
		}
		
		private function loaderStatusChangedHandler(event:AssetLoaderEvent):void
		{
			removeFromLists(event.target as AssetLoader);
			
			//it is not needed to validate AssetLoaderStatus.LOADING status
			//because before it is setted the AssetLoaderStatus.TRYING_TO_CONNECT status
			//is setted, and for the purpose of this object it has the same effect
			//as the AssetLoaderStatus.LOADING status
			if (event.status.equals(AssetLoaderStatus.TRYING_TO_CONNECT))
			{
				_loadingLoaders.add(event.target);
			}
			else if (event.status.equals(AssetLoaderStatus.STOPPED))
			{
				_stoppedLoaders.add(event.target);
			}
			else if (event.status.equals(AssetLoaderStatus.CANCELED))
			{
				_canceledLoaders.add(event.target);
			}
			else if (event.status.equals(AssetLoaderStatus.COMPLETE))
			{
				_completeLoaders.add(event.target);
			}
			//TODO:terminar de implementar
			/*
			else if (event.status.equals(AssetLoaderStatus.FAILED_EXHAUSTED_ATTEMPTS) ||
					event.status.equals(AssetLoaderStatus.FAILED_SECURITY_ERROR))
			{
				_failedLoaders.add(event.target);
			}
			else if (event.status.equals(AssetLoaderStatus.FAILED_ASYNC_ERROR))
			{
				_failedLoaders.add(event.target);
			}
			else if (event.status.equals(AssetLoaderStatus.FAILED_IO_ERROR))
			{
				_failedLoaders.add(event.target);
			}
			else if (event.status.equals(AssetLoaderStatus.FAILED_UNKNOWN_ERROR))
			{
				_failedLoaders.add(event.target);
			}
			*/
			/*else
			{
				//_queuedLoaders.add(event.target);
			}*/
		}
		
		private function removeFromLists(loader:AssetLoader):void
		{
			_canceledLoaders.remove(loader);
			_completeLoaders.remove(loader);
			_loadingLoaders.remove(loader);
			_queuedLoaders.remove(loader);
			_failedLoaders.remove(loader);
			_stoppedLoaders.remove(loader);
		}

	}

}