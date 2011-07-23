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

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StubAbstractLoader extends AbstractLoader
	{
		private var _cancelCalled:Boolean;
		private var _loadCalled:Boolean;
		private var _stopCalled:Boolean;
		
		public function get cancelCalled():Boolean { return _cancelCalled; }
		
		public function get loadCalled():Boolean { return _loadCalled; }
		
		public function get stopCalled():Boolean { return _stopCalled; }
		
		public function StubAbstractLoader(id:String, maxAttempts:int, priority:LoadPriority = null)
		{
			if (!priority) priority = LoadPriority.MEDIUM;
			super(id, priority, maxAttempts);
		}
		
		public function $loadingComplete():void
		{
			super.loadingComplete();
		}
		
		override internal function doCancel(): void
		{
			_cancelCalled = true;
		}
		
		override internal function doLoad(): void
		{
			_loadCalled = true;
		}

		override internal function doStop(): void
		{
			_stopCalled = true;
		}

	}

}