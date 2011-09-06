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
	import org.as3collections.IIterator;
	import org.as3collections.IQueue;
	import org.vostokframework.loadingmanagement.domain.ILoaderState;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.ILoader;

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
		override public function getNext(state:ILoaderState, queue:IQueue, loadingLoaders:ICollection):ILoader
		{
			if (queue.isEmpty()) return null;
			
			var nextLoader:ILoader = queue.peek();
			var nextLoaderPriority:LoadPriority = LoadPriority.getByOrdinal(nextLoader.priority);
			
			if (nextLoaderPriority.equals(LoadPriority.HIGHEST))
			{
				stopAnyNotHighest(state, loadingLoaders);
				return super.getNext(state, queue, loadingLoaders);
			}
			
			if (nextLoaderPriority.equals(LoadPriority.LOWEST))
			{
				if (isOnlyLowestLoading(loadingLoaders)) return super.getNext(state, queue, loadingLoaders);
				return null; 
			}
			
			//nextLoaderPriority is not LoadPriority.HIGHEST nor LoadPriority.LOWEST
			//if it contains any HIGHEST it's denied
			//otherwise all LOWEST loaders are stopped and
			//the permission is delegated to super.getNext()
			if (containsSomeHighest(loadingLoaders)) return null;
			
			stopAnyLowest(state, loadingLoaders); 
			
			return super.getNext(state, queue, loadingLoaders);
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
		
		private function stopAnyNotHighest(state:ILoaderState, loadingLoaders:ICollection):void
		{
			if (loadingLoaders.isEmpty()) return;
			
			var it:IIterator = loadingLoaders.iterator();
			var loader:ILoader;
			var loaderPriority:LoadPriority;
			
			while (it.hasNext())
			{
				loader = it.next();
				loaderPriority = LoadPriority.getByOrdinal(loader.priority);
				
				if (!loaderPriority.equals(LoadPriority.HIGHEST))
				{
					state.stopChild(loader.identification);
					it.remove();
				}
			}
		}
		
		private function stopAnyLowest(state:ILoaderState, loadingLoaders:ICollection):void
		{
			if (loadingLoaders.isEmpty()) return;
			
			var it:IIterator = loadingLoaders.iterator();
			var loader:ILoader;
			var loaderPriority:LoadPriority;
			
			while (it.hasNext())
			{
				loader = it.next();
				loaderPriority = LoadPriority.getByOrdinal(loader.priority);
				
				if (loaderPriority.equals(LoadPriority.LOWEST))
				{
					state.stopChild(loader.identification);
					it.remove();
				}
			}
		}
		
	}

}