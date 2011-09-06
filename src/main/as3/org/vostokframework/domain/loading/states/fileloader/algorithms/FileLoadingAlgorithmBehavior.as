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
	import org.as3collections.IList;
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.FileLoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.IFileLoadingAlgorithm;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class FileLoadingAlgorithmBehavior implements IFileLoadingAlgorithm
	{
		/**
		 * @private
 		 */
		private var _disposed:Boolean;
		private var _wrappedAlgorithm:IFileLoadingAlgorithm;
		
		protected function get wrappedAlgorithm():IFileLoadingAlgorithm { return _wrappedAlgorithm; }
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function FileLoadingAlgorithmBehavior(wrapAlgorithm:IFileLoadingAlgorithm)
		{
			if (ReflectionUtil.classPathEquals(this, FileLoadingAlgorithm))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be directly instantiated.");
			if (!wrapAlgorithm) throw new ArgumentError("Argument <wrapAlgorithm> must not be null.");
			
			_wrappedAlgorithm = wrapAlgorithm;
		}
		
		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			validateDisposal();
			_wrappedAlgorithm.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function addParsers(parsers:IList):void
		{
			validateDisposal();
			_wrappedAlgorithm.addParsers(parsers);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function cancel(): void
		{
			validateDisposal();
			_wrappedAlgorithm.cancel();
		}
		
		public function dispatchEvent(event: Event): Boolean
		{
			validateDisposal();
			return _wrappedAlgorithm.dispatchEvent(event);
		}
		
		public function dispose():void
		{
			if (_disposed) return;
			
			doDispose();
			
			_wrappedAlgorithm.dispose();
			
			_disposed = true;
			_wrappedAlgorithm = null;
		}
		
		public function hasEventListener(type : String) : Boolean
		{
			validateDisposal();
			return _wrappedAlgorithm.hasEventListener(type);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function load(): void
		{
			validateDisposal();
			_wrappedAlgorithm.load();
		}
		
		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			validateDisposal();
			_wrappedAlgorithm.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * description
		 */
		public function stop(): void
		{
			validateDisposal();
			_wrappedAlgorithm.stop();
		}
		
		public function willTrigger(type : String) : Boolean
		{
			validateDisposal();
			return _wrappedAlgorithm.willTrigger(type);
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