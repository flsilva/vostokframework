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
	import org.vostokframework.domain.loading.settings.LoadingSettings;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingSettingsXMLNodeParserTests
	{
		
		public var parser:LoadingSettingsXMLNodeParser;
		
		public function LoadingSettingsXMLNodeParserTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			parser = new LoadingSettingsXMLNodeParser(LoadingContext.getInstance().loadingSettingsFactory);
		}
		
		[After]
		public function tearDown(): void
		{
			parser = null;
		}
		
		//////////////////////////////////////////
		// LoadingSettingsXMLNodeParser().parse //
		//////////////////////////////////////////
		
		[Test]
		public function parse_nullArgument_ReturnsNull(): void
		{
			var settings:LoadingSettings = parser.parse(null);
			Assert.assertNull(settings);
		}
		
		// <default-settings><allow-internal-cache>
		
		[Test]
		public function parse_argumentWithAllowInternalCacheTrue_verifyValueMatches(): void
		{
			var xml:XML = <default-settings><allow-internal-cache>true</allow-internal-cache></default-settings>;
			
			var settings:LoadingSettings = parser.parse(xml);
			Assert.assertTrue(settings.cache.allowInternalCache);
		}
		
		[Test]
		public function parse_argumentWithAllowInternalCacheFalse_verifyValueMatches(): void
		{
			var xml:XML = <default-settings><allow-internal-cache>false</allow-internal-cache></default-settings>;
			
			var settings:LoadingSettings = parser.parse(xml);
			Assert.assertFalse(settings.cache.allowInternalCache);
		}
		
		// <default-settings><kill-external-cache>
		
		[Test]
		public function parse_argumentWithKillExternalCacheTrue_verifyValueMatches(): void
		{
			var xml:XML = <default-settings><kill-external-cache>true</kill-external-cache></default-settings>;
			
			var settings:LoadingSettings = parser.parse(xml);
			Assert.assertTrue(settings.cache.killExternalCache);
		}
		
		[Test]
		public function parse_argumentWithKillExternalCacheFalse_verifyValueMatches(): void
		{
			var xml:XML = <default-settings><kill-external-cache>false</kill-external-cache></default-settings>;
			
			var settings:LoadingSettings = parser.parse(xml);
			Assert.assertFalse(settings.cache.killExternalCache);
		}
		
	}

}