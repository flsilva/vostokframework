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

package org.vostokframework.configuration.parsers.xml
{
	import org.as3collections.ICollection;
	import org.as3collections.IList;
	import org.flexunit.Assert;
	import org.vostokframework.application.LoadingContext;
	import org.vostokframework.configuration.AssetConfiguration;
	import org.vostokframework.domain.assets.AssetType;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class AssetXMLNodeParserTests
	{
		
		public var parser:AssetXMLNodeParser;
		
		public function AssetXMLNodeParserTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			var loadingSettingsXMLNodeParser:LoadingSettingsXMLNodeParser = new LoadingSettingsXMLNodeParser(LoadingContext.getInstance().loadingSettingsFactory);
			
			parser = new AssetXMLNodeParser(loadingSettingsXMLNodeParser);
		}
		
		[After]
		public function tearDown(): void
		{
			parser = null;
		}
		
		////////////////////////////////
		// AssetXMLNodeParser().parse //
		////////////////////////////////
		
		// <index><packages><package><asset>
		
		[Test(expects="org.vostokframework.configuration.parsers.xml.errors.XMLConfigurationParserError")]
		public function parse_argumentWithAssetWithoutSrc_ThrowsError(): void
		{
			var xml:XML = <package><asset></asset></package>;
			
			var assetsNode:XMLList = xml.children().(name().localName == "asset");
			parser.parse(assetsNode);
		}
		
		[Test]
		public function parse_argumentWithTwoValidAssets_checkCollectionSize_ReturnsTwo(): void
		{
			var xml:XML = <package><asset src="a.xml" /><asset src="b.xml" /></package>;
			
			var assetsNode:XMLList = xml.children().(name().localName == "asset");
			var assets:ICollection = parser.parse(assetsNode);
			
			var size:int = assets.size();
			Assert.assertEquals(2, size);
		}
		
		[Test]
		public function parse_argumentWithAsset_verifyAssetSrc(): void
		{
			var xml:XML = <package><asset src="a.xml" /></package>;
			
			var assetsNode:XMLList = xml.children().(name().localName == "asset");
			var assets:IList = parser.parse(assetsNode);
			
			var assetConfiguration:AssetConfiguration = assets.getAt(0);
			Assert.assertEquals("a.xml", assetConfiguration.src);
		}
		
		[Test]
		public function parse_argumentWithAsset_verifyAssetId(): void
		{
			var xml:XML = <package><asset src="a.xml" id="asset-1" /></package>;
			
			var assetsNode:XMLList = xml.children().(name().localName == "asset");
			var assets:IList = parser.parse(assetsNode);
			
			var assetConfiguration:AssetConfiguration = assets.getAt(0);
			Assert.assertEquals("asset-1", assetConfiguration.id);
		}
		
		[Test]
		public function parse_argumentWithAsset_verifyAssetType(): void
		{
			var xml:XML = <package><asset src="a.xml" type="swf" /></package>;
			
			var assetsNode:XMLList = xml.children().(name().localName == "asset");
			var assets:IList = parser.parse(assetsNode);
			
			var assetConfiguration:AssetConfiguration = assets.getAt(0);
			Assert.assertEquals(AssetType.SWF, assetConfiguration.type);
		}
		
		//SETTINGS
		
		[Test]
		public function parse_argumentWithAsset_killExternalCacheAttributeTrue_AssertTrue(): void
		{
			var xml:XML = <package><asset src="a.xml" kill-external-cache="true" /></package>;
			
			var assetsNode:XMLList = xml.children().(name().localName == "asset");
			var assets:IList = parser.parse(assetsNode);
			
			var assetConfiguration:AssetConfiguration = assets.getAt(0);
			Assert.assertTrue(assetConfiguration.settings.cache.killExternalCache);
		}
		
		[Test]
		public function parse_argumentWithAsset_killExternalCacheAttributeFalse_AssertFalse(): void
		{
			var xml:XML = <package><asset src="a.xml" kill-external-cache="false" /></package>;
			
			var assetsNode:XMLList = xml.children().(name().localName == "asset");
			var assets:IList = parser.parse(assetsNode);
			
			var assetConfiguration:AssetConfiguration = assets.getAt(0);
			Assert.assertFalse(assetConfiguration.settings.cache.killExternalCache);
		}
		
		[Test]
		public function parse_argumentWithAsset_killExternalCacheNodeTrue_AssertTrue(): void
		{
			var xml:XML = <package><asset src="a.xml"><settings><kill-external-cache>true</kill-external-cache></settings></asset></package>;
			
			var assetsNode:XMLList = xml.children().(name().localName == "asset");
			var assets:IList = parser.parse(assetsNode);
			
			var assetConfiguration:AssetConfiguration = assets.getAt(0);
			Assert.assertTrue(assetConfiguration.settings.cache.killExternalCache);
		}
		
		[Test]
		public function parse_argumentWithAsset_killExternalCacheNodeFalse_AssertFalse(): void
		{
			var xml:XML = <package><asset src="a.xml"><settings><kill-external-cache>false</kill-external-cache></settings></asset></package>;
			
			var assetsNode:XMLList = xml.children().(name().localName == "asset");
			var assets:IList = parser.parse(assetsNode);
			
			var assetConfiguration:AssetConfiguration = assets.getAt(0);
			Assert.assertFalse(assetConfiguration.settings.cache.killExternalCache);
		}
		
		[Test]
		public function parse_argumentWithAsset_killExternalCacheAttributeTrue_killExternalCacheNodeFalse_AssertFalse(): void
		{
			var xml:XML = <package><asset src="a.xml" kill-external-cache="true"><settings><kill-external-cache>false</kill-external-cache></settings></asset></package>;
			
			var assetsNode:XMLList = xml.children().(name().localName == "asset");
			var assets:IList = parser.parse(assetsNode);
			
			var assetConfiguration:AssetConfiguration = assets.getAt(0);
			Assert.assertFalse(assetConfiguration.settings.cache.killExternalCache);
		}
		
		[Test]
		public function parse_argumentWithAsset_killExternalCacheAttributeFalse_killExternalCacheNodeTrue_AssertTrue(): void
		{
			var xml:XML = <package><asset src="a.xml" kill-external-cache="false"><settings><kill-external-cache>true</kill-external-cache></settings></asset></package>;
			
			var assetsNode:XMLList = xml.children().(name().localName == "asset");
			var assets:IList = parser.parse(assetsNode);
			
			var assetConfiguration:AssetConfiguration = assets.getAt(0);
			Assert.assertTrue(assetConfiguration.settings.cache.killExternalCache);
		}
		
	}

}