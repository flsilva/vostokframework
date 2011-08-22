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
	public class LoadingServiceTestsStop extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE1_ID:String = "queue-1";
		private static const QUEUE2_ID:String = "queue-2";
		private static const QUEUE3_ID:String = "queue-3";
		
		public function LoadingServiceTestsStop()
		{
			
		}
		
		/////////////////////////////
		// LoadingService().stop() //
		/////////////////////////////
		
		//QUEUE testing
		
		[Test(expects="ArgumentError")]
		public function stop_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.stop(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function stop_notExistingLoader_ThrowsError(): void
		{
			service.stop(QUEUE1_ID);
		}
		
		[Test]
		public function stop_loadingQueueLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var stopped:Boolean = service.stop(QUEUE1_ID);
			Assert.assertTrue(stopped);
		}
		
		[Test]
		public function stop_queuedQueueLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			service.load(QUEUE1_ID, list, null, 1);
			
			var list2:IList = new ArrayList();
			list2.add(asset3);
			
			service.load(QUEUE2_ID, list2, null, 1);
			
			var list3:IList = new ArrayList();
			list3.add(asset4);
			
			service.load(QUEUE3_ID, list3, null, 1);
			
			var stopped:Boolean = service.stop(QUEUE3_ID);
			Assert.assertTrue(stopped);
		}
		
		[Test]
		public function stop_stoppedQueueLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(QUEUE1_ID);
			
			var stopped:Boolean = service.stop(QUEUE1_ID);
			Assert.assertFalse(stopped);
		}
		
		//ASSET testing
		
		[Test]
		public function stop_loadingAssetLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var stopped:Boolean = service.stop(asset1.identification.id, asset1.identification.locale);
			Assert.assertTrue(stopped);
		}
		
		[Test]
		public function stop_queuedAssetLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			service.load(QUEUE1_ID, list, null, 1);
			
			var stopped:Boolean = service.stop(asset2.identification.id, asset2.identification.locale);
			Assert.assertTrue(stopped);
		}
		
		[Test]
		public function stop_stoppedAssetLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(asset1.identification.id, asset1.identification.locale);
			
			var stopped:Boolean = service.stop(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(stopped);
		}
		
	}

}