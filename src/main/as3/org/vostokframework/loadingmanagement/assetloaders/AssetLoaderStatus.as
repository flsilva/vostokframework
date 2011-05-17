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
package org.vostokframework.loadingmanagement.assetloaders
{
	import org.as3coreaddendum.system.Enum;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoaderStatus extends Enum
	{
		public static const CANCELED:AssetLoaderStatus = new AssetLoaderStatus("CANCELED", 0);
		public static const COMPLETE:AssetLoaderStatus = new AssetLoaderStatus("COMPLETE", 1);
		public static const FAILED_ASYNC_ERROR:AssetLoaderStatus = new AssetLoaderStatus("FAILED ASYNC ERROR", 2);
		public static const FAILED_EXHAUSTED_ATTEMPTS:AssetLoaderStatus = new AssetLoaderStatus("FAILED EXHAUSTED ATTEMPTS", 3);
		public static const FAILED_IO_ERROR:AssetLoaderStatus = new AssetLoaderStatus("FAILED IO ERROR", 4);
		public static const FAILED_LATENCY_TIMEOUT:AssetLoaderStatus = new AssetLoaderStatus("FAILED LATENCY TIMEOUT", 5);
		public static const FAILED_SECURITY_ERROR:AssetLoaderStatus = new AssetLoaderStatus("FAILED SECURITY ERROR", 6);
		public static const FAILED_UNKNOWN_ERROR:AssetLoaderStatus = new AssetLoaderStatus("FAILED UNKNOWN ERROR", 7);
		public static const LOADING:AssetLoaderStatus = new AssetLoaderStatus("LOADING", 8);
		public static const QUEUED:AssetLoaderStatus = new AssetLoaderStatus("QUEUED", 9);
		public static const STOPPED:AssetLoaderStatus = new AssetLoaderStatus("STOPPED", 10);
		public static const TRYING_TO_CONNECT:AssetLoaderStatus = new AssetLoaderStatus("TRYING TO CONNECT", 11);
		
		/**
		 * @private
		 */
		private static var _created :Boolean = false;
		
		{
			_created = true;
		}

		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function AssetLoaderStatus(name:String, ordinal:int)
		{
			super(name, ordinal);
			if (_created) throw new IllegalOperationError("The set of acceptable values by this Enumerated Type has already been created internally.");
		}
		
	}

}