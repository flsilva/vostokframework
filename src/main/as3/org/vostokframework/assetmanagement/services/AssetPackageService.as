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
package org.vostokframework
{
	import org.as3collections.IList;
	import org.as3utils.StringUtil;
	import org.vostokframework.assetmanagement.AssetPackage;
	import org.vostokframework.assetmanagement.AssetsContext;
	import org.vostokframework.assetmanagement.errors.AssetPackageNotFoundError;
	import org.vostokframework.assetmanagement.errors.DuplicateAssetError;
	import org.vostokframework.assetmanagement.errors.DuplicateAssetPackageError;
	import org.vostokframework.assetmanagement.utils.LocaleUtil;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetPackageService
	{
		/**
		 * @private
		 */
		private var _context: AssetsContext;
		
		/**
		 * description
		 */
		public function AssetPackageService()
		{
			_context = AssetsContext.getInstance();
		}
		
		/**
		 * description
		 * 
		 * @param id
		 * @param locale
		 * @throws 	ArgumentError 	if the <code>assetPackageId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function assetPackageExists(assetPackageId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(assetPackageId)) throw new ArgumentError("Argument <assetPackageId> must not be null nor an empty String.");
			
			var composedId:String = LocaleUtil.composeId(assetPackageId, locale);
			return _context.assetPackageRepository.exists(composedId);
		}

		/**
		 * description
		 * 
		 * @param id
		 * @param locale
		 * @throws 	ArgumentError 	if the <code>assetPackageId</code> argument is <code>null</code> or <code>empty</code>.
		 * @throws 	org.vostokframework.assetmanagement.errors.DuplicateAssetPackageError 	if already exists an <code>AssetPackage</code> object stored with the provided <code>assetPackageId</code> and <code>locale</code>.
		 * @return
		 */
		public function createAssetPackage(assetPackageId:String, locale:String = null): AssetPackage
		{
			if (StringUtil.isBlank(assetPackageId)) throw new ArgumentError("Argument <assetPackageId> must not be null nor an empty String.");
			
			var assetPackage:AssetPackage = _context.assetPackageFactory.create(assetPackageId, locale);
			
			try
			{
				_context.assetPackageRepository.add(assetPackage);
			}
			catch(error:DuplicateAssetPackageError)
			{
				var message:String = error.message;
				message += "\n";
				message += "Make sure you have provided the correct <assetPackageId> and <locale> arguments:\n";
				message += "Provided <assetPackageId>: " + assetPackageId + "\n";
				message += "Provided <locale>: " + locale + "\n";
				message += "Final composed AssetPackage id: " + error.assetPackageId + "\n";
				message += "For further information please read the documentation section about the AssetPackage object.";
				
				throw new DuplicateAssetError(error.assetPackageId, message);
			}
			
			return assetPackage;
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function getAllAssetPackages(): IList
		{
			return _context.assetPackageRepository.findAll();
		}

		/**
		 * description
		 * 
		 * @param id
		 * @param locale
		 * @throws 	ArgumentError 	if the <code>assetPackageId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function getAssetPackage(assetPackageId:String, locale:String = null): AssetPackage
		{
			if (StringUtil.isBlank(assetPackageId)) throw new ArgumentError("Argument <assetPackageId> must not be null nor an empty String.");
			locale = LocaleUtil.validateLocale(locale);
			
			if (!assetPackageExists(assetPackageId, locale))
			{
				var message:String = "There is no AssetPackage object stored with id:\n";
				message += "<" + LocaleUtil.composeId(assetPackageId, locale) + ">.\n";
				message += "Use the method <AssetPackageService().assetPackageExists()> to check if an AssetPackage exists.\n";
				message += "In addition, make sure you have provided the correct <assetPackageId> and <locale> arguments:\n";
				message += "Provided <assetPackageId>: " + assetPackageId + "\n";
				message += "Provided <locale>: " + locale + "\n";
				message += "Final composed AssetPackage id: " + LocaleUtil.composeId(assetPackageId, locale) + "\n";
				message += "For further information please read the documentation section about the AssetPackage object.";
				
				throw new AssetPackageNotFoundError(LocaleUtil.composeId(assetPackageId, locale), message);
			}
			
			var composedId:String = LocaleUtil.composeId(assetPackageId, locale);
			
			return _context.assetPackageRepository.find(composedId);
		}

		/**
		 * description
		 */
		public function removeAllAssetPackages(): void
		{
			_context.assetPackageRepository.clear();
		}

		/**
		 * description
		 * 
		 * @param id
		 * @param locale
		 * @throws 	ArgumentError 	if the <code>assetPackageId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function removeAssetPackage(assetPackageId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(assetPackageId)) throw new ArgumentError("Argument <assetPackageId> must not be null nor an empty String.");
			
			locale = LocaleUtil.validateLocale(locale);
			var composedId:String = LocaleUtil.composeId(assetPackageId, locale);
			
			return _context.assetPackageRepository.remove(composedId);
		}

	}

}