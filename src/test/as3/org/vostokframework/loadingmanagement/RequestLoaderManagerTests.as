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

package org.vostokframework.loadingmanagement
{
	import org.flexunit.Assert;
	import org.vostokframework.loadingmanagement.policies.StubRequestLoadingPolicy;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=14)]
	public class RequestLoaderManagerTests
	{
		
		private var _requestLoaderManager:RequestLoaderManager;
		
		public function RequestLoaderManagerTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			var policy:StubRequestLoadingPolicy = new StubRequestLoadingPolicy();
			policy.globalMaxConnections = 6;
			policy.localMaxConnections = 3;
			
			_requestLoaderManager = new RequestLoaderManager(new RequestLoaderQueueManager(policy));
		}
		
		[After]
		public function tearDown(): void
		{
			_requestLoaderManager = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		
		
		///////////////////////////////////
		// RequestLoaderManager().load() //
		///////////////////////////////////
		
		[Test]
		public function load_validLoader_checkIfLoaderStatusIsTryingToConnect(): void
		{
			var requestLoader:StubRequestLoader = new StubRequestLoader("request-loader");
			_requestLoaderManager.load(requestLoader);
			Assert.assertEquals(RequestLoaderStatus.TRYING_TO_CONNECT, requestLoader.status);
		}
		
	}

}