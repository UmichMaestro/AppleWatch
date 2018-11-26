import CoreBluetooth

let TRANSFER_SERVICE_UUID = "7A8BF7DD-94B2-48A0-B79A-8D88561321A7"
let TRANSFER_CHARACTERISTIC_UUID = "871CDFD5-6743-492A-BF8B-00094DF4F057"
let NOTIFY_MTU = 20

let transferServiceUUID = CBUUID(string: TRANSFER_SERVICE_UUID)
let transferCharacteristicUUID = CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)

var bluetooth_manager = BluetoothManager()
var state:AppState = .bluetooth

var state_lookup = [0: "ViewBluetooth", 1: "ViewHello", 2:"ViewPhoneWrist", 3:"ViewLargestGesture", 4:"ViewLargestGestureObtained", 5:"ViewLessonSelect",
                    6: "ViewLessonSelected",
                    7: "ViewFreeplaySelected",
                    8: "ViewLevel1Selected",
                    9: "ViewLevel2Selected",
                    10: "ViewLevel3Selected",
                    11: "ViewLevel4Selected",
                    12: "ViewStart"]

var level_state_prim = 0
var level_state_second = 0

func set_level_state(prim:Int,second:Int){
    level_state_prim = prim
    level_state_second = second
}
