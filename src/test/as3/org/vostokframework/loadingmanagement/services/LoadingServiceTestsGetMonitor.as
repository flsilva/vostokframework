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
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsGetMonitor extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE_ID:String = "queue-1";
		
		public function LoadingServiceTestsGetMonitor()
		{
			
		}
		
		///////////////////////////////////
		// LoadingService().getMonitor() //
		///////////////////////////////////
		
		//QUEUE testing
		
		[Test(expects="ArgumentError")]
		public function getMonitor_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.getMonitor(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoadingMonitorNotFoundError")]
		public function getMonitor_notExistingMonitor_ThrowsError(): void
		{
			service.getMonitor(QUEUE_ID);
		}
		
		[Test]
		public function getMonitor_existingMonitorForQueueLoader_ReturnsValidObject(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var monitor:ILoadingMonitor = service.getMonitor(QUEUE_ID);
			Assert.assertNotNull(monitor);
		}
		
		//ASSET testing
		
		[Test]
		public function getMonitor_existingMonitorForAssetLoader_ReturnsValidObject(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var monitor:ILoadingMonitor = service.getMonitor(asset1.identification.id, asset1.identification.locale);
			Assert.assertNotNull(monitor);
		}
		
	}

}