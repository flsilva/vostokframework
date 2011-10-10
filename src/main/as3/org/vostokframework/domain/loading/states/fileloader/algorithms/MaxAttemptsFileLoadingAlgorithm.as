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
package org.vostokframework.domain.loading.states.fileloader.algorithms
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.TypedList;
	import org.vostokframework.domain.loading.LoadError;
	import org.vostokframework.domain.loading.LoadErrorType;
	import org.vostokframework.domain.loading.states.fileloader.IFileLoadingAlgorithm;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.events.FileLoadingAlgorithmErrorEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class MaxAttemptsFileLoadingAlgorithm extends FileLoadingAlgorithmBehavior
	{
		/**
		 * @private
 		 */
		private var _dispatcher:IEventDispatcher;
		private var _errors:IList;//<LoadError>
		private var _maxAttempts:int;
		private var _performedAttempts:int;
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function MaxAttemptsFileLoadingAlgorithm(wrapAlgorithm:IFileLoadingAlgorithm, maxAttempts:int = 1)
		{
			super(wrapAlgorithm);
			
			if (maxAttempts < 1) throw new ArgumentError("Argument <maxAttempts> must be greater than zero. Received: <" + maxAttempts + ">");
			
			_maxAttempts = maxAttempts;
			_dispatcher = new EventDispatcher(this);
			_errors = new TypedList(new ArrayList(), LoadError);
			
			addWrappedAlgorithmListeners();
		}
		
		override public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			validateDisposal();
			
			if (type == FileLoadingAlgorithmErrorEvent.FAILED)
			{
				_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
			else
			{
				super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		
		override public function dispatchEvent(event : Event) : Boolean
		{
			validateDisposal();
			
			if (event.type == FileLoadingAlgorithmErrorEvent.FAILED)
			{
				return _dispatcher.dispatchEvent(event);
			}
			else
			{
				return super.dispatchEvent(event);
			}
		}
		
		override public function hasEventListener(type : String) : Boolean
		{
			validateDisposal();
			
			if (type == FileLoadingAlgorithmErrorEvent.FAILED)
			{
				return _dispatcher.hasEventListener(type);
			}
			else
			{
				return super.hasEventListener(type);
			}
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		override public function load(): void
		{
			validateDisposal();
			
			if (isExaustedAttempts() || hasSomeFatalError())
			{
				failed();
				return;
			}
			
			wrappedAlgorithm.load();
		}

		override public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			validateDisposal();
			
			if (type == FileLoadingAlgorithmErrorEvent.FAILED)
			{
				_dispatcher.removeEventListener(type, listener, useCapture);
			}
			else
			{
				super.removeEventListener(type, listener, useCapture);
			}
		}
		
		override public function willTrigger(type : String) : Boolean
		{
			validateDisposal();
			
			if (type == FileLoadingAlgorithmErrorEvent.FAILED)
			{
				return _dispatcher.willTrigger(type);
			}
			else
			{
				return super.willTrigger(type);
			}
		}
		
		override protected function doDispose():void
		{
			removeWrappedAlgorithmListeners();
		}
		
		private function addWrappedAlgorithmListeners():void
		{
			wrappedAlgorithm.addEventListener(FileLoadingAlgorithmErrorEvent.FAILED, failedHandler, false, 0, true);
		}
		
		private function failed():void
		{
			validateDisposal();
			removeWrappedAlgorithmListeners();
			
			dispatchEvent(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, _errors));
		}
		
		private function failedHandler(event:FileLoadingAlgorithmErrorEvent):void
		{
			validateDisposal();
			
			_errors.addAll(event.errors);
			_performedAttempts++;
			/*
			// IF IT'S A SECURITY ERROR
			// IT DOES NOT USE ATTEMPTS TO TRY AGAIN
			// IT JUST FAIL
			var lastError:LoadError = _errors.getAt(_errors.size() - 1);
			if (lastError.type.equals(LoadErrorType.SECURITY_ERROR))
			{
				failed();
				return;
			}
			else
			{
				load();
			}
			*/
			load();
		}
		
		private function hasSomeFatalError():Boolean
		{
			if (!_errors || _errors.isEmpty()) return false;
			
			var it:IIterator = _errors.iterator();
			var error:LoadError;
			
			// IF A SECURITY ERROR OR IO ERROR OCCURRED
			// IT DOES NOT USE ATTEMPTS TO TRY AGAIN
			// IT JUST FAIL
			
			while (it.hasNext())
			{
				error = it.next();
				if (error.type.equals(LoadErrorType.SECURITY_ERROR)
					|| error.type.equals(LoadErrorType.IO_ERROR)) return true;
			}
			
			return false;
		}
		
		private function isExaustedAttempts():Boolean
		{
			return _performedAttempts >= _maxAttempts;
		}
		
		private function removeWrappedAlgorithmListeners():void
		{
			wrappedAlgorithm.removeEventListener(FileLoadingAlgorithmErrorEvent.FAILED, failedHandler, false);
		}
		
	}

}