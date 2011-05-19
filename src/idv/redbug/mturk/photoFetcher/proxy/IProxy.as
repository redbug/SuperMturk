/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.photoFetcher.proxy
{
    import flash.events.Event;

	public interface IProxy
	{
        function reset():void;
        function destroy():void;
        
        //connect to API
        function connect():void;
        function onConnectReady( event:Event=null ):void;
        function onConnectError( event:Event=null ):void;
        
        //Send searching query to API
        function search( keyword:String, numResult:int, restaurantAddr:String=null ):void;
        function onSearchComplete( event:Event=null ):void;
        function onSearchError( event:Event=null ):void;
	}
}