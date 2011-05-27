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
	import org.vostokframework.loadingmanagement.events.RequestLoaderEvent;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class RequestLoaderManager
	{
		private var _context:LoadingManagementContext;
		private var _queueManager:RequestLoaderQueueManager;
		private var _requestLoaderQueueManager: RequestLoaderQueueManager;
		
		/**
		 * description
		 * 
		 * @param id
		 * @param queueManager
		 * @param priority
		 */
		public function RequestLoaderManager(queueManager:RequestLoaderQueueManager)
		{
			if (!queueManager) throw new ArgumentError("Argument <queueManager> must not be null.");
			
			_queueManager = queueManager;
			_context = LoadingManagementContext.getInstance();
		}
		
		/**
		 * description
		 * 
		 * @param id
		 * @return
		 */
		public function cancelRequest(id:String): Boolean
		{
			return false;
		}

		/**
		 * description
		 * 
		 * @param requestId
		 * @param assets
		 * @param priority
		 * @param simultaneousConnections
		 * @return
		 */
		public function load(loader:RequestLoader): void
		{
			_queueManager.addLoader(loader);
			addLoaderListener(loader);
			loadNext();
		}

		/**
		 * description
		 * 
		 * @param requestId
		 * @param assets
		 * @return
		 */
		public function mergeAssetsOnRequest(requestId:String, assets:ICollection): void
		{
			
		}
		
		private function addLoaderListener(loader:RequestLoader):void
		{
			loader.addEventListener(RequestLoaderEvent.STATUS_CHANGED, loaderStatusChangedHandler, false, 0, true);
		}
		
		private function loaderStatusChangedHandler(event:RequestLoaderEvent):void
		{
			loadNext();
		}
		
		private function loadNext():void
		{
			var loader:RequestLoader = _queueManager.getNext();
			if (loader) loader.load();
		}

	}

}