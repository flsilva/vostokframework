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
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;
	import org.vostokframework.loadingmanagement.events.FileLoaderEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoader extends RefinedLoader
	{
		/**
		 * @private
		 */
		private var _failDescription:String;
		private var _loader:PlainLoader;

		/**
		 * description
		 * 
		 * @param asset
		 * @param fileLoader
		 */
		public function AssetLoader(id:String, priority:LoadPriority, loader:PlainLoader, settings:LoadingAssetSettings)
		{
			super(id, priority, settings);
			
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			_loader = loader;
		}
		
		override public function dispose():void
		{
			removeFileLoaderListeners();
			_loader.dispose();
			
			_loader = null;
			
			super.dispose();
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
		
		override protected function loadingComplete():void
		{
			super.loadingComplete();
			removeFileLoaderListeners();
		}
		
		private function addFileLoaderListeners():void
		{
			_loader.addEventListener(Event.OPEN, loaderOpenHandler, false, 0, true);
			_loader.addEventListener(FileLoaderEvent.COMPLETE, loaderCompleteHandler, false, 0, true);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler, false, 0, true);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderSecurityErrorHandler, false, 0, true);
		}
		
		private function loaderOpenHandler(event:Event):void
		{
			loadingStarted();
		}
		
		private function loaderCompleteHandler(event:FileLoaderEvent):void
		{
			loadingComplete();
		}
		
		private function loaderIOErrorHandler(event:IOErrorEvent):void
		{
			ioError(event);
		}
		
		private function loaderSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			securityError(event);
		}
		
		private function ioError(event:IOErrorEvent):void
		{
			setStatus(LoaderStatus.FAILED_IO_ERROR);
			_failDescription = event.text;
		}
		
		private function removeFileLoaderListeners():void
		{
			_loader.removeEventListener(Event.OPEN, loaderOpenHandler, false);
			_loader.removeEventListener(FileLoaderEvent.COMPLETE, loaderCompleteHandler, false);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler, false);
			_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderSecurityErrorHandler, false);
		}
		
		private function securityError(event:SecurityErrorEvent):void
		{
			setStatus(LoaderStatus.FAILED_SECURITY_ERROR);
			_failDescription = event.text;
		}
		
	}

}