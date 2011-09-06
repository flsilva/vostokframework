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

package org.vostokframework.domain.assets
{
	import org.flexunit.Assert;
	import org.vostokframework.VostokIdentification;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class AssetTests
	{
		private static const IDENTIFICATION:VostokIdentification = new VostokIdentification("asset-id", "en-US");
		private static const ASSET_SRC:String = "asset-path/asset.xml";
		private static const ASSET_TYPE:AssetType = AssetType.XML;
		
		private var _asset:Asset;
		
		public function AssetTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_asset = new Asset(IDENTIFICATION, ASSET_SRC, ASSET_TYPE);
		}
		
		[After]
		public function tearDown(): void
		{
			_asset = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidIdentification_ThrowsError(): void
		{
			new Asset(null, null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidSrc_ThrowsError(): void
		{
			new Asset(IDENTIFICATION, null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidType_ThrowsError(): void
		{
			new Asset(IDENTIFICATION, "asset-path/asset.xml", null);
		}
		
		[Test]
		public function constructor_validInstantiation_ReturnsValidObject(): void
		{
			var asset:Asset = new Asset(IDENTIFICATION, "asset-path/asset.xml", AssetType.XML);
			Assert.assertNotNull(asset);
		}
		
		////////////////////////////
		// Asset().equals() TESTS //
		////////////////////////////
		
		[Test]
		public function equals_compareTwoEqualAssets_ReturnsTrue(): void
		{
			var otherAsset:Asset = new Asset(_asset.identification, _asset.src, _asset.type);
			Assert.assertTrue(_asset.equals(otherAsset));
		}
		
		[Test]
		public function equals_compareTwoDifferentAssets_ReturnsFalse(): void
		{
			var identification:VostokIdentification = new VostokIdentification("other-asset-id", "en-US");
			var otherAsset:Asset = new Asset(identification, "asset-path/asset.xml", AssetType.XML);
			Assert.assertFalse(_asset.equals(otherAsset));
		}
		
		//////////////////////////////////
		// Asset().identification TESTS //
		//////////////////////////////////
		
		[Test]
		public function identification_checkIfIdMatches_ReturnsTrue(): void
		{
			Assert.assertTrue(_asset.identification.equals(IDENTIFICATION));
		}
		
		///////////////////////
		// Asset().src TESTS //
		///////////////////////
		
		[Test]
		public function src_checkIfSrcMatches_ReturnsTrue(): void
		{
			Assert.assertEquals(ASSET_SRC, _asset.src);
		}
		
		////////////////////////
		// Asset().type TESTS //
		////////////////////////
		
		[Test]
		public function type_checkIfTypeMatches_ReturnsTrue(): void
		{
			Assert.assertEquals(ASSET_TYPE, _asset.type);
		}
		
	}

}