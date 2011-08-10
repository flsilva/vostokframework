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

package org.vostokframework.loadingmanagement.domain.policies
{
	import org.as3collections.ICollection;
	import org.as3collections.IQueue;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.LoadingAlgorithm;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingPolicy implements ILoadingPolicy
	{
		private var _loaderRepository:LoaderRepository;
		private var _globalMaxConnections:int;
		private var _localMaxConnections:int;
		
		private function get totalGlobalConnections():int { return _loaderRepository.openedConnections; }
		
		public function get globalMaxConnections():int { return _globalMaxConnections; }
		public function set globalMaxConnections(value:int):void
		{
			if (value < 1) throw new ArgumentError("The value must be greater than zero. Received: <" + value + ">");
			_globalMaxConnections = value;
		}
		
		public function get localMaxConnections():int { return _localMaxConnections; }
		public function set localMaxConnections(value:int):void
		{
			if (value < 1) throw new ArgumentError("The value must be greater than zero. Received: <" + value + ">");
			_localMaxConnections = value;
		}
		
		/**
		 * Constructor, creates a new AssetRepositoryError instance.
		 * 
		 * @param message 	A string associated with the error object.
		 */
		public function LoadingPolicy(loaderRepository:LoaderRepository)
		{
			if (!loaderRepository) throw new ArgumentError("Argument <loaderRepository> must not be null.");
			
			_loaderRepository = loaderRepository;
		}
		
		public function getNext(algorithm:LoadingAlgorithm, queue:IQueue, loadingLoaders:ICollection):VostokLoader
		{
			//if (hasAvailableConnection(algorithm.openedConnections)) return queue.poll();
			if (hasAvailableConnection(loadingLoaders.size())) return queue.poll();
			//TODO:pensar sobre usar loadingLoaders.size(). porem precisaria implementar remoção dos loaders da lista no ElaborateLoadingPolicy.as qnd chamar stop()
			return null;
		}
		
		private function hasAvailableConnection(activeLocalConnections:int):Boolean
		{
			if (activeLocalConnections < 0) throw new ArgumentError("Argument <activeLocalConnections> must not be a negative integer. Received: <" + activeLocalConnections + ">");
			return activeLocalConnections < _localMaxConnections && totalGlobalConnections < _globalMaxConnections;
		}

	}

}