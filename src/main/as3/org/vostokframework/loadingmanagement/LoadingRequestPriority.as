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
package org.vostokframework.loadingmanagement
{
	import org.as3coreaddendum.system.Enum;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingRequestPriority extends Enum
	{
		public static const LOWEST:LoadingRequestPriority = new LoadingRequestPriority("LOWEST", 0);
		public static const LOW:LoadingRequestPriority = new LoadingRequestPriority("LOW", 1);
		public static const MEDIUM:LoadingRequestPriority = new LoadingRequestPriority("MEDIUM", 2);
		public static const HIGH:LoadingRequestPriority = new LoadingRequestPriority("HIGH", 3);
		public static const HIGHEST:LoadingRequestPriority = new LoadingRequestPriority("HIGHEST", 4);
				
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
		public function LoadingRequestPriority(name:String, ordinal:int)
		{
			super(name, ordinal);
			if (_created) throw new IllegalOperationError("The set of acceptable values by this Enumerated Type has already been created internally.");
		}

	}

}