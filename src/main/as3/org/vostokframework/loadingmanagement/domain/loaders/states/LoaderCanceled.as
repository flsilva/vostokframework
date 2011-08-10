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
	import org.vostokframework.VostokIdentification;
	import org.as3collections.IList;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.loadingmanagement.domain.LoaderState;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.LoadingAlgorithm;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoaderCanceled extends LoaderState
	{
		public static const INSTANCE:LoaderState = new LoaderCanceled("CANCELED", 0);
		
		/**
		 * @private
		 */
		private static var _created :Boolean = false;
		
		{
			_created = true;
		}
		
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function LoaderCanceled(name:String, ordinal:int)
		{
			super(name, ordinal);
			
			if (_created) throw new IllegalOperationError("The set of acceptable values by this Enumerated Type has already been created internally.");
		}
		
		override public function addLoader(loader:VostokLoader, algorithm:LoadingAlgorithm): void
		{
			throw new IllegalOperationError("The current state is <"+ReflectionUtil.getClassName(this)+">, therefore it is no longer allowed to add new loaders.");
		}
		
		override public function addLoaders(loaders:IList, algorithm:LoadingAlgorithm): void
		{
			throw new IllegalOperationError("The current state is <"+ReflectionUtil.getClassName(this)+">, therefore it is no longer allowed to add new loaders.");
		}
		
		override public function cancel(loader:VostokLoader, algorithm:LoadingAlgorithm):void
		{
			// do nothing
		}
		
		override public function cancelLoader(identification:VostokIdentification, algorithm:LoadingAlgorithm): void
		{
			// do nothing
		}
		
		override public function load(loader:VostokLoader, algorithm:LoadingAlgorithm):void
		{
			throw new IllegalOperationError("The current state is <"+ReflectionUtil.getClassName(this)+">, therefore it is no longer allowed loadings.");
		}
		
		override public function removeLoader(identification:VostokIdentification, algorithm:LoadingAlgorithm): void
		{
			throw new IllegalOperationError("The current state is <"+ReflectionUtil.getClassName(this)+">, therefore it is no longer allowed to remove loaders.");
		}
		
		override public function resumeLoader(identification:VostokIdentification, algorithm:LoadingAlgorithm): void
		{
			throw new IllegalOperationError("The current state is <"+ReflectionUtil.getClassName(this)+">, therefore it is no longer allowed to resume any loader.");
		}
		
		override public function stop(loader:VostokLoader, algorithm:LoadingAlgorithm):void
		{
			// do nothing
		}
		
		override public function stopLoader(identification:VostokIdentification, algorithm:LoadingAlgorithm): void
		{
			// do nothing
		}

	}

}