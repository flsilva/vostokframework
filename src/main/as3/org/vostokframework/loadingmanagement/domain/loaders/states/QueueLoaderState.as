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
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.ILoader;
	import org.vostokframework.loadingmanagement.domain.ILoaderState;
	import org.vostokframework.loadingmanagement.domain.ILoaderStateTransition;
	import org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError;
	import org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.policies.ILoadingPolicy;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class QueueLoaderState implements ILoaderState
	{
		//TODO:pensar em transformar essa classe em outra classe utilizada pelas subclasses como composition
		//renomear pra algo como QueueLoaderCommonBehavior.as
		//issue com metodos "loaderAdded(), loaderRemoved()" etc
		/**
		 * @private
		 */
		private var _disposed:Boolean;
		private var _loader:ILoaderStateTransition;
		private var _loadingStatus:QueueLoadingStatus;
		private var _policy:ILoadingPolicy;
		
		/**
		 * @private
		 */
		protected function get loader():ILoaderStateTransition { return _loader; }
		
		protected function get loadingStatus():QueueLoadingStatus { return _loadingStatus; }
		
		protected function get policy():ILoadingPolicy { return _policy; }
		
		public function get openedConnections():int { return 0; }
		
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function QueueLoaderState(loadingStatus:QueueLoadingStatus, policy:ILoadingPolicy)
		{
			if (ReflectionUtil.classPathEquals(this, QueueLoaderState))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be directly instantiated.");
			if (!loadingStatus) throw new ArgumentError("Argument <loadingStatus> must not be null.");
			if (!policy) throw new ArgumentError("Argument <policy> must not be null.");
			
			_loadingStatus = loadingStatus;
			_policy = policy;
		}
		
		public function addLoader(loader:ILoader): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function addLoaders(loaders:IList): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function cancel():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function cancelLoader(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function containsLoader(identification:VostokIdentification): Boolean
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function dispose():void
		{
			if (_disposed) return;
			
			doDispose();
			
			_loadingStatus.dispose();
			
			_disposed = true;
			_loader = null;
			_loadingStatus = null;
			_policy = null;
		}
		
		public function equals(other:*):Boolean
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function getLoader(identification:VostokIdentification): ILoader
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function getLoaderState(identification:VostokIdentification): ILoaderState
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function getParent(identification:VostokIdentification): ILoader
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function load():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function removeLoader(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function resumeLoader(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function setLoader(loader:ILoaderStateTransition):void
		{
			_loader = loader;
		}
		
		public function stop():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function stopLoader(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * @private
		 */
		protected function addLoaderBehavior(loader:ILoader): void
		{
			validateDisposal();
			
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			
			if (containsLoader(loader.identification))
			{
				var errorMessage:String = "There is already a ILoader object stored with identification:\n";
				errorMessage += "<" + loader.identification + ">";
				
				throw new DuplicateLoaderError(loader.identification, errorMessage);
			}
			
			loader.index = loadingStatus.allLoaders.size();
			
			// VostokIdentification().toString() used for performance optimization
			loadingStatus.allLoaders.put(loader.identification.toString(), loader);
			loadingStatus.canceledLoaders.remove(loader);
			loadingStatus.queuedLoaders.add(loader); 
			
			loaderAdded(loader);
		}
		
		/**
		 * @private
		 */
		protected function addLoadersBehavior(loaders:IList): void
		{
			validateDisposal();
			
			if (!loaders || loaders.isEmpty()) throw new ArgumentError("Argument <loaders> must not be null nor empty.");
			
			var it:IIterator = loaders.iterator();
			var child:ILoader;
			
			while (it.hasNext())
			{
				child = it.next();
				addLoader(child);
			}
		}
		
		/**
		 * @private
		 */
		protected function cancelBehavior(): void
		{
			validateDisposal();
			
			var it:IIterator = loadingStatus.allLoaders.iterator();
			var child:ILoader;
			
			while (it.hasNext())
			{
				child = it.next();
				/*loader.cancel();
				
				loadingStatus.canceledLoaders.add(loader);
				loadingStatus.loadingLoaders.remove(loader);
				loadingStatus.queuedLoaders.remove(loader);
				loadingStatus.stoppedLoaders.remove(loader);*/
				
				cancelLoaderBehavior(child.identification);
			}
			
			loader.setState(new CanceledQueueLoader(loader, loadingStatus, policy));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.CANCELED));
			dispose();
		}
		
		/**
		 * @private
		 */
		protected function cancelLoaderBehavior(identification:VostokIdentification): void
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			var child:ILoader;
			
			if (loadingStatus.allLoaders.containsKey(identification.toString()))
			{
				child = loadingStatus.allLoaders.getValue(identification.toString());
				
				loadingStatus.canceledLoaders.add(child);
				loadingStatus.completeLoaders.remove(child);
				loadingStatus.loadingLoaders.remove(child);
				loadingStatus.queuedLoaders.remove(child);
				loadingStatus.stoppedLoaders.remove(child);
				
				child.cancel();
				loaderCanceled(child);
				
				removeLoader(child.identification);
				
				//TODO:verificar se nao deve chamar loaderNext();
				//loadNext();
			}
			else
			{
				var it:IIterator = loadingStatus.allLoaders.iterator();
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification))
					{
						child.cancelLoader(identification);
						return;
					}
				}
				
				var message:String = "There is no ILoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		/**
		 * @private
		 */
		protected function containsLoaderBehavior(identification:VostokIdentification): Boolean
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			if (loadingStatus.allLoaders.isEmpty()) return false;
			if (loadingStatus.allLoaders.containsKey(identification.toString())) return true;
			
			var it:IIterator = loadingStatus.allLoaders.iterator();
			var child:ILoader;
			
			while (it.hasNext())
			{
				child = it.next();
				if (child.containsLoader(identification)) return true;
			}
			
			return false;
		}
		
		/**
		 * @private
		 */
		protected function doDispose():void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function getLoaderBehavior(identification:VostokIdentification): ILoader
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			if (loadingStatus.allLoaders.containsKey(identification.toString()))
			{
				return loadingStatus.allLoaders.getValue(identification.toString());
			}
			else
			{
				var it:IIterator = loadingStatus.allLoaders.iterator();
				var child:ILoader;
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification)) return child.getLoader(identification);
				}
				
				var message:String = "There is no ILoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		/**
		 * @private
		 */
		protected function getLoaderStateBehavior(identification:VostokIdentification): ILoaderState
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			var child:ILoader;
			
			if (loadingStatus.allLoaders.containsKey(identification.toString()))
			{
				child = loadingStatus.allLoaders.getValue(identification.toString());
				return child.state;
			}
			else
			{
				var it:IIterator = loadingStatus.allLoaders.iterator();
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification)) return child.getLoaderState(identification);
				}
				
				var message:String = "There is no ILoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		/**
		 * @private
		 */
		protected function getParentBehavior(identification:VostokIdentification): ILoader
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			if (loadingStatus.allLoaders.containsKey(identification.toString()))
			{
				return loader;
			}
			else
			{
				var it:IIterator = loadingStatus.allLoaders.iterator();
				var child:ILoader;
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification)) return child.getParent(identification);
				}
			}
			
			return null;
		}
		
		/**
		 * @private
		 */
		protected function loadBehavior(): void
		{
			//TODO:pensar sobre criar factory para states e chamar método daqui
			loader.setState(new LoadingQueueLoader(loader, loadingStatus, policy));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.CONNECTING));
		}
		
		/**
		 * @private
		 */
		protected function loaderAdded(loader:ILoader): void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function loaderCanceled(loader:ILoader): void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function loaderRemoved(loader:ILoader): void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function loaderResumed(loader:ILoader): void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function loaderStopped(loader:ILoader): void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function removeLoaderBehavior(identification:VostokIdentification): void
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			var child:ILoader;
			
			if (loadingStatus.allLoaders.containsKey(identification.toString()))
			{
				child = loadingStatus.allLoaders.getValue(identification.toString());
				
				loadingStatus.allLoaders.remove(identification.toString());
				loadingStatus.canceledLoaders.remove(child);
				loadingStatus.loadingLoaders.remove(child);
				loadingStatus.queuedLoaders.remove(child);
				loadingStatus.stoppedLoaders.remove(child);
				
				child.dispose();//TODO:pensar se tirar a chamada daqui e colocar no client (acho melhor)
				loaderRemoved(child);
			}
			else
			{
				var it:IIterator = loadingStatus.allLoaders.iterator();
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification))
					{
						child.removeLoader(identification);
						return;
					}
				}
				
				var message:String = "There is no ILoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		/**
		 * @private
		 */
		protected function resumeLoaderBehavior(identification:VostokIdentification): void
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			var child:ILoader;
			
			if (loadingStatus.allLoaders.containsKey(identification.toString()))
			{
				child = loadingStatus.allLoaders.getValue(identification.toString());
				
				if (loadingStatus.queuedLoaders.contains(child)
					|| loadingStatus.loadingLoaders.contains(child)) return;
				
				var errorMessage:String;
				
				if (loadingStatus.canceledLoaders.contains(child))
				{
					errorMessage = "ILoader object with identification:\n";
					errorMessage += identification + "\n";
					errorMessage += "was canceled, therefore it is not allowed to resume it.";
					
					throw new IllegalOperationError(errorMessage);
				}
				
				if (loadingStatus.completeLoaders.contains(child))
				{
					errorMessage = "ILoader object with identification:\n";
					errorMessage += identification + "\n";
					errorMessage += "is complete, therefore it is not allowed to resume it.";
					
					throw new IllegalOperationError(errorMessage);
				}
				
				loadingStatus.queuedLoaders.add(child);
				loadingStatus.stoppedLoaders.remove(child);
				
				loaderResumed(child);
				
				//isLoading = true;//IMPORTANT: if queue is stopped, it will resume its loading
				//loadNext();
			}
			else
			{
				var it:IIterator = loadingStatus.allLoaders.iterator();
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification))
					{
						child.resumeLoader(identification);
						return;
					}
				}
				
				var message:String = "There is no ILoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		/**
		 * @private
		 */
		protected function stopBehavior():void
		{
			validateDisposal();
			
			//_isLoading = false;
			//_openEventDispatched = false;
			
			var it:IIterator = loadingStatus.allLoaders.iterator();
			var child:ILoader;
			
			while (it.hasNext())
			{
				child = it.next();
				stopLoaderBehavior(child.identification);
			}
			
			loader.setState(new StoppedQueueLoader(loader, loadingStatus, policy));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.STOPPED));
			dispose();
		}
		
		/**
		 * @private
		 */
		protected function stopLoaderBehavior(identification:VostokIdentification):void
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			var child:ILoader;
			
			if (loadingStatus.allLoaders.containsKey(identification.toString()))
			{
				child = loadingStatus.allLoaders.getValue(identification.toString());
				
				loadingStatus.loadingLoaders.remove(child);
				loadingStatus.queuedLoaders.remove(child);
				loadingStatus.stoppedLoaders.add(child);
				
				child.stop();
				//loadNext();
				loaderStopped(child);
			}
			else
			{
				var it:IIterator = loadingStatus.allLoaders.iterator();
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsLoader(identification))
					{
						child.stopLoader(identification);
						return;
					}
				}
				
				var message:String = "There is no ILoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		/**
		 * @private
		 */
		protected function validateDisposal():void
		{
			if (_disposed) throw new ObjectDisposedError("This object was disposed, therefore no more operations can be performed.");
		}
		
	}

}