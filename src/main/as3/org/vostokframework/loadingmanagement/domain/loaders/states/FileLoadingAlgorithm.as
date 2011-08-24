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
package org.vostokframework.loadingmanagement.domain.loaders.states
{
	import org.as3coreaddendum.errors.IllegalStateError;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3coreaddendum.system.IDisposable;
	import org.as3utils.ReflectionUtil;

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
		
		private var _dispatcher:IEventDispatcher;
		
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
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function cancel(): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function dispatchEvent(event : Event) : Boolean
		{
			validateDispatcher();
			return _dispatcher.dispatchEvent(event);
		}
		
		public function dispose():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function getData():*
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function hasEventListener(type : String) : Boolean
		{
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
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			validateDispatcher();
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * description
		 */
		public function stop(): void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function willTrigger(type : String) : Boolean
		{
			validateDispatcher();
			return _dispatcher.willTrigger(type);
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

	}

}