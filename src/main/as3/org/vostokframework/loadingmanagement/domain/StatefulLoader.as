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
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3coreaddendum.system.IEquatable;
	import org.as3coreaddendum.system.IIndexable;
	import org.as3coreaddendum.system.IPriority;
	import org.as3utils.ReflectionUtil;
	import org.as3utils.StringUtil;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StatefulLoader extends PlainLoader implements IEquatable, IPriority, IIndexable
	{
		/**
		 * @private
		 */
		private var _currentAttempt:int;
		private var _disposed:Boolean;
		private var _errorHistory:IList;
		private var _failDescription:String;
		private var _id:String;
		private var _index:int;
		private var _maxAttempts:int;
		private var _priority:LoadPriority;
		private var _status:LoaderStatus;
		private var _statusHistory:IList;
		
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
		public function get status(): LoaderStatus { return _status; }
		
		/**
		 * description
		 */
		public function get statusHistory(): IList { return new ReadOnlyArrayList(_statusHistory.toArray()); }
		
		/**
		 * description
		 * 
		 * @param asset
		 * @param fileLoader
		 */
		public function StatefulLoader(id:String, priority:LoadPriority, maxAttempts:int)
		{
			if (ReflectionUtil.classPathEquals(this, StatefulLoader))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be directly instantiated.");
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			if (maxAttempts < 1) throw new ArgumentError("Argument <maxAttempts> must be greater than zero. Received: <" + maxAttempts + ">");
			
			_id = id;
			_priority = priority;
			_maxAttempts = maxAttempts;
			_errorHistory = new ArrayList();
			_statusHistory = new ArrayList();
			
			setStatus(LoaderStatus.QUEUED);
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		override public function cancel(): void
		{
			validateDisposal();
			
			if (_status.equals(LoaderStatus.CANCELED) ||
				_status.equals(LoaderStatus.COMPLETE) ||
				_status.equals(LoaderStatus.FAILED)) return;
			
			doCancel();
			
			setStatus(LoaderStatus.CANCELED);
			dispatchEvent(new LoaderEvent(LoaderEvent.CANCELED));
		}
		
		override public function dispose():void
		{
			if (_disposed) return;
			
			_errorHistory.clear();
			_statusHistory.clear();
			
			_errorHistory = null;
			_statusHistory = null;
			_status = null;
			
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
		 * @return
 		 */
		override public function load(): void
		{
			validateDisposal();
			
			if (_status.equals(LoaderStatus.CONNECTING)) throw new IllegalOperationError("The current status is <LoaderStatus.CONNECTING>, therefore it is not allowed to start a new loading right now.");
			if (_status.equals(LoaderStatus.LOADING)) throw new IllegalOperationError("The current status is <LoaderStatus.LOADING>, therefore it is not allowed to start a new loading right now.");
			if (_status.equals(LoaderStatus.COMPLETE)) throw new IllegalOperationError("The current status is <LoaderStatus.COMPLETE>, therefore it is no longer allowed loadings.");
			if (_status.equals(LoaderStatus.FAILED)) throw new IllegalOperationError("The current status is <LoaderStatus.FAILED>, therefore it is no longer allowed loadings.");
			if (_status.equals(LoaderStatus.CANCELED)) throw new IllegalOperationError("The current status is <LoaderStatus.CANCELED>, therefore it is no longer allowed loadings.");
			
			_load();
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		override public function stop(): void
		{
			validateDisposal();
			
			if (_status.equals(LoaderStatus.STOPPED) ||
				_status.equals(LoaderStatus.CANCELED) ||
				_status.equals(LoaderStatus.COMPLETE) ||
				_status.equals(LoaderStatus.FAILED))
			{
				return;
			}
			
			if (_status.equals(LoaderStatus.CONNECTING) || _status.equals(LoaderStatus.LOADING))
			{
				_currentAttempt--;
			}
			
			setStatus(LoaderStatus.STOPPED);
			dispatchEvent(new LoaderEvent(LoaderEvent.STOPPED));
			doStop();
		}
		
		override public function toString():String
		{
			return "[" + ReflectionUtil.getClassName(this) + " id <" + id + ">]";
		}
		
		protected function error(error:LoadError, errorDescription:String):void
		{
			validateDisposal();
			
			_failDescription = errorDescription;
			_errorHistory.add(error);
			
			setStatus(LoaderStatus.CONNECTION_ERROR);
			
			if (error.equals(LoadError.SECURITY_ERROR))
			{
				failed();
				return;
			}
			
			_load();
		}
		
		protected function loadingInit(data:* = null):void
		{
			validateDisposal();
			dispatchEvent(new LoaderEvent(LoaderEvent.INIT, data));
		}
		
		protected function loadingStarted(data:* = null, latency:int = 0):void
		{
			validateDisposal();
			setStatus(LoaderStatus.LOADING);
			dispatchEvent(new LoaderEvent(LoaderEvent.OPEN, data, latency));
		}
		
		protected function loadingComplete(data:* = null):void
		{
			validateDisposal();
			setStatus(LoaderStatus.COMPLETE);
			dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, data));
		}
		
		protected function doCancel():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function doDispose():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function doLoad():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function doStop():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * @private
		 */
		protected function validateDisposal():void
		{
			if (_disposed) throw new ObjectDisposedError("This object was disposed, therefore no more operations can be performed.");
		}
		
		private function failed():void
		{
			validateDisposal();
			setStatus(LoaderStatus.FAILED);
			dispatchEvent(new LoaderEvent(LoaderEvent.FAILED));
		}
		
		private function _load():void
		{
			validateDisposal();
			
			_currentAttempt++;
			
			if (isExhaustedAttempts())
			{
				failed();
				return;
			}
			
			setStatus(LoaderStatus.CONNECTING);
			dispatchEvent(new LoaderEvent(LoaderEvent.CONNECTING));
			doLoad();
		}
		
		/**
		 * @private
		 */
		private function isExhaustedAttempts():Boolean
		{
			return _currentAttempt > _maxAttempts;
		}
		
		/**
		 * @private
		 */
		private function setStatus(status:LoaderStatus):void
		{
			validateDisposal();
			_status = status;
			_statusHistory.add(_status);
		}

	}

}