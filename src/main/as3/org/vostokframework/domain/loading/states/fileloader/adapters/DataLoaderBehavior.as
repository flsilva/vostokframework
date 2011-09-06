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
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.domain.loading.states.fileloader.FileLoadingAlgorithm;
	import org.vostokframework.domain.loading.states.fileloader.IDataLoader;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class DataLoaderBehavior implements IDataLoader
	{
		/**
		 * @private
 		 */
		private var _disposed:Boolean;
		private var _wrappedDataLoader:IDataLoader;
		
		protected function get wrappedDataLoader():IDataLoader { return _wrappedDataLoader; }
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function DataLoaderBehavior(wrappedDataLoader:IDataLoader)
		{
			if (ReflectionUtil.classPathEquals(this, FileLoadingAlgorithm))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be directly instantiated.");
			if (!wrappedDataLoader) throw new ArgumentError("Argument <wrappedDataLoader> must not be null.");
			
			_wrappedDataLoader = wrappedDataLoader;
		}
		
		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			validateDisposal();
			_wrappedDataLoader.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function cancel(): void
		{
			validateDisposal();
			_wrappedDataLoader.cancel();
		}
		
		public function dispatchEvent(event: Event): Boolean
		{
			validateDisposal();
			return _wrappedDataLoader.dispatchEvent(event);
		}
		
		public function dispose():void
		{
			if (_disposed) return;
			
			doDispose();
			
			_wrappedDataLoader.dispose();
			
			_disposed = true;
			_wrappedDataLoader = null;
		}
		
		public function getData(): *
		{
			validateDisposal();
			return _wrappedDataLoader.getData();
		}
		
		public function hasEventListener(type : String) : Boolean
		{
			validateDisposal();
			return _wrappedDataLoader.hasEventListener(type);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function load(): void
		{
			validateDisposal();
			_wrappedDataLoader.load();
		}
		
		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			validateDisposal();
			_wrappedDataLoader.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * description
		 */
		public function stop(): void
		{
			validateDisposal();
			_wrappedDataLoader.stop();
		}
		
		public function willTrigger(type : String) : Boolean
		{
			validateDisposal();
			return _wrappedDataLoader.willTrigger(type);
		}
		
		protected function doDispose():void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function validateDisposal():void
		{
			if (_disposed) throw new ObjectDisposedError("This object was disposed, therefore no more operations can be performed.");
		}
		
	}

}