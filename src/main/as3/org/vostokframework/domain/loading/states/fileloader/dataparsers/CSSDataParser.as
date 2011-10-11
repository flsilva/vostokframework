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
package org.vostokframework.domain.loading.states.fileloader.dataparsers
{
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.domain.loading.IDataParser;

	import flash.text.StyleSheet;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class CSSDataParser implements IDataParser
	{
		
		/**
		 * description
		 * 
		 */
		public function CSSDataParser()
		{
			
		}
		
		public function equals(other : *): Boolean
		{
			if (this == other) return true;
			return ReflectionUtil.classPathEquals(this, other);
		}
		
		/**
		 * description
		 */
		public function parse(data:*): *
		{
			var ss:StyleSheet = new StyleSheet();
			ss.parseCSS(data);
			return ss;
		}

	}

}