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
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class VostokLoader implements IFileLoader
	{
		/**
		 * @private
 		 */
		private var _context:LoaderContext;
		private var _loader:Loader;
		private var _request:URLRequest;
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function VostokLoader(loader:Loader, request:URLRequest, context:LoaderContext = null)
		{
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			if (!request) throw new ArgumentError("Argument <request> must not be null.");
			
			_loader = loader;
			_request = request;
			_context = context;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_loader.contentLoaderInfo.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * description
		 */
		public function cancel(): void
		{
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
		
		public function dispatchEvent(event:Event):Boolean
		{
			return _loader.contentLoaderInfo.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return _loader.contentLoaderInfo.hasEventListener(type);
		}
		
		
		/**
		 * description
		 */
		public function load(): void
		{
			_loader.load(_request, _context);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_loader.contentLoaderInfo.addEventListener(type, listener, useCapture);
		}
		
		
		public function willTrigger(type:String):Boolean
		{
			return _loader.contentLoaderInfo.willTrigger(type);
		}

	}

}