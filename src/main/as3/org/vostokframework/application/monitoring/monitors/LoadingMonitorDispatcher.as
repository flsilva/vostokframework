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
package org.vostokframework.application.monitoring.monitors
{
	import org.as3collections.IMap;
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.application.monitoring.LoadingMonitoring;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;

	/**
	 * @author Flavio
	 * @version 1.0
	 * @created 14-mai-2011 12:02:52
	 */
	public class LoadingMonitorDispatcher extends EventDispatcher
	{
		/**
		 * 
		 */
		public function LoadingMonitorDispatcher()
		{
			if (ReflectionUtil.classPathEquals(this, LoadingMonitorDispatcher))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be directly instantiated.");
		}
		
		public function dispatchCanceledEvent(monitoring:LoadingMonitoring):void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function dispatchCompleteEvent(monitoring:LoadingMonitoring, data:* = null):void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function dispatchFailedEvent(monitoring:LoadingMonitoring, errors:IMap):void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function dispatchHttpStatusEvent(monitoring:LoadingMonitoring, status:int):void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function dispatchInitEvent(monitoring:LoadingMonitoring, data:* = null):void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function dispatchOpenEvent(monitoring:LoadingMonitoring, data:* = null):void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function dispatchProgressEvent(monitoring:LoadingMonitoring):void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function dispatchStoppedEvent(monitoring:LoadingMonitoring):void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function typeBelongs(type:String):Boolean
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
	}

}