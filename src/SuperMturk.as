/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextField;
    
    import idv.redbug.robotbody.CoreContext;
    
    [SWF(width="1000", height="700", frameRate="30", backgroundColor="#FFFFFF")]
    public class SuperMturk extends Sprite
    {
        protected var _context:CoreContext;
        
        public function SuperMturk()
        {
            this._context = new CoreContext(this, SceneA);
        }
    }
}