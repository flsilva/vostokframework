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
	import org.as3collections.IList;
	import org.as3collections.IQueue;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3collections.queues.PriorityQueue;
	import org.as3coreaddendum.system.IDisposable;
	import org.vostokframework.loadingmanagement.events.RequestLoaderEvent;
	import org.vostokframework.loadingmanagement.policies.RequestLoadingPolicy;

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
		private var _policy:RequestLoadingPolicy;
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
		public function RequestLoaderQueueManager(policy:RequestLoadingPolicy)
		{
			_policy = policy;
			_queuedLoaders = new PriorityQueue();
			_requestLoaders = new ArrayList();
			_canceledLoaders = new ArrayList();
			_completeLoaders = new ArrayList();
			_loadingLoaders = new ArrayList();
			_failedLoaders = new ArrayList();
			_stoppedLoaders = new ArrayList();
		}
		
		public function addLoader(loader:RequestLoader):void
		{
			_queuedLoaders.add(loader);
			_requestLoaders = new ArrayList(_queuedLoaders.toArray());
			addLoaderListeners(loader);
		}
		
		public function dispose():void
		{
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
			//TODO
		}

		/**
		 * description
		 */
		public function getAllFailed(): void
		{
			//TODO
		}

		/**
		 * description
		 */
		public function getAllLoaded(): void
		{
			//TODO
		}

		/**
		 * description
		 */
		public function getAllLoading(): void
		{
			//TODO
		}

		/**
		 * description
		 */
		public function getAllQueued(): void
		{
			//TODO
		}

		/**
		 * description
		 */
		public function getAllStopped(): void
		{
			//TODO
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function getNext(): RequestLoader
		{
			if (_queuedLoaders.isEmpty()) return null;
			if (!_policy.allow(activeConnections, _loadingLoaders, _queuedLoaders.peek())) return null;
			
			return _queuedLoaders.poll();
		}
		
		private function addLoaderListeners(loader:RequestLoader):void
		{
			loader.addEventListener(RequestLoaderEvent.STATUS_CHANGED, loaderStatusChangedHandler, false, 0, true);
		}
		
		private function loaderStatusChangedHandler(event:RequestLoaderEvent):void
		{
			removeFromLists(event.target as RequestLoader);
			
			//it is not needed to validate RequestLoaderStatus.LOADING status
			//because before it is setted the RequestLoaderStatus.TRYING_TO_CONNECT status
			//is setted, and for the purpose of this object it has the same effect
			//as the RequestLoaderStatus.LOADING status
			if (event.status.equals(RequestLoaderStatus.TRYING_TO_CONNECT))
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
		
		private function removeLoaderListeners(loader:RequestLoader):void
		{
			loader.removeEventListener(RequestLoaderEvent.STATUS_CHANGED, loaderStatusChangedHandler, false);
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