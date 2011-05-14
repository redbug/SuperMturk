/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.photoFetcher.agent.flickr.extraInfo
{
    import com.adobe.webapis.flickr.FlickrService;
    import com.adobe.webapis.flickr.Photo;
    
    import idv.redbug.mturk.photo.PhotoModel;
    import idv.redbug.robotbody.commands.AsyncCommand;
    import idv.redbug.robotbody.commands.SimpleCommand;
    
    public class GetPhotosExtraCmd extends SimpleCommand
    {
        private var _flickrService          :FlickrService;
        private var _photoList              :Array;
        private var _photoModelList         :Vector.<PhotoModel>;
        
        public function GetPhotosExtraCmd( flickrService:FlickrService, photoList:Array, photoModelList:Vector.<PhotoModel>, delay:Number=0 )
        {
            super( delay );
            
            _flickrService = flickrService;
            _photoList = photoList;
            _photoModelList = photoModelList;
            
        }
        
        override public function execute():void
        {
            var cmdArray:Array = [];
            var numPhotos:int = _photoList.length;
            
            for( var i:int=0; i<numPhotos; ++i )
            {
                cmdArray.push( new GetExtraCmd( _flickrService, _photoList[i], _photoModelList[i], 0) );                
            }
            
            var cmd:AsyncCommand = new AsyncCommand(0, cmdArray);
            cmd.sgCommandComplete.addOnce( complete );
            cmd.start();
        }
    }
}