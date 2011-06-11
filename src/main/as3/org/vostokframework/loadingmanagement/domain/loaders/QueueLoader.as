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
	import org.vostokframework.loadingmanagement.domain.RefinedLoader;
	import org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError;
	import org.vostokframework.loadingmanagement.domain.events.QueueEvent;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class QueueLoader extends RefinedLoader
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
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 */
		public function addLoader(loader:RefinedLoader): void
		{
			if (status.equals(LoaderStatus.CANCELED)) throw new IllegalOperationError("The current status is <LoaderStatus.CANCELED>, therefore it is no longer allowed to add new loaders.");
			if (status.equals(LoaderStatus.COMPLETE)) throw new IllegalOperationError("The current status is <LoaderStatus.COMPLETE>, therefore it is no longer allowed to add new loaders.");
			if (status.equals(LoaderStatus.FAILED)) throw new IllegalOperationError("The current status is <LoaderStatus.FAILED>, therefore it is no longer allowed to add new loaders.");
			
			_queue.addLoader(loader);
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 */
		public function addLoaders(loaders:IList): void
		{
			if (status.equals(LoaderStatus.CANCELED)) throw new IllegalOperationError("The current status is <LoaderStatus.CANCELED>, therefore it is no longer allowed to add new loaders.");
			if (status.equals(LoaderStatus.COMPLETE)) throw new IllegalOperationError("The current status is <LoaderStatus.COMPLETE>, therefore it is no longer allowed to add new loaders.");
			if (status.equals(LoaderStatus.FAILED)) throw new IllegalOperationError("The current status is <LoaderStatus.FAILED>, therefore it is no longer allowed to add new loaders.");
			
			_queue.addLoaders(loaders);
		}

		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function cancelLoader(loaderId:String): void
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			var loader:RefinedLoader = _queue.find(loaderId);
			if (!loader)
			{
				var message:String = "There is no RefinedLoader object stored with id:\n";
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
			return _queue.contains(loaderId);
		}

		override public function dispose():void
		{
			removeQueueListener();
			_queue.dispose();
			
			_queue = null;
			
			super.dispose();
		}

		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function resumeLoader(loaderId:String): void
		{
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
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			var loader:RefinedLoader = _queue.find(loaderId);
			if (!loader)
			{
				var message:String = "There is no RefinedLoader object stored with id:\n";
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
			cancelLoaders();
		}
		
		/**
		 * @private
 		 */
		override protected function doLoad(): void
		{
			loadNext();
		}

		/**
		 * @private
 		 */
		override protected function doStop(): void
		{
			stopLoaders();
		}
		
		private function addQueueListener():void
		{
			_queue.addEventListener(QueueEvent.QUEUE_CHANGED, queueChangedHandler, false, 0, true);
		}
		
		private function queueChangedHandler(event:QueueEvent):void
		{
			if (!status.equals(LoaderStatus.LOADING) && event.activeConnections > 0) loadingStarted();
			loadNext();
		}
		
		private function cancelLoaders():void
		{
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
		
		private function removeQueueListener():void
		{
			_queue.removeEventListener(QueueEvent.QUEUE_CHANGED, queueChangedHandler, false);
		}
		
		private function stopLoaders():void
		{
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