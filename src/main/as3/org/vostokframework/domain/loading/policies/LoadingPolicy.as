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

package org.vostokframework.domain.loading.policies
{
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.LoaderRepository;
	import org.vostokframework.domain.loading.states.queueloader.QueueLoadingStatus;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingPolicy implements ILoadingPolicy
	{
		private var _loaderRepository:LoaderRepository;
		private var _globalMaxConnections:int;
		
		private function get activeGlobalConnections():int { return _loaderRepository.openedConnections; }
		
		public function get globalMaxConnections():int { return _globalMaxConnections; }
		public function set globalMaxConnections(value:int):void
		{
			if (value < 1) throw new ArgumentError("The value must be greater than zero. Received: <" + value + ">");
			_globalMaxConnections = value;
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
		
		public function process(loadingStatus:QueueLoadingStatus, localMaxConnections:int):void
		{
			//if (hasAvailableConnection(loadingStatus.loadingLoaders.size())) return loadingStatus.queuedLoaders.poll();
			
			stopExceedingConnections(loadingStatus, localMaxConnections);
			
			var loader:ILoader;
			
			while (hasAvailableConnection(localMaxConnections, loadingStatus.loadingLoaders.size()) && !loadingStatus.queuedLoaders.isEmpty())
			{
				loader = loadingStatus.queuedLoaders.poll();
				
				loadingStatus.loadingLoaders.add(loader);
				loader.load();
			}
			
			/*
			if (hasAvailableConnection(localMaxConnections, loadingStatus.loadingLoaders.size()))
			{
				var loader:ILoader = loadingStatus.queuedLoaders.poll();
				loader.load();
			}
			*/
			//return null;
		}
		
		private function hasAvailableConnection(localMaxConnections:int, activeLocalConnections:int):Boolean
		{
			if (activeLocalConnections < 0) throw new ArgumentError("Argument <activeLocalConnections> must not be a negative integer. Received: <" + activeLocalConnections + ">");
			return activeLocalConnections < localMaxConnections && activeGlobalConnections < _globalMaxConnections;
		}
		
		private function stopExceedingConnections(loadingStatus:QueueLoadingStatus, localMaxConnections:int):void
		{
			var activeLocalConnections:int = loadingStatus.loadingLoaders.size();
			var loader:ILoader;
			
			while (activeLocalConnections > 0 && (activeLocalConnections > localMaxConnections || activeGlobalConnections > _globalMaxConnections))
			{
				//stop LAST loading ILoader object
				loader = loadingStatus.loadingLoaders.removeAt(activeLocalConnections - 1);
				loadingStatus.queuedLoaders.add(loader);
				loader.stop();
				
				activeLocalConnections = loadingStatus.loadingLoaders.size();
			}
		}

	}

}