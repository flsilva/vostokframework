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

package org.vostokframework.assetmanagement.domain.utils
{
	import org.flexunit.Assert;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=1)]
	public class LocaleUtilTests
	{
		
		public function LocaleUtilTests()
		{
			
		}
		
		///////////////////////////////////////
		// LocaleUtilTests().composeId TESTS //
		///////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function composeId_invalidId_ThrowsError(): void
		{
			LocaleUtil.composeId(null, "en-US");
		}
		
		[Test]
		public function composeId_validArgumentsWithoutLocale_checkIfIdMatches_ReturnsTrue(): void
		{
			var id:String = LocaleUtil.composeId("1.xyz");
			Assert.assertEquals("1.xyz-" + LocaleUtil.CROSS_LOCALE, id);
		}
		
		[Test]
		public function composeId_validArgumentsWithLocale_checkIfIdMatches_ReturnsTrue(): void
		{
			var id:String = LocaleUtil.composeId("1.xyz", "en-US");
			Assert.assertEquals("1.xyz-en-US", id);
		}
		
	}

}