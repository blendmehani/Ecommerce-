--CREATE DATABASE Ecommerce IF IT DOESN'T EXIST
IF DB_ID('Ecommerce') IS NULL
BEGIN 
	CREATE DATABASE Ecommerce
END

GO

--USE DATABASE Ecommerce
USE Ecommerce

GO

--CREATING ProductCategory TABLE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ProductCategory'))
BEGIN

	CREATE TABLE ProductCategory(
	PCId INT PRIMARY KEY IDENTITY (1,1),
	Category NVARCHAR(100))

	IF NOT EXISTS ( SELECT PCID FROM ProductCategory WHERE Category='Laptop')
	BEGIN
	INSERT INTO ProductCategory VALUES ('Laptop')
	END

	IF NOT EXISTS ( SELECT PCID FROM ProductCategory WHERE Category='Smartphone')
	BEGIN
	INSERT INTO ProductCategory VALUES ('Smartphone')
	END

	IF NOT EXISTS ( SELECT PCID FROM ProductCategory WHERE Category='Camera')
	BEGIN
	INSERT INTO ProductCategory VALUES ('Camera')
	END

	IF NOT EXISTS ( SELECT PCID FROM ProductCategory WHERE Category='Accessory')
	BEGIN
	INSERT INTO ProductCategory VALUES ('Accessory')
	END

END

GO

--CREATING ProductSubCategory TABLE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ProductSubCategory'))
BEGIN

	CREATE TABLE ProductSubCategory(
	PSCId INT PRIMARY KEY IDENTITY(1,1),
	Subcategory NVARCHAR(100),
	PCId INT FOREIGN KEY REFERENCES ProductCategory(PCId))

	IF NOT EXISTS ( SELECT PCID FROM ProductSubCategory WHERE Subcategory='Asus')
	BEGIN
	INSERT INTO ProductSubCategory VALUES ('Asus',1)
	END

	IF NOT EXISTS ( SELECT PCID FROM ProductSubCategory WHERE Subcategory='Lenovo')
	BEGIN
	INSERT INTO ProductSubCategory VALUES ('Lenovo',1)
	END

	IF NOT EXISTS ( SELECT PCID FROM ProductSubCategory WHERE Subcategory='Samsung')
	BEGIN
	INSERT INTO ProductSubCategory VALUES ('Samsung',2)
	END

	IF NOT EXISTS ( SELECT PCID FROM ProductSubCategory WHERE Subcategory='Iphone')
	BEGIN
	INSERT INTO ProductSubCategory VALUES ('Iphone',2)
	END

	IF NOT EXISTS ( SELECT PCID FROM ProductSubCategory WHERE Subcategory='Canon')
	BEGIN
	INSERT INTO ProductSubCategory VALUES ('Canon',3)
	END

	IF NOT EXISTS ( SELECT PCID FROM ProductSubCategory WHERE Subcategory='Nikon')
	BEGIN
	INSERT INTO ProductSubCategory VALUES ('Nikon',3)
	END

	IF NOT EXISTS ( SELECT PCID FROM ProductSubCategory WHERE Subcategory='Mouse')
	BEGIN
	INSERT INTO ProductSubCategory VALUES ('Mouse',4)
	END

	IF NOT EXISTS ( SELECT PCID FROM ProductSubCategory WHERE Subcategory='Headphone')
	BEGIN
	INSERT INTO ProductSubCategory VALUES ('Headphone',4)
	END

END

GO

--CREATING Product TABLE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Product'))
BEGIN

	CREATE TABLE Product(
	PId INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(200) NOT NULL,
	Price MONEY NOT NULL,
	OldPrice MONEY NULL,
	Description NVARCHAR(MAX),
	DetailedDescription NVARCHAR(MAX) NOT NULL,
	Color NVARCHAR(50) NOT NULL,
	Size NVARCHAR(50) NOT NULL,
	Weight DECIMAL(7,2),
	Image1 NVARCHAR(MAX) NULL,
	Image2 NVARCHAR(MAX) NULL,
	Image3 NVARCHAR(MAX) NULL,
	Image4 NVARCHAR(MAX) NULL,
	Image5 NVARCHAR(MAX) NULL,
	PCID INT FOREIGN KEY REFERENCES ProductCategory(PCID) ON DELETE CASCADE,
	PSCId INT FOREIGN KEY REFERENCES ProductSubCategory(PSCId) ON DELETE CASCADE,
	DateInserted DateTime)

