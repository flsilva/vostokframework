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
	import org.flexunit.Assert;
	import org.vostokframework.application.LoadingContext;
	import org.vostokframework.configuration.AssetConfiguration;
	import org.vostokframework.configuration.AssetPackageConfiguration;
	import org.vostokframework.configuration.VostokFrameworkConfiguration;
	import org.vostokframework.domain.loading.ILoadingSettingsFactory;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class XMLConfigurationParserTestsIntegration
	{
		
		public var parser:XMLConfigurationParser;
		
		public var assetParser:AssetXMLNodeParser;
		public var assetPackageParser:AssetPackageXMLNodeParser;
		public var settingsParser:LoadingSettingsXMLNodeParser;
		
		public function XMLConfigurationParserTestsIntegration()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			var loadingSettingsFactory:ILoadingSettingsFactory = LoadingContext.getInstance().loadingSettingsFactory;
			settingsParser = new LoadingSettingsXMLNodeParser(loadingSettingsFactory);
			
			assetParser = new AssetXMLNodeParser(settingsParser);
			assetPackageParser = new AssetPackageXMLNodeParser(assetParser);
			
			parser = new XMLConfigurationParser(assetPackageParser, settingsParser, loadingSettingsFactory);
		}
		
		[After]
		public function tearDown(): void
		{
			parser = null;
		}
		
		/////////////////////////////////////
		// XMLConfigurationParser().parse //
		/////////////////////////////////////
		
		// <index><default-settings>
		
		[Test]
		public function parse_argumentWithDefaultSettingsWithKillExternalCacheTrue_checkIfValueMatches(): void
		{
			var xml:XML = <index><default-settings><kill-external-cache>true</kill-external-cache></default-settings></index>;
			
			var configuration:VostokFrameworkConfiguration = parser.parse(xml);
			Assert.assertTrue(configuration.defaultSettings.cache.killExternalCache);
		}
		
		[Test]
		public function parse_argumentWithDefaultSettingsWithKillExternalCacheFalse_checkIfValueMatches(): void
		{
			var xml:XML = <index><default-settings><kill-external-cache>false</kill-external-cache></default-settings></index>;
			
			var configuration:VostokFrameworkConfiguration = parser.parse(xml);
			Assert.assertFalse(configuration.defaultSettings.cache.killExternalCache);
		}
		
		[Test]
		public function parse_argumentWithOnePackage_ReturnsConfigurationWithPackages(): void
		{
			var xml:XML = <index><packages><package id="test" /></packages></index>;
			
			var configuration:VostokFrameworkConfiguration = parser.parse(xml);
			Assert.assertNotNull(configuration.packages);
		}
		
		[Test]
		public function parse_argumentWithOnePackage_ReturnsConfigurationWithOnePackage(): void
		{
			var xml:XML = <index><packages><package id="test" /></packages></index>;
			
			var configuration:VostokFrameworkConfiguration = parser.parse(xml);
			
			var size:int = configuration.packages.size();
			Assert.assertEquals(1, size);
		}
		
		[Test]
		public function parse_argumentWithOnePackageWithOneAsset_ReturnsConfigurationWithOnePackageWithOneAsset(): void
		{
			var xml:XML = <index><packages><package id="test"><asset src="test-1.swf" /></package></packages></index>;
			
			var configuration:VostokFrameworkConfiguration = parser.parse(xml);
			var assetPacakgeConfiguration:AssetPackageConfiguration = configuration.packages.iterator().next();
			
			var size:int = assetPacakgeConfiguration.assets.size();
			Assert.assertEquals(1, size);
		}
		
		[Test]
		public function parse_argumentWithDefaultSettingsWithKillExternalCacheTrue_argumentWithAsset_checkIfAssetSettingsKillExternalCacheValueMatches(): void
		{
			var xml:XML = <index><default-settings><kill-external-cache>true</kill-external-cache></default-settings><packages><package id="test"><asset src="test.swf" /></package></packages></index>;
			
			var configuration:VostokFrameworkConfiguration = parser.parse(xml);
			
			var assetPackageConfiguration:AssetPackageConfiguration = configuration.packages.iterator().next();
			var assetConfiguration:AssetConfiguration = assetPackageConfiguration.assets.iterator().next();
			
			Assert.assertTrue(assetConfiguration.settings.cache.killExternalCache);
		}
		
		[Test]
		public function parse_argumentWithDefaultSettingsWithKillExternalCacheFalse_argumentWithAsset_checkIfAssetSettingsKillExternalCacheValueMatches(): void
		{
			var xml:XML = <index><default-settings><kill-external-cache>false</kill-external-cache></default-settings><packages><package id="test"><asset src="test.swf" /></package></packages></index>;
			
			var configuration:VostokFrameworkConfiguration = parser.parse(xml);
			
			var assetPacakgeConfiguration:AssetPackageConfiguration = configuration.packages.iterator().next();
			var assetConfiguration:AssetConfiguration = assetPacakgeConfiguration.assets.iterator().next();
			
			Assert.assertFalse(assetConfiguration.settings.cache.killExternalCache);
		}
		
	}

}