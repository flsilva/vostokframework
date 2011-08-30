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
package org.vostokframework.loadingmanagement.domain.states.fileloader
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3coreaddendum.errors.IllegalStateError;
	import org.as3coreaddendum.errors.ObjectDisposedError;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3coreaddendum.system.IDisposable;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.loadingmanagement.domain.IDataParser;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class FileLoadingAlgorithm implements IEventDispatcher, IDisposable
	{
		/**
		 * @private
 		 */
		private var _dispatcher:IEventDispatcher;
		private var _disposed:Boolean;
		private var _parsers:IList;
		
		/**
		 * description
		 * 
		 */
		public function FileLoadingAlgorithm()
		{
			if (ReflectionUtil.classPathEquals(this, FileLoadingAlgorithm))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be directly instantiated.");
		}
		
		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			validateDispatcher();
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function addParsers(parsers:IList):void
		{
			_parsers = parsers;
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function cancel(): void
		{
			validateDisposal();
			doCancel();
		}
		
		public function dispatchEvent(event : Event) : Boolean
		{
			validateDisposal();
			validateDispatcher();
			return _dispatcher.dispatchEvent(event);
		}
		
		public function dispose():void
		{
			if (_disposed) return;
			
			doDispose();
			
			_disposed = true;
			_dispatcher = null;
			_parsers = null;
		}
		
		public function getData():*
		{
			validateDisposal();
			return doGetData();
		}
		
		public function hasEventListener(type : String) : Boolean
		{
			validateDisposal();
			validateDispatcher();
			return _dispatcher.hasEventListener(type);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function load(): void
		{
			validateDisposal();
			doLoad();
		}
		
		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			validateDisposal();
			validateDispatcher();
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * description
		 */
		public function stop(): void
		{
			validateDisposal();
			doStop();
		}
		
		public function willTrigger(type : String) : Boolean
		{
			validateDisposal();
			validateDispatcher();
			return _dispatcher.willTrigger(type);
		}
		
		protected function doCancel():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function doDispose():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function doGetData():*
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function doLoad():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function doStop():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function parseData(rawData:*):*
		{
			validateDisposal();
			
			if (!rawData) return null;
			if (!_parsers) return rawData;
			
			var it:IIterator = _parsers.iterator();
			var parser:IDataParser;
			var parsedData:* = rawData;
			
			while (it.hasNext())
			{
				parser = it.next();
				parsedData = parser.parse(parsedData);
			}
		}

		protected function setLoadingDispatcher(dispatcher:IEventDispatcher):void
		{
			if (!dispatcher) throw new ArgumentError("Argument <dispatcher> must not be null.");
			_dispatcher = dispatcher;
		}
		
		private function validateDispatcher():void
		{
			if (!_dispatcher) throw new IllegalStateError("Method <setLoadingDispatcher> must be called at the startup of the object.");
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