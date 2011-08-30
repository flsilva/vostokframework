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
	import org.as3collections.IMap;
	import org.as3collections.maps.ArrayListMap;
	import org.as3collections.maps.TypedMap;
	import org.vostokframework.loadingmanagement.domain.ILoaderStateTransition;
	import org.vostokframework.loadingmanagement.domain.LoadError;
	import org.vostokframework.loadingmanagement.domain.events.LoaderErrorEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;

	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
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
	public class LoadingFileLoader extends FileLoaderState
	{
		
		/**
		 * @private
 		 */
		private var _errors:IMap;//<LoadError, String> - where String is the original Flash Player error message
		private var _performedAttempts:int;
		private var _timeConnectionStarted:int;
		
		override public function get isLoading():Boolean { return true; }
		
		override public function get openedConnections():int { return 1; }
		
		//TODO:note: explain that this object starts its logic as soon as it is instanciated
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function LoadingFileLoader(loader:ILoaderStateTransition, algorithm:FileLoadingAlgorithm, maxAttempts:int)
		{
			super(algorithm, maxAttempts);
			
			_errors = new TypedMap(new ArrayListMap(), LoadError, String);
			
			setLoader(loader);
			_load();
		}
		
		override public function load():void
		{
			//do nothing
		}
		
		override protected function doDispose():void
		{
			removeAlgorithmListeners();
			
			_errors = null;
		}
		
		private function addAlgorithmListeners():void
		{
			algorithm.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			algorithm.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			algorithm.addEventListener(Event.INIT, initHandler, false, 0, true);
			algorithm.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			algorithm.addEventListener(Event.OPEN, openHandler, false, 0, true);
			algorithm.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
			algorithm.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			algorithm.addEventListener(ErrorEvent.ERROR, unknownErrorHandler, false, 0, true);
		}
		
		private function error(error:LoadError, errorMessage:String):void
		{
			validateDisposal();
			
			_performedAttempts++;
			_errors.put(error, errorMessage);
			
			// IF IT'S A SECURITY ERROR
			// IT DOES NOT USE ATTEMPTS TO TRY AGAIN
			// IT JUST FAIL
			if (error.equals(LoadError.SECURITY_ERROR))
			{
				failed();
				return;
			}
			else
			{
				_load();
			}
		}
		
		private function failed():void
		{
			validateDisposal();
			removeAlgorithmListeners();
			
			loader.setState(new FailedFileLoader(loader, algorithm, maxAttempts));
			loader.dispatchEvent(new LoaderErrorEvent(LoaderErrorEvent.FAILED, _errors));
			dispose();
		}
		
		private function isExaustedAttempts():Boolean
		{
			return _performedAttempts >= maxAttempts;
		}
		
		private function loadingComplete():void
		{
			validateDisposal();
			removeAlgorithmListeners();
			
			try
			{
				var data:* = algorithm.getData();
				
				loader.setState(new CompleteFileLoader(loader, algorithm, maxAttempts));
				loader.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, data));
				dispose();
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
				var data:* = algorithm.getData();
				loader.dispatchEvent(new LoaderEvent(LoaderEvent.INIT, data));
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
				var data:* = algorithm.getData();
				loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN, data, latency));
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
			error(LoadError.IO_ERROR, errorMessage);
		}
		
		private function securityError(errorMessage:String):void
		{
			validateDisposal();
			error(LoadError.SECURITY_ERROR, errorMessage);
		}
		
		private function unknownError(errorMessage:String):void
		{
			validateDisposal();
			error(LoadError.UNKNOWN_ERROR, errorMessage);
		}
		
		private function removeAlgorithmListeners():void
		{
			algorithm.removeEventListener(Event.COMPLETE, completeHandler, false);
			algorithm.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false);
			algorithm.removeEventListener(Event.INIT, initHandler, false);
			algorithm.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false);
			algorithm.removeEventListener(Event.OPEN, openHandler, false);
			algorithm.removeEventListener(ProgressEvent.PROGRESS, progressHandler, false);
			algorithm.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false);
			algorithm.removeEventListener(ErrorEvent.ERROR, unknownErrorHandler, false);
		}
		
		private function _load():void
		{
			validateDisposal();
			
			if (isExaustedAttempts())
			{
				failed();
				return;
			}
			
			addAlgorithmListeners();
			_timeConnectionStarted = getTimer();
			
			try
			{
				algorithm.load();//TODO:implementar delay (inicial e de erro)
			}
			catch (error:SecurityError)
			{
				securityError(error.message);
			}
			catch (error:IOError)
			{
				ioError(error.message);
			}
			catch (error:Error)
			{
				unknownError(error.message);
			}
		}
		
		////////////////////////////////////////////////////////////////////////
		/////////////////////////// ADAPTER LISTENERS //////////////////////////
		////////////////////////////////////////////////////////////////////////
		
		private function completeHandler(event:Event):void
		{
			loadingComplete();
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			validateDisposal();
			
			var $event:LoaderEvent = new LoaderEvent(LoaderEvent.HTTP_STATUS);
			$event.httpStatus = event.status;
			
			loader.dispatchEvent($event);
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
		
		private function progressHandler(event:ProgressEvent):void
		{
			loader.dispatchEvent(event);
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