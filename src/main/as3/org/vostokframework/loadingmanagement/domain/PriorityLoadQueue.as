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
package org.vostokframework.loadingmanagement.domain
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.IQueue;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3collections.queues.IndexablePriorityQueue;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3coreaddendum.system.IDisposable;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.QueueEvent;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class PriorityLoadQueue extends EventDispatcher implements IDisposable
	{
		/**
		 * @private
		 */
		private var _canceledLoaders:IList;
		private var _completeLoaders:IList;
		private var _failedLoaders:IList;
		private var _index:int;
		private var _loaders:IQueue;
		private var _loadingLoaders:IList;
		private var _queuedLoaders:IQueue;
		private var _stoppedLoaders:IList;
		
		/**
		 * @private
		 */
		protected function get loadingLoaders():IList { return _loadingLoaders; }
		protected function get queuedLoaders():IQueue { return _queuedLoaders; }
		
		/**
		 * description
		 */
		public function get isComplete(): Boolean
		{
			return totalLoading == 0 && totalQueued == 0 && totalStopped == 0;
		}
		
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
		public function PriorityLoadQueue()
		{
			if (ReflectionUtil.classPathEquals(this, PriorityLoadQueue))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be instantiated directly.");
			
			_queuedLoaders = new IndexablePriorityQueue();
			_loaders = new IndexablePriorityQueue();
			_canceledLoaders = new ArrayList();
			_completeLoaders = new ArrayList();
			_loadingLoaders = new ArrayList();
			_failedLoaders = new ArrayList();
			_stoppedLoaders = new ArrayList();
		}
		
		public function addLoader(loader:RefinedLoader):void
		{
			loader.index = _index++;
			_queuedLoaders.add(loader);
			_loaders.add(loader);
			addLoaderListeners(loader);
		}
		
		public function dispose():void
		{
			removeLoadersListeners();
			
			_loaders.clear();
			_canceledLoaders.clear();
			_completeLoaders.clear();
			_loadingLoaders.clear();
			_queuedLoaders.clear();
			_failedLoaders.clear();
			_stoppedLoaders.clear();
			
			_loaders = null;
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
		public function getLoaders(): IList
		{
			return new ReadOnlyArrayList(_loaders.toArray());
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
		public function getNext(): RefinedLoader
		{
			if (_queuedLoaders.isEmpty()) return null;
			if (!allowGetNext()) return null;
			return doGetNext();
		}
		
		protected function allowGetNext():Boolean
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function doGetNext():RefinedLoader
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		private function addLoaderListeners(loader:RefinedLoader):void
		{
			loader.addEventListener(LoaderEvent.CANCELED, loaderCanceledHandler, false, 0, true);
			loader.addEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false, 0, true);
			loader.addEventListener(LoaderEvent.FAILED, loaderFailedHandler, false, 0, true);
			loader.addEventListener(LoaderEvent.STOPPED, loaderStoppedHandler, false, 0, true);
			loader.addEventListener(LoaderEvent.CONNECTING, loaderConnectingHandler, false, 0, true);
		}
		
		private function changed():void
		{
			dispatchEvent(new QueueEvent(QueueEvent.QUEUE_CHANGED, totalLoading));
		}
		
		private function loaderCanceledHandler(event:LoaderEvent):void
		{
			removeFromLists(event.target as RefinedLoader);
			_canceledLoaders.add(event.target);
			changed();
		}
		
		private function loaderCompleteHandler(event:LoaderEvent):void
		{
			removeFromLists(event.target as RefinedLoader);
			_completeLoaders.add(event.target);
			changed();
		}
		
		private function loaderFailedHandler(event:LoaderEvent):void
		{
			removeFromLists(event.target as RefinedLoader);
			_failedLoaders.add(event.target);
			changed();
		}
		
		private function loaderStoppedHandler(event:LoaderEvent):void
		{
			removeFromLists(event.target as RefinedLoader);
			_stoppedLoaders.add(event.target);
			changed();
		}
		
		private function loaderConnectingHandler(event:LoaderEvent):void
		{
			removeFromLists(event.target as RefinedLoader);
			_loadingLoaders.add(event.target);
			changed();
		}
		
		private function removeLoadersListeners():void
		{
			var it:IIterator = _loaders.iterator();
			var loader:RefinedLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				loader.removeEventListener(LoaderEvent.CANCELED, loaderCanceledHandler, false);
				loader.removeEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false);
				loader.removeEventListener(LoaderEvent.FAILED, loaderFailedHandler, false);
				loader.removeEventListener(LoaderEvent.STOPPED, loaderStoppedHandler, false);
				loader.removeEventListener(LoaderEvent.CONNECTING, loaderConnectingHandler, false);
			}
		}
		
		private function removeFromLists(loader:RefinedLoader):void
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