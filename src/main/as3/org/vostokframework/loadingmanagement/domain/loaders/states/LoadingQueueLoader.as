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
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.ILoaderState;
	import org.vostokframework.loadingmanagement.domain.ILoader;
	import org.vostokframework.loadingmanagement.domain.events.LoaderErrorEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.policies.ILoadingPolicy;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingQueueLoader extends QueueLoaderState
	{
		
		/**
		 * @private
		 */
		private var _openEventDispatched:Boolean;
		
		override public function get openedConnections():int
		{
			validateDisposal();
			
			var it:IIterator = loadingStatus.allLoaders.iterator();
			var child:ILoader;
			var sum:int;
			
			while (it.hasNext())
			{
				child = it.next();
				sum += child.openedConnections;
			}
			
			return sum;
		}
		//TODO:note: explain that this Composite implementation
		//does not have the Failed state
		//if all loader fail it will become Complete
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function LoadingQueueLoader(loader:ILoaderStateTransition, loadingStatus:QueueLoadingStatus, policy:ILoadingPolicy)
		{
			super(loadingStatus, policy);
			
			setLoader(loader);
			addChildrenListeners();
			loadNextLoader();
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
			return other is LoadingQueueLoader;
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
			//do nothing
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
			stopBehavior();
			_openEventDispatched = false;
		}
		
		override public function stopLoader(identification:VostokIdentification): void
		{
			stopLoaderBehavior(identification);
		}
		
		/**
		 * @private
		 */
		override protected function doDispose():void
		{
			removeChildrenListeners();
			super.doDispose();
		}
		
		/**
		 * @private
		 */
		override protected function loaderAdded(loader:ILoader): void
		{
			addChildListeners(loader);
		}
		
		/**
		 * @private
		 */
		override protected function loaderRemoved(loader:ILoader): void
		{
			removeChildListeners(loader);
			loadNextLoader();
		}
		
		/**
		 * @private
		 */
		override protected function loaderResumed(loader:ILoader): void
		{
			loader = null;//just to avoid FDT warnings
			loadNextLoader();
		}
		
		/**
		 * @private
		 */
		override protected function loaderStopped(loader:ILoader): void
		{
			loader = null;//just to avoid FDT warnings
			loadNextLoader();
		}
		
		/**
		 * @private
		 */
		private function addChildrenListeners():void
		{
			if (loadingStatus.allLoaders.isEmpty()) return;
			
			var it:IIterator = loadingStatus.allLoaders.iterator();
			var child:ILoader;
			
			while (it.hasNext())
			{
				child = it.next();
				addChildListeners(child);
			}
		}
		
		private function addChildListeners(child:ILoader):void
		{
			validateDisposal();
			
			child.addEventListener(LoaderEvent.COMPLETE, childCompleteHandler, false, 0, true);
			child.addEventListener(LoaderEvent.CONNECTING, childConnectingHandler, false, 0, true);
			child.addEventListener(LoaderErrorEvent.FAILED, childFailedHandler, false, 0, true);
			child.addEventListener(LoaderEvent.OPEN, childOpenedHandler, false, 0, true);
		}
		
		/**
		 * @private
		 */
		private function isLoadingComplete():Boolean
		{
			validateDisposal();
			
			return loadingStatus.queuedLoaders.isEmpty() &&
				loadingStatus.stoppedLoaders.isEmpty() &&
				loadingStatus.loadingLoaders.size() == 0;
			
			/*
			return _queuedLoaders.isEmpty() &&
				_stoppedLoaders.isEmpty() &&
				getLoadingLoaders().size() == 0;
			*/
			/*
			return !_allLoaders.isEmpty() &&
				_queuedLoaders.isEmpty() &&
				_stoppedLoaders.isEmpty() &&
				getLoadingLoaders().size() == 0;
			*/
		}
		
		/**
		 * @private
		 */
		private function loadNextLoader(): void
		{
			validateDisposal();
			
			if (isLoadingComplete())
			{
				loadingComplete();
				return;
			}
			
			if (loadingStatus.queuedLoaders.isEmpty()) return;
			
			var loader:ILoader = policy.getNext(this, loadingStatus.queuedLoaders, loadingStatus.loadingLoaders);
			if (loader) loader.load();
		}
		
		/**
		 * @private
		 */
		private function loadingComplete(): void
		{
			removeChildrenListeners();
			//TODO:pensar se vai disparar FAILED se todos os loaders falharem
			loader.setState(new CompleteQueueLoader(loader, loadingStatus, policy));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE));
			dispose();
		}
		
		private function removeChildrenListeners():void
		{
			validateDisposal();
			
			var it:IIterator = loadingStatus.allLoaders.iterator();
			var child:ILoader;
			
			while (it.hasNext())
			{
				child = it.next();
				removeChildListeners(child);
			}
		}
		
		private function removeChildListeners(child:ILoader):void
		{
			validateDisposal();
			
			child.removeEventListener(LoaderEvent.COMPLETE, childCompleteHandler, false);
			child.removeEventListener(LoaderEvent.CONNECTING, childConnectingHandler, false);
			child.removeEventListener(LoaderErrorEvent.FAILED, childFailedHandler, false);
			child.removeEventListener(LoaderEvent.OPEN, childOpenedHandler, false);
		}
		
		////////////////////////////////////////////////////////////////////////
		//////////////////////////// CHILD LISTENERS ///////////////////////////
		////////////////////////////////////////////////////////////////////////
		
		private function childCompleteHandler(event:LoaderEvent):void
		{
			loadNextLoader();
		}
		
		private function childConnectingHandler(event:LoaderEvent):void
		{
			loadNextLoader();
		}
		
		private function childFailedHandler(event:LoaderErrorEvent):void
		{
			loadNextLoader();
		}
		
		private function childOpenedHandler(event:LoaderEvent):void
		{
			validateDisposal();
			
			if (!_openEventDispatched) loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN, null, event.latency));
			_openEventDispatched = true;
		}
	}

}