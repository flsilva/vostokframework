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
	import org.as3collections.ICollection;
	import org.as3collections.IIterator;
	import org.as3utils.StringUtil;
	import org.vostokframework.loadingmanagement.errors.AssetLoaderNotFoundError;
	import org.vostokframework.loadingmanagement.events.QueueEvent;

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
		 * @param asset
		 * @param fileLoader
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
		 * @param assetLoaderId
		 */
		public function cancelAssetLoader(assetLoaderId:String): void
		{
			//TODO
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
		 * @param assetLoaders
		 */
		public function mergeAssetLoaders(assetLoaders:ICollection): void
		{
			//TODO
		}

		/**
		 * description
		 * 
		 * @param assetLoaderId
		 */
		public function resumeAssetLoader(assetLoaderId:String): void
		{
			//TODO
		}
		
		/**
		 * description
		 * 
		 * @param assetLoaderId
		 */
		public function stopAssetLoader(assetLoaderId:String): void
		{
			if (StringUtil.isBlank(assetLoaderId)) throw new ArgumentError("Argument <assetLoaderId> must not be null nor an empty String.");
			
			var it:IIterator = _queue.getLoaders().iterator();
			var loader:AssetLoader;//TODO:pensar sobre essa questao de ter que usar o tipo AssetLoader apenas aqui por causa do id. pensar sobre PlainLoader(id:String = null)
			
			while (it.hasNext())
			{
				loader = it.next();
				if (loader.id == assetLoaderId)
				{
					try
					{
						loader.stop();
					}
					catch (error:Error)
					{
						//do nothing
					}
					
					return;
				}
			}
			
			var message:String = "There is no AssetLoader object stored with id:\n";
			message += "<" + assetLoaderId + ">";
			throw new AssetLoaderNotFoundError(assetLoaderId, message);
		}

		/**
		 * @private
 		 */
		override protected function doCancel(): void
		{
			cancelAssetLoaders();
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
			stopAssetLoaders();
		}
		
		private function addQueueListener():void
		{
			_queue.addEventListener(QueueEvent.QUEUE_CHANGED, queueChangedHandler, false, 0, true);
		}
		
		private function queueChangedHandler(event:QueueEvent):void
		{
			if (!status.equals(RequestLoaderStatus.LOADING) && event.activeConnections > 0) loadingStarted();
			loadNext();
		}
		
		private function cancelAssetLoaders():void
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
			if (!status.equals(RequestLoaderStatus.TRYING_TO_CONNECT) &&
				!status.equals(RequestLoaderStatus.LOADING)) return;
			
			if (_queue.isComplete)
			{
				removeQueueListener();
				loadingComplete();
				return;
			}
			
			var assetLoader:PlainLoader = _queue.getNext();
			if (assetLoader) assetLoader.load();
		}
		
		private function removeQueueListener():void
		{
			_queue.removeEventListener(QueueEvent.QUEUE_CHANGED, queueChangedHandler, false);
		}
		
		private function stopAssetLoaders():void
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