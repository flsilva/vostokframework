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

package org.vostokframework.domain.loading.states.queueloader.policies
{
	import org.as3collections.ICollection;
	import org.as3collections.IIterator;
	import org.vostokframework.domain.loading.GlobalLoadingSettings;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.LoadPriority;
	import org.vostokframework.domain.loading.LoaderRepository;
	import org.vostokframework.domain.loading.states.queueloader.QueueLoadingStatus;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class SpecialHighestLowestQueueLoadingPolicy extends AbstractQueueLoadingPolicy
	{
		
		/**
		 * Constructor, creates a new AssetRepositoryError instance.
		 * 
		 * @param message 	A string associated with the error object.
		 */
		public function SpecialHighestLowestQueueLoadingPolicy(loaderRepository:LoaderRepository, globalLoadingSettings:GlobalLoadingSettings)
		{
			super(loaderRepository, globalLoadingSettings);
		}
		
		override protected function isNextLoaderEligible(loadingStatus:QueueLoadingStatus):Boolean
		{
			var nextLoader:ILoader = loadingStatus.queuedLoaders.peek();
			var priorityNextLoader:LoadPriority = LoadPriority.getByOrdinal(nextLoader.priority);
			
			if (priorityNextLoader.equals(LoadPriority.HIGHEST))
			{
				stopAnyNotHighest(loadingStatus);
				return true;
			}
			
			if (priorityNextLoader.equals(LoadPriority.LOWEST))
			{
				if (containsOnlyLowest(loadingStatus.loadingLoaders)) return true;
				return false;
			}
			
			//priorityNextLoader is not LoadPriority.HIGHEST nor LoadPriority.LOWEST
			//if it contains any HIGHEST loader loading, permission is denied
			if (containsSomeHighest(loadingStatus.loadingLoaders)) return false;
			
			//otherwise all LOWEST loading loaders are stopped
			//and permission is accepted
			stopAnyLowest(loadingStatus);
			return true;
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
		
		private function containsOnlyLowest(loadingLoaders:ICollection):Boolean
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
					loadingStatus.queuedLoaders.add(loader);
					it.remove();
					
					loader.stop();
				}
			}
		}
		
	}

}