END

GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Admin'))
BEGIN
Create Table Admin(
AID INT PRIMARY KEY IDENTITY(1,1),
username NVARCHAR(50),
password NVARCHAR(MAX)
)
END

GO

--CREATING Laptops VIEW
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Laptops'))
BEGIN
	DROP VIEW Laptops
END

GO

CREATE VIEW Laptops AS
SELECT PId, Name, Price, OldPrice, Weight, Description, DetailedDescription, Color, Size, Image1, Image2, Image3, Image4, Image5,Category,Subcategory,DateInserted
FROM Product P
INNER JOIN ProductCategory PC on PC.PCId = P.PCID
INNER JOIN ProductSubCategory PSC on PSC.PSCId = P.PSCId
WHERE PC.Category = 'Laptop'
	
GO

--CREATING SmartPhones VIEW
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'SmartPhones'))
BEGIN
	DROP VIEW SmartPhones
END

GO

CREATE VIEW SmartPhones AS
SELECT PId, Name, Price, OldPrice, Weight, Description, DetailedDescription, Color, Size, Image1, Image2, Image3, Image4, Image5,Category,Subcategory,DateInserted
FROM Product P
INNER JOIN ProductCategory PC on PC.PCId = P.PCID
INNER JOIN ProductSubCategory PSC on PSC.PSCId = P.PSCId
WHERE PC.Category = 'SmartPhone'

GO

--CREATING Cameras VIEW
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Cameras'))
BEGIN
	DROP VIEW Cameras
END

GO

CREATE VIEW Cameras AS
SELECT PId, Name, Price, OldPrice, Weight, Description, DetailedDescription, Color, Size, Image1, Image2, Image3, Image4, Image5,Category,Subcategory,DateInserted
FROM Product P
INNER JOIN ProductCategory PC on PC.PCId = P.PCID
INNER JOIN ProductSubCategory PSC on PSC.PSCId = P.PSCId
WHERE PC.Category = 'Camera'

GO

--CREATING Accessories VIEW
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Accessories'))
BEGIN
	DROP VIEW Accessories
END

GO

CREATE VIEW Accessories AS
SELECT PId, Name, Price, OldPrice, Weight, Description, DetailedDescription, Color, Size, Image1, Image2, Image3, Image4, Image5,Category,Subcategory,DateInserted
FROM Product P
INNER JOIN ProductCategory PC on PC.PCId = P.PCID
INNER JOIN ProductSubCategory PSC on PSC.PSCId = P.PSCId
WHERE PC.Category = 'Accessory'

GO
		
--CREATING Review Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Review'))
BEGIN

	CREATE TABLE Review(
	RId INT PRIMARY KEY IDENTITY(1,1),
	ReviewerName NVARCHAR(50),
	ReviewerEmail NVARCHAR(100),
	ReviewComment NVARCHAR(MAX),
	Rating INT,
	DateInserted DATETIME,
	PId INT FOREIGN KEY REFERENCES Product(PId),
	UNIQUE(PId, ReviewerEmail))

END

GO

--CREATING Rating VIEW
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Rating'))
BEGIN
	DROP VIEW Rating
END

GO

CREATE VIEW Rating AS 
SELECT R.PId, SUM(Rating)/COUNT(Rating) AS Rating, COUNT(Rating) AS RatingNumber, P.Name, P.Price, P.OldPrice, PC.Category, P.Image1, P.[Weight], P.Description,P.Color, P.PCID
FROM Review R
INNER JOIN Product P ON P.PId = R.PId 
INNER JOIN ProductCategory PC ON PC.PCId = P.PCID
GROUP BY R.PId,P.Name, P.Price, P.OldPrice, PC.Category, P.Image1, P.[Weight], P.Description,P.Color, P.PCID 

GO

--CREATING RelatedProd FUNCTION
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'RelatedProd'))
BEGIN
DROP FUNCTION RelatedProd
END

GO

