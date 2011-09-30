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
package org.vostokframework.domain.loading.states.fileloader.adapters
{
	import flash.display.Loader;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class NativeLoaderAdapter extends DataLoaderAdapter
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
		public function NativeLoaderAdapter(loader:Loader, request:URLRequest, context:LoaderContext = null)
		{
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			if (!request) throw new ArgumentError("Argument <request> must not be null.");
			
			_loader = loader;
			_request = request;
			_context = context;
		}
		
		/**
		 * description
		 */
		override protected function doCancel(): void
		{
			close();
		}
		
		override protected function doDispose():void
		{
			close();
			
			_loader = null;
			_request = null;
			_context = null;
		}
		
		override protected function doGetData():*
		{
			return _loader.content;
		}
		
		/**
		 * description
		 */
		override protected function doLoad(): void
		{
			_loader.load(_request, _context);
		}
		
		/**
		 * description
		 */
		override protected function doStop():void
		{
			close();
		}
		
		override protected function getLoadingDispatcher():IEventDispatcher
		{
			return _loader.contentLoaderInfo;
		}
		
		private function close():void
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
		}

	}

}