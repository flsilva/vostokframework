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
	import org.as3collections.IList;
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.ILoaderState;
	import org.vostokframework.domain.loading.ILoaderStateTransition;
	import org.vostokframework.domain.loading.events.LoaderEvent;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class FileLoaderState implements ILoaderState
	{
		
		/**
		 * @private
		 */
		private var _algorithm:IFileLoadingAlgorithm;
		private var _disposed:Boolean;
		private var _loader:ILoaderStateTransition;
		
		protected function get algorithm():IFileLoadingAlgorithm { return _algorithm; }
		
		protected function get loader():ILoaderStateTransition { return _loader; }
		
		
		public function get isLoading():Boolean { return false; }
		
		public function get isQueued():Boolean { return false; }
		
		public function get isStopped():Boolean { return false; }
		
		public function get openedConnections():int { return 0; }
		
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function FileLoaderState(algorithm:IFileLoadingAlgorithm)
		{
			if (ReflectionUtil.classPathEquals(this, FileLoaderState))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be directly instantiated.");
			if (!algorithm) throw new ArgumentError("Argument <algorithm> must not be null.");
			
			_algorithm = algorithm;
		}
		
		public function addChild(child:ILoader): void
		{
			throw new UnsupportedOperationError("This is a Leaf implementation of the ILoaderState interface and does not support this operation. " + ReflectionUtil.getClassPath(this));
		}
		
		public function addChildren(children:IList): void
		{
			throw new UnsupportedOperationError("This is a Leaf implementation of the ILoaderState interface and does not support this operation. " + ReflectionUtil.getClassPath(this));
		}
		
		public function cancel():void
		{
			validateDisposal();
			algorithm.cancel();
			
			loader.setState(new CanceledFileLoader(loader, algorithm));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.CANCELED));
			dispose();
		}
		
		public function cancelChild(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("This is a Leaf implementation of the ILoaderState interface and does not support this operation. " + ReflectionUtil.getClassPath(this));
		}
		
		public function containsChild(identification:VostokIdentification): Boolean
		{
			return false;
		}
		
		public function dispose():void
		{
			if (_disposed) return;
			
			doDispose();
			
			_disposed = true;
			_algorithm = null;
			_loader = null;
		}
		
		public function getChild(identification:VostokIdentification): ILoader
		{
			throw new UnsupportedOperationError("This is a Leaf implementation of the ILoaderState interface and does not support this operation. " + ReflectionUtil.getClassPath(this));
		}
		
		public function getParent(identification:VostokIdentification): ILoader
		{
			throw new UnsupportedOperationError("This is a Leaf implementation of the ILoaderState interface and does not support this operation. " + ReflectionUtil.getClassPath(this));
		}
		
		public function load():void
		{
			validateDisposal();
			
			loader.setState(new LoadingFileLoader(loader, algorithm));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.CONNECTING));
			dispose();
		}
		
		public function removeChild(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("This is a Leaf implementation of the ILoaderState interface and does not support this operation. " + ReflectionUtil.getClassPath(this));
		}
		
		public function resumeChild(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("This is a Leaf implementation of the ILoaderState interface and does not support this operation. " + ReflectionUtil.getClassPath(this));
		}
		
		public function setLoader(loader:ILoaderStateTransition):void
		{
			_loader = loader;
		}
		
		public function stop():void
		{
			validateDisposal();
			algorithm.stop();
			
			loader.setState(new StoppedFileLoader(loader, algorithm));
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.STOPPED));
			dispose();
		}
		
		public function stopChild(identification:VostokIdentification): void
		{
			throw new UnsupportedOperationError("This is a Leaf implementation of the ILoaderState interface and does not support this operation. " + ReflectionUtil.getClassPath(this));
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