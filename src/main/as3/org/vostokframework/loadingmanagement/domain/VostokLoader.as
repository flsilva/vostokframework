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
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3collections.lists.TypedList;
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3coreaddendum.system.IDisposable;
	import org.as3coreaddendum.system.IEquatable;
	import org.as3coreaddendum.system.IIndexable;
	import org.as3coreaddendum.system.IPriority;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.events.LoaderErrorEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoadingAlgorithmErrorEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoadingAlgorithmEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.LoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderComplete;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderConnecting;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderFailed;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderLoading;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderQueued;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class VostokLoader extends EventDispatcher implements IEquatable, IDisposable, IPriority, IIndexable
	{
		/**
		 * @private
		 */
		private var _algorithm:LoadingAlgorithm;
		private var _disposed:Boolean;
		private var _identification:VostokIdentification;
		private var _index:int;
		private var _priority:LoadPriority;
		private var _state:LoaderState;
		private var _stateHistory:IList;
		
		/**
		 * description
		 */
		public function get identification(): VostokIdentification { return _identification; }
		
		/**
		 * description
		 */
		public function get index(): int { return _index; }
		public function set index(value:int): void { _index = value; }
		
		/**
		 * description
		 */
		public function get priority(): int { return _priority.ordinal; }
		public function set priority(value:int): void
		{
			try
			{
				_priority = LoadPriority.getByOrdinal(value);
			}
			catch(error:Error)
			{
				var errorMessage:String = "Value must be between 0 and 4. Received: <" + value + ">.\n";
				errorMessage += "For further information please consult the documentation section about:\n";
				errorMessage += ReflectionUtil.getClassPath(LoadPriority);
				throw new ArgumentError(errorMessage);
			}
		}
		
		/**
		 * description
		 */
		public function get state(): LoaderState { return _state; }
		
		/**
		 * description
		 */
		public function get stateHistory(): IList
		{
			validateDisposal();
			return new ReadOnlyArrayList(_stateHistory.toArray());
		}
		
		public function get openedConnections():int
		{
			validateDisposal();
			return _algorithm.openedConnections;
		}
		
		/**
		 * description
		 * 
		 */
		public function VostokLoader(identification:VostokIdentification, algorithm:LoadingAlgorithm, priority:LoadPriority)
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			if (!algorithm) throw new ArgumentError("Argument <algorithm> must not be null.");
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			
			_identification = identification;
			_algorithm = algorithm;
			_priority = priority;
			
			_stateHistory = new TypedList(new ArrayList(), LoaderState);
			
			addAlgorithmListeners();
			setState(LoaderQueued.INSTANCE);
		}
		
		override public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			validateDisposal();
			
			if (type == ProgressEvent.PROGRESS)
			{
				_algorithm.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
			else
			{
				super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 */
		public function addLoader(loader:VostokLoader): void
		{
			validateDisposal();
			_state.addLoader(loader, _algorithm);
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 */
		public function addLoaders(loaders:IList): void
		{
			validateDisposal();
			_state.addLoaders(loaders, _algorithm);
		}
		
		/**
		 * description
		 * 
 		 */
		public function cancel(): void
		{
			validateDisposal();
			_state.cancel(this, _algorithm);
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function cancelLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			_state.cancelLoader(identification, _algorithm);
		}
		
		/**
		 * description
		 * 
		 * @param identification
		 */
		public function containsLoader(identification:VostokIdentification): Boolean
		{
			validateDisposal();
			return _algorithm.containsLoader(identification);
		}
		
		override public function dispatchEvent(event : Event) : Boolean
		{
			validateDisposal();
			
			if (event.type == ProgressEvent.PROGRESS)
			{
				return _algorithm.dispatchEvent(event);
			}
			else
			{
				return super.dispatchEvent(event);
			}
		}
		
		/**
		 * description
		 * 
 		 */
		public function dispose():void
		{
			if (_disposed) return;
			
			removeAlgorithmListeners();
			
			_stateHistory.clear();
			_algorithm.dispose();
			
			_stateHistory = null;
			_state = null;
			_algorithm = null;
			
			_disposed = true;
		}
		
		public function equals(other : *): Boolean
		{
			validateDisposal();
			
			if (this == other) return true;
			if (!(other is VostokLoader)) return false;
			
			var otherLoader:VostokLoader = other as VostokLoader;
			return _identification.equals(otherLoader.identification);
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function getLoader(identification:VostokIdentification): VostokLoader
		{
			validateDisposal();
			return _algorithm.getLoader(identification);
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function getLoaderState(identification:VostokIdentification): LoaderState
		{
			validateDisposal();
			return _algorithm.getLoaderState(identification);
		}
		
		/**
		 * description
		 * 
		 * @param identification
		 */
		public function getParent(identification:VostokIdentification): VostokLoader
		{
			validateDisposal();
			return _algorithm.getParent(this, identification);
		}
		
		override public function hasEventListener(type : String) : Boolean
		{
			validateDisposal();
			
			if (type == ProgressEvent.PROGRESS)
			{
				return _algorithm.hasEventListener(type);
			}
			else
			{
				return super.hasEventListener(type);
			}
		}
		
		override public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			validateDisposal();
			
			if (type == ProgressEvent.PROGRESS)
			{
				_algorithm.removeEventListener(type, listener, useCapture);
			}
			else
			{
				super.removeEventListener(type, listener, useCapture);
			}
		}
		
		/**
		 * description
		 * 
 		 */
		public function load(): void
		{
			validateDisposal();
			_state.load(this, _algorithm);
		}

		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function removeLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			_state.removeLoader(identification, _algorithm);
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function resumeLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			_state.resumeLoader(identification, _algorithm);
		}

		/**
		 * description
		 */
		public function stop(): void
		{
			validateDisposal();
			_state.stop(this, _algorithm);
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function stopLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			_state.stopLoader(identification, _algorithm);
		}
		
		override public function toString():String
		{
			return "[VostokLoader " + identification + "]";
		}
		
		override public function willTrigger(type : String) : Boolean
		{
			validateDisposal();
			
			if (type == ProgressEvent.PROGRESS)
			{
				return _algorithm.willTrigger(type);
			}
			else
			{
				return super.willTrigger(type);
			}
		}
		
		/**
		 * @private
		 */
		internal function setState(state:LoaderState):void
		{
			validateDisposal();
			
			_state = state;
			_stateHistory.add(_state);
		}
		
		private function addAlgorithmListeners():void
		{
			validateDisposal();
			
			_algorithm.addEventListener(LoadingAlgorithmEvent.COMPLETE, completeHandler, false, 0, true);
			_algorithm.addEventListener(LoadingAlgorithmEvent.CONNECTING, connectingHandler, false, 0, true);
			_algorithm.addEventListener(LoadingAlgorithmEvent.OPEN, openHandler, false, 0, true);
			_algorithm.addEventListener(LoadingAlgorithmEvent.INIT, initHandler, false, 0, true);
			_algorithm.addEventListener(LoadingAlgorithmEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			_algorithm.addEventListener(LoadingAlgorithmErrorEvent.FAILED, failedHandler, false, 0, true);
		}
		
		private function completeHandler(event:LoadingAlgorithmEvent):void
		{
			validateDisposal();
			setState(LoaderComplete.INSTANCE);
			dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, event.data));
		}
		
		private function connectingHandler(event:LoadingAlgorithmEvent):void
		{
			validateDisposal();
			setState(LoaderConnecting.INSTANCE);
			dispatchEvent(new LoaderEvent(LoaderEvent.CONNECTING));
		}
		
		private function failedHandler(event:LoadingAlgorithmErrorEvent):void
		{
			setState(LoaderFailed.INSTANCE);
			dispatchEvent(new LoaderErrorEvent(LoaderErrorEvent.FAILED, event.errors));
		}
		
		private function httpStatusHandler(event:LoadingAlgorithmEvent):void
		{
			validateDisposal();
			
			var $event:LoaderEvent = new LoaderEvent(LoaderEvent.HTTP_STATUS);
			$event.httpStatus = event.httpStatus;
			
			dispatchEvent($event);
		}
		
		private function initHandler(event:LoadingAlgorithmEvent):void
		{
			validateDisposal();
			dispatchEvent(new LoaderEvent(LoaderEvent.INIT, event.data));
		}
		
		private function openHandler(event:LoadingAlgorithmEvent):void
		{
			validateDisposal();
			setState(LoaderLoading.INSTANCE);
			dispatchEvent(new LoaderEvent(LoaderEvent.OPEN, event.data, event.latency));
		}
		
		private function removeAlgorithmListeners():void
		{
			validateDisposal();
			
			_algorithm.removeEventListener(LoadingAlgorithmEvent.COMPLETE, completeHandler, false);
			_algorithm.removeEventListener(LoadingAlgorithmEvent.CONNECTING, connectingHandler, false);
			_algorithm.removeEventListener(LoadingAlgorithmEvent.OPEN, openHandler, false);
			_algorithm.removeEventListener(LoadingAlgorithmEvent.INIT, initHandler, false);
			_algorithm.removeEventListener(LoadingAlgorithmEvent.HTTP_STATUS, httpStatusHandler, false);
			_algorithm.removeEventListener(LoadingAlgorithmErrorEvent.FAILED, failedHandler, false);
		}
		
		/**
		 * @private
		 */
		private function validateDisposal():void
		{
			if (_disposed) throw new ObjectDisposedError("This object was disposed, therefore no more operations can be performed.");
		}
	}

}