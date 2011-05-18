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
	import org.as3utils.StringUtil;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class RequestLoader
	{
		/**
		 * description
		 */
		private var _id:String;
		private var _priority:LoadingRequestPriority;
		private var _queueManager:AssetLoaderQueueManager;
		private var _status:RequestLoaderStatus;
		
		/**
		 * description
		 */
		public function get id(): String { return _id; }
		
		/**
		 * description
		 */
		public function get priority(): LoadingRequestPriority { return _priority; }
		
		/**
		 * description
		 */
		public function get status(): RequestLoaderStatus { return _status; }
		
		/**
		 * description
		 * 
		 * @param id
		 * @param queueManager
		 * @param priority
		 */
		public function RequestLoader(id:String, queueManager:AssetLoaderQueueManager, priority:LoadingRequestPriority): void
		{
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			if (!queueManager) throw new ArgumentError("Argument <queueManager> must not be null.");
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			
			_id = id;
			_queueManager = queueManager;
			_priority = priority;
		}
		
		public function cancel(): void
		{
			
		}

		/**
		 * description
		 * 
		 * @param assetLoaderId
		 */
		public function cancelAssetLoader(assetLoaderId:String): void
		{
			
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function load(): Boolean
		{
			return false;
		}

		/**
		 * description
		 * 
		 * @param assetLoaders
		 */
		public function mergeAssetLoaders(assetLoaders:ICollection): void
		{
			
		}

		/**
		 * description
		 * 
		 * @param assetLoaderId
		 */
		public function resumeAssetLoader(assetLoaderId:String): void
		{
			
		}

		/**
		 * description
		 */
		public function stop(): void
		{
			
		}

		/**
		 * description
		 * 
		 * @param assetLoaderId
		 */
		public function stopAssetLoader(assetLoaderId:String): void
		{
			
		}

	}

}