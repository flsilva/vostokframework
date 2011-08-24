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
	import org.as3coreaddendum.system.IEquatable;
	import org.as3coreaddendum.system.IIndexable;
	import org.as3coreaddendum.system.IPriority;
	import org.vostokframework.VostokIdentification;

	import flash.events.IEventDispatcher;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public interface ILoader extends IEventDispatcher, IEquatable, IDisposable, IPriority, IIndexable
	{
		//TODO:mudar nomes para child/children (e.g. addChild(), addChildren())
		
		function get identification():VostokIdentification;
		
		function get openedConnections():int;
		
		//function get state():ILoaderState;//TODO:pensar sobre remover
		
		//function get stateHistory():IList;//TODO:teria q remover esse tbm
		
		function addLoader(loader:ILoader):void;
		
		function addLoaders(loaders:IList):void;
		
		function cancel():void;
		
		function cancelLoader(identification:VostokIdentification):void;
		
		function containsLoader(identification:VostokIdentification):Boolean;
		
		function equals(other:*):Boolean;
		
		function getLoader(identification:VostokIdentification):ILoader;
		
		function getLoaderState(identification:VostokIdentification):ILoaderState;
		
		function getParent(identification:VostokIdentification):ILoader;
		
		function load():void;
		
		function removeLoader(identification:VostokIdentification):void;
		
		function resumeLoader(identification:VostokIdentification):void;
		
		function stop():void;
		
		function stopLoader(identification:VostokIdentification):void;
		
	}

}