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
	import org.as3collections.queues.PriorityQueue;
	import org.as3collections.IList;
	import org.as3collections.IQueue;
	import org.vostokframework.loadingmanagement.assetloaders.AbstractAssetLoader;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoaderQueueManager
	{
		/**
		 * @private
		 */
		private var _concurrentConnections:int;
		private var _queuedLoaders:IQueue;
		
		/**
		 * description
		 */
		public function get activeConnections(): int { return 0; }
		
		/**
		 * description
		 */
		public function get totalQueued(): int { return _queuedLoaders.size(); }

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
			
			addLoaderListeners(assetLoaders);
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
		public function getNext(): AbstractAssetLoader
		{
			return null;
		}
		
		private function addLoaderListeners(loaders:IList):void
		{
			
		}

	}

}