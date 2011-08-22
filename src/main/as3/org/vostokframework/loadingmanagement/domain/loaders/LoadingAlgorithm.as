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
package org.vostokframework.loadingmanagement.domain.loaders
{
	import org.as3collections.ICollection;
	import org.as3collections.IMap;
	import org.as3collections.maps.ArrayListMap;
	import org.as3collections.maps.TypedMap;
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3coreaddendum.system.IDisposable;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.LoadError;
	import org.vostokframework.loadingmanagement.domain.LoaderState;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.events.LoadingAlgorithmErrorEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoadingAlgorithmEvent;

	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingAlgorithm extends EventDispatcher implements IDisposable
	{
		/**
		 * @private
 		 */
		private var _disposed:Boolean;
		private var _errors:IMap;//<LoadError, String> - where String is the original Flash Player error message
		private var _isLoading:Boolean;
		private var _loaderDispatcher:IEventDispatcher;
		private var _maxAttempts:int;
		private var _performedAttempts:int;
		
		/**
		 * @private
 		 */
		protected function get isLoading():Boolean { return _isLoading; }
		protected function set isLoading(value:Boolean):void { _isLoading = value; }
		
		/**
		 * @private
 		 */
		protected function get loaderDispatcher():IEventDispatcher { return _loaderDispatcher; }
		protected function set loaderDispatcher(value:IEventDispatcher):void { _loaderDispatcher = value; }
		
		public function get openedConnections():int
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 * 
		 */
		public function LoadingAlgorithm (maxAttempts:int = 1)
		{
			if (ReflectionUtil.classPathEquals(this, LoadingAlgorithm))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be directly instantiated.");
			if (maxAttempts < 1) throw new ArgumentError("Argument <maxAttempts> must be greater than zero. Received: <" + maxAttempts + ">");
			
			_maxAttempts = maxAttempts;
			_errors = new TypedMap(new ArrayListMap(), LoadError, String);
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 */
		public function addLoader(loader:VostokLoader): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 * 
		 * @param loaders
		 */
		public function addLoaders(loaders:ICollection): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function cancel(): void
		{
			validateDisposal();
			
			_isLoading = false;
			removeLoaderDispatcherListeners();
			doCancel();
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
			
			removeLoaderDispatcherListeners();
			doDispose();
			_disposed = true;
		}
		
		public function getLoader(identification:VostokIdentification): VostokLoader
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function getLoaderState(identification:VostokIdentification): LoaderState
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 * 
		 * @param identification
		 */
		public function getParent(context:VostokLoader, identification:VostokIdentification): VostokLoader
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function load(): void
		{
			validateDisposal();
			
			/*if (isExaustedAttempts())
			{
				var errorMessage:String = "This object has reached its attempt limit.\n";
				errorMessage += "<maxAttempts>: " + _maxAttempts;
				errorMessage += "<performedAttempts>: " + _performedAttempts;
				
				throw new IllegalOperationError(errorMessage);
			}*/
			
			if (isExaustedAttempts())
			{
				failed();
				return;
			}
			
			_isLoading = true;
			addLoaderDispatcherListeners();
			dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING));
			doLoad();//TODO:implementar delay inicial e de erro
		}
		
		public function removeLoader(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function resumeLoader(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function stopLoader(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 */
		public function stop(): void
		{
			validateDisposal();
			
			_isLoading = false;
			removeLoaderDispatcherListeners();
			doStop();
		}
		
		/**
		 * @private
		 */
		protected function doCancel():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * @private
		 */
		protected function doDispose():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * @private
		 */
		protected function doLoad():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * @private
		 */
		protected function doStop():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function loadingComplete():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function loadingInit():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function loadingOpen():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function ioError(errorMessage:String):void
		{
			validateDisposal();
			error(LoadError.IO_ERROR, errorMessage);
		}
		
		protected function securityError(errorMessage:String):void
		{
			validateDisposal();
			error(LoadError.SECURITY_ERROR, errorMessage);
		}
		
		protected function unknownError(errorMessage:String):void
		{
			validateDisposal();
			error(LoadError.UNKNOWN_ERROR, errorMessage);
		}
		
		/**
		 * @private
		 */
		protected function validateDisposal():void
		{
			if (_disposed) throw new ObjectDisposedError("This object was disposed, therefore no more operations can be performed.");
		}
		
		private function addLoaderDispatcherListeners():void
		{
			if (!_loaderDispatcher) return;
			
			_loaderDispatcher.addEventListener(Event.INIT, initHandler, false, 0, true);
			_loaderDispatcher.addEventListener(Event.OPEN, openHandler, false, 0, true);
			_loaderDispatcher.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			_loaderDispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			_loaderDispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			_loaderDispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			_loaderDispatcher.addEventListener(ErrorEvent.ERROR, unknownErrorHandler, false, 0, true);
		}
		
		private function completeHandler(event:Event):void
		{
			validateDisposal();
			removeLoaderDispatcherListeners();
			loadingComplete();
		}
		
		private function error(error:LoadError, errorMessage:String):void
		{
			validateDisposal();
			
			_performedAttempts++;
			_errors.put(error, errorMessage);
			
			// IF IT'S A SECURITY ERROR
			// IT DOES NOT USE ATTEMPTS TO TRY AGAIN
			if (error.equals(LoadError.SECURITY_ERROR))
			{
				failed();
				return;
			}
			else
			{
				load();
			}
		}
		
		private function failed():void
		{
			validateDisposal();
			_isLoading = false;
			dispatchEvent(new LoadingAlgorithmErrorEvent(LoadingAlgorithmErrorEvent.FAILED, _errors));
		}
		
		private function initHandler(event:Event):void
		{
			validateDisposal();
			loadingInit();
		}
		
		private function isExaustedAttempts():Boolean
		{
			return _performedAttempts >= _maxAttempts;
		}

		private function openHandler(event:Event):void
		{
			validateDisposal();
			loadingOpen();
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			validateDisposal();
			
			var $event:LoadingAlgorithmEvent = new LoadingAlgorithmEvent(LoadingAlgorithmEvent.HTTP_STATUS);
			$event.httpStatus = event.status;
			
			dispatchEvent($event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			ioError(event.text);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			securityError(event.text);
		}
		
		private function unknownErrorHandler(event:ErrorEvent):void
		{
			unknownError(event.text);
		}
		
		private function removeLoaderDispatcherListeners():void
		{
			if (!_loaderDispatcher) return;
			
			_loaderDispatcher.removeEventListener(Event.INIT, initHandler, false);
			_loaderDispatcher.removeEventListener(Event.OPEN, openHandler, false);
			_loaderDispatcher.removeEventListener(Event.COMPLETE, completeHandler, false);
			_loaderDispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false);
			_loaderDispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false);
			_loaderDispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false);
			_loaderDispatcher.removeEventListener(ErrorEvent.ERROR, unknownErrorHandler, false);
		}

	}

}