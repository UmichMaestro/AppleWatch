import CoreBluetooth

let TRANSFER_SERVICE_UUID = "7A8BF7DD-94B2-48A0-B79A-8D88561321A7"
let TRANSFER_CHARACTERISTIC_UUID = "871CDFD5-6743-492A-BF8B-00094DF4F057"
let NOTIFY_MTU = 20

let transferServiceUUID = CBUUID(string: TRANSFER_SERVICE_UUID)
let transferCharacteristicUUID = CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)


