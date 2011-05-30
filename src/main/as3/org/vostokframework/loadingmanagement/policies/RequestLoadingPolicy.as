/*
 * Licensed under the MIT License
 * 
 * Copyright 2010 (c) Flávio Silva, http://flsilva.com
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

package org.vostokframework.loadingmanagement.policies
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.vostokframework.loadingmanagement.LoadingRequestPriority;
	import org.vostokframework.loadingmanagement.RequestLoader;
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoaderRepository;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class RequestLoadingPolicy
	{
		private var _assetLoaderRepository:AssetLoaderRepository;
		private var _globalMaxConnections:int;
		private var _localMaxConnections:int;
		//TODO:create tests
		private function get totalGlobalConnections():int
		{
			var list:IList = _assetLoaderRepository.findAllLoading();
			if (!list) return 0;
			return list.size();
		}
		
		/**
		 * Constructor, creates a new AssetRepositoryError instance.
		 * 
		 * @param message 	A string associated with the error object.
		 */
		public function RequestLoadingPolicy(localMaxConnections:int, globalMaxConnections:int, assetLoaderRepository:AssetLoaderRepository)
		{
			if (localMaxConnections < 1) throw new ArgumentError("Argument <localMaxConnections> must be greater than zero. Received: <" + localMaxConnections + ">");
			if (globalMaxConnections < 1) throw new ArgumentError("Argument <globalMaxConnections> must be greater than zero. Received: <" + globalMaxConnections + ">");
			if (!assetLoaderRepository) throw new ArgumentError("Argument <assetLoaderRepository> must not be null.");
			
			_localMaxConnections = localMaxConnections;
			_globalMaxConnections = globalMaxConnections;
			_assetLoaderRepository = assetLoaderRepository;
		}
		
		public function allow(localActiveConnections:int, activeLoadings:IList, allowLoader:RequestLoader):Boolean
		{
			if (localActiveConnections < 0) throw new ArgumentError("Argument <localActiveConnections> must be a positive integer. Received: <" + localActiveConnections + ">");
			if (!activeLoadings) throw new ArgumentError("Argument <activeLoadings> must not be null.");
			if (!allowLoader) throw new ArgumentError("Argument <allowLoader> must not be null.");
			
			if (LoadingRequestPriority.getByOrdinal(allowLoader.priority).equals(LoadingRequestPriority.LOWEST) &&
				!containsOnlyLowest(activeLoadings)) return false;
			
			return localActiveConnections < _localMaxConnections && totalGlobalConnections < _globalMaxConnections;
		}
		
		private function containsOnlyLowest(activeLoadings:IList):Boolean
		{
			if (activeLoadings.isEmpty()) return true;
			
			var it:IIterator = activeLoadings.iterator();
			var loader:RequestLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				if (!LoadingRequestPriority.getByOrdinal(loader.priority).equals(LoadingRequestPriority.LOWEST)) return false;
			}
			
			return true;
		}

	}

}