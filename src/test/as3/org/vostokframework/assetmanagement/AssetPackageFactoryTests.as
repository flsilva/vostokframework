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

package org.vostokframework.assetmanagement
{
	import org.flexunit.Assert;
	import org.vostokframework.assetmanagement.utils.LocaleUtil;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=4)]
	public class AssetPackageFactoryTests
	{
		
		public function AssetPackageFactoryTests()
		{
			
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		private function getFactory():AssetPackageFactory
		{
			return new AssetPackageFactory();
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test]
		public function constructor_validInstantiation_ReturnsValidObject(): void
		{
			var factory:AssetPackageFactory = new AssetPackageFactory();
			Assert.assertNotNull(factory);
		}
		
		//////////////////////////////////////////
		// AssetPackageFactory().create() TESTS //
		//////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function create_invalidArguments_ThrowsError(): void
		{
			var factory:AssetPackageFactory = getFactory();
			factory.create(null);
		}
		
		[Test]
		public function create_validArgumentsWithoutLocale_ReturnsValidObject(): void
		{
			var factory:AssetPackageFactory = getFactory();
			var assetPackage:AssetPackage = factory.create("package-id");
			Assert.assertNotNull(assetPackage);
		}
		
		[Test]
		public function create_validArgumentsWithoutLocale_checkIfAssetPackageIdMatches_ReturnsTrue(): void
		{
			var factory:AssetPackageFactory = getFactory();
			var assetPackage:AssetPackage = factory.create("package-id");
			Assert.assertEquals("package-id-" + LocaleUtil.CROSS_LOCALE, assetPackage.id);
		}
		
		[Test]
		public function create_validArgumentsWithLocale_checkIfAssetPackageIdMatches_ReturnsTrue(): void
		{
			var factory:AssetPackageFactory = getFactory();
			var assetPackage:AssetPackage = factory.create("package-id", "en-US");
			Assert.assertEquals("package-id-en-US", assetPackage.id);
		}
		
		[Test]
		public function create_validArgumentsWithoutLocale_checkIfAssetPackageLocaleMatches_ReturnsTrue(): void
		{
			var factory:AssetPackageFactory = getFactory();
			var assetPackage:AssetPackage = factory.create("package-id");
			Assert.assertEquals(LocaleUtil.CROSS_LOCALE, assetPackage.locale);
		}
		
		[Test]
		public function create_validArgumentsWithLocale_checkIfAssetPackageLocaleMatches_ReturnsTrue(): void
		{
			var factory:AssetPackageFactory = getFactory();
			var assetPackage:AssetPackage = factory.create("package-id", "en-US");
			Assert.assertEquals("en-US", assetPackage.locale);
		}
		
	}

}