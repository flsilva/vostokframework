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
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3coreaddendum.system.IEquatable;
	import org.as3coreaddendum.system.IPriority;
	import org.as3utils.ReflectionUtil;
	import org.as3utils.StringUtil;
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;
	import org.vostokframework.loadingmanagement.events.LoaderEvent;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class RefinedLoader extends PlainLoader implements IEquatable, IPriority
	{
		/**
		 * @private
		 */
		private var _currentAttempt:int;
		private var _priority:LoadPriority;
		private var _settings:LoadingAssetSettings;
		private var _status:LoaderStatus;
		private var _statusHistory:IList;
		
		/**
		 * description
		 */
		private var _id:String;
		
		/**
		 * description
		 */
		public function get id(): String { return _id; }
		
		/**
		 * description
		 */
		public function get priority(): int { return _priority.ordinal; }
		
		public function set priority(value:int): void { return; }
		
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
		public function RefinedLoader(id:String, priority:LoadPriority, settings:LoadingAssetSettings)
		{
			if (ReflectionUtil.classPathEquals(this, RefinedLoader))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be instantiated directly.");
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			if (!settings) throw new ArgumentError("Argument <settings> must not be null.");
			
			_id = id;
			_priority = priority;
			_settings = settings;
			_statusHistory = new ArrayList();
			
			setStatus(LoaderStatus.QUEUED);
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		override public final function cancel(): void
		{
			if (_status.equals(LoaderStatus.CANCELED) || _status.equals(LoaderStatus.COMPLETE)) return;
			if (_status.equals(LoaderStatus.FAILED_EXHAUSTED_ATTEMPTS)) return;
			
			setStatus(LoaderStatus.CANCELED);
			doCancel();
		}
		
		override public function dispose():void
		{
			_statusHistory.clear();
			
			_statusHistory = null;
			_settings = null;
			_status = null;
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
		override public final function load(): void
		{
			if (_status.equals(LoaderStatus.FAILED_EXHAUSTED_ATTEMPTS)) throw new IllegalOperationError("The current status is <AssetLoaderStatus.FAILED_EXHAUSTED_ATTEMPTS>, therefore it is no longer allowed loadings.");
			if (_status.equals(LoaderStatus.CANCELED)) throw new IllegalOperationError("The current status is <LoaderStatus.CANCELED>, therefore it is no longer allowed loadings.");
			if (_status.equals(LoaderStatus.COMPLETE)) throw new IllegalOperationError("The current status is <LoaderStatus.COMPLETE>, therefore it is no longer allowed loadings.");
			if (_status.equals(LoaderStatus.LOADING)) throw new IllegalOperationError("The current status is <LoaderStatus.LOADING>, therefore it is not allowed to start a new loading right now.");
			if (_status.equals(LoaderStatus.TRYING_TO_CONNECT)) throw new IllegalOperationError("The current status is <LoaderStatus.TRYING_TO_CONNECT>, therefore it is not allowed to start a new loading right now.");
			
			_currentAttempt++;
			
			if (isExhaustedAttempts())
			{
				setStatus(LoaderStatus.FAILED_EXHAUSTED_ATTEMPTS);
				return;
			}
			
			setStatus(LoaderStatus.TRYING_TO_CONNECT);
			doLoad();
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		override public final function stop(): void
		{
			if (_status.equals(LoaderStatus.STOPPED) ||
				_status.equals(LoaderStatus.CANCELED) ||
				_status.equals(LoaderStatus.COMPLETE) ||
				_status.equals(LoaderStatus.FAILED_EXHAUSTED_ATTEMPTS))
			{
				return;
			}
			
			if (_status.equals(LoaderStatus.TRYING_TO_CONNECT) || _status.equals(LoaderStatus.LOADING))
			{
				_currentAttempt--;
			}
			
			setStatus(LoaderStatus.STOPPED);
			doStop();
		}
		
		override public function toString():String
		{
			return "[" + ReflectionUtil.getClassName(this) + " id <" + id + ">]";
		}
		
		protected function loadingStarted():void
		{
			setStatus(LoaderStatus.LOADING);
		}
		
		protected function loadingComplete():void
		{
			setStatus(LoaderStatus.COMPLETE);
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
		
		protected final function setStatus(status:LoaderStatus):void
		{
			_status = status;
			_statusHistory.add(_status);
			dispatchEvent(new LoaderEvent(LoaderEvent.STATUS_CHANGED, _status));
		}
		
		/**
		 * @private
		 */
		private function isExhaustedAttempts():Boolean
		{
			return _currentAttempt > _settings.policy.maxAttempts;
		}

	}

}