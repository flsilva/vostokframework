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

package org.vostokframework.loadingmanagement.services
{
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsResume extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE_ID:String = "queue-1";
		
		public function LoadingServiceTestsResume()
		{
			
		}
		
		///////////////////////////////
		// LoadingService().resume() //
		///////////////////////////////
		
		//QUEUE testing
		
		[Test(expects="ArgumentError")]
		public function resume_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.resume(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function resume_notExistingLoader_ThrowsError(): void
		{
			service.resume(QUEUE_ID);
		}
		
		[Test]
		public function resume_stoppedQueueLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stop(QUEUE_ID);
			
			var resumed:Boolean = service.resume(QUEUE_ID);
			Assert.assertTrue(resumed);
		}
		
		[Test]
		public function resume_loadingQueueLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var resumed:Boolean = service.resume(QUEUE_ID);
			Assert.assertFalse(resumed);
		}
		
		//ASSET testing
		
		[Test]
		public function resume_stoppedAssetLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stop(asset1.identification.id, asset1.identification.locale);
			
			var resumed:Boolean = service.resume(asset1.identification.id, asset1.identification.locale);
			Assert.assertTrue(resumed);
		}
		
		[Test]
		public function resume_loadingAssetLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var resumed:Boolean = service.resume(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(resumed);
		}
		
	}

}