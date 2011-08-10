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
package org.vostokframework.loadingmanagement.domain.events
{
	import flash.events.ErrorEvent;
	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingAlgorithmErrorEvent extends ErrorEvent
	{
		public static const IO_ERROR:String = "VostokFramework.LoadingAlgorithmErrorEvent.IO_ERROR";
		public static const SECURITY_ERROR:String = "VostokFramework.LoadingAlgorithmErrorEvent.SECURITY_ERROR";
		public static const UNKNOWN_ERROR:String = "VostokFramework.LoadingAlgorithmErrorEvent.UNKNOWN_ERROR";
		
		/**
		 * description
		 * 
		 * @param type
		 * @param loadedAssetData
		 */
		public function LoadingAlgorithmErrorEvent(type: String, bubbles: Boolean = false, cancelable: Boolean = false, text: String = "")
		{
			super(type, bubbles, cancelable, text);
		}
		
		override public function clone():Event
		{
			return new LoadingAlgorithmErrorEvent(type, bubbles, cancelable, text);
		}
		
	}

}