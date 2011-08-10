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
package org.vostokframework.loadingmanagement.domain.loaders
{
	import org.as3collections.ICollection;
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.IMap;
	import org.as3collections.IQueue;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.UniqueList;
	import org.as3collections.maps.HashMap;
	import org.as3collections.maps.TypedMap;
	import org.as3collections.queues.IndexablePriorityQueue;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.LoaderState;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError;
	import org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoadingAlgorithmEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderConnecting;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderLoading;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderStopped;
	import org.vostokframework.loadingmanagement.domain.policies.ILoadingPolicy;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class QueueLoadingAlgorithm extends LoadingAlgorithm
	{
		/**
		 * @private
 		 */
		private var _allLoaders:IMap;
		private var _index:int;
		//private var _isLoading:Boolean;
		private var _openEventDispatched:Boolean;
		private var _policy:ILoadingPolicy;
		private var _queuedLoaders:IQueue;
		private var _stoppedLoaders:IList;
		
		override public function get openedConnections():int
		{
			validateDisposal();
			
			var it:IIterator = _allLoaders.iterator();
			var loader:VostokLoader;
			var sum:int;
			
			while (it.hasNext())
			{
				loader = it.next();
				sum += loader.openedConnections;
			}
			
			return sum;
		}
		
		/**
		 * description
		 */
		public function QueueLoadingAlgorithm(policy:ILoadingPolicy, queue:IQueue = null)
		{
			if (!policy) throw new ArgumentError("Argument <policy> must not be null.");
			
			_policy = policy;
			
			_queuedLoaders = new IndexablePriorityQueue();
			
			// IMap<String, VostokLoader>
			// VostokIdentification().toString() used for performance optimization
			_allLoaders = new TypedMap(new HashMap(), String, VostokLoader);
			_stoppedLoaders = new UniqueList(new ArrayList());
			
			if (queue && !queue.isEmpty()) addLoaders(queue);
		}
		
		override public function addLoader(loader:VostokLoader): void
		{
			validateDisposal();
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			
			if (containsLoader(loader.identification))
			{
				var errorMessage:String = "There is already a VostokLoader object stored with identification:\n";
				errorMessage += "<" + loader.identification + ">";
				
				throw new DuplicateLoaderError(loader.identification, errorMessage);
			}
			//if (_allLoaders.containsKey(loader.id)) throw new DuplicateLoaderError(loader.id, "There is already an VostokLoader object stored with id:\n<" + loader.id + ">");
			
			loader.index = _index++;
			
			// VostokIdentification().toString() used for performance optimization
			_allLoaders.put(loader.identification.toString(), loader);
			_queuedLoaders.add(loader);
			addLoaderListeners(loader);
			
			loadNext();
		}
		
		override public function addLoaders(loaders:ICollection): void
		{
			validateDisposal();
			if (!loaders || loaders.isEmpty()) throw new ArgumentError("Argument <loaders> must not be null nor empty.");
			
			var it:IIterator = loaders.iterator();
			var loader:VostokLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				addLoader(loader);
			}
		}
		
		/**
		 * description
		 */
		override protected function doCancel(): void
		{
			validateDisposal();
			
			//_isLoading = false;
			
			var it:IIterator = _allLoaders.iterator();
			var loader:VostokLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				loader.cancel();
				
				_queuedLoaders.remove(loader);
				_stoppedLoaders.remove(loader);
			}
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		override public function cancelLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			/*
			var loader:VostokLoader = _allLoaders.getValue(loaderId);
			if (!loader)
			{
				var message:String = "There is no VostokLoader object stored with id:\n";
				message += "<" + loaderId + ">";
				throw new LoaderNotFoundError(loaderId, message);
			}
			
			_queuedLoaders.remove(loader);
			_stoppedLoaders.remove(loader);
			
			loader.cancel();
			loadNext();
			*/
			
			if (_allLoaders.containsKey(identification.toString()))
			{
				var loader:VostokLoader = _allLoaders.getValue(identification.toString());
				
				_queuedLoaders.remove(loader);
				_stoppedLoaders.remove(loader);
				
				loader.cancel();
				loadNext();
			}
			else
			{
				var it:IIterator = _allLoaders.iterator();
				var child:VostokLoader;
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification))
					{
						child.cancelLoader(identification);
						return;
					}
				}
				
				var message:String = "There is no VostokLoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		override public function containsLoader(identification:VostokIdentification): Boolean
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			//return _allLoaders.containsKey(loaderId);
			
			if (_allLoaders.isEmpty()) return false;
			if (_allLoaders.containsKey(identification.toString())) return true;
			
			var it:IIterator = _allLoaders.iterator();
			var child:VostokLoader;
			
			while (it.hasNext())
			{
				child = it.next();
				if (child.containsLoader(identification)) return true;
			}
			
			return false;
		}
		
		override public function getLoader(identification:VostokIdentification): VostokLoader
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			/*
			var loader:VostokLoader = _allLoaders.getValue(loaderId);
			if (!loader)
			{
				var message:String = "There is no VostokLoader object stored with id:\n";
				message += "<" + loaderId + ">";
				throw new LoaderNotFoundError(loaderId, message);
			}
			
			return loader;
			*/
			
			if (_allLoaders.containsKey(identification.toString()))
			{
				return _allLoaders.getValue(identification.toString());
			}
			else
			{
				var it:IIterator = _allLoaders.iterator();
				var child:VostokLoader;
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification)) return child.getLoader(identification);
				}
				
				var message:String = "There is no VostokLoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		override public function getLoaderState(identification:VostokIdentification): LoaderState
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			/*
			var loader:VostokLoader = _allLoaders.getValue(loaderId);
			if (!loader)
			{
				var message:String = "There is no VostokLoader object stored with id:\n";
				message += "<" + loaderId + ">";
				throw new LoaderNotFoundError(loaderId, message);
			}
			
			return loader.state;
			*/
			
			if (_allLoaders.containsKey(identification.toString()))
			{
				var loader:VostokLoader = _allLoaders.getValue(identification.toString());
				return loader.state;
			}
			else
			{
				var it:IIterator = _allLoaders.iterator();
				var child:VostokLoader;
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification)) return child.getLoaderState(identification);
				}
				
				var message:String = "There is no VostokLoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		/**
		 * description
		 * 
		 * @param identification
		 */
		override public function getParent(context:VostokLoader, identification:VostokIdentification): VostokLoader
		{
			validateDisposal();
			
			if (_allLoaders.containsKey(identification.toString()))
			{
				return context;
			}
			else
			{
				var it:IIterator = _allLoaders.iterator();
				var child:VostokLoader;
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification)) return child.getParent(identification);
				}
			}
			
			return null;
		}
		
		/**
		 * description
		 */
		override protected function doLoad(): void
		{
			validateDisposal();
			
			//_isLoading = true;
			
			
			loadNext();
			dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING));
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		override public function removeLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			if (_allLoaders.containsKey(identification.toString()))
			{
				var loader:VostokLoader = _allLoaders.getValue(identification.toString());
				loader.dispose();
				
				if (_queuedLoaders.contains(loader)) _queuedLoaders.remove(loader);
				if (_stoppedLoaders.contains(loader)) _stoppedLoaders.remove(loader);
				
				_allLoaders.remove(identification.toString());
				loadNext();
			}
			else
			{
				var it:IIterator = _allLoaders.iterator();
				var child:VostokLoader;
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification))
					{
						child.removeLoader(identification);
						return;
					}
				}
				
				var message:String = "There is no VostokLoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		override public function resumeLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			/*
			var loader:VostokLoader = _allLoaders.getValue(loaderId);
			if (!loader)
			{
				var message:String = "There is no VostokLoader object stored with id:\n";
				message += "<" + loaderId + ">";
				throw new LoaderNotFoundError(loaderId, message);
			}
			
			if (!_queuedLoaders.contains(loader)) _queuedLoaders.add(loader);
			_stoppedLoaders.remove(loader);
			
			_isLoading = true;//IMPORTANT: if queue is stopped, it will resume its loading
			loadNext();
			*/
			
			if (_allLoaders.containsKey(identification.toString()))
			{
				var loader:VostokLoader = _allLoaders.getValue(identification.toString());
				
				if (!_queuedLoaders.contains(loader)) _queuedLoaders.add(loader);
				_stoppedLoaders.remove(loader);
				
				isLoading = true;//IMPORTANT: if queue is stopped, it will resume its loading
				loadNext();
			}
			else
			{
				var it:IIterator = _allLoaders.iterator();
				var child:VostokLoader;
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification))
					{
						child.resumeLoader(identification);
						return;
					}
				}
				
				var message:String = "There is no VostokLoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		/**
		 * description
		 */
		override protected function doStop():void
		{
			validateDisposal();
			
			//_isLoading = false;
			_openEventDispatched = false;
			
			var it:IIterator = _allLoaders.iterator();
			var loader:VostokLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				loader.stop();
				
				_queuedLoaders.remove(loader);
				if (loader.state.equals(LoaderStopped.INSTANCE)) _stoppedLoaders.add(loader);
			}
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		override public function stopLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			/*
			var loader:VostokLoader = _allLoaders.getValue(loaderId);
			if (!loader)
			{
				var message:String = "There is no VostokLoader object stored with id:\n";
				message += "<" + loaderId + ">";
				throw new LoaderNotFoundError(loaderId, message);
			}
			
			_queuedLoaders.remove(loader);
			if (loader.state.equals(LoaderStopped.INSTANCE)) _stoppedLoaders.add(loader);
			
			loader.stop();
			loadNext();
			*/
			
			if (_allLoaders.containsKey(identification.toString()))
			{
				var loader:VostokLoader = _allLoaders.getValue(identification.toString());
				
				_queuedLoaders.remove(loader);
				//if (loader.state.equals(LoaderStopped.INSTANCE)) _stoppedLoaders.add(loader);
				if (!_stoppedLoaders.contains(loader)) _stoppedLoaders.add(loader);
				
				loader.stop();
				loadNext();
			}
			else
			{
				var it:IIterator = _allLoaders.iterator();
				var child:VostokLoader;
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification))
					{
						child.stopLoader(identification);
						return;
					}
				}
				
				var message:String = "There is no VostokLoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		/**
		 * @private
		 */
		override protected function doDispose():void
		{
			removeLoadersListeners();
			
			_allLoaders.clear();
			_queuedLoaders.clear();
			_stoppedLoaders.clear();
			
			_allLoaders = null;
			_policy = null;
			_queuedLoaders = null;
			_stoppedLoaders = null;
		}
		
		private function loadNext():void
		{
			validateDisposal();
			if (!isLoading) return;
			
			if (isLoadingComplete())
			{
				removeLoadersListeners();
				//TODO:pensar se vai disparar FAILED se todos os loaders falharem
				dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.COMPLETE));
				isLoading = false;
				return;
			}
			
			if (_queuedLoaders.isEmpty()) return;
			
			var loader:VostokLoader = _policy.getNext(this, _queuedLoaders, getLoadingLoaders());
			if (loader) loader.load();
			
			/*
			var loader:VostokLoader;
			var firstTime:Boolean = true;
			
			while (firstTime || loader != null)
			{
				loader = _policy.getNext(this, _queuedLoaders, getLoadingLoaders());
				if (loader) loader.load();
				firstTime = false;
			}*/
		}

		private function addLoaderListeners(loader:VostokLoader):void
		{
			validateDisposal();
			
			loader.addEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false, 0, true);
			loader.addEventListener(LoaderEvent.CONNECTING, loaderConnectingHandler, false, 0, true);
			loader.addEventListener(LoaderEvent.FAILED, loaderFailedHandler, false, 0, true);
			loader.addEventListener(LoaderEvent.OPEN, loaderOpenedHandler, false, 0, true);
		}
		//TODO:pensar em eliminar esse metodo e manter uma lista de loadingLoaders (já tem o listener para o evento LoaderEvent.CONNECTING)
		private function getLoadingLoaders():ICollection
		{
			validateDisposal();
			
			var it:IIterator = _allLoaders.iterator();
			var loader:VostokLoader;
			var loading:ICollection = new ArrayList();
			
			while (it.hasNext())
			{
				loader = it.next();
				
				if (loader.state.equals(LoaderConnecting.INSTANCE) || loader.state.equals(LoaderLoading.INSTANCE))
				{
					loading.add(loader);
				}
			}
			
			return loading;
		}

		private function isLoadingComplete():Boolean
		{
			return !_allLoaders.isEmpty()
				&& _queuedLoaders.isEmpty()
				&& _stoppedLoaders.isEmpty()
				&& getLoadingLoaders().size() == 0;
		}
		
		private function loaderConnectingHandler(event:LoaderEvent):void
		{
			loadNext();
		}
		
		private function loaderCompleteHandler(event:LoaderEvent):void
		{
			loadNext();
		}
		
		private function loaderFailedHandler(event:LoaderEvent):void
		{
			loadNext();
		}
		
		private function loaderOpenedHandler(event:LoaderEvent):void
		{
			validateDisposal();
			
			if (!_openEventDispatched) dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.OPEN, null, event.latency));
			_openEventDispatched = true;
		}

		private function removeLoadersListeners():void
		{
			validateDisposal();
			
			var it:IIterator = _allLoaders.iterator();
			var loader:VostokLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				removeLoaderListeners(loader);
			}
		}
		
		private function removeLoaderListeners(loader:VostokLoader):void
		{
			validateDisposal();
			
			loader.removeEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false);
			loader.removeEventListener(LoaderEvent.CONNECTING, loaderConnectingHandler, false);
			loader.removeEventListener(LoaderEvent.FAILED, loaderFailedHandler, false);
			loader.removeEventListener(LoaderEvent.OPEN, loaderOpenedHandler, false);
		}

	}

}