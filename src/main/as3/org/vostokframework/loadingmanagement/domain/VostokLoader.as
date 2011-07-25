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
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3coreaddendum.system.IDisposable;
	import org.as3coreaddendum.system.IEquatable;
	import org.as3coreaddendum.system.IIndexable;
	import org.as3coreaddendum.system.IPriority;
	import org.as3utils.ReflectionUtil;
	import org.as3utils.StringUtil;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.LoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderComplete;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderConnectionError;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderFailed;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderLoading;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderQueued;

	import flash.events.EventDispatcher;

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
		private var _currentAttempt:int;
		private var _disposed:Boolean;
		private var _errorHistory:IList;
		private var _failDescription:String;
		private var _id:String;
		private var _index:int;
		private var _maxAttempts:int;
		private var _priority:LoadPriority;
		private var _state:LoaderState;
		private var _stateHistory:IList;
		
		/**
		 * description
		 */
		public function get errorHistory(): IList { return _errorHistory; }
		
		/**
		 * description
		 */
		public function get id(): String { return _id; }
		
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
		public function get stateHistory(): IList { return new ReadOnlyArrayList(_stateHistory.toArray()); }
		
		/**
		 * @private
		 */
		internal function get currentAttempt():int { return _currentAttempt; }
		internal function set currentAttempt(value:int):void { _currentAttempt = value; }
		
		internal function get maxAttempts():int { return _maxAttempts; }
		
		/**
		 * description
		 * 
		 */
		public function VostokLoader(id:String, algorithm:LoadingAlgorithm, priority:LoadPriority, maxAttempts:int)
		{
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			if (maxAttempts < 1) throw new ArgumentError("Argument <maxAttempts> must be greater than zero. Received: <" + maxAttempts + ">");
			
			_id = id;
			_algorithm = algorithm;
			_priority = priority;
			_maxAttempts = maxAttempts;
			
			_errorHistory = new ArrayList();
			_stateHistory = new TypedList(new ArrayList(), LoaderState);
			
			setState(LoaderQueued.INSTANCE);
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
 		 */
		public function dispose():void
		{
			if (_disposed) return;
			
			_errorHistory.clear();
			_stateHistory.clear();
			_algorithm.dispose();
			
			_errorHistory = null;
			_stateHistory = null;
			_state = null;
			_algorithm = null;
			
			doDispose();
			_disposed = true;
		}
		
		public function equals(other : *): Boolean
		{
			validateDisposal();
			
			if (this == other) return true;
			if (!(other is StatefulLoader)) return false;
			
			var otherLoader:StatefulLoader = other as StatefulLoader;
			return _id == otherLoader.id;
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
		 */
		public function stop(): void
		{
			validateDisposal();
			_state.stop(this, _algorithm);
		}
		
		internal function failed():void
		{
			validateDisposal();
			
			setState(LoaderFailed.INSTANCE);
			dispatchEvent(new LoaderEvent(LoaderEvent.FAILED));
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
		
		protected function doDispose():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function loadingInit(data:* = null):void
		{
			validateDisposal();
			dispatchEvent(new LoaderEvent(LoaderEvent.INIT, data));
		}
		
		protected function loadingStarted(data:* = null, latency:int = 0):void
		{
			validateDisposal();
			setState(LoaderLoading.INSTANCE);
			dispatchEvent(new LoaderEvent(LoaderEvent.OPEN, data, latency));
		}
		
		protected function loadingComplete(data:* = null):void
		{
			validateDisposal();
			setState(LoaderComplete.INSTANCE);
			dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, data));
		}
		
		protected function error(error:LoadError, errorDescription:String):void
		{
			validateDisposal();
			
			_failDescription = errorDescription;
			_errorHistory.add(error);
			
			setState(LoaderConnectionError.INSTANCE);
			
			if (error.equals(LoadError.SECURITY_ERROR))
			{
				failed();
				return;
			}
			
			load();
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