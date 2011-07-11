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
	import org.vostokframework.loadingmanagement.domain.LoadError;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.PlainLoader;
	import org.vostokframework.loadingmanagement.domain.StatefulLoader;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;

	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoader extends StatefulLoader
	{
		/**
		 * @private
		 */
		private var _loader:PlainLoader;

		/**
		 * description
		 * 
		 * @param asset
		 * @param fileLoader
		 */
		public function AssetLoader(id:String, priority:LoadPriority, loader:PlainLoader, maxAttempts:int)
		{
			super(id, priority, maxAttempts);
			
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			_loader = loader;
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			validateDisposal();
			
			if (!LoaderEvent.typeBelongs(type))
			{
				_loader.addEventListener(type, listener, useCapture, priority, useWeakReference);
				return;
			}
			
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function hasEventListener(type:String):Boolean
		{
			validateDisposal();
			
			if (!LoaderEvent.typeBelongs(type))
			{
				return _loader.hasEventListener(type);
			}
			
			return super.hasEventListener(type);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			validateDisposal();
			
			if (!LoaderEvent.typeBelongs(type))
			{
				_loader.removeEventListener(type, listener, useCapture);
				return;
			}
			
			super.removeEventListener(type, listener, useCapture);
		}
		
		override public function willTrigger(type:String):Boolean
		{
			validateDisposal();
			
			if (!LoaderEvent.typeBelongs(type))
			{
				return _loader.willTrigger(type);
			}
			
			return super.willTrigger(type);
		}

		/**
		 * @private
 		 */
		override protected function doCancel(): void
		{
			removeFileLoaderListeners();
			
			try
			{
				_loader.cancel();
			}
			catch (error:Error)
			{
				//do nothing
			}
		}
		
		/**
		 * @private
 		 */
		override protected function doDispose():void
		{
			removeFileLoaderListeners();
			_loader.dispose();
			_loader = null;
		}
		
		/**
		 * @private
 		 */
		override protected function doLoad(): void
		{
			addFileLoaderListeners();
			_loader.load();
		}

		/**
		 * @private
 		 */
		override protected function doStop(): void
		{
			try
			{
				_loader.stop();
			}
			catch (error:Error)
			{
				//do nothing
			}
		}
		
		private function addFileLoaderListeners():void
		{
			_loader.addEventListener(LoaderEvent.INIT, loaderInitHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.OPEN, loaderOpenHandler, false, 0, true);
			_loader.addEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false, 0, true);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler, false, 0, true);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderSecurityErrorHandler, false, 0, true);
		}
		
		private function loaderInitHandler(event:LoaderEvent):void
		{
			loadingInit(event.data);
		}
		
		private function loaderOpenHandler(event:LoaderEvent):void
		{
			loadingStarted(event.data, event.latency);
		}
		
		private function loaderCompleteHandler(event:LoaderEvent):void
		{
			removeFileLoaderListeners();
			loadingComplete(event.data);
		}
		
		private function loaderIOErrorHandler(event:IOErrorEvent):void
		{
			error(LoadError.IO_ERROR, event.text);
		}
		
		private function loaderSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			error(LoadError.SECURITY_ERROR, event.text);
		}
		
		private function removeFileLoaderListeners():void
		{
			_loader.removeEventListener(LoaderEvent.INIT, loaderInitHandler, false);
			_loader.removeEventListener(LoaderEvent.OPEN, loaderOpenHandler, false);
			_loader.removeEventListener(LoaderEvent.COMPLETE, loaderCompleteHandler, false);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler, false);
			_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderSecurityErrorHandler, false);
		}
		
	}

}