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
	import org.vostokframework.loadingmanagement.domain.events.LoadingAlgorithmErrorEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoadingAlgorithmEvent;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.getTimer;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoaderAlgorithm extends LoadingAlgorithm
	{
		/**
		 * @private
 		 */
		private var _context:LoaderContext;
		private var _loader:Loader;
		private var _request:URLRequest;
		private var _timeConnectionStarted:int;
		
		override public function get openedConnections():int
		{
			validateDisposal();
			
			if (isLoading)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function LoaderAlgorithm(loader:Loader, request:URLRequest, context:LoaderContext = null)
		{
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			if (!request) throw new ArgumentError("Argument <request> must not be null.");
			
			_loader = loader;
			_request = request;
			_context = context;
		}
		//TODO:implementar ProgressEvent.PROGRESS
		/**
		 * description
		 */
		override protected function doCancel(): void
		{
			validateDisposal();
			removeFileLoaderListeners();
			
			try
			{
				_loader.close();
			}
			catch (error:Error)
			{
				throw error;
			}
			finally
			{
				_loader.unload();
			}
		}
		
		/**
		 * description
		 */
		override protected function doLoad(): void
		{
			validateDisposal();
			
			dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING));
			_timeConnectionStarted = getTimer();
			addFileLoaderListeners();
			
			try
			{
				_loader.load(_request, _context);
			}
			catch (error:SecurityError)
			{
				dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, error.message));
			}
			catch (error:IOError)
			{
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, error.message));
			}
			catch (error:Error)
			{
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, error.message));
			}
		}
		
		/**
		 * description
		 */
		override protected function doStop():void
		{
			validateDisposal();
			
			try
			{
				_loader.close();
			}
			catch (error:Error)
			{
				throw error;
			}
			finally
			{
				_loader.unload();
			}
		}
		
		/**
		 * @private
		 */
		override protected function doDispose():void
		{
			try
			{
				_loader.close();
			}
			catch (error:Error)
			{
				//do nothing
			}
			finally
			{
				_loader.unload();
			}
			
			_loader = null;
			_request = null;
			_context = null;
		}
		
		private function addFileLoaderListeners():void
		{
			validateDisposal();
			
			_loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(Event.OPEN, openHandler, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
		}
		
		private function complete():void
		{
			validateDisposal();
			removeFileLoaderListeners();
			
			try
			{
				var data:DisplayObject = _loader.content;
				dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.COMPLETE, data));
			}
			catch (error:SecurityError)
			{
				dispatchEvent(new LoadingAlgorithmErrorEvent(LoadingAlgorithmErrorEvent.SECURITY_ERROR, false, false, error.message));
			}
			catch (error:Error)
			{
				dispatchEvent(new LoadingAlgorithmErrorEvent(LoadingAlgorithmErrorEvent.UNKNOWN_ERROR, false, false, error.message));
			}
		}
		
		private function completeHandler(event:Event):void
		{
			complete();
		}
		
		private function initHandler(event:Event):void
		{
			validateDisposal();
			
			try
			{
				var data:DisplayObject = _loader.content;
				dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.INIT, data));
			}
			catch (error:SecurityError)
			{
				dispatchEvent(new LoadingAlgorithmErrorEvent(LoadingAlgorithmErrorEvent.SECURITY_ERROR, false, false, error.message));
			}
			catch (error:Error)
			{
				dispatchEvent(new LoadingAlgorithmErrorEvent(LoadingAlgorithmErrorEvent.UNKNOWN_ERROR, false, false, error.message));
			}
		}
		
		private function openHandler(event:Event):void
		{
			validateDisposal();
			
			try
			{
				var latency:int = getTimer() - _timeConnectionStarted;
				var data:DisplayObject = _loader.content;
				
				dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.OPEN, data, latency));
			}
			catch (error:SecurityError)
			{
				dispatchEvent(new LoadingAlgorithmErrorEvent(LoadingAlgorithmErrorEvent.SECURITY_ERROR, false, false, error.message));
			}
			catch (error:Error)
			{
				dispatchEvent(new LoadingAlgorithmErrorEvent(LoadingAlgorithmErrorEvent.UNKNOWN_ERROR, false, false, error.message));
			}
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
			validateDisposal();
			dispatchEvent(new LoadingAlgorithmErrorEvent(LoadingAlgorithmErrorEvent.IO_ERROR, false, false, event.text));
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			validateDisposal();
			dispatchEvent(new LoadingAlgorithmErrorEvent(LoadingAlgorithmErrorEvent.SECURITY_ERROR, false, false, event.text));
		}
		
		private function removeFileLoaderListeners():void
		{
			validateDisposal();
			
			_loader.contentLoaderInfo.removeEventListener(Event.INIT, initHandler, false);
			_loader.contentLoaderInfo.removeEventListener(Event.OPEN, openHandler, false);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler, false);
			_loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false);
			_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false);
		}

	}

}