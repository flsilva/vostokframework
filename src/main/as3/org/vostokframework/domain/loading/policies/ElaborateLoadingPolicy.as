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
	import org.as3collections.ICollection;
	import org.as3collections.IIterator;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.LoadPriority;
	import org.vostokframework.domain.loading.LoaderRepository;
	import org.vostokframework.domain.loading.states.queueloader.QueueLoadingStatus;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class ElaborateLoadingPolicy extends LoadingPolicy
	{
		
		/**
		 * Constructor, creates a new AssetRepositoryError instance.
		 * 
		 * @param message 	A string associated with the error object.
		 */
		public function ElaborateLoadingPolicy(loaderRepository:LoaderRepository)
		{
			super(loaderRepository);
		}
		
		//override public function getNext(algorithm:LoadingAlgorithm, queue:IQueue, loadingLoaders:ICollection):ILoader
		//override public function getNext(state:ILoaderState, queue:IQueue, loadingLoaders:ICollection):ILoader
		//override public function getNext(state:ILoaderState, loadingStatus:QueueLoadingStatus):ILoader
		override public function process(loadingStatus:QueueLoadingStatus, localMaxConnections:int):void
		{
			//if (loadingStatus.queuedLoaders.isEmpty()) return null;
			if (loadingStatus.queuedLoaders.isEmpty()) return;
			
			var nextLoader:ILoader = loadingStatus.queuedLoaders.peek();
			var nextLoaderPriority:LoadPriority = LoadPriority.getByOrdinal(nextLoader.priority);
			
			if (nextLoaderPriority.equals(LoadPriority.HIGHEST))
			{
				//stopAnyNotHighest(state, loadingStatus);
				//return super.getNext(state, loadingStatus);
				
				stopAnyNotHighest(loadingStatus);
				super.process(loadingStatus, localMaxConnections);
				return;
			}
			
			if (nextLoaderPriority.equals(LoadPriority.LOWEST))
			{
				//if (isOnlyLowestLoading(loadingStatus.loadingLoaders)) return super.getNext(state, loadingStatus);
				//return null;
				
				if (isOnlyLowestLoading(loadingStatus.loadingLoaders)) super.process(loadingStatus, localMaxConnections);
				return; 
			}
			
			//nextLoaderPriority is not LoadPriority.HIGHEST nor LoadPriority.LOWEST
			//if it contains any HIGHEST it's denied
			//otherwise all LOWEST loaders are stopped and
			//the permission is delegated to super.getNext()
			//if (containsSomeHighest(loadingStatus.loadingLoaders)) return null;
			if (containsSomeHighest(loadingStatus.loadingLoaders)) return;
			
			//stopAnyLowest(state, loadingStatus); 
			stopAnyLowest(loadingStatus);
			
			//return super.getNext(state, loadingStatus);
			super.process(loadingStatus, localMaxConnections);
		}
		
		private function containsSomeHighest(loadingLoaders:ICollection):Boolean
		{
			if (loadingLoaders.isEmpty()) return false;
			
			var it:IIterator = loadingLoaders.iterator();
			var loader:ILoader;
			var loaderPriority:LoadPriority;
			
			while (it.hasNext())
			{
				loader = it.next();
				loaderPriority = LoadPriority.getByOrdinal(loader.priority);
				if (loaderPriority.equals(LoadPriority.HIGHEST)) return true;
			}
			
			return false;
		}
		
		private function isOnlyLowestLoading(loadingLoaders:ICollection):Boolean
		{
			if (loadingLoaders.isEmpty()) return true;
			
			var it:IIterator = loadingLoaders.iterator();
			var loader:ILoader;
			var loaderPriority:LoadPriority;
			
			while (it.hasNext())
			{
				loader = it.next();
				loaderPriority = LoadPriority.getByOrdinal(loader.priority);
				if (!loaderPriority.equals(LoadPriority.LOWEST)) return false;
			}
			
			return true;
		}
		
		private function stopAnyNotHighest(loadingStatus:QueueLoadingStatus):void
		{
			if (loadingStatus.loadingLoaders.isEmpty()) return;
			
			var it:IIterator = loadingStatus.loadingLoaders.iterator();
			var loader:ILoader;
			var loaderPriority:LoadPriority;
			
			while (it.hasNext())
			{
				loader = it.next();
				loaderPriority = LoadPriority.getByOrdinal(loader.priority);
				
				if (!loaderPriority.equals(LoadPriority.HIGHEST))
				{
					//state.stopChild(loader.identification);
					
					loadingStatus.queuedLoaders.add(loader);
					it.remove();
					
					loader.stop();
				}
			}
		}
		
		private function stopAnyLowest(loadingStatus:QueueLoadingStatus):void
		{
			if (loadingStatus.loadingLoaders.isEmpty()) return;
			
			var it:IIterator = loadingStatus.loadingLoaders.iterator();
			var loader:ILoader;
			var loaderPriority:LoadPriority;
			
			while (it.hasNext())
			{
				loader = it.next();
				loaderPriority = LoadPriority.getByOrdinal(loader.priority);
				
				if (loaderPriority.equals(LoadPriority.LOWEST))
				{
					//state.stopChild(loader.identification);
					
					loadingStatus.queuedLoaders.add(loader);
					it.remove();
					
					loader.stop();
				}
			}
		}
		
	}

}