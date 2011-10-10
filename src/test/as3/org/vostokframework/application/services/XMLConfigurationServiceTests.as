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

package org.vostokframework.application.services
{
	import org.flexunit.Assert;
	import org.vostokframework.application.AssetsContext;
	import org.vostokframework.domain.assets.AssetPackageRepository;
	import org.vostokframework.domain.assets.AssetRepository;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class XMLConfigurationServiceTests
	{
		private var _service:XMLConfigurationService;
		
		public function XMLConfigurationServiceTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			AssetsContext.getInstance().setAssetRepository(new AssetRepository());
			AssetsContext.getInstance().setAssetPackageRepository(new AssetPackageRepository());
			
			_service = new XMLConfigurationService();
		}
		
		[After]
		public function tearDown(): void
		{
			_service = null;
		}
		
		/////////////////////////////////////////////////
		// XMLConfigurationService().configure() TESTS //
		/////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function configure_invalidArgument_ThrowsError(): void
		{
			_service.configure(null);
		}
		
		[Test]
		public function configure_validArgument_checksIfAssetPackageExists_ReturnsTrue(): void
		{
			var xml:XML = <index><packages><package id="package-1" /></packages></index>;
			_service.configure(xml);
			
			var assetPackageService:AssetPackageService = new AssetPackageService();
			
			var exists:Boolean = assetPackageService.assetPackageExists("package-1");
			Assert.assertTrue(exists);
		}
		
	}

}