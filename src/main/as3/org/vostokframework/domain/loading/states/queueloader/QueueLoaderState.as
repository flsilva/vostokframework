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
	import org.as3collections.IList;
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.ILoaderState;
	import org.vostokframework.domain.loading.ILoaderStateTransition;
	import org.vostokframework.domain.loading.errors.DuplicateLoaderError;
	import org.vostokframework.domain.loading.errors.LoaderNotFoundError;
	import org.vostokframework.domain.loading.events.LoaderEvent;
	import org.vostokframework.domain.loading.policies.ILoadingPolicy;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class QueueLoaderState implements ILoaderState
	{
		
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
		
		public function get isLoading():Boolean { return false; }
		
		public function get isQueued():Boolean { return false; }
		
		public function get isStopped():Boolean { return false; }
		
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
		
		public function addChild(child:ILoader): void
		{
			validateDisposal();
			if (!child) throw new ArgumentError("Argument <loader> must not be null.");
			
			if (containsChild(child.identification))
			{
				var errorMessage:String = "There is already an ILoader object stored with identification:\n";
				errorMessage += "<" + child.identification + ">";
				
				throw new DuplicateLoaderError(child.identification, errorMessage);
			}
			
			child.index = loadingStatus.allLoaders.size();
			
			// VostokIdentification().toString() used for performance optimization
			loadingStatus.allLoaders.put(child.identification.toString(), child);
			loadingStatus.queuedLoaders.add(child); 
			
			childAdded(child);
		}
		
		public function addChildren(children:IList): void
		{
			validateDisposal();
			
			if (!children || children.isEmpty()) throw new ArgumentError("Argument <loaders> must not be null nor empty.");
			
			var it:IIterator = children.iterator();
			var child:ILoader;
			
			while (it.hasNext())
			{
				child = it.next();
				addChild(child);
			}
		}
		
		public function cancel():void
		{
			validateDisposal();
			
			var it:IIterator = loadingStatus.allLoaders.iterator();
			var child:ILoader;
			
			while (it.hasNext())
			{
				child = it.next();
				//cancelChild(child.identification);
				
				//DO NOT CALL cancelChild() BECAUSE IT MUST NOT NOTIFY SUBCLASS
				//VIA childCanceled() AND childRemoved()
				//OTHERWISE AFTER CANCEL LAST CHILD LoadingQueueLoader CLASS
				//WOULD DISPATCH LoaderEvent.COMPLETE AND
				//MAKE STATE TRANSITION TO CompleteQueueLoader
				loadingStatus.allLoaders.remove(child.identification.toString());
				loadingStatus.completeLoaders.remove(child);
				loadingStatus.failedLoaders.remove(child);
				loadingStatus.loadingLoaders.remove(child);
				loadingStatus.queuedLoaders.remove(child);
				loadingStatus.stoppedLoaders.remove(child);
				
				child.cancel();
				child.dispose();
			}
			
			loader.setState(new CanceledQueueLoader(loader, loadingStatus, policy));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.CANCELED));
			dispose();
		}
		
		public function cancelChild(identification:VostokIdentification): void
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			var child:ILoader;
			
			if (loadingStatus.allLoaders.containsKey(identification.toString()))
			{
				child = loadingStatus.allLoaders.getValue(identification.toString());
				
				loadingStatus.completeLoaders.remove(child);
				loadingStatus.loadingLoaders.remove(child);
				loadingStatus.queuedLoaders.remove(child);
				loadingStatus.stoppedLoaders.remove(child);
				
				child.cancel();
				childCanceled(child);
				
				removeChild(child.identification);
				child.dispose();
			}
			else
			{
				var it:IIterator = loadingStatus.allLoaders.iterator();
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsChild(identification))
					{
						child.cancelChild(identification);
						return;
					}
				}
				
				var message:String = "There is no ILoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		public function containsChild(identification:VostokIdentification): Boolean
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
				if (child.containsChild(identification)) return true;
			}
			
			return false;
		}
		
		public function dispose():void
		{
			if (_disposed) return;
			
			doDispose();
			
			//_loadingStatus.dispose();
			
			_disposed = true;
			_loader = null;
			_loadingStatus = null;
			_policy = null;
		}
		
		public function getChild(identification:VostokIdentification): ILoader
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
					if (child.containsChild(identification)) return child.getChild(identification);
				}
				
				var message:String = "There is no ILoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		public function getParent(identification:VostokIdentification): ILoader
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
					if (child.containsChild(identification)) return child.getParent(identification);
				}
			}
			
			return null;
		}
		
		public function load():void
		{
			//TODO:pensar sobre criar factory para states e chamar método daqui
			loader.setState(new LoadingQueueLoader(loader, loadingStatus, policy));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.CONNECTING));
			dispose();
		}
		
		public function removeChild(identification:VostokIdentification): void
		{
			validateDisposal();
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			var child:ILoader;
			
			if (loadingStatus.allLoaders.containsKey(identification.toString()))
			{
				child = loadingStatus.allLoaders.getValue(identification.toString());
				
				loadingStatus.allLoaders.remove(identification.toString());
				loadingStatus.completeLoaders.remove(child);
				loadingStatus.failedLoaders.remove(child);
				loadingStatus.loadingLoaders.remove(child);
				loadingStatus.queuedLoaders.remove(child);
				loadingStatus.stoppedLoaders.remove(child);
				
				childRemoved(child);
			}
			else
			{
				var it:IIterator = loadingStatus.allLoaders.iterator();
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsChild(identification))
					{
						child.removeChild(identification);
						return;
					}
				}
				
				var message:String = "There is no ILoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		public function resumeChild(identification:VostokIdentification): void
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
				
				if (loadingStatus.failedLoaders.contains(child))
				{
					errorMessage = "ILoader object with identification:\n";
					errorMessage += identification + "\n";
					errorMessage += "has failed, therefore it is not allowed to resume it.";
					
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
				
				childResumed(child);
				
				//isLoading = true;//IMPORTANT: if queue is stopped, it will resume its loading
				//loadNext();
			}
			else
			{
				var it:IIterator = loadingStatus.allLoaders.iterator();
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsChild(identification))
					{
						child.resumeChild(identification);
						return;
					}
				}
				
				var message:String = "There is no ILoader object stored with identification:\n";
				message += "<" + identification + ">";
				throw new LoaderNotFoundError(identification, message);
			}
		}
		
		public function setLoader(loader:ILoaderStateTransition):void
		{
			_loader = loader;
		}
		
		public function stop():void
		{
			validateDisposal();
			
			//_isLoading = false;
			//_openEventDispatched = false;
			
			//var it:IIterator = loadingStatus.allLoaders.iterator();
			var it:IIterator = loadingStatus.loadingLoaders.iterator();
			var child:ILoader;
			
			while (it.hasNext())
			{
				child = it.next();
				//stopChild(child.identification);
				
				//DO NOT CALL stopChild() BECAUSE IT MUST NOT NOTIFY SUBCLASS
				//VIA childStopped()
				//OTHERWISE AFTER STOP FIRST CHILD LoadingQueueLoader CLASS
				//WILL CALL load() IN NEXT CHILD, WHICH MUST BE STOPPED TOO
				/*loadingStatus.loadingLoaders.remove(child);
				loadingStatus.queuedLoaders.remove(child);
				loadingStatus.stoppedLoaders.add(child);*/
				
				loadingStatus.queuedLoaders.add(child);
				it.remove();
				
				child.stop();
			}
			
			loader.setState(new StoppedQueueLoader(loader, loadingStatus, policy));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.STOPPED));
			dispose();
		}
		
		public function stopChild(identification:VostokIdentification): void
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
				childStopped(child);
			}
			else
			{
				var it:IIterator = loadingStatus.allLoaders.iterator();
				
				while (it.hasNext())
				{
					child = it.next();
					if (child.containsChild(identification))
					{
						child.stopChild(identification);
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
		protected function doDispose():void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function childAdded(child:ILoader): void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function childCanceled(child:ILoader): void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function childRemoved(child:ILoader): void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function childResumed(child:ILoader): void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function childStopped(child:ILoader): void
		{
			
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