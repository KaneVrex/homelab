## The Devices

| Device                   | Role                          | CPU                   | RAM | Details                                                                                          |
| ------------------------ | ----------------------------- | --------------------- | --- | ------------------------------------------------------------------------------------------------ |
| Raspberry Pi  5 (RPI5)   | Service host, hub node        | Quad Arm Cortex-A76   | 8   | [link]()                                                                                         |
| Lenovo ThinkCentre M715q | Proxmox VM host, service host | AMD Ryzen 5<br>2400GE | 16  | [link](https://shop.lenovo.ua/computers/kompyuter-lenovo-thinkcentre-m715q-tiny-10vhs0xw00.html) |

### RPI5
Upgraded with fan stack and HAT extension plate with 2 NVME slots

#### Fan Config
Config located here: 
```bash
/boot/firmware/config.txt 
```
Appended with:
```
dtparam=fan_temp0=40000
dtparam=fan_temp0_hyst=10000
dtparam=fan_temp0_speed=125
```

==Note: the config is automatically generated and overwritten by NixOS, plan to adjust fan config in future.==

#### NVME Extension plate 
The device: [link](https://www.aliexpress.com/item/1005006533152444.html?pvid=115edd95-abe3-4fbd-912a-a57c6de90594&_t=gps-id%3ApcDetailTopMoreOtherSeller%2Cscm-url%3A1007.40050.354490.0%2Cpvid%3A115edd95-abe3-4fbd-912a-a57c6de90594%2Ctpp_buckets%3A668%232846%238111%231996&pdp_ext_f={%22order%22%3A%2294%22%2C%22eval%22%3A%221%22%2C%22sceneId%22%3A%2230050%22%2C%22fromPage%22%3A%22recommend%22}&pdp_npi=6%40dis!UAH!1239.09!1111.99!!!26.81!24.06!%40211b807017631819973644272eb924!12000037556241240!rec!UA!4077354482!X!1!0!n_tag%3A-29919%3Bd%3Ac68de4a7%3Bm03_new_user%3A-29895&utparam-url=scene%3ApcDetailTopMoreOtherSeller|query_from%3A|x_object_id%3A1005006533152444|_p_origin_prod%3A)
Hosts two NVME SSD's: 

| Drive name | Part Name | FS type | Label    | Size(GB) | Role              | Model        | Link                                                                    |
| ---------- | --------- | ------- | -------- | -------- | ----------------- | ------------ | ----------------------------------------------------------------------- |
| nvme0n1    | nvme0n1p1 | vfat    | FIRMWARE | 1        | bootloader        | Patriot P300 | [link](https://hard.rozetka.com.ua/ua/patriot_p300p128gm28/p265346706/) |
| nvme0n1    | nvme0n1p2 | ext4    | NIXIS_SD | 119      | root              | Patriot P300 | [link](https://hard.rozetka.com.ua/ua/patriot_p300p128gm28/p265346706/) |
| nvme1n1    | nvme1n1p1 | ext4    | NAS      | 931      | samba share drive | Kingston NV2 | [link](https://hard.rozetka.com.ua/ua/kingston-snv2s-1000g/p353568015/) |

### Lenovo ThinkCentre M715q

#### Removed
- sound module
- WIFi module
- WiFi Anthena
- Additional display port slot
- redundant metal parts 
- redundant connectors and buttons

#### Added
Additional SSD drive nvme0n1

| Drive name | Part Name | FS type | Label | Size(GB) | Role                | Model           | Link                                                                           |
| ---------- | --------- | ------- | ----- | -------- | ------------------- | --------------- | ------------------------------------------------------------------------------ |
| sda        | sda1      | ---     | ---   | 1 MB     | ---                 | ---             | ---                                                                            |
| sda        | sda2      | vfat    | ---   | 1        | bootloader          | Patriot P220    | [link](https://hard.rozetka.com.ua/ua/366882999/p366882999/)                   |
| sda        | sda3      | ext4    | ---   | 102      | root                | Patriot P220    | [link](https://hard.rozetka.com.ua/ua/366882999/p366882999/)                   |
| nvme0n1    | varies    | ext4    | ---   | 931      | vm and file storage | WD Green SN3000 | [link](https://hard.rozetka.com.ua/ua/western-digital-wds100t4g0e/p496268769/) |

#### Upgraded
SODIM 8GB RAM -> 16GB
	==Note: probably more is supported but in specification 16 is max for the board==
Default SSD replaced with WD Green SN3000