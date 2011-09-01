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
package org.vostokframework.loadingmanagement.domain.states.fileloader
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.IListMap;
	import org.as3collections.maps.ArrayListMap;
	import org.as3collections.maps.TypedListMap;
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.vostokframework.loadingmanagement.domain.IDataParser;
	import org.vostokframework.loadingmanagement.domain.LoadError;

	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.getTimer;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class FileLoadingAlgorithm extends EventDispatcher implements IFileLoadingAlgorithm
	{
		/**
		 * @private
 		 */
		//private var _dispatcher:IEventDispatcher;
		private var _disposed:Boolean;
		private var _errors:IListMap;//<LoadError, String> - where String is the original Flash Player error message
		private var _dataLoader:NativeDataLoader;
		private var _parsers:IList;
		private var _timeConnectionStarted:int;
		
		/**
		 * description
		 * 
		 */
		public function FileLoadingAlgorithm(dataLoader:NativeDataLoader)
		{
			if (!dataLoader) throw new ArgumentError("Argument <dataLoader> must not be null.");
			
			_dataLoader = dataLoader;
			_errors = new TypedListMap(new ArrayListMap(), LoadError, String);
		}
		
		override public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			validateDisposal();
			
			if (type == ProgressEvent.PROGRESS)
			{
				_dataLoader.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
			else
			{
				super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		
		public function addParsers(parsers:IList):void
		{
			validateDisposal();
			_parsers = parsers;
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function cancel(): void
		{
			validateDisposal();
			_dataLoader.cancel();
		}
		
		override public function dispatchEvent(event : Event) : Boolean
		{
			validateDisposal();
			
			if (event.type == ProgressEvent.PROGRESS)
			{
				return _dataLoader.dispatchEvent(event);
			}
			else
			{
				return super.dispatchEvent(event);
			}
		}
		
		public function dispose():void
		{
			if (_disposed) return;
			
			removeDataLoaderListeners();
			_dataLoader.dispose();
			
			_dataLoader = null;
			_disposed = true;
			//_dataLoader = null;
			_errors = null;
			_parsers = null;
		}
		
		override public function hasEventListener(type : String) : Boolean
		{
			validateDisposal();

			if (type == ProgressEvent.PROGRESS)
			{
				return _dataLoader.hasEventListener(type);
			}
			else
			{
				return super.hasEventListener(type);
			}
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function load(): void
		{
			validateDisposal();
			
			addDataLoaderListeners();
			_timeConnectionStarted = getTimer();
			
			try
			{
				_dataLoader.load();
			}
			catch (error:SecurityError)
			{
				securityError(error.message);
			}
			catch (error:IOError)
			{
				ioError(error.message);
			}
			catch (error:UnsupportedOperationError)
			{
				throw error;
			}
			catch (error:Error)
			{
				unknownError(error.message);
			}
		}
		
		override public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			validateDisposal();
			
			if (type == ProgressEvent.PROGRESS)
			{
				_dataLoader.removeEventListener(type, listener, useCapture);
			}
			else
			{
				super.removeEventListener(type, listener, useCapture);
			}
		}
		
		/**
		 * description
		 */
		public function stop(): void
		{
			validateDisposal();
			_dataLoader.stop();
		}
		
		override public function willTrigger(type : String) : Boolean
		{
			validateDisposal();
			
			if (type == ProgressEvent.PROGRESS)
			{
				return _dataLoader.willTrigger(type);
			}
			else
			{
				return super.willTrigger(type);
			}
		}
		
		protected function parseData(rawData:*):*
		{
			validateDisposal();
			
			if (!rawData) return null;
			if (!_parsers) return rawData;
			
			var it:IIterator = _parsers.iterator();
			var parser:IDataParser;
			var parsedData:* = rawData;
			
			while (it.hasNext())
			{
				parser = it.next();
				parsedData = parser.parse(parsedData);
			}
			
			return parsedData;
		}
		/*
		protected function setLoadingDispatcher(dispatcher:IEventDispatcher):void
		{
			if (!dispatcher) throw new ArgumentError("Argument <dispatcher> must not be null.");
			//_dispatcher = dispatcher;
		}
		*/
		private function addDataLoaderListeners():void
		{
			_dataLoader.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			_dataLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			_dataLoader.addEventListener(Event.INIT, initHandler, false, 0, true);
			_dataLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			_dataLoader.addEventListener(Event.OPEN, openHandler, false, 0, true);
			_dataLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			_dataLoader.addEventListener(ErrorEvent.ERROR, unknownErrorHandler, false, 0, true);
		}
		
		private function failed(error:LoadError, errorMessage:String):void
		{
			validateDisposal();
			removeDataLoaderListeners();
			
			_errors.put(error, errorMessage);
			dispatchEvent(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, _errors));
		}
		
		private function getData():*
		{
			validateDisposal();
			return parseData(_dataLoader.getData());
		}
		
		private function loadingComplete():void
		{
			validateDisposal();
			removeDataLoaderListeners();
			
			try
			{
				var data:* = getData();
				dispatchEvent(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.COMPLETE, data));
			}
			catch (error:SecurityError)
			{
				securityError(error.message);
			}
			catch (error:Error)
			{
				unknownError(error.message);
			}
		}
		
		private function loadingInit():void
		{
			validateDisposal();
			
			try
			{
				var data:* = getData();
				dispatchEvent(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.INIT, data));
			}
			catch (error:SecurityError)
			{
				securityError(error.message);
			}
			catch (error:Error)
			{
				unknownError(error.message);
			}
		}
		
		private function loadingOpen():void
		{
			validateDisposal();
			
			var latency:int = getTimer() - _timeConnectionStarted;
			
			try
			{
				var data:* = getData();
				dispatchEvent(new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.OPEN, data, latency));
			}
			catch (error:SecurityError)
			{
				securityError(error.message);
			}
			catch (error:Error)
			{
				unknownError(error.message);
			}
		}
		
		private function ioError(errorMessage:String):void
		{
			validateDisposal();
			failed(LoadError.IO_ERROR, errorMessage);
		}
		
		private function securityError(errorMessage:String):void
		{
			validateDisposal();
			failed(LoadError.SECURITY_ERROR, errorMessage);
		}
		
		private function unknownError(errorMessage:String):void
		{
			validateDisposal();
			failed(LoadError.UNKNOWN_ERROR, errorMessage);
		}
		
		private function removeDataLoaderListeners():void
		{
			_dataLoader.removeEventListener(Event.COMPLETE, completeHandler, false);
			_dataLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false);
			_dataLoader.removeEventListener(Event.INIT, initHandler, false);
			_dataLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false);
			_dataLoader.removeEventListener(Event.OPEN, openHandler, false);
			_dataLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false);
			_dataLoader.removeEventListener(ErrorEvent.ERROR, unknownErrorHandler, false);
		}
		
		/**
		 * @private
		 */
		private function validateDisposal():void
		{
			if (_disposed) throw new ObjectDisposedError("This object was disposed, therefore no more operations can be performed.");
		}
		
		////////////////////////////////////////////////////////////////////////
		///////////////////////// DISPATCHER LISTENERS /////////////////////////
		////////////////////////////////////////////////////////////////////////
		
		private function completeHandler(event:Event):void
		{
			loadingComplete();
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			var $event:FileLoadingAlgorithmEvent = new FileLoadingAlgorithmEvent(FileLoadingAlgorithmEvent.HTTP_STATUS);
			$event.httpStatus = event.status;
			
			dispatchEvent($event);
		}
		
		private function initHandler(event:Event):void
		{
			validateDisposal();
			loadingInit();
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			ioError(event.text);
		}
		
		private function openHandler(event:Event):void
		{
			validateDisposal();
			loadingOpen();
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			securityError(event.text);
		}
		
		private function unknownErrorHandler(event:ErrorEvent):void
		{
			unknownError(event.text);
		}

	}

}