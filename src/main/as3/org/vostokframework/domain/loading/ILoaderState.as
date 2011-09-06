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
package org.vostokframework.loadingmanagement.domain
{
	import org.as3collections.IList;
	import org.as3coreaddendum.system.IDisposable;
	import org.vostokframework.VostokIdentification;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public interface ILoaderState extends IDisposable
	{
		
		function get isLoading():Boolean;
		
		function get isQueued():Boolean;
		
		function get isStopped():Boolean;
		
		function get openedConnections():int;
		
		function addChild(child:ILoader):void;
		
		function addChildren(children:IList):void;
		
		function cancel():void;
		
		function cancelChild(identification:VostokIdentification):void;
		
		function containsChild(identification:VostokIdentification):Boolean;
		
		function getChild(identification:VostokIdentification):ILoader;
		
		//function getLoaderState(identification:VostokIdentification):ILoaderState;
		
		function getParent(identification:VostokIdentification):ILoader;
		
		function load():void;
		
		function removeChild(identification:VostokIdentification):void;
		
		function resumeChild(identification:VostokIdentification):void;
		
		function setLoader(loader:ILoaderStateTransition):void;
		
		function stop():void;
		
		function stopChild(identification:VostokIdentification):void;
		
	}

}