CREATE FUNCTION RelatedProd ( @Cat INT, @SubCat NVARCHAR(50) )
	RETURNS @Prod TABLE (
	PId INT PRIMARY KEY,
	Name NVARCHAR(200),
	Price MONEY,
	OldPrice MONEY,
	Description NVARCHAR(MAX),
	Color NVARCHAR(50),
	Weight DECIMAL(7,2),
	Image1 NVARCHAR(MAX) )
BEGIN

	INSERT INTO @Prod
	SELECT P.PId, P.Name, P.Price, P.OldPrice, P.Description, P.Color, P.Weight, P.Image1 FROM Product P
	INNER JOIN ProductSubCategory PSC ON PSC.PSCId = P.PSCId 
	WHERE PSC.Subcategory LIKE ''+@SubCat+''

	IF(@@ROWCOUNT <5 )
	BEGIN

		INSERT INTO @Prod
		SELECT P.PId, P.Name, P.Price, P.OldPrice, P.Description, P.Color, P.Weight, P.Image1 FROM Product P
		WHERE P.PCID = @Cat
	
	END

	RETURN

END

GO

--CREATING InsertDate Trigger
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'InsertDate'))
BEGIN
DROP TRIGGER InsertDate
END

GO

CREATE TRIGGER InsertDate
ON Review
AFTER INSERT, UPDATE
AS
BEGIN
	UPDATE Review
	SET DateInserted = GETUTCDATE()
	FROM Review 
	JOIN inserted i ON Review.RId = I.RId 
END

GO

--Created by Blend Mehani
---INSERTION OF PRODUCTS IN DATABASE


-------INSERTING LAPTOPS
INSERT INTO Product(Name,Price,OldPrice,Description,DetailedDescription,Color,Size,Weight,PCID,PSCId,DateInserted)
VALUES( ' Asus Rog Strix G15',
'1499.99',
'1700',
'ASUS ROG Strix G15 (2020) - 15.6" 240 Hz - GeForce RTX 2070 - Intel Core i7-10750H - 
16 GB DDR4 - 1 TB PCIe SSD - Windows 10 Home - Black - Gaming Laptop (G512LW-ES76)',
'NVIDIA GeForce RTX 2070 8 GB GDDR6 with ROG Boost (Base: 1260 MHz, Boost: 1455 MHz, 115W). 
Latest 10th Gen Intel Core i7-10750H Processor, 240 Hz 3 ms 15.6" Full HD 1920 x 1080 IPS-Type Display. 
16 GB DDR4 3200 MHz RAM, 1 TB PCIe SSD, Windows 10 Home. 
ROG Intelligent Cooling thermal system with Thermal Grizzly Liquid Metal Thermal Compound. 
ROG Aura Sync System with RGB Keyboard and Light Bar. Gig+ Wi-Fi 6 & Bluetooth 5.0, ROG Easy Upgrade Design. 
Bundle: Get 30 days of Xbox Game Pass for PC with purchase (*Active subscription required; continues until cancelled; 
game catalog varies over time. Requires Windows 10; see details at xbox.com/pcgamesplan.)',
'Black',
'15.6"',
'2.4',
'1',
'1',
'2019-09-15')

GO

UPDATE Product 
SET Image1='rogstrix1.png',
Image2='rogstrix2.png',
Image3='rogstrix3.png',
Image4='rogstrix4.png'
WHERE Name ='Asus Rog Strix G15'

GO

INSERT INTO Product(Name,Price,Description,DetailedDescription,Color,Size,Weight,PCID,PSCId,DateInserted)
VALUES( 'ASUS 14" ZenBook 14 UX434FLC',
1199.99,
'1.8 GHz Intel Core i7-10510U Quad-Core
16GB LPDDR3 | 512GB PCIe 3.0 x2 SSD
14" 1920 x 1080 Full HD Display
NVIDIA GeForce MX250 (2GB GDDR5)
microSD Media Card Reader
USB Type-A & Type-C | HDMI
Wi-Fi 6 (802.11ax) | Bluetooth 5.0
Windows 10 Pro (64-Bit)',
'The 14" ZenBook 14 UX434FLC Laptop from Asus is a compact and lightweight system for creative users on the go. 
With its unique touchpad design, users will be able to improve and simplify their workflow. Specs-wise, 
its equipped with a 1.8 GHz Intel Core i7-10510U quad-core processor, 16GB of LPDDR3 RAM, a 512GB PCIe SSD, and an NVIDIA GeForce MX250 graphics card. 
With these combined, you will be able to easily tackle everyday tasks and even some graphical work. Its 14" display has a 1920 x 1080 Full HD resolution and minimal bezels for a more immersive viewing experience. 
Other integrated features include a microSD card, USB Type-A and Type-C connectivity, an HDMI port, 802.11ax Wi-Fi, Bluetooth 5.0, an IR webcam, microphone, speakers, and a 3.5mm combo audio jack. 
The operating system installed is Windows 10 Pro (64-Bit).',
'Dark blue',
'14"',
'1.3',
1,
1,
'2019-09-10')

