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
package org.vostokframework.domain.loading.states.queueloader
{
	import org.as3collections.IList;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.ILoaderStateTransition;
	import org.vostokframework.domain.loading.policies.ILoadingPolicy;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class CanceledQueueLoader extends QueueLoaderState
	{
		
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function CanceledQueueLoader(loader:ILoaderStateTransition, loadingStatus:QueueLoadingStatus, policy:ILoadingPolicy)
		{
			super(loadingStatus, policy);
			setLoader(loader);
		}
		
		override public function addChild(child:ILoader): void
		{
			throw new IllegalOperationError("The current state is <" + ReflectionUtil.getClassName(this) + ">, therefore it is no longer allowed to add new loaders.");
		}
		
		override public function addChildren(children:IList): void
		{
			throw new IllegalOperationError("The current state is <" + ReflectionUtil.getClassName(this) + ">, therefore it is no longer allowed to add new loaders.");
		}
		
		override public function cancel():void
		{
			//do nothing
		}
		
		override public function cancelChild(identification:VostokIdentification): void
		{
			//do nothing
		}
		
		override public function load():void
		{
			throw new IllegalOperationError("The current state is <" + ReflectionUtil.getClassName(this) + ">, therefore it is no longer allowed loadings.");
		}
		
		override public function removeChild(identification:VostokIdentification): void
		{
			throw new IllegalOperationError("The current state is <" + ReflectionUtil.getClassName(this) + ">, therefore it is no longer allowed to remove any loader.");
		}
		
		override public function resumeChild(identification:VostokIdentification): void
		{
			throw new IllegalOperationError("The current state is <" + ReflectionUtil.getClassName(this) + ">, therefore it is no longer allowed to resume any loader.");
		}
		
		override public function stop():void
		{
			throw new IllegalOperationError("The current state is <" + ReflectionUtil.getClassName(this) + ">, therefore it is no longer allowed to stop.");
		}
		
		override public function stopChild(identification:VostokIdentification): void
		{
			throw new IllegalOperationError("The current state is <" + ReflectionUtil.getClassName(this) + ">, therefore it is no longer allowed to stop any loader.");
		}
		
	}

}