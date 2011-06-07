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
package org.vostokframework.assetmanagement.domain
{
	import org.as3coreaddendum.system.Enum;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetType extends Enum
	{
		public static const AAC:AssetType = new AssetType("AAC", 0);
		public static const CSS:AssetType = new AssetType("CSS", 1);
		public static const IMAGE:AssetType = new AssetType("IMAGE", 2);
		public static const JSON:AssetType = new AssetType("JSON", 3);
		public static const MP3:AssetType = new AssetType("MP3", 4);
		public static const SWF:AssetType = new AssetType("SWF", 5);
		public static const VIDEO:AssetType = new AssetType("VIDEO", 6);
		public static const XML:AssetType = new AssetType("XML", 7);
		
		/**
		 * @private
		 */
		private static var _created :Boolean = false;
		
		{
			_created = true;
		}
		
		public function AssetType(name:String, ordinal:int)
		{
			super(name, ordinal);
			if (_created) throw new IllegalOperationError("The set of acceptable values by this Enumerated Type has already been created internally.");
		}

	}

}