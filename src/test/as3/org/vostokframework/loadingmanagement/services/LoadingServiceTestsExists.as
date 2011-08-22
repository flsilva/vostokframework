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
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.loaders.StubVostokLoaderFactory;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsExists extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE_ID:String = "queue-1";
		
		public function LoadingServiceTestsExists()
		{
			
		}
		
		///////////////////////////////
		// LoadingService().exists() //
		///////////////////////////////
		
		//QUEUE testing
		
		[Test(expects="ArgumentError")]
		public function exists_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.exists(null);
		}
		
		[Test]
		public function exists_notExistingLoaderId_ReturnsFalse(): void
		{
			var exists:Boolean = service.exists(QUEUE_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function exists_callLoadAndCheckIfQueueLoaderExists_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = service.exists(QUEUE_ID);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function exists_callLoad_queueLoadingCompletes_checkIfQueueLoaderExists_ReturnsFalse(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = service.exists(QUEUE_ID);
			Assert.assertFalse(exists);
		}
		
		//ASSET testing
		
		[Test]
		public function exists_callLoadAndCheckIfAssetLoaderExists_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = service.exists(asset1.identification.id, asset1.identification.locale);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function exists_callLoad_queueLoadingCompletes_checkIfAssetLoaderExists_ReturnsFalse(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorSync = true;
			LoadingManagementContext.getInstance().setAssetLoaderFactory(stubVostokLoaderFactory);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var exists:Boolean = service.exists(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(exists);
		}
		
	}

}