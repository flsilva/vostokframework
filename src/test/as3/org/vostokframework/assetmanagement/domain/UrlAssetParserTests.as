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

package org.vostokframework.assetmanagement.domain
{
	import org.flexunit.Assert;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=1)]
	public class UrlAssetParserTests
	{
		
		public function UrlAssetParserTests()
		{
			
		}
		
		/////////////////////////////////////////
		// UrlAssetParser().getAssetType TESTS //
		/////////////////////////////////////////
		
		[Test]
		public function getAssetType_unsupportedExtension_ReturnsNull(): void
		{
			var type:AssetType = UrlAssetParser.getInstance().getAssetType("1.xyz");
			Assert.assertNull(type);
		}
		
		[Test]
		public function getAssetType_validSourceAACExtension_checkIfReturnedTypeMatches_ReturnsTrue(): void
		{
			var type:AssetType = UrlAssetParser.getInstance().getAssetType("1.aac");
			Assert.assertEquals(AssetType.AAC, type);
		}
		
		[Test]
		public function getAssetType_validSourceXMLExtension_checkIfReturnedTypeMatches_ReturnsTrue(): void
		{
			var type:AssetType = UrlAssetParser.getInstance().getAssetType("http://www.test.com/asset-path/test-asset.XML");
			Assert.assertEquals(AssetType.XML, type);
		}
		
	}

}