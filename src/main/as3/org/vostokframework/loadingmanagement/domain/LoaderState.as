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
package org.vostokframework.loadingmanagement.domain
{
	import org.as3coreaddendum.system.Enum;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.FileLoaderStrategy;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderCanceled;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderConnecting;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderStopped;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoaderState extends Enum
	{
		
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function LoaderState(name:String, ordinal:int)
		{
			super(name, ordinal);
			
			if (ReflectionUtil.classPathEquals(this, LoaderState))  throw new IllegalOperationError(ReflectionUtil.getClassName(this) + " is an abstract class and shouldn't be directly instantiated.");
		}
		
		public function cancel(loader:FileLoader, strategy:FileLoaderStrategy):void
		{
			loader.setState(LoaderCanceled.INSTANCE);
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.CANCELED));
			strategy.cancel();
		}
		
		public function load(loader:FileLoader, strategy:FileLoaderStrategy):void
		{
			loader.currentAttempt++;
			
			if (loader.currentAttempt > loader.maxAttempts)
			{
				loader.failed();
				return;
			}
			
			loader.setState(LoaderConnecting.INSTANCE);
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.CONNECTING));
			strategy.load();
		}
		
		public function stop(loader:FileLoader, strategy:FileLoaderStrategy):void
		{
			loader.setState(LoaderStopped.INSTANCE);
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.STOPPED));
			strategy.stop();
		}
		
		protected function decreaseLoaderCurrentAttempt(loader:FileLoader):void
		{
			loader.currentAttempt--;
		}

	}

}