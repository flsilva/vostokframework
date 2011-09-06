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
package org.vostokframework.domain.loading.states.fileloader
{
	import org.vostokframework.domain.loading.ILoaderStateTransition;
	import org.vostokframework.domain.loading.events.LoaderErrorEvent;
	import org.vostokframework.domain.loading.events.LoaderEvent;

	import flash.events.ProgressEvent;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingFileLoader extends FileLoaderState
	{
		
		override public function get isLoading():Boolean { return true; }
		
		override public function get openedConnections():int { return 1; }
		
		//TODO:note: explain that this object starts its logic as soon as it is instanciated
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function LoadingFileLoader(loader:ILoaderStateTransition, algorithm:IFileLoadingAlgorithm)
		{
			super(algorithm);
			
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
		}
		
		private function addAlgorithmListeners():void
		{
			algorithm.addEventListener(FileLoadingAlgorithmEvent.COMPLETE, completeHandler, false, 0, true);
			algorithm.addEventListener(FileLoadingAlgorithmEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			algorithm.addEventListener(FileLoadingAlgorithmEvent.INIT, initHandler, false, 0, true);
			algorithm.addEventListener(FileLoadingAlgorithmErrorEvent.FAILED, failedHandler, false, 0, true);
			algorithm.addEventListener(FileLoadingAlgorithmEvent.OPEN, openHandler, false, 0, true);
			algorithm.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
		}
		
		private function removeAlgorithmListeners():void
		{
			algorithm.removeEventListener(FileLoadingAlgorithmEvent.COMPLETE, completeHandler, false);
			algorithm.removeEventListener(FileLoadingAlgorithmEvent.HTTP_STATUS, httpStatusHandler, false);
			algorithm.removeEventListener(FileLoadingAlgorithmEvent.INIT, initHandler, false);
			algorithm.removeEventListener(FileLoadingAlgorithmErrorEvent.FAILED, failedHandler, false);
			algorithm.removeEventListener(FileLoadingAlgorithmEvent.OPEN, openHandler, false);
			algorithm.removeEventListener(ProgressEvent.PROGRESS, progressHandler, false);
		}
		
		private function _load():void
		{
			validateDisposal();
			
			addAlgorithmListeners();
			algorithm.load();
		}
		
		////////////////////////////////////////////////////////////////////////
		////////////////////////// ALGORITHM LISTENERS /////////////////////////
		////////////////////////////////////////////////////////////////////////
		
		private function completeHandler(event:FileLoadingAlgorithmEvent):void
		{
			validateDisposal();
			removeAlgorithmListeners();
			
			loader.setState(new CompleteFileLoader(loader, algorithm));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, event.data));
			dispose();
		}
		
		private function failedHandler(event:FileLoadingAlgorithmErrorEvent):void
		{
			validateDisposal();
			removeAlgorithmListeners();
			
			loader.setState(new FailedFileLoader(loader, algorithm));
			loader.dispatchEvent(new LoaderErrorEvent(LoaderErrorEvent.FAILED, event.errors));
			dispose();
		}
		
		private function httpStatusHandler(event:FileLoadingAlgorithmEvent):void
		{
			validateDisposal();
			
			var $event:LoaderEvent = new LoaderEvent(LoaderEvent.HTTP_STATUS);
			$event.httpStatus = event.httpStatus;
			
			loader.dispatchEvent($event);
		}
		
		private function initHandler(event:FileLoadingAlgorithmEvent):void
		{
			validateDisposal();
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.INIT, event.data));
		}
		
		private function openHandler(event:FileLoadingAlgorithmEvent):void
		{
			validateDisposal();
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.OPEN, event.data, event.latency));
		}
		//TODO:pensar sobre criar LoaderEvent.PROGRESS
		//ja esta redisparando aqui
		//nao muda muito criar um novo evento e a clonagem interna do player para redisparar
		private function progressHandler(event:ProgressEvent):void
		{
			loader.dispatchEvent(event);
		}
		
	}

}