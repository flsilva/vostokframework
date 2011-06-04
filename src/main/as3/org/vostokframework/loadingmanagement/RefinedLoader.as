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
package org.vostokframework.loadingmanagement
{
	import org.as3coreaddendum.system.IIndexable;
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3coreaddendum.system.IEquatable;
	import org.as3coreaddendum.system.IPriority;
	import org.as3utils.ReflectionUtil;
	import org.as3utils.StringUtil;
	import org.vostokframework.loadingmanagement.events.LoaderEvent;

	import flash.errors.IllegalOperationError;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class RefinedLoader extends PlainLoader implements IEquatable, IPriority, IIndexable
	{
		/**
		 * @private
		 */
		private static const DELAY_FIRST_LOAD:int = 50;//milliseconds
		
		private var _currentAttempt:int;
		private var _delayLoadAfterError:int;
		private var _errorHistory:IList;
		private var _failDescription:String;
		private var _index:int;
		private var _maxAttempts:int;
		private var _priority:LoadPriority;
		private var _status:LoaderStatus;
		private var _statusHistory:IList;
		private var _timerLoadDelay:Timer;
		
		/**
		 * description
		 */
		private var _id:String;
		
		/**
		 * description
		 */
		public function get delayLoadAfterError(): int { return _delayLoadAfterError; }
		public function set delayLoadAfterError(value:int): void { _delayLoadAfterError = value; }//TODO:VALIDATE
		
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
		public function set priority(value:int): void { return; }//TODO:implementar
		
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
		public function RefinedLoader(id:String, priority:LoadPriority, maxAttempts:int)
		{
			if (ReflectionUtil.classPathEquals(this, RefinedLoader))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be instantiated directly.");
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			if (maxAttempts < 1) throw new ArgumentError("Argument <maxAttempts> must be greater than zero. Received: <" + maxAttempts + ">");
			
			_id = id;
			_priority = priority;
			_maxAttempts = maxAttempts;
			_delayLoadAfterError = 5000;
			_errorHistory = new ArrayList();
			_statusHistory = new ArrayList();
			
			_timerLoadDelay = new Timer(DELAY_FIRST_LOAD);
			_timerLoadDelay.addEventListener(TimerEvent.TIMER, timerLoadDelayHandler, false, 0, true);
			
			setStatus(LoaderStatus.QUEUED);
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		override public function cancel(): void
		{
			if (_status.equals(LoaderStatus.CANCELED) ||
				_status.equals(LoaderStatus.COMPLETE) ||
				_status.equals(LoaderStatus.FAILED)) return;
			
			_timerLoadDelay.stop();
			setStatus(LoaderStatus.CANCELED);
			dispatchEvent(new LoaderEvent(LoaderEvent.CANCELED));
			doCancel();
		}
		
		override public function dispose():void
		{
			_errorHistory.clear();
			_statusHistory.clear();
			_timerLoadDelay.removeEventListener(TimerEvent.TIMER, timerLoadDelayHandler, false);
			
			_errorHistory = null;
			_statusHistory = null;
			_status = null;
			_timerLoadDelay = null;
			
			super.dispose();
		}
		
		public function equals(other : *): Boolean
		{
			if (this == other) return true;
			if (!(other is RefinedLoader)) return false;
			
			var otherLoader:RefinedLoader = other as RefinedLoader;
			return _id == otherLoader.id;
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		override public function load(): void
		{
			if (_status.equals(LoaderStatus.CONNECTING)) throw new IllegalOperationError("The current status is <LoaderStatus.CONNECTING>, therefore it is not allowed to start a new loading right now.");
			if (_status.equals(LoaderStatus.LOADING)) throw new IllegalOperationError("The current status is <LoaderStatus.LOADING>, therefore it is not allowed to start a new loading right now.");
			if (_status.equals(LoaderStatus.COMPLETE)) throw new IllegalOperationError("The current status is <LoaderStatus.COMPLETE>, therefore it is no longer allowed loadings.");
			if (_status.equals(LoaderStatus.FAILED)) throw new IllegalOperationError("The current status is <AssetLoaderStatus.FAILED_EXHAUSTED_ATTEMPTS>, therefore it is no longer allowed loadings.");
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
			
			_timerLoadDelay.stop();
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
			_failDescription = errorDescription;
			_errorHistory.add(error);
			_timerLoadDelay.delay = _delayLoadAfterError;
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
			dispatchEvent(new LoaderEvent(LoaderEvent.INIT, data));
		}
		
		protected function loadingStarted(data:* = null):void
		{
			setStatus(LoaderStatus.LOADING);
			dispatchEvent(new LoaderEvent(LoaderEvent.OPEN, data));
		}
		
		protected function loadingComplete(data:* = null):void
		{
			setStatus(LoaderStatus.COMPLETE);
			dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, data));
		}
		
		protected function doCancel():void
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
		
		private function failed():void
		{
			setStatus(LoaderStatus.FAILED);
			dispatchEvent(new LoaderEvent(LoaderEvent.FAILED));
		}
		
		private function _load():void
		{
			_currentAttempt++;
			
			if (isExhaustedAttempts())
			{
				failed();
				return;
			}
			
			setStatus(LoaderStatus.CONNECTING);
			dispatchEvent(new LoaderEvent(LoaderEvent.CONNECTING));
			_timerLoadDelay.start();
		}

		private function timerLoadDelayHandler(event:TimerEvent):void
		{
			_timerLoadDelay.stop();
			doLoad();
		}
		
		/**
		 * @private
		 */
		private function isExhaustedAttempts():Boolean
		{
			return _currentAttempt > _maxAttempts;
		}
		
		private function setStatus(status:LoaderStatus):void
		{
			_status = status;
			_statusHistory.add(_status);
		}

	}

}