/*
 * Licensed under the MIT License
 * 
 * Copyright 2011 (c) Flávio Silva, flsilva.com
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
	import org.as3utils.StringUtil;
	import org.vostokframework.assetmanagement.utils.LocaleUtil;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetPackageFactory
	{
		
		public function AssetPackageFactory()
		{
			
		}

		/**
		 * description
		 * 
		 * @param id
		 * @param locale
		 * @throws 	ArgumentError 	if the <code>id</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function create(id:String, locale:String = null): AssetPackage
		{
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			locale = validateLocale(locale);
			
			id = composeId(id, locale);
			
			return instanciate(id, locale);
		}
		
		/**
		 * @private
		 */
		protected function instanciate(id:String, locale:String): AssetPackage
		{
			return new AssetPackage(id, locale);
		}
		
		/**
		 * @private
		 */
		protected function composeId(id:String, locale:String = null): String
		{
			return LocaleUtil.composeId(id, locale);
		}
		
		/**
		 * @private
		 */
		protected function validateLocale(locale:String = null): String
		{
			return LocaleUtil.validateLocale(locale);
		}

	}

}