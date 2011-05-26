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
	import org.vostokframework.loadingmanagement.events.RequestLoaderEvent;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class RequestLoaderQueueManager implements IDisposable
	{
		/**
		 * @private
		 */
		private var _canceledLoaders:IList;
		private var _completeLoaders:IList;
		private var _failedLoaders:IList;
		private var _loadingLoaders:IList;
		private var _queuedLoaders:IQueue;
		private var _requestLoaders:IList;
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
		 * @param requestLoaders
		 */
		public function RequestLoaderQueueManager(requestLoaders:IList)
		{
			if (!requestLoaders || requestLoaders.isEmpty()) throw new ArgumentError("Argument <requestLoaders> must not be null nor empty.");
			
			_queuedLoaders = new PriorityQueue(requestLoaders.toArray());
			_requestLoaders = new ArrayList(_queuedLoaders.toArray());
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
			_requestLoaders.clear();
			_canceledLoaders.clear();
			_completeLoaders.clear();
			_loadingLoaders.clear();
			_queuedLoaders.clear();
			_failedLoaders.clear();
			_stoppedLoaders.clear();
			
			_requestLoaders = null;
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
		public function getRequestLoaders(): IList
		{
			return new ReadOnlyArrayList(_requestLoaders.toArray());
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
		public function getNext(): RequestLoader
		{
			if (activeConnections >= LoadingManagementContext.getInstance().maxConcurrentRequests) return null;
			
			return _queuedLoaders.poll();
		}
		
		private function addLoaderListeners():void
		{
			var it:IIterator = _requestLoaders.iterator();
			var loader:RequestLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				loader.addEventListener(RequestLoaderEvent.STATUS_CHANGED, loaderStatusChangedHandler, false, 0, true);
			}
		}
		
		private function removeLoaderListeners():void
		{
			var it:IIterator = _requestLoaders.iterator();
			var loader:RequestLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				loader.removeEventListener(RequestLoaderEvent.STATUS_CHANGED, loaderStatusChangedHandler, false);
			}
		}
		
		private function loaderStatusChangedHandler(event:RequestLoaderEvent):void
		{
			removeFromLists(event.target as RequestLoader);
			
			if (event.status.equals(RequestLoaderStatus.LOADING))
			{
				_loadingLoaders.add(event.target);
			}
			else if (event.status.equals(RequestLoaderStatus.STOPPED))
			{
				_stoppedLoaders.add(event.target);
			}
			else if (event.status.equals(RequestLoaderStatus.CANCELED))
			{
				_canceledLoaders.add(event.target);
			}
			else if (event.status.equals(RequestLoaderStatus.COMPLETE) ||
					event.status.equals(RequestLoaderStatus.COMPLETE_WITH_FAILURES))
			{
				_completeLoaders.add(event.target);
			}
		}
		
		private function removeFromLists(loader:RequestLoader):void
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