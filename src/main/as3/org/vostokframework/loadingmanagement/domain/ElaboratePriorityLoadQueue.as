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
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicy;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class ElaboratePriorityLoadQueue extends PlainPriorityLoadQueue
	{

		/**
		 * description
		 * 
		 * @param requestLoaders
		 */
		public function ElaboratePriorityLoadQueue(policy:LoadingPolicy)
		{
			super(policy);
		}
		
		override protected function allowGetNext():Boolean
		{
			var nextLoader:RefinedLoader = queuedLoaders.peek();
			var nextLoaderPriority:LoadPriority = LoadPriority.getByOrdinal(nextLoader.priority);
			
			if (nextLoaderPriority.equals(LoadPriority.HIGHEST))
			{
				stopNotHighest();
				return super.allowGetNext();
			}
			
			if (nextLoaderPriority.equals(LoadPriority.LOWEST))
			{
				if (containsOnlyLowest(getLoading())) return super.allowGetNext();
				return false; 
			}
			
			//nextLoaderPriority is not LoadPriority.HIGHEST nor LoadPriority.LOWEST
			//if it contains any HIGHEST it's denied
			//otherwise all LOWEST loaders are stopped and
			//the permission is delegated to super.allowGetNext()
			if (containsHighest(getLoading())) return false;
			
			stopLowest(); 
			
			return super.allowGetNext();
		}
		
		private function containsHighest(loadingLoaders:IList):Boolean
		{
			if (loadingLoaders.isEmpty()) return false;
			
			var it:IIterator = loadingLoaders.iterator();
			var loader:RefinedLoader;
			var loaderPriority:LoadPriority;
			
			while (it.hasNext())
			{
				loader = it.next();
				loaderPriority = LoadPriority.getByOrdinal(loader.priority);
				if (loaderPriority.equals(LoadPriority.HIGHEST)) return true;
			}
			
			return false;
		}
		
		private function containsOnlyLowest(loadingLoaders:IList):Boolean
		{
			if (loadingLoaders.isEmpty()) return true;
			
			var it:IIterator = loadingLoaders.iterator();
			var loader:RefinedLoader;
			var loaderPriority:LoadPriority;
			
			while (it.hasNext())
			{
				loader = it.next();
				loaderPriority = LoadPriority.getByOrdinal(loader.priority);
				if (!loaderPriority.equals(LoadPriority.LOWEST)) return false;
			}
			
			return true;
		}
		
		private function stopNotHighest():void
		{
			var loadings:IList = getLoading();
			if (loadings.isEmpty()) return;
			
			var it:IIterator = loadings.iterator();
			var loader:RefinedLoader;
			var loaderPriority:LoadPriority;
			
			while (it.hasNext())
			{
				loader = it.next();
				loaderPriority = LoadPriority.getByOrdinal(loader.priority);
				if (!loaderPriority.equals(LoadPriority.HIGHEST))
				{
					loader.stop();
					queuedLoaders.add(loader);
				}
			}
		}
		
		private function stopLowest():void
		{
			var loadings:IList = getLoading();
			if (loadings.isEmpty()) return;
			
			var it:IIterator = loadings.iterator();
			var loader:RefinedLoader;
			var loaderPriority:LoadPriority;
			
			while (it.hasNext())
			{
				loader = it.next();
				loaderPriority = LoadPriority.getByOrdinal(loader.priority);
				if (loaderPriority.equals(LoadPriority.LOWEST))
				{
					loader.stop();
					queuedLoaders.add(loader);
				}
			}
		}
		
	}

}