GO


UPDATE Product 
SET Image1='zenbook1.png',
Image2='zenbook2.png',
Image3='zenbook3.png'
WHERE Name like '%zenbook%'

GO

INSERT INTO Product(Name,Price,Description,DetailedDescription,Color,Size,Weight,PCID,PSCId,DateInserted)
VALUES ('ThinkPad X1 Carbon GEN 7',
		'1504.30',
		'Styled for premium performance
		Slimmer, sleeker and lighter version
		Up to 18.3-hour of battery life
		Built-in suite of ThinkShield security features
		Intel® Core™ technology for high performance
		Enhanced audio for ultimate surround sound
		An optional carbon-fiber weave top cover available',
		'8th Generation Intel® Core™ i5-8265U Processor (1.60GHz, up to 3.90GHz with Turbo Boost, 4 Cores, 6MB Cache).
		14" UHD (3840 x 2160) 500 nits, IPS with Dolby Vision™ HDR400, 10 bit, glossy.
		16 GB LPDDR3 2133 MHz.
		1 TB PCIe SSD.
		Integrated Intel® UHD 620 Graphics.
		720p HD Camera with microphone.
		2.40 lbs (1.08 kg).
		65W AC adapter.',
		'Black',
		'14"',
		'1.2',
		1,
		2,
		'2019-09-20')

GO

UPDATE Product 
SET Image1='x12.png',
Image2='x11.png'
WHERE Name like 'ThinkPad%'

GO

INSERT INTO Product(Name,Price,Description,DetailedDescription,Color,Size,Weight,PCID,PSCId,DateInserted)
VALUES( 'Lenovo Legion Y740',
1929.99,
'Lenovo Legion Y740-17IRHg 81UJ0002US 17.3" Gaming Notebook - 1920 X 1080 - 
Core I7 I7-9750H - 16 GB RAM - 1 TB HDD - 512 GB SSD - Black - Windows 10 Home 64-Bit - 
NVIDIA GeForce RTX 2060 With 6 GB - In-Plane Switching (IPS) Technology - English (US)',
'Lenovo Legion Y740-17IRHg 81UJ0002US 17.3" Gaming Notebook - 1920 x 1080 - Core i7 i7-9750H - 16 GB RAM - 1 TB HDD - 512 GB SSD - Black - Windows 10 Home 64-bit - NVIDIA GeForce RTX 2060 with 6 GB - 
In-plane Switching (IPS) Technology - English (US) LEGION Y740,I7-9750H,16GB,512GB.
Lenovo Legion! Together, we are the collective of the gaming community. We understand your passion for the game, because we live it. We listened to your needs for the ultimate gaming experience, and have designed our new rigs to be performance-ready, straight out of the box, to match your gaming needs. Our goal is simple: Make gaming better for gamers - for you and because of you - for Lenovo Legion!
Manufacturer	Lenovo Group Limited
Manufacturer Part Number	81UJ0002US
Brand Name	Lenovo
Product Line	Legion
Product Series	Y740-17IRHg
Product Model	81UJ0002US
Product Name	Legion Y740-17IRHg 81UJ0002US Gaming Notebook
Product Type	Gaming Notebook
  Product UPC	193386413400',
'Black',
'17.3"',
'3.2',
1,
2,
'2019-09-21')

GO

UPDATE Product 
SET Image1='legion1.png',
Image2='legion2.png',
Image3='legion3.png'
WHERE Name like '%Legion%'

GO

