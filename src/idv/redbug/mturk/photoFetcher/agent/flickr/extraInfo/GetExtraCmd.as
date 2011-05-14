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
    
    public class GetExtraCmd extends SimpleCommand
    {
        private var _flickrService          :FlickrService;
        private var _photo                  :Photo;
        private var _photoModel             :PhotoModel;
        
        public function GetExtraCmd( flickrService:FlickrService, photo:Photo, photoModel:PhotoModel, delay:Number=0 )
        {
            super(delay);
            
            _flickrService = flickrService;
            _photo = photo;
            _photoModel = photoModel;    
        }
        
        override final public function execute():void
        {
            var cmd:AsyncCommand = new AsyncCommand( 0,
                                                     new GetSizeCmd( _flickrService, _photo, _photoModel, 0),
                                                     new GetInfoCmd( _flickrService, _photo, _photoModel, 0)
                                                   );
            cmd.sgCommandComplete.addOnce( complete );
            cmd.start();
        }
        
    }
}