'#Picaxe-08M2
#Com 5
'Set com Port for programming and serial terminal monitoring
#Terminal 2400
'Directive to set the Serial Terminal ro 4800 Baud
#No_Data
'Directive to prevent data table download
DisableBOD
'Select uPower Sleep mode

Pre:
 high 1						'Preset TTL Logic Level to Pin 1 Data To Pi GPIO ttyAMA0
 b21 = 1						'Preload Good data 
 b22 = 1						'Preload Bad data 
 b8  = "1"  					'Node ID
 time = 123						'Advance clock for a faster initial Server Data Result
 tune 0,0,(21,22,23)				'Start Up Twinkle
 
do 

RF_RX:
 serin 3,T2400,(":0",b8),b9,b10,b11,b12,b13	'Listen for ":0X" and read in following 4 bytes
								'b9=Channel, b10 and b11 Lo and Hi byte data, b12 CSum
Check_Sum:
 b14 = b8 XOR b9 XOR b10 XOR b11 XOR b12		'Check data with CSum
 serout 0,N2400,(13,10,"ASK_RF_Rx:",9,":0",b8,b9,32,#w5,32,#b12,32,#b14,9,#b13,13,10)	'Echo data to editor 

Good_Rx_Data: 
 if b14 = 0 then 				'If CSum result = GOOD = a zero 
  gosub RF_Tx				'Go send the data to the Pi / Cayenne
  inc b21					'Inc QoS counter
  toggle 2					'Good data TIC
'  tune 0,0,(32,33,34)			'Optional annoying system BEEP if good data Rx
Bad_Rx_Data: 
 else						'Otherwise
  inc b22					'Bad data counter
  toggle 2					'Bad data TIC						
  pause 100					'Bad data TIC						
  toggle 2					'Bad data TIC					
  tune 0,3,(34,33,32)			'Optional system BUZZ if bady data Rx
 endif						

LoRa_Rssi: 
 b9 = "V"
 w5 = b13
 b14 = 0					'Dummy Check Sum 
 gosub RF_Tx

'Server_Data:
'if time > 10 then				'If X seconds of processor time has elapsed then
' time = 0					'Reset the time

'Read_Temperature:				'Read DS18B20 on pin 4 IF fitted WPU = NO 4k7 resistor needed)
' pokesfr %10001100, %00010000		'WPU Power ON selected Pins (NO 4k7 resistor needed)
' readtemp12 4,w0				'Read HIGH resolution 12 bit DS18Btemperature by default
' pokesfr %10001100, %00000000		'WPU Power OFF selected Pins
' w0 = w0 * 10 / 16			'High Res = Decimal Deg C gives TENTHS of a degree Cee
' b9 = "W"
' w5 = w0
' b14 = 0					'Dummy Check Sum 
' gosub RF_Tx
 
'Read_Light:					'Read DS18B20 on pin 4 IF fitted WPU = NO 4k7 resistor needed)
' pokesfr %10001100, %00000100		'WPU Power ON selected Pins (NO 4k7 resistor needed)
' input 2
' pause 100
' readadc10 2, w0				'Read HIGH resolution 12 bit DS18Btemperature by default
' pokesfr %10001100, %00000000		'WPU Power OFF selected Pins
' w0 = 1024 - w0				'High Res = Decimal Deg C gives TENTHS of a degree Cee
' b9 = "X"
' w5 = w0
' b14 = 0					'Dummy Check Sum 
' gosub RF_Tx

endif

loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RF_Tx:
 serout 1,T2400,(":0",b8,44,b9,44,#w5,44,#b14,13,10)	'Tx Data packet
 serout 0,N2400,("LoRa Txd = ",9,":0",b8,44,b9,44,#w5,44,#b14,13,10)	'Echo Local Data to Programming Lead
 nap 5								'Inter Packet Fixed Min Pacing delay
return


