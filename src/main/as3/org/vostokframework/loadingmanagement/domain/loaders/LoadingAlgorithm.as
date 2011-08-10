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
	import org.as3collections.ICollection;
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3coreaddendum.system.IDisposable;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.LoaderState;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingAlgorithm extends EventDispatcher implements IDisposable
	{
		/**
		 * @private
 		 */
		private var _disposed:Boolean;
		private var _isLoading:Boolean;
		
		/**
		 * @private
 		 */
		protected function get isLoading():Boolean { return _isLoading; }
		protected function set isLoading(value:Boolean):void { _isLoading = value; }
		
		public function get openedConnections():int
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 * 
		 */
		public function LoadingAlgorithm ()
		{
			if (ReflectionUtil.classPathEquals(this, LoadingAlgorithm ))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be directly instantiated.");
		}
		
		/**
		 * description
		 * 
		 * @param loader
		 */
		public function addLoader(loader:VostokLoader): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 * 
		 * @param loaders
		 */
		public function addLoaders(loaders:ICollection): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function cancel(): void
		{
			_isLoading = false;
			doCancel();
		}
		
		public function cancelLoader(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function containsLoader(identification:VostokIdentification): Boolean
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function dispose():void
		{
			if (_disposed) return;
			
			doDispose();
			_disposed = true;
		}
		
		public function getLoader(identification:VostokIdentification): VostokLoader
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function getLoaderState(identification:VostokIdentification): LoaderState
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 * 
		 * @param identification
		 */
		public function getParent(context:VostokLoader, identification:VostokIdentification): VostokLoader
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function load(): void
		{
			_isLoading = true;
			doLoad();
		}
		
		public function removeLoader(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function resumeLoader(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function stopLoader(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * description
		 */
		public function stop(): void
		{
			_isLoading = false;
			doStop();
		}
		
		/**
		 * @private
		 */
		protected function doCancel():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * @private
		 */
		protected function doDispose():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * @private
		 */
		protected function doLoad():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		/**
		 * @private
		 */
		protected function doStop():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
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