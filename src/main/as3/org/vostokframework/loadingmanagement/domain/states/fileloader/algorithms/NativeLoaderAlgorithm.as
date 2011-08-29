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
package org.vostokframework.loadingmanagement.domain.states.fileloader.algorithms
{
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.FileLoadingAlgorithm;

	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.getTimer;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class NativeLoaderAlgorithm extends FileLoadingAlgorithm
	{
		/**
		 * @private
 		 */
		private var _context:LoaderContext;
		private var _disposed:Boolean;
		private var _loader:Loader;
		private var _request:URLRequest;
		private var _timeConnectionStarted:int;
		
		//TODO:pensar sobre deixar logica "dispose" na base class (doCancel(), doLoad(), etc)
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function NativeLoaderAlgorithm(loader:Loader, request:URLRequest, context:LoaderContext = null)
		{
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			if (!request) throw new ArgumentError("Argument <request> must not be null.");
			
			_loader = loader;
			_request = request;
			_context = context;
			
			setLoadingDispatcher(_loader.contentLoaderInfo);
		}
		
		/**
		 * description
		 */
		override public function cancel(): void
		{
			validateDisposal();
			close();
		}
		
		override public function dispose():void
		{
			if (_disposed) return;
			
			close();
			
			_loader = null;
			_request = null;
			_context = null;
		}
		
		override public function getData():*
		{
			validateDisposal();
			return _loader.content;
		}
		
		/**
		 * description
		 */
		override public function load(): void
		{
			validateDisposal();
			_timeConnectionStarted = getTimer();
			
			_loader.load(_request, _context);
		}
		
		/**
		 * description
		 */
		override public function stop():void
		{
			validateDisposal();
			close();
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
		
		/**
		 * @private
		 */
		private function validateDisposal():void
		{
			if (_disposed) throw new ObjectDisposedError("This object was disposed, therefore no more operations can be performed.");
		}

	}

}