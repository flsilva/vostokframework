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
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.domain.loading.GlobalLoadingSettings;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.LoaderRepository;
	import org.vostokframework.domain.loading.states.queueloader.QueueLoadingStatus;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AbstractLoadingPolicy implements ILoadingPolicy
	{
		private var _loaderRepository:LoaderRepository;
		private var _globalLoadingSettings:GlobalLoadingSettings;
		
		private function get activeGlobalConnections():int { return _loaderRepository.openedConnections; }
		
		/**
		 * Constructor, creates a new AssetRepositoryError instance.
		 * 
		 * @param message 	A string associated with the error object.
		 */
		public function AbstractLoadingPolicy(loaderRepository:LoaderRepository, globalLoadingSettings:GlobalLoadingSettings)
		{
			if (ReflectionUtil.classPathEquals(this, AbstractLoadingPolicy))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be directly instantiated.");
			if (!loaderRepository) throw new ArgumentError("Argument <loaderRepository> must not be null.");
			
			_globalLoadingSettings = globalLoadingSettings;
			_loaderRepository = loaderRepository;
		}
		
		public function process(loadingStatus:QueueLoadingStatus, localMaxConnections:int):void
		{
			stopExceedingConnections(loadingStatus, localMaxConnections);
			
			var loader:ILoader;
			
			while (hasNextLoader(loadingStatus, localMaxConnections))
			{
				loader = loadingStatus.queuedLoaders.poll();
				
				loadingStatus.loadingLoaders.add(loader);
				loader.load();
			}
		}
		
		protected function isNextLoaderEligible(loadingLoaders:QueueLoadingStatus):Boolean
		{
			throw new UnsupportedOperationError("Method must be overriden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		private function hasAvailableConnection(localMaxConnections:int, activeLocalConnections:int):Boolean
		{
			if (activeLocalConnections < 0) throw new ArgumentError("Argument <activeLocalConnections> must not be a negative integer. Received: <" + activeLocalConnections + ">");
			return activeLocalConnections < localMaxConnections && activeGlobalConnections < _globalLoadingSettings.maxConcurrentConnections;
		}
		
		private function hasNextLoader(loadingStatus:QueueLoadingStatus, localMaxConnections:int):Boolean
		{
			if (loadingStatus.queuedLoaders.isEmpty()) return false;
			
			if (!isNextLoaderEligible(loadingStatus)) return false;
			
			var localActiveConnections:int = loadingStatus.loadingLoaders.size();
			if (!hasAvailableConnection(localMaxConnections, localActiveConnections)) return false;
			
			return true;
		}
		
		private function stopExceedingConnections(loadingStatus:QueueLoadingStatus, localMaxConnections:int):void
		{
			var activeLocalConnections:int = loadingStatus.loadingLoaders.size();
			var loader:ILoader;
			
			while (activeLocalConnections > 0 && (activeLocalConnections > localMaxConnections || activeGlobalConnections > _globalLoadingSettings.maxConcurrentConnections))
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