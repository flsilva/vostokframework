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
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;

	import flash.events.EventDispatcher;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class VostokLoader extends EventDispatcher implements ILoaderStateTransition
	{
		/**
		 * @private
		 */
		private var _disposed:Boolean;
		private var _identification:VostokIdentification;
		private var _index:int;
		private var _priority:LoadPriority;
		private var _state:ILoaderState;
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
		public function get state(): ILoaderState { return _state; }
		
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
			return _state.openedConnections;
		}
		
		/**
		 * description
		 * 
		 */
		public function VostokLoader(identification:VostokIdentification, state:ILoaderState, priority:LoadPriority)
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			if (!state) throw new ArgumentError("Argument <state> must not be null.");
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			
			_identification = identification;
			_state = state;
			_priority = priority;
			_stateHistory = new TypedList(new ArrayList(), ILoaderState);
			
			_state.setLoader(this);
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 */
		public function addLoader(loader:ILoader): void
		{
			validateDisposal();
			_state.addLoader(loader);
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 */
		public function addLoaders(loaders:IList): void
		{
			validateDisposal();
			_state.addLoaders(loaders);
		}
		
		/**
		 * description
		 * 
 		 */
		public function cancel(): void
		{
			validateDisposal();
			_state.cancel();
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function cancelLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			_state.cancelLoader(identification);
		}
		
		/**
		 * description
		 * 
		 * @param identification
		 */
		public function containsLoader(identification:VostokIdentification): Boolean
		{
			validateDisposal();
			return _state.containsLoader(identification);
		}
		
		/**
		 * description
		 * 
 		 */
		public function dispose():void
		{
			if (_disposed) return;
			
			_state.dispose();
			_stateHistory.clear();
			
			_stateHistory = null;
			_state = null;
			
			_disposed = true;
		}
		
		public function equals(other : *): Boolean
		{
			validateDisposal();
			
			if (this == other) return true;
			if (!(other is ILoader)) return false;
			
			var otherLoader:ILoader = other as ILoader;
			return _identification.equals(otherLoader.identification);
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function getLoader(identification:VostokIdentification): ILoader
		{
			validateDisposal();
			return _state.getLoader(identification);
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function getLoaderState(identification:VostokIdentification): ILoaderState
		{
			validateDisposal();
			return _state.getLoaderState(identification);
		}
		
		/**
		 * description
		 * 
		 * @param identification
		 */
		public function getParent(identification:VostokIdentification): ILoader
		{
			validateDisposal();
			return _state.getParent(identification);
		}
		
		/**
		 * description
		 * 
 		 */
		public function load(): void
		{
			validateDisposal();
			_state.load();
		}

		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function removeLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			_state.removeLoader(identification);
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function resumeLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			_state.resumeLoader(identification);
		}
		
		/**
		 * @private
		 */
		public function setState(state:ILoaderState):void
		{
			validateDisposal();
			
			_state = state;
			_stateHistory.add(_state);
		}

		/**
		 * description
		 */
		public function stop(): void
		{
			validateDisposal();
			_state.stop();
		}
		
		/**
		 * description
		 * 
		 * @param loaderId
		 */
		public function stopLoader(identification:VostokIdentification): void
		{
			validateDisposal();
			_state.stopLoader(identification);
		}
		
		override public function toString():String
		{
			return "[ILoader " + identification + "]";
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