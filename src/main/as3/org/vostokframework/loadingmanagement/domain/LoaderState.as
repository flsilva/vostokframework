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
	import org.as3collections.IList;
	import org.as3coreaddendum.system.Enum;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.LoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderCanceled;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderStopped;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoaderState extends Enum
	{
		//TODO:implementar equals em cada um dos states, comparando com a instancia flyweight
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
		
		public function addLoader(loader:VostokLoader, algorithm:LoadingAlgorithm): void
		{
			algorithm.addLoader(loader);
		}
		
		public function addLoaders(loaders:IList, algorithm:LoadingAlgorithm): void
		{
			algorithm.addLoaders(loaders);
		}
		
		public function cancel(loader:VostokLoader, algorithm:LoadingAlgorithm):void
		{
			algorithm.cancel();
			loader.setState(LoaderCanceled.INSTANCE);
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.CANCELED));
		}
		
		public function cancelLoader(identification:VostokIdentification, algorithm:LoadingAlgorithm): void
		{
			algorithm.cancelLoader(identification);
		}
		
		public function load(loader:VostokLoader, algorithm:LoadingAlgorithm):void
		{
			loader.currentAttempt++;
			//TODO:refactoring:tirar incremento daqui e colocar em failed(). state nao precisara acessar essa variavel. logica de max attempts fica dentro do loader, em failed().
			if (loader.currentAttempt > loader.maxAttempts)
			{
				loader.failed();
				return;
			}
			
			// here first set state then call algorithm
			// because anyway algorithm is async
			//loader.setState(LoaderConnecting.INSTANCE);
			//loader.dispatchEvent(new LoaderEvent(LoaderEvent.CONNECTING));
			algorithm.load();
		}
		
		public function removeLoader(identification:VostokIdentification, algorithm:LoadingAlgorithm): void
		{
			algorithm.removeLoader(identification);
		}
		
		public function resumeLoader(identification:VostokIdentification, algorithm:LoadingAlgorithm): void
		{
			algorithm.resumeLoader(identification);
		}
		
		public function stop(loader:VostokLoader, algorithm:LoadingAlgorithm):void
		{
			algorithm.stop();
			loader.setState(LoaderStopped.INSTANCE);
			loader.dispatchEvent(new LoaderEvent(LoaderEvent.STOPPED));
		}
		
		public function stopLoader(identification:VostokIdentification, algorithm:LoadingAlgorithm): void
		{
			algorithm.stopLoader(identification);
		}
		
		protected function decreaseLoaderCurrentAttempt(loader:VostokLoader):void
		{
			loader.currentAttempt--;
		}

	}

}