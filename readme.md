# Sample Code Project

## Design Approach
  * Use Async Blocks and/or operation queue for API calls
  * Probably use singleton "Manager" classes to wrap up WS and Location Services calls
  * Use simple storyboard and autolayout for UI
    * BONUS: Make UI sexy
  * Get location from CoreLocation with background notification API and process for deltas from previous location
    * ~~BONUS: Use Foursquare [Venues API](https://developer.foursquare.com/docs/venues/search) to be more intelligent about location changes~~ _Venues API doesn't include venue perimeter making this more difficult than time allows_
    * BONUS: If arrival/departure of venue detected post local notification
  * Set update interval on CL to conserve battery power
  * Write comprehensive README.md file with OmniGraffle Pro generated class diagram
  * Use ~~SBJSON framework for JSON Parsing~~
    * **UPDATE:** [Apple `NSJSONSerialization` is faster](http://stackoverflow.com/questions/16218583/jsonkit-benchmarks)

## Implementation Steps
  * Search web for WS API examples
    * [Ray Wenderlick](http://www.raywenderlich.com/2965/how-to-write-an-ios-app-that-uses-a-web-service) example uses ASI & JSON but has overly-simplistic object model
    * [AppCoda](http://www.appcoda.com/fetch-parse-json-ios-programming-tutorial/) example has good design structure but uses buggy `NSURLConnection sendAsynchronousRequest`
  * Base app off of AppCoda project ~~and copy in ASI & SBJSON frameworks and calls~~
  * **I should** rename the classes next but I'm not due to time-constraints and desire to make clear what is my code and what came from the source
  * Update: Turns most of the original sample app was overkill for my needs or too far off base so I just wrote my own according to the **App Structure** section below.

    
## App Structure
  * Location Manager - (singleton) handles all of the CoreLocation stuff
  * Connection Manager - (singlton) handles all of the 1Q API stuff
  * Location - (data model) encapsulates all location tracking information
  * ~~REST Helper - static utility class that wrappers up repeatable API call stuff~~ This would be required in a more complex example but wasn't needed for this demo.
    


