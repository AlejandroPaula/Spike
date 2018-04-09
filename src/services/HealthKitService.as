package services
{
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	
	import flash.events.Event;
	
	import database.BgReading;
	import database.LocalSettings;
	
	import events.FollowerEvent;
	import events.SettingsServiceEvent;
	import events.TransmitterServiceEvent;
	
	public class HealthKitService
	{
		private static var _instance:HealthKitService = new HealthKitService(); 
		private static var initialStart:Boolean = true;
		
		public function HealthKitService()
		{
			if (_instance != null) {
				throw new Error("HealthKitService class constructor can not be used");	
			}
		}
		
		public static function init():void {
			if (!initialStart)
				return;
			else
				initialStart = false;
			
			LocalSettings.instance.addEventListener(SettingsServiceEvent.SETTING_CHANGED, localSettingChanged);
			TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, bgReadingReceived);
			NightscoutService.instance.addEventListener(FollowerEvent.BG_READING_RECEIVED, bgReadingReceived);
			if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_HEALTHKIT_STORE_ON) == "true") {
				BackgroundFetch.initHealthKit();
			}
		}
		
		private static function localSettingChanged(event:SettingsServiceEvent):void {
			if (event.data == LocalSettings.LOCAL_SETTING_HEALTHKIT_STORE_ON) {
				if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_HEALTHKIT_STORE_ON) == "true") {
					//doesn't matterif it's already initiated
					BackgroundFetch.initHealthKit();
				}
			}
		}
		
		private static function bgReadingReceived(be:Event):void {
			trace("bgReadingReceived no HEALTHKIT");
			
			if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_HEALTHKIT_STORE_ON) == "false") {
				return;
			}
			
			trace("1");
			
			var bgReading:BgReading = BgReading.lastNoSensor();
			
			if (bgReading == null)
				return;
			if (bgReading.calculatedValue == 0) {
				return;
			}
			
			trace("2")
			/*if ((new Date()).valueOf() - bgReading.timestamp > 4 * 60 * 1000) {
				return;
			}*/
			
			trace(new Date(bgReading.timestamp));
			
			BackgroundFetch.storeBGInHealthKitMgDl(bgReading.calculatedValue, bgReading.timestamp);
		}
	}
}