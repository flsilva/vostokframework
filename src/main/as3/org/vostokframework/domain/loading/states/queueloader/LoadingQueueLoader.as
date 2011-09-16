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
package org.vostokframework.domain.loading.states.queueloader
{
	import org.as3collections.IIterator;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.ILoaderStateTransition;
	import org.vostokframework.domain.loading.events.LoaderErrorEvent;
	import org.vostokframework.domain.loading.events.LoaderEvent;
	import org.vostokframework.domain.loading.policies.ILoadingPolicy;

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
		
		override public function get isLoading():Boolean { return true; }
		
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
		//also explain that this objeto starts its logic as soon as it is instanciated
		//therefore if its instantiated with an empty queue of loaders
		//it will dispatches LoaderEvent.COMPLETE
		//and make state transition to CompleteQueueLoader
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function LoadingQueueLoader(loader:ILoaderStateTransition, loadingStatus:QueueLoadingStatus, policy:ILoadingPolicy, maxConcurrentConnections:int)
		{
			super(loadingStatus, policy, maxConcurrentConnections);
			
			if (loadingStatus.queuedLoaders.isEmpty())
			{
				var errorMessage:String = "Argument <loadingStatus> must not have an empty queue (loadingStatus.queuedLoaders).";
				errorMessage += " Queue must have at least one element.";
				
				throw new ArgumentError(errorMessage);
			}
			
			setLoader(loader);
			addChildrenListeners();
			loadNextLoader();
		}
		
		override public function load():void
		{
			//do nothing
		}
		
		override public function stop():void
		{
			super.stop();
			_openEventDispatched = false;
		}
		
		/**
		 * @private
		 */
		override protected function doDispose():void
		{
			removeChildrenListeners();
		}
		
		/**
		 * @private
		 */
		override protected function childAdded(child:ILoader): void
		{
			addChildListeners(child);
			loadNextLoader();
		}
		
		/**
		 * @private
		 */
		override protected function childRemoved(child:ILoader): void
		{
			removeChildListeners(child);
			loadNextLoader();
		}
		
		/**
		 * @private
		 */
		override protected function childResumed(child:ILoader): void
		{
			child = null;//just to avoid compiler warnings
			loadNextLoader();
		}
		
		/**
		 * @private
		 */
		override protected function childStopped(child:ILoader): void
		{
			child = null;//just to avoid compiler warnings
			loadNextLoader();
		}
		
		/**
		 * @private
		 */
		override protected function maxConcurrentConnectionsChanged(): void
		{
			loadNextLoader();
		}
		
		/**
		 * @private
		 */
		override protected function priorityChildChanged(child:ILoader): void
		{
			child = null;//just to avoid compiler warnings
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
			child.addEventListener(LoaderEvent.OPEN, childOpenHandler, false, 0, true);
		}
		
		/**
		 * @private
		 */
		private function isLoadingComplete():Boolean
		{
			validateDisposal();
			
			return loadingStatus.loadingLoaders.isEmpty() &&
				loadingStatus.queuedLoaders.isEmpty() &&
				loadingStatus.stoppedLoaders.isEmpty();
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
			
			//var loader:ILoader = policy.getNext(this, loadingStatus.queuedLoaders, loadingStatus.loadingLoaders);
			/*
			var loader:ILoader = policy.getNext(this, loadingStatus);
			if (loader)
			{
				loader.load();
				//loadingStatus.loadingLoaders.add(loader);
			}
			*/
			
			policy.process(loadingStatus, maxConcurrentConnections);
			
			/*
			var loader:ILoader;
			var firstTime:Boolean = true;
			
			while (loader || firstTime)
			{
				firstTime = false;
				
				loader = policy.getNext(this, loadingStatus.queuedLoaders, loadingStatus.loadingLoaders);
				if (loader)
				{
					loader.load();
					loadingStatus.loadingLoaders.add(loader);
				}
			}
			*/
		}
		
		/**
		 * @private
		 */
		private function loadingComplete(): void
		{
			removeChildrenListeners();
			//TODO:pensar se vai disparar FAILED se todos os loaders falharem
			loader.setState(new CompleteQueueLoader(loader, loadingStatus, policy, maxConcurrentConnections));
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
			child.removeEventListener(LoaderEvent.OPEN, childOpenHandler, false);
		}
		
		////////////////////////////////////////////////////////////////////////
		//////////////////////////// CHILD LISTENERS ///////////////////////////
		////////////////////////////////////////////////////////////////////////
		
		private function childCompleteHandler(event:LoaderEvent):void
		{
			loadingStatus.completeLoaders.add(event.target);
			loadingStatus.loadingLoaders.remove(event.target);
			
			loadNextLoader();
		}
		
		private function childConnectingHandler(event:LoaderEvent):void
		{
			//loadingStatus.loadingLoaders.add(event.target);
			
			//loadNextLoader();
		}
		
		private function childFailedHandler(event:LoaderErrorEvent):void
		{
			loadingStatus.failedLoaders.add(event.target);
			loadingStatus.loadingLoaders.remove(event.target);
			
			loadNextLoader();
		}
		
		private function childOpenHandler(event:LoaderEvent):void
		{
			validateDisposal();
			
			if (!_openEventDispatched) loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN, null, event.latency));
			_openEventDispatched = true;
		}
	}

}