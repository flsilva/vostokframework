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
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.domain.loaders.StubLoadingAlgorithm;

	import flash.events.Event;
	import flash.utils.setTimeout;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StubVostokLoader extends VostokLoader
	{
		public var $state:LoaderState;
		
		override public function get state():LoaderState
		{
			if ($state) return $state;
			return super.state;
		}
		
		public function StubVostokLoader(identification:VostokIdentification)
		{
			super(identification, new StubLoadingAlgorithm(), LoadPriority.MEDIUM);
		}
		
		public function asyncDispatchEvent(event:Event, state:LoaderState, delay:int = 50):int
		{
			return setTimeout(_dispatchEvent, delay, event, state);
		}
		
		private function _dispatchEvent(event:Event, state:LoaderState):void
		{
			setState(state);
			$state = state;
			dispatchEvent(event);
		}
		
	}

}