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
package org.vostokframework.loadingmanagement.services
{
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoadingService
	{
		/**
		 * @private
		 */
		private var _context:LoadingManagementContext;

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function cancel(assetId:String, locale:String = null): Boolean
		{
			return false;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 */
		public function getAssetData(assetId:String, locale:String = null): *
		{
			return null;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function getAssetLoadingMonitor(assetId:String, locale:String = null): ILoadingMonitor
		{
			return null;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function isLoaded(assetId:String, locale:String = null): Boolean
		{
			return false;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function isLoading(assetId:String, locale:String = null): Boolean
		{
			return false;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function isQueued(assetId:String, locale:String = null): Boolean
		{
			return false;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function resume(assetId:String, locale:String = null): Boolean
		{
			return false;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function stop(assetId:String, locale:String = null): Boolean
		{
			return false;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function unload(assetId:String, locale:String = null): Boolean
		{
			return false;
		}

	}

}