INSERT INTO Product(Name,Price,Description,DetailedDescription,Color,Size,Weight,Image1,Image2,Image3,Image4,Image5,PCID,PSCId,DateInserted)
VALUES( 'ROG Zephyrus G14',
1449.99,
'ASUS - ROG Zephyrus G14 14" Gaming Laptop - AMD Ryzen 9 - 16GB Memory - NVIDIA GeForce RTX 2060 Max-Q - 1TB SSD - Moonlight White',
'Dynamic and ready to travel, the pioneering ROG Zephyrus G14 is the world’s most powerful 14-inch Windows 10 Pro gaming laptop. 
Outclass the competition with an 8-core AMD Ryzen™ 4900HS CPU and potent GeForce RTX™ 2060 Max-Q graphics that speed through everyday multitasking and gaming. 
Create and edit with a high-resolution FHD 1080p panel that’s Pantone® Validated for superb color accuracy. Quad speakers pump out incredible Dolby Atmos sound for immersive movies, games, music, and more. 
Live life at Zephyrus speed with a light and portable gaming laptop, and be active anywhere.',
'Moonlight White',
'14"',
1.45,
'g141.png',
'g142.png',
'g143.png',
'g144.png',
'g145.png',
1,
1,
'2020-05-20'
)

GO

------INSERTING SMARTPHONES
INSERT INTO Product(Name,Price,OldPrice,Description,DetailedDescription,Color,Size,Weight,Image1,Image2,Image3,Image4,Image5,PCID,PSCId,DateInserted)
VALUES('Iphone 11 Pro Max',
980,
1200,
'Shoot amazing videos and photos with the Ultra Wide, Wide, and Telephoto cameras. 
Capture your best low-light photos with Night mode. Watch HDR movies and shows on the 6.5-inch Super Retina XDR display – the brightest iPhone display yet.¹ 
Experience unprecedented performance with A13 Bionic for gaming, augmented reality (AR), and photography. And get all-day battery life² and a new level of water resistance.³
All in the first iPhone powerful enough to be called Pro.',
'256GB Memory. 6.5-inch Super Retina XDR OLED display¹
Water and dust resistant (4 meters for up to 30 minutes, IP68)³
Triple-camera system with 12MP Ultra Wide, Wide, and Telephoto cameras; Night mode, Portrait mode, and 4K video up to 60fps
12MP TrueDepth front camera with Portrait Mode, 4K video, and Slo-Mo
Face ID for secure authentication and Apple Pay
A13 Bionic chip with third-generation Neural Engine
Fast charge with 18W adapter included
Wireless charging⁴
iOS 13 with Dark Mode, new tools for editing photos and video, and brand new privacy features
¹The display has rounded corners. When measured as a rectangle, the iPhone 11 Pro screen is 5.85 inches diagonally and the iPhone 11 Pro Max screen is 6.46 inches diagonally. Actual viewable area is less.
²Battery life varies by use and configuration. See apple.com/batteries for more information.
³iPhone 11 Pro and iPhone 11 Pro Max are splash, water, and dust resistant and were tested under controlled laboratory conditions; iPhone 11 Pro and iPhone 11 Pro Max have a rating of IP68 under IEC standard 60529 (maximum depth of 4 meters up to 30 minutes).
Splash, water, and dust resistance are not permanent conditions and resistance might decrease as a result of normal wear. Do not attempt to charge a wet iPhone; refer to the user guide for cleaning and drying instructions. Liquid damage not covered under warranty.
⁴Qi wireless chargers sold separately.',
'Space Gray',
'6.2 x 3.1 x 0.32',
0.226,
'iphone11promax1.png',
'iphone11promax2.png',
'iphone11promax3.png',
'iphone11promax4.png',
'iphone11promax5.png',
2,
4,
'2020-09-25')

GO

