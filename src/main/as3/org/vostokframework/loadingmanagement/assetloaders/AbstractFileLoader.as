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
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3utils.ReflectionUtil;

	import flash.errors.IllegalOperationError;
	import flash.events.IEventDispatcher;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AbstractFileLoader
	{
		//TODO: delete this class
		/**
		 * @private
 		 */
		private var _loadingDispatcher:IEventDispatcher;

		/**
		 * description
		 * 
		 * @return
 		 */
		public function get loadingDispatcher(): IEventDispatcher { return _loadingDispatcher; }

		/**
		 * description
		 * 
		 * @param loaderDispatcher
		 */
		public function AbstractFileLoader(loadingDispatcher:IEventDispatcher)
		{
			if (ReflectionUtil.classPathEquals(this, AbstractFileLoader))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be instantiated directly.");
			
			_loadingDispatcher = loadingDispatcher;
		}

		/**
		 * description
		 */
		public function cancel(): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}

		/**
		 * description
		 */
		public function load(): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		/*
		protected function addLoadingListeners(loadingDispatcher:IEventDispatcher):void
		{
			loadingDispatcher.addEventListener(Event.OPEN, openHandler, false, 0, true);
			//loadingDispatcher.addEventListener(Event.INIT, initHandler, false, 0, true);
			loadingDispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
			loadingDispatcher.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			loadingDispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			loadingDispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			loadingDispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
		}
		
		protected function removeLoadingListeners(loadingDispatcher:IEventDispatcher):void
		{
			loadingDispatcher.removeEventListener(Event.OPEN, openHandler, false);
			//loadingDispatcher.removeEventListener(Event.INIT, initHandler, false);
			loadingDispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler, false);
			loadingDispatcher.removeEventListener(Event.COMPLETE, completeHandler, false);
			loadingDispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false);
			loadingDispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false);
			loadingDispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false);
		}
*/
	}

}