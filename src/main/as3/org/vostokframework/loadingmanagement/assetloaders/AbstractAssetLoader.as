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
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;
	import org.vostokframework.loadingmanagement.events.FileLoaderEvent;
	import org.vostokframework.loadingmanagement.monitors.ILoadingMonitor;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AbstractAssetLoader implements IEquatable, IDisposable
	{
		/**
		 * @private
		 */
		private var _currentAttempt:int;
		private var _failDescription:String;
		private var _fileLoader:IFileLoader;
		private var _historicalStatus:IList;
		private var _id:String;
		private var _monitor:ILoadingMonitor;
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
		public function get monitor(): ILoadingMonitor { return _monitor; }

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
		public function AbstractAssetLoader(id:String, fileLoader:IFileLoader, settings:LoadingAssetSettings): void
		{
			//if (ReflectionUtil.classPathEquals(this, AbstractAssetLoader))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be instantiated directly.");
			if (!fileLoader) throw new ArgumentError("Argument <fileLoader> must not be null.");
			if (!settings) throw new ArgumentError("Argument <settings> must not be null.");
			
			_id = id;
			_fileLoader = fileLoader;
			_settings = settings;
			_currentAttempt = 1;
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
			if (_status == AssetLoaderStatus.CANCELED) return;
			if (isExhaustedAttempts()) return;
			
			setStatus(AssetLoaderStatus.CANCELED);
			cancelFileLoader();
		}
		
		public function dispose():void
		{
			_fileLoader.dispose();
			_historicalStatus.clear();
			_monitor.dispose();
			
			_fileLoader = null;
			_historicalStatus = null;
			_monitor = null;
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
			/*
			//if (!_policy.allowLoading())
			if (_currentAttempt > _settings.policy.maxAttempts)
			{
				setStatus(AssetLoaderStatus.FAILED);
				_failDescription = "EXHAUSTED ATTEMPTS";//FAIL_DESCRIPTION_EXHAUSTED_ATTEMPTS
				return false;
			}
			*/
			
			//if (_currentAttempt > _settings.policy.maxAttempts) return false;
			
			if (_status == AssetLoaderStatus.CANCELED) throw new IllegalOperationError("The current status is <AssetLoaderStatus.CANCELED>, therefore it is no longer allowed loadings.");
			if (_status == AssetLoaderStatus.COMPLETE) throw new IllegalOperationError("The current status is <AssetLoaderStatus.COMPLETE>, therefore it is no longer allowed loadings.");
			if (_status == AssetLoaderStatus.LOADING) throw new IllegalOperationError("The current status is <AssetLoaderStatus.LOADING>, therefore it is not allowed to start a new loading right now.");
			if (_status == AssetLoaderStatus.TRYING_TO_CONNECT) throw new IllegalOperationError("The current status is <AssetLoaderStatus.TRYING_TO_CONNECT>, therefore it is not allowed to start a new loading right now.");
			
			if (isExhaustedAttempts()) return false;
			
			_currentAttempt++;
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
			if (_status == AssetLoaderStatus.STOPPED) return;
			if (isExhaustedAttempts()) return;
			
			if (_status == AssetLoaderStatus.TRYING_TO_CONNECT || _status == AssetLoaderStatus.LOADING)
			{
				_currentAttempt--;
			}
			
			//if the status is AssetLoaderStatus.CANCELED,
			//AssetLoaderStatus.COMPLETED or AssetLoaderStatus.FAILED
			//then do nothing
			
			setStatus(AssetLoaderStatus.STOPPED);
			stopFileLoader();
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
			setStatus(AssetLoaderStatus.FAILED);
			_failDescription = event.text;
		}
		
		private function securityError(event:SecurityErrorEvent):void
		{
			setStatus(AssetLoaderStatus.FAILED);
			_failDescription = event.text;
		}

		private function addFileLoaderListeners():void
		{
			_fileLoader.addEventListener(Event.OPEN, fileLoaderOpenHandler, false, 0, true);
			_fileLoader.addEventListener(FileLoaderEvent.COMPLETE, fileLoaderCompleteHandler, false, 0, true);
			_fileLoader.addEventListener(IOErrorEvent.IO_ERROR, fileLoaderIOErrorHandler, false, 0, true);
			_fileLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fileLoaderSecurityErrorHandler, false, 0, true);
		}
		
		private function removeFileLoaderListeners():void
		{
			_fileLoader.removeEventListener(Event.OPEN, fileLoaderOpenHandler, false);
			_fileLoader.removeEventListener(FileLoaderEvent.COMPLETE, fileLoaderCompleteHandler, false);
			_fileLoader.removeEventListener(IOErrorEvent.IO_ERROR, fileLoaderIOErrorHandler, false);
			_fileLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, fileLoaderSecurityErrorHandler, false);
		}
		
		private function cancelFileLoader():void
		{
			try
			{
				_fileLoader.cancel();
			}
			catch (error:Error)
			{
				//do nothing
			}
		}
		
		private function stopFileLoader():void
		{
			try
			{
				_fileLoader.stop();
			}
			catch (error:Error)
			{
				//do nothing
			}
		}
		
		private function isExhaustedAttempts():Boolean
		{
			return _currentAttempt > _settings.policy.maxAttempts;
		}
		
		private function setStatus(status:AssetLoaderStatus):void
		{
			_status = status;
			_historicalStatus.add(_status);
		}

	}

}