INSERT INTO Product(Name,Price,OldPrice,Description,DetailedDescription,Color,Size,Weight,Image1,Image2,Image3,Image4,Image5,PCID,PSCId,DateInserted)
VALUES('Iphone X',
388.99,
530.99,
'Apple‘s new iPhone X is the biggest change the company has made to its flagship smartphone in years. 
With a larger screen, a better camera system for augmented reality and facial recognition capabilities, it’s clear that this is Apple’s vision for the future of the smartphone.',
'Operating System: iOS.
Storage: 64GB.
Camera Resolution: 12 MP.
Battery: Built-in rechargeable lithium-ion.
Display: 5.8-inch (diagonal) all-screen OLED Multi-Touch displayHDR display.
Connectivity: GSM/EDGE; UMTS/HSPA+; DC-HSDPA; CDMA EV-DO Rev. A; Activate Advanced Calling 1.0 to experience Simultaneous Voice & Data.
Size: 5.65"H x 2.79"W x 0.3"D.
Weight: 6.14oz.',
'Silver',
'5.65 x 2.79 x 0.3',
0.174,
'iphonex1.png',
'iphonex2.png',
'iphonex3.png',
'iphonex4.png',
'iphonex5.png',
2,
4,
'2020-09-19')

GO

INSERT INTO Product(Name,Price,OldPrice,Description,DetailedDescription,Color,Size,Weight,Image1,Image2,Image3,Image4,Image5,PCID,PSCId,DateInserted)
VALUES('Samsung S20 Ultra',
799.99,
999.99,
'This Samsung Galaxy S20 5G cell phone features an immersive display, it’s sleek in size while packed with power and is equipped with an intelligent battery that’s big enough to share. 
The incredible, powerful camera with 30x Space Zoom capabilities captures more detail with a totally reimagined interface to do more in less space. Backward-compatible with 4G networks.',
'Galaxy S20 Ultra 5G 128GB - Silver Unlocked specs
Manufacturing part numbers (MPN) : SM-G988U
Screen size (inches) : 6.9
Color : Silver
Is the phone Unlocked or tied to a carrier? : Unlocked
Sim Card Format : Nano
Storage : 128 GB
Memory : 12 GB
Model : Galaxy S20 Ultra 5G
eSIM : No
Processor Core : 8
Megapixels : 108
OS : Android
Resolution : 1920 x 1080
Foldable : No
Network : GSM / CDMA
Release Date : March 2020
Double SIM : No
5G : Yes
Verizon compatible : Yes
AT&T compatible : Yes
T-Mobile compatible : Yes
Sprint Compatible : Yes
Release Year : 2020
Memory Card Slot : Yes
Manufacturer Ref. : SM-G988U
Brand : Samsung
Weight : 8 oz',
'Silver',
'6.2"',
0.220,
'samsungs20ultra1.png',
'samsungs20ultra2.png',
'samsungs20ultra3.png',
'samsungs20ultra4.png',
'samsungs20ultra5.png',
2,
3,
'2020-09-13')

GO

INSERT INTO Product(Name,Price,Description,DetailedDescription,Color,Size,Weight,Image1,Image2,Image3,Image4,Image5,PCID,PSCId,DateInserted)
VALUES('Samsung A70',
359.99,
'GSM
Rear Camera: Triple 32MP, 8MP and 5MP
Front Camera: 32MP
Octa-core (2x2.0 GHz Kryo 460 Gold and 6x1.7 GHz Kryo 460 Silver) Processor
Fingerprint (under display), accelerometer, gyro, proximity, compass Sensors',
'The Galaxy A70’s maximized 6.7" screen brings the world to life on its FHD+ sAMOLED Infinity-U Display. Whether streaming or watching your favourite shows, the expansive 20:9 aspect ratio is a remarkable viewing experience that takes you to new worlds. 
The Galaxy A70 has a minimal look, thanks to its integrated sensors and the On-Screen Fingerprint technology. And with a 3D design and glasstic back, it’s easy to hold as you go to work or dinner. Choose from black, white, blue or coral to match with your personality.
The Galaxy A70’s Triple Camera consists of an ultra-wide camera with a 123° field of vision like the human eye, as well as a 32MP (F1.7) camera for bright, clear photos all day. The third camera is a 5MP depth camera for adjusting depth of field. 
The 123° ultra-wide camera lets you capture the world without any restrictions. Capture epic scenes at angles like the human eye. Naturally go from wide to ultra-wide to get open panorama shots that will make your images look ultra-epic. 
The 5MP depth camera lets you adjust the depth of field before and after you nail the shot, and also knocks out unwanted background noise from your images to make them look more professional.',
'Black',
'6.7"',
0.183,
'samsunga701.png',
'samsunga702.png',
'samsunga703.png',
'samsunga704.png',
'samsunga705.png',
2,
3,
'2020-08-07')

