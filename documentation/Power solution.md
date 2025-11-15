## The Devices 

| Device                   | V    | A    | W   | Connector              |
| ------------------------ | ---- | ---- | --- | ---------------------- |
| Lenovo ThinkCentre M715q | 20   | 3.25 | 65  | Lenovo Slim-Tip        |
| ASUS RT-AX86U Pro        | 19.5 | 2.31 | 45  | DC Barrel Jack 5.5x2.5 |
| RPI5                     | 5    | 3    | 15  | USB-C                  |
| Optical Adapter          | 12   | 0.5  | 6   | DC Barrel Jack 5.5x2.1 |
|                          |      |      |     |                        |
| Total                    |      |      | 131 |                        |
### Power supply

| Device          | Max out (W) | mAh   | Type C Output                                           | Type A Output                                 | Technology                                                                                                    | link                                                                                                                                    |
| --------------- | ----------- | ----- | ------------------------------------------------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| Baseus Amblight | 65          | 26800 | 5V-3A; <br>9V-3A; <br>12V-3A; <br>15V-3A; <br>20V-3.25A | 5V-3A; <br>9V-3A; <br>12V-2.5A; <br>10V-2.25A | Quick Charge; <br>Quick Charge 3.0;                                                                           | [link](https://hotline.ua/ua/mobile-universalnye-batarei/baseus-amblight-digital-display-26800mah-65w-black-p10022402113-00/?tab=about) |
| Baseus Bipow    | 20          | 20000 | 5V-3A;<br>9V-2.22A; <br>12V-1.5A                        | 5V-2A; <br>9V-2A; <br>12V-1.5A                | Quick Charge 3.0; <br>Power Delivery 3.0; <br>Samsung Adaptive Fast Charge; <br>Huawei Super Charge Protocol; | [link](https://hotline.ua/ua/mobile-universalnye-batarei/baseus-bipow-digital-display-20w-20000-mah-black-ppdml-m01/?tab=about)         |

### Connectors
| Input  | Output                 | V       | A   | W   | Tech | Link                                                                                                 |
| ------ | ---------------------- | ------- | --- | --- | ---- | ---------------------------------------------------------------------------------------------------- |
| Type C | Barrel Jack DC 5.5x2.5 | 18-20   | 3   | 65  | PD   | [link](https://brain.com.ua/ukr/Kabel_jhivlennya_USB_Type-C_to_DC-55-25_XoKo_XK-DC5525-p967358.html) |
| Type A | Barrel Jack DC 5.5x2.1 | 12      | 2   | 6   | ---  | [link](https://brain.com.ua/ukr/Kabel_jhivlennya_USB_to_DC-5-12_5V-12V_XoKo_XK-DC512-p931825.html)   |
| Type C | Lenovo Slim-Tip        | 18.5-20 | 5   | 100 | PD   | [link](https://rozetka.com.ua/ua/475527259/p475527259/)                                              |
| Type A | Type C                 | 5       | 3   | 15  |      | [link](https://rozetka.com.ua/ua/370922907/p370922907/)                                              |
potential replacement candidates 
https://prom.ua/ua/p2312500067-kabel-pitaniya-dlya.html

### Partitioning
Since it is impossible to get a power bank output higher than 100W or it will fall into power station group which is complete different prices we will separate the devices into two groups powered by two separate PSU devices.
Key points: 
	maximum battery lifetime for side devices
	internet uplink maximum uptime

#### Internet uplink stack

| Device            | V    | A    | W   | Connector              |
| ----------------- | ---- | ---- | --- | ---------------------- |
| ASUS RT-AX86U Pro | 19.5 | 2.31 | 45  | DC Barrel Jack 5.5x2.5 |
| Optical Adapter   | 12   | 0.5  | 6   | DC Barrel Jack 5.5x2.1 |
|                   |      |      |     |                        |
| Total             |      |      | 51  |                        |
connection

| Input  | Output                 | V     | A   | W   | Tech | Link                                                                                                 |
| ------ | ---------------------- | ----- | --- | --- | ---- | ---------------------------------------------------------------------------------------------------- |
| Type C | Barrel Jack DC 5.5x2.5 | 18-20 | 3   | 65  | PD   | [link](https://brain.com.ua/ukr/Kabel_jhivlennya_USB_Type-C_to_DC-55-25_XoKo_XK-DC5525-p967358.html) |
| Type A | Barrel Jack DC 5.5x2.1 | 12    | 2   | 6   | ---  | [link](https://brain.com.ua/ukr/Kabel_jhivlennya_USB_to_DC-5-12_5V-12V_XoKo_XK-DC512-p931825.html)   |

power supply

| Device          | Max out (W) | mAh   | Type C Output                                           | Type A Output                                 | Technology                          | link                                                                                                                                    |
| --------------- | ----------- | ----- | ------------------------------------------------------- | --------------------------------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| Baseus Amblight | 65          | 26800 | 5V-3A; <br>9V-3A; <br>12V-3A; <br>15V-3A; <br>20V-3.25A | 5V-3A; <br>9V-3A; <br>12V-2.5A; <br>10V-2.25A | Quick Charge; <br>Quick Charge 3.0; | [link](https://hotline.ua/ua/mobile-universalnye-batarei/baseus-amblight-digital-display-26800mah-65w-black-p10022402113-00/?tab=about) |

#### Server stack 

| Device                   | V   | A    | W   | Connector       |
| ------------------------ | --- | ---- | --- | --------------- |
| Lenovo ThinkCentre M715q | 20  | 3.25 | 65  | Lenovo Slim-Tip |
| RPI5                     | 5   | 3    | 15  | USB-C           |
|                          |     |      |     |                 |
| Total                    |     |      | 80  |                 |
connection

| Input  | Output          | V       | A   | W   | Tech | Link                                                    |
| ------ | --------------- | ------- | --- | --- | ---- | ------------------------------------------------------- |
| Type C | Lenovo Slim-Tip | 18.5-20 | 5   | 100 | PD   | [link](https://rozetka.com.ua/ua/475527259/p475527259/) |
| Type A | Type C          | 5       | 3   | 15  |      | [link](https://rozetka.com.ua/ua/370922907/p370922907/) |

power supply

| Device      | Max out (W) | mAh   | Type C Output | Type A Output | Technology                               | link                                                                                                            |
| ----------- | ----------- | ----- | ------------- | ------------- | ---------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Sandberg PD | 130         | 50000 | 100           | 30            | Quick Charge 3.0; <br>Power Delivery 3.0 | [link](https://hotline.ua/ua/mobile-universalnye-batarei/sandberg-pd-50000-mah-130w-pd-black-420-75/?tab=about) |
