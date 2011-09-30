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

package org.vostokframework.domain.loading.states.queueloader.policies
{
	import org.vostokframework.domain.loading.GlobalLoadingSettings;
	import org.vostokframework.domain.loading.StubLoaderRepository;
	import org.vostokframework.domain.loading.states.queueloader.IQueueLoadingPolicy;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class SpecialHighestLowestQueueLoadingPolicyTests extends SimpleQueueLoadingPolicyTests
	{
		
		public function SpecialHighestLowestQueueLoadingPolicyTests()
		{
			
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		override protected function getPolicy(totalGlobalConnections:int):IQueueLoadingPolicy
		{
			var repository:StubLoaderRepository = new StubLoaderRepository();
			repository.$openedConnections = totalGlobalConnections;
			
			var globalLoadingSettings:GlobalLoadingSettings = GlobalLoadingSettings.getInstance();
			globalLoadingSettings.maxConcurrentConnections = 6;
			
			var policy:IQueueLoadingPolicy = new SpecialHighestLowestQueueLoadingPolicy(repository, globalLoadingSettings);
			
			return policy;
		}
		
	}

}