GO

INSERT INTO Product(Name,Price,Description,DetailedDescription,Color,Size,Weight,Image1,PCID,PSCId,DateInserted)
VALUES('Samsung Note 10',
949.99,
'Fast charging, long lasting intelligent power and super speed processing outlast whatever you throw at Note 10
S pen’s newest Evolution gives you the power of air gestures, a remote shutter and playlist button and handwriting to text, all in One Magic wand
With a full set of Pro lenses, super stabilization, live video bokeh and precision audio recording, Note 10 is a studio in your pocket
Note 10’s nearly bezel less Infinity display gives an immersive, cinematic quality to whatever you’re viewing
Internet usage time(LTE) (hours) up to 14. Internet usage time(wi fi) (hours) up to 14. Audio playback time (hours, wireless) up to 60. Talk time (4G LTE) (hours) up to 38. Video playback time (hours, wireless) up to 19',
'Color: Black. 
Screen: 6.3” Nearly Bezel-less Infinity Display*. 
Display Type: Edge. 
S Pen: Bluetooth, Air Action Wireless Gestures, Handwriting-to-Text. 
Biometrics: Ultrasonic In-Display Fingerprint ID. 
Front Camera: 10MP Selfie Camera with Dual Pixel. 
Rear Camera: 12MP Wide, 12MP 2x Zoom, 16MP Ultra Wide. 
Capacity: 256GB Storage / 8 GB RAM. 
Battery: 3,500mAh Superfast Charging, All-Day Battery, Wireless PowerShare. 
Legal: *Screen measured diagonally as a full rectangle without accounting for the rounded corners.',
'Black',
'6.3"',
0.168,
'samsungnote101.png',
2,
3,
'2020-07-03')

GO

------INSERTING ACCESSORIES
INSERT INTO Product(Name,Price,OldPrice,Description,DetailedDescription,Color,Size,Weight,Image1,Image2,Image3,Image4,Image5,PCID,PSCId,DateInserted)
VALUES('BenQ Zowie FK2',
59.99,
72.99,
'3310 optical sensor with 400/800/1600/3200 DPI to give you a unique tracking experience.
Ambidextrous design with multiple shapes and sizes to maximize performance and provide a comfortable gaming experience for competitive esports players.
Consistent tactile feedback to avoid double switch presses, ensuring efficient functionality, and sleek design.
Adjustable report rate 125/500/1000Hz for different levels of responsiveness.
Plug and Play (No drivers required).
Cable Length: 2m / 6. 6ft.
Manufacturer Limited : 1 Year.',
'No matter whether you are right-handed or left-handed, FK Series are designed for your comfort. The low profile design provides better control for both claw and palm-grip users. FK Series comes in three different sizes.
 Select the one that is right for you & wield your mouse firm in grip on the battlefield. FK1+: Extra Large, FK1: Large, FK2: Medium.
 Designed for intense gameplay. The Zowie FK allows your fingertips to hold and cover your mouse so you can operate precisely and smoothly.',
'Black',
'4.88 x 2.51 x 1.41',
0.08,
'zowiefk21.png',
'zowiefk22.png',
'zowiefk23.png',
'zowiefk24.png',
'zowiefk25.png',
4,
7,
'2020-09-24')

GO

