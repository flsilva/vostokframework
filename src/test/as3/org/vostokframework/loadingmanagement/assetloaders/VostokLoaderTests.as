/*
 * Licensed under the MIT License
 * 
 * Copyright 2010 (c) Flávio Silva, http://flsilva.com
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

package org.vostokframework.loadingmanagement.assetloaders
{
	import flash.display.Loader;
	import flash.net.URLRequest;

	/**
	 * @author Flávio Silva
	 */
	public class VostokLoaderTests
	{
		
		public function VostokLoaderTests()
		{
			
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidInstantiation1_ThrowsError(): void
		{
			var loader:IFileLoader = new VostokLoader(null, null);
			loader = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidInstantiation2_ThrowsError(): void
		{
			var loader:IFileLoader = new VostokLoader(new Loader(), null);
			loader = null;
		}
		
		[Test]
		public function constructor_validInstantiation_Void(): void
		{
			var loader:IFileLoader = new VostokLoader(new Loader(), new URLRequest());
			loader = null;
		}
		
		///////////////////////////////////////////
		// VostokLoader().loaderDispatcher TESTS //
		//////////////////////////////////////////
		/*
		[Test]
		public function loaderDispatcher_validGet_IEventDispatcher(): void
		{
			var flashLoader:Loader = new Loader();
			var loader:IFileLoader = new VostokLoader(flashLoader, new URLRequest());
			
			Assert.assertNotNull(loader.loadingDispatcher);
			
			//Assert.assertEquals(flashLoader.loaderInfo, loader.loaderDispatcher);
		}
		*/
	}

}