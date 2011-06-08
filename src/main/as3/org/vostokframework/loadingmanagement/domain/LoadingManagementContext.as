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
	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingManagementContext
	{
		/**
		 * @private
		 */
		private static var _instance:LoadingManagementContext = new LoadingManagementContext();
		
		//private var _assetLoaderFactory:AbstractAssetLoaderFactory;
		private var _maxConcurrentConnections:int;
		private var _maxConcurrentQueues:int;
		//private var _requestLoaderFactory:AbstractRequestLoaderFactory;
		
		/**
		 * @private
		 */
		private static var _created :Boolean = false;
		
		{
			_created = true;
		}
		
		//public function get assetLoaderFactory(): AbstractAssetLoaderFactory { return _assetLoaderFactory; }

		/**
		 * description
		 */
		public function get maxConcurrentConnections(): int { return _maxConcurrentConnections; }

		/**
		 * description
		 */
		public function get maxConcurrentQueues(): int { return _maxConcurrentQueues; }
		
		/**
		 * description
		 */
		//public function get requestLoaderFactory(): AbstractRequestLoaderFactory { return _requestLoaderFactory; }
		
		/**
		 * description
		 */
		public function LoadingManagementContext(): void
		{
			if (_created) throw new IllegalOperationError("<LoadingManagementContext> is a singleton class and should be accessed only by its <getInstance> method.");
			
			_maxConcurrentConnections = 6;
			_maxConcurrentQueues = 3;
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public static function getInstance(): LoadingManagementContext
		{
			return _instance;
		}

		/**
		 * description
		 * 
		 * @param factory
		 */
		/*public function setAssetLoaderFactory(factory:AbstractAssetLoaderFactory): void
		{
			
		}*/

		/**
		 * description
		 * 
		 * @param value
		 */
		public function setMaxConcurrentConnections(value:int): void
		{
			if (value < 1) throw new ArgumentError("Argument <value> must be greater than zero.");
			_maxConcurrentConnections = value;
		}

		/**
		 * description
		 * 
		 * @param value
		 */
		public function setMaxConcurrentQueues(value:int): void
		{
			if (value < 1) throw new ArgumentError("Argument <value> must be greater than zero.");
			_maxConcurrentQueues = value;
		}

		/**
		 * description
		 * 
		 * @param factory
		 */
		/*public function setRequestLoaderFactory(factory:AbstractRequestLoaderFactory): void
		{
			
		}*/

	}

}