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
package org.vostokframework.loadingmanagement.domain.loaders
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3utils.StringUtil;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderStatus;
	import org.vostokframework.loadingmanagement.domain.PlainLoader;
	import org.vostokframework.loadingmanagement.domain.PriorityLoadQueue;
	import org.vostokframework.loadingmanagement.domain.StatefulLoader;
	import org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.QueueEvent;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class QueueLoader extends StatefulLoader
	{
		/**
		 * @private
		 */
		private var _queue:PriorityLoadQueue;
		
		/**
		 * description
		 * 
		 * @param id
		 * @param priority
		 * @param queue
		 */
		public function QueueLoader(id:String, priority:LoadPriority, queue:PriorityLoadQueue)
		{
			super(id, priority, 1);
			
			if (!queue) throw new ArgumentError("Argument <queue> must not be null.");
			_queue = queue;
			
			addQueueListener();
			addLoadersListener(queue.getLoaders());
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 */
		public function addLoader(loader:StatefulLoader): void
		{
			validateDisposal();
			
			if (status.equals(LoaderStatus.CANCELED)) throw new IllegalOperationError("The current status is <LoaderStatus.CANCELED>, therefore it is no longer allowed to add new loaders.");
			if (status.equals(LoaderStatus.COMPLETE)) throw new IllegalOperationError("The current status is <LoaderStatus.COMPLETE>, therefore it is no longer allowed to add new loaders.");
			if (status.equals(LoaderStatus.FAILED)) throw new IllegalOperationError("The current status is <LoaderStatus.FAILED>, therefore it is no longer allowed to add new loaders.");
			
			_queue.addLoader(loader);
			addLoaderListener(loader);
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 */
		public function addLoaders(loaders:IList): void
		{
			validateDisposal();
			
			if (status.equals(LoaderStatus.CANCELED)) throw new IllegalOperationError("The current status is <LoaderStatus.CANCELED>, therefore it is no longer allowed to add new loaders.");
			if (status.equals(LoaderStatus.COMPLETE)) throw new IllegalOperationError("The current status is <LoaderStatus.COMPLETE>, therefore it is no longer allowed to add new loaders.");
			if (status.equals(LoaderStatus.FAILED)) throw new IllegalOperationError("The current status is <LoaderStatus.FAILED>, therefore it is no longer allowed to add new loaders.");
			
			_queue.addLoaders(loaders);
			addLoadersListener(loaders);
		}

		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function cancelLoader(loaderId:String): void
		{
			validateDisposal();
			
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			var loader:StatefulLoader = _queue.find(loaderId);
			if (!loader)
			{
				var message:String = "There is no StatefulLoader object stored with id:\n";
				message += "<" + loaderId + ">";
				throw new LoaderNotFoundError(loaderId, message);
			}
			
			try
			{
				loader.cancel();
			}
			catch (error:Error)
			{
				//do nothing
			}
		}
		
		public function containsLoader(loaderId:String): Boolean
		{
			validateDisposal();
			return _queue.contains(loaderId);
		}
		
		public function getLoaders():IList
		{
			validateDisposal();
			return _queue.getLoaders();
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 */
		public function removeLoader(loader:StatefulLoader): void
		{
			validateDisposal();
			
			if (status.equals(LoaderStatus.CANCELED)) throw new IllegalOperationError("The current status is <LoaderStatus.CANCELED>, therefore it is no longer allowed to remove loaders.");
			if (status.equals(LoaderStatus.COMPLETE)) throw new IllegalOperationError("The current status is <LoaderStatus.COMPLETE>, therefore it is no longer allowed to remove loaders.");
			if (status.equals(LoaderStatus.FAILED)) throw new IllegalOperationError("The current status is <LoaderStatus.FAILED>, therefore it is no longer allowed to remove loaders.");
			
			_queue.removeLoader(loader);
			removeLoaderListener(loader);
		}

		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function resumeLoader(loaderId:String): void
		{
			validateDisposal();
			
			if (status.equals(LoaderStatus.CANCELED)) throw new IllegalOperationError("The current status is <LoaderStatus.CANCELED>, therefore it is no longer allowed to add new loaders.");
			if (status.equals(LoaderStatus.COMPLETE)) throw new IllegalOperationError("The current status is <LoaderStatus.COMPLETE>, therefore it is no longer allowed to add new loaders.");
			if (status.equals(LoaderStatus.FAILED)) throw new IllegalOperationError("The current status is <LoaderStatus.FAILED>, therefore it is no longer allowed to add new loaders.");
			
			_queue.resumeLoader(loaderId);
		}
		
		/**
		 * description
		 * 
		 * @param assetLoaderId
		 */
		public function stopLoader(loaderId:String): void
		{
			validateDisposal();
			
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			var loader:StatefulLoader = _queue.find(loaderId);
			if (!loader)
			{
				var message:String = "There is no StatefulLoader object stored with id:\n";
				message += "<" + loaderId + ">";
				throw new LoaderNotFoundError(loaderId, message);
			}
			
			try
			{
				loader.stop();
			}
			catch (error:Error)
			{
				//do nothing
			}
		}

		/**
		 * @private
 		 */
		override protected function doCancel(): void
		{
			validateDisposal();
			cancelLoaders();
		}
		
		/**
		 * @private
 		 */
		override protected function doDispose():void
		{
			removeQueueListener();
			removeLoadersListener(_queue.getLoaders());
			
			var loaders:IList = _queue.getLoaders();
			
			_queue.dispose();
			
			var it:IIterator = loaders.iterator();
			var loader:PlainLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				loader.dispose();
			}
			
			_queue = null;
		}
		
		/**
		 * @private
 		 */
		override protected function doLoad(): void
		{
			validateDisposal();
			loadNext();
		}

		/**
		 * @private
 		 */
		override protected function doStop(): void
		{
			validateDisposal();
			stopLoaders();
		}
		
		private function addLoadersListener(loaders:IList):void
		{
			validateDisposal();
			
			var it:IIterator = loaders.iterator();
			var loader:PlainLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				addLoaderListener(loader);
			}
		}
		
		private function addLoaderListener(loader:PlainLoader):void
		{
			validateDisposal();
			loader.addEventListener(LoaderEvent.OPEN, loaderOpenedHandler, false, 0, true);
		}
		
		private function addQueueListener():void
		{
			validateDisposal();
			_queue.addEventListener(QueueEvent.QUEUE_CHANGED, queueChangedHandler, false, 0, true);
		}
		
		private function cancelLoaders():void
		{
			validateDisposal();
			
			var it:IIterator = _queue.getLoaders().iterator();
			var loader:PlainLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				
				try
				{
					loader.cancel();
				}
				catch (error:Error)
				{
					//do nothing
				}
			}
		}
		
		private function loadNext():void
		{
			validateDisposal();
			
			if (!status.equals(LoaderStatus.CONNECTING) &&
				!status.equals(LoaderStatus.LOADING)) return;
			
			if (_queue.isComplete)
			{
				removeQueueListener();
				loadingComplete();//TODO:pensar se vai disparar FAILED se todos os loaders falharem
				return;
			}
			
			var loader:PlainLoader = _queue.getNext();
			if (loader) loader.load();
		}
		
		private function loaderOpenedHandler(event:LoaderEvent):void
		{
			validateDisposal();
			if (!status.equals(LoaderStatus.LOADING)) loadingStarted(null, event.latency);
		}
		
		private function queueChangedHandler(event:QueueEvent):void
		{
			validateDisposal();
			loadNext();
		}
		
		private function removeLoadersListener(loaders:IList):void
		{
			validateDisposal();
			
			var it:IIterator = loaders.iterator();
			var loader:PlainLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				removeLoaderListener(loader);
			}
		}
		
		private function removeLoaderListener(loader:PlainLoader):void
		{
			validateDisposal();
			loader.removeEventListener(LoaderEvent.OPEN, loaderOpenedHandler, false);
		}
		
		private function removeQueueListener():void
		{
			validateDisposal();
			_queue.removeEventListener(QueueEvent.QUEUE_CHANGED, queueChangedHandler, false);
		}
		
		private function stopLoaders():void
		{
			validateDisposal();
			
			var it:IIterator = _queue.getLoaders().iterator();
			var loader:PlainLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				try
				{
					loader.stop();
				}
				catch (error:Error)
				{
					//do nothing
				}
			}
		}
		
	}

}