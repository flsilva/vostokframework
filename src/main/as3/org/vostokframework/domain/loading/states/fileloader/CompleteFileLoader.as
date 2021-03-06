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
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.domain.loading.ILoaderStateTransition;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class CompleteFileLoader extends FileLoaderState
	{
		
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function CompleteFileLoader(loader:ILoaderStateTransition, algorithm:IFileLoadingAlgorithm)
		{
			super(algorithm);
			setLoader(loader);
		}
		
		override public function cancel():void
		{
			throw new IllegalOperationError("The current state is <"+ReflectionUtil.getClassName(this)+">, therefore it is no longer allowed to cancel.");
		}
		
		override public function load():void
		{
			throw new IllegalOperationError("The current state is <"+ReflectionUtil.getClassName(this)+">, therefore it is no longer allowed loadings.");
		}
		
		override public function stop():void
		{
			throw new IllegalOperationError("The current state is <"+ReflectionUtil.getClassName(this)+">, therefore it is no longer allowed to stop.");
		}
		
		override protected function doDispose():void
		{
			algorithm.dispose();
		}
		
	}

}