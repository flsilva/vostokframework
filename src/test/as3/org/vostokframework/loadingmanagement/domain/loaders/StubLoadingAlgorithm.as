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
package org.vostokframework.loadingmanagement.domain.loaders
{
	import org.vostokframework.VostokIdentification;
	import org.as3collections.ICollection;
	import org.vostokframework.loadingmanagement.domain.LoaderState;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.events.LoadingAlgorithmEvent;

	import flash.display.MovieClip;
	import flash.events.ProgressEvent;
	import flash.utils.setTimeout;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StubLoadingAlgorithm extends LoadingAlgorithm
	{
		
		private var _openBehaviorSync:Boolean;
		private var _successBehaviorAsync:Boolean;
		private var _successBehaviorSync:Boolean;
		
		public function set openBehaviorSync(value:Boolean):void { _openBehaviorSync = value; }
		
		public function set successBehaviorAsync(value:Boolean):void { _successBehaviorAsync = value; }
		
		public function set successBehaviorSync(value:Boolean):void { _successBehaviorSync = value; }
		
		override public function get openedConnections():int
		{
			if (isLoading)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		
		/**
		 * description
		 * 
		 */
		public function StubLoadingAlgorithm(maxAttempts:int = 1)
		{
			super(maxAttempts);
		}
		
		override public function addLoader(loader:VostokLoader): void
		{
			
		}
		
		override public function addLoaders(loaders:ICollection): void
		{
			
		}
		
		override protected function doCancel(): void
		{
			
		}
		
		override public function cancelLoader(identification:VostokIdentification): void
		{
			
		}
		
		override public function containsLoader(identification:VostokIdentification): Boolean
		{
			return false;
		}
		
		override public function dispose():void
		{
			
		}
		
		override public function getLoaderState(identification:VostokIdentification): LoaderState
		{
			return null;
		}
		
		override protected function doLoad(): void
		{
			dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.CONNECTING));
			
			if (_openBehaviorSync)
			{
				dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.OPEN));
			}
			else if (_successBehaviorAsync)
			{
				setTimeout(dispatchEvent, 50, new LoadingAlgorithmEvent(LoadingAlgorithmEvent.OPEN));
				setTimeout(dispatchEvent, 75, new ProgressEvent(ProgressEvent.PROGRESS, false, false, 500, 750));
				setTimeout(dispatchEvent, 100, new ProgressEvent(ProgressEvent.PROGRESS, false, false, 750, 750));
				setTimeout(dispatchEvent, 125, new LoadingAlgorithmEvent(LoadingAlgorithmEvent.COMPLETE, new MovieClip()));
			}
			else if (_successBehaviorSync)
			{
				dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.OPEN));
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 500, 750));
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 750, 750));
				dispatchEvent(new LoadingAlgorithmEvent(LoadingAlgorithmEvent.COMPLETE, new MovieClip()));
			}
		}
		
		override public function removeLoader(identification:VostokIdentification): void
		{
			
		}
		
		override public function resumeLoader(identification:VostokIdentification): void
		{
			
		}
		
		override public function stopLoader(identification:VostokIdentification): void
		{
			
		}
		
		override protected function doStop(): void
		{
			
		}

	}

}