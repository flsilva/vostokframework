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
package org.vostokframework.loadingmanagement.domain.loaders.states
{
	import org.vostokframework.loadingmanagement.domain.ILoaderStateTransition;
	import org.as3collections.IList;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.ILoaderState;
	import org.vostokframework.loadingmanagement.domain.ILoader;
	import org.vostokframework.loadingmanagement.domain.policies.ILoadingPolicy;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StoppedQueueLoader extends QueueLoaderState
	{
		
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function StoppedQueueLoader(loader:ILoaderStateTransition, loadingStatus:QueueLoadingStatus, policy:ILoadingPolicy)
		{
			super(loadingStatus, policy);
			setLoader(loader);
		}
		
		override public function addLoader(loader:ILoader): void
		{
			addLoaderBehavior(loader);
		}
		
		override public function addLoaders(loaders:IList): void
		{
			addLoadersBehavior(loaders);
		}
		
		override public function cancel():void
		{
			cancelBehavior();
		}
		
		override public function cancelLoader(identification:VostokIdentification): void
		{
			cancelLoaderBehavior(identification);
		}
		
		override public function containsLoader(identification:VostokIdentification): Boolean
		{
			return containsLoaderBehavior(identification);
		}
		
		override public function equals(other:*):Boolean
		{
			if (this == other) return true;
			return other is StoppedQueueLoader;
		}
		
		override public function getLoader(identification:VostokIdentification): ILoader
		{
			return getLoaderBehavior(identification);
		}
		
		override public function getLoaderState(identification:VostokIdentification): ILoaderState
		{
			return getLoaderStateBehavior(identification);
		}
		
		override public function getParent(identification:VostokIdentification): ILoader
		{
			return getParentBehavior(identification);
		}
		
		override public function load():void
		{
			loadBehavior();
		}
		
		override public function removeLoader(identification:VostokIdentification): void
		{
			removeLoaderBehavior(identification);
		}
		
		override public function resumeLoader(identification:VostokIdentification): void
		{
			resumeLoaderBehavior(identification);
		}
		
		override public function stop():void
		{
			//do nothing
		}
		
		override public function stopLoader(identification:VostokIdentification): void
		{
			//do nothing
		}
		
	}

}