INSERT INTO Product(Name,Price,Description,DetailedDescription,Color,Size,Weight,Image1,Image2,Image3,Image4,Image5,PCID,PSCId,DateInserted)
VALUES('Logitech MX Master 3',
99.99,
'Ultra-fast magspeed scrolling - Remarkable speed, precision & quietness of electromagnetic scrolling with all new magspeed wheel - up to 90% faster, 87% more precise & ultra quiet. 
Comfort shape and intuitive controls - Work comfortably with perfectly sculpted shape and ideally placed thumb wheel and controls. 
App-specific customizations - Speed up your workflow with predefined app-specific profiles and numerous customization options. Advanced 2.4 GHz wireless technology. 
Flow cross-computer control - Work seamlessly on three computers. Seamlessly transfer cursor, text, and files – between windows & macOS, desktop & laptop. 
Works on any surface even on glass with dark field 4000 DPI sensor. It is faster and 5x more precise than the basic mouse – so you always hit the right Pixel. 
USB-c rechargeable - Full charge lasts up-to 70 days, quick 1 min charge gives 3 hrs of use.
Multi-device and multi-OS - Connect the way you want Up to 3 devices via Bluetooth or the included USB receiver on windows, Mac or Linux.',
'Mx master 3 is the most advanced master series mouse yet. It has been designed for designers and engineered for coders – to create, make, and do faster and more efficiently with an all-New electromagnetic scroll wheel, app-specific workflow customizations, and a crafted form designed for the shape of your palm. 
Brand:	Logitech.
Series:	 Logitech MX Master 3 Advanced Wireless Mouse - Graphite.
Item model number:	 910-005620.
Hardware Platform:	 PC, Linux, Mac.
Operating System:	Linux.
Item Weight:  9.1 ounces.
Package Dimensions:	 4.9 x 3.3 x 2.0 inches..
Color:	Graphite.
Batteries:	1 Lithium Polymer batteries required. (included).
Manufacturer:	Logitech.
ASIN:	B07S395RWD.
Date First Available:	September 4, 2019.',
'Graphite',
'4.9 x 3.3 x 2.0',
0.14,
'logitechmxmaster31.png',
'logitechmxmaster32.png',
'logitechmxmaster33.png',
'logitechmxmaster34.png',
'logitechmxmaster35.png',
4,
7,
'2020-07-09')

GO

INSERT INTO Product(Name,Price,Description,DetailedDescription,Color,Size,Weight,Image1,Image2,Image3,Image4,Image5,PCID,PSCId,DateInserted)
VALUES('Glorius Model D',
48.50,
'SIZE & STYLE: Ergonomic ultralight weight gaming mouse ideal for [MEDIUM to LARGE] hands. Built for speed, control, and comfort.
ULTRA FLEXIBLE CABLE: Our Braided Ascended Cord is so light it produces a drag-free wireless feel.
MOUSE FEET: Our Glorious Skates are 100% pure Virgin PTFE that will glide like blades on ice.
E-SPORT CUSTOMIZATION: 6-Step DPI, lighting effects, polling rate, lift-off distance, click/scroll speed, 6 buttons with macro support, and more.
FREE REPLACEMENT WARRANTY: 180-Day Replacement Guarantee + 2 Year Warranty - If anything happens, simply contact our customer support team and you will get a quick response from our representatives.',
'Size:	120 mm x 67 mm x 40 mm.
Size (inches):	4.72" x 2.64" x 1.57".
Ambidextrous:	No.
Weight:	63 g (matte).
Number of Buttons:	6 (including wheel click).
Main Switches:	Omron D2FC-F-7N (20M) (OF).
Wheel Encoder:	Mechanical.
Sensor:	PixArt PMW3360.
Resolution:	400–12,000 CPI.
Polling Rate:	125/250/500/1000 Hz.
Cable:	2 m, braided.
Software:	Yes.
Warranty:	2 years.',
'Matte black',
'4.72 x 2.64 x 1.57',
0.06,
'gloriusmodeld1.png',
'gloriusmodeld2.png',
'gloriusmodeld3.png',
'gloriusmodeld4.png',
'gloriusmodeld5.png',
4,
7,
'2020-01-25')


GO


INSERT INTO Product(Name,Price,Description,DetailedDescription,Color,Size,Weight,Image1,PCID,PSCId,DateInserted)
VALUES('Razer Mamba',
62.92,
'Razer Mamba Wireless, Wired/Wireless Gaming Mouse with True 16,000 DPI 5 Generation Optical Sensor, 50 Hour Battery Life, Powered by Razer Chroma',
'Gaming mouse wireless; extended battery life for up to 50 hours of use on a single charge
Razer 5 Generation advanced optical sensor with true 16,000 DPI
Seven programmable buttons for increased control
Powered by Razer Chroma: With 16.8 millions customisable colour options
Hybrid on-board and cloud storage to access personalized settings anytime, anywhere
With Razer proprietary adaptive frequency technology, enjoy stability thats as reliable as a wired connection',
'Black',
'4.95 x 2.75 x 1.70',
0.125,
'razermamba1.png',
4,
7,
'2020-09-29')


