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
package org.vostokframework.loadingmanagement.assetloaders
{
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3coreaddendum.system.IDisposable;
	import org.as3coreaddendum.system.IEquatable;
	import org.as3coreaddendum.system.IPriority;
	import org.as3utils.ReflectionUtil;
	import org.as3utils.StringUtil;
	import org.vostokframework.assetmanagement.AssetLoadingPriority;
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;
	import org.vostokframework.loadingmanagement.events.AssetLoaderEvent;
	import org.vostokframework.loadingmanagement.events.FileLoaderEvent;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AbstractAssetLoader extends EventDispatcher implements IEquatable, IDisposable, IPriority
	{
		/**
		 * @private
		 */
		private var _currentAttempt:int;
		private var _failDescription:String;
		private var _fileLoader:IFileLoader;
		private var _historicalStatus:IList;
		private var _id:String;
		//private var _monitor:ILoadingMonitor;
		private var _priority:AssetLoadingPriority;
		private var _settings:LoadingAssetSettings;
		private var _status:AssetLoaderStatus;

		/**
		 * description
		 */
		public function get historicalStatus(): IList { return new ReadOnlyArrayList(_historicalStatus.toArray()); }
		
		/**
		 * description
		 */
		public function get id(): String { return _id; }
		
		/**
		 * description
		 */
		//public function get monitor(): ILoadingMonitor { return _monitor; }
		
		/**
		 * description
		 */
		public function get priority(): int { return _priority.ordinal; }
		
		public function set priority(value:int): void { return; }
		
		/**
		 * description
		 */
		public function get status(): AssetLoaderStatus { return _status; }

		/**
		 * description
		 * 
		 * @param asset
		 * @param fileLoader
		 */
		public function AbstractAssetLoader(id:String, priority:AssetLoadingPriority, fileLoader:IFileLoader, settings:LoadingAssetSettings): void
		{
			//if (ReflectionUtil.classPathEquals(this, AbstractAssetLoader))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be instantiated directly.");
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			if (!fileLoader) throw new ArgumentError("Argument <fileLoader> must not be null.");
			if (!settings) throw new ArgumentError("Argument <settings> must not be null.");
			
			_id = id;
			_fileLoader = fileLoader;
			_priority = priority;
			_settings = settings;
			_historicalStatus = new ArrayList();
			
			setStatus(AssetLoaderStatus.QUEUED);
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function cancel(): void
		{
			if (_status.equals(AssetLoaderStatus.CANCELED) || _status.equals(AssetLoaderStatus.COMPLETE)) return;
			if (_status.equals(AssetLoaderStatus.FAILED_EXHAUSTED_ATTEMPTS)) return;
			
			setStatus(AssetLoaderStatus.CANCELED);
			removeFileLoaderListeners();
			
			try
			{
				_fileLoader.cancel();
			}
			catch (error:Error)
			{
				//do nothing
			}
		}
		
		public function dispose():void
		{
			removeFileLoaderListeners();
			_fileLoader.dispose();
			_historicalStatus.clear();
			//_monitor.dispose();
			
			_fileLoader = null;
			_historicalStatus = null;
			//_monitor = null;
			_settings = null;
			_status = null;
		}
		
		public function equals(other : *): Boolean
		{
			if (this == other) return true;
			if (!(other is AbstractAssetLoader)) return false;
			
			var otherLoader:AbstractAssetLoader = other as AbstractAssetLoader;
			return _id == otherLoader.id;
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function load(): Boolean
		{
			if (_status.equals(AssetLoaderStatus.FAILED_EXHAUSTED_ATTEMPTS)) throw new IllegalOperationError("The current status is <AssetLoaderStatus.FAILED_EXHAUSTED_ATTEMPTS>, therefore it is no longer allowed loadings.");
			if (_status.equals(AssetLoaderStatus.CANCELED)) throw new IllegalOperationError("The current status is <AssetLoaderStatus.CANCELED>, therefore it is no longer allowed loadings.");
			if (_status.equals(AssetLoaderStatus.COMPLETE)) throw new IllegalOperationError("The current status is <AssetLoaderStatus.COMPLETE>, therefore it is no longer allowed loadings.");
			if (_status.equals(AssetLoaderStatus.LOADING)) throw new IllegalOperationError("The current status is <AssetLoaderStatus.LOADING>, therefore it is not allowed to start a new loading right now.");
			if (_status.equals(AssetLoaderStatus.TRYING_TO_CONNECT)) throw new IllegalOperationError("The current status is <AssetLoaderStatus.TRYING_TO_CONNECT>, therefore it is not allowed to start a new loading right now.");
			
			_currentAttempt++;
			
			if (isExhaustedAttempts())
			{
				setStatus(AssetLoaderStatus.FAILED_EXHAUSTED_ATTEMPTS);
				return false;
			}
			trace("AbstractAssetLoader() - load()");
			setStatus(AssetLoaderStatus.TRYING_TO_CONNECT);
			addFileLoaderListeners();
			_fileLoader.load();
			
			return true;
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function stop(): void
		{
			if (_status.equals(AssetLoaderStatus.STOPPED) ||
				_status.equals(AssetLoaderStatus.CANCELED) ||
				_status.equals(AssetLoaderStatus.COMPLETE) ||
				_status.equals(AssetLoaderStatus.FAILED_EXHAUSTED_ATTEMPTS))
			{
				return;
			}
			
			if (_status.equals(AssetLoaderStatus.TRYING_TO_CONNECT) || _status.equals(AssetLoaderStatus.LOADING))
			{
				_currentAttempt--;
			}
			
			setStatus(AssetLoaderStatus.STOPPED);
			
			try
			{
				_fileLoader.stop();
			}
			catch (error:Error)
			{
				//do nothing
			}
		}
		
		override public function toString():String
		{
			return "[" + ReflectionUtil.getClassName(this) + " id<" + id + ">]";
		}
		
		private function fileLoaderOpenHandler(event:Event):void
		{
			loadingStarted();
		}
		
		private function fileLoaderCompleteHandler(event:FileLoaderEvent):void
		{
			loadingComplete();
		}
		
		private function fileLoaderIOErrorHandler(event:IOErrorEvent):void
		{
			ioError(event);
		}
		
		private function fileLoaderSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			securityError(event);
		}
		
		private function loadingStarted():void
		{
			setStatus(AssetLoaderStatus.LOADING);
		}
		
		private function loadingComplete():void
		{
			setStatus(AssetLoaderStatus.COMPLETE);
			removeFileLoaderListeners();
		}
		
		private function ioError(event:IOErrorEvent):void
		{
			setStatus(AssetLoaderStatus.FAILED_IO_ERROR);
			_failDescription = event.text;
		}
		
		private function securityError(event:SecurityErrorEvent):void
		{
			setStatus(AssetLoaderStatus.FAILED_SECURITY_ERROR);
			_failDescription = event.text;
		}

		private function addFileLoaderListeners():void
		{
			trace("AbstractAssetLoader() - addFileLoaderListeners()");
			
			_fileLoader.addEventListener(Event.OPEN, fileLoaderOpenHandler, false, 0, true);
			_fileLoader.addEventListener(FileLoaderEvent.COMPLETE, fileLoaderCompleteHandler, false, 0, true);
			_fileLoader.addEventListener(IOErrorEvent.IO_ERROR, fileLoaderIOErrorHandler, false, 0, true);
			_fileLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fileLoaderSecurityErrorHandler, false, 0, true);
		}
		
		private function removeFileLoaderListeners():void
		{
			trace("AbstractAssetLoader() - removeFileLoaderListeners()");
			
			_fileLoader.removeEventListener(Event.OPEN, fileLoaderOpenHandler, false);
			_fileLoader.removeEventListener(FileLoaderEvent.COMPLETE, fileLoaderCompleteHandler, false);
			_fileLoader.removeEventListener(IOErrorEvent.IO_ERROR, fileLoaderIOErrorHandler, false);
			_fileLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, fileLoaderSecurityErrorHandler, false);
		}
		
		private function isExhaustedAttempts():Boolean
		{
			return _currentAttempt > _settings.policy.maxAttempts;
		}
		/*
		private function isStatusFailed():Boolean
		{
			return _status.equals(AssetLoaderStatus.FAILED_ASYNC_ERROR) ||
					_status.equals(AssetLoaderStatus.FAILED_IO_ERROR) ||
					_status.equals(AssetLoaderStatus.FAILED_LATENCY_TIMEOUT) ||
					_status.equals(AssetLoaderStatus.FAILED_SECURITY_ERROR) ||
					_status.equals(AssetLoaderStatus.FAILED_UNKNOWN_ERROR);
		}
		*/
		private function setStatus(status:AssetLoaderStatus):void
		{
			_status = status;
			_historicalStatus.add(_status);
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.STATUS_CHANGED, _status));
		}

	}

}