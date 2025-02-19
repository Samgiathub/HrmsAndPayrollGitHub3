


-- Created By Tejas for insert default Dist on 17052024

CREATE PROCEDURE [dbo].[InsertSubDist] 
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN


if not Exists(select 1 from SubDist_Master WITH (NOLOCK) where SubDist_Name='Campbell Bay')
begin

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
SELECT N'Assam', N'Nicobars', N'Campbell Bay' UNION ALL
SELECT N'Assam', N'Nicobars', N'Car Nicobar' UNION ALL
SELECT N'Assam', N'Nicobars', N'Nancowrie' UNION ALL
SELECT N'Assam', N'North And Middle Andaman', N'Diglipur' UNION ALL
SELECT N'Assam', N'North And Middle Andaman', N'Mayabunder' UNION ALL
SELECT N'Assam', N'North And Middle Andaman', N'Rangat' UNION ALL
SELECT N'Assam', N'South Andamans' , N'Ferrargunj' UNION ALL
SELECT N'Assam', N'South Andamans', N'Little Andaman' UNION ALL
SELECT N'Assam', N'South Andamans' , N'Prothrapur' 
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
SELECT N'Assam', N'Bajali', N'Bajali' UNION ALL
SELECT N'Assam', N'Bajali', N'Bhabanipur' UNION ALL
SELECT N'Assam', N'Baksa', N'Barama' UNION ALL
SELECT N'Assam', N'Baksa', N'Baska' UNION ALL
SELECT N'Assam', N'Baksa' , N'Dhamdhama' UNION ALL
SELECT N'Assam', N'Baksa' , N'Jalah' UNION ALL
SELECT N'Assam', N'Barpeta' , N'Gobardhana' UNION ALL
SELECT N'Assam', N'Barpeta' , N'Barpeta' UNION ALL
SELECT N'Assam', N'Barpeta' , N'Chakchaka' UNION ALL
SELECT N'Assam', N'Barpeta' , N'Chenga' UNION ALL
SELECT N'Assam', N'Barpeta' , N'Gomaphulbari' UNION ALL
SELECT N'Assam', N'Barpeta' , N'Mandia' UNION ALL
SELECT N'Assam', N'Barpeta' , N'Pakabetbari' UNION ALL
SELECT N'Assam', N'Barpeta' , N'Ruposhi' UNION ALL
SELECT N'Assam', N'Barpeta' , N'Sarukhetri' UNION ALL
SELECT N'Assam', N'Biswanath' , N'Baghmara' UNION ALL
SELECT N'Assam', N'Biswanath' , N'Behali' UNION ALL
SELECT N'Assam', N'Biswanath' , N'Biswanath' UNION ALL
SELECT N'Assam', N'Biswanath' , N'Chaiduar' UNION ALL
SELECT N'Assam', N'Biswanath' , N'Pub Chaiduar' UNION ALL
SELECT N'Assam', N'Biswanath' , N'Sakomatha' UNION ALL
SELECT N'Assam', N'Biswanath' , N'Sootea' UNION ALL
SELECT N'Assam', N'Bongaigaon' , N'Manikpur' UNION ALL
SELECT N'Assam', N'Bongaigaon' , N'Boitamari' UNION ALL
SELECT N'Assam', N'Bongaigaon' , N'Dangtol' UNION ALL
SELECT N'Assam', N'Bongaigaon' , N'Srijangram' UNION ALL
SELECT N'Assam', N'Bongaigaon' , N'Tapattary' UNION ALL
SELECT N'Assam', N'Cachar' , N'Banskandi' UNION ALL	
SELECT N'Assam', N'Cachar' , N'Barjalenga' UNION ALL
SELECT N'Assam', N'Cachar' , N'Binnakandi' UNION ALL
SELECT N'Assam', N'Cachar' , N'Borkhola' UNION ALL
SELECT N'Assam', N'Cachar' , N'Kalain' UNION ALL
SELECT N'Assam', N'Cachar' , N'Katigorah' UNION ALL
SELECT N'Assam', N'Cachar' , N'Lakhipur' UNION ALL
SELECT N'Assam', N'Cachar' , N'Narsingpur' UNION ALL
SELECT N'Assam', N'Cachar' , N'Palonghat' UNION ALL
SELECT N'Assam', N'Cachar' , N'Rajabazar' UNION ALL
SELECT N'Assam', N'Cachar' , N'Salchapra' UNION ALL
SELECT N'Assam', N'Cachar' , N'Silchar' UNION ALL
SELECT N'Assam', N'Cachar' , N'Sonai' UNION ALL
SELECT N'Assam', N'Cachar' , N'Tapang' UNION ALL
SELECT N'Assam', N'Cachar' , N'Udharbond' UNION ALL
SELECT N'Assam', N'Charaideo' , N'Lakuwa' UNION ALL
SELECT N'Assam', N'Charaideo' , N'Mahmara' UNION ALL
SELECT N'Assam', N'Charaideo' , N'Sapekhati' UNION ALL
SELECT N'Assam', N'Charaideo' , N'Sonari' UNION ALL
SELECT N'Assam', N'Chirang' , N'Khoirabari' UNION ALL
SELECT N'Assam', N'Chirang' , N'Manikpur' UNION ALL
SELECT N'Assam', N'Chirang' , N'Borobazar' UNION ALL
SELECT N'Assam', N'Chirang' , N'Manikpur Part' UNION ALL
SELECT N'Assam', N'Darrang' , N'Sidli-Chirang' UNION ALL
SELECT N'Assam', N'Darrang' , N'Bechimari' UNION ALL
SELECT N'Assam', N'Darrang' , N'Dalgaon-Sialmari' UNION ALL
SELECT N'Assam', N'Darrang' , N'Kalaigaon' UNION ALL
SELECT N'Assam', N'Darrang' , N'Pachim-Mangaldai' UNION ALL
SELECT N'Assam', N'Darrang' , N'Pub-Mangaldai' UNION ALL
SELECT N'Assam', N'Darrang' , N'Sipajhar' UNION ALL
SELECT N'Assam', N'Dhemaji' , N'Bordoloni' UNION ALL
SELECT N'Assam', N'Dhemaji' , N'Dhemaji' UNION ALL
SELECT N'Assam', N'Dhemaji' , N'Machkhowa' UNION ALL
SELECT N'Assam', N'Dhemaji' , N'Murkongselek' UNION ALL
SELECT N'Assam', N'Dhemaji' , N'Sissiborgaon' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Bilasipara' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Chapar Salkocha' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Debitola' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Golakganj' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Hatidhura' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Mahamaya' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Rupshi' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Agomani' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Birshing-Jarua' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Gauripur' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Hatidhura' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Jamadarhat' UNION ALL
SELECT N'Assam', N'Dhubri' , N'Nayeralga' UNION ALL
SELECT N'Assam', N'Dhubri' , N'South Salmara' UNION ALL
 Select 'Assam', N'Dibrugarh' , N'Bilasipara'  UNION ALL
 Select 'Assam', N'Dibrugarh' , N'Chapar Salkocha'  UNION ALL
 Select 'Assam', N'Dibrugarh' , N'Debitola'  UNION ALL
 Select 'Assam', N'Dibrugarh' , N'Golakganj'  UNION ALL
 Select 'Assam', N'Dibrugarh' , N'Hatidhura'  UNION ALL
 Select 'Assam', N'Dibrugarh' , N'Khoirabari'  UNION ALL
 Select 'Assam', N'Dibrugarh' , N'Mahamaya'  UNION ALL
 Select 'Assam', N'Dima Hasao' , N'Rupshi'  UNION ALL
 Select 'Assam', N'Dima Hasao' , N'Barbaruah'  UNION ALL
 Select 'Assam', N'Dima Hasao' , N'Joypur'  UNION ALL
 Select 'Assam', N'Dima Hasao' , N'Khowang'  UNION ALL
 Select 'Assam', N'Dima Hasao' , N'Lahoal'  UNION ALL
 Select 'Assam', N'Goalpara' , N'Panitola'  UNION ALL
 Select 'Assam', N'Goalpara' , N'Tengakhat'  UNION ALL
 Select 'Assam', N'Goalpara' , N'Tingkhong'  UNION ALL
 Select 'Assam', N'Goalpara' , N'Diyang Valley'  UNION ALL
 Select 'Assam', N'Goalpara' , N'Diyungbra'  UNION ALL
 Select 'Assam', N'Goalpara' , N'Harangajao'  UNION ALL
 Select 'Assam', N'Goalpara' , N'Jatinga Valley'  UNION ALL
 Select 'Assam', N'Goalpara' , N'New Sangbar'  UNION ALL
 Select 'Assam', N'Golaghat' , N'Balijana'  UNION ALL
 Select 'Assam', N'Golaghat' , N'Jaleswar'  UNION ALL
 Select 'Assam', N'Golaghat' , N'Kharmuza'  UNION ALL
 Select 'Assam', N'Golaghat' , N'Krishnai'  UNION ALL
 Select 'Assam', N'Golaghat' , N'Kuchdhowa'  UNION ALL
 Select 'Assam', N'Golaghat' , N'Lakhipur'  UNION ALL
 Select 'Assam', N'Golaghat' , N'Matia'  UNION ALL
 Select 'Assam', N'Golaghat' , N'Rongjuli'  UNION ALL
 Select 'Assam', N'Hailakandi' , N'Golaghat Central'  UNION ALL
 Select 'Assam', N'Hailakandi' , N'Golaghat East'  UNION ALL
 Select 'Assam', N'Hailakandi' , N'Golaghat North'  UNION ALL
 Select 'Assam', N'Hailakandi' , N'Golaghat South'  UNION ALL
 Select 'Assam', N'Hailakandi' , N'Golaghat West'  UNION ALL
 Select 'Assam', N'Hojai' , N'Gomariguri'  UNION ALL
 Select 'Assam', N'Hojai' , N'Kakodonga'  UNION ALL
 Select 'Assam', N'Hojai' , N'Morongi'  UNION ALL
 Select 'Assam', N'Hojai' , N'Algapur'  UNION ALL
 Select 'Assam', N'Hojai' , N'Hailakandi'  UNION ALL
 Select 'Assam', N'Jorhat' , N'Katlicherra'  UNION ALL
 Select 'Assam', N'Jorhat' , N'Lala'  UNION ALL
 Select 'Assam', N'Jorhat' , N'South Hailakandi'  UNION ALL
 Select 'Assam', N'Jorhat' , N'Binakandi'  UNION ALL
 Select 'Assam', N'Jorhat' , N'Dhalpukhuri'  UNION ALL
 Select 'Assam', N'Jorhat' , N'Jugijan'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Lumding'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Udali'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Jorhat'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Jorhat Central'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Jorhat East'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Kaliapani'  UNION ALL
 Select 'Assam', N'Kamrup' , N'North West Jorhat'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Titabor'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Bezera'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Bihdia -Jajikona'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Boko'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Bongaon'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Chamaria'  UNION ALL
 Select 'Assam', N'Kamrup' , N'Chayani'  UNION ALL
 Select 'Assam', N'Kamrup Metro' , N'Chaygaon'  UNION ALL
 Select 'Assam', N'Kamrup Metro' , N'Goroimari'  UNION ALL
 Select 'Assam', N'Kamrup Metro' , N'Hajo'  UNION ALL
 Select 'Assam', N'Kamrup Metro' , N'Kamalpur'  UNION ALL
 Select 'Assam', N'Karbi Anglong' , N'Rampur'  UNION ALL
 Select 'Assam', N'Karbi Anglong' , N'Rangia'  UNION ALL
 Select 'Assam', N'Karbi Anglong' , N'Rani'  UNION ALL
 Select 'Assam', N'Karbi Anglong' , N'Sualkuchi'  UNION ALL
 Select 'Assam', N'Karbi Anglong' , N'Bezera (Pt)'  UNION ALL
 Select 'Assam', N'Karbi Anglong' , N'Chandrapur'  UNION ALL
 Select 'Assam', N'Karbi Anglong' , N'Dimoria'  UNION ALL
 Select 'Assam', N'Karimganj' , N'Rani (Pt)'  UNION ALL
 Select 'Assam', N'Karimganj' , N'Bokajan'  UNION ALL
 Select 'Assam', N'Karimganj' , N'Howraghat'  UNION ALL
 Select 'Assam', N'Karimganj' , N'Langsomepi'  UNION ALL
 Select 'Assam', N'Karimganj' , N'Lumbajong'  UNION ALL
 Select 'Assam', N'Karimganj' , N'Nilip'  UNION ALL
 Select 'Assam', N'Karimganj' , N'Rongmongwe'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Samelangso'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Badarpur'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Dullavcherra'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Lowairpoa'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'North Karimganj'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Patharkandi'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Ramkrishna Nagar'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'South Karimganj'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Bilashipara-Btc'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Chapor-Salkocha-Btc'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Debitola-Btc'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Dotma'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Golakganj-Btc'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Gossaigaon'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Kachugaon'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Kokrajhar'  UNION ALL
 Select 'Assam', N'Kokrajhar' , N'Mahamaya-Btc'  UNION ALL
 Select 'Assam', N'Lakhimpur' , N'Rupshi-Btc'  UNION ALL
 Select 'Assam', N'Lakhimpur' , N'Bihpuria'  UNION ALL
 Select 'Assam', N'Lakhimpur' , N'Boginadi'  UNION ALL
 Select 'Assam', N'Lakhimpur' , N'Dhakuakhana'  UNION ALL
 Select 'Assam', N'Lakhimpur' , N'Ghilamara'  UNION ALL
 Select 'Assam', N'Lakhimpur' , N'Karunabari'  UNION ALL
 Select 'Assam', N'Lakhimpur' , N'Lakhimpur'  UNION ALL
 Select 'Assam', N'Lakhimpur' , N'Narayanpur'  UNION ALL
 Select 'Assam', N'Lakhimpur' , N'Nowboicha'  UNION ALL
 Select 'Assam', N'Majuli' , N'Telahi'  UNION ALL
 Select 'Assam', N'Majuli' , N'Majuli'  UNION ALL
 Select 'Assam', N'Marigaon' , N'Ujani Majuli'  UNION ALL
 Select 'Assam', N'Marigaon' , N'Batabraba (Part)'  UNION ALL
 Select 'Assam', N'Marigaon' , N'Bhurbandha'  UNION ALL
 Select 'Assam', N'Marigaon' , N'Dolongghat (Part)'  UNION ALL
 Select 'Assam', N'Marigaon' , N'Kapili'  UNION ALL
 Select 'Assam', N'Marigaon' , N'Laharighat'  UNION ALL
 Select 'Assam', N'Marigaon' , N'Mayang'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Moirabari'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Bajiagaon'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Barhampur'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Batadrava'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Dolongghat'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Juria'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Kaliabor'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Kapili Pt.I'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Kathiatoli'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Khagarijan'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Laokhowa'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Moirabari Part'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Pachim Kaliabor'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Pakhimoria'  UNION ALL
 Select 'Assam', N'Nagaon' , N'Raha'  UNION ALL
 Select 'Assam', N'Nalbari' , N'Rupahi'  UNION ALL
 Select 'Assam', N'Nalbari' , N'Barigog Banbhag'  UNION ALL
 Select 'Assam', N'Nalbari' , N'Barkhetri'  UNION ALL
 Select 'Assam', N'Nalbari' , N'Borbhag'  UNION ALL
 Select 'Assam', N'Nalbari' , N'Madhupur'  UNION ALL
 Select 'Assam', N'Nalbari' , N'Paschim Nalbari'  UNION ALL
 Select 'Assam', N'Nalbari' , N'Pub Nalbari'  UNION ALL
 Select 'Assam', N'Sivasagar' , N'Tihu'  UNION ALL
 Select 'Assam', N'Sivasagar' , N'Amguri'  UNION ALL
 Select 'Assam', N'Sivasagar' , N'Demow'  UNION ALL
 Select 'Assam', N'Sivasagar' , N'Gaurisagar'  UNION ALL
 Select 'Assam', N'Sivasagar' , N'Nazira'  UNION ALL
 Select 'Assam', N'Sonitpur' , N'Sivasagar'  UNION ALL
 Select 'Assam', N'Sonitpur' , N'Balipara'  UNION ALL
 Select 'Assam', N'Sonitpur' , N'Bihaguri'  UNION ALL
 Select 'Assam', N'Sonitpur' , N'Borchala'  UNION ALL
 Select 'Assam', N'Sonitpur' , N'Dhekiajuli'  UNION ALL
 Select 'Assam', N'Sonitpur' , N'Gabhoru'  UNION ALL
 Select 'Assam', N'Sonitpur' , N'Naduar'  UNION ALL
 Select 'Assam', N'South Salmara Mancachar' , N'Rangapara'  UNION ALL
 Select 'Assam', N'South Salmara Mancachar' , N'Fekamari'  UNION ALL
 Select 'Assam', N'South Salmara Mancachar' , N'Mankachar'  UNION ALL
 Select 'Assam', N'Tamulpur' , N'South Salmara Part'  UNION ALL
 Select 'Assam', N'Tamulpur' , N'Goreswar'  UNION ALL
 Select 'Assam', N'Tamulpur' , N'Nagrijuli'  UNION ALL
 Select 'Assam', N'Tinsukia' , N'Tamulpur'  UNION ALL
 Select 'Assam', N'Tinsukia' , N'Guijan'  UNION ALL
 Select 'Assam', N'Tinsukia' , N'Hapjan'  UNION ALL
 Select 'Assam', N'Tinsukia' , N'Itakhuli'  UNION ALL
 Select 'Assam', N'Tinsukia' , N'Kakopathar'  UNION ALL
 Select 'Assam', N'Tinsukia' , N'Margherita'  UNION ALL
 Select 'Assam', N'Tinsukia' , N'Sadiya'  UNION ALL
 Select 'Assam', N'Udalguri' , N'Saikhowa'  UNION ALL
 Select 'Assam', N'Udalguri' , N'Bechimari'  UNION ALL
 Select 'Assam', N'Udalguri' , N'Bhergaon'  UNION ALL
 Select 'Assam', N'Udalguri' , N'Borsola'  UNION ALL
 Select 'Assam', N'Udalguri' , N'Dalgaon-Sialmari'  UNION ALL
 Select 'Assam', N'Udalguri' , N'Kalaigaon'  UNION ALL
 Select 'Assam', N'Udalguri' , N'Mazbat'  UNION ALL
 Select 'Assam', N'Udalguri' , N'Odalguri'  UNION ALL
 Select 'Assam', N'Udalguri' , N'Paschim-Mangaldai'  UNION ALL
 Select 'Assam', N'Udalguri' , N'Pub-Mangaldai'  UNION ALL
 Select 'Assam', N'Udalguri' , N'Rowta'  UNION ALL
 Select 'Assam', N'West Karbi Anglong' , N'Amri'  UNION ALL
 Select 'Assam', N'West Karbi Anglong' , N'Chinthong'  UNION ALL
 Select 'Assam', N'West Karbi Anglong' , N'Rongkhang'  UNION ALL
 Select 'Assam', N'West Karbi Anglong' , N'Socheng'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Addateegala' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Ananthagiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Araku Valley' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Chintapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Chintoor' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Devipatnam' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Dumbriguda' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Gangavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'G.Madugula' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Gudem Kotha Veedhi' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Hukumpeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Koyyuru' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Kunavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Maredumilli' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Munchingi Puttu' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Nellipaka' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Paderu' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Peda Bayalu' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Rajavommangi' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Rampachodavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Vararamachandrapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Alluri Sitharama Raju' , N'Y. Ramavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Achutapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Anakapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Butchayyapeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Cheedikada' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Chodavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Devarapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Golugonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Kasimkota' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'K.Kotapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Kotauratla' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Madugula' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Makavarapalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Munagapaka' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Nakkapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Narsipatnam' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Nathavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Paravada' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Payakaraopeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Rambilli' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Ravikamatham' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Rolugunta' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Sabbavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'S.Rayavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Anakapalli' , N'Yelamanchili' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Anantapur' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Atmakur' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Beluguppa' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Bommanahal' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Brahmasamudram' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Bukkarayasamudram' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'D.Hirehal' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Garladinne' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Gooty' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Gummagatta' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Guntakal' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Kalyandrug' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Kambadur' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Kanekal' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Kudair' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Kundurpi' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Narpala' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Pamidi' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Peddapappur' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Peddavadugur' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Putlur' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Raptadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Rayadurg' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Settur' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Singanamala' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Tadipatri' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Uravakonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Vajrakarur' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Vidapanakal' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Yadiki' UNION ALL 
 Select 'Andhra Pradesh' , N'Ananthapuramu' , N'Yellanur' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'B.Kothakota' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Chinnamandem' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Chitvel' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Galiveedu' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Gurramkonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Kalakada' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Kalikiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Kambhamvaripalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Kodur' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Kurabalakota' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Lakkireddipalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Madanapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Mulakalacheruvu' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Nandalur' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Nimmanapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Obulavaripalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Peddamandyam' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Peddathippasamudram' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Penagalur' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Piler' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Pullampeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Rajampet' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Ramapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Ramasamudram' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Rayachoty' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Sambepalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Thamballapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'T.Sundupalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Valmikipuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Annamayya' , N'Veeraballi' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Addanki' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Amruthalur' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Ballikurava' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Bapatla' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Bhattiprolu' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Cherukupalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Chinaganjam' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Chirala' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Inkollu' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Janakavaram Ponguluru' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Karamchedu' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Karlapalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Kollur' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Korisapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Martur' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Nagaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Nizampatnam' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Parchur' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Pittalavanipalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Repalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Santhamaguluru' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Tsundur' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Vemuru' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Vetapalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Bapatla' , N'Yddana Pudi' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Baireddipalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Bangarupalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Chittoor' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Chowdepalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Gangadhara Nellore' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Gangavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Gudipala' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Gudupalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Irala' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Karvetinagar' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Kuppam' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Nagari' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Nindra' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Palamaner' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Palasamudram' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Peddapanjani' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Penumuru' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Pulicherla H/O Reddivaripalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Punganur' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Puthalapattu' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Ramakuppam' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Rompicherla' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Santhipuram Ho Arimuthanapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Sodam' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Somala' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Srirangarajapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Thavanampalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Vedurukuppam' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Venkatagirikota' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Vijayapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Chittoor' , N'Yadamari' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Ainavilli' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Alamuru' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Allavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Amalapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Ambajipeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Atreyapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'I. Polavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Kapileswarapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Katrenikona' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Kothapeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Malikipuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Mamidikuduru' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Mandapeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Mummidivaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Pamarru' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'P.Gannavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Ramachandrapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Ravulapalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Rayavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Razole' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Sakhinetipalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Dr. B.R. Ambedkar Konaseema' , N'Uppalaguptam' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Anaparthy' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Biccavolu' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Chagallu' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Devarapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Gokavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Gopalapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Kadiam' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Korukonda' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Kovvur' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Nallajerla' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Nidadavole' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Peravali' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Rajahmundry Rural' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Rajahmundry Urban' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Rajanagaram' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Rangampeta' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Seethanagaram' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Thallapudi' UNION ALL 
 Select 'Andhra Pradesh' , N'East Godavari' , N'Undrajavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Agiripalli' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Bhimadole' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Buttayagudem' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Chatrai' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Chintalapudi' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Denduluru' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Dwarakatirumala' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Eluru' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Jangareddigudem' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Jeelugumilli' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Kaikalur' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Kalidindi' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Kamavarapukota' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Koyyalagudem' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Kukkunur' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Lingapalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Mandavalli' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Mudinepalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Musunuru' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Nidamarru' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Nuzvid' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Pedapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Pedavegi' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Polavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'T.Narasapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Unguturu' UNION ALL 
 Select 'Andhra Pradesh' , N'Eluru' , N'Velairpad' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Chebrole' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Duggirala' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Guntur' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Kakumanu' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Kollipara' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Mangalagiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Medikonduru' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Pedakakani' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Pedanandipadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Phirangipuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Ponnur' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Prathipadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Tadepalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Tadikonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Tenali' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Thullur' UNION ALL 
 Select 'Andhra Pradesh' , N'Guntur' , N'Vatticherukuru' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Gandepalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Gollaprolu' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Jaggampeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Kajuluru' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Kakinada Rural' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Kakinada Urban' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Karapa' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Kirlampudi' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Kotananduru' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Pedapudi' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Peddapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Pithapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Prathipadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Routhulapudi' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Samalkota' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Sankhavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Thallarevu' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Thondangi' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Tuni' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'U.Kothapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Kakinada' , N'Yeleswaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Avanigadda' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Bantumilli' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Bapulapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Challapalli' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Gannavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Ghantasala' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Gudivada' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Gudlavalleru' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Guduru' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Kankipadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Koduru' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Kruttivennu' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Machilipatnam' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Mopidevi' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Movva' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Nagayalanka' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Nandivada' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Pamarru' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Pamidimukkala' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Pedana' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Pedaparupudi' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Penamaluru' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Thotlavalluru' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Unguturu' UNION ALL 
 Select 'Andhra Pradesh' , N'Krishna' , N'Vuyyuru' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Adoni' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Alur' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Aspari' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'C.Belagal' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Chippagiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Devanakonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Gonegandla' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Gudur' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Halaharvi' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Holagunda' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Kallur' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Kodumur' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Kosigi' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Kowthalam' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Krishnagiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Kurnool' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Maddikera (East)' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Mantralayam' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Nandavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Orvakal' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Pattikonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Peddakadabur' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Tuggali' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Veldurthi' UNION ALL 
 Select 'Andhra Pradesh' , N'Kurnool' , N'Yemmiganur' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Allagadda' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Atmakur' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Banaganapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Bandi Atmakur' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Bethamcherla' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Chagalamarri' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Dhone Alias Dronachalam' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Dornipadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Gadivemula' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Gospadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Jupadu Bungalow' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Koilakuntla' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Kolimigundla' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Kothapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Mahanandi' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Midthur' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Nandikotkur' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Nandyal' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Owk' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Pagidyala' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Pamulapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Panyam' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Peapully' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Rudravaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Sanjamala' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Sirivel' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Srisailam' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Uyyalawada' UNION ALL 
 Select 'Andhra Pradesh' , N'Nandyal' , N'Velugodu' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'A.Konduru' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Chandarlapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Gampalagudem' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'G.Konduru' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Ibrahimpatnam' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Jaggayyapeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Kanchikacherla' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Mylavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Nandigama' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Penuganchiprolu' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Reddigudem' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Tiruvuru' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Vatsavai' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Veerullapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Vijayawada Rural' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Vijayawada Urban' UNION ALL 
 Select 'Andhra Pradesh' , N'Ntr' , N'Vissannapet' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Amaravathi' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Atchempet' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Bellamkonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Bollapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Chilakaluripet' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Dachepalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Durgi' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Edlapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Gurazala' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Ipur' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Karempudi' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Krosuru' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Machavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Macherla' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Muppalla' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Nadendla' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Narasaraopeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Nekarikallu' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Nuzendla' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Pedakurapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Piduguralla' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Rajupalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Rentachintala' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Rompicherla' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Sattenapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Savalyapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Veldurthy' UNION ALL 
 Select 'Andhra Pradesh' , N'Palnadu' , N'Vinukonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Balijipeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Bhamini' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Garugubilli' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Gummalakshmipuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Jiyyammavalasa' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Komarada' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Kurupam' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Makkuva' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Pachipenta' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Palakonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Parvathipuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Salur' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Seethampeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Seethanagaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Parvathipuram Manyam' , N'Veeraghattam' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Ardhaveedu' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Bestavaripeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Chandra Sekhara Puram' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Chimakurthi' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Cumbum' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Darsi' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Donakonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Dornala' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Giddaluru' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Hanumanthuni Padu' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Kanigiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Komarolu' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Konakanamittla' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Kondapi' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Kotha Patnam' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Kurichedu' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Maddipadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Markapur' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Marripudi' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Mundlamuru' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Naguluppala Padu' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Ongole' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Pamur' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Peda Araveedu' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Pedacherlo Palle' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Podili' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Ponnaluru' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Pullalacheruvu' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Racherla' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Santhanuthala Padu' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Singarayakonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Tallur' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Tangutur' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Tarlupadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Tripuranthakam' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Veligandla' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Yerragondapalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Prakasam' , N'Zarugumilli' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Amadalavalasa' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Burja' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Etcherla' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Ganguvarisigadam' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Gara' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Hiramandalam' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Ichapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Jalumuru' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Kanchili' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Kaviti' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Kotabommili' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Kotturu' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Laveru' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'L.N Peta' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Mandasa' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Meliaputti' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Nandigam' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Narasannapeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Palasa' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Pathapatnam' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Polaki' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Ponduru' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Ranastalam' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Santhabommali' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Saravakota' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Sarubujjili' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Sompeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Srikakulam' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Tekkali' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Vajrapukotturu' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Allur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Ananthasagaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Anumasamudrampeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Atmakur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Bogole' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Butchireddipalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Potti Sriramulu Nellore' , N'Chejerla' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Dagadarthi' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Duttalur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Gudluru' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Indukurpet' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Jaladanki' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Kaligiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Kaluvoya' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Kandukur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Kavali' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Kodavalur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Kondapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Kovur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Lingasamudram' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Manubolu' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Marripadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Muthukur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Nellore Rural' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Podalakur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Rapur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Sangam' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Seetharamapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Sydapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Thotapalligudur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Udayagiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Ulavapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Varikuntapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Venkatachalam' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Vidavalur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Vinjamur' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Voletivari Palem' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Agali' UNION ALL 
 Select 'Andhra Pradesh' , N'Sri Sathya Sai' , N'Amadagur' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Amarapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Bathalapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Bukkapatnam' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Chennekothapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Chilamathur' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Dharmavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Gandlapenta' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Gorantla' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Gudibanda' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Hindupur' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Kadiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Kanaganapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Kothacheruvu' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Lepakshi' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Madakasira' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Mudigubba' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Nallacheruvu' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Nallamada' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Nambulapulikunta' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Obuladevarecheruvu' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Parigi' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Penukonda' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Puttaparthi' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Ramagiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Roddam' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Rolla' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Somandepalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Tadimarri' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Talupula' UNION ALL 
 Select 'Andhra Pradesh' , N'Srikakulam' , N'Tanakal' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Balayapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Buchinadidu Khandriga' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Chandragiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Chillakur' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Chinnagottigallu' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Chittamur' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Dakkili' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Doravarisatram' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Gudur' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Kota' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'K.V.B.Puram' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Nagalapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Naidupeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Narayanavanam' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Ozili' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Pakala' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Pellakur' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Pitchatur' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Puttur' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Ramachandrapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Renigunta' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Satyavedu' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Srikalahasti' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Sullurpeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Tada' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Thottambedu' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Tirupati (Rural)' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Vadamalapeta' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Vakadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Varadaiahpalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Venkatagiri' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Yerpedu' UNION ALL 
 Select 'Andhra Pradesh' , N'Tirupati' , N'Yerravaripalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Visakhapatnam' , N'Anandapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Visakhapatnam' , N'Bheemunipatnam' UNION ALL 
 Select 'Andhra Pradesh' , N'Visakhapatnam' , N'Gajuwaka' UNION ALL 
 Select 'Andhra Pradesh' , N'Visakhapatnam' , N'Padmanabham' UNION ALL 
 Select 'Andhra Pradesh' , N'Visakhapatnam' , N'Pedagantyada' UNION ALL 
 Select 'Andhra Pradesh' , N'Visakhapatnam' , N'Pendurthi' UNION ALL 
 Select 'Andhra Pradesh' , N'Visakhapatnam' , N'Visakhapatnam(Rural)' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Badangi' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Bhoghapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Bobbili' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Bondapalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Cheepurupalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Dattirajeru' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Denkada' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Gajapathinagaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Gantyada' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Garividi' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Gurla' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Jami' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Kothavalasa' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Lakkavarapukota' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Mentada' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Merakamudidam' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Nellimarla' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Pusapatirega' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Rajam' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Ramabhadrapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Regidi Amadalavalasa' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Santhakavati' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Srungavarapukota' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Therlam' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Vangara' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Vepada' UNION ALL 
 Select 'Andhra Pradesh' , N'Vizianagaram' , N'Vizianagaram' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Achanta' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Akividu' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Attili' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Bhimavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Elamanchili' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Ganapavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Iragavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Kalla' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Mogalthur' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Narsapur' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Palacole' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Palakoderu' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Pentapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Penugonda' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Penumantra' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Poduru' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Tadepalligudem' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Tanuku' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Undi' UNION ALL 
 Select 'Andhra Pradesh' , N'West Godavari' , N'Veeravasaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Atlur' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Badvel' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'B.Kodur' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Brahmamgarimatham.' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Chakrayapet' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Chapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Chennur' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Chintakomma Dinne' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Duvvur' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Gopavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Jammalamadugu' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Kadapa' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Kalasapadu' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Kamalapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Khajipet' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Kondapuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Lingala' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Muddanur' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Mydukur' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Mylavaram' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Peddamudium' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Pendlimarri' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Porumamilla' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Proddatur' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Pulivendla' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Rajupalem' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Sidhout' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Simhadripuram' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Sri Avadutha Kasinayana' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Thondur' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Vallur' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Veerapanayani Palle' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Vempalle' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Vemula' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Vontimitta' UNION ALL 
 Select 'Andhra Pradesh' , N'Y.S.R.' , N'Yerraguntla' 
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Arunachal Pradesh', N'Anjaw' , N'Chaglagam' UNION ALL 
 Select 'Arunachal Pradesh', N'Anjaw' , N'Hawai-Walong' UNION ALL 
 Select 'Arunachal Pradesh', N'Anjaw' , N'Hayuliang' UNION ALL 
 Select 'Arunachal Pradesh', N'Anjaw' , N'Manchal' UNION ALL 
 Select 'Arunachal Pradesh', N'Changlang' , N'Bordumsa' UNION ALL 
 Select 'Arunachal Pradesh', N'Changlang' , N'Changlang' UNION ALL 
 Select 'Arunachal Pradesh', N'Changlang' , N'Diyun' UNION ALL 
 Select 'Arunachal Pradesh', N'Changlang' , N'Kantang' UNION ALL 
 Select 'Arunachal Pradesh', N'Changlang' , N'Khagam-Miao' UNION ALL 
 Select 'Arunachal Pradesh', N'Changlang' , N'Khimiyang' UNION ALL 
 Select 'Arunachal Pradesh', N'Changlang' , N'Manmao' UNION ALL 
 Select 'Arunachal Pradesh', N'Changlang' , N'Nampong' UNION ALL 
 Select 'Arunachal Pradesh', N'Changlang' , N'Vijoynagar' UNION ALL 
 Select 'Arunachal Pradesh', N'Changlang' , N'Yatdam' UNION ALL 
 Select 'Arunachal Pradesh', N'Dibang Valley' , N'Anelih Arzu' UNION ALL 
 Select 'Arunachal Pradesh', N'Dibang Valley' , N'Anini-Mepi' UNION ALL 
 Select 'Arunachal Pradesh', N'Dibang Valley' , N'Etalin Malinye' UNION ALL 
 Select 'Arunachal Pradesh', N'East Kameng' , N'Bameng' UNION ALL 
 Select 'Arunachal Pradesh', N'East Kameng' , N'Bana' UNION ALL 
 Select 'Arunachal Pradesh', N'East Kameng' , N'Chayangtajo' UNION ALL 
 Select 'Arunachal Pradesh', N'East Kameng' , N'Khenewa' UNION ALL 
 Select 'Arunachal Pradesh', N'East Kameng' , N'Lada' UNION ALL 
 Select 'Arunachal Pradesh', N'East Kameng' , N'Pipu' UNION ALL 
 Select 'Arunachal Pradesh', N'East Kameng' , N'Sawa' UNION ALL 
 Select 'Arunachal Pradesh', N'East Kameng' , N'Seppa' UNION ALL 
 Select 'Arunachal Pradesh', N'East Siang' , N'Bilat' UNION ALL 
 Select 'Arunachal Pradesh', N'East Siang' , N'Mebo' UNION ALL 
 Select 'Arunachal Pradesh', N'East Siang' , N'Pasighat' UNION ALL 
 Select 'Arunachal Pradesh', N'East Siang' , N'Ruksin' UNION ALL 
 Select 'Arunachal Pradesh', N'Kamle' , N'Gepen' UNION ALL 
 Select 'Arunachal Pradesh', N'Kamle' , N'Kamporijo' UNION ALL 
 Select 'Arunachal Pradesh', N'Kamle' , N'Persin Dollungmukh' UNION ALL 
 Select 'Arunachal Pradesh', N'Kamle' , N'Puchi Geko' UNION ALL 
 Select 'Arunachal Pradesh', N'Kamle' , N'Tamen-Raga' UNION ALL 
 Select 'Arunachal Pradesh', N'Kra Daadi' , N'Chambang' UNION ALL 
 Select 'Arunachal Pradesh', N'Kra Daadi' , N'Gangte' UNION ALL 
 Select 'Arunachal Pradesh', N'Kra Daadi' , N'Palin' UNION ALL 
 Select 'Arunachal Pradesh', N'Kra Daadi' , N'Pipsorang' UNION ALL 
 Select 'Arunachal Pradesh', N'Kra Daadi' , N'Tali' UNION ALL 
 Select 'Arunachal Pradesh', N'Kra Daadi' , N'Yangte' UNION ALL 
 Select 'Arunachal Pradesh', N'Kurung Kumey' , N'Damin' UNION ALL 
 Select 'Arunachal Pradesh', N'Kurung Kumey' , N'Koloriang' UNION ALL 
 Select 'Arunachal Pradesh', N'Kurung Kumey' , N'Nyapin' UNION ALL 
 Select 'Arunachal Pradesh', N'Kurung Kumey' , N'Paniasang' UNION ALL 
 Select 'Arunachal Pradesh', N'Kurung Kumey' , N'Parsiparlo' UNION ALL 
 Select 'Arunachal Pradesh', N'Kurung Kumey' , N'Phassang' UNION ALL 
 Select 'Arunachal Pradesh', N'Kurung Kumey' , N'Polosang' UNION ALL 
 Select 'Arunachal Pradesh', N'Kurung Kumey' , N'Sangram' UNION ALL 
 Select 'Arunachal Pradesh', N'Kurung Kumey' , N'Sarli' UNION ALL 
 Select 'Arunachal Pradesh', N'Leparada' , N'Basar' UNION ALL 
 Select 'Arunachal Pradesh', N'Leparada' , N'Daring' UNION ALL 
 Select 'Arunachal Pradesh', N'Leparada' , N'Tirbin' UNION ALL 
 Select 'Arunachal Pradesh', N'Lohit' , N'Tezu' UNION ALL 
 Select 'Arunachal Pradesh', N'Lohit' , N'Wakro' UNION ALL 
 Select 'Arunachal Pradesh', N'Longding' , N'Kanubari' UNION ALL 
 Select 'Arunachal Pradesh', N'Longding' , N'Lawnu' UNION ALL 
 Select 'Arunachal Pradesh', N'Longding' , N'Niausa' UNION ALL 
 Select 'Arunachal Pradesh', N'Longding' , N'Pongchau' UNION ALL 
 Select 'Arunachal Pradesh', N'Longding' , N'Wakka' UNION ALL 
 Select 'Arunachal Pradesh', N'Lower Dibang Valley' , N'Dambuk' UNION ALL 
 Select 'Arunachal Pradesh', N'Lower Dibang Valley' , N'Hunli-Kronli' UNION ALL 
 Select 'Arunachal Pradesh', N'Lower Dibang Valley' , N'Roing' UNION ALL 
 Select 'Arunachal Pradesh', N'Lower Siang' , N'Gensi' UNION ALL 
 Select 'Arunachal Pradesh', N'Lower Siang' , N'Kangku' UNION ALL 
 Select 'Arunachal Pradesh', N'Lower Siang' , N'Likabali' UNION ALL 
 Select 'Arunachal Pradesh', N'Lower Siang' , N'Ramle Bango' UNION ALL 
 Select 'Arunachal Pradesh', N'Lower Subansiri' , N'Hong-Hari' UNION ALL 
 Select 'Arunachal Pradesh', N'Lower Subansiri' , N'Pistana' UNION ALL 
 Select 'Arunachal Pradesh', N'Lower Subansiri' , N'Ziro-I' UNION ALL 
 Select 'Arunachal Pradesh', N'Lower Subansiri' , N'Ziro-Ii' UNION ALL 
 Select 'Arunachal Pradesh', N'Namsai' , N'Chowkham' UNION ALL 
 Select 'Arunachal Pradesh', N'Namsai' , N'Lekang' UNION ALL 
 Select 'Arunachal Pradesh', N'Namsai' , N'Namsai' UNION ALL 
 Select 'Arunachal Pradesh', N'Pakke Kessang' , N'Pakkekessang' UNION ALL 
 Select 'Arunachal Pradesh', N'Pakke Kessang' , N'Seijosa' UNION ALL 
 Select 'Arunachal Pradesh', N'Papum Pare' , N'Balijan' UNION ALL 
 Select 'Arunachal Pradesh', N'Papum Pare' , N'Borum' UNION ALL 
 Select 'Arunachal Pradesh', N'Papum Pare' , N'Doimukh' UNION ALL 
 Select 'Arunachal Pradesh', N'Papum Pare' , N'Kimin' UNION ALL 
 Select 'Arunachal Pradesh', N'Papum Pare' , N'Mengio' UNION ALL 
 Select 'Arunachal Pradesh', N'Papum Pare' , N'Sagalee' UNION ALL 
 Select 'Arunachal Pradesh', N'Shi Yomi' , N'Manigoan' UNION ALL 
 Select 'Arunachal Pradesh', N'Shi Yomi' , N'Mechuka-Tato' UNION ALL 
 Select 'Arunachal Pradesh', N'Siang' , N'Boleng' UNION ALL 
 Select 'Arunachal Pradesh', N'Siang' , N'Kaying' UNION ALL 
 Select 'Arunachal Pradesh', N'Siang' , N'Pangin' UNION ALL 
 Select 'Arunachal Pradesh', N'Siang' , N'Payum' UNION ALL 
 Select 'Arunachal Pradesh', N'Siang' , N'Rebo Parging' UNION ALL 
 Select 'Arunachal Pradesh', N'Siang' , N'Riga' UNION ALL 
 Select 'Arunachal Pradesh', N'Siang' , N'Rumgong' UNION ALL 
 Select 'Arunachal Pradesh', N'Tawang' , N'Jang-Thingbu' UNION ALL 
 Select 'Arunachal Pradesh', N'Tawang' , N'Kitpi' UNION ALL 
 Select 'Arunachal Pradesh', N'Tawang' , N'Lumla' UNION ALL 
 Select 'Arunachal Pradesh', N'Tawang' , N'Mukto Bongkhar' UNION ALL 
 Select 'Arunachal Pradesh', N'Tawang' , N'Tawang' UNION ALL 
 Select 'Arunachal Pradesh', N'Tawang' , N'Zemithang Dudunghar' UNION ALL 
 Select 'Arunachal Pradesh', N'Tirap' , N'Bari Basip' UNION ALL 
 Select 'Arunachal Pradesh', N'Tirap' , N'Borduria' UNION ALL 
 Select 'Arunachal Pradesh', N'Tirap' , N'Dadam' UNION ALL 
 Select 'Arunachal Pradesh', N'Tirap' , N'Khonsa' UNION ALL 
 Select 'Arunachal Pradesh', N'Tirap' , N'Lazu' UNION ALL 
 Select 'Arunachal Pradesh', N'Tirap' , N'Namsang' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Siang' , N'Geku' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Siang' , N'Jengging' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Siang' , N'Mariyang' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Siang' , N'Singa Gelling' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Siang' , N'Tuting' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Siang' , N'Yingkiong' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Subansiri' , N'Baririjo' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Subansiri' , N'Chetam' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Subansiri' , N'Daporijo' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Subansiri' , N'Dumporijo' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Subansiri' , N'Giba' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Subansiri' , N'Limeking' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Subansiri' , N'Nacho' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Subansiri' , N'Payeng' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Subansiri' , N'Siyum' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Subansiri' , N'Taksing' UNION ALL 
 Select 'Arunachal Pradesh', N'Upper Subansiri' , N'Taliha' UNION ALL 
 Select 'Arunachal Pradesh', N'West Kameng' , N'Dirang' UNION ALL 
 Select 'Arunachal Pradesh', N'West Kameng' , N'Kalaktang' UNION ALL 
 Select 'Arunachal Pradesh', N'West Kameng' , N'Nafra' UNION ALL 
 Select 'Arunachal Pradesh', N'West Kameng' , N'Singchung' UNION ALL 
 Select 'Arunachal Pradesh', N'West Kameng' , N'Thrizino' UNION ALL 
 Select 'Arunachal Pradesh', N'West Siang' , N'Along East' UNION ALL 
 Select 'Arunachal Pradesh', N'West Siang' , N'Along West' UNION ALL 
 Select 'Arunachal Pradesh', N'West Siang' , N'Bagra' UNION ALL 
 Select 'Arunachal Pradesh', N'West Siang' , N'Darak' UNION ALL 
 Select 'Arunachal Pradesh', N'West Siang' , N'Liromoba-Yomcha'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Bihar' , N'Araria' , N'Araria' UNION ALL 
 Select 'Bihar' , N'Araria' , N'Bhargama' UNION ALL 
 Select 'Bihar' , N'Araria' , N'Forbesganj' UNION ALL 
 Select 'Bihar' , N'Araria' , N'Jokihat' UNION ALL 
 Select 'Bihar' , N'Araria' , N'Kursakanta' UNION ALL 
 Select 'Bihar' , N'Araria' , N'Narpatganj' UNION ALL 
 Select 'Bihar' , N'Araria' , N'Palasi' UNION ALL 
 Select 'Bihar' , N'Araria' , N'Raniganj' UNION ALL 
 Select 'Bihar' , N'Araria' , N'Sikty' UNION ALL 
 Select 'Bihar' , N'Arwal' , N'Arwal' UNION ALL 
 Select 'Bihar' , N'Arwal' , N'Kaler' UNION ALL 
 Select 'Bihar' , N'Arwal' , N'Kapri' UNION ALL 
 Select 'Bihar' , N'Arwal' , N'Kurtha' UNION ALL 
 Select 'Bihar' , N'Arwal' , N'Sonbhadra-Bansi-Surajpur' UNION ALL 
 Select 'Bihar' , N'Aurangabad' , N'Aurangabad' UNION ALL 
 Select 'Bihar' , N'Aurangabad' , N'Barun' UNION ALL 
 Select 'Bihar' , N'Aurangabad' , N'Daudnagar' UNION ALL 
 Select 'Bihar' , N'Aurangabad' , N'Deo' UNION ALL 
 Select 'Bihar' , N'Aurangabad' , N'Goh' UNION ALL 
 Select 'Bihar' , N'Aurangabad' , N'Haspura' UNION ALL 
 Select 'Bihar' , N'Aurangabad' , N'Kutumba' UNION ALL 
 Select 'Bihar' , N'Aurangabad' , N'Madanpur' UNION ALL 
 Select 'Bihar' , N'Aurangabad' , N'Nabinagar' UNION ALL 
 Select 'Bihar' , N'Aurangabad' , N'Obra' UNION ALL 
 Select 'Bihar' , N'Aurangabad' , N'Rafiganj' UNION ALL 
 Select 'Bihar' , N'Banka' , N'Amarpur' UNION ALL 
 Select 'Bihar' , N'Banka' , N'Banka' UNION ALL 
 Select 'Bihar' , N'Banka' , N'Barahat' UNION ALL 
 Select 'Bihar' , N'Banka' , N'Bausi' UNION ALL 
 Select 'Bihar' , N'Banka' , N'Belhar' UNION ALL 
 Select 'Bihar' , N'Banka' , N'Chandan' UNION ALL 
 Select 'Bihar' , N'Banka' , N'Dhuraiya' UNION ALL 
 Select 'Bihar' , N'Banka' , N'Fullidumar' UNION ALL 
 Select 'Bihar' , N'Banka' , N'Katoria' UNION ALL 
 Select 'Bihar' , N'Banka' , N'Rajaun' UNION ALL 
 Select 'Bihar' , N'Banka' , N'Shambhuganj' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Bachhwara' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Bakhri' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Ballia' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Barauni' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Begusarai' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Bhagwanpur' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Birpur' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Cheria Bariarpur' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Chhaurahi' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Dandari' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Gadhpura' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Khodawandpur' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Mansurchak' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Matihani' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Nawkothi' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Sahebpur Kamal' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Samho Akha Kurha' UNION ALL 
 Select 'Bihar' , N'Begusarai' , N'Teghra' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Bihpur' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Gopalpur' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Goradih' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Ismailpur' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Jagdishpur' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Kahalgaon' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Kharik' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Narayanpur' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Nathnagar' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Naugachhia' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Pirpainti' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Rangrachowk' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Sabour' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Shahkund' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Sonhaula' UNION ALL 
 Select 'Bihar' , N'Bhagalpur' , N'Sultanganj' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Agiaon' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Ara' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Barhara' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Behea' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Charpokhari' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Garhani' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Jagdishpur' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Koilwar' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Piro' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Sahar' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Sandesh' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Shahpur' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Tarari' UNION ALL 
 Select 'Bihar' , N'Bhojpur' , N'Udwantnagar' UNION ALL 
 Select 'Bihar' , N'Buxar' , N'Brahmpur' UNION ALL 
 Select 'Bihar' , N'Buxar' , N'Buxar' UNION ALL 
 Select 'Bihar' , N'Buxar' , N'Chakki' UNION ALL 
 Select 'Bihar' , N'Buxar' , N'Chausa' UNION ALL 
 Select 'Bihar' , N'Buxar' , N'Chougain' UNION ALL 
 Select 'Bihar' , N'Buxar' , N'Dumraon' UNION ALL 
 Select 'Bihar' , N'Buxar' , N'Itarhi' UNION ALL 
 Select 'Bihar' , N'Buxar' , N'Kesath' UNION ALL 
 Select 'Bihar' , N'Buxar' , N'Nawanagar' UNION ALL 
 Select 'Bihar' , N'Buxar' , N'Rajpur' UNION ALL 
 Select 'Bihar' , N'Buxar' , N'Simri' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Alinagar' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Bahadurpur' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Baheri' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Benipur' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Biraul' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Darbhanga' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Gaurabauram' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Ghanshyampur' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Hanuman Nagar' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Hayaghat' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Jale' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Keotirunway' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Kiratpur' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Kusheshwar Asthan' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Kusheswar Asthan East' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Manigachhi' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Singhwara' UNION ALL 
 Select 'Bihar' , N'Darbhanga' , N'Tardih' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Amas' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Atri' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Bankey Bazar' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Barachatti' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Belaganj' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Bodhgaya' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Dobhi' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Dumaria' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Fatehpur' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Gaya Town' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Guraru' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Gurua' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Imamganj' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Khizarsarai' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Konch' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Manpur' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Mohanpur' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Mohra' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Neemchak Bathani' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Paraiya' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Sherghatty' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Tankuppa' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Tekari' UNION ALL 
 Select 'Bihar' , N'Gaya' , N'Wazirganj' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Baikunthpur' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Barauli' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Bhorey' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Bijaipur' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Gopalganj' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Hathua' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Kataiya' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Kuchaikote' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Manjha' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Panchdeori' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Phulwariya' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Sidhwaliya' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Thawe' UNION ALL 
 Select 'Bihar' , N'Gopalganj' , N'Uchkagaon' UNION ALL 
 Select 'Bihar' , N'Jamui' , N'Barhat' UNION ALL 
 Select 'Bihar' , N'Jamui' , N'Chakai' UNION ALL 
 Select 'Bihar' , N'Jamui' , N'Gidhor' UNION ALL 
 Select 'Bihar' , N'Jamui' , N'Islamnagar Aliganj' UNION ALL 
 Select 'Bihar' , N'Jamui' , N'Jamui' UNION ALL 
 Select 'Bihar' , N'Jamui' , N'Jhajha' UNION ALL 
 Select 'Bihar' , N'Jamui' , N'Khaira' UNION ALL 
 Select 'Bihar' , N'Jamui' , N'Laxmipur' UNION ALL 
 Select 'Bihar' , N'Jamui' , N'Sikandra' UNION ALL 
 Select 'Bihar' , N'Jamui' , N'Sono' UNION ALL 
 Select 'Bihar' , N'Jehanabad' , N'Ghoshi' UNION ALL 
 Select 'Bihar' , N'Jehanabad' , N'Hulasganj' UNION ALL 
 Select 'Bihar' , N'Jehanabad' , N'Jehanabad' UNION ALL 
 Select 'Bihar' , N'Jehanabad' , N'Kako' UNION ALL 
 Select 'Bihar' , N'Jehanabad' , N'Makhdumpur' UNION ALL 
 Select 'Bihar' , N'Jehanabad' , N'Modanganj' UNION ALL 
 Select 'Bihar' , N'Jehanabad' , N'Ratni Faridpur' UNION ALL 
 Select 'Bihar' , N'Kaimur (Bhabua)' , N'Adhaura' UNION ALL 
 Select 'Bihar' , N'Kaimur (Bhabua)' , N'Bhabua' UNION ALL 
 Select 'Bihar' , N'Kaimur (Bhabua)' , N'Bhagwanpur' UNION ALL 
 Select 'Bihar' , N'Kaimur (Bhabua)' , N'Chainpur' UNION ALL 
 Select 'Bihar' , N'Kaimur (Bhabua)' , N'Chand' UNION ALL 
 Select 'Bihar' , N'Kaimur (Bhabua)' , N'Durgawati' UNION ALL 
 Select 'Bihar' , N'Kaimur (Bhabua)' , N'Kudra' UNION ALL 
 Select 'Bihar' , N'Kaimur (Bhabua)' , N'Mohania' UNION ALL 
 Select 'Bihar' , N'Kaimur (Bhabua)' , N'Nuaon' UNION ALL 
 Select 'Bihar' , N'Kaimur (Bhabua)' , N'Ramgarh' UNION ALL 
 Select 'Bihar' , N'Kaimur (Bhabua)' , N'Rampur' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Amdabad' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Azamnagar' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Balrampur' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Barari' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Barsoi' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Dandkhora' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Falka' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Hasanganj' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Kadwa' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Katihar' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Korha' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Kursela' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Manihari' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Mansahi' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Pranpur' UNION ALL 
 Select 'Bihar' , N'Katihar' , N'Sameli' UNION ALL 
 Select 'Bihar' , N'Khagaria' , N'Alauli' UNION ALL 
 Select 'Bihar' , N'Khagaria' , N'Beldaur' UNION ALL 
 Select 'Bihar' , N'Khagaria' , N'Chautham' UNION ALL 
 Select 'Bihar' , N'Khagaria' , N'Gogri' UNION ALL 
 Select 'Bihar' , N'Khagaria' , N'Khagaria' UNION ALL 
 Select 'Bihar' , N'Khagaria' , N'Mansi' UNION ALL 
 Select 'Bihar' , N'Khagaria' , N'Parbatta' UNION ALL 
 Select 'Bihar' , N'Kishanganj' , N'Bahadurganj' UNION ALL 
 Select 'Bihar' , N'Kishanganj' , N'Dighalbank' UNION ALL 
 Select 'Bihar' , N'Kishanganj' , N'Kishanganj' UNION ALL 
 Select 'Bihar' , N'Kishanganj' , N'Kochadhaman' UNION ALL 
 Select 'Bihar' , N'Kishanganj' , N'Pothia' UNION ALL 
 Select 'Bihar' , N'Kishanganj' , N'Terhagachh' UNION ALL 
 Select 'Bihar' , N'Kishanganj' , N'Thakurganj' UNION ALL 
 Select 'Bihar' , N'Lakhisarai' , N'Barahiya' UNION ALL 
 Select 'Bihar' , N'Lakhisarai' , N'Channan' UNION ALL 
 Select 'Bihar' , N'Lakhisarai' , N'Halsi' UNION ALL 
 Select 'Bihar' , N'Lakhisarai' , N'Lakhisarai' UNION ALL 
 Select 'Bihar' , N'Lakhisarai' , N'Pipariya' UNION ALL 
 Select 'Bihar' , N'Lakhisarai' , N'Ramgarh Chowk' UNION ALL 
 Select 'Bihar' , N'Lakhisarai' , N'Surajgarha' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Alamnagar' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Bihariganj' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Chausa' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Gamhariya' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Ghelarh' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Gwalpara' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Kumarkhand' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Madhepura' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Murliganj' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Purani' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Shankarpur' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Singheshwar' UNION ALL 
 Select 'Bihar' , N'Madhepura' , N'Udakishunganj' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Andhratharhi' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Babu Barhi' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Basopatti' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Benipatti' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Bisfi' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Ghoghardiha' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Harlakhi' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Jainagar' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Jhanjharpur' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Kaluahi' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Khajauli' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Ladania' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Lakhnaur' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Laukaha (Khutauna)' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Laukahi' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Madhepur' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Madhwapur' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Pandaul' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Phulparas' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Rahika' UNION ALL 
 Select 'Bihar' , N'Madhubani' , N'Rajnagar' UNION ALL 
 Select 'Bihar' , N'Munger' , N'Asarganj' UNION ALL 
 Select 'Bihar' , N'Munger' , N'Bariyarpur' UNION ALL 
 Select 'Bihar' , N'Munger' , N'Dharhara' UNION ALL 
 Select 'Bihar' , N'Munger' , N'Jamalpur' UNION ALL 
 Select 'Bihar' , N'Munger' , N'Kharagpur' UNION ALL 
 Select 'Bihar' , N'Munger' , N'Munger Sadar' UNION ALL 
 Select 'Bihar' , N'Munger' , N'Sangrampur' UNION ALL 
 Select 'Bihar' , N'Munger' , N'Tarapur' UNION ALL 
 Select 'Bihar' , N'Munger' , N'Tetiabambar' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Aurai' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Bandra' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Bochahan' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Gaighat' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Kanti' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Katra' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Kurhani' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Marwan' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Minapur' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Motipur' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Muraul' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Mushahari' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Paroo' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Sahebganj' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Sakra' UNION ALL 
 Select 'Bihar' , N'Muzaffarpur' , N'Saraiya' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Asthawan' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Ben' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Biharsharif' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Bind' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Chandi' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Ekangarsarai' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Giriak' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Harnaut' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Hilsa' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Islampur' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Karai Parsurai' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Katrisarai' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Nagar Nausa' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Noorsarai' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Parbalpur' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Rahui' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Rajgir' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Sarmera' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Silao' UNION ALL 
 Select 'Bihar' , N'Nalanda' , N'Tharthari' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Akbarpur' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Gobindpur' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Hisua' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Kashichak' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Kawakole' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Mescaur' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Nardiganj' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Narhat' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Nawada' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Pakri Barawan' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Rajauli' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Roh' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Sirdala' UNION ALL 
 Select 'Bihar' , N'Nawada' , N'Warisaliganj' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Bagaha-I' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Bagaha-Ii' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Bairia' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Bettiah' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Bhitaha' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Chanpatia' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Gaunaha' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Jogapatti' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Lauriya' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Madhubani' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Mainatand' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Majhaulia' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Narkatiaganj' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Nautan' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Piprasi' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Ramnagar' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Sikta' UNION ALL 
 Select 'Bihar' , N'Pashchim Champaran' , N'Thakrahan' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Athamalgola' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Bakhtiarpur' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Barh' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Belchchi' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Bihta' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Bikram' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Daniyawan' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Dhanarua' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Dinapur' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Dulhin Bazar' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Fatuha' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Ghoswari' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Khusrupur' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Maner' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Masaurhi' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Mokama' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Naubatpur' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Paliganj' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Pandarak' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Patna Sadar' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Phulwari' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Punpun' UNION ALL 
 Select 'Bihar' , N'Patna' , N'Sampatchak' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Adapur' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Areraj' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Banjariya' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Bankatwa' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Chakia (Pipra)' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Chawradano' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Chiraiya' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Dhaka' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Ghorasahan' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Harsidhi' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Kalyanpur' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Kesaria' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Kotwa' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Madhuban' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Mehsi' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Motihari' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Paharpur' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Pakridayal' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Patahi' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Phenhara' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Pipra Kothi' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Ramgarhwa' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Raxaul' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Sangrampur' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Sugauli' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Tetariya' UNION ALL 
 Select 'Bihar' , N'Purbi Champaran' , N'Turkaulia' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Amour' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Baisa' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Baisi' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Banmankhi' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Barhara' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Bhawanipur' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Dagraua' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Dhamdaha' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Jalalgarh' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Kasba' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Krityanand Nagar' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Purnia East' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Rupouli' UNION ALL 
 Select 'Bihar' , N'Purnia' , N'Srinagar' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Akorhigola' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Bikramganj' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Chenari' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Dawath' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Dehri' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Dinara' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Karakat' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Kargahar' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Kochas' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Nasriganj' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Nawhatta' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Nokha' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Rajpur' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Rohtas' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Sanjhouli' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Sasaram' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Sheosagar' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Surajpura' UNION ALL 
 Select 'Bihar' , N'Rohtas' , N'Tilouthu' UNION ALL 
 Select 'Bihar' , N'Saharsa' , N'Banma Itahari' UNION ALL 
 Select 'Bihar' , N'Saharsa' , N'Kahara' UNION ALL 
 Select 'Bihar' , N'Saharsa' , N'Mahishi' UNION ALL 
 Select 'Bihar' , N'Saharsa' , N'Nauhatta' UNION ALL 
 Select 'Bihar' , N'Saharsa' , N'Patarghat' UNION ALL 
 Select 'Bihar' , N'Saharsa' , N'Salkhua' UNION ALL 
 Select 'Bihar' , N'Saharsa' , N'Sattar Kattaiya' UNION ALL 
 Select 'Bihar' , N'Saharsa' , N'Simri Bakhtiarpur' UNION ALL 
 Select 'Bihar' , N'Saharsa' , N'Sonbarsa' UNION ALL 
 Select 'Bihar' , N'Saharsa' , N'Sour Bazar' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Bibhutipur' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Bithan' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Dalsinghsarai' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Hasanpur' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Kalyanpur' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Khanpur' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Mohanpur' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Mohiuddinagar' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Morwa' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Patori' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Pusa' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Rosera' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Samastipur' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Sarairanjan' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Shivaji Nagar' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Singhia' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Tajpur' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Ujiarpur' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Vidyapati Nagar' UNION ALL 
 Select 'Bihar' , N'Samastipur' , N'Warisnagar' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Amnour' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Baniapur' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Chhapra' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Dariapur' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Dighwara' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Ekma' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Garkha' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Isuapur' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Jalalpur' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Lahladpur' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Maker' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Manjhi' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Marhaurah' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Mashrakh' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Nagra' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Panapur' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Parsa' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Revelganj' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Sonepur' UNION ALL 
 Select 'Bihar' , N'Saran' , N'Taraiya' UNION ALL 
 Select 'Bihar' , N'Sheikhpura' , N'Ariari' UNION ALL 
 Select 'Bihar' , N'Sheikhpura' , N'Barbigha' UNION ALL 
 Select 'Bihar' , N'Sheikhpura' , N'Chewara' UNION ALL 
 Select 'Bihar' , N'Sheikhpura' , N'Ghatkusumbha' UNION ALL 
 Select 'Bihar' , N'Sheikhpura' , N'Sheikhpura' UNION ALL 
 Select 'Bihar' , N'Sheikhpura' , N'Shekhopur Sarai' UNION ALL 
 Select 'Bihar' , N'Sheohar' , N'Dumari Katsari' UNION ALL 
 Select 'Bihar' , N'Sheohar' , N'Piprahi' UNION ALL 
 Select 'Bihar' , N'Sheohar' , N'Purnahiya' UNION ALL 
 Select 'Bihar' , N'Sheohar' , N'Sheohar' UNION ALL 
 Select 'Bihar' , N'Sheohar' , N'Tariyani' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Bairgania' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Bajpatti' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Bathanaha' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Belsand' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Bokhra' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Choraut' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Dumra' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Majorganj' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Nanpur' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Parihar' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Parsauni' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Pupri' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Riga' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Runnisaidpur' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Sonbarsa' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Suppi' UNION ALL 
 Select 'Bihar' , N'Sitamarhi' , N'Sursand' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Andar' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Barharia' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Basantpur' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Bhagwanpur Hat' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Darauli' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Daraundha' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Goriakothi' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Guthani' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Hasan Pura' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Hussainganj' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Lakri Nabiganj' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Maharajganj' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Mairwa' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Nautan' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Pachrukhi' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Raghunathpur' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Siswan' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Siwan' UNION ALL 
 Select 'Bihar' , N'Siwan' , N'Ziradei' UNION ALL 
 Select 'Bihar' , N'Supaul' , N'Basantpur' UNION ALL 
 Select 'Bihar' , N'Supaul' , N'Chhatapur' UNION ALL 
 Select 'Bihar' , N'Supaul' , N'Kishanpur' UNION ALL 
 Select 'Bihar' , N'Supaul' , N'Marauna' UNION ALL 
 Select 'Bihar' , N'Supaul' , N'Nirmali' UNION ALL 
 Select 'Bihar' , N'Supaul' , N'Pipra' UNION ALL 
 Select 'Bihar' , N'Supaul' , N'Pratapganj' UNION ALL 
 Select 'Bihar' , N'Supaul' , N'Raghopur' UNION ALL 
 Select 'Bihar' , N'Supaul' , N'Saraigarh Bhaptiyahi' UNION ALL 
 Select 'Bihar' , N'Supaul' , N'Supaul' UNION ALL 
 Select 'Bihar' , N'Supaul' , N'Tribeniganj' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Bhagwanpur' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Bidupur' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Chehrakala' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Desri' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Garaul' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Hajipur' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Jandaha' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Lalganj' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Mahnar' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Mahua' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Patedhi Belsar' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Patepur' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Raghopur' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Rajapakar' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Sahdei Buzurg' UNION ALL 
 Select 'Bihar' , N'Vaishali' , N'Vaishali'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
Select 'Chandigarh' , N'Chandigarh' , N'Chandigarh'
)
INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
Select 'Chandigarh' , N'Chandigarh' , N'Chandigarh'
)
INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Chhattisgarh' , N'Balod' , N'Balod' UNION ALL 
 Select 'Chhattisgarh' , N'Balod' , N'Dondi' UNION ALL 
 Select 'Chhattisgarh' , N'Balod' , N'Dondilohara' UNION ALL 
 Select 'Chhattisgarh' , N'Balod' , N'Gunderdehi' UNION ALL 
 Select 'Chhattisgarh' , N'Balod' , N'Gurur' UNION ALL 
 Select 'Chhattisgarh' , N'Balodabazar-Bhatapara' , N'Baloda Bazar' UNION ALL 
 Select 'Chhattisgarh' , N'Balodabazar-Bhatapara' , N'Bhatapara' UNION ALL 
 Select 'Chhattisgarh' , N'Balodabazar-Bhatapara' , N'Kasdol' UNION ALL 
 Select 'Chhattisgarh' , N'Balodabazar-Bhatapara' , N'Palari' UNION ALL 
 Select 'Chhattisgarh' , N'Balodabazar-Bhatapara' , N'Simga' UNION ALL 
 Select 'Chhattisgarh' , N'Balrampur Ramanujganj' , N'Balrampur' UNION ALL 
 Select 'Chhattisgarh' , N'Balrampur Ramanujganj' , N'Kusmi' UNION ALL 
 Select 'Chhattisgarh' , N'Balrampur Ramanujganj' , N'Rajpur' UNION ALL 
 Select 'Chhattisgarh' , N'Balrampur Ramanujganj' , N'Ramchandrapur' UNION ALL 
 Select 'Chhattisgarh' , N'Balrampur Ramanujganj' , N'Shankargarh' UNION ALL 
 Select 'Chhattisgarh' , N'Balrampur Ramanujganj' , N'Wadrafnagar' UNION ALL 
 Select 'Chhattisgarh' , N'Bastar' , N'Bakawand' UNION ALL 
 Select 'Chhattisgarh' , N'Bastar' , N'Bastanar' UNION ALL 
 Select 'Chhattisgarh' , N'Bastar' , N'Bastar' UNION ALL 
 Select 'Chhattisgarh' , N'Bastar' , N'Darbha' UNION ALL 
 Select 'Chhattisgarh' , N'Bastar' , N'Jagdalpur' UNION ALL 
 Select 'Chhattisgarh' , N'Bastar' , N'Lohandiguda' UNION ALL 
 Select 'Chhattisgarh' , N'Bastar' , N'Tokapal' UNION ALL 
 Select 'Chhattisgarh' , N'Bemetara' , N'Bemetara' UNION ALL 
 Select 'Chhattisgarh' , N'Bemetara' , N'Berla' UNION ALL 
 Select 'Chhattisgarh' , N'Bemetara' , N'Nawagarh' UNION ALL 
 Select 'Chhattisgarh' , N'Bemetara' , N'Saja' UNION ALL 
 Select 'Chhattisgarh' , N'Bijapur' , N'Bhairamgarh' UNION ALL 
 Select 'Chhattisgarh' , N'Bijapur' , N'Bhopal Patnam' UNION ALL 
 Select 'Chhattisgarh' , N'Bijapur' , N'Bijapur' UNION ALL 
 Select 'Chhattisgarh' , N'Bijapur' , N'Usoor' UNION ALL 
 Select 'Chhattisgarh' , N'Bilaspur' , N'Belha' UNION ALL 
 Select 'Chhattisgarh' , N'Bilaspur' , N'Kota' UNION ALL 
 Select 'Chhattisgarh' , N'Bilaspur' , N'Masturi' UNION ALL 
 Select 'Chhattisgarh' , N'Bilaspur' , N'Takhatpur' UNION ALL 
 Select 'Chhattisgarh' , N'Dakshin Bastar Dantewada' , N'Dantewada' UNION ALL 
 Select 'Chhattisgarh' , N'Dakshin Bastar Dantewada' , N'Geedam' UNION ALL 
 Select 'Chhattisgarh' , N'Dakshin Bastar Dantewada' , N'Katekalyan' UNION ALL 
 Select 'Chhattisgarh' , N'Dakshin Bastar Dantewada' , N'Kuwakonda' UNION ALL 
 Select 'Chhattisgarh' , N'Dhamtari' , N'Dhamtari' UNION ALL 
 Select 'Chhattisgarh' , N'Dhamtari' , N'Kurud' UNION ALL 
 Select 'Chhattisgarh' , N'Dhamtari' , N'Magarlod' UNION ALL 
 Select 'Chhattisgarh' , N'Dhamtari' , N'Nagari' UNION ALL 
 Select 'Chhattisgarh' , N'Durg' , N'Dhamdha' UNION ALL 
 Select 'Chhattisgarh' , N'Durg' , N'Durg' UNION ALL 
 Select 'Chhattisgarh' , N'Durg' , N'Patan' UNION ALL 
 Select 'Chhattisgarh' , N'Gariyaband' , N'Chhurra' UNION ALL 
 Select 'Chhattisgarh' , N'Gariyaband' , N'Deobhog' UNION ALL 
 Select 'Chhattisgarh' , N'Gariyaband' , N'Fingeshwar' UNION ALL 
 Select 'Chhattisgarh' , N'Gariyaband' , N'Gariyaband' UNION ALL 
 Select 'Chhattisgarh' , N'Gariyaband' , N'Mainpur' UNION ALL 
 Select 'Chhattisgarh' , N'Gaurela Pendra Marwahi' , N'Gaurella-1' UNION ALL 
 Select 'Chhattisgarh' , N'Gaurela Pendra Marwahi' , N'Gaurella-2' UNION ALL 
 Select 'Chhattisgarh' , N'Gaurela Pendra Marwahi' , N'Marwahi' UNION ALL 
 Select 'Chhattisgarh' , N'Janjgir-Champa' , N'Akaltara' UNION ALL 
 Select 'Chhattisgarh' , N'Janjgir-Champa' , N'Baloda' UNION ALL 
 Select 'Chhattisgarh' , N'Janjgir-Champa' , N'Bamhindih' UNION ALL 
 Select 'Chhattisgarh' , N'Janjgir-Champa' , N'Nawagarh' UNION ALL 
 Select 'Chhattisgarh' , N'Janjgir-Champa' , N'Pamgarh' UNION ALL 
 Select 'Chhattisgarh' , N'Jashpur' , N'Bagicha' UNION ALL 
 Select 'Chhattisgarh' , N'Jashpur' , N'Duldula' UNION ALL 
 Select 'Chhattisgarh' , N'Jashpur' , N'Jashpur' UNION ALL 
 Select 'Chhattisgarh' , N'Jashpur' , N'Kansabel' UNION ALL 
 Select 'Chhattisgarh' , N'Jashpur' , N'Kunkuri' UNION ALL 
 Select 'Chhattisgarh' , N'Jashpur' , N'Manora' UNION ALL 
 Select 'Chhattisgarh' , N'Jashpur' , N'Patthalgaon' UNION ALL 
 Select 'Chhattisgarh' , N'Jashpur' , N'Pharsabahar' UNION ALL 
 Select 'Chhattisgarh' , N'Kabeerdham' , N'Bodla' UNION ALL 
 Select 'Chhattisgarh' , N'Kabeerdham' , N'Kawardha' UNION ALL 
 Select 'Chhattisgarh' , N'Kabeerdham' , N'Pandariya' UNION ALL 
 Select 'Chhattisgarh' , N'Kabeerdham' , N'S.Lohara' UNION ALL 
 Select 'Chhattisgarh' , N'Khairagarh Chhuikhadan Gandai' , N'Chhuikhadan' UNION ALL 
 Select 'Chhattisgarh' , N'Khairagarh Chhuikhadan Gandai' , N'Khairagarh' UNION ALL 
 Select 'Chhattisgarh' , N'Kondagaon' , N'Baderajpur' UNION ALL 
 Select 'Chhattisgarh' , N'Kondagaon' , N'Keshkal' UNION ALL 
 Select 'Chhattisgarh' , N'Kondagaon' , N'Kondagaon' UNION ALL 
 Select 'Chhattisgarh' , N'Kondagaon' , N'Makdi' UNION ALL 
 Select 'Chhattisgarh' , N'Kondagaon' , N'Pharasgaon' UNION ALL 
 Select 'Chhattisgarh' , N'Korba' , N'Kartala' UNION ALL 
 Select 'Chhattisgarh' , N'Korba' , N'Katghora' UNION ALL 
 Select 'Chhattisgarh' , N'Korba' , N'Korba' UNION ALL 
 Select 'Chhattisgarh' , N'Korba' , N'Pali' UNION ALL 
 Select 'Chhattisgarh' , N'Korba' , N'Podi Uparoda' UNION ALL 
 Select 'Chhattisgarh' , N'Korea' , N'Baikunthpur' UNION ALL 
 Select 'Chhattisgarh' , N'Korea' , N'Sonhat' UNION ALL 
 Select 'Chhattisgarh' , N'Mahasamund' , N'Bagbahara' UNION ALL 
 Select 'Chhattisgarh' , N'Mahasamund' , N'Basna' UNION ALL 
 Select 'Chhattisgarh' , N'Mahasamund' , N'Mahasamund' UNION ALL 
 Select 'Chhattisgarh' , N'Mahasamund' , N'Pithora' UNION ALL 
 Select 'Chhattisgarh' , N'Mahasamund' , N'Saraipali' UNION ALL 
 Select 'Chhattisgarh' , N'Manendragarh Chirmiri Bharatpur Mcb' , N'Khadgawana' UNION ALL 
 Select 'Chhattisgarh' , N'Manendragarh Chirmiri Bharatpur Mcb' , N'Bharatpur' UNION ALL 
 Select 'Chhattisgarh' , N'Manendragarh Chirmiri Bharatpur Mcb' , N'Manendragarh' UNION ALL 
 Select 'Chhattisgarh' , N'Mohla Manpur Ambagarh Chouki' , N'A.Chowki (Td)' UNION ALL 
 Select 'Chhattisgarh' , N'Mohla Manpur Ambagarh Chouki' , N'Manpur (Td)' UNION ALL 
 Select 'Chhattisgarh' , N'Mohla Manpur Ambagarh Chouki' , N'Mohala (Td)' UNION ALL 
 Select 'Chhattisgarh' , N'Mungeli' , N'Lormi' UNION ALL 
 Select 'Chhattisgarh' , N'Mungeli' , N'Mungeli' UNION ALL 
 Select 'Chhattisgarh' , N'Mungeli' , N'Pathariya' UNION ALL 
 Select 'Chhattisgarh' , N'Narayanpur' , N'Narayanpur' UNION ALL 
 Select 'Chhattisgarh' , N'Narayanpur' , N'Orchha(Abhujmad)' UNION ALL 
 Select 'Chhattisgarh' , N'Raigarh' , N'Dharamjaigarh' UNION ALL 
 Select 'Chhattisgarh' , N'Raigarh' , N'Gharghoda' UNION ALL 
 Select 'Chhattisgarh' , N'Raigarh' , N'Kharsia' UNION ALL 
 Select 'Chhattisgarh' , N'Raigarh' , N'Lailunga' UNION ALL 
 Select 'Chhattisgarh' , N'Raigarh' , N'Pussore' UNION ALL 
 Select 'Chhattisgarh' , N'Raigarh' , N'Raigarh' UNION ALL 
 Select 'Chhattisgarh' , N'Raigarh' , N'Tamnar' UNION ALL 
 Select 'Chhattisgarh' , N'Raipur' , N'Abhanpur' UNION ALL 
 Select 'Chhattisgarh' , N'Raipur' , N'Arang' UNION ALL 
 Select 'Chhattisgarh' , N'Raipur' , N'Dharsiwa' UNION ALL 
 Select 'Chhattisgarh' , N'Raipur' , N'Tilda' UNION ALL 
 Select 'Chhattisgarh' , N'Rajnandgaon' , N'Chhuriya' UNION ALL 
 Select 'Chhattisgarh' , N'Rajnandgaon' , N'Dongargaon' UNION ALL 
 Select 'Chhattisgarh' , N'Rajnandgaon' , N'Dongarghar' UNION ALL 
 Select 'Chhattisgarh' , N'Rajnandgaon' , N'Rajnandgaon' UNION ALL 
 Select 'Chhattisgarh' , N'Sakti' , N'Dabhara' UNION ALL 
 Select 'Chhattisgarh' , N'Sakti' , N'Jaijaipur' UNION ALL 
 Select 'Chhattisgarh' , N'Sakti' , N'Malkharoda' UNION ALL 
 Select 'Chhattisgarh' , N'Sakti' , N'Sakti' UNION ALL 
 Select 'Chhattisgarh' , N'Sarangarh Bilaigarh' , N'Baramkela' UNION ALL 
 Select 'Chhattisgarh' , N'Sarangarh Bilaigarh' , N'Bilaigarh' UNION ALL 
 Select 'Chhattisgarh' , N'Sarangarh Bilaigarh' , N'Sarangarh' UNION ALL 
 Select 'Chhattisgarh' , N'Sukma' , N'Chhindgarh' UNION ALL 
 Select 'Chhattisgarh' , N'Sukma' , N'Konta' UNION ALL 
 Select 'Chhattisgarh' , N'Sukma' , N'Sukma' UNION ALL 
 Select 'Chhattisgarh' , N'Surajpur' , N'Bhaiyathan' UNION ALL 
 Select 'Chhattisgarh' , N'Surajpur' , N'Odagi' UNION ALL 
 Select 'Chhattisgarh' , N'Surajpur' , N'Pratappur' UNION ALL 
 Select 'Chhattisgarh' , N'Surajpur' , N'Premnagar' UNION ALL 
 Select 'Chhattisgarh' , N'Surajpur' , N'Ramanujnagar' UNION ALL 
 Select 'Chhattisgarh' , N'Surajpur' , N'Surajpur' UNION ALL 
 Select 'Chhattisgarh' , N'Surguja' , N'Ambikapur' UNION ALL 
 Select 'Chhattisgarh' , N'Surguja' , N'Batauli' UNION ALL 
 Select 'Chhattisgarh' , N'Surguja' , N'Lakhanpur' UNION ALL 
 Select 'Chhattisgarh' , N'Surguja' , N'Lundra' UNION ALL 
 Select 'Chhattisgarh' , N'Surguja' , N'Mainpat' UNION ALL 
 Select 'Chhattisgarh' , N'Surguja' , N'Sitapur' UNION ALL 
 Select 'Chhattisgarh' , N'Surguja' , N'Udaipur' UNION ALL 
 Select 'Chhattisgarh' , N'Uttar Bastar Kanker' , N'Antagarh' UNION ALL 
 Select 'Chhattisgarh' , N'Uttar Bastar Kanker' , N'Bhanupratappur' UNION ALL 
 Select 'Chhattisgarh' , N'Uttar Bastar Kanker' , N'Charama' UNION ALL 
 Select 'Chhattisgarh' , N'Uttar Bastar Kanker' , N'Durgukondal' UNION ALL 
 Select 'Chhattisgarh' , N'Uttar Bastar Kanker' , N'Kanker' UNION ALL 
 Select 'Chhattisgarh' , N'Uttar Bastar Kanker' , N'Koilebeda' UNION ALL 
 Select 'Chhattisgarh' , N'Uttar Bastar Kanker' , N'Narharpur'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
Select 'Delhi' , N'Delhi' , 'Delhi'
)
INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Goa' , N'North Goa' , N'Bardez' UNION ALL 
 Select 'Goa' , N'North Goa' , N'Bicholim' UNION ALL 
 Select 'Goa' , N'North Goa' , N'Pernem' UNION ALL 
 Select 'Goa' , N'North Goa' , N'Satari' UNION ALL 
 Select 'Goa' , N'North Goa' , N'Tiswadi' UNION ALL 
 Select 'Goa' , N'South Goa' , N'Canacona' UNION ALL 
 Select 'Goa' , N'South Goa' , N'Dharbandora' UNION ALL 
 Select 'Goa' , N'South Goa' , N'Mormugao' UNION ALL 
 Select 'Goa' , N'South Goa' , N'Ponda' UNION ALL 
 Select 'Goa' , N'South Goa' , N'Quepem' UNION ALL 
 Select 'Goa' , N'South Goa' , N'Salcete' UNION ALL 
 Select 'Goa' , N'South Goa' , N'Sanguem'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Gujarat' , N'Ahmedabad' , N'Ahmadabad City' UNION ALL 
 Select 'Gujarat' , N'Ahmedabad' , N'Bavla' UNION ALL 
 Select 'Gujarat' , N'Ahmedabad' , N'Daskroi' UNION ALL 
 Select 'Gujarat' , N'Ahmedabad' , N'Detroj Rampura' UNION ALL 
 Select 'Gujarat' , N'Ahmedabad' , N'Dhandhuka' UNION ALL 
 Select 'Gujarat' , N'Ahmedabad' , N'Dholera' UNION ALL 
 Select 'Gujarat' , N'Ahmedabad' , N'Dholka' UNION ALL 
 Select 'Gujarat' , N'Ahmedabad' , N'Mandal' UNION ALL 
 Select 'Gujarat' , N'Ahmedabad' , N'Sanand' UNION ALL 
 Select 'Gujarat' , N'Ahmedabad' , N'Viramgam' UNION ALL 
 Select 'Gujarat' , N'Amreli' , N'Amreli' UNION ALL 
 Select 'Gujarat' , N'Amreli' , N'Babra' UNION ALL 
 Select 'Gujarat' , N'Amreli' , N'Bagasara' UNION ALL 
 Select 'Gujarat' , N'Amreli' , N'Dhari' UNION ALL 
 Select 'Gujarat' , N'Amreli' , N'Jafrabad' UNION ALL 
 Select 'Gujarat' , N'Amreli' , N'Khambha' UNION ALL 
 Select 'Gujarat' , N'Amreli' , N'Kunkavav -Vadia' UNION ALL 
 Select 'Gujarat' , N'Amreli' , N'Lathi' UNION ALL 
 Select 'Gujarat' , N'Amreli' , N'Lilia' UNION ALL 
 Select 'Gujarat' , N'Amreli' , N'Rajula' UNION ALL 
 Select 'Gujarat' , N'Amreli' , N'Saverkundla' UNION ALL 
 Select 'Gujarat' , N'Anand' , N'Anand' UNION ALL 
 Select 'Gujarat' , N'Anand' , N'Anklav' UNION ALL 
 Select 'Gujarat' , N'Anand' , N'Borsad' UNION ALL 
 Select 'Gujarat' , N'Anand' , N'Khambhat' UNION ALL 
 Select 'Gujarat' , N'Anand' , N'Petlad' UNION ALL 
 Select 'Gujarat' , N'Anand' , N'Sojitra' UNION ALL 
 Select 'Gujarat' , N'Anand' , N'Tarapur' UNION ALL 
 Select 'Gujarat' , N'Anand' , N'Umreth' UNION ALL 
 Select 'Gujarat' , N'Arvalli' , N'Bayad' UNION ALL 
 Select 'Gujarat' , N'Arvalli' , N'Bhiloda' UNION ALL 
 Select 'Gujarat' , N'Arvalli' , N'Dhansura' UNION ALL 
 Select 'Gujarat' , N'Arvalli' , N'Malpur' UNION ALL 
 Select 'Gujarat' , N'Arvalli' , N'Meghraj' UNION ALL 
 Select 'Gujarat' , N'Arvalli' , N'Modasa' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Amirgadh' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Bhabhar' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Danta' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Dantivada' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Deesa' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Deodar' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Dhanera' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Kankrej' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Lakhani' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Palanpur' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Suigam' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Tharad' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Vadgam' UNION ALL 
 Select 'Gujarat' , N'Banas Kantha' , N'Vav' UNION ALL 
 Select 'Gujarat' , N'Bharuch' , N'Amod' UNION ALL 
 Select 'Gujarat' , N'Bharuch' , N'Anklesvar' UNION ALL 
 Select 'Gujarat' , N'Bharuch' , N'Bharuch' UNION ALL 
 Select 'Gujarat' , N'Bharuch' , N'Hansot' UNION ALL 
 Select 'Gujarat' , N'Bharuch' , N'Jambusar' UNION ALL 
 Select 'Gujarat' , N'Bharuch' , N'Jhagadia' UNION ALL 
 Select 'Gujarat' , N'Bharuch' , N'Netrang' UNION ALL 
 Select 'Gujarat' , N'Bharuch' , N'Vagra' UNION ALL 
 Select 'Gujarat' , N'Bharuch' , N'Valia' UNION ALL 
 Select 'Gujarat' , N'Bhavnagar' , N'Bhavnagar' UNION ALL 
 Select 'Gujarat' , N'Bhavnagar' , N'Gariadhar' UNION ALL 
 Select 'Gujarat' , N'Bhavnagar' , N'Ghogha' UNION ALL 
 Select 'Gujarat' , N'Bhavnagar' , N'Jesar' UNION ALL 
 Select 'Gujarat' , N'Bhavnagar' , N'Mahuva' UNION ALL 
 Select 'Gujarat' , N'Bhavnagar' , N'Palitana' UNION ALL 
 Select 'Gujarat' , N'Bhavnagar' , N'Sihor' UNION ALL 
 Select 'Gujarat' , N'Bhavnagar' , N'Talaja' UNION ALL 
 Select 'Gujarat' , N'Bhavnagar' , N'Umrala' UNION ALL 
 Select 'Gujarat' , N'Bhavnagar' , N'Vallabhipur' UNION ALL 
 Select 'Gujarat' , N'Botad' , N'Barvala' UNION ALL 
 Select 'Gujarat' , N'Botad' , N'Botad' UNION ALL 
 Select 'Gujarat' , N'Botad' , N'Gadhada' UNION ALL 
 Select 'Gujarat' , N'Botad' , N'Ranpur' UNION ALL 
 Select 'Gujarat' , N'Chhotaudepur' , N'Bodeli' UNION ALL 
 Select 'Gujarat' , N'Chhotaudepur' , N'Chhota Udepur' UNION ALL 
 Select 'Gujarat' , N'Chhotaudepur' , N'Jetpur Pavi' UNION ALL 
 Select 'Gujarat' , N'Chhotaudepur' , N'Kawant' UNION ALL 
 Select 'Gujarat' , N'Chhotaudepur' , N'Naswadi' UNION ALL 
 Select 'Gujarat' , N'Chhotaudepur' , N'Sankheda' UNION ALL 
 Select 'Gujarat' , N'Dahod' , N'Dahod' UNION ALL 
 Select 'Gujarat' , N'Dahod' , N'Devgad Bariya' UNION ALL 
 Select 'Gujarat' , N'Dahod' , N'Dhanpur' UNION ALL 
 Select 'Gujarat' , N'Dahod' , N'Fatepura' UNION ALL 
 Select 'Gujarat' , N'Dahod' , N'Garbada' UNION ALL 
 Select 'Gujarat' , N'Dahod' , N'Jhalod' UNION ALL 
 Select 'Gujarat' , N'Dahod' , N'Limkheda' UNION ALL 
 Select 'Gujarat' , N'Dahod' , N'Sanjeli' UNION ALL 
 Select 'Gujarat' , N'Dahod' , N'Singvad' UNION ALL 
 Select 'Gujarat' , N'Dangs' , N'Ahwa' UNION ALL 
 Select 'Gujarat' , N'Dangs' , N'Subir' UNION ALL 
 Select 'Gujarat' , N'Dangs' , N'Waghai' UNION ALL 
 Select 'Gujarat' , N'Devbhumi Dwarka' , N'Bhanvad' UNION ALL 
 Select 'Gujarat' , N'Devbhumi Dwarka' , N'Kalyanpur' UNION ALL 
 Select 'Gujarat' , N'Devbhumi Dwarka' , N'Khambhalia' UNION ALL 
 Select 'Gujarat' , N'Devbhumi Dwarka' , N'Okhamandal' UNION ALL 
 Select 'Gujarat' , N'Gandhinagar' , N'Dehgam' UNION ALL 
 Select 'Gujarat' , N'Gandhinagar' , N'Gandhinagar' UNION ALL 
 Select 'Gujarat' , N'Gandhinagar' , N'Kalol' UNION ALL 
 Select 'Gujarat' , N'Gandhinagar' , N'Mansa' UNION ALL 
 Select 'Gujarat' , N'Gir Somnath' , N'Girgadhda' UNION ALL 
 Select 'Gujarat' , N'Gir Somnath' , N'Kodinar' UNION ALL 
 Select 'Gujarat' , N'Gir Somnath' , N'Patan Veraval' UNION ALL 
 Select 'Gujarat' , N'Gir Somnath' , N'Sutrapada' UNION ALL 
 Select 'Gujarat' , N'Gir Somnath' , N'Talala' UNION ALL 
 Select 'Gujarat' , N'Gir Somnath' , N'Una' UNION ALL 
 Select 'Gujarat' , N'Jamnagar' , N'Dhrol' UNION ALL 
 Select 'Gujarat' , N'Jamnagar' , N'Jamjodhpur' UNION ALL 
 Select 'Gujarat' , N'Jamnagar' , N'Jamnagar' UNION ALL 
 Select 'Gujarat' , N'Jamnagar' , N'Jodiya' UNION ALL 
 Select 'Gujarat' , N'Jamnagar' , N'Kalavad' UNION ALL 
 Select 'Gujarat' , N'Jamnagar' , N'Lalpur' UNION ALL 
 Select 'Gujarat' , N'Junagadh' , N'Bhesan' UNION ALL 
 Select 'Gujarat' , N'Junagadh' , N'Junagadh' UNION ALL 
 Select 'Gujarat' , N'Junagadh' , N'Keshod' UNION ALL 
 Select 'Gujarat' , N'Junagadh' , N'Malia' UNION ALL 
 Select 'Gujarat' , N'Junagadh' , N'Manavadar' UNION ALL 
 Select 'Gujarat' , N'Junagadh' , N'Mangrol' UNION ALL 
 Select 'Gujarat' , N'Junagadh' , N'Mendarda' UNION ALL 
 Select 'Gujarat' , N'Junagadh' , N'Vanthali' UNION ALL 
 Select 'Gujarat' , N'Junagadh' , N'Visavadar' UNION ALL 
 Select 'Gujarat' , N'Kachchh' , N'Abdasa' UNION ALL 
 Select 'Gujarat' , N'Kachchh' , N'Anjar' UNION ALL 
 Select 'Gujarat' , N'Kachchh' , N'Bhachau' UNION ALL 
 Select 'Gujarat' , N'Kachchh' , N'Bhuj' UNION ALL 
 Select 'Gujarat' , N'Kachchh' , N'Gandhidham' UNION ALL 
 Select 'Gujarat' , N'Kachchh' , N'Lakhpat' UNION ALL 
 Select 'Gujarat' , N'Kachchh' , N'Mandvi' UNION ALL 
 Select 'Gujarat' , N'Kachchh' , N'Mundra' UNION ALL 
 Select 'Gujarat' , N'Kachchh' , N'Nakhatrana' UNION ALL 
 Select 'Gujarat' , N'Kachchh' , N'Rapar' UNION ALL 
 Select 'Gujarat' , N'Kheda' , N'Galteshwar' UNION ALL 
 Select 'Gujarat' , N'Kheda' , N'Kapadvanj' UNION ALL 
 Select 'Gujarat' , N'Kheda' , N'Kathlal' UNION ALL 
 Select 'Gujarat' , N'Kheda' , N'Kheda' UNION ALL 
 Select 'Gujarat' , N'Kheda' , N'Mahudha' UNION ALL 
 Select 'Gujarat' , N'Kheda' , N'Matar' UNION ALL 
 Select 'Gujarat' , N'Kheda' , N'Mehmedabad' UNION ALL 
 Select 'Gujarat' , N'Kheda' , N'Nadiad' UNION ALL 
 Select 'Gujarat' , N'Kheda' , N'Thasra' UNION ALL 
 Select 'Gujarat' , N'Kheda' , N'Vaso' UNION ALL 
 Select 'Gujarat' , N'Mahesana' , N'Bechraji' UNION ALL 
 Select 'Gujarat' , N'Mahesana' , N'Jotana' UNION ALL 
 Select 'Gujarat' , N'Mahesana' , N'Kadi' UNION ALL 
 Select 'Gujarat' , N'Mahesana' , N'Kheralu' UNION ALL 
 Select 'Gujarat' , N'Mahesana' , N'Mahesana' UNION ALL 
 Select 'Gujarat' , N'Mahesana' , N'Satlasna' UNION ALL 
 Select 'Gujarat' , N'Mahesana' , N'Unjha' UNION ALL 
 Select 'Gujarat' , N'Mahesana' , N'Vadnagar' UNION ALL 
 Select 'Gujarat' , N'Mahesana' , N'Vijapur' UNION ALL 
 Select 'Gujarat' , N'Mahesana' , N'Visnagar' UNION ALL 
 Select 'Gujarat' , N'Mahisagar' , N'Balasinor' UNION ALL 
 Select 'Gujarat' , N'Mahisagar' , N'Kadana' UNION ALL 
 Select 'Gujarat' , N'Mahisagar' , N'Khanpur' UNION ALL 
 Select 'Gujarat' , N'Mahisagar' , N'Lunawada' UNION ALL 
 Select 'Gujarat' , N'Mahisagar' , N'Santrampur' UNION ALL 
 Select 'Gujarat' , N'Mahisagar' , N'Virpur' UNION ALL 
 Select 'Gujarat' , N'Morbi' , N'Halvad' UNION ALL 
 Select 'Gujarat' , N'Morbi' , N'Maliya' UNION ALL 
 Select 'Gujarat' , N'Morbi' , N'Morvi' UNION ALL 
 Select 'Gujarat' , N'Morbi' , N'Tankara' UNION ALL 
 Select 'Gujarat' , N'Morbi' , N'Wankaner' UNION ALL 
 Select 'Gujarat' , N'Narmada' , N'Dediyapada' UNION ALL 
 Select 'Gujarat' , N'Narmada' , N'Garudeshwar' UNION ALL 
 Select 'Gujarat' , N'Narmada' , N'Nandod' UNION ALL 
 Select 'Gujarat' , N'Narmada' , N'Sagbara' UNION ALL 
 Select 'Gujarat' , N'Narmada' , N'Tilakwada' UNION ALL 
 Select 'Gujarat' , N'Navsari' , N'Chikhali' UNION ALL 
 Select 'Gujarat' , N'Navsari' , N'Gandevi' UNION ALL 
 Select 'Gujarat' , N'Navsari' , N'Jalalpore' UNION ALL 
 Select 'Gujarat' , N'Navsari' , N'Khergam' UNION ALL 
 Select 'Gujarat' , N'Navsari' , N'Navsari' UNION ALL 
 Select 'Gujarat' , N'Navsari' , N'Vansda' UNION ALL 
 Select 'Gujarat' , N'Panch Mahals' , N'Ghoghamba' UNION ALL 
 Select 'Gujarat' , N'Panch Mahals' , N'Godhra' UNION ALL 
 Select 'Gujarat' , N'Panch Mahals' , N'Halol' UNION ALL 
 Select 'Gujarat' , N'Panch Mahals' , N'Jambughoda' UNION ALL 
 Select 'Gujarat' , N'Panch Mahals' , N'Kalol' UNION ALL 
 Select 'Gujarat' , N'Panch Mahals' , N'Morvahadaf' UNION ALL 
 Select 'Gujarat' , N'Panch Mahals' , N'Shehera' UNION ALL 
 Select 'Gujarat' , N'Patan' , N'Chanasma' UNION ALL 
 Select 'Gujarat' , N'Patan' , N'Harij' UNION ALL 
 Select 'Gujarat' , N'Patan' , N'Patan' UNION ALL 
 Select 'Gujarat' , N'Patan' , N'Radhanpur' UNION ALL 
 Select 'Gujarat' , N'Patan' , N'Sami' UNION ALL 
 Select 'Gujarat' , N'Patan' , N'Sankheshwar' UNION ALL 
 Select 'Gujarat' , N'Patan' , N'Santalpur' UNION ALL 
 Select 'Gujarat' , N'Patan' , N'Saraswati' UNION ALL 
 Select 'Gujarat' , N'Patan' , N'Sidhpur' UNION ALL 
 Select 'Gujarat' , N'Porbandar' , N'Kutiyana' UNION ALL 
 Select 'Gujarat' , N'Porbandar' , N'Porbandar' UNION ALL 
 Select 'Gujarat' , N'Porbandar' , N'Ranavav' UNION ALL 
 Select 'Gujarat' , N'Rajkot' , N'Dhoraji' UNION ALL 
 Select 'Gujarat' , N'Rajkot' , N'Gondal' UNION ALL 
 Select 'Gujarat' , N'Rajkot' , N'Jamkandorna' UNION ALL 
 Select 'Gujarat' , N'Rajkot' , N'Jasdan' UNION ALL 
 Select 'Gujarat' , N'Rajkot' , N'Jetpur' UNION ALL 
 Select 'Gujarat' , N'Rajkot' , N'Kotda Sangani' UNION ALL 
 Select 'Gujarat' , N'Rajkot' , N'Lodhika' UNION ALL 
 Select 'Gujarat' , N'Rajkot' , N'Paddhari' UNION ALL 
 Select 'Gujarat' , N'Rajkot' , N'Rajkot' UNION ALL 
 Select 'Gujarat' , N'Rajkot' , N'Upleta' UNION ALL 
 Select 'Gujarat' , N'Rajkot' , N'Vinchhiya' UNION ALL 
 Select 'Gujarat' , N'Sabar Kantha' , N'Himatnagar' UNION ALL 
 Select 'Gujarat' , N'Sabar Kantha' , N'Idar' UNION ALL 
 Select 'Gujarat' , N'Sabar Kantha' , N'Khedbrahma' UNION ALL 
 Select 'Gujarat' , N'Sabar Kantha' , N'Poshina' UNION ALL 
 Select 'Gujarat' , N'Sabar Kantha' , N'Prantij' UNION ALL 
 Select 'Gujarat' , N'Sabar Kantha' , N'Talod' UNION ALL 
 Select 'Gujarat' , N'Sabar Kantha' , N'Vadali' UNION ALL 
 Select 'Gujarat' , N'Sabar Kantha' , N'Vijaynagar' UNION ALL 
 Select 'Gujarat' , N'Surat' , N'Bardoli' UNION ALL 
 Select 'Gujarat' , N'Surat' , N'Chorasi' UNION ALL 
 Select 'Gujarat' , N'Surat' , N'Kamrej' UNION ALL 
 Select 'Gujarat' , N'Surat' , N'Mahuva' UNION ALL 
 Select 'Gujarat' , N'Surat' , N'Mandvi' UNION ALL 
 Select 'Gujarat' , N'Surat' , N'Mangrol' UNION ALL 
 Select 'Gujarat' , N'Surat' , N'Olpad' UNION ALL 
 Select 'Gujarat' , N'Surat' , N'Palsana' UNION ALL 
 Select 'Gujarat' , N'Surat' , N'Suratcity' UNION ALL 
 Select 'Gujarat' , N'Surat' , N'Umarpada' UNION ALL 
 Select 'Gujarat' , N'Surendranagar' , N'Chotila' UNION ALL 
 Select 'Gujarat' , N'Surendranagar' , N'Chuda' UNION ALL 
 Select 'Gujarat' , N'Surendranagar' , N'Dasada' UNION ALL 
 Select 'Gujarat' , N'Surendranagar' , N'Dhrangadhra' UNION ALL 
 Select 'Gujarat' , N'Surendranagar' , N'Lakhtar' UNION ALL 
 Select 'Gujarat' , N'Surendranagar' , N'Limbdi' UNION ALL 
 Select 'Gujarat' , N'Surendranagar' , N'Muli' UNION ALL 
 Select 'Gujarat' , N'Surendranagar' , N'Sayla' UNION ALL 
 Select 'Gujarat' , N'Surendranagar' , N'Thangadh' UNION ALL 
 Select 'Gujarat' , N'Surendranagar' , N'Wadhwan' UNION ALL 
 Select 'Gujarat' , N'Tapi' , N'Dolvan' UNION ALL 
 Select 'Gujarat' , N'Tapi' , N'Kukarmunda' UNION ALL 
 Select 'Gujarat' , N'Tapi' , N'Nizar' UNION ALL 
 Select 'Gujarat' , N'Tapi' , N'Songadh' UNION ALL 
 Select 'Gujarat' , N'Tapi' , N'Uchchhal' UNION ALL 
 Select 'Gujarat' , N'Tapi' , N'Valod' UNION ALL 
 Select 'Gujarat' , N'Tapi' , N'Vyara' UNION ALL 
 Select 'Gujarat' , N'Vadodara' , N'Dabhoi' UNION ALL 
 Select 'Gujarat' , N'Vadodara' , N'Desar' UNION ALL 
 Select 'Gujarat' , N'Vadodara' , N'Karjan' UNION ALL 
 Select 'Gujarat' , N'Vadodara' , N'Padra' UNION ALL 
 Select 'Gujarat' , N'Vadodara' , N'Savli' UNION ALL 
 Select 'Gujarat' , N'Vadodara' , N'Shinor' UNION ALL 
 Select 'Gujarat' , N'Vadodara' , N'Vadodara(City And Rural)' UNION ALL 
 Select 'Gujarat' , N'Vadodara' , N'Waghodia' UNION ALL 
 Select 'Gujarat' , N'Valsad' , N'Dharampur' UNION ALL 
 Select 'Gujarat' , N'Valsad' , N'Kaprada' UNION ALL 
 Select 'Gujarat' , N'Valsad' , N'Pardi' UNION ALL 
 Select 'Gujarat' , N'Valsad' , N'Umbergaon' UNION ALL 
 Select 'Gujarat' , N'Valsad' , N'Valsad' UNION ALL 
 Select 'Gujarat' , N'Valsad' , N'Vapi'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Haryana' , N'Ambala' , N'Ambala-I' UNION ALL 
 Select 'Haryana' , N'Ambala' , N'Ambala-Ii' UNION ALL 
 Select 'Haryana' , N'Ambala' , N'Barara' UNION ALL 
 Select 'Haryana' , N'Ambala' , N'Naraingarh' UNION ALL 
 Select 'Haryana' , N'Ambala' , N'Saha' UNION ALL 
 Select 'Haryana' , N'Ambala' , N'Shahzadpur' UNION ALL 
 Select 'Haryana' , N'Bhiwani' , N'Bawani Khera' UNION ALL 
 Select 'Haryana' , N'Bhiwani' , N'Behal' UNION ALL 
 Select 'Haryana' , N'Bhiwani' , N'Bhiwani' UNION ALL 
 Select 'Haryana' , N'Bhiwani' , N'Kairu' UNION ALL 
 Select 'Haryana' , N'Bhiwani' , N'Loharu' UNION ALL 
 Select 'Haryana' , N'Bhiwani' , N'Siwani' UNION ALL 
 Select 'Haryana' , N'Bhiwani' , N'Tosham' UNION ALL 
 Select 'Haryana' , N'Charki Dadri' , N'Badhra' UNION ALL 
 Select 'Haryana' , N'Charki Dadri' , N'Baund' UNION ALL 
 Select 'Haryana' , N'Charki Dadri' , N'Charkhi Dadri' UNION ALL 
 Select 'Haryana' , N'Charki Dadri' , N'Jhojhu' UNION ALL 
 Select 'Haryana' , N'Faridabad' , N'Ballabgarh' UNION ALL 
 Select 'Haryana' , N'Faridabad' , N'Faridabad' UNION ALL 
 Select 'Haryana' , N'Faridabad' , N'Tigaon' UNION ALL 
 Select 'Haryana' , N'Fatehabad' , N'Bhattu Kalan' UNION ALL 
 Select 'Haryana' , N'Fatehabad' , N'Bhuna' UNION ALL 
 Select 'Haryana' , N'Fatehabad' , N'Fatehabad' UNION ALL 
 Select 'Haryana' , N'Fatehabad' , N'Jakhal' UNION ALL 
 Select 'Haryana' , N'Fatehabad' , N'Nagpur' UNION ALL 
 Select 'Haryana' , N'Fatehabad' , N'Ratia' UNION ALL 
 Select 'Haryana' , N'Fatehabad' , N'Tohana' UNION ALL 
 Select 'Haryana' , N'Gurugram' , N'Farrukh Nagar' UNION ALL 
 Select 'Haryana' , N'Gurugram' , N'Gurgaon' UNION ALL 
 Select 'Haryana' , N'Gurugram' , N'Pataudi' UNION ALL 
 Select 'Haryana' , N'Gurugram' , N'Sohna' UNION ALL 
 Select 'Haryana' , N'Hisar' , N'Adampur' UNION ALL 
 Select 'Haryana' , N'Hisar' , N'Agroha' UNION ALL 
 Select 'Haryana' , N'Hisar' , N'Barwala' UNION ALL 
 Select 'Haryana' , N'Hisar' , N'Hansi-I' UNION ALL 
 Select 'Haryana' , N'Hisar' , N'Hansi-Ii' UNION ALL 
 Select 'Haryana' , N'Hisar' , N'Hisar-I' UNION ALL 
 Select 'Haryana' , N'Hisar' , N'Hisar-Ii' UNION ALL 
 Select 'Haryana' , N'Hisar' , N'Narnaund' UNION ALL 
 Select 'Haryana' , N'Hisar' , N'Uklana' UNION ALL 
 Select 'Haryana' , N'Jhajjar' , N'Badli' UNION ALL 
 Select 'Haryana' , N'Jhajjar' , N'Bahadurgarh' UNION ALL 
 Select 'Haryana' , N'Jhajjar' , N'Beri' UNION ALL 
 Select 'Haryana' , N'Jhajjar' , N'Jhajjar' UNION ALL 
 Select 'Haryana' , N'Jhajjar' , N'Machhrauli' UNION ALL 
 Select 'Haryana' , N'Jhajjar' , N'Matannail' UNION ALL 
 Select 'Haryana' , N'Jhajjar' , N'Salhawas' UNION ALL 
 Select 'Haryana' , N'Jind' , N'Alewa' UNION ALL 
 Select 'Haryana' , N'Jind' , N'Jind' UNION ALL 
 Select 'Haryana' , N'Jind' , N'Julana' UNION ALL 
 Select 'Haryana' , N'Jind' , N'Narwana' UNION ALL 
 Select 'Haryana' , N'Jind' , N'Pillukhera' UNION ALL 
 Select 'Haryana' , N'Jind' , N'Safidon' UNION ALL 
 Select 'Haryana' , N'Jind' , N'Uchana' UNION ALL 
 Select 'Haryana' , N'Jind' , N'Ujhana' UNION ALL 
 Select 'Haryana' , N'Kaithal' , N'Dhand' UNION ALL 
 Select 'Haryana' , N'Kaithal' , N'Guhla' UNION ALL 
 Select 'Haryana' , N'Kaithal' , N'Kaithal' UNION ALL 
 Select 'Haryana' , N'Kaithal' , N'Kalayat' UNION ALL 
 Select 'Haryana' , N'Kaithal' , N'Pundri' UNION ALL 
 Select 'Haryana' , N'Kaithal' , N'Rajound' UNION ALL 
 Select 'Haryana' , N'Kaithal' , N'Siwan' UNION ALL 
 Select 'Haryana' , N'Karnal' , N'Assandh' UNION ALL 
 Select 'Haryana' , N'Karnal' , N'Chirao' UNION ALL 
 Select 'Haryana' , N'Karnal' , N'Gharaunda (Part)' UNION ALL 
 Select 'Haryana' , N'Karnal' , N'Indri' UNION ALL 
 Select 'Haryana' , N'Karnal' , N'Karnal' UNION ALL 
 Select 'Haryana' , N'Karnal' , N'Kunjpura' UNION ALL 
 Select 'Haryana' , N'Karnal' , N'Munak' UNION ALL 
 Select 'Haryana' , N'Karnal' , N'Nilokheri' UNION ALL 
 Select 'Haryana' , N'Karnal' , N'Nissing' UNION ALL 
 Select 'Haryana' , N'Kurukshetra' , N'Babain' UNION ALL 
 Select 'Haryana' , N'Kurukshetra' , N'Ismailabad' UNION ALL 
 Select 'Haryana' , N'Kurukshetra' , N'Ladwa' UNION ALL 
 Select 'Haryana' , N'Kurukshetra' , N'Pehowa' UNION ALL 
 Select 'Haryana' , N'Kurukshetra' , N'Pipli' UNION ALL 
 Select 'Haryana' , N'Kurukshetra' , N'Shahbad' UNION ALL 
 Select 'Haryana' , N'Kurukshetra' , N'Thanesar' UNION ALL 
 Select 'Haryana' , N'Mahendragarh' , N'Ateli Nangal' UNION ALL 
 Select 'Haryana' , N'Mahendragarh' , N'Kanina' UNION ALL 
 Select 'Haryana' , N'Mahendragarh' , N'Mahendragarh' UNION ALL 
 Select 'Haryana' , N'Mahendragarh' , N'Nangal Chaudhry' UNION ALL 
 Select 'Haryana' , N'Mahendragarh' , N'Narnaul' UNION ALL 
 Select 'Haryana' , N'Mahendragarh' , N'Nizampur' UNION ALL 
 Select 'Haryana' , N'Mahendragarh' , N'Satnali' UNION ALL 
 Select 'Haryana' , N'Mahendragarh' , N'Sihma' UNION ALL 
 Select 'Haryana' , N'Nuh' , N'Ferozepur Jhirka' UNION ALL 
 Select 'Haryana' , N'Nuh' , N'Indri' UNION ALL 
 Select 'Haryana' , N'Nuh' , N'Nagina' UNION ALL 
 Select 'Haryana' , N'Nuh' , N'Nuh' UNION ALL 
 Select 'Haryana' , N'Nuh' , N'Pingwan' UNION ALL 
 Select 'Haryana' , N'Nuh' , N'Punahana' UNION ALL 
 Select 'Haryana' , N'Nuh' , N'Taoru' UNION ALL 
 Select 'Haryana' , N'Palwal' , N'Badoli' UNION ALL 
 Select 'Haryana' , N'Palwal' , N'Hassanpur' UNION ALL 
 Select 'Haryana' , N'Palwal' , N'Hathin' UNION ALL 
 Select 'Haryana' , N'Palwal' , N'Hodal' UNION ALL 
 Select 'Haryana' , N'Palwal' , N'Palwal' UNION ALL 
 Select 'Haryana' , N'Palwal' , N'Prithla' UNION ALL 
 Select 'Haryana' , N'Panchkula' , N'Barwala' UNION ALL 
 Select 'Haryana' , N'Panchkula' , N'Morni' UNION ALL 
 Select 'Haryana' , N'Panchkula' , N'Pinjore' UNION ALL 
 Select 'Haryana' , N'Panchkula' , N'Raipur Rani' UNION ALL 
 Select 'Haryana' , N'Panipat' , N'Bapoli' UNION ALL 
 Select 'Haryana' , N'Panipat' , N'Israna' UNION ALL 
 Select 'Haryana' , N'Panipat' , N'Madlauda' UNION ALL 
 Select 'Haryana' , N'Panipat' , N'Panipat' UNION ALL 
 Select 'Haryana' , N'Panipat' , N'Samalkha' UNION ALL 
 Select 'Haryana' , N'Panipat' , N'Sanauli Khurd' UNION ALL 
 Select 'Haryana' , N'Rewari' , N'Bawal' UNION ALL 
 Select 'Haryana' , N'Rewari' , N'Dahina' UNION ALL 
 Select 'Haryana' , N'Rewari' , N'Dharuhera' UNION ALL 
 Select 'Haryana' , N'Rewari' , N'Jatusana' UNION ALL 
 Select 'Haryana' , N'Rewari' , N'Khol At Rewari' UNION ALL 
 Select 'Haryana' , N'Rewari' , N'Nahar' UNION ALL 
 Select 'Haryana' , N'Rewari' , N'Rewari' UNION ALL 
 Select 'Haryana' , N'Rohtak' , N'Kalanaur' UNION ALL 
 Select 'Haryana' , N'Rohtak' , N'Lakhan Majra' UNION ALL 
 Select 'Haryana' , N'Rohtak' , N'Maham' UNION ALL 
 Select 'Haryana' , N'Rohtak' , N'Rohtak' UNION ALL 
 Select 'Haryana' , N'Rohtak' , N'Sampla' UNION ALL 
 Select 'Haryana' , N'Sirsa' , N'Baragudha' UNION ALL 
 Select 'Haryana' , N'Sirsa' , N'Dabwali' UNION ALL 
 Select 'Haryana' , N'Sirsa' , N'Ellenabad' UNION ALL 
 Select 'Haryana' , N'Sirsa' , N'Nathusari Chopta' UNION ALL 
 Select 'Haryana' , N'Sirsa' , N'Odhan' UNION ALL 
 Select 'Haryana' , N'Sirsa' , N'Rania' UNION ALL 
 Select 'Haryana' , N'Sirsa' , N'Sirsa' UNION ALL 
 Select 'Haryana' , N'Sonipat' , N'Ganaur' UNION ALL 
 Select 'Haryana' , N'Sonipat' , N'Gohana' UNION ALL 
 Select 'Haryana' , N'Sonipat' , N'Kathura' UNION ALL 
 Select 'Haryana' , N'Sonipat' , N'Kharkhoda' UNION ALL 
 Select 'Haryana' , N'Sonipat' , N'Mundlana' UNION ALL 
 Select 'Haryana' , N'Sonipat' , N'Murthal' UNION ALL 
 Select 'Haryana' , N'Sonipat' , N'Rai' UNION ALL 
 Select 'Haryana' , N'Sonipat' , N'Sonipat' UNION ALL 
 Select 'Haryana' , N'Yamunanagar' , N'Bilaspur' UNION ALL 
 Select 'Haryana' , N'Yamunanagar' , N'Chhachhrauli' UNION ALL 
 Select 'Haryana' , N'Yamunanagar' , N'Jagadhri' UNION ALL 
 Select 'Haryana' , N'Yamunanagar' , N'Partap Nagar' UNION ALL 
 Select 'Haryana' , N'Yamunanagar' , N'Radaur' UNION ALL 
 Select 'Haryana' , N'Yamunanagar' , N'Sadaura (Part)' UNION ALL 
 Select 'Haryana' , N'Yamunanagar' , N'Saraswati Nagar'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Himachal Pradesh' , N'Bilaspur' , N'Bilaspur Sadar' UNION ALL 
 Select 'Himachal Pradesh' , N'Bilaspur' , N'Ghumarwin' UNION ALL 
 Select 'Himachal Pradesh' , N'Bilaspur' , N'Jhandutta' UNION ALL 
 Select 'Himachal Pradesh' , N'Bilaspur' , N'Shree Naina Devi' UNION ALL 
 Select 'Himachal Pradesh' , N'Chamba' , N'Bharmour' UNION ALL 
 Select 'Himachal Pradesh' , N'Chamba' , N'Bhatiyat' UNION ALL 
 Select 'Himachal Pradesh' , N'Chamba' , N'Chamba' UNION ALL 
 Select 'Himachal Pradesh' , N'Chamba' , N'Mehla' UNION ALL 
 Select 'Himachal Pradesh' , N'Chamba' , N'Pangi' UNION ALL 
 Select 'Himachal Pradesh' , N'Chamba' , N'Salooni' UNION ALL 
 Select 'Himachal Pradesh' , N'Chamba' , N'Tissa' UNION ALL 
 Select 'Himachal Pradesh' , N'Hamirpur' , N'Bamsan' UNION ALL 
 Select 'Himachal Pradesh' , N'Hamirpur' , N'Bhoranj' UNION ALL 
 Select 'Himachal Pradesh' , N'Hamirpur' , N'Bijhri' UNION ALL 
 Select 'Himachal Pradesh' , N'Hamirpur' , N'Hamirpur' UNION ALL 
 Select 'Himachal Pradesh' , N'Hamirpur' , N'Nadaun' UNION ALL 
 Select 'Himachal Pradesh' , N'Hamirpur' , N'Sujanpur Tira' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Badoh' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Baijnath' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Bhawarna' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Dehra' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Dharamshala' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Fatehpur' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Indora' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Kangra' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Lambagaon' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Nagrota Bagwan' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Nagrota Surian' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Nurpur' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Palampur' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Panchrukhi' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Pragpur' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Rait' UNION ALL 
 Select 'Himachal Pradesh' , N'Kangra' , N'Sulah' UNION ALL 
 Select 'Himachal Pradesh' , N'Kinnaur' , N'Kalpa' UNION ALL 
 Select 'Himachal Pradesh' , N'Kinnaur' , N'Nichar' UNION ALL 
 Select 'Himachal Pradesh' , N'Kinnaur' , N'Pooh' UNION ALL 
 Select 'Himachal Pradesh' , N'Kullu' , N'Anni' UNION ALL 
 Select 'Himachal Pradesh' , N'Kullu' , N'Banjar' UNION ALL 
 Select 'Himachal Pradesh' , N'Kullu' , N'Bhunter' UNION ALL 
 Select 'Himachal Pradesh' , N'Kullu' , N'Kullu' UNION ALL 
 Select 'Himachal Pradesh' , N'Kullu' , N'Naggar' UNION ALL 
 Select 'Himachal Pradesh' , N'Kullu' , N'Nirmand' UNION ALL 
 Select 'Himachal Pradesh' , N'Lahul And Spiti' , N'Lahaul' UNION ALL 
 Select 'Himachal Pradesh' , N'Lahul And Spiti' , N'Spiti' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Balh' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Balichowki' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Chauntra' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Churag' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Dhanotu' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Dharmpur' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Drang' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Gohar' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Gopalpur' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Karsog' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Mandi Sadar' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Nihri' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Seraj' UNION ALL 
 Select 'Himachal Pradesh' , N'Mandi' , N'Sundarnagar' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Basantpur' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Chhohara' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Chopal' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Jubbal Kotkhai' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Kotkhai' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Kupvi' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Mashobra' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Nankhari' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Narkanda' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Rampur' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Rohru' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Theog' UNION ALL 
 Select 'Himachal Pradesh' , N'Shimla' , N'Totu' UNION ALL 
 Select 'Himachal Pradesh' , N'Sirmaur' , N'Nahan' UNION ALL 
 Select 'Himachal Pradesh' , N'Sirmaur' , N'Pachhad' UNION ALL 
 Select 'Himachal Pradesh' , N'Sirmaur' , N'Paonta Sahib' UNION ALL 
 Select 'Himachal Pradesh' , N'Sirmaur' , N'Rajgarh' UNION ALL 
 Select 'Himachal Pradesh' , N'Sirmaur' , N'Sangrah' UNION ALL 
 Select 'Himachal Pradesh' , N'Sirmaur' , N'Shillai' UNION ALL 
 Select 'Himachal Pradesh' , N'Sirmaur' , N'Tilordhar' UNION ALL 
 Select 'Himachal Pradesh' , N'Solan' , N'Dharampur' UNION ALL 
 Select 'Himachal Pradesh' , N'Solan' , N'Kandaghat' UNION ALL 
 Select 'Himachal Pradesh' , N'Solan' , N'Kunihar' UNION ALL 
 Select 'Himachal Pradesh' , N'Solan' , N'Nalagarh' UNION ALL 
 Select 'Himachal Pradesh' , N'Solan' , N'Patta' UNION ALL 
 Select 'Himachal Pradesh' , N'Solan' , N'Solan' UNION ALL 
 Select 'Himachal Pradesh' , N'Una' , N'Amb' UNION ALL 
 Select 'Himachal Pradesh' , N'Una' , N'Bangana' UNION ALL 
 Select 'Himachal Pradesh' , N'Una' , N'Gagret' UNION ALL 
 Select 'Himachal Pradesh' , N'Una' , N'Haroli' UNION ALL 
 Select 'Himachal Pradesh' , N'Una' , N'Una'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Achabal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Anantnag' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Bijibehara' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Breng' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Chathergul' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Dachnipora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Hiller Shahabad' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Khoveripora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Larnoo' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Pahalgam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Qazigund (Partly)' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Quimoh Anantnag District Part' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Sagam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Shahabad' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Shangus' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Verinag' UNION ALL 
 Select 'Jammu And Kashmir' , N'Anantnag' , N'Vessu' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Aloosa' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Arin' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Baktoor' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Bandipora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Bonkoot' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Ganstan' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Gurez' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Hajin' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Naidkhay' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Nowgam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Sumbal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Bandipora' , N'Tulail' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Baramulla' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Bijhama' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Boniyar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Chandil Wangam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Hardaboora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Kandi Rafiabad' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Khaipora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Kunzer' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Lalpora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Nadihal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Narwah' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Noorkah' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Paranpeela' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Pattan' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Rafiabad' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Rohama' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Sangrama' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Sherabad Khore' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Singhpora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Sopore' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Tangmarag' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Tujjar Sharief' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Uri' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Wagoora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Wailoo' UNION ALL 
 Select 'Jammu And Kashmir' , N'Baramulla' , N'Zaingeer' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Badgam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Beerwah' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'B.K.Pora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Chadoora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Charisharief' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Khag' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Khan-Sahib' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Nagam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Narbal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Pakherpora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Parnewa' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Rathsun' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'S K Pora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Soibugh' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Sukhnag Hard Panzoo' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Surasyar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Budgam' , N'Waterhail' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Assar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Bhaderwah' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Bhagwah' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Bhalessa(Gandoh)' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Bhalla' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Changa' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Chilli Pingal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Chiralla' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Dali Udhyanpur' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Doda' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Gundana' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Jakyas' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Kahara' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Kastigarh' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Khellani' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Marmat' UNION ALL 
 Select 'Jammu And Kashmir' , N'Doda' , N'Thathri' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ganderbal' , N'Ganderbal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ganderbal' , N'Gund' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ganderbal' , N'Kangan' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ganderbal' , N'Lar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ganderbal' , N'Safapora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ganderbal' , N'Sherpathri' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ganderbal' , N'Wakoora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Akhnoor' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Arnia' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Bhalwal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Bhalwal Brahmana' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Bishnah' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Chowki Choura' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Dansal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Kharah Balli' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Khour' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Maira Mandrian' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Mandal Phallain' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Marh' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Mathwar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Miran Sahib' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Nagrota' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Pragwal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'R.S.Pura' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Samwan' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Satwari' UNION ALL 
 Select 'Jammu And Kashmir' , N'Jammu' , N'Suchetgarh' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Baggan' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Bani' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Barnoti' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Basohli' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Bhoond' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Billawar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Dhar Mahanpur' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Dinga Amb' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Duggain' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Duggan' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Hiranagar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Kathua' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Keerian Gangyal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Lohai-Malhar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Mahanpur' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Mandli' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Marheen' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Nagri' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kathua' , N'Nagrota Gujroo' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Bunjwah' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Dachhan' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Drabshalla' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Inderwal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Kishtwar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Marwah' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Mughalmaidan' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Nagseni' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Padder' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Palmar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Thakraie' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Trigam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kishtwar' , N'Warwan' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kulgam' , N'Behibag' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kulgam' , N'Devsar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kulgam' , N'D.H. Pora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kulgam' , N'D K Marg' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kulgam' , N'Frisal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kulgam' , N'Kulgam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kulgam' , N'Kund' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kulgam' , N'Manzgam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kulgam' , N'Pahloo' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kulgam' , N'Pombay' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kulgam' , N'Qaimoh' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Drugmulla' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Handwara' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Hayhama' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Kalarooch' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Keran' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Kralpora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Kupwara' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Langate' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Machil' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Magam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Mawar Kalamabad' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Meliyal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Nutnoosa' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Qadirabad' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Qaziabad Supernagama' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Rajwar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Ramhal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Reddi Chowkibal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Sogam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Tangdar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Tarathpora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Teetwal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Trehgam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Kupwara' , N'Wavoora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Poonch' , N'Balakote' UNION ALL 
 Select 'Jammu And Kashmir' , N'Poonch' , N'Bufliaz' UNION ALL 
 Select 'Jammu And Kashmir' , N'Poonch' , N'Lassana' UNION ALL 
 Select 'Jammu And Kashmir' , N'Poonch' , N'Loran' UNION ALL 
 Select 'Jammu And Kashmir' , N'Poonch' , N'Mandi' UNION ALL 
 Select 'Jammu And Kashmir' , N'Poonch' , N'Mankote' UNION ALL 
 Select 'Jammu And Kashmir' , N'Poonch' , N'Mendhar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Poonch' , N'Nangali Sahib Sain Baba' UNION ALL 
 Select 'Jammu And Kashmir' , N'Poonch' , N'Poonch' UNION ALL 
 Select 'Jammu And Kashmir' , N'Poonch' , N'Sathra' UNION ALL 
 Select 'Jammu And Kashmir' , N'Poonch' , N'Surankote' UNION ALL 
 Select 'Jammu And Kashmir' , N'Pulwama' , N'Aripal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Pulwama' , N'Awantipora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Pulwama' , N'Dadsara' UNION ALL 
 Select 'Jammu And Kashmir' , N'Pulwama' , N'Ichegoza' UNION ALL 
 Select 'Jammu And Kashmir' , N'Pulwama' , N'Kakapora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Pulwama' , N'Litter' UNION ALL 
 Select 'Jammu And Kashmir' , N'Pulwama' , N'Newa' UNION ALL 
 Select 'Jammu And Kashmir' , N'Pulwama' , N'Pampore' UNION ALL 
 Select 'Jammu And Kashmir' , N'Pulwama' , N'Pulwama' UNION ALL 
 Select 'Jammu And Kashmir' , N'Pulwama' , N'Shadimarg' UNION ALL 
 Select 'Jammu And Kashmir' , N'Pulwama' , N'Tral' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Budhal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Budhal New' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Darhal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Dhangri' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Doongi' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Kalakote' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Khawas' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Lamberi' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Manjakote' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Moughla' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Nowshera' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Panjgrian' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Planger' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Qila Darhal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Rajouri' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Seri' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Siot' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Sunderbani' UNION ALL 
 Select 'Jammu And Kashmir' , N'Rajouri' , N'Thana Mandi' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ramban' , N'Banihal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ramban' , N'Batote' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ramban' , N'Gandhri' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ramban' , N'Gool' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ramban' , N'Gundi Dharam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ramban' , N'Khari' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ramban' , N'Rajgarh' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ramban' , N'Ramban' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ramban' , N'Ramsoo' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ramban' , N'Sangaldan' UNION ALL 
 Select 'Jammu And Kashmir' , N'Ramban' , N'Ukhral' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Arnas' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Bamagh' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Chassana' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Gulab Garh' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Jig Bagli' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Katra' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Mahore' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Panthal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Pouni' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Reasi' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Thakrakote' UNION ALL 
 Select 'Jammu And Kashmir' , N'Reasi' , N'Thuroo' UNION ALL 
 Select 'Jammu And Kashmir' , N'Samba' , N'Bari Brahmana' UNION ALL 
 Select 'Jammu And Kashmir' , N'Samba' , N'Ghagwal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Samba' , N'Nud' UNION ALL 
 Select 'Jammu And Kashmir' , N'Samba' , N'Purmandal' UNION ALL 
 Select 'Jammu And Kashmir' , N'Samba' , N'Rajpura' UNION ALL 
 Select 'Jammu And Kashmir' , N'Samba' , N'Ramgarh' UNION ALL 
 Select 'Jammu And Kashmir' , N'Samba' , N'Samba' UNION ALL 
 Select 'Jammu And Kashmir' , N'Samba' , N'Sumb' UNION ALL 
 Select 'Jammu And Kashmir' , N'Samba' , N'Vijaypur' UNION ALL 
 Select 'Jammu And Kashmir' , N'Shopian' , N'Chitragam' UNION ALL 
 Select 'Jammu And Kashmir' , N'Shopian' , N'Harman' UNION ALL 
 Select 'Jammu And Kashmir' , N'Shopian' , N'Imamsahib' UNION ALL 
 Select 'Jammu And Kashmir' , N'Shopian' , N'Kanji Ullar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Shopian' , N'Kaprin' UNION ALL 
 Select 'Jammu And Kashmir' , N'Shopian' , N'Keller' UNION ALL 
 Select 'Jammu And Kashmir' , N'Shopian' , N'Ramnagri' UNION ALL 
 Select 'Jammu And Kashmir' , N'Shopian' , N'Shopian' UNION ALL 
 Select 'Jammu And Kashmir' , N'Shopian' , N'Zainpora' UNION ALL 
 Select 'Jammu And Kashmir' , N'Srinagar' , N'Eidgah' UNION ALL 
 Select 'Jammu And Kashmir' , N'Srinagar' , N'Harwan Rural Area Dara' UNION ALL 
 Select 'Jammu And Kashmir' , N'Srinagar' , N'Khanmoh' UNION ALL 
 Select 'Jammu And Kashmir' , N'Srinagar' , N'Qamarwari' UNION ALL 
 Select 'Jammu And Kashmir' , N'Srinagar' , N'Srinagar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Chanunta Dalsar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Chenani' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Dudu' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Ghordi' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Jaganoo' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Khoon' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Kulwanta' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Latti' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Majalta' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Moungri' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Narsoo' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Panchari' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Parli Dhar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Ramnagar' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Sewna' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Tikri' UNION ALL 
 Select 'Jammu And Kashmir' , N'Udhampur' , N'Udhampur'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Jharkhand' , N'Bokaro' , N'Bermo' UNION ALL 
 Select 'Jharkhand' , N'Bokaro' , N'Chandankiyari' UNION ALL 
 Select 'Jharkhand' , N'Bokaro' , N'Chandrapura' UNION ALL 
 Select 'Jharkhand' , N'Bokaro' , N'Chas' UNION ALL 
 Select 'Jharkhand' , N'Bokaro' , N'Gomia' UNION ALL 
 Select 'Jharkhand' , N'Bokaro' , N'Jaridih' UNION ALL 
 Select 'Jharkhand' , N'Bokaro' , N'Kasmar' UNION ALL 
 Select 'Jharkhand' , N'Bokaro' , N'Nawadih' UNION ALL 
 Select 'Jharkhand' , N'Bokaro' , N'Peterwar' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Chatra' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Giddhor' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Itkhori' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Kanhachatti' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Kunda' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Lawalong' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Mayurhand' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Pathalgada' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Pratappur' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Shaligram Ram Narayanpur Alias Hunterganj' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Simaria' UNION ALL 
 Select 'Jharkhand' , N'Chatra' , N'Tandwa' UNION ALL 
 Select 'Jharkhand' , N'Deoghar' , N'Deoghar' UNION ALL 
 Select 'Jharkhand' , N'Deoghar' , N'Devipur' UNION ALL 
 Select 'Jharkhand' , N'Deoghar' , N'Karown' UNION ALL 
 Select 'Jharkhand' , N'Deoghar' , N'Madhupur' UNION ALL 
 Select 'Jharkhand' , N'Deoghar' , N'Margomunda' UNION ALL 
 Select 'Jharkhand' , N'Deoghar' , N'Mohanpur' UNION ALL 
 Select 'Jharkhand' , N'Deoghar' , N'Palojori' UNION ALL 
 Select 'Jharkhand' , N'Deoghar' , N'Sarath' UNION ALL 
 Select 'Jharkhand' , N'Deoghar' , N'Sarwan' UNION ALL 
 Select 'Jharkhand' , N'Deoghar' , N'Sonaraithari' UNION ALL 
 Select 'Jharkhand' , N'Dhanbad' , N'Baghmara' UNION ALL 
 Select 'Jharkhand' , N'Dhanbad' , N'Baliapur' UNION ALL 
 Select 'Jharkhand' , N'Dhanbad' , N'Dhanbad' UNION ALL 
 Select 'Jharkhand' , N'Dhanbad' , N'Egarkund' UNION ALL 
 Select 'Jharkhand' , N'Dhanbad' , N'Govindpur' UNION ALL 
 Select 'Jharkhand' , N'Dhanbad' , N'Kaliasol' UNION ALL 
 Select 'Jharkhand' , N'Dhanbad' , N'Nirsa' UNION ALL 
 Select 'Jharkhand' , N'Dhanbad' , N'Purvi Tundi' UNION ALL 
 Select 'Jharkhand' , N'Dhanbad' , N'Topchanchi' UNION ALL 
 Select 'Jharkhand' , N'Dhanbad' , N'Tundi' UNION ALL 
 Select 'Jharkhand' , N'Dumka' , N'Dumka' UNION ALL 
 Select 'Jharkhand' , N'Dumka' , N'Gopikander' UNION ALL 
 Select 'Jharkhand' , N'Dumka' , N'Jama' UNION ALL 
 Select 'Jharkhand' , N'Dumka' , N'Jarmundi' UNION ALL 
 Select 'Jharkhand' , N'Dumka' , N'Kathikund' UNION ALL 
 Select 'Jharkhand' , N'Dumka' , N'Masaliya' UNION ALL 
 Select 'Jharkhand' , N'Dumka' , N'Ramgarh' UNION ALL 
 Select 'Jharkhand' , N'Dumka' , N'Ranishwar' UNION ALL 
 Select 'Jharkhand' , N'Dumka' , N'Saraiyahat' UNION ALL 
 Select 'Jharkhand' , N'Dumka' , N'Sikaripara' UNION ALL 
 Select 'Jharkhand' , N'East Singhbum' , N'Bahragora' UNION ALL 
 Select 'Jharkhand' , N'East Singhbum' , N'Boram' UNION ALL 
 Select 'Jharkhand' , N'East Singhbum' , N'Chakulia' UNION ALL 
 Select 'Jharkhand' , N'East Singhbum' , N'Dhalbhumgarh' UNION ALL 
 Select 'Jharkhand' , N'East Singhbum' , N'Dumaria' UNION ALL 
 Select 'Jharkhand' , N'East Singhbum' , N'Ghatshila' UNION ALL 
 Select 'Jharkhand' , N'East Singhbum' , N'Golmuri Cum Jugsalai' UNION ALL 
 Select 'Jharkhand' , N'East Singhbum' , N'Gurabanda' UNION ALL 
 Select 'Jharkhand' , N'East Singhbum' , N'Musabani' UNION ALL 
 Select 'Jharkhand' , N'East Singhbum' , N'Patamda' UNION ALL 
 Select 'Jharkhand' , N'East Singhbum' , N'Potka' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Bardiha' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Bargad' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Bhandaria' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Bhawnathpur' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Bishunpura' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Chinia' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Danda' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Dandai' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Dhurki' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Garhwa' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Kandi' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Ketar' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Kharaundhi' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Manjhiaon' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Meral' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Nagar Untari' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Ramkanda' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Ramna' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Ranka' UNION ALL 
 Select 'Jharkhand' , N'Garhwa' , N'Sagma' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Bagodar' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Bengabad' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Birni' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Deori' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Dhanwar' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Dumri' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Gandey' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Gawan' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Giridih' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Jamua' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Pirtand' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Suriya' UNION ALL 
 Select 'Jharkhand' , N'Giridih' , N'Tisri' UNION ALL 
 Select 'Jharkhand' , N'Godda' , N'Basantray' UNION ALL 
 Select 'Jharkhand' , N'Godda' , N'Boarijor' UNION ALL 
 Select 'Jharkhand' , N'Godda' , N'Godda' UNION ALL 
 Select 'Jharkhand' , N'Godda' , N'Mahagama' UNION ALL 
 Select 'Jharkhand' , N'Godda' , N'Meharma' UNION ALL 
 Select 'Jharkhand' , N'Godda' , N'Pathargama' UNION ALL 
 Select 'Jharkhand' , N'Godda' , N'Poraiyahat' UNION ALL 
 Select 'Jharkhand' , N'Godda' , N'Sundarpahari' UNION ALL 
 Select 'Jharkhand' , N'Godda' , N'Thakurgangti' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Albert Ekka' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Basia' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Bharno' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Bishunpur' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Chainpur' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Dumri' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Ghaghra' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Gumla' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Kamdara' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Palkot' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Raidih' UNION ALL 
 Select 'Jharkhand' , N'Gumla' , N'Sisai' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Barhi' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Barkagaon' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Barkatha' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Bishnugarh' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Chalkusha' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Chouparan' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Churchu' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Dadi' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Daru' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Ichak' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Katkamdag' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Katkamsandi' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Keredari' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Padma' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Sadar' UNION ALL 
 Select 'Jharkhand' , N'Hazaribagh' , N'Tatijhariya' UNION ALL 
 Select 'Jharkhand' , N'Jamtara' , N'Fatehpur' UNION ALL 
 Select 'Jharkhand' , N'Jamtara' , N'Jamtara' UNION ALL 
 Select 'Jharkhand' , N'Jamtara' , N'Karmatanr Vidyasagar' UNION ALL 
 Select 'Jharkhand' , N'Jamtara' , N'Kundhit' UNION ALL 
 Select 'Jharkhand' , N'Jamtara' , N'Nala' UNION ALL 
 Select 'Jharkhand' , N'Jamtara' , N'Narayanpur' UNION ALL 
 Select 'Jharkhand' , N'Khunti' , N'Arki' UNION ALL 
 Select 'Jharkhand' , N'Khunti' , N'Karra' UNION ALL 
 Select 'Jharkhand' , N'Khunti' , N'Khunti' UNION ALL 
 Select 'Jharkhand' , N'Khunti' , N'Murhu' UNION ALL 
 Select 'Jharkhand' , N'Khunti' , N'Rania' UNION ALL 
 Select 'Jharkhand' , N'Khunti' , N'Torpa' UNION ALL 
 Select 'Jharkhand' , N'Koderma' , N'Chandwara' UNION ALL 
 Select 'Jharkhand' , N'Koderma' , N'Domchanch' UNION ALL 
 Select 'Jharkhand' , N'Koderma' , N'Jainagar' UNION ALL 
 Select 'Jharkhand' , N'Koderma' , N'Koderma' UNION ALL 
 Select 'Jharkhand' , N'Koderma' , N'Markacho' UNION ALL 
 Select 'Jharkhand' , N'Koderma' , N'Satgawan' UNION ALL 
 Select 'Jharkhand' , N'Latehar' , N'Balumath' UNION ALL 
 Select 'Jharkhand' , N'Latehar' , N'Bariyatu' UNION ALL 
 Select 'Jharkhand' , N'Latehar' , N'Barwadih' UNION ALL 
 Select 'Jharkhand' , N'Latehar' , N'Chandwa' UNION ALL 
 Select 'Jharkhand' , N'Latehar' , N'Garu' UNION ALL 
 Select 'Jharkhand' , N'Latehar' , N'Herhanj' UNION ALL 
 Select 'Jharkhand' , N'Latehar' , N'Latehar' UNION ALL 
 Select 'Jharkhand' , N'Latehar' , N'Mahuadanr' UNION ALL 
 Select 'Jharkhand' , N'Latehar' , N'Manika' UNION ALL 
 Select 'Jharkhand' , N'Latehar' , N'Saryu' UNION ALL 
 Select 'Jharkhand' , N'Lohardaga' , N'Bhandra' UNION ALL 
 Select 'Jharkhand' , N'Lohardaga' , N'Kairo' UNION ALL 
 Select 'Jharkhand' , N'Lohardaga' , N'Kisko' UNION ALL 
 Select 'Jharkhand' , N'Lohardaga' , N'Kuru' UNION ALL 
 Select 'Jharkhand' , N'Lohardaga' , N'Lohardaga' UNION ALL 
 Select 'Jharkhand' , N'Lohardaga' , N'Peshrar' UNION ALL 
 Select 'Jharkhand' , N'Lohardaga' , N'Senha' UNION ALL 
 Select 'Jharkhand' , N'Pakur' , N'Amrapara' UNION ALL 
 Select 'Jharkhand' , N'Pakur' , N'Hiranpur' UNION ALL 
 Select 'Jharkhand' , N'Pakur' , N'Littipara' UNION ALL 
 Select 'Jharkhand' , N'Pakur' , N'Maheshpur' UNION ALL 
 Select 'Jharkhand' , N'Pakur' , N'Pakur' UNION ALL 
 Select 'Jharkhand' , N'Pakur' , N'Pakuria' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Bishrampur' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Chainpur' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Chhatarpur' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Haidernagar' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Hariharganj' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Hussainabad' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Lesliganj' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Manatu' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Medininagar' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Mohamadganj' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Nawa Bazar' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Nawdiha Bazar' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Padwa' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Pandu' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Panki' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Patan' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Pipra' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Ramgarh' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Satbarwa' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Tarhasi' UNION ALL 
 Select 'Jharkhand' , N'Palamu' , N'Untari Road' UNION ALL 
 Select 'Jharkhand' , N'Ramgarh' , N'Chitarpur' UNION ALL 
 Select 'Jharkhand' , N'Ramgarh' , N'Dulmi' UNION ALL 
 Select 'Jharkhand' , N'Ramgarh' , N'Gola' UNION ALL 
 Select 'Jharkhand' , N'Ramgarh' , N'Mandu' UNION ALL 
 Select 'Jharkhand' , N'Ramgarh' , N'Patratu' UNION ALL 
 Select 'Jharkhand' , N'Ramgarh' , N'Ramgarh' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Angara' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Bero' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Bundu' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Burmu' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Chanho' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Itki' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Kanke' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Khelari' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Lapung' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Mandar' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Nagri' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Namkum' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Ormanjhi' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Rahe' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Ratu' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Silli' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Sonahatu' UNION ALL 
 Select 'Jharkhand' , N'Ranchi' , N'Tamar' UNION ALL 
 Select 'Jharkhand' , N'Sahebganj' , N'Barhait' UNION ALL 
 Select 'Jharkhand' , N'Sahebganj' , N'Barharwa' UNION ALL 
 Select 'Jharkhand' , N'Sahebganj' , N'Borio' UNION ALL 
 Select 'Jharkhand' , N'Sahebganj' , N'Mandro' UNION ALL 
 Select 'Jharkhand' , N'Sahebganj' , N'Pathna' UNION ALL 
 Select 'Jharkhand' , N'Sahebganj' , N'Rajmahal' UNION ALL 
 Select 'Jharkhand' , N'Sahebganj' , N'Sahibganj' UNION ALL 
 Select 'Jharkhand' , N'Sahebganj' , N'Taljhari' UNION ALL 
 Select 'Jharkhand' , N'Sahebganj' , N'Udhwa' UNION ALL 
 Select 'Jharkhand' , N'Saraikela Kharsawan' , N'Chandil' UNION ALL 
 Select 'Jharkhand' , N'Saraikela Kharsawan' , N'Gamharia' UNION ALL 
 Select 'Jharkhand' , N'Saraikela Kharsawan' , N'Ichagarh' UNION ALL 
 Select 'Jharkhand' , N'Saraikela Kharsawan' , N'Kharsawan' UNION ALL 
 Select 'Jharkhand' , N'Saraikela Kharsawan' , N'Kuchai' UNION ALL 
 Select 'Jharkhand' , N'Saraikela Kharsawan' , N'Kukru' UNION ALL 
 Select 'Jharkhand' , N'Saraikela Kharsawan' , N'Nimdih' UNION ALL 
 Select 'Jharkhand' , N'Saraikela Kharsawan' , N'Rajnagar' UNION ALL 
 Select 'Jharkhand' , N'Saraikela Kharsawan' , N'Seraikella' UNION ALL 
 Select 'Jharkhand' , N'Simdega' , N'Bano' UNION ALL 
 Select 'Jharkhand' , N'Simdega' , N'Bansjore' UNION ALL 
 Select 'Jharkhand' , N'Simdega' , N'Bolba' UNION ALL 
 Select 'Jharkhand' , N'Simdega' , N'Jaldega' UNION ALL 
 Select 'Jharkhand' , N'Simdega' , N'Kersai' UNION ALL 
 Select 'Jharkhand' , N'Simdega' , N'Kolebira' UNION ALL 
 Select 'Jharkhand' , N'Simdega' , N'Kurdeg' UNION ALL 
 Select 'Jharkhand' , N'Simdega' , N'Pakartanr' UNION ALL 
 Select 'Jharkhand' , N'Simdega' , N'Simdega' UNION ALL 
 Select 'Jharkhand' , N'Simdega' , N'Thethaitanger' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Anandpur' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Bandgaon' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Chaibasa' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Chakradharpur' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Goelkera' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Gudri' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Hatgamharia' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Jagannathpur' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Jhinkpani' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Khuntpani' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Kumardungi' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Manjhari' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Manjhgaon' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Manoharpur' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Noamundi' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Sonua' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Tantnagar' UNION ALL 
 Select 'Jharkhand' , N'West Singhbhum' , N'Tonto'

)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Karnataka' , N'Bagalkote' , N'Badami' UNION ALL 
 Select 'Karnataka' , N'Bagalkote' , N'Bagalkot' UNION ALL 
 Select 'Karnataka' , N'Bagalkote' , N'Bilagi' UNION ALL 
 Select 'Karnataka' , N'Bagalkote' , N'Guledagudda' UNION ALL 
 Select 'Karnataka' , N'Bagalkote' , N'Hungund' UNION ALL 
 Select 'Karnataka' , N'Bagalkote' , N'Ilkal' UNION ALL 
 Select 'Karnataka' , N'Bagalkote' , N'Jamkhandi' UNION ALL 
 Select 'Karnataka' , N'Bagalkote' , N'Mudhol' UNION ALL 
 Select 'Karnataka' , N'Bagalkote' , N'Rabakavi Banahatti' UNION ALL 
 Select 'Karnataka' , N'Ballari' , N'Ballari' UNION ALL 
 Select 'Karnataka' , N'Ballari' , N'Kampli' UNION ALL 
 Select 'Karnataka' , N'Ballari' , N'Kurugodu' UNION ALL 
 Select 'Karnataka' , N'Ballari' , N'Sandur' UNION ALL 
 Select 'Karnataka' , N'Ballari' , N'Siruguppa' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Athni' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Belagavi' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Bylahongal' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Chikodi' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Gokak' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Hukeri' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Kagawada' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Khanapur' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Kittur' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Mudalagi' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Nippani' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Ramdurg' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Raybag' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Savadathi' UNION ALL 
 Select 'Karnataka' , N'Belagavi' , N'Yaragatti' UNION ALL 
 Select 'Karnataka' , N'Bengaluru Rural' , N'Devanhalli' UNION ALL 
 Select 'Karnataka' , N'Bengaluru Rural' , N'Dodballapur' UNION ALL 
 Select 'Karnataka' , N'Bengaluru Rural' , N'Hoskote' UNION ALL 
 Select 'Karnataka' , N'Bengaluru Rural' , N'Nelamangala' UNION ALL 
 Select 'Karnataka' , N'Bengaluru Urban' , N'Anekal' UNION ALL 
 Select 'Karnataka' , N'Bengaluru Urban' , N'Bengaluru East' UNION ALL 
 Select 'Karnataka' , N'Bengaluru Urban' , N'Bengaluru North' UNION ALL 
 Select 'Karnataka' , N'Bengaluru Urban' , N'Bengaluru South' UNION ALL 
 Select 'Karnataka' , N'Bengaluru Urban' , N'Yelahanka' UNION ALL 
 Select 'Karnataka' , N'Bidar' , N'Aurad' UNION ALL 
 Select 'Karnataka' , N'Bidar' , N'Basavakalyan' UNION ALL 
 Select 'Karnataka' , N'Bidar' , N'Bhalki' UNION ALL 
 Select 'Karnataka' , N'Bidar' , N'Bidar' UNION ALL 
 Select 'Karnataka' , N'Bidar' , N'Chittaguppa' UNION ALL 
 Select 'Karnataka' , N'Bidar' , N'Hulasuru' UNION ALL 
 Select 'Karnataka' , N'Bidar' , N'Humnabad' UNION ALL 
 Select 'Karnataka' , N'Bidar' , N'Kamalanagara' UNION ALL 
 Select 'Karnataka' , N'Chamarajanagara' , N'Chamarajanagar' UNION ALL 
 Select 'Karnataka' , N'Chamarajanagara' , N'Gundlupet' UNION ALL 
 Select 'Karnataka' , N'Chamarajanagara' , N'Hanuru' UNION ALL 
 Select 'Karnataka' , N'Chamarajanagara' , N'Kollegala' UNION ALL 
 Select 'Karnataka' , N'Chamarajanagara' , N'Yelandur' UNION ALL 
 Select 'Karnataka' , N'Chikkaballapura' , N'Bagepalli' UNION ALL 
 Select 'Karnataka' , N'Chikkaballapura' , N'Cheluru' UNION ALL 
 Select 'Karnataka' , N'Chikkaballapura' , N'Chikballapur' UNION ALL 
 Select 'Karnataka' , N'Chikkaballapura' , N'Chintamani' UNION ALL 
 Select 'Karnataka' , N'Chikkaballapura' , N'Gauribidanur' UNION ALL 
 Select 'Karnataka' , N'Chikkaballapura' , N'Gudibanda' UNION ALL 
 Select 'Karnataka' , N'Chikkaballapura' , N'Manchenahalli' UNION ALL 
 Select 'Karnataka' , N'Chikkaballapura' , N'Sidlaghatta' UNION ALL 
 Select 'Karnataka' , N'Chikkamagaluru' , N'Ajjampura' UNION ALL 
 Select 'Karnataka' , N'Chikkamagaluru' , N'Chikkamagaluru' UNION ALL 
 Select 'Karnataka' , N'Chikkamagaluru' , N'Kadur' UNION ALL 
 Select 'Karnataka' , N'Chikkamagaluru' , N'Kalasa' UNION ALL 
 Select 'Karnataka' , N'Chikkamagaluru' , N'Koppa' UNION ALL 
 Select 'Karnataka' , N'Chikkamagaluru' , N'Mudigere' UNION ALL 
 Select 'Karnataka' , N'Chikkamagaluru' , N'Narasimharajapura' UNION ALL 
 Select 'Karnataka' , N'Chikkamagaluru' , N'Sringeri' UNION ALL 
 Select 'Karnataka' , N'Chikkamagaluru' , N'Tarikere' UNION ALL 
 Select 'Karnataka' , N'Chitradurga' , N'Challakere' UNION ALL 
 Select 'Karnataka' , N'Chitradurga' , N'Chitradurga' UNION ALL 
 Select 'Karnataka' , N'Chitradurga' , N'Hiriyur' UNION ALL 
 Select 'Karnataka' , N'Chitradurga' , N'Holalkere' UNION ALL 
 Select 'Karnataka' , N'Chitradurga' , N'Hosdurga' UNION ALL 
 Select 'Karnataka' , N'Chitradurga' , N'Molakalmuru' UNION ALL 
 Select 'Karnataka' , N'Dakshina Kannada' , N'Bantval' UNION ALL 
 Select 'Karnataka' , N'Dakshina Kannada' , N'Beltangadi' UNION ALL 
 Select 'Karnataka' , N'Dakshina Kannada' , N'Kadaba' UNION ALL 
 Select 'Karnataka' , N'Dakshina Kannada' , N'Mangaluru' UNION ALL 
 Select 'Karnataka' , N'Dakshina Kannada' , N'Mudubidare' UNION ALL 
 Select 'Karnataka' , N'Dakshina Kannada' , N'Mulki' UNION ALL 
 Select 'Karnataka' , N'Dakshina Kannada' , N'Puttur' UNION ALL 
 Select 'Karnataka' , N'Dakshina Kannada' , N'Sulya' UNION ALL 
 Select 'Karnataka' , N'Dakshina Kannada' , N'Ullala' UNION ALL 
 Select 'Karnataka' , N'Davangere' , N'Channagiri' UNION ALL 
 Select 'Karnataka' , N'Davangere' , N'Davanagere' UNION ALL 
 Select 'Karnataka' , N'Davangere' , N'Harihara' UNION ALL 
 Select 'Karnataka' , N'Davangere' , N'Honnali' UNION ALL 
 Select 'Karnataka' , N'Davangere' , N'Jagalur' UNION ALL 
 Select 'Karnataka' , N'Davangere' , N'Nyamathi' UNION ALL 
 Select 'Karnataka' , N'Dharwad' , N'Alnavar' UNION ALL 
 Select 'Karnataka' , N'Dharwad' , N'Annigeri' UNION ALL 
 Select 'Karnataka' , N'Dharwad' , N'Dharwad' UNION ALL 
 Select 'Karnataka' , N'Dharwad' , N'Hubballi' UNION ALL 
 Select 'Karnataka' , N'Dharwad' , N'Kalghatgi' UNION ALL 
 Select 'Karnataka' , N'Dharwad' , N'Kundgol' UNION ALL 
 Select 'Karnataka' , N'Dharwad' , N'Navalgund' UNION ALL 
 Select 'Karnataka' , N'Gadag' , N'Gadag' UNION ALL 
 Select 'Karnataka' , N'Gadag' , N'Gajendragad' UNION ALL 
 Select 'Karnataka' , N'Gadag' , N'Laxmeshwar' UNION ALL 
 Select 'Karnataka' , N'Gadag' , N'Mundaragi' UNION ALL 
 Select 'Karnataka' , N'Gadag' , N'Naragund' UNION ALL 
 Select 'Karnataka' , N'Gadag' , N'Ron' UNION ALL 
 Select 'Karnataka' , N'Gadag' , N'Shirahatti' UNION ALL 
 Select 'Karnataka' , N'Hassan' , N'Alur' UNION ALL 
 Select 'Karnataka' , N'Hassan' , N'Arkalgud' UNION ALL 
 Select 'Karnataka' , N'Hassan' , N'Arsikere' UNION ALL 
 Select 'Karnataka' , N'Hassan' , N'Belur' UNION ALL 
 Select 'Karnataka' , N'Hassan' , N'Channarayapatna' UNION ALL 
 Select 'Karnataka' , N'Hassan' , N'Hassan' UNION ALL 
 Select 'Karnataka' , N'Hassan' , N'Holenarsipur' UNION ALL 
 Select 'Karnataka' , N'Hassan' , N'Sakaleshpur' UNION ALL 
 Select 'Karnataka' , N'Haveri' , N'Byadgi' UNION ALL 
 Select 'Karnataka' , N'Haveri' , N'Hanagal' UNION ALL 
 Select 'Karnataka' , N'Haveri' , N'Haveri' UNION ALL 
 Select 'Karnataka' , N'Haveri' , N'Hirekerur' UNION ALL 
 Select 'Karnataka' , N'Haveri' , N'Ranebennur' UNION ALL 
 Select 'Karnataka' , N'Haveri' , N'Rattihalli' UNION ALL 
 Select 'Karnataka' , N'Haveri' , N'Savanur' UNION ALL 
 Select 'Karnataka' , N'Haveri' , N'Shiggaon' UNION ALL 
 Select 'Karnataka' , N'Kalaburagi' , N'Afzalpur' UNION ALL 
 Select 'Karnataka' , N'Kalaburagi' , N'Aland' UNION ALL 
 Select 'Karnataka' , N'Kalaburagi' , N'Chincholi' UNION ALL 
 Select 'Karnataka' , N'Kalaburagi' , N'Chitapur' UNION ALL 
 Select 'Karnataka' , N'Kalaburagi' , N'Jevargi' UNION ALL 
 Select 'Karnataka' , N'Kalaburagi' , N'Kalaburagi' UNION ALL 
 Select 'Karnataka' , N'Kalaburagi' , N'Kalagi' UNION ALL 
 Select 'Karnataka' , N'Kalaburagi' , N'Kamalapur' UNION ALL 
 Select 'Karnataka' , N'Kalaburagi' , N'Sedam' UNION ALL 
 Select 'Karnataka' , N'Kalaburagi' , N'Shabad' UNION ALL 
 Select 'Karnataka' , N'Kalaburagi' , N'Yadrami' UNION ALL 
 Select 'Karnataka' , N'Kodagu' , N'Kushalanagar' UNION ALL 
 Select 'Karnataka' , N'Kodagu' , N'Madikeri' UNION ALL 
 Select 'Karnataka' , N'Kodagu' , N'Ponnampet' UNION ALL 
 Select 'Karnataka' , N'Kodagu' , N'Somvarpet' UNION ALL 
 Select 'Karnataka' , N'Kodagu' , N'Virajpet' UNION ALL 
 Select 'Karnataka' , N'Kolar' , N'Bangarapet' UNION ALL 
 Select 'Karnataka' , N'Kolar' , N'K G F' UNION ALL 
 Select 'Karnataka' , N'Kolar' , N'Kolar' UNION ALL 
 Select 'Karnataka' , N'Kolar' , N'Malur' UNION ALL 
 Select 'Karnataka' , N'Kolar' , N'Mulbagal' UNION ALL 
 Select 'Karnataka' , N'Kolar' , N'Srinivaspur' UNION ALL 
 Select 'Karnataka' , N'Koppal' , N'Gangavathi' UNION ALL 
 Select 'Karnataka' , N'Koppal' , N'Kanakagiri' UNION ALL 
 Select 'Karnataka' , N'Koppal' , N'Karatagi' UNION ALL 
 Select 'Karnataka' , N'Koppal' , N'Koppal' UNION ALL 
 Select 'Karnataka' , N'Koppal' , N'Kukunoor' UNION ALL 
 Select 'Karnataka' , N'Koppal' , N'Kushtagi' UNION ALL 
 Select 'Karnataka' , N'Koppal' , N'Yelburga' UNION ALL 
 Select 'Karnataka' , N'Mandya' , N'Krishnarajpet' UNION ALL 
 Select 'Karnataka' , N'Mandya' , N'Maddur' UNION ALL 
 Select 'Karnataka' , N'Mandya' , N'Malvalli' UNION ALL 
 Select 'Karnataka' , N'Mandya' , N'Mandya' UNION ALL 
 Select 'Karnataka' , N'Mandya' , N'Nagamangala' UNION ALL 
 Select 'Karnataka' , N'Mandya' , N'Pandavapura' UNION ALL 
 Select 'Karnataka' , N'Mandya' , N'Shrirangapattana' UNION ALL 
 Select 'Karnataka' , N'Mysuru' , N'Heggadadevankote' UNION ALL 
 Select 'Karnataka' , N'Mysuru' , N'Hunsur' UNION ALL 
 Select 'Karnataka' , N'Mysuru' , N'Krishnarajanagara' UNION ALL 
 Select 'Karnataka' , N'Mysuru' , N'Mysuru' UNION ALL 
 Select 'Karnataka' , N'Mysuru' , N'Nanjangud' UNION ALL 
 Select 'Karnataka' , N'Mysuru' , N'Piriyapatna' UNION ALL 
 Select 'Karnataka' , N'Mysuru' , N'Saligrama' UNION ALL 
 Select 'Karnataka' , N'Mysuru' , N'Saraguru' UNION ALL 
 Select 'Karnataka' , N'Mysuru' , N'Tirumakudal-Narsipur' UNION ALL 
 Select 'Karnataka' , N'Raichur' , N'Devadurga' UNION ALL 
 Select 'Karnataka' , N'Raichur' , N'Lingsugur' UNION ALL 
 Select 'Karnataka' , N'Raichur' , N'Manvi' UNION ALL 
 Select 'Karnataka' , N'Raichur' , N'Maski' UNION ALL 
 Select 'Karnataka' , N'Raichur' , N'Raichur' UNION ALL 
 Select 'Karnataka' , N'Raichur' , N'Sindhanur' UNION ALL 
 Select 'Karnataka' , N'Raichur' , N'Sirawara' UNION ALL 
 Select 'Karnataka' , N'Ramanagara' , N'Channapatna' UNION ALL 
 Select 'Karnataka' , N'Ramanagara' , N'Harohalli' UNION ALL 
 Select 'Karnataka' , N'Ramanagara' , N'Kanakapura' UNION ALL 
 Select 'Karnataka' , N'Ramanagara' , N'Magadi' UNION ALL 
 Select 'Karnataka' , N'Ramanagara' , N'Ramanagara' UNION ALL 
 Select 'Karnataka' , N'Shivamogga' , N'Bhadravati' UNION ALL 
 Select 'Karnataka' , N'Shivamogga' , N'Hosanagara' UNION ALL 
 Select 'Karnataka' , N'Shivamogga' , N'Sagar' UNION ALL 
 Select 'Karnataka' , N'Shivamogga' , N'Shikarpur' UNION ALL 
 Select 'Karnataka' , N'Shivamogga' , N'Shivamogga' UNION ALL 
 Select 'Karnataka' , N'Shivamogga' , N'Sorab' UNION ALL 
 Select 'Karnataka' , N'Shivamogga' , N'Tirthahalli' UNION ALL 
 Select 'Karnataka' , N'Tumakuru' , N'Chiknayakanhalli' UNION ALL 
 Select 'Karnataka' , N'Tumakuru' , N'Gubbi' UNION ALL 
 Select 'Karnataka' , N'Tumakuru' , N'Koratagere' UNION ALL 
 Select 'Karnataka' , N'Tumakuru' , N'Kunigal' UNION ALL 
 Select 'Karnataka' , N'Tumakuru' , N'Madhugiri' UNION ALL 
 Select 'Karnataka' , N'Tumakuru' , N'Pavagada' UNION ALL 
 Select 'Karnataka' , N'Tumakuru' , N'Sira' UNION ALL 
 Select 'Karnataka' , N'Tumakuru' , N'Tiptur' UNION ALL 
 Select 'Karnataka' , N'Tumakuru' , N'Tumakuru' UNION ALL 
 Select 'Karnataka' , N'Tumakuru' , N'Turuvekere' UNION ALL 
 Select 'Karnataka' , N'Udupi' , N'Bainduru' UNION ALL 
 Select 'Karnataka' , N'Udupi' , N'Brahmavara' UNION ALL 
 Select 'Karnataka' , N'Udupi' , N'Hebri' UNION ALL 
 Select 'Karnataka' , N'Udupi' , N'Kapu' UNION ALL 
 Select 'Karnataka' , N'Udupi' , N'Karkal' UNION ALL 
 Select 'Karnataka' , N'Udupi' , N'Kundapura' UNION ALL 
 Select 'Karnataka' , N'Udupi' , N'Udupi' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Ankola' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Bhatkal' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Dandeli' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Haliyal' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Honavar' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Karwar' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Kumta' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Mundgod' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Siddapur' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Sirsi' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Supa' UNION ALL 
 Select 'Karnataka' , N'Uttara Kannada' , N'Yellapur' UNION ALL 
 Select 'Karnataka' , N'Vijayanagar' , N'Hadagalli' UNION ALL 
 Select 'Karnataka' , N'Vijayanagar' , N'Hagaribommanahalli' UNION ALL 
 Select 'Karnataka' , N'Vijayanagar' , N'Harappanahalli' UNION ALL 
 Select 'Karnataka' , N'Vijayanagar' , N'Hosapete' UNION ALL 
 Select 'Karnataka' , N'Vijayanagar' , N'Kottur' UNION ALL 
 Select 'Karnataka' , N'Vijayanagar' , N'Kudligi' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Almel' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Babaleshwar' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Basavana Bagewadi' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Chadachan' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Devara Hipparagi' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Indi' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Kolhar' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Muddebihal' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Nidagundi' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Sindagi' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Thalikoti' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Thikota' UNION ALL 
 Select 'Karnataka' , N'Vijayapura' , N'Vijayapura' UNION ALL 
 Select 'Karnataka' , N'Yadgir' , N'Gurumitkal' UNION ALL 
 Select 'Karnataka' , N'Yadgir' , N'Hunasagi' UNION ALL 
 Select 'Karnataka' , N'Yadgir' , N'Shahapur' UNION ALL 
 Select 'Karnataka' , N'Yadgir' , N'Shorapur' UNION ALL 
 Select 'Karnataka' , N'Yadgir' , N'Wadagera' UNION ALL 
 Select 'Karnataka' , N'Yadgir' , N'Yadgir'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Kerala' , N'Alappuzha' , N'Ambalappuzha' UNION ALL 
 Select 'Kerala' , N'Alappuzha' , N'Aryad' UNION ALL 
 Select 'Kerala' , N'Alappuzha' , N'Bharanicavu' UNION ALL 
 Select 'Kerala' , N'Alappuzha' , N'Champakulam' UNION ALL 
 Select 'Kerala' , N'Alappuzha' , N'Chengannur' UNION ALL 
 Select 'Kerala' , N'Alappuzha' , N'Harippad' UNION ALL 
 Select 'Kerala' , N'Alappuzha' , N'Kanjikkuzhy' UNION ALL 
 Select 'Kerala' , N'Alappuzha' , N'Mavelikkara' UNION ALL 
 Select 'Kerala' , N'Alappuzha' , N'Muthukulam' UNION ALL 
 Select 'Kerala' , N'Alappuzha' , N'Pattanakkad' UNION ALL 
 Select 'Kerala' , N'Alappuzha' , N'Thycattussery' UNION ALL 
 Select 'Kerala' , N'Alappuzha' , N'Veliyanad' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Alangad' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Angamali' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Edappally' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Koovappady' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Kothamangalam' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Mulanthuruthy' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Muvattupuzha' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Palluruthy' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Pampakuda' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Parakkadav' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Paravur' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Vadavucode' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Vazhakkulam' UNION ALL 
 Select 'Kerala' , N'Ernakulam' , N'Vypeen' UNION ALL 
 Select 'Kerala' , N'Idukki' , N'Adimaly' UNION ALL 
 Select 'Kerala' , N'Idukki' , N'Azhutha' UNION ALL 
 Select 'Kerala' , N'Idukki' , N'Devikulam' UNION ALL 
 Select 'Kerala' , N'Idukki' , N'Elemdesam' UNION ALL 
 Select 'Kerala' , N'Idukki' , N'Idukki' UNION ALL 
 Select 'Kerala' , N'Idukki' , N'Kattappana' UNION ALL 
 Select 'Kerala' , N'Idukki' , N'Nedumkandom' UNION ALL 
 Select 'Kerala' , N'Idukki' , N'Thodupuzha' UNION ALL 
 Select 'Kerala' , N'Kannur' , N'Edakkad' UNION ALL 
 Select 'Kerala' , N'Kannur' , N'Irikkur' UNION ALL 
 Select 'Kerala' , N'Kannur' , N'Iritty' UNION ALL 
 Select 'Kerala' , N'Kannur' , N'Kalliasseri' UNION ALL 
 Select 'Kerala' , N'Kannur' , N'Kannur' UNION ALL 
 Select 'Kerala' , N'Kannur' , N'Kuthuparamba' UNION ALL 
 Select 'Kerala' , N'Kannur' , N'Panoor' UNION ALL 
 Select 'Kerala' , N'Kannur' , N'Payyannur' UNION ALL 
 Select 'Kerala' , N'Kannur' , N'Peravoor' UNION ALL 
 Select 'Kerala' , N'Kannur' , N'Taliparamba' UNION ALL 
 Select 'Kerala' , N'Kannur' , N'Thalassery' UNION ALL 
 Select 'Kerala' , N'Kasaragod' , N'Kanhangad' UNION ALL 
 Select 'Kerala' , N'Kasaragod' , N'Karadka' UNION ALL 
 Select 'Kerala' , N'Kasaragod' , N'Kasargod' UNION ALL 
 Select 'Kerala' , N'Kasaragod' , N'Manjeshwar' UNION ALL 
 Select 'Kerala' , N'Kasaragod' , N'Nileshwar' UNION ALL 
 Select 'Kerala' , N'Kasaragod' , N'Parappa' UNION ALL 
 Select 'Kerala' , N'Kollam' , N'Anchal' UNION ALL 
 Select 'Kerala' , N'Kollam' , N'Chadayamangalam' UNION ALL 
 Select 'Kerala' , N'Kollam' , N'Chavara' UNION ALL 
 Select 'Kerala' , N'Kollam' , N'Chittumala' UNION ALL 
 Select 'Kerala' , N'Kollam' , N'Ithikkara' UNION ALL 
 Select 'Kerala' , N'Kollam' , N'Kottarakkara' UNION ALL 
 Select 'Kerala' , N'Kollam' , N'Mukhathala' UNION ALL 
 Select 'Kerala' , N'Kollam' , N'Oachira' UNION ALL 
 Select 'Kerala' , N'Kollam' , N'Pathanapuram' UNION ALL 
 Select 'Kerala' , N'Kollam' , N'Sasthamcottah' UNION ALL 
 Select 'Kerala' , N'Kollam' , N'Vettikkavala' UNION ALL 
 Select 'Kerala' , N'Kottayam' , N'Erattupetta' UNION ALL 
 Select 'Kerala' , N'Kottayam' , N'Ettumanoor' UNION ALL 
 Select 'Kerala' , N'Kottayam' , N'Kaduthuruthy' UNION ALL 
 Select 'Kerala' , N'Kottayam' , N'Kanjirappally' UNION ALL 
 Select 'Kerala' , N'Kottayam' , N'Lalam' UNION ALL 
 Select 'Kerala' , N'Kottayam' , N'Madappally' UNION ALL 
 Select 'Kerala' , N'Kottayam' , N'Pallom' UNION ALL 
 Select 'Kerala' , N'Kottayam' , N'Pampady' UNION ALL 
 Select 'Kerala' , N'Kottayam' , N'Uzhavoor' UNION ALL 
 Select 'Kerala' , N'Kottayam' , N'Vaikom' UNION ALL 
 Select 'Kerala' , N'Kottayam' , N'Vazhoor' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Balusseri' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Chelannur' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Koduvally' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Kozhikode' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Kunnamangalam' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Kunnummal' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Melday' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Panthalayani' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Perambra' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Thodannur' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Thuneri' UNION ALL 
 Select 'Kerala' , N'Kozhikode' , N'Vadakara' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Areakode' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Kalikavu' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Kondotty' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Kuttippuram' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Malappuram' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Mankada' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Nilambur' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Perinthalmanna' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Perumpadappu' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Ponnani' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Tanur' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Tirur' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Tirurangadi' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Vengara' UNION ALL 
 Select 'Kerala' , N'Malappuram' , N'Wandoor' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Alathur' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Attappadi' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Chittur' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Kollengode' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Kuzhalmannam' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Malampuzha' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Mannarkad' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Nemmara' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Ottappalam' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Palakkad' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Pattambi' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Sreekrishnapuram' UNION ALL 
 Select 'Kerala' , N'Palakkad' , N'Trithala' UNION ALL 
 Select 'Kerala' , N'Pathanamthitta' , N'Elanthoor' UNION ALL 
 Select 'Kerala' , N'Pathanamthitta' , N'Koipuram' UNION ALL 
 Select 'Kerala' , N'Pathanamthitta' , N'Konni' UNION ALL 
 Select 'Kerala' , N'Pathanamthitta' , N'Mallappally' UNION ALL 
 Select 'Kerala' , N'Pathanamthitta' , N'Pandlam' UNION ALL 
 Select 'Kerala' , N'Pathanamthitta' , N'Parakode' UNION ALL 
 Select 'Kerala' , N'Pathanamthitta' , N'Pulikeezhu' UNION ALL 
 Select 'Kerala' , N'Pathanamthitta' , N'Ranni' UNION ALL 
 Select 'Kerala' , N'Thiruvananthapuram' , N'Athiyannoor' UNION ALL 
 Select 'Kerala' , N'Thiruvananthapuram' , N'Chirayinkeezhu' UNION ALL 
 Select 'Kerala' , N'Thiruvananthapuram' , N'Kilimanoor' UNION ALL 
 Select 'Kerala' , N'Thiruvananthapuram' , N'Nedumangad' UNION ALL 
 Select 'Kerala' , N'Thiruvananthapuram' , N'Nemom' UNION ALL 
 Select 'Kerala' , N'Thiruvananthapuram' , N'Parassala' UNION ALL 
 Select 'Kerala' , N'Thiruvananthapuram' , N'Perumkadavila' UNION ALL 
 Select 'Kerala' , N'Thiruvananthapuram' , N'Pothencode' UNION ALL 
 Select 'Kerala' , N'Thiruvananthapuram' , N'Vamanapuram' UNION ALL 
 Select 'Kerala' , N'Thiruvananthapuram' , N'Varkala' UNION ALL 
 Select 'Kerala' , N'Thiruvananthapuram' , N'Vellanad' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Anthikkad' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Chalakkudy' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Chavakkad' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Cherpu' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Chowannur' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Irinjalakkuda' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Kodakara' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Mala' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Mathilakam' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Mullassery' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Ollukkara' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Pazhayannur' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Puzhakkal' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Thalikkulam' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Vellangallur' UNION ALL 
 Select 'Kerala' , N'Thrissur' , N'Wadakkanchery' UNION ALL 
 Select 'Kerala' , N'Wayanad' , N'Kalpetta' UNION ALL 
 Select 'Kerala' , N'Wayanad' , N'Mananthavady' UNION ALL 
 Select 'Kerala' , N'Wayanad' , N'Panamaram' UNION ALL 
 Select 'Kerala' , N'Wayanad' , N'Sulthan Bathery'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Ladakh' , N'Kargil' , N'Barsoo' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Bhimbat' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Drass' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Gm Pora (Trespone)' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Kargil' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Karsha' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Lotsum' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Lungnak' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Pashkum' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Sankoo' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Shaker Chaktan' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Shargol' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Soudh' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Taisuru' UNION ALL 
 Select 'Ladakh' , N'Kargil' , N'Zansker' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Chuchot' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Deskit' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Durbuk' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Khaltsi' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Kharu' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Leh' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Nimoo' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Nyoma' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Panamic' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Rong' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Rupsho' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Saspol' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Singay Lalok Wanla' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Sukerbachan' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Thiksay' UNION ALL 
 Select 'Ladakh' , N'Leh Ladakh' , N'Turtuk'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Lakshadweep' , N'Lakshadweep District' , N'Agatti' UNION ALL 
 Select 'Lakshadweep' , N'Lakshadweep District' , N'Amini' UNION ALL 
 Select 'Lakshadweep' , N'Lakshadweep District' , N'Andrott' UNION ALL 
 Select 'Lakshadweep' , N'Lakshadweep District' , N'Bitra' UNION ALL 
 Select 'Lakshadweep' , N'Lakshadweep District' , N'Chetlat' UNION ALL 
 Select 'Lakshadweep' , N'Lakshadweep District' , N'Kadmat' UNION ALL 
 Select 'Lakshadweep' , N'Lakshadweep District' , N'Kalpeni' UNION ALL 
 Select 'Lakshadweep' , N'Lakshadweep District' , N'Kavaratti' UNION ALL 
 Select 'Lakshadweep' , N'Lakshadweep District' , N'Kiltan' UNION ALL 
 Select 'Lakshadweep' , N'Lakshadweep District' , N'Minicoy'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Madhya Pradesh' , N'Agar-Malwa' , N'Agar' UNION ALL 
 Select 'Madhya Pradesh' , N'Agar-Malwa' , N'Barod' UNION ALL 
 Select 'Madhya Pradesh' , N'Agar-Malwa' , N'Nalkheda' UNION ALL 
 Select 'Madhya Pradesh' , N'Agar-Malwa' , N'Susner' UNION ALL 
 Select 'Madhya Pradesh' , N'Alirajpur' , N'Alirajpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Alirajpur' , N'Bhabra' UNION ALL 
 Select 'Madhya Pradesh' , N'Alirajpur' , N'Jobat' UNION ALL 
 Select 'Madhya Pradesh' , N'Alirajpur' , N'Katthiwada' UNION ALL 
 Select 'Madhya Pradesh' , N'Alirajpur' , N'Sondwa' UNION ALL 
 Select 'Madhya Pradesh' , N'Alirajpur' , N'Udaigarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Anuppur' , N'Anuppur' UNION ALL 
 Select 'Madhya Pradesh' , N'Anuppur' , N'Jaithari' UNION ALL 
 Select 'Madhya Pradesh' , N'Anuppur' , N'Kotma' UNION ALL 
 Select 'Madhya Pradesh' , N'Anuppur' , N'Pushprajgarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Ashoknagar' , N'Ashoknagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Ashoknagar' , N'Chanderi' UNION ALL 
 Select 'Madhya Pradesh' , N'Ashoknagar' , N'Isagarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Ashoknagar' , N'Mungaoli' UNION ALL 
 Select 'Madhya Pradesh' , N'Balaghat' , N'Baihar' UNION ALL 
 Select 'Madhya Pradesh' , N'Balaghat' , N'Balaghat' UNION ALL 
 Select 'Madhya Pradesh' , N'Balaghat' , N'Birsa' UNION ALL 
 Select 'Madhya Pradesh' , N'Balaghat' , N'Katangi' UNION ALL 
 Select 'Madhya Pradesh' , N'Balaghat' , N'Khairlanji' UNION ALL 
 Select 'Madhya Pradesh' , N'Balaghat' , N'Kirnapur' UNION ALL 
 Select 'Madhya Pradesh' , N'Balaghat' , N'Lalbarra' UNION ALL 
 Select 'Madhya Pradesh' , N'Balaghat' , N'Lanji' UNION ALL 
 Select 'Madhya Pradesh' , N'Balaghat' , N'Paraswada' UNION ALL 
 Select 'Madhya Pradesh' , N'Balaghat' , N'Waraseoni' UNION ALL 
 Select 'Madhya Pradesh' , N'Barwani' , N'Barwani' UNION ALL 
 Select 'Madhya Pradesh' , N'Barwani' , N'Newali' UNION ALL 
 Select 'Madhya Pradesh' , N'Barwani' , N'Pansemal' UNION ALL 
 Select 'Madhya Pradesh' , N'Barwani' , N'Pati' UNION ALL 
 Select 'Madhya Pradesh' , N'Barwani' , N'Rajpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Barwani' , N'Sendhawa' UNION ALL 
 Select 'Madhya Pradesh' , N'Barwani' , N'Thikri' UNION ALL 
 Select 'Madhya Pradesh' , N'Betul' , N'Amla' UNION ALL 
 Select 'Madhya Pradesh' , N'Betul' , N'Athner' UNION ALL 
 Select 'Madhya Pradesh' , N'Betul' , N'Betul' UNION ALL 
 Select 'Madhya Pradesh' , N'Betul' , N'Bhainsdehi' UNION ALL 
 Select 'Madhya Pradesh' , N'Betul' , N'Bhimpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Betul' , N'Chicholi' UNION ALL 
 Select 'Madhya Pradesh' , N'Betul' , N'Ghoradongri' UNION ALL 
 Select 'Madhya Pradesh' , N'Betul' , N'Multai' UNION ALL 
 Select 'Madhya Pradesh' , N'Betul' , N'Prabhat Pattan' UNION ALL 
 Select 'Madhya Pradesh' , N'Betul' , N'Shahpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Bhind' , N'Ater' UNION ALL 
 Select 'Madhya Pradesh' , N'Bhind' , N'Bhind' UNION ALL 
 Select 'Madhya Pradesh' , N'Bhind' , N'Gohad' UNION ALL 
 Select 'Madhya Pradesh' , N'Bhind' , N'Lahar' UNION ALL 
 Select 'Madhya Pradesh' , N'Bhind' , N'Mehgaon' UNION ALL 
 Select 'Madhya Pradesh' , N'Bhind' , N'Raon' UNION ALL 
 Select 'Madhya Pradesh' , N'Bhopal' , N'Berasia' UNION ALL 
 Select 'Madhya Pradesh' , N'Bhopal' , N'Phanda' UNION ALL 
 Select 'Madhya Pradesh' , N'Burhanpur' , N'Burhanpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Burhanpur' , N'Khaknar' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhatarpur' , N'Bada Malehara' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhatarpur' , N'Barigarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhatarpur' , N'Bijawar' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhatarpur' , N'Buxwaha' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhatarpur' , N'Chhatarpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhatarpur' , N'Lavkush Nagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhatarpur' , N'Nowgong' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhatarpur' , N'Rajnagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhindwara' , N'Amarwara' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhindwara' , N'Bichhua' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhindwara' , N'Chaurai' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhindwara' , N'Chhindwara' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhindwara' , N'Harrai' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhindwara' , N'Jamai' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhindwara' , N'Mohkhed' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhindwara' , N'Parasia' UNION ALL 
 Select 'Madhya Pradesh' , N'Chhindwara' , N'Tamia' UNION ALL 
 Select 'Madhya Pradesh' , N'Damoh' , N'Batiyagarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Damoh' , N'Damoh' UNION ALL 
 Select 'Madhya Pradesh' , N'Damoh' , N'Hatta' UNION ALL 
 Select 'Madhya Pradesh' , N'Damoh' , N'Jabera' UNION ALL 
 Select 'Madhya Pradesh' , N'Damoh' , N'Patera' UNION ALL 
 Select 'Madhya Pradesh' , N'Damoh' , N'Pathariya' UNION ALL 
 Select 'Madhya Pradesh' , N'Damoh' , N'Tendukheda' UNION ALL 
 Select 'Madhya Pradesh' , N'Datia' , N'Bhander' UNION ALL 
 Select 'Madhya Pradesh' , N'Datia' , N'Datia' UNION ALL 
 Select 'Madhya Pradesh' , N'Datia' , N'Seondha' UNION ALL 
 Select 'Madhya Pradesh' , N'Dewas' , N'Bagli' UNION ALL 
 Select 'Madhya Pradesh' , N'Dewas' , N'Dewas' UNION ALL 
 Select 'Madhya Pradesh' , N'Dewas' , N'Kannod' UNION ALL 
 Select 'Madhya Pradesh' , N'Dewas' , N'Khategaon' UNION ALL 
 Select 'Madhya Pradesh' , N'Dewas' , N'Sonkatch' UNION ALL 
 Select 'Madhya Pradesh' , N'Dewas' , N'Tonk Khurd' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Badnawar' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Bagh' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Dahi' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Dhar' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Dharampuri' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Gandhwani' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Kukshi' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Manawar' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Nalchha' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Nisarpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Sardarpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Tirla' UNION ALL 
 Select 'Madhya Pradesh' , N'Dhar' , N'Umarban' UNION ALL 
 Select 'Madhya Pradesh' , N'Dindori' , N'Amarpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Dindori' , N'Bajag' UNION ALL 
 Select 'Madhya Pradesh' , N'Dindori' , N'Dindori' UNION ALL 
 Select 'Madhya Pradesh' , N'Dindori' , N'Karanjiya' UNION ALL 
 Select 'Madhya Pradesh' , N'Dindori' , N'Mehandwani' UNION ALL 
 Select 'Madhya Pradesh' , N'Dindori' , N'Samnapur' UNION ALL 
 Select 'Madhya Pradesh' , N'Dindori' , N'Shahpura' UNION ALL 
 Select 'Madhya Pradesh' , N'Guna' , N'Aron' UNION ALL 
 Select 'Madhya Pradesh' , N'Guna' , N'Bamori' UNION ALL 
 Select 'Madhya Pradesh' , N'Guna' , N'Chanchoda' UNION ALL 
 Select 'Madhya Pradesh' , N'Guna' , N'Guna' UNION ALL 
 Select 'Madhya Pradesh' , N'Guna' , N'Raghogarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Gwalior' , N'Bhitarwar' UNION ALL 
 Select 'Madhya Pradesh' , N'Gwalior' , N'Dabra' UNION ALL 
 Select 'Madhya Pradesh' , N'Gwalior' , N'Ghatigaon' UNION ALL 
 Select 'Madhya Pradesh' , N'Gwalior' , N'Morar' UNION ALL 
 Select 'Madhya Pradesh' , N'Harda' , N'Harda' UNION ALL 
 Select 'Madhya Pradesh' , N'Harda' , N'Khirkiya' UNION ALL 
 Select 'Madhya Pradesh' , N'Harda' , N'Timarni' UNION ALL 
 Select 'Madhya Pradesh' , N'Indore' , N'Depalpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Indore' , N'Indore' UNION ALL 
 Select 'Madhya Pradesh' , N'Indore' , N'Mhow' UNION ALL 
 Select 'Madhya Pradesh' , N'Indore' , N'Sanwer' UNION ALL 
 Select 'Madhya Pradesh' , N'Jabalpur' , N'Jabalpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Jabalpur' , N'Kundam' UNION ALL 
 Select 'Madhya Pradesh' , N'Jabalpur' , N'Majhouli' UNION ALL 
 Select 'Madhya Pradesh' , N'Jabalpur' , N'Panagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Jabalpur' , N'Patan' UNION ALL 
 Select 'Madhya Pradesh' , N'Jabalpur' , N'Shahpura' UNION ALL 
 Select 'Madhya Pradesh' , N'Jabalpur' , N'Sihora' UNION ALL 
 Select 'Madhya Pradesh' , N'Jhabua' , N'Jhabua' UNION ALL 
 Select 'Madhya Pradesh' , N'Jhabua' , N'Meghnagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Jhabua' , N'Petlawad' UNION ALL 
 Select 'Madhya Pradesh' , N'Jhabua' , N'Rama' UNION ALL 
 Select 'Madhya Pradesh' , N'Jhabua' , N'Ranapur' UNION ALL 
 Select 'Madhya Pradesh' , N'Jhabua' , N'Thandla' UNION ALL 
 Select 'Madhya Pradesh' , N'Katni' , N'Badwara' UNION ALL 
 Select 'Madhya Pradesh' , N'Katni' , N'Bahoriband' UNION ALL 
 Select 'Madhya Pradesh' , N'Katni' , N'Dheemerkheda' UNION ALL 
 Select 'Madhya Pradesh' , N'Katni' , N'Katni' UNION ALL 
 Select 'Madhya Pradesh' , N'Katni' , N'Rithi' UNION ALL 
 Select 'Madhya Pradesh' , N'Katni' , N'Vijayraghavgarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Khandwa (East Nimar)' , N'Baladi' UNION ALL 
 Select 'Madhya Pradesh' , N'Khandwa (East Nimar)' , N'Chhaigaon Makhan' UNION ALL 
 Select 'Madhya Pradesh' , N'Khandwa (East Nimar)' , N'Harsud' UNION ALL 
 Select 'Madhya Pradesh' , N'Khandwa (East Nimar)' , N'Khalwa' UNION ALL 
 Select 'Madhya Pradesh' , N'Khandwa (East Nimar)' , N'Khandwa' UNION ALL 
 Select 'Madhya Pradesh' , N'Khandwa (East Nimar)' , N'Pandhana' UNION ALL 
 Select 'Madhya Pradesh' , N'Khandwa (East Nimar)' , N'Punasa' UNION ALL 
 Select 'Madhya Pradesh' , N'Khargone (West Nimar)' , N'Barwah' UNION ALL 
 Select 'Madhya Pradesh' , N'Khargone (West Nimar)' , N'Bhagvanpura' UNION ALL 
 Select 'Madhya Pradesh' , N'Khargone (West Nimar)' , N'Bhikangaon' UNION ALL 
 Select 'Madhya Pradesh' , N'Khargone (West Nimar)' , N'Gogawan' UNION ALL 
 Select 'Madhya Pradesh' , N'Khargone (West Nimar)' , N'Kasrawad' UNION ALL 
 Select 'Madhya Pradesh' , N'Khargone (West Nimar)' , N'Khargone' UNION ALL 
 Select 'Madhya Pradesh' , N'Khargone (West Nimar)' , N'Maheshwar' UNION ALL 
 Select 'Madhya Pradesh' , N'Khargone (West Nimar)' , N'Segaon' UNION ALL 
 Select 'Madhya Pradesh' , N'Khargone (West Nimar)' , N'Ziranya' UNION ALL 
 Select 'Madhya Pradesh' , N'Maihar' , N'Amarpatan' UNION ALL 
 Select 'Madhya Pradesh' , N'Maihar' , N'Maihar' UNION ALL 
 Select 'Madhya Pradesh' , N'Maihar' , N'Ramnagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandla' , N'Bichhiya' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandla' , N'Bijadandi' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandla' , N'Ghughri' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandla' , N'Mandla' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandla' , N'Mawai' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandla' , N'Mohgaon' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandla' , N'Nainpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandla' , N'Narayanganj' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandla' , N'Niwas' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandsaur' , N'Bhanpura' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandsaur' , N'Garoth' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandsaur' , N'Malhargarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandsaur' , N'Mandsaur' UNION ALL 
 Select 'Madhya Pradesh' , N'Mandsaur' , N'Sitamau' UNION ALL 
 Select 'Madhya Pradesh' , N'MAUGANJ' , N'Hanumana' UNION ALL 
 Select 'Madhya Pradesh' , N'MAUGANJ' , N'Mauganj' UNION ALL 
 Select 'Madhya Pradesh' , N'MAUGANJ' , N'Naigarhi' UNION ALL 
 Select 'Madhya Pradesh' , N'Morena' , N'Ambah' UNION ALL 
 Select 'Madhya Pradesh' , N'Morena' , N'Joura' UNION ALL 
 Select 'Madhya Pradesh' , N'Morena' , N'Kailaras' UNION ALL 
 Select 'Madhya Pradesh' , N'Morena' , N'Morena' UNION ALL 
 Select 'Madhya Pradesh' , N'Morena' , N'Pahadgarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Morena' , N'Porsa' UNION ALL 
 Select 'Madhya Pradesh' , N'Morena' , N'Sabalgarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Narmadapuram' , N'Bankhedi' UNION ALL 
 Select 'Madhya Pradesh' , N'Narmadapuram' , N'Kesla' UNION ALL 
 Select 'Madhya Pradesh' , N'Narmadapuram' , N'Makhan Nagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Narmadapuram' , N'Narmadapuram' UNION ALL 
 Select 'Madhya Pradesh' , N'Narmadapuram' , N'Pipariya' UNION ALL 
 Select 'Madhya Pradesh' , N'Narmadapuram' , N'Seoni Malwa' UNION ALL 
 Select 'Madhya Pradesh' , N'Narmadapuram' , N'Sohagpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Narsimhapur' , N'Babai Chichali' UNION ALL 
 Select 'Madhya Pradesh' , N'Narsimhapur' , N'Chawarpatha' UNION ALL 
 Select 'Madhya Pradesh' , N'Narsimhapur' , N'Gotegaon' UNION ALL 
 Select 'Madhya Pradesh' , N'Narsimhapur' , N'Kareli' UNION ALL 
 Select 'Madhya Pradesh' , N'Narsimhapur' , N'Narsimhapur' UNION ALL 
 Select 'Madhya Pradesh' , N'Narsimhapur' , N'Sainkheda' UNION ALL 
 Select 'Madhya Pradesh' , N'Neemuch' , N'Jawad' UNION ALL 
 Select 'Madhya Pradesh' , N'Neemuch' , N'Manasa' UNION ALL 
 Select 'Madhya Pradesh' , N'Neemuch' , N'Neemuch' UNION ALL 
 Select 'Madhya Pradesh' , N'Niwari' , N'Niwari' UNION ALL 
 Select 'Madhya Pradesh' , N'Niwari' , N'Prithvipur' UNION ALL 
 Select 'Madhya Pradesh' , N'Pandhurna' , N'Pandhurna' UNION ALL 
 Select 'Madhya Pradesh' , N'Pandhurna' , N'Sausar' UNION ALL 
 Select 'Madhya Pradesh' , N'Panna' , N'Ajaigarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Panna' , N'Gunour' UNION ALL 
 Select 'Madhya Pradesh' , N'Panna' , N'Panna' UNION ALL 
 Select 'Madhya Pradesh' , N'Panna' , N'Pawai' UNION ALL 
 Select 'Madhya Pradesh' , N'Panna' , N'Shahnagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Raisen' , N'Badi' UNION ALL 
 Select 'Madhya Pradesh' , N'Raisen' , N'Begamganj' UNION ALL 
 Select 'Madhya Pradesh' , N'Raisen' , N'Gairatganj' UNION ALL 
 Select 'Madhya Pradesh' , N'Raisen' , N'Obaidallaganj' UNION ALL 
 Select 'Madhya Pradesh' , N'Raisen' , N'Sanchi' UNION ALL 
 Select 'Madhya Pradesh' , N'Raisen' , N'Silwani' UNION ALL 
 Select 'Madhya Pradesh' , N'Raisen' , N'Udaipura' UNION ALL 
 Select 'Madhya Pradesh' , N'Rajgarh' , N'Biaora' UNION ALL 
 Select 'Madhya Pradesh' , N'Rajgarh' , N'Khilchipur' UNION ALL 
 Select 'Madhya Pradesh' , N'Rajgarh' , N'Narsinghgarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Rajgarh' , N'Rajgarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Rajgarh' , N'Sarangpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Rajgarh' , N'Zirapur' UNION ALL 
 Select 'Madhya Pradesh' , N'Ratlam' , N'Alot' UNION ALL 
 Select 'Madhya Pradesh' , N'Ratlam' , N'Bajna' UNION ALL 
 Select 'Madhya Pradesh' , N'Ratlam' , N'Jaora' UNION ALL 
 Select 'Madhya Pradesh' , N'Ratlam' , N'Piploda' UNION ALL 
 Select 'Madhya Pradesh' , N'Ratlam' , N'Ratlam' UNION ALL 
 Select 'Madhya Pradesh' , N'Ratlam' , N'Sailana' UNION ALL 
 Select 'Madhya Pradesh' , N'Rewa' , N'Gangev' UNION ALL 
 Select 'Madhya Pradesh' , N'Rewa' , N'Jawa' UNION ALL 
 Select 'Madhya Pradesh' , N'Rewa' , N'Raipur Karchuliyan' UNION ALL 
 Select 'Madhya Pradesh' , N'Rewa' , N'Rewa' UNION ALL 
 Select 'Madhya Pradesh' , N'Rewa' , N'Sirmour' UNION ALL 
 Select 'Madhya Pradesh' , N'Rewa' , N'Teonthar' UNION ALL 
 Select 'Madhya Pradesh' , N'Sagar' , N'Banda' UNION ALL 
 Select 'Madhya Pradesh' , N'Sagar' , N'Bina' UNION ALL 
 Select 'Madhya Pradesh' , N'Sagar' , N'Deori' UNION ALL 
 Select 'Madhya Pradesh' , N'Sagar' , N'Jaisinagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Sagar' , N'Kesli' UNION ALL 
 Select 'Madhya Pradesh' , N'Sagar' , N'Khurai' UNION ALL 
 Select 'Madhya Pradesh' , N'Sagar' , N'Malthone' UNION ALL 
 Select 'Madhya Pradesh' , N'Sagar' , N'Rahatgarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Sagar' , N'Rehli' UNION ALL 
 Select 'Madhya Pradesh' , N'Sagar' , N'Sagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Sagar' , N'Shahgarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Satna' , N'Majhgawan' UNION ALL 
 Select 'Madhya Pradesh' , N'Satna' , N'Nagod' UNION ALL 
 Select 'Madhya Pradesh' , N'Satna' , N'Rampur Baghelan' UNION ALL 
 Select 'Madhya Pradesh' , N'Satna' , N'Sohawal' UNION ALL 
 Select 'Madhya Pradesh' , N'Satna' , N'Unchahara' UNION ALL 
 Select 'Madhya Pradesh' , N'Sehore' , N'Ashta' UNION ALL 
 Select 'Madhya Pradesh' , N'Sehore' , N'Budni' UNION ALL 
 Select 'Madhya Pradesh' , N'Sehore' , N'Ichhawar' UNION ALL 
 Select 'Madhya Pradesh' , N'Sehore' , N'Nasrullaganj' UNION ALL 
 Select 'Madhya Pradesh' , N'Sehore' , N'Sehore' UNION ALL 
 Select 'Madhya Pradesh' , N'Seoni' , N'Barghat' UNION ALL 
 Select 'Madhya Pradesh' , N'Seoni' , N'Chhapara' UNION ALL 
 Select 'Madhya Pradesh' , N'Seoni' , N'Dhanaura' UNION ALL 
 Select 'Madhya Pradesh' , N'Seoni' , N'Kahnapas(Ghansaur)' UNION ALL 
 Select 'Madhya Pradesh' , N'Seoni' , N'Keolari' UNION ALL 
 Select 'Madhya Pradesh' , N'Seoni' , N'Kurai' UNION ALL 
 Select 'Madhya Pradesh' , N'Seoni' , N'Lakhnadon' UNION ALL 
 Select 'Madhya Pradesh' , N'Seoni' , N'Seoni' UNION ALL 
 Select 'Madhya Pradesh' , N'Shahdol' , N'Beohari' UNION ALL 
 Select 'Madhya Pradesh' , N'Shahdol' , N'Burhar' UNION ALL 
 Select 'Madhya Pradesh' , N'Shahdol' , N'Gohparu' UNION ALL 
 Select 'Madhya Pradesh' , N'Shahdol' , N'Jaisinghnagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Shahdol' , N'Sohagpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Shajapur' , N'Kalapipal' UNION ALL 
 Select 'Madhya Pradesh' , N'Shajapur' , N'Moman Badodia' UNION ALL 
 Select 'Madhya Pradesh' , N'Shajapur' , N'Shajapur' UNION ALL 
 Select 'Madhya Pradesh' , N'Shajapur' , N'Shujalpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Sheopur' , N'Karahal' UNION ALL 
 Select 'Madhya Pradesh' , N'Sheopur' , N'Sheopur' UNION ALL 
 Select 'Madhya Pradesh' , N'Sheopur' , N'Vijaypur' UNION ALL 
 Select 'Madhya Pradesh' , N'Shivpuri' , N'Badarwas' UNION ALL 
 Select 'Madhya Pradesh' , N'Shivpuri' , N'Karera' UNION ALL 
 Select 'Madhya Pradesh' , N'Shivpuri' , N'Khaniadhana' UNION ALL 
 Select 'Madhya Pradesh' , N'Shivpuri' , N'Kolaras' UNION ALL 
 Select 'Madhya Pradesh' , N'Shivpuri' , N'Narwar' UNION ALL 
 Select 'Madhya Pradesh' , N'Shivpuri' , N'Pichhore' UNION ALL 
 Select 'Madhya Pradesh' , N'Shivpuri' , N'Pohri' UNION ALL 
 Select 'Madhya Pradesh' , N'Shivpuri' , N'Shivpuri' UNION ALL 
 Select 'Madhya Pradesh' , N'Sidhi' , N'Kusmi' UNION ALL 
 Select 'Madhya Pradesh' , N'Sidhi' , N'Majhauli' UNION ALL 
 Select 'Madhya Pradesh' , N'Sidhi' , N'Rampur Naikin' UNION ALL 
 Select 'Madhya Pradesh' , N'Sidhi' , N'Sidhi' UNION ALL 
 Select 'Madhya Pradesh' , N'Sidhi' , N'Sihawal' UNION ALL 
 Select 'Madhya Pradesh' , N'Singrauli' , N'Baidhan' UNION ALL 
 Select 'Madhya Pradesh' , N'Singrauli' , N'Chitrangi' UNION ALL 
 Select 'Madhya Pradesh' , N'Singrauli' , N'Devsar' UNION ALL 
 Select 'Madhya Pradesh' , N'Tikamgarh' , N'Baldeogarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Tikamgarh' , N'Jatara' UNION ALL 
 Select 'Madhya Pradesh' , N'Tikamgarh' , N'Palera' UNION ALL 
 Select 'Madhya Pradesh' , N'Tikamgarh' , N'Tikamgarh' UNION ALL 
 Select 'Madhya Pradesh' , N'Ujjain' , N'Badnagar' UNION ALL 
 Select 'Madhya Pradesh' , N'Ujjain' , N'Ghatiya' UNION ALL 
 Select 'Madhya Pradesh' , N'Ujjain' , N'Khacharod' UNION ALL 
 Select 'Madhya Pradesh' , N'Ujjain' , N'Mahidpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Ujjain' , N'Tarana' UNION ALL 
 Select 'Madhya Pradesh' , N'Ujjain' , N'Ujjain' UNION ALL 
 Select 'Madhya Pradesh' , N'Umaria' , N'Karkeli' UNION ALL 
 Select 'Madhya Pradesh' , N'Umaria' , N'Manpur' UNION ALL 
 Select 'Madhya Pradesh' , N'Umaria' , N'Pali' UNION ALL 
 Select 'Madhya Pradesh' , N'Vidisha' , N'Basoda' UNION ALL 
 Select 'Madhya Pradesh' , N'Vidisha' , N'Gyaraspur' UNION ALL 
 Select 'Madhya Pradesh' , N'Vidisha' , N'Kurwai' UNION ALL 
 Select 'Madhya Pradesh' , N'Vidisha' , N'Lateri' UNION ALL 
 Select 'Madhya Pradesh' , N'Vidisha' , N'Nateran' UNION ALL 
 Select 'Madhya Pradesh' , N'Vidisha' , N'Sironj' UNION ALL 
 Select 'Madhya Pradesh' , N'Vidisha' , N'Vidisha'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Maharashtra' , N'Ahmednagar' , N'Akole' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Jamkhed' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Karjat' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Kopargaon' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Nagar' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Nevasa' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Parner' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Pathardi' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Rahata' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Rahuri' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Sangamner' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Shevgaon' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Shrigonda' UNION ALL 
 Select 'Maharashtra' , N'Ahmednagar' , N'Shrirampur' UNION ALL 
 Select 'Maharashtra' , N'Akola' , N'Akola' UNION ALL 
 Select 'Maharashtra' , N'Akola' , N'Akot' UNION ALL 
 Select 'Maharashtra' , N'Akola' , N'Balapur' UNION ALL 
 Select 'Maharashtra' , N'Akola' , N'Barshitakli' UNION ALL 
 Select 'Maharashtra' , N'Akola' , N'Murtijapur' UNION ALL 
 Select 'Maharashtra' , N'Akola' , N'Patur' UNION ALL 
 Select 'Maharashtra' , N'Akola' , N'Telhara' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Achalpur' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Amravati' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Anjangaon S' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Bhatkuli' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Chandur Bz' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Chandur Ril' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Chikhaldara' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Daryapur' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Dhamangaon Ril' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Dharni' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Morshi' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Nandgaon Kh' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Tiwsa' UNION ALL 
 Select 'Maharashtra' , N'Amravati' , N'Warud' UNION ALL 
 Select 'Maharashtra' , N'Beed' , N'Ambajogai' UNION ALL 
 Select 'Maharashtra' , N'Beed' , N'Ashti' UNION ALL 
 Select 'Maharashtra' , N'Beed' , N'Beed' UNION ALL 
 Select 'Maharashtra' , N'Beed' , N'Dharur' UNION ALL 
 Select 'Maharashtra' , N'Beed' , N'Georai' UNION ALL 
 Select 'Maharashtra' , N'Beed' , N'Kaij' UNION ALL 
 Select 'Maharashtra' , N'Beed' , N'Majalgaon' UNION ALL 
 Select 'Maharashtra' , N'Beed' , N'Parali V .' UNION ALL 
 Select 'Maharashtra' , N'Beed' , N'Patoda' UNION ALL 
 Select 'Maharashtra' , N'Beed' , N'Shirur ( Ka )' UNION ALL 
 Select 'Maharashtra' , N'Beed' , N'Wadwani' UNION ALL 
 Select 'Maharashtra' , N'Bhandara' , N'Bhandara' UNION ALL 
 Select 'Maharashtra' , N'Bhandara' , N'Lakhandur' UNION ALL 
 Select 'Maharashtra' , N'Bhandara' , N'Lakhani' UNION ALL 
 Select 'Maharashtra' , N'Bhandara' , N'Mohadi' UNION ALL 
 Select 'Maharashtra' , N'Bhandara' , N'Pauni' UNION ALL 
 Select 'Maharashtra' , N'Bhandara' , N'Sakoli' UNION ALL 
 Select 'Maharashtra' , N'Bhandara' , N'Tumsar' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Buldana' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Chikhli' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'D. Raja' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Jalgaonjamod' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Khamgaon' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Lonar' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Malkapur' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Mehkar' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Motala' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Nandura' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Sangrampur' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Shegaon' UNION ALL 
 Select 'Maharashtra' , N'Buldhana' , N'Sindkhedraja' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Ballarpur' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Bhadrawati' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Brahmapuri' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Chandrapur' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Chimur' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Gondpipri' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Jiwati' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Korpana' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Mul' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Nagbhid' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Pombhurna' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Rajura' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Saoli' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Sindewahi' UNION ALL 
 Select 'Maharashtra' , N'Chandrapur' , N'Warora' UNION ALL 
 Select 'Maharashtra' , N'Chhatrapati Sambhajinagar' , N'Aurangabad' UNION ALL 
 Select 'Maharashtra' , N'Chhatrapati Sambhajinagar' , N'Gangapur' UNION ALL 
 Select 'Maharashtra' , N'Chhatrapati Sambhajinagar' , N'Kanand' UNION ALL 
 Select 'Maharashtra' , N'Chhatrapati Sambhajinagar' , N'Khultabad' UNION ALL 
 Select 'Maharashtra' , N'Chhatrapati Sambhajinagar' , N'Paithan' UNION ALL 
 Select 'Maharashtra' , N'Chhatrapati Sambhajinagar' , N'Phulambri' UNION ALL 
 Select 'Maharashtra' , N'Chhatrapati Sambhajinagar' , N'Sillod' UNION ALL 
 Select 'Maharashtra' , N'Chhatrapati Sambhajinagar' , N'Soegaon' UNION ALL 
 Select 'Maharashtra' , N'Chhatrapati Sambhajinagar' , N'Vaijapur' UNION ALL 
 Select 'Maharashtra' , N'Dharashiv' , N'Bhoom' UNION ALL 
 Select 'Maharashtra' , N'Dharashiv' , N'Kalamb' UNION ALL 
 Select 'Maharashtra' , N'Dharashiv' , N'Lohara' UNION ALL 
 Select 'Maharashtra' , N'Dharashiv' , N'Omerga' UNION ALL 
 Select 'Maharashtra' , N'Dharashiv' , N'Osmanabad' UNION ALL 
 Select 'Maharashtra' , N'Dharashiv' , N'Paranda' UNION ALL 
 Select 'Maharashtra' , N'Dharashiv' , N'Tuljapur' UNION ALL 
 Select 'Maharashtra' , N'Dharashiv' , N'Washi' UNION ALL 
 Select 'Maharashtra' , N'Dhule' , N'Dhule' UNION ALL 
 Select 'Maharashtra' , N'Dhule' , N'Sakri' UNION ALL 
 Select 'Maharashtra' , N'Dhule' , N'Shindkhede' UNION ALL 
 Select 'Maharashtra' , N'Dhule' , N'Shirpur' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Aheri' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Armori' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Bhamaragad' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Chamorshi' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Desaiganj (Wadsa)' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Dhanora' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Etapalli' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Gadchiroli' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Korchi' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Kurkheda' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Mulchera' UNION ALL 
 Select 'Maharashtra' , N'Gadchiroli' , N'Sironcha' UNION ALL 
 Select 'Maharashtra' , N'Gondia' , N'Amgaon' UNION ALL 
 Select 'Maharashtra' , N'Gondia' , N'Arjuni Morgaon' UNION ALL 
 Select 'Maharashtra' , N'Gondia' , N'Deori' UNION ALL 
 Select 'Maharashtra' , N'Gondia' , N'Gondia' UNION ALL 
 Select 'Maharashtra' , N'Gondia' , N'Goregaon' UNION ALL 
 Select 'Maharashtra' , N'Gondia' , N'Sadak Arjuni' UNION ALL 
 Select 'Maharashtra' , N'Gondia' , N'Salekasa' UNION ALL 
 Select 'Maharashtra' , N'Gondia' , N'Tirora' UNION ALL 
 Select 'Maharashtra' , N'Hingoli' , N'Aundha Nagnath' UNION ALL 
 Select 'Maharashtra' , N'Hingoli' , N'Basmat' UNION ALL 
 Select 'Maharashtra' , N'Hingoli' , N'Hingoli' UNION ALL 
 Select 'Maharashtra' , N'Hingoli' , N'Kalamnuri' UNION ALL 
 Select 'Maharashtra' , N'Hingoli' , N'Sengaon' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Amalner' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Bhadgaon' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Bhusawal' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Bodwad' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Chalisgaon' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Chopda' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Dharangaon' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Erandol' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Jalgaon' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Jamner' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Muktainagar' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Pachora' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Parola' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Raver' UNION ALL 
 Select 'Maharashtra' , N'Jalgaon' , N'Yawal' UNION ALL 
 Select 'Maharashtra' , N'Jalna' , N'Ambad' UNION ALL 
 Select 'Maharashtra' , N'Jalna' , N'Badnapur' UNION ALL 
 Select 'Maharashtra' , N'Jalna' , N'Bhokardan' UNION ALL 
 Select 'Maharashtra' , N'Jalna' , N'Ghansawangi' UNION ALL 
 Select 'Maharashtra' , N'Jalna' , N'Jafrabad' UNION ALL 
 Select 'Maharashtra' , N'Jalna' , N'Jalna' UNION ALL 
 Select 'Maharashtra' , N'Jalna' , N'Mantha' UNION ALL 
 Select 'Maharashtra' , N'Jalna' , N'Partur' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Ajara' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Bhudargad' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Chandgad' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Gadhinglaj' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Gagan Bavada' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Hatkanangale' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Kagal' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Karveer' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Panhala' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Radhanagari' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Shahuwadi' UNION ALL 
 Select 'Maharashtra' , N'Kolhapur' , N'Shirol' UNION ALL 
 Select 'Maharashtra' , N'Latur' , N'Ahemadpur' UNION ALL 
 Select 'Maharashtra' , N'Latur' , N'Ausa' UNION ALL 
 Select 'Maharashtra' , N'Latur' , N'Chakur' UNION ALL 
 Select 'Maharashtra' , N'Latur' , N'Deoni' UNION ALL 
 Select 'Maharashtra' , N'Latur' , N'Jalkot' UNION ALL 
 Select 'Maharashtra' , N'Latur' , N'Latur' UNION ALL 
 Select 'Maharashtra' , N'Latur' , N'Nilanga' UNION ALL 
 Select 'Maharashtra' , N'Latur' , N'Renapur' UNION ALL 
 Select 'Maharashtra' , N'Latur' , N'Shirur Anantpal' UNION ALL 
 Select 'Maharashtra' , N'Latur' , N'Udgir' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Bhivapur' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Hingna' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Kalmeshwar' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Kamptee' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Katol' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Kuhi' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Mouda' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Nagpur' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Narkhed' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Parseoni' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Ramtek' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Saoner' UNION ALL 
 Select 'Maharashtra' , N'Nagpur' , N'Umred' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Ardhapur' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Bhokar' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Biloli' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Deglur' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Dharmabad' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Hadgaon' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Himayatnagar' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Kandhar' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Kinwat' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Loha' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Mahur' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Modkhed' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Mokhed' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Naigaon (Kh)' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Nanded' UNION ALL 
 Select 'Maharashtra' , N'Nanded' , N'Umri' UNION ALL 
 Select 'Maharashtra' , N'Nandurbar' , N'Akarani' UNION ALL 
 Select 'Maharashtra' , N'Nandurbar' , N'Akkalkuwa' UNION ALL 
 Select 'Maharashtra' , N'Nandurbar' , N'Nandurbar' UNION ALL 
 Select 'Maharashtra' , N'Nandurbar' , N'Navapur' UNION ALL 
 Select 'Maharashtra' , N'Nandurbar' , N'Shahada' UNION ALL 
 Select 'Maharashtra' , N'Nandurbar' , N'Taloda' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Baglan' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Chandwad' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Deola' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Dindori' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Igatpuri' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Kalwan' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Malegaon' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Nandgaon' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Nashik' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Niphad' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Peth' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Sinnar' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Surgana' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Trimbak' UNION ALL 
 Select 'Maharashtra' , N'Nashik' , N'Yeola' UNION ALL 
 Select 'Maharashtra' , N'Palghar' , N'Dahanu' UNION ALL 
 Select 'Maharashtra' , N'Palghar' , N'Jawhar' UNION ALL 
 Select 'Maharashtra' , N'Palghar' , N'Mokhada' UNION ALL 
 Select 'Maharashtra' , N'Palghar' , N'Palghar' UNION ALL 
 Select 'Maharashtra' , N'Palghar' , N'Talasari' UNION ALL 
 Select 'Maharashtra' , N'Palghar' , N'Vasai' UNION ALL 
 Select 'Maharashtra' , N'Palghar' , N'Vikramgad' UNION ALL 
 Select 'Maharashtra' , N'Palghar' , N'Wada' UNION ALL 
 Select 'Maharashtra' , N'Parbhani' , N'Gangakhed' UNION ALL 
 Select 'Maharashtra' , N'Parbhani' , N'Jintur' UNION ALL 
 Select 'Maharashtra' , N'Parbhani' , N'Manwat' UNION ALL 
 Select 'Maharashtra' , N'Parbhani' , N'Palam' UNION ALL 
 Select 'Maharashtra' , N'Parbhani' , N'Parbhani' UNION ALL 
 Select 'Maharashtra' , N'Parbhani' , N'Pathri' UNION ALL 
 Select 'Maharashtra' , N'Parbhani' , N'Purna' UNION ALL 
 Select 'Maharashtra' , N'Parbhani' , N'Sailu' UNION ALL 
 Select 'Maharashtra' , N'Parbhani' , N'Sonpeth' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Ambegaon' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Baramati' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Bhor' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Daund' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Haveli' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Indapur' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Junnar' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Khed' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Maval' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Mulshi' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Pune City' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Purandar' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Shirur' UNION ALL 
 Select 'Maharashtra' , N'Pune' , N'Velhe' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Alibag' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Karjat' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Khalapur' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Mahad' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Mangaon' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Mhasala' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Murud' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Panvel' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Pen' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Poladpur' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Roha' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Shrivardhan' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Sudhagad' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Tala' UNION ALL 
 Select 'Maharashtra' , N'Raigad' , N'Uran' UNION ALL 
 Select 'Maharashtra' , N'Ratnagiri' , N'Chipalun' UNION ALL 
 Select 'Maharashtra' , N'Ratnagiri' , N'Dapoli' UNION ALL 
 Select 'Maharashtra' , N'Ratnagiri' , N'Guhagar' UNION ALL 
 Select 'Maharashtra' , N'Ratnagiri' , N'Khed' UNION ALL 
 Select 'Maharashtra' , N'Ratnagiri' , N'Lanja' UNION ALL 
 Select 'Maharashtra' , N'Ratnagiri' , N'Mandangad' UNION ALL 
 Select 'Maharashtra' , N'Ratnagiri' , N'Rajapur' UNION ALL 
 Select 'Maharashtra' , N'Ratnagiri' , N'Ratnagiri' UNION ALL 
 Select 'Maharashtra' , N'Ratnagiri' , N'Sangmeshwar' UNION ALL 
 Select 'Maharashtra' , N'Sangli' , N'Atpadi' UNION ALL 
 Select 'Maharashtra' , N'Sangli' , N'Jath' UNION ALL 
 Select 'Maharashtra' , N'Sangli' , N'Kadegaon' UNION ALL 
 Select 'Maharashtra' , N'Sangli' , N'Kavathemahankal' UNION ALL 
 Select 'Maharashtra' , N'Sangli' , N'Khanapur-Vita' UNION ALL 
 Select 'Maharashtra' , N'Sangli' , N'Miraj' UNION ALL 
 Select 'Maharashtra' , N'Sangli' , N'Palus' UNION ALL 
 Select 'Maharashtra' , N'Sangli' , N'Shirala' UNION ALL 
 Select 'Maharashtra' , N'Sangli' , N'Tasgaon' UNION ALL 
 Select 'Maharashtra' , N'Sangli' , N'Valva-Islampur' UNION ALL 
 Select 'Maharashtra' , N'Satara' , N'Jawali' UNION ALL 
 Select 'Maharashtra' , N'Satara' , N'Karad' UNION ALL 
 Select 'Maharashtra' , N'Satara' , N'Khandala' UNION ALL 
 Select 'Maharashtra' , N'Satara' , N'Khatav' UNION ALL 
 Select 'Maharashtra' , N'Satara' , N'Koregaon' UNION ALL 
 Select 'Maharashtra' , N'Satara' , N'Mahabaleshwar' UNION ALL 
 Select 'Maharashtra' , N'Satara' , N'Man' UNION ALL 
 Select 'Maharashtra' , N'Satara' , N'Patan' UNION ALL 
 Select 'Maharashtra' , N'Satara' , N'Phaltan' UNION ALL 
 Select 'Maharashtra' , N'Satara' , N'Satara' UNION ALL 
 Select 'Maharashtra' , N'Satara' , N'Wai' UNION ALL 
 Select 'Maharashtra' , N'Sindhudurg' , N'Deogad' UNION ALL 
 Select 'Maharashtra' , N'Sindhudurg' , N'Dodamarg' UNION ALL 
 Select 'Maharashtra' , N'Sindhudurg' , N'Kankavali' UNION ALL 
 Select 'Maharashtra' , N'Sindhudurg' , N'Kudal' UNION ALL 
 Select 'Maharashtra' , N'Sindhudurg' , N'Malvan' UNION ALL 
 Select 'Maharashtra' , N'Sindhudurg' , N'Sawantwadi' UNION ALL 
 Select 'Maharashtra' , N'Sindhudurg' , N'Vaibhavawadi' UNION ALL 
 Select 'Maharashtra' , N'Sindhudurg' , N'Vengurla' UNION ALL 
 Select 'Maharashtra' , N'Solapur' , N'Akkalkot' UNION ALL 
 Select 'Maharashtra' , N'Solapur' , N'Barshi' UNION ALL 
 Select 'Maharashtra' , N'Solapur' , N'Karmala' UNION ALL 
 Select 'Maharashtra' , N'Solapur' , N'Madha' UNION ALL 
 Select 'Maharashtra' , N'Solapur' , N'Malshiras' UNION ALL 
 Select 'Maharashtra' , N'Solapur' , N'Mangalvedhe' UNION ALL 
 Select 'Maharashtra' , N'Solapur' , N'Mohol' UNION ALL 
 Select 'Maharashtra' , N'Solapur' , N'Pandharpur' UNION ALL 
 Select 'Maharashtra' , N'Solapur' , N'Sangola' UNION ALL 
 Select 'Maharashtra' , N'Solapur' , N'Solapur North' UNION ALL 
 Select 'Maharashtra' , N'Solapur' , N'South Solapur' UNION ALL 
 Select 'Maharashtra' , N'Thane' , N'Ambernath' UNION ALL 
 Select 'Maharashtra' , N'Thane' , N'Bhiwandi' UNION ALL 
 Select 'Maharashtra' , N'Thane' , N'Kalyan' UNION ALL 
 Select 'Maharashtra' , N'Thane' , N'Murbad' UNION ALL 
 Select 'Maharashtra' , N'Thane' , N'Shahapur' UNION ALL 
 Select 'Maharashtra' , N'Wardha' , N'Arvi' UNION ALL 
 Select 'Maharashtra' , N'Wardha' , N'Ashti' UNION ALL 
 Select 'Maharashtra' , N'Wardha' , N'Deoli' UNION ALL 
 Select 'Maharashtra' , N'Wardha' , N'Hinganghat' UNION ALL 
 Select 'Maharashtra' , N'Wardha' , N'Karanja' UNION ALL 
 Select 'Maharashtra' , N'Wardha' , N'Samudrapur' UNION ALL 
 Select 'Maharashtra' , N'Wardha' , N'Seloo' UNION ALL 
 Select 'Maharashtra' , N'Wardha' , N'Wardha' UNION ALL 
 Select 'Maharashtra' , N'Washim' , N'Karanja' UNION ALL 
 Select 'Maharashtra' , N'Washim' , N'Malegaon' UNION ALL 
 Select 'Maharashtra' , N'Washim' , N'Mangrulpir' UNION ALL 
 Select 'Maharashtra' , N'Washim' , N'Manora' UNION ALL 
 Select 'Maharashtra' , N'Washim' , N'Risod' UNION ALL 
 Select 'Maharashtra' , N'Washim' , N'Washim' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Arni' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Babhulgaon' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Darwha' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Digras' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Ghatanji' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Kalamb' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Kelapur' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Mahagaon' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Maregaon' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Ner' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Pusad' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Ralegaon' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Umarkhed' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Wani' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Yavatmal' UNION ALL 
 Select 'Maharashtra' , N'Yavatmal' , N'Zari Jamni'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Manipur' , N'Bishnupur' , N'Bishnupur' UNION ALL 
 Select 'Manipur' , N'Bishnupur' , N'Moirang' UNION ALL 
 Select 'Manipur' , N'Bishnupur' , N'Nambol' UNION ALL 
 Select 'Manipur' , N'Chandel' , N'Chakpikarong' UNION ALL 
 Select 'Manipur' , N'Chandel' , N'Chandel' UNION ALL 
 Select 'Manipur' , N'Chandel' , N'Khangbarol' UNION ALL 
 Select 'Manipur' , N'Chandel' , N'Khengjoy' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Henglep' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Kangvai' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Lamka' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Lamka South' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Lanva' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Mualnuam' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Saikot' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Samulamlan' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Sangaikot' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Singngat' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Suangdoh' UNION ALL 
 Select 'Manipur' , N'Churachandpur' , N'Tuibong' UNION ALL 
 Select 'Manipur' , N'Imphal East' , N'Heingang CD Block' UNION ALL 
 Select 'Manipur' , N'Imphal East' , N'Keirao CD Block' UNION ALL 
 Select 'Manipur' , N'Imphal East' , N'Kshetrigao CD Block' UNION ALL 
 Select 'Manipur' , N'Imphal East' , N'Sawombung CD Block' UNION ALL 
 Select 'Manipur' , N'Imphal West' , N'Haorangsabal' UNION ALL 
 Select 'Manipur' , N'Imphal West' , N'Hiyangthang' UNION ALL 
 Select 'Manipur' , N'Imphal West' , N'Patsoi' UNION ALL 
 Select 'Manipur' , N'Imphal West' , N'Wangoi' UNION ALL 
 Select 'Manipur' , N'Jiribam' , N'Borobekra CD Block' UNION ALL 
 Select 'Manipur' , N'Jiribam' , N'Jiribam C D Block' UNION ALL 
 Select 'Manipur' , N'Kakching' , N'Kakching' UNION ALL 
 Select 'Manipur' , N'Kakching' , N'Langmeidong' UNION ALL 
 Select 'Manipur' , N'Kamjong' , N'Kamjong' UNION ALL 
 Select 'Manipur' , N'Kamjong' , N'Kasom Khullen' UNION ALL 
 Select 'Manipur' , N'Kamjong' , N'Phungyar' UNION ALL 
 Select 'Manipur' , N'Kamjong' , N'Sahamphung Td Block' UNION ALL 
 Select 'Manipur' , N'Kangpokpi' , N'Bungte Chiru' UNION ALL 
 Select 'Manipur' , N'Kangpokpi' , N'Champhai' UNION ALL 
 Select 'Manipur' , N'Kangpokpi' , N'Island' UNION ALL 
 Select 'Manipur' , N'Kangpokpi' , N'Kangchup Geljang' UNION ALL 
 Select 'Manipur' , N'Kangpokpi' , N'Kangpokpi' UNION ALL 
 Select 'Manipur' , N'Kangpokpi' , N'Lhungtin' UNION ALL 
 Select 'Manipur' , N'Kangpokpi' , N'Saikul' UNION ALL 
 Select 'Manipur' , N'Kangpokpi' , N'Saitu Gamphazol' UNION ALL 
 Select 'Manipur' , N'Kangpokpi' , N'T Vaichong' UNION ALL 
 Select 'Manipur' , N'Noney' , N'Haochong' UNION ALL 
 Select 'Manipur' , N'Noney' , N'Khoupum' UNION ALL 
 Select 'Manipur' , N'Noney' , N'Longmai' UNION ALL 
 Select 'Manipur' , N'Noney' , N'Nungba' UNION ALL 
 Select 'Manipur' , N'Pherzawl' , N'Thanlon' UNION ALL 
 Select 'Manipur' , N'Pherzawl' , N'Tipaimukh' UNION ALL 
 Select 'Manipur' , N'Pherzawl' , N'Vangai Range' UNION ALL 
 Select 'Manipur' , N'Senapati' , N'Paomata' UNION ALL 
 Select 'Manipur' , N'Senapati' , N'Phaibung Khullen' UNION ALL 
 Select 'Manipur' , N'Senapati' , N'Purul' UNION ALL 
 Select 'Manipur' , N'Senapati' , N'Song Song' UNION ALL 
 Select 'Manipur' , N'Senapati' , N'Tadubi' UNION ALL 
 Select 'Manipur' , N'Senapati' , N'Willong' UNION ALL 
 Select 'Manipur' , N'Tamenglong' , N'Tamei' UNION ALL 
 Select 'Manipur' , N'Tamenglong' , N'Tamenglong' UNION ALL 
 Select 'Manipur' , N'Tamenglong' , N'Tousem' UNION ALL 
 Select 'Manipur' , N'Tengnoupal' , N'Machi' UNION ALL 
 Select 'Manipur' , N'Tengnoupal' , N'Moreh' UNION ALL 
 Select 'Manipur' , N'Tengnoupal' , N'Tengnoupal' UNION ALL 
 Select 'Manipur' , N'Thoubal' , N'Lilong CD Block' UNION ALL 
 Select 'Manipur' , N'Thoubal' , N'Thoubal' UNION ALL 
 Select 'Manipur' , N'Thoubal' , N'Wangjing CD Block' UNION ALL 
 Select 'Manipur' , N'Ukhrul' , N'Chingai' UNION ALL 
 Select 'Manipur' , N'Ukhrul' , N'Jessami Td' UNION ALL 
 Select 'Manipur' , N'Ukhrul' , N'Lungchong Meiphai' UNION ALL 
 Select 'Manipur' , N'Ukhrul' , N'Ukhrul'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Meghalaya' , N'Eastern West Khasi Hills' , N'Mairang' UNION ALL 
 Select 'Meghalaya' , N'Eastern West Khasi Hills' , N'Mawthadraishan' UNION ALL 
 Select 'Meghalaya' , N'East Garo Hills' , N'Dambo Rongjeng' UNION ALL 
 Select 'Meghalaya' , N'East Garo Hills' , N'Samanda' UNION ALL 
 Select 'Meghalaya' , N'East Garo Hills' , N'Songsak' UNION ALL 
 Select 'Meghalaya' , N'East Jaintia Hills' , N'Lumshnong' UNION ALL 
 Select 'Meghalaya' , N'East Jaintia Hills' , N'Saipung' UNION ALL 
 Select 'Meghalaya' , N'East Jaintia Hills' , N'Wapung' UNION ALL 
 Select 'Meghalaya' , N'East Khasi Hills' , N'Khadarshnong-Laitkroh' UNION ALL 
 Select 'Meghalaya' , N'East Khasi Hills' , N'Mawkynrew' UNION ALL 
 Select 'Meghalaya' , N'East Khasi Hills' , N'Mawlai' UNION ALL 
 Select 'Meghalaya' , N'East Khasi Hills' , N'Mawpat' UNION ALL 
 Select 'Meghalaya' , N'East Khasi Hills' , N'Mawphlang' UNION ALL 
 Select 'Meghalaya' , N'East Khasi Hills' , N'Mawryngkneng' UNION ALL 
 Select 'Meghalaya' , N'East Khasi Hills' , N'Mawsynram' UNION ALL 
 Select 'Meghalaya' , N'East Khasi Hills' , N'Mylliem' UNION ALL 
 Select 'Meghalaya' , N'East Khasi Hills' , N'Pynursla' UNION ALL 
 Select 'Meghalaya' , N'East Khasi Hills' , N'Shella Bholaganj' UNION ALL 
 Select 'Meghalaya' , N'East Khasi Hills' , N'Sohiong' UNION ALL 
 Select 'Meghalaya' , N'North Garo Hills' , N'Adokgre' UNION ALL 
 Select 'Meghalaya' , N'North Garo Hills' , N'Bajengdoba' UNION ALL 
 Select 'Meghalaya' , N'North Garo Hills' , N'Kharkutta' UNION ALL 
 Select 'Meghalaya' , N'North Garo Hills' , N'Resubelpara' UNION ALL 
 Select 'Meghalaya' , N'Ri Bhoi' , N'Bhoirymbong' UNION ALL 
 Select 'Meghalaya' , N'Ri Bhoi' , N'Jirang' UNION ALL 
 Select 'Meghalaya' , N'Ri Bhoi' , N'Umling' UNION ALL 
 Select 'Meghalaya' , N'Ri Bhoi' , N'Umsning' UNION ALL 
 Select 'Meghalaya' , N'South Garo Hills' , N'Baghmara' UNION ALL 
 Select 'Meghalaya' , N'South Garo Hills' , N'Chokpot' UNION ALL 
 Select 'Meghalaya' , N'South Garo Hills' , N'Gasuapara' UNION ALL 
 Select 'Meghalaya' , N'South Garo Hills' , N'Rongara' UNION ALL 
 Select 'Meghalaya' , N'South Garo Hills' , N'Siju' UNION ALL 
 Select 'Meghalaya' , N'South West Garo Hills' , N'Betasing' UNION ALL 
 Select 'Meghalaya' , N'South West Garo Hills' , N'Rerapara' UNION ALL 
 Select 'Meghalaya' , N'South West Garo Hills' , N'Zikzak' UNION ALL 
 Select 'Meghalaya' , N'South West Khasi Hills' , N'Mawkyrwat' UNION ALL 
 Select 'Meghalaya' , N'South West Khasi Hills' , N'Ranikor' UNION ALL 
 Select 'Meghalaya' , N'West Garo Hills' , N'Batabari' UNION ALL 
 Select 'Meghalaya' , N'West Garo Hills' , N'Dadenggiri' UNION ALL 
 Select 'Meghalaya' , N'West Garo Hills' , N'Dalu' UNION ALL 
 Select 'Meghalaya' , N'West Garo Hills' , N'Demdema' UNION ALL 
 Select 'Meghalaya' , N'West Garo Hills' , N'Gambegre' UNION ALL 
 Select 'Meghalaya' , N'West Garo Hills' , N'Rongram' UNION ALL 
 Select 'Meghalaya' , N'West Garo Hills' , N'Salsella' UNION ALL 
 Select 'Meghalaya' , N'West Garo Hills' , N'Tikrikilla' UNION ALL 
 Select 'Meghalaya' , N'West Jaintia Hills' , N'Amlarem' UNION ALL 
 Select 'Meghalaya' , N'West Jaintia Hills' , N'Laskein' UNION ALL 
 Select 'Meghalaya' , N'West Jaintia Hills' , N'Namdong' UNION ALL 
 Select 'Meghalaya' , N'West Jaintia Hills' , N'Thadlaskein' UNION ALL 
 Select 'Meghalaya' , N'West Khasi Hills' , N'Mawshynrut' UNION ALL 
 Select 'Meghalaya' , N'West Khasi Hills' , N'Nongstoin' UNION ALL 
 Select 'Meghalaya' , N'West Khasi Hills' , N'Rambrai' UNION ALL 
 Select 'Meghalaya' , N'West Khasi Hills' , N'Ri-Muliang' UNION ALL 
 Select 'Meghalaya' , N'West Khasi Hills' , N'Shallang'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Mizoram' , N'Aizawl' , N'Aibawk' UNION ALL 
 Select 'Mizoram' , N'Aizawl' , N'Darlawn' UNION ALL 
 Select 'Mizoram' , N'Aizawl' , N'Thingsulthliah' UNION ALL 
 Select 'Mizoram' , N'Aizawl' , N'Tlangnuam' UNION ALL 
 Select 'Mizoram' , N'Champhai' , N'Champhai' UNION ALL 
 Select 'Mizoram' , N'Champhai' , N'Khawbung' UNION ALL 
 Select 'Mizoram' , N'Hnahthial' , N'Hnahthial' UNION ALL 
 Select 'Mizoram' , N'Khawzawl' , N'Khawzawl' UNION ALL 
 Select 'Mizoram' , N'Kolasib' , N'Bilkhawthlir' UNION ALL 
 Select 'Mizoram' , N'Kolasib' , N'Thingdawl' UNION ALL 
 Select 'Mizoram' , N'Lawngtlai' , N'Bungtlang South' UNION ALL 
 Select 'Mizoram' , N'Lawngtlai' , N'Chawngte' UNION ALL 
 Select 'Mizoram' , N'Lawngtlai' , N'Lawngtlai' UNION ALL 
 Select 'Mizoram' , N'Lawngtlai' , N'Sangau' UNION ALL 
 Select 'Mizoram' , N'Lunglei' , N'Bunghmun' UNION ALL 
 Select 'Mizoram' , N'Lunglei' , N'Lunglei' UNION ALL 
 Select 'Mizoram' , N'Lunglei' , N'Lungsen' UNION ALL 
 Select 'Mizoram' , N'Lunglei' , N'Tlabung' UNION ALL 
 Select 'Mizoram' , N'Mamit' , N'Kawrtethawveng' UNION ALL 
 Select 'Mizoram' , N'Mamit' , N'Reiek' UNION ALL 
 Select 'Mizoram' , N'Mamit' , N'West Phaileng' UNION ALL 
 Select 'Mizoram' , N'Mamit' , N'Zawlnuam' UNION ALL 
 Select 'Mizoram' , N'Saitual' , N'Ngopa' UNION ALL 
 Select 'Mizoram' , N'Saitual' , N'Phullen' UNION ALL 
 Select 'Mizoram' , N'Serchhip' , N'East Lungdar' UNION ALL 
 Select 'Mizoram' , N'Serchhip' , N'Serchhip' UNION ALL 
 Select 'Mizoram' , N'Siaha' , N'Saiha' UNION ALL 
 Select 'Mizoram' , N'Siaha' , N'Tuipang'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Nagaland' , N'Dimapur' , N'Aghunaqa' UNION ALL 
 Select 'Nagaland' , N'Dimapur' , N'Chumukedima' UNION ALL 
 Select 'Nagaland' , N'Dimapur' , N'Dhansiripar' UNION ALL 
 Select 'Nagaland' , N'Dimapur' , N'Kuhuboto' UNION ALL 
 Select 'Nagaland' , N'Dimapur' , N'Medziphema' UNION ALL 
 Select 'Nagaland' , N'Dimapur' , N'Niuland' UNION ALL 
 Select 'Nagaland' , N'Kiphire' , N'Khonsa' UNION ALL 
 Select 'Nagaland' , N'Kiphire' , N'Kiphire' UNION ALL 
 Select 'Nagaland' , N'Kiphire' , N'Longmatra' UNION ALL 
 Select 'Nagaland' , N'Kiphire' , N'Pungro' UNION ALL 
 Select 'Nagaland' , N'Kiphire' , N'Sitimi' UNION ALL 
 Select 'Nagaland' , N'Kohima' , N'Botsa' UNION ALL 
 Select 'Nagaland' , N'Kohima' , N'Chiephobozou' UNION ALL 
 Select 'Nagaland' , N'Kohima' , N'Chunlikha' UNION ALL 
 Select 'Nagaland' , N'Kohima' , N'Jakhama' UNION ALL 
 Select 'Nagaland' , N'Kohima' , N'Kohima' UNION ALL 
 Select 'Nagaland' , N'Kohima' , N'Sechu Zubza' UNION ALL 
 Select 'Nagaland' , N'Kohima' , N'Tseminyu' UNION ALL 
 Select 'Nagaland' , N'Longleng' , N'Longleng' UNION ALL 
 Select 'Nagaland' , N'Longleng' , N'Sakshi' UNION ALL 
 Select 'Nagaland' , N'Longleng' , N'Tamlu' UNION ALL 
 Select 'Nagaland' , N'Mokokchung' , N'Changtongya' UNION ALL 
 Select 'Nagaland' , N'Mokokchung' , N'Chuchuyimlang' UNION ALL 
 Select 'Nagaland' , N'Mokokchung' , N'Kubolong' UNION ALL 
 Select 'Nagaland' , N'Mokokchung' , N'Longchem' UNION ALL 
 Select 'Nagaland' , N'Mokokchung' , N'Mangkolemba' UNION ALL 
 Select 'Nagaland' , N'Mokokchung' , N'Ongpangkong(North)' UNION ALL 
 Select 'Nagaland' , N'Mokokchung' , N'Ongpangkong(South)' UNION ALL 
 Select 'Nagaland' , N'Mokokchung' , N'Tsurangkong' UNION ALL 
 Select 'Nagaland' , N'Mokokchung' , N'Tuli' UNION ALL 
 Select 'Nagaland' , N'Mon' , N'Aboi' UNION ALL 
 Select 'Nagaland' , N'Mon' , N'Angjangyang' UNION ALL 
 Select 'Nagaland' , N'Mon' , N'Chen' UNION ALL 
 Select 'Nagaland' , N'Mon' , N'Mon' UNION ALL 
 Select 'Nagaland' , N'Mon' , N'Phomching' UNION ALL 
 Select 'Nagaland' , N'Mon' , N'Tizit' UNION ALL 
 Select 'Nagaland' , N'Mon' , N'Tobu' UNION ALL 
 Select 'Nagaland' , N'Mon' , N'Wakching' UNION ALL 
 Select 'Nagaland' , N'Noklak' , N'Noklak' UNION ALL 
 Select 'Nagaland' , N'Noklak' , N'Panso' UNION ALL 
 Select 'Nagaland' , N'Noklak' , N'Thonoknyu' UNION ALL 
 Select 'Nagaland' , N'Peren' , N'Athibung' UNION ALL 
 Select 'Nagaland' , N'Peren' , N'Jalukie' UNION ALL 
 Select 'Nagaland' , N'Peren' , N'Peren' UNION ALL 
 Select 'Nagaland' , N'Peren' , N'Tenning' UNION ALL 
 Select 'Nagaland' , N'Phek' , N'Chetheba' UNION ALL 
 Select 'Nagaland' , N'Phek' , N'Chizami' UNION ALL 
 Select 'Nagaland' , N'Phek' , N'Kikruma' UNION ALL 
 Select 'Nagaland' , N'Phek' , N'Meluri' UNION ALL 
 Select 'Nagaland' , N'Phek' , N'Pfutsero' UNION ALL 
 Select 'Nagaland' , N'Phek' , N'Phek' UNION ALL 
 Select 'Nagaland' , N'Phek' , N'Sekruzu' UNION ALL 
 Select 'Nagaland' , N'Phek' , N'Weziho' UNION ALL 
 Select 'Nagaland' , N'Shamator' , N'Chessore' UNION ALL 
 Select 'Nagaland' , N'Tuensang' , N'Chare' UNION ALL 
 Select 'Nagaland' , N'Tuensang' , N'Longkhim' UNION ALL 
 Select 'Nagaland' , N'Tuensang' , N'Noksen' UNION ALL 
 Select 'Nagaland' , N'Tuensang' , N'Sangsangyu' UNION ALL 
 Select 'Nagaland' , N'Tuensang' , N'Shamator' UNION ALL 
 Select 'Nagaland' , N'Wokha' , N'Bhandari' UNION ALL 
 Select 'Nagaland' , N'Wokha' , N'Changpang' UNION ALL 
 Select 'Nagaland' , N'Wokha' , N'Chukitong' UNION ALL 
 Select 'Nagaland' , N'Wokha' , N'Ralan' UNION ALL 
 Select 'Nagaland' , N'Wokha' , N'Sanis' UNION ALL 
 Select 'Nagaland' , N'Wokha' , N'Wokha' UNION ALL 
 Select 'Nagaland' , N'Wokha' , N'Wozhuro-Ralan' UNION ALL 
 Select 'Nagaland' , N'Zunheboto' , N'Akuhaito' UNION ALL 
 Select 'Nagaland' , N'Zunheboto' , N'Akuluto' UNION ALL 
 Select 'Nagaland' , N'Zunheboto' , N'Ghathashi' UNION ALL 
 Select 'Nagaland' , N'Zunheboto' , N'Satakha' UNION ALL 
 Select 'Nagaland' , N'Zunheboto' , N'Satoi' UNION ALL 
 Select 'Nagaland' , N'Zunheboto' , N'Suruhoto' UNION ALL 
 Select 'Nagaland' , N'Zunheboto' , N'Tokiye' UNION ALL 
 Select 'Nagaland' , N'Zunheboto' , N'Zunheboto'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Odisha' , N'Anugul' , N'Anugul' UNION ALL 
 Select 'Odisha' , N'Anugul' , N'Athmallik' UNION ALL 
 Select 'Odisha' , N'Anugul' , N'Banarpal' UNION ALL 
 Select 'Odisha' , N'Anugul' , N'Chhendipada' UNION ALL 
 Select 'Odisha' , N'Anugul' , N'Kaniha' UNION ALL 
 Select 'Odisha' , N'Anugul' , N'Kishorenagar' UNION ALL 
 Select 'Odisha' , N'Anugul' , N'Palalahada' UNION ALL 
 Select 'Odisha' , N'Anugul' , N'Talacher' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Agalpur' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Balangir' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Bangomunda' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Belpara' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Deogaon' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Gudvella' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Khaprakhol' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Loisinga' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Muribahal' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Patnagarh' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Puintala' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Saintala' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Titlagarh' UNION ALL 
 Select 'Odisha' , N'Balangir' , N'Turekela' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Bahanaga' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Baleshwar' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Baliapal' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Basta' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Bhograi' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Jaleswar' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Khaira' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Nilgiri' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Oupada' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Remuna' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Simulia' UNION ALL 
 Select 'Odisha' , N'Baleshwar' , N'Soro' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Ambabhona' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Attabira' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Bargarh' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Barpali' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Bhatli' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Bheden' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Bijepur' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Gaisilet' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Jharbandh' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Padampur' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Paikmal' UNION ALL 
 Select 'Odisha' , N'Bargarh' , N'Sohella' UNION ALL 
 Select 'Odisha' , N'Bhadrak' , N'Basudevpur' UNION ALL 
 Select 'Odisha' , N'Bhadrak' , N'Bhadrak' UNION ALL 
 Select 'Odisha' , N'Bhadrak' , N'Bhandaripokhari' UNION ALL 
 Select 'Odisha' , N'Bhadrak' , N'Bonth' UNION ALL 
 Select 'Odisha' , N'Bhadrak' , N'Chandabali' UNION ALL 
 Select 'Odisha' , N'Bhadrak' , N'Dhamanagar' UNION ALL 
 Select 'Odisha' , N'Bhadrak' , N'Tihidi' UNION ALL 
 Select 'Odisha' , N'Boudh' , N'Boudh' UNION ALL 
 Select 'Odisha' , N'Boudh' , N'Harabhanga' UNION ALL 
 Select 'Odisha' , N'Boudh' , N'Kantamal' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Athagad' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Badamba' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Banki' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Banki- Dampara' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Baranga' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Cuttacksadar' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Kantapada' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Mahanga' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Narasinghpur' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Niali' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Nischinta Koili' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Salepur' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Tangi Choudwar' UNION ALL 
 Select 'Odisha' , N'Cuttack' , N'Tigiria' UNION ALL 
 Select 'Odisha' , N'Deogarh' , N'Barkote' UNION ALL 
 Select 'Odisha' , N'Deogarh' , N'Reamal' UNION ALL 
 Select 'Odisha' , N'Deogarh' , N'Tileibani' UNION ALL 
 Select 'Odisha' , N'Dhenkanal' , N'Bhuban' UNION ALL 
 Select 'Odisha' , N'Dhenkanal' , N'Dhenkanal Sadar' UNION ALL 
 Select 'Odisha' , N'Dhenkanal' , N'Gondia' UNION ALL 
 Select 'Odisha' , N'Dhenkanal' , N'Hindol' UNION ALL 
 Select 'Odisha' , N'Dhenkanal' , N'Kamakhyanagar' UNION ALL 
 Select 'Odisha' , N'Dhenkanal' , N'Kankada Had' UNION ALL 
 Select 'Odisha' , N'Dhenkanal' , N'Odapada' UNION ALL 
 Select 'Odisha' , N'Dhenkanal' , N'Parjang' UNION ALL 
 Select 'Odisha' , N'Gajapati' , N'Gosani' UNION ALL 
 Select 'Odisha' , N'Gajapati' , N'Gumma' UNION ALL 
 Select 'Odisha' , N'Gajapati' , N'Kasinagar' UNION ALL 
 Select 'Odisha' , N'Gajapati' , N'Mohana' UNION ALL 
 Select 'Odisha' , N'Gajapati' , N'Nuagada' UNION ALL 
 Select 'Odisha' , N'Gajapati' , N'Rayagada' UNION ALL 
 Select 'Odisha' , N'Gajapati' , N'R.Udayagiri' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Aska' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Beguniapada' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Bellaguntha' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Bhanjanagar' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Buguda' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Chatrapur' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Chikiti' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Dharakote' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Digapahandi' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Ganjam' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Hinjilicut' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Jagannathprasad' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Kabisuryanagar' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Khallikote' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Kukudakhandi' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Patrapur' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Polosara' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Purushottampur' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Rangeilunda' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Sanakhemundi' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Sheragada' UNION ALL 
 Select 'Odisha' , N'Ganjam' , N'Surada' UNION ALL 
 Select 'Odisha' , N'Jagatsinghapur' , N'Balikuda' UNION ALL 
 Select 'Odisha' , N'Jagatsinghapur' , N'Biridi' UNION ALL 
 Select 'Odisha' , N'Jagatsinghapur' , N'Erasama' UNION ALL 
 Select 'Odisha' , N'Jagatsinghapur' , N'Jagatsinghpur' UNION ALL 
 Select 'Odisha' , N'Jagatsinghapur' , N'Kujang' UNION ALL 
 Select 'Odisha' , N'Jagatsinghapur' , N'Naugaon' UNION ALL 
 Select 'Odisha' , N'Jagatsinghapur' , N'Raghunathpur' UNION ALL 
 Select 'Odisha' , N'Jagatsinghapur' , N'Tirtol' UNION ALL 
 Select 'Odisha' , N'Jajapur' , N'Badchana' UNION ALL 
 Select 'Odisha' , N'Jajapur' , N'Bari' UNION ALL 
 Select 'Odisha' , N'Jajapur' , N'Binjharpur' UNION ALL 
 Select 'Odisha' , N'Jajapur' , N'Dahrmasala' UNION ALL 
 Select 'Odisha' , N'Jajapur' , N'Danagadi' UNION ALL 
 Select 'Odisha' , N'Jajapur' , N'Dasarathapur' UNION ALL 
 Select 'Odisha' , N'Jajapur' , N'Jajpur' UNION ALL 
 Select 'Odisha' , N'Jajapur' , N'Korei' UNION ALL 
 Select 'Odisha' , N'Jajapur' , N'Rasulpur' UNION ALL 
 Select 'Odisha' , N'Jajapur' , N'Sukinda' UNION ALL 
 Select 'Odisha' , N'Jharsuguda' , N'Jharsuguda' UNION ALL 
 Select 'Odisha' , N'Jharsuguda' , N'Kirmira' UNION ALL 
 Select 'Odisha' , N'Jharsuguda' , N'Kolabira' UNION ALL 
 Select 'Odisha' , N'Jharsuguda' , N'Laikera' UNION ALL 
 Select 'Odisha' , N'Jharsuguda' , N'Lakhanpur' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Bhawanipatna' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Dharamagarh' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Golamunda' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Jayapatna' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Junagarh' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Kalampur' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Karlamunda' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Kesinga' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Kokasara' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Lanjigarh' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Madanpur Rampur' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Narala' UNION ALL 
 Select 'Odisha' , N'Kalahandi' , N'Thuamul Ram Pur' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'Baliguda' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'Chakapad' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'Daringibadi' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'G.Udayagiri' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'Khajuripada' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'K.Nuagan' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'Kotagarh' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'Phiringia' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'Phulbani' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'Raikia' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'Tikabali' UNION ALL 
 Select 'Odisha' , N'Kandhamal' , N'Tumudibandh' UNION ALL 
 Select 'Odisha' , N'Kendrapara' , N'Aul' UNION ALL 
 Select 'Odisha' , N'Kendrapara' , N'Derabish' UNION ALL 
 Select 'Odisha' , N'Kendrapara' , N'Garadapur' UNION ALL 
 Select 'Odisha' , N'Kendrapara' , N'Kendrapada' UNION ALL 
 Select 'Odisha' , N'Kendrapara' , N'Mahakalapada' UNION ALL 
 Select 'Odisha' , N'Kendrapara' , N'Marsaghai' UNION ALL 
 Select 'Odisha' , N'Kendrapara' , N'Pattamundai' UNION ALL 
 Select 'Odisha' , N'Kendrapara' , N'Rajkanika' UNION ALL 
 Select 'Odisha' , N'Kendrapara' , N'Rajnagar' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Anandapur' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Bansapal' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Champua' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Ghasipura' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Ghatgaon' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Harichadanpur' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Hatadihi' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Jhumpura' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Joda' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Kendujhar Sadar' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Patana' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Saharapada' UNION ALL 
 Select 'Odisha' , N'Kendujhar' , N'Telkoi' UNION ALL 
 Select 'Odisha' , N'Khordha' , N'Balianta' UNION ALL 
 Select 'Odisha' , N'Khordha' , N'Balipatna' UNION ALL 
 Select 'Odisha' , N'Khordha' , N'Banapur' UNION ALL 
 Select 'Odisha' , N'Khordha' , N'Begunia' UNION ALL 
 Select 'Odisha' , N'Khordha' , N'Bhubaneswar' UNION ALL 
 Select 'Odisha' , N'Khordha' , N'Bolagarh' UNION ALL 
 Select 'Odisha' , N'Khordha' , N'Chilika' UNION ALL 
 Select 'Odisha' , N'Khordha' , N'Jatni' UNION ALL 
 Select 'Odisha' , N'Khordha' , N'Khordha' UNION ALL 
 Select 'Odisha' , N'Khordha' , N'Tangi' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Bandhugaon' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Boipariguda' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Borigumma' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Dasamantapur' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Jeypore' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Koraput' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Kotpad' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Kundura' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Lamtaput' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Laxmipur' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Nandapur' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Narayan Patana' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Pottangi' UNION ALL 
 Select 'Odisha' , N'Koraput' , N'Semiliguda' UNION ALL 
 Select 'Odisha' , N'Malkangiri' , N'Chitrakonda' UNION ALL 
 Select 'Odisha' , N'Malkangiri' , N'Kalimela' UNION ALL 
 Select 'Odisha' , N'Malkangiri' , N'Khairaput' UNION ALL 
 Select 'Odisha' , N'Malkangiri' , N'Korukonda' UNION ALL 
 Select 'Odisha' , N'Malkangiri' , N'Malkangiri' UNION ALL 
 Select 'Odisha' , N'Malkangiri' , N'Mathili' UNION ALL 
 Select 'Odisha' , N'Malkangiri' , N'Podia' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Badasahi' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Bahalda' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Bangriposi' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Baripada' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Betnoti' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Bijatala' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Bisoi' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Gopabandhunagar' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Jamda' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Joshipur' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Kaptipada' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Karanjia' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Khunta' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Kuliana' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Kusumi' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Morada' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Rairangpur' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Raruan' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Rasgovindpur' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Samakhunta' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Saraskana' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Sukruli' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Suliapada' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Thakurmunda' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Tiring' UNION ALL 
 Select 'Odisha' , N'Mayurbhanj' , N'Udala' UNION ALL 
 Select 'Odisha' , N'Nabarangpur' , N'Chandahandi' UNION ALL 
 Select 'Odisha' , N'Nabarangpur' , N'Dabugam' UNION ALL 
 Select 'Odisha' , N'Nabarangpur' , N'Jharigam' UNION ALL 
 Select 'Odisha' , N'Nabarangpur' , N'Kosagumuda' UNION ALL 
 Select 'Odisha' , N'Nabarangpur' , N'Nabarangpur' UNION ALL 
 Select 'Odisha' , N'Nabarangpur' , N'Nandahandi' UNION ALL 
 Select 'Odisha' , N'Nabarangpur' , N'Papadahandi' UNION ALL 
 Select 'Odisha' , N'Nabarangpur' , N'Raighar' UNION ALL 
 Select 'Odisha' , N'Nabarangpur' , N'Tentulikhunti' UNION ALL 
 Select 'Odisha' , N'Nabarangpur' , N'Umerkote' UNION ALL 
 Select 'Odisha' , N'Nayagarh' , N'Bhapur' UNION ALL 
 Select 'Odisha' , N'Nayagarh' , N'Dasapalla' UNION ALL 
 Select 'Odisha' , N'Nayagarh' , N'Gania' UNION ALL 
 Select 'Odisha' , N'Nayagarh' , N'Khandapara' UNION ALL 
 Select 'Odisha' , N'Nayagarh' , N'Nayagarh' UNION ALL 
 Select 'Odisha' , N'Nayagarh' , N'Nuagaon' UNION ALL 
 Select 'Odisha' , N'Nayagarh' , N'Odagaon' UNION ALL 
 Select 'Odisha' , N'Nayagarh' , N'Ranapur' UNION ALL 
 Select 'Odisha' , N'Nuapada' , N'Boden' UNION ALL 
 Select 'Odisha' , N'Nuapada' , N'Khariar' UNION ALL 
 Select 'Odisha' , N'Nuapada' , N'Komna' UNION ALL 
 Select 'Odisha' , N'Nuapada' , N'Nuapada' UNION ALL 
 Select 'Odisha' , N'Nuapada' , N'Sinapali' UNION ALL 
 Select 'Odisha' , N'Puri' , N'Astaranga' UNION ALL 
 Select 'Odisha' , N'Puri' , N'Brahmagiri' UNION ALL 
 Select 'Odisha' , N'Puri' , N'Delanga' UNION ALL 
 Select 'Odisha' , N'Puri' , N'Gop' UNION ALL 
 Select 'Odisha' , N'Puri' , N'Kakat Pur' UNION ALL 
 Select 'Odisha' , N'Puri' , N'Kanas' UNION ALL 
 Select 'Odisha' , N'Puri' , N'Krushnaprasad' UNION ALL 
 Select 'Odisha' , N'Puri' , N'Nimapada' UNION ALL 
 Select 'Odisha' , N'Puri' , N'Pipili' UNION ALL 
 Select 'Odisha' , N'Puri' , N'Sadar' UNION ALL 
 Select 'Odisha' , N'Puri' , N'Satyabadi' UNION ALL 
 Select 'Odisha' , N'Rayagada' , N'Bissamcuttack' UNION ALL 
 Select 'Odisha' , N'Rayagada' , N'Chandrapur' UNION ALL 
 Select 'Odisha' , N'Rayagada' , N'Gudari' UNION ALL 
 Select 'Odisha' , N'Rayagada' , N'Gunupur' UNION ALL 
 Select 'Odisha' , N'Rayagada' , N'Kalyansingpur' UNION ALL 
 Select 'Odisha' , N'Rayagada' , N'Kasipur' UNION ALL 
 Select 'Odisha' , N'Rayagada' , N'Kolnara' UNION ALL 
 Select 'Odisha' , N'Rayagada' , N'Muniguda' UNION ALL 
 Select 'Odisha' , N'Rayagada' , N'Padmapur' UNION ALL 
 Select 'Odisha' , N'Rayagada' , N'Ramanaguda' UNION ALL 
 Select 'Odisha' , N'Rayagada' , N'Rayagada' UNION ALL 
 Select 'Odisha' , N'Sambalpur' , N'Bamra' UNION ALL 
 Select 'Odisha' , N'Sambalpur' , N'Dhankauda' UNION ALL 
 Select 'Odisha' , N'Sambalpur' , N'Jamankira' UNION ALL 
 Select 'Odisha' , N'Sambalpur' , N'Jujomura' UNION ALL 
 Select 'Odisha' , N'Sambalpur' , N'Kuchinda' UNION ALL 
 Select 'Odisha' , N'Sambalpur' , N'Maneswar' UNION ALL 
 Select 'Odisha' , N'Sambalpur' , N'Naktideul' UNION ALL 
 Select 'Odisha' , N'Sambalpur' , N'Rairakhol' UNION ALL 
 Select 'Odisha' , N'Sambalpur' , N'Rengali' UNION ALL 
 Select 'Odisha' , N'Sonepur' , N'Binika' UNION ALL 
 Select 'Odisha' , N'Sonepur' , N'Birmaharajpur' UNION ALL 
 Select 'Odisha' , N'Sonepur' , N'Dunguripali' UNION ALL 
 Select 'Odisha' , N'Sonepur' , N'Sonepur' UNION ALL 
 Select 'Odisha' , N'Sonepur' , N'Tarbha' UNION ALL 
 Select 'Odisha' , N'Sonepur' , N'Ullunda' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Balisankara' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Bargaon' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Bisra' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Bonaigarh' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Gurundia' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Hemgir' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Koida' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Kuarmunda' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Kutra' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Lahunipara' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Lathikata' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Lephripara' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Nuagaon' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Rajgangpur' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Subdega' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Sundargarh' UNION ALL 
 Select 'Odisha' , N'Sundargarh' , N'Tangarpali'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Puducherry' , N'Karaikal' , N'Karaikal' UNION ALL 
 Select 'Puducherry' , N'Mahe' , N'Mahe' UNION ALL 
 Select 'Puducherry' , N'Pondicherry' , N'Ariankuppam' UNION ALL 
 Select 'Puducherry' , N'Pondicherry' , N'Ozhukarai' UNION ALL 
 Select 'Puducherry' , N'Pondicherry' , N'Villianur' UNION ALL 
 Select 'Puducherry' , N'Yanam' , N'Yanam'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Punjab' , N'Amritsar' , N'Ajnala' UNION ALL 
 Select 'Punjab' , N'Amritsar' , N'Attari' UNION ALL 
 Select 'Punjab' , N'Amritsar' , N'Chogawan' UNION ALL 
 Select 'Punjab' , N'Amritsar' , N'Harshe Chhina' UNION ALL 
 Select 'Punjab' , N'Amritsar' , N'Jandiala Guru' UNION ALL 
 Select 'Punjab' , N'Amritsar' , N'Majitha' UNION ALL 
 Select 'Punjab' , N'Amritsar' , N'Rayya' UNION ALL 
 Select 'Punjab' , N'Amritsar' , N'Tarsikka' UNION ALL 
 Select 'Punjab' , N'Amritsar' , N'Verka' UNION ALL 
 Select 'Punjab' , N'Barnala' , N'Barnala' UNION ALL 
 Select 'Punjab' , N'Barnala' , N'Mehal Kalan' UNION ALL 
 Select 'Punjab' , N'Barnala' , N'Sehna' UNION ALL 
 Select 'Punjab' , N'Bathinda' , N'Bathinda' UNION ALL 
 Select 'Punjab' , N'Bathinda' , N'Bhagta Bhaika' UNION ALL 
 Select 'Punjab' , N'Bathinda' , N'Goniana' UNION ALL 
 Select 'Punjab' , N'Bathinda' , N'Maur' UNION ALL 
 Select 'Punjab' , N'Bathinda' , N'Nathana' UNION ALL 
 Select 'Punjab' , N'Bathinda' , N'Phul' UNION ALL 
 Select 'Punjab' , N'Bathinda' , N'Rampura' UNION ALL 
 Select 'Punjab' , N'Bathinda' , N'Sangat' UNION ALL 
 Select 'Punjab' , N'Bathinda' , N'Talwandi Sabo' UNION ALL 
 Select 'Punjab' , N'Faridkot' , N'Faridkot' UNION ALL 
 Select 'Punjab' , N'Faridkot' , N'Jaitu' UNION ALL 
 Select 'Punjab' , N'Faridkot' , N'Kot Kapura' UNION ALL 
 Select 'Punjab' , N'Fatehgarh Sahib' , N'Amloh' UNION ALL 
 Select 'Punjab' , N'Fatehgarh Sahib' , N'Bassi Pathana' UNION ALL 
 Select 'Punjab' , N'Fatehgarh Sahib' , N'Khamano' UNION ALL 
 Select 'Punjab' , N'Fatehgarh Sahib' , N'Khera' UNION ALL 
 Select 'Punjab' , N'Fatehgarh Sahib' , N'Sirhind' UNION ALL 
 Select 'Punjab' , N'Fazilka' , N'Abohar' UNION ALL 
 Select 'Punjab' , N'Fazilka' , N'Arniwala Shiekh Subhan' UNION ALL 
 Select 'Punjab' , N'Fazilka' , N'Fazilka' UNION ALL 
 Select 'Punjab' , N'Fazilka' , N'Jalalabad' UNION ALL 
 Select 'Punjab' , N'Fazilka' , N'Khuian Sarwar' UNION ALL 
 Select 'Punjab' , N'Ferozepur' , N'Firozpur' UNION ALL 
 Select 'Punjab' , N'Ferozepur' , N'Ghall Khurd' UNION ALL 
 Select 'Punjab' , N'Ferozepur' , N'Guru Har Sahai' UNION ALL 
 Select 'Punjab' , N'Ferozepur' , N'Makhu' UNION ALL 
 Select 'Punjab' , N'Ferozepur' , N'Mamdot' UNION ALL 
 Select 'Punjab' , N'Ferozepur' , N'Zira' UNION ALL 
 Select 'Punjab' , N'Gurdaspur' , N'Batala' UNION ALL 
 Select 'Punjab' , N'Gurdaspur' , N'Dera Baba Nanak' UNION ALL 
 Select 'Punjab' , N'Gurdaspur' , N'Dhariwal' UNION ALL 
 Select 'Punjab' , N'Gurdaspur' , N'Dinanagar' UNION ALL 
 Select 'Punjab' , N'Gurdaspur' , N'Dorangla' UNION ALL 
 Select 'Punjab' , N'Gurdaspur' , N'Fatehgarh Churian' UNION ALL 
 Select 'Punjab' , N'Gurdaspur' , N'Gurdaspur' UNION ALL 
 Select 'Punjab' , N'Gurdaspur' , N'Kahnuwan' UNION ALL 
 Select 'Punjab' , N'Gurdaspur' , N'Kalanaur' UNION ALL 
 Select 'Punjab' , N'Gurdaspur' , N'Qadian' UNION ALL 
 Select 'Punjab' , N'Gurdaspur' , N'Sri Hargobindpur' UNION ALL 
 Select 'Punjab' , N'Hoshiarpur' , N'Bhunga' UNION ALL 
 Select 'Punjab' , N'Hoshiarpur' , N'Dasuya' UNION ALL 
 Select 'Punjab' , N'Hoshiarpur' , N'Garhshankar' UNION ALL 
 Select 'Punjab' , N'Hoshiarpur' , N'Hajipur' UNION ALL 
 Select 'Punjab' , N'Hoshiarpur' , N'Hoshiarpur-I' UNION ALL 
 Select 'Punjab' , N'Hoshiarpur' , N'Hoshiarpur-Ii' UNION ALL 
 Select 'Punjab' , N'Hoshiarpur' , N'Mahilpur' UNION ALL 
 Select 'Punjab' , N'Hoshiarpur' , N'Mukerian' UNION ALL 
 Select 'Punjab' , N'Hoshiarpur' , N'Talwara' UNION ALL 
 Select 'Punjab' , N'Hoshiarpur' , N'Tanda' UNION ALL 
 Select 'Punjab' , N'Jalandhar' , N'Adampur' UNION ALL 
 Select 'Punjab' , N'Jalandhar' , N'Bhogpur' UNION ALL 
 Select 'Punjab' , N'Jalandhar' , N'Jalandhar-East' UNION ALL 
 Select 'Punjab' , N'Jalandhar' , N'Jalandhar - West' UNION ALL 
 Select 'Punjab' , N'Jalandhar' , N'Lohian' UNION ALL 
 Select 'Punjab' , N'Jalandhar' , N'Mehatpur' UNION ALL 
 Select 'Punjab' , N'Jalandhar' , N'Nakodar' UNION ALL 
 Select 'Punjab' , N'Jalandhar' , N'Nurmahal' UNION ALL 
 Select 'Punjab' , N'Jalandhar' , N'Phillaur' UNION ALL 
 Select 'Punjab' , N'Jalandhar' , N'Rurka Kalan' UNION ALL 
 Select 'Punjab' , N'Jalandhar' , N'Shahkot' UNION ALL 
 Select 'Punjab' , N'Kapurthala' , N'Dhilwan' UNION ALL 
 Select 'Punjab' , N'Kapurthala' , N'Kapurthala' UNION ALL 
 Select 'Punjab' , N'Kapurthala' , N'Nadala' UNION ALL 
 Select 'Punjab' , N'Kapurthala' , N'Phagwara' UNION ALL 
 Select 'Punjab' , N'Kapurthala' , N'Sultanpur Lodhi' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Dehlon' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Doraha' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Jagraon' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Khanna' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Ludhiana-1' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Ludhiana-2' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Machhiwara' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Maloud' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Pakhowal' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Raikot' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Samrala' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Sidhwan Bet' UNION ALL 
 Select 'Punjab' , N'Ludhiana' , N'Sudhar' UNION ALL 
 Select 'Punjab' , N'Malerkotla' , N'Ahmedgarh' UNION ALL 
 Select 'Punjab' , N'Malerkotla' , N'Amargarh' UNION ALL 
 Select 'Punjab' , N'Malerkotla' , N'Malerkotla H' UNION ALL 
 Select 'Punjab' , N'Mansa' , N'Bhikhi' UNION ALL 
 Select 'Punjab' , N'Mansa' , N'Budhlada' UNION ALL 
 Select 'Punjab' , N'Mansa' , N'Jhunir' UNION ALL 
 Select 'Punjab' , N'Mansa' , N'Mansa' UNION ALL 
 Select 'Punjab' , N'Mansa' , N'Sardulgarh' UNION ALL 
 Select 'Punjab' , N'Moga' , N'Baghapurana' UNION ALL 
 Select 'Punjab' , N'Moga' , N'Kot-Ise-Khan' UNION ALL 
 Select 'Punjab' , N'Moga' , N'Moga-I' UNION ALL 
 Select 'Punjab' , N'Moga' , N'Moga-Ii' UNION ALL 
 Select 'Punjab' , N'Moga' , N'Nihal Singh Wala' UNION ALL 
 Select 'Punjab' , N'Pathankot' , N'Bamial' UNION ALL 
 Select 'Punjab' , N'Pathankot' , N'Dharkalan' UNION ALL 
 Select 'Punjab' , N'Pathankot' , N'Gharota' UNION ALL 
 Select 'Punjab' , N'Pathankot' , N'Narot Jaimal Singh' UNION ALL 
 Select 'Punjab' , N'Pathankot' , N'Pathankot' UNION ALL 
 Select 'Punjab' , N'Pathankot' , N'Sujanpur' UNION ALL 
 Select 'Punjab' , N'Patiala' , N'Bhuner Heri' UNION ALL 
 Select 'Punjab' , N'Patiala' , N'Ghanaur' UNION ALL 
 Select 'Punjab' , N'Patiala' , N'Nabha' UNION ALL 
 Select 'Punjab' , N'Patiala' , N'Patiala' UNION ALL 
 Select 'Punjab' , N'Patiala' , N'Patiala Rural' UNION ALL 
 Select 'Punjab' , N'Patiala' , N'Patran' UNION ALL 
 Select 'Punjab' , N'Patiala' , N'Rajpura' UNION ALL 
 Select 'Punjab' , N'Patiala' , N'Samana' UNION ALL 
 Select 'Punjab' , N'Patiala' , N'Sanour' UNION ALL 
 Select 'Punjab' , N'Patiala' , N'Shambu Kalan' UNION ALL 
 Select 'Punjab' , N'Rupnagar' , N'Anandpur Sahib' UNION ALL 
 Select 'Punjab' , N'Rupnagar' , N'Chamkaur Sahib' UNION ALL 
 Select 'Punjab' , N'Rupnagar' , N'Morinda' UNION ALL 
 Select 'Punjab' , N'Rupnagar' , N'Nurpur Bedi' UNION ALL 
 Select 'Punjab' , N'Rupnagar' , N'Rupnagar' UNION ALL 
 Select 'Punjab' , N'Sangrur' , N'Andana' UNION ALL 
 Select 'Punjab' , N'Sangrur' , N'Bhawani Garh' UNION ALL 
 Select 'Punjab' , N'Sangrur' , N'Dhuri' UNION ALL 
 Select 'Punjab' , N'Sangrur' , N'Dirba' UNION ALL 
 Select 'Punjab' , N'Sangrur' , N'Lehragaga' UNION ALL 
 Select 'Punjab' , N'Sangrur' , N'Sangrur' UNION ALL 
 Select 'Punjab' , N'Sangrur' , N'Sherpur' UNION ALL 
 Select 'Punjab' , N'Sangrur' , N'Sunam' UNION ALL 
 Select 'Punjab' , N'S.A.S Nagar' , N'Dera Bassi' UNION ALL 
 Select 'Punjab' , N'S.A.S Nagar' , N'Kharar' UNION ALL 
 Select 'Punjab' , N'S.A.S Nagar' , N'Majri' UNION ALL 
 Select 'Punjab' , N'S.A.S Nagar' , N'Mohali' UNION ALL 
 Select 'Punjab' , N'Shahid Bhagat Singh Nagar' , N'Aur' UNION ALL 
 Select 'Punjab' , N'Shahid Bhagat Singh Nagar' , N'Balachaur' UNION ALL 
 Select 'Punjab' , N'Shahid Bhagat Singh Nagar' , N'Banga' UNION ALL 
 Select 'Punjab' , N'Shahid Bhagat Singh Nagar' , N'Nawanshahr' UNION ALL 
 Select 'Punjab' , N'Shahid Bhagat Singh Nagar' , N'Saroya' UNION ALL 
 Select 'Punjab' , N'Sri Muktsar Sahib' , N'Gidderbaha' UNION ALL 
 Select 'Punjab' , N'Sri Muktsar Sahib' , N'Lambi' UNION ALL 
 Select 'Punjab' , N'Sri Muktsar Sahib' , N'Malout' UNION ALL 
 Select 'Punjab' , N'Sri Muktsar Sahib' , N'Muktsar' UNION ALL 
 Select 'Punjab' , N'Tarn Taran' , N'Bhikhi Wind-13' UNION ALL 
 Select 'Punjab' , N'Tarn Taran' , N'Chohla Sahib-8' UNION ALL 
 Select 'Punjab' , N'Tarn Taran' , N'Gandiwind-9' UNION ALL 
 Select 'Punjab' , N'Tarn Taran' , N'Khadur-Sahib-10' UNION ALL 
 Select 'Punjab' , N'Tarn Taran' , N'Naushehra Pannuan-11' UNION ALL 
 Select 'Punjab' , N'Tarn Taran' , N'Patti-14' UNION ALL 
 Select 'Punjab' , N'Tarn Taran' , N'Tarn Taran-12' UNION ALL 
 Select 'Punjab' , N'Tarn Taran' , N'Valtoha-15'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Rajasthan' , N'Ajmer' , N'Ajmer Rural' UNION ALL 
 Select 'Rajasthan' , N'Ajmer' , N'Kishangarh Silora' UNION ALL 
 Select 'Rajasthan' , N'Ajmer' , N'Pisangan' UNION ALL 
 Select 'Rajasthan' , N'Ajmer' , N'Srinagar' UNION ALL 
 Select 'Rajasthan' , N'Alwar' , N'Govindgarh' UNION ALL 
 Select 'Rajasthan' , N'Alwar' , N'Kathumar' UNION ALL 
 Select 'Rajasthan' , N'Alwar' , N'Laxmangarh' UNION ALL 
 Select 'Rajasthan' , N'Alwar' , N'Malkheda' UNION ALL 
 Select 'Rajasthan' , N'Alwar' , N'Rajgarh' UNION ALL 
 Select 'Rajasthan' , N'Alwar' , N'Ramgarh' UNION ALL 
 Select 'Rajasthan' , N'Alwar' , N'Reni' UNION ALL 
 Select 'Rajasthan' , N'Alwar' , N'Thanagazi' UNION ALL 
 Select 'Rajasthan' , N'Alwar' , N'Umren' UNION ALL 
 Select 'Rajasthan' , N'Anupgarh' , N'Anupgarh' UNION ALL 
 Select 'Rajasthan' , N'Anupgarh' , N'Gharsana' UNION ALL 
 Select 'Rajasthan' , N'Anupgarh' , N'Vijainagar' UNION ALL 
 Select 'Rajasthan' , N'Balotra' , N'Baltora' UNION ALL 
 Select 'Rajasthan' , N'Balotra' , N'Gira' UNION ALL 
 Select 'Rajasthan' , N'Balotra' , N'Kalyanpur' UNION ALL 
 Select 'Rajasthan' , N'Balotra' , N'Patodi' UNION ALL 
 Select 'Rajasthan' , N'Balotra' , N'Samdari' UNION ALL 
 Select 'Rajasthan' , N'Balotra' , N'Sindhari' UNION ALL 
 Select 'Rajasthan' , N'Balotra' , N'Siwana' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Anandpuri' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Arthuna' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Bagidora' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Banswara' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Chhoti Sarwa' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Chhoti Sarwan' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Gangar Talai' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Ganoda' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Garhi' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Ghatol' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Kushalgarh' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Sajjangarh' UNION ALL 
 Select 'Rajasthan' , N'Banswara' , N'Talwara' UNION ALL 
 Select 'Rajasthan' , N'Baran' , N'Anta' UNION ALL 
 Select 'Rajasthan' , N'Baran' , N'Atru' UNION ALL 
 Select 'Rajasthan' , N'Baran' , N'Baran (Full)' UNION ALL 
 Select 'Rajasthan' , N'Baran' , N'Chhabra' UNION ALL 
 Select 'Rajasthan' , N'Baran' , N'Chhipabarod' UNION ALL 
 Select 'Rajasthan' , N'Baran' , N'Kishanganj' UNION ALL 
 Select 'Rajasthan' , N'Baran' , N'Mangrol' UNION ALL 
 Select 'Rajasthan' , N'Baran' , N'Shahbad' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Aadel' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Barmer' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Barmer Rural' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Chohtan' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Dhanau' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Dhorimanna' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Fagliya' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Gadra Road' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Gudhamalani' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Ramsar' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Sedwa' UNION ALL 
 Select 'Rajasthan' , N'Barmer' , N'Sheo' UNION ALL 
 Select 'Rajasthan' , N'Beawar' , N'Jaitaran' UNION ALL 
 Select 'Rajasthan' , N'Beawar' , N'Jawaja' UNION ALL 
 Select 'Rajasthan' , N'Beawar' , N'Masooda' UNION ALL 
 Select 'Rajasthan' , N'Beawar' , N'Raipur' UNION ALL 
 Select 'Rajasthan' , N'Bharatpur' , N'Bayana' UNION ALL 
 Select 'Rajasthan' , N'Bharatpur' , N'Bhusawar' UNION ALL 
 Select 'Rajasthan' , N'Bharatpur' , N'Nadbai' UNION ALL 
 Select 'Rajasthan' , N'Bharatpur' , N'Rupbas' UNION ALL 
 Select 'Rajasthan' , N'Bharatpur' , N'Sewar' UNION ALL 
 Select 'Rajasthan' , N'Bharatpur' , N'Uchain' UNION ALL 
 Select 'Rajasthan' , N'Bharatpur' , N'Weir' UNION ALL 
 Select 'Rajasthan' , N'Bhilwara' , N'Asind' UNION ALL 
 Select 'Rajasthan' , N'Bhilwara' , N'Hurda' UNION ALL 
 Select 'Rajasthan' , N'Bhilwara' , N'Kareda' UNION ALL 
 Select 'Rajasthan' , N'Bhilwara' , N'Mandal' UNION ALL 
 Select 'Rajasthan' , N'Bhilwara' , N'Raipur' UNION ALL 
 Select 'Rajasthan' , N'Bhilwara' , N'Sahara' UNION ALL 
 Select 'Rajasthan' , N'Bhilwara' , N'Suwana' UNION ALL 
 Select 'Rajasthan' , N'Bikaner' , N'Bajju Khalsa' UNION ALL 
 Select 'Rajasthan' , N'Bikaner' , N'Bikaner' UNION ALL 
 Select 'Rajasthan' , N'Bikaner' , N'Hadan' UNION ALL 
 Select 'Rajasthan' , N'Bikaner' , N'Khajuwala' UNION ALL 
 Select 'Rajasthan' , N'Bikaner' , N'Kolayat' UNION ALL 
 Select 'Rajasthan' , N'Bikaner' , N'Lunkaransar' UNION ALL 
 Select 'Rajasthan' , N'Bikaner' , N'Nokha' UNION ALL 
 Select 'Rajasthan' , N'Bikaner' , N'Panchoo' UNION ALL 
 Select 'Rajasthan' , N'Bikaner' , N'Poogal' UNION ALL 
 Select 'Rajasthan' , N'Bikaner' , N'Sri Dungargarh' UNION ALL 
 Select 'Rajasthan' , N'Bundi' , N'Bundi' UNION ALL 
 Select 'Rajasthan' , N'Bundi' , N'Hindoli' UNION ALL 
 Select 'Rajasthan' , N'Bundi' , N'Keshoraipatan' UNION ALL 
 Select 'Rajasthan' , N'Bundi' , N'Nainwa' UNION ALL 
 Select 'Rajasthan' , N'Bundi' , N'Talera' UNION ALL 
 Select 'Rajasthan' , N'Chittorgarh' , N'Bari Sadri' UNION ALL 
 Select 'Rajasthan' , N'Chittorgarh' , N'Begun' UNION ALL 
 Select 'Rajasthan' , N'Chittorgarh' , N'Bhadesar' UNION ALL 
 Select 'Rajasthan' , N'Chittorgarh' , N'Bhainsrorgarh' UNION ALL 
 Select 'Rajasthan' , N'Chittorgarh' , N'Bhopalsagar' UNION ALL 
 Select 'Rajasthan' , N'Chittorgarh' , N'Chittorgarh' UNION ALL 
 Select 'Rajasthan' , N'Chittorgarh' , N'Dungla' UNION ALL 
 Select 'Rajasthan' , N'Chittorgarh' , N'Gangrar' UNION ALL 
 Select 'Rajasthan' , N'Chittorgarh' , N'Kapasan' UNION ALL 
 Select 'Rajasthan' , N'Chittorgarh' , N'Nimbahera' UNION ALL 
 Select 'Rajasthan' , N'Chittorgarh' , N'Rashmi' UNION ALL 
 Select 'Rajasthan' , N'Churu' , N'Bidasar' UNION ALL 
 Select 'Rajasthan' , N'Churu' , N'Churu' UNION ALL 
 Select 'Rajasthan' , N'Churu' , N'Rajgarh' UNION ALL 
 Select 'Rajasthan' , N'Churu' , N'Ratangarh' UNION ALL 
 Select 'Rajasthan' , N'Churu' , N'Sardarshahar' UNION ALL 
 Select 'Rajasthan' , N'Churu' , N'Sidhmukh' UNION ALL 
 Select 'Rajasthan' , N'Churu' , N'Sujangarh' UNION ALL 
 Select 'Rajasthan' , N'Churu' , N'Taranagar' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Baijupada' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Bandikui' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Baswa' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Dausa' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Lalsot' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Lawan' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Mahwa' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Mandaawar' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Nangal Rajawatan' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Ramgarh Pachwara' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Sikandara' UNION ALL 
 Select 'Rajasthan' , N'Dausa' , N'Sikrai' UNION ALL 
 Select 'Rajasthan' , N'Deeg' , N'Deeg' UNION ALL 
 Select 'Rajasthan' , N'Deeg' , N'Kaman' UNION ALL 
 Select 'Rajasthan' , N'Deeg' , N'Kumher' UNION ALL 
 Select 'Rajasthan' , N'Deeg' , N'Nagar Pahari' UNION ALL 
 Select 'Rajasthan' , N'Deeg' , N'Pahari' UNION ALL 
 Select 'Rajasthan' , N'Dholpur' , N'Bari' UNION ALL 
 Select 'Rajasthan' , N'Dholpur' , N'Baseri' UNION ALL 
 Select 'Rajasthan' , N'Dholpur' , N'Dhaulpur' UNION ALL 
 Select 'Rajasthan' , N'Dholpur' , N'Rajakhera' UNION ALL 
 Select 'Rajasthan' , N'Dholpur' , N'Saipau' UNION ALL 
 Select 'Rajasthan' , N'Dholpur' , N'Sarmathura' UNION ALL 
 Select 'Rajasthan' , N'Didwana-Kuchaman' , N'Didwana' UNION ALL 
 Select 'Rajasthan' , N'Didwana-Kuchaman' , N'Kuchaman' UNION ALL 
 Select 'Rajasthan' , N'Didwana-Kuchaman' , N'Ladnu' UNION ALL 
 Select 'Rajasthan' , N'Didwana-Kuchaman' , N'Makrana' UNION ALL 
 Select 'Rajasthan' , N'Didwana-Kuchaman' , N'Molasar' UNION ALL 
 Select 'Rajasthan' , N'Didwana-Kuchaman' , N'Nawa' UNION ALL 
 Select 'Rajasthan' , N'Didwana-Kuchaman' , N'Parbatsar' UNION ALL 
 Select 'Rajasthan' , N'Dudu' , N'Dudu' UNION ALL 
 Select 'Rajasthan' , N'Dudu' , N'Mauzamabad' UNION ALL 
 Select 'Rajasthan' , N'Dudu' , N'Phagi' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Aspur' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Bichiwara' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Chikhali' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Dovada' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Dungarpur' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Galiyakoat' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Gamdi Ahara' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Jothari' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Paldeval' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Sabla' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Sagwara' UNION ALL 
 Select 'Rajasthan' , N'Dungarpur' , N'Simalwara' UNION ALL 
 Select 'Rajasthan' , N'Ganganagar' , N'Ganganagar' UNION ALL 
 Select 'Rajasthan' , N'Ganganagar' , N'Karanpur' UNION ALL 
 Select 'Rajasthan' , N'Ganganagar' , N'Padampur' UNION ALL 
 Select 'Rajasthan' , N'Ganganagar' , N'Sadulshahar' UNION ALL 
 Select 'Rajasthan' , N'Ganganagar' , N'Suratgarh' UNION ALL 
 Select 'Rajasthan' , N'Gangapurcity' , N'Bamanwas' UNION ALL 
 Select 'Rajasthan' , N'Gangapurcity' , N'Gangapur City' UNION ALL 
 Select 'Rajasthan' , N'Gangapurcity' , N'Nadauti' UNION ALL 
 Select 'Rajasthan' , N'Hanumangarh' , N'Bhadra' UNION ALL 
 Select 'Rajasthan' , N'Hanumangarh' , N'Hanumangarh' UNION ALL 
 Select 'Rajasthan' , N'Hanumangarh' , N'Nohar' UNION ALL 
 Select 'Rajasthan' , N'Hanumangarh' , N'Pilibanga' UNION ALL 
 Select 'Rajasthan' , N'Hanumangarh' , N'Rawatsar' UNION ALL 
 Select 'Rajasthan' , N'Hanumangarh' , N'Sangaria' UNION ALL 
 Select 'Rajasthan' , N'Hanumangarh' , N'Tibbi' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Amber' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Andhi' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Bassi' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Chaksu' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Govindgarh' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Jalsu' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Jamwa Ramgarh' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Jhotwara' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Jobner' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Kishangarh Renwal' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Kotkhawda' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Madhorajpura' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Sambhar' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Sanganer' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Shahpura' UNION ALL 
 Select 'Rajasthan' , N'Jaipur (Gramin)' , N'Tunga' UNION ALL 
 Select 'Rajasthan' , N'Jaisalmer' , N'Bhaniyana' UNION ALL 
 Select 'Rajasthan' , N'Jaisalmer' , N'Fatehgarh' UNION ALL 
 Select 'Rajasthan' , N'Jaisalmer' , N'Jaisalmer' UNION ALL 
 Select 'Rajasthan' , N'Jaisalmer' , N'Mohangarh' UNION ALL 
 Select 'Rajasthan' , N'Jaisalmer' , N'Sam' UNION ALL 
 Select 'Rajasthan' , N'Jaisalmer' , N'Sankra' UNION ALL 
 Select 'Rajasthan' , N'Jalore' , N'Ahore' UNION ALL 
 Select 'Rajasthan' , N'Jalore' , N'Jalore' UNION ALL 
 Select 'Rajasthan' , N'Jalore' , N'Jaswantpura' UNION ALL 
 Select 'Rajasthan' , N'Jalore' , N'Sayla' UNION ALL 
 Select 'Rajasthan' , N'Jhalawar' , N'Aklera' UNION ALL 
 Select 'Rajasthan' , N'Jhalawar' , N'Bakani' UNION ALL 
 Select 'Rajasthan' , N'Jhalawar' , N'Bhawani Mandi' UNION ALL 
 Select 'Rajasthan' , N'Jhalawar' , N'Dag' UNION ALL 
 Select 'Rajasthan' , N'Jhalawar' , N'Jhalrapatan' UNION ALL 
 Select 'Rajasthan' , N'Jhalawar' , N'Khanpur' UNION ALL 
 Select 'Rajasthan' , N'Jhalawar' , N'Manoharthana' UNION ALL 
 Select 'Rajasthan' , N'Jhalawar' , N'Pirawa (Sunel)' UNION ALL 
 Select 'Rajasthan' , N'Jhunjhunu' , N'Alsisar' UNION ALL 
 Select 'Rajasthan' , N'Jhunjhunu' , N'Buhana' UNION ALL 
 Select 'Rajasthan' , N'Jhunjhunu' , N'Chirawa' UNION ALL 
 Select 'Rajasthan' , N'Jhunjhunu' , N'Jhunjhunu' UNION ALL 
 Select 'Rajasthan' , N'Jhunjhunu' , N'Mandawa' UNION ALL 
 Select 'Rajasthan' , N'Jhunjhunu' , N'Nawalgarh' UNION ALL 
 Select 'Rajasthan' , N'Jhunjhunu' , N'Pilani' UNION ALL 
 Select 'Rajasthan' , N'Jhunjhunu' , N'Singhana' UNION ALL 
 Select 'Rajasthan' , N'Jhunjhunu' , N'Surajgarh' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Balesar' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Bawadi' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Bhopalgarh' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Bilara' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Chamu' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Dhawa' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Keru' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Luni' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Mandor' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Osian' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Peepad Sahar' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Sekhala' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Shergarh' UNION ALL 
 Select 'Rajasthan' , N'Jodhpur (Gramin)' , N'Tinwari' UNION ALL 
 Select 'Rajasthan' , N'Karauli' , N'Hindaun' UNION ALL 
 Select 'Rajasthan' , N'Karauli' , N'Karauli' UNION ALL 
 Select 'Rajasthan' , N'Karauli' , N'Mandrayal' UNION ALL 
 Select 'Rajasthan' , N'Karauli' , N'Masalpur' UNION ALL 
 Select 'Rajasthan' , N'Karauli' , N'Sapotra' UNION ALL 
 Select 'Rajasthan' , N'Karauli' , N'Sri Mahaveer Ji' UNION ALL 
 Select 'Rajasthan' , N'Kekri' , N'Bhinay' UNION ALL 
 Select 'Rajasthan' , N'Kekri' , N'Kekri' UNION ALL 
 Select 'Rajasthan' , N'Kekri' , N'Sarwar' UNION ALL 
 Select 'Rajasthan' , N'Kekri' , N'Sawar' UNION ALL 
 Select 'Rajasthan' , N'Khairthal-Tijara' , N'Kishangarh Bas' UNION ALL 
 Select 'Rajasthan' , N'Khairthal-Tijara' , N'Kotkasim' UNION ALL 
 Select 'Rajasthan' , N'Khairthal-Tijara' , N'Mandawar' UNION ALL 
 Select 'Rajasthan' , N'Khairthal-Tijara' , N'Tijara' UNION ALL 
 Select 'Rajasthan' , N'Kota' , N'Itawa' UNION ALL 
 Select 'Rajasthan' , N'Kota' , N'Khairabad' UNION ALL 
 Select 'Rajasthan' , N'Kota' , N'Ladpura' UNION ALL 
 Select 'Rajasthan' , N'Kota' , N'Sangod' UNION ALL 
 Select 'Rajasthan' , N'Kota' , N'Sultanpur' UNION ALL 
 Select 'Rajasthan' , N'Kotputli-Behror' , N'Bansur' UNION ALL 
 Select 'Rajasthan' , N'Kotputli-Behror' , N'Behror' UNION ALL 
 Select 'Rajasthan' , N'Kotputli-Behror' , N'Kotputli' UNION ALL 
 Select 'Rajasthan' , N'Kotputli-Behror' , N'Neemrana' UNION ALL 
 Select 'Rajasthan' , N'Kotputli-Behror' , N'Paota' UNION ALL 
 Select 'Rajasthan' , N'Nagaur' , N'Bherunda' UNION ALL 
 Select 'Rajasthan' , N'Nagaur' , N'Degana' UNION ALL 
 Select 'Rajasthan' , N'Nagaur' , N'Jayal' UNION ALL 
 Select 'Rajasthan' , N'Nagaur' , N'Khinvsar' UNION ALL 
 Select 'Rajasthan' , N'Nagaur' , N'Merta' UNION ALL 
 Select 'Rajasthan' , N'Nagaur' , N'Mundwa' UNION ALL 
 Select 'Rajasthan' , N'Nagaur' , N'Nagaur' UNION ALL 
 Select 'Rajasthan' , N'Nagaur' , N'Riyan Badi' UNION ALL 
 Select 'Rajasthan' , N'Neem Ka Thana' , N'Ajeetgarh' UNION ALL 
 Select 'Rajasthan' , N'Neem Ka Thana' , N'Neem Ka Thana' UNION ALL 
 Select 'Rajasthan' , N'Neem Ka Thana' , N'Patan' UNION ALL 
 Select 'Rajasthan' , N'Neem Ka Thana' , N'Sri Madhopur' UNION ALL 
 Select 'Rajasthan' , N'Pali' , N'Bagari' UNION ALL 
 Select 'Rajasthan' , N'Pali' , N'Bali' UNION ALL 
 Select 'Rajasthan' , N'Pali' , N'Desuri' UNION ALL 
 Select 'Rajasthan' , N'Pali' , N'Kharchi(Mar.Jun)' UNION ALL 
 Select 'Rajasthan' , N'Pali' , N'Pali' UNION ALL 
 Select 'Rajasthan' , N'Pali' , N'Rani Station' UNION ALL 
 Select 'Rajasthan' , N'Pali' , N'Rohat' UNION ALL 
 Select 'Rajasthan' , N'Pali' , N'Sojat' UNION ALL 
 Select 'Rajasthan' , N'Pali' , N'Sumerpur' UNION ALL 
 Select 'Rajasthan' , N'Phalodi' , N'Aau' UNION ALL 
 Select 'Rajasthan' , N'Phalodi' , N'Bap' UNION ALL 
 Select 'Rajasthan' , N'Phalodi' , N'Bapini' UNION ALL 
 Select 'Rajasthan' , N'Phalodi' , N'Dechu' UNION ALL 
 Select 'Rajasthan' , N'Phalodi' , N'Ghantiyali' UNION ALL 
 Select 'Rajasthan' , N'Phalodi' , N'Lohawat' UNION ALL 
 Select 'Rajasthan' , N'Phalodi' , N'Phalodi' UNION ALL 
 Select 'Rajasthan' , N'Pratapgarh' , N'Arnod' UNION ALL 
 Select 'Rajasthan' , N'Pratapgarh' , N'Chhoti Sadri' UNION ALL 
 Select 'Rajasthan' , N'Pratapgarh' , N'Dalot' UNION ALL 
 Select 'Rajasthan' , N'Pratapgarh' , N'Dhamotar' UNION ALL 
 Select 'Rajasthan' , N'Pratapgarh' , N'Dhariawad' UNION ALL 
 Select 'Rajasthan' , N'Pratapgarh' , N'Peepal Khoont' UNION ALL 
 Select 'Rajasthan' , N'Pratapgarh' , N'Pratapgarh' UNION ALL 
 Select 'Rajasthan' , N'Pratapgarh' , N'Suhagpura' UNION ALL 
 Select 'Rajasthan' , N'Rajsamand' , N'Amet' UNION ALL 
 Select 'Rajasthan' , N'Rajsamand' , N'Delwada' UNION ALL 
 Select 'Rajasthan' , N'Rajsamand' , N'Deogarh' UNION ALL 
 Select 'Rajasthan' , N'Rajsamand' , N'Khamnor' UNION ALL 
 Select 'Rajasthan' , N'Rajsamand' , N'Kumbhalgarh' UNION ALL 
 Select 'Rajasthan' , N'Rajsamand' , N'Railmagra' UNION ALL 
 Select 'Rajasthan' , N'Rajsamand' , N'Rajsamand' UNION ALL 
 Select 'Rajasthan' , N'Salumbar' , N'Jaisamand' UNION ALL 
 Select 'Rajasthan' , N'Salumbar' , N'Jhallara' UNION ALL 
 Select 'Rajasthan' , N'Salumbar' , N'Lasadiya' UNION ALL 
 Select 'Rajasthan' , N'Salumbar' , N'Salumbar' UNION ALL 
 Select 'Rajasthan' , N'Salumbar' , N'Sarada' UNION ALL 
 Select 'Rajasthan' , N'Salumbar' , N'Semari' UNION ALL 
 Select 'Rajasthan' , N'Sanchore' , N'Bagoda' UNION ALL 
 Select 'Rajasthan' , N'Sanchore' , N'Chitalwana' UNION ALL 
 Select 'Rajasthan' , N'Sanchore' , N'Raniwara' UNION ALL 
 Select 'Rajasthan' , N'Sanchore' , N'Sanchore' UNION ALL 
 Select 'Rajasthan' , N'Sanchore' , N'Sarnau' UNION ALL 
 Select 'Rajasthan' , N'Sawai Madhopur' , N'Bonli' UNION ALL 
 Select 'Rajasthan' , N'Sawai Madhopur' , N'Chauth Ka Barwara' UNION ALL 
 Select 'Rajasthan' , N'Sawai Madhopur' , N'Khandar' UNION ALL 
 Select 'Rajasthan' , N'Sawai Madhopur' , N'Malarna Doongar' UNION ALL 
 Select 'Rajasthan' , N'Sawai Madhopur' , N'Sawai Madhopur' UNION ALL 
 Select 'Rajasthan' , N'Shahpura' , N'Jahazpur' UNION ALL 
 Select 'Rajasthan' , N'Shahpura' , N'Shahpura' UNION ALL 
 Select 'Rajasthan' , N'Sikar' , N'Danta Ramgarh' UNION ALL 
 Select 'Rajasthan' , N'Sikar' , N'Dhod' UNION ALL 
 Select 'Rajasthan' , N'Sikar' , N'Fatehpur' UNION ALL 
 Select 'Rajasthan' , N'Sikar' , N'Khandela' UNION ALL 
 Select 'Rajasthan' , N'Sikar' , N'Lachhmangarh' UNION ALL 
 Select 'Rajasthan' , N'Sikar' , N'Nechwa' UNION ALL 
 Select 'Rajasthan' , N'Sikar' , N'Palsana' UNION ALL 
 Select 'Rajasthan' , N'Sikar' , N'Piprali' UNION ALL 
 Select 'Rajasthan' , N'Sirohi' , N'Abu Road' UNION ALL 
 Select 'Rajasthan' , N'Sirohi' , N'Pindwara' UNION ALL 
 Select 'Rajasthan' , N'Sirohi' , N'Reodar' UNION ALL 
 Select 'Rajasthan' , N'Sirohi' , N'Sheoganj' UNION ALL 
 Select 'Rajasthan' , N'Sirohi' , N'Sirohi' UNION ALL 
 Select 'Rajasthan' , N'Tonk' , N'Deoli' UNION ALL 
 Select 'Rajasthan' , N'Tonk' , N'Malpura' UNION ALL 
 Select 'Rajasthan' , N'Tonk' , N'Newai' UNION ALL 
 Select 'Rajasthan' , N'Tonk' , N'Peeplu' UNION ALL 
 Select 'Rajasthan' , N'Tonk' , N'Tonk' UNION ALL 
 Select 'Rajasthan' , N'Tonk' , N'Uniara' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Bargaon' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Bhinder' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Devla' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Girwa' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Gogunda' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Jhadol' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Khemli' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Kherwara' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Kotra' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Kurabad' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Mavli' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Nayagaon' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Phalasiya' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Rishbhdeo' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Sayra' UNION ALL 
 Select 'Rajasthan' , N'Udaipur' , N'Vallabhnagar'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Sikkim' , N'Gangtok' , N'Khamdong' UNION ALL 
 Select 'Sikkim' , N'Gangtok' , N'Martam' UNION ALL 
 Select 'Sikkim' , N'Gangtok' , N'Nandok' UNION ALL 
 Select 'Sikkim' , N'Gangtok' , N'Rakdong Tintek' UNION ALL 
 Select 'Sikkim' , N'Gangtok' , N'Ranka' UNION ALL 
 Select 'Sikkim' , N'Gyalshing' , N'Arithang Chongrang' UNION ALL 
 Select 'Sikkim' , N'Gyalshing' , N'Dentam' UNION ALL 
 Select 'Sikkim' , N'Gyalshing' , N'Gyalshing' UNION ALL 
 Select 'Sikkim' , N'Gyalshing' , N'Hee Martam' UNION ALL 
 Select 'Sikkim' , N'Gyalshing' , N'Yuksom' UNION ALL 
 Select 'Sikkim' , N'Mangan' , N'Chungthang' UNION ALL 
 Select 'Sikkim' , N'Mangan' , N'Kabi Tingda' UNION ALL 
 Select 'Sikkim' , N'Mangan' , N'Mangan' UNION ALL 
 Select 'Sikkim' , N'Mangan' , N'Passingdang' UNION ALL 
 Select 'Sikkim' , N'Namchi' , N'Jorethang' UNION ALL 
 Select 'Sikkim' , N'Namchi' , N'Namchi' UNION ALL 
 Select 'Sikkim' , N'Namchi' , N'Namthang' UNION ALL 
 Select 'Sikkim' , N'Namchi' , N'Ravangla' UNION ALL 
 Select 'Sikkim' , N'Namchi' , N'Sumbuk' UNION ALL 
 Select 'Sikkim' , N'Namchi' , N'Temi' UNION ALL 
 Select 'Sikkim' , N'Namchi' , N'Wok' UNION ALL 
 Select 'Sikkim' , N'Namchi' , N'Yangang' UNION ALL 
 Select 'Sikkim' , N'Pakyong' , N'Duga' UNION ALL 
 Select 'Sikkim' , N'Pakyong' , N'Namcheybong' UNION ALL 
 Select 'Sikkim' , N'Pakyong' , N'Pakyong' UNION ALL 
 Select 'Sikkim' , N'Pakyong' , N'Parkha' UNION ALL 
 Select 'Sikkim' , N'Pakyong' , N'Reghu' UNION ALL 
 Select 'Sikkim' , N'Pakyong' , N'Rhenock' UNION ALL 
 Select 'Sikkim' , N'Soreng' , N'Baiguney' UNION ALL 
 Select 'Sikkim' , N'Soreng' , N'Chumbong Chakung' UNION ALL 
 Select 'Sikkim' , N'Soreng' , N'Daramdin' UNION ALL 
 Select 'Sikkim' , N'Soreng' , N'Kaluk' UNION ALL 
 Select 'Sikkim' , N'Soreng' , N'Mangalbarey' UNION ALL 
 Select 'Sikkim' , N'Soreng' , N'Soreng'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Tamil Nadu' , N'Ariyalur' , N'Andimadam' UNION ALL 
 Select 'Tamil Nadu' , N'Ariyalur' , N'Ariyalur' UNION ALL 
 Select 'Tamil Nadu' , N'Ariyalur' , N'Jayamkondam' UNION ALL 
 Select 'Tamil Nadu' , N'Ariyalur' , N'Sendurai' UNION ALL 
 Select 'Tamil Nadu' , N'Ariyalur' , N'Thirumanur' UNION ALL 
 Select 'Tamil Nadu' , N'Ariyalur' , N'T. Palur' UNION ALL 
 Select 'Tamil Nadu' , N'Chengalpattu' , N'Acharapakkam' UNION ALL 
 Select 'Tamil Nadu' , N'Chengalpattu' , N'Chithamur' UNION ALL 
 Select 'Tamil Nadu' , N'Chengalpattu' , N'Kattankolathur' UNION ALL 
 Select 'Tamil Nadu' , N'Chengalpattu' , N'Lathur' UNION ALL 
 Select 'Tamil Nadu' , N'Chengalpattu' , N'Madurantakam' UNION ALL 
 Select 'Tamil Nadu' , N'Chengalpattu' , N'St.Thomas Mount' UNION ALL 
 Select 'Tamil Nadu' , N'Chengalpattu' , N'Thiruporur' UNION ALL 
 Select 'Tamil Nadu' , N'Chengalpattu' , N'Tirukkalukunram' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Anamalai' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Annur' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Karamadai' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Kinathukadavu' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Madukkarai' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Periyanayakkanpalayam' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Pollachi North' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Pollachi South' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Sarcarsamakulam' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Sultanpet' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Sulur' UNION ALL 
 Select 'Tamil Nadu' , N'Coimbatore' , N'Thondamuthur' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Annagramam' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Cuddalore' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Kammapuram' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Kattumannarkoil' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Keerapalayam' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Komaratchi' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Kurinjipadi' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Mangalur' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Melbhuvanagiri' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Nallur' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Panruti' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Parangipettai' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Srimushnam' UNION ALL 
 Select 'Tamil Nadu' , N'Cuddalore' , N'Vriddhachalam' UNION ALL 
 Select 'Tamil Nadu' , N'Dharmapuri' , N'Dharmapuri' UNION ALL 
 Select 'Tamil Nadu' , N'Dharmapuri' , N'Eriyur' UNION ALL 
 Select 'Tamil Nadu' , N'Dharmapuri' , N'Harur' UNION ALL 
 Select 'Tamil Nadu' , N'Dharmapuri' , N'Kadathur' UNION ALL 
 Select 'Tamil Nadu' , N'Dharmapuri' , N'Karimangalam' UNION ALL 
 Select 'Tamil Nadu' , N'Dharmapuri' , N'Morappur' UNION ALL 
 Select 'Tamil Nadu' , N'Dharmapuri' , N'Nallampalli' UNION ALL 
 Select 'Tamil Nadu' , N'Dharmapuri' , N'Palakkodu' UNION ALL 
 Select 'Tamil Nadu' , N'Dharmapuri' , N'Pappireddipatty' UNION ALL 
 Select 'Tamil Nadu' , N'Dharmapuri' , N'Pennagaram' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Athoor' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Dindigul' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Guziliamparai' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Kodaikanal' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Nattam' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Nilakottai' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Oddanchatram' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Palani' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Reddiyarchatiram' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Shanarpatti' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Thoppampatti' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Vadamadurai' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Vattalkundu' UNION ALL 
 Select 'Tamil Nadu' , N'Dindigul' , N'Vedasandur' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Ammapet' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Andiyur' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Bhavani' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Bhavanisagar' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Chennimalai' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Erode' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Gopichettipalaiyam' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Kodumudi' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Modakurichi' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Nambiyur' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Perundurai' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Satyamangalam' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Talavadi' UNION ALL 
 Select 'Tamil Nadu' , N'Erode' , N'Thoockanaickenpalaiyam' UNION ALL 
 Select 'Tamil Nadu' , N'Kallakurichi' , N'Chinnasalem' UNION ALL 
 Select 'Tamil Nadu' , N'Kallakurichi' , N'Kallakkurichi' UNION ALL 
 Select 'Tamil Nadu' , N'Kallakurichi' , N'Kalrayanhills' UNION ALL 
 Select 'Tamil Nadu' , N'Kallakurichi' , N'Rishivandiam' UNION ALL 
 Select 'Tamil Nadu' , N'Kallakurichi' , N'Sankarapuram' UNION ALL 
 Select 'Tamil Nadu' , N'Kallakurichi' , N'Thiagadurgam' UNION ALL 
 Select 'Tamil Nadu' , N'Kallakurichi' , N'Tirukkoyilur' UNION ALL 
 Select 'Tamil Nadu' , N'Kallakurichi' , N'Tirunavalur' UNION ALL 
 Select 'Tamil Nadu' , N'Kallakurichi' , N'Ulundurpet' UNION ALL 
 Select 'Tamil Nadu' , N'Kancheepuram' , N'Kanchipuram' UNION ALL 
 Select 'Tamil Nadu' , N'Kancheepuram' , N'Kunnattur' UNION ALL 
 Select 'Tamil Nadu' , N'Kancheepuram' , N'Sriperumbudur' UNION ALL 
 Select 'Tamil Nadu' , N'Kancheepuram' , N'Uttiramerur' UNION ALL 
 Select 'Tamil Nadu' , N'Kancheepuram' , N'Walajabad' UNION ALL 
 Select 'Tamil Nadu' , N'Kanniyakumari' , N'Agastiswaram' UNION ALL 
 Select 'Tamil Nadu' , N'Kanniyakumari' , N'Killiyoor' UNION ALL 
 Select 'Tamil Nadu' , N'Kanniyakumari' , N'Kurunthancode' UNION ALL 
 Select 'Tamil Nadu' , N'Kanniyakumari' , N'Melpuram' UNION ALL 
 Select 'Tamil Nadu' , N'Kanniyakumari' , N'Munchira' UNION ALL 
 Select 'Tamil Nadu' , N'Kanniyakumari' , N'Rajakkamangalam' UNION ALL 
 Select 'Tamil Nadu' , N'Kanniyakumari' , N'Thackalai' UNION ALL 
 Select 'Tamil Nadu' , N'Kanniyakumari' , N'Thiruvattar' UNION ALL 
 Select 'Tamil Nadu' , N'Kanniyakumari' , N'Thovala' UNION ALL 
 Select 'Tamil Nadu' , N'Karur' , N'Aravakurichi' UNION ALL 
 Select 'Tamil Nadu' , N'Karur' , N'Kadavur' UNION ALL 
 Select 'Tamil Nadu' , N'Karur' , N'Karur' UNION ALL 
 Select 'Tamil Nadu' , N'Karur' , N'K.Paramathy' UNION ALL 
 Select 'Tamil Nadu' , N'Karur' , N'Krishnarayapuram' UNION ALL 
 Select 'Tamil Nadu' , N'Karur' , N'Kulittalai' UNION ALL 
 Select 'Tamil Nadu' , N'Karur' , N'Thanthoni' UNION ALL 
 Select 'Tamil Nadu' , N'Karur' , N'Thogaimalai' UNION ALL 
 Select 'Tamil Nadu' , N'Krishnagiri' , N'Bargur' UNION ALL 
 Select 'Tamil Nadu' , N'Krishnagiri' , N'Hosur' UNION ALL 
 Select 'Tamil Nadu' , N'Krishnagiri' , N'Kaveripattinam' UNION ALL 
 Select 'Tamil Nadu' , N'Krishnagiri' , N'Kelamangalam' UNION ALL 
 Select 'Tamil Nadu' , N'Krishnagiri' , N'Krishnagiri' UNION ALL 
 Select 'Tamil Nadu' , N'Krishnagiri' , N'Mathur' UNION ALL 
 Select 'Tamil Nadu' , N'Krishnagiri' , N'Shoolagiri' UNION ALL 
 Select 'Tamil Nadu' , N'Krishnagiri' , N'Thally' UNION ALL 
 Select 'Tamil Nadu' , N'Krishnagiri' , N'Uthangarai' UNION ALL 
 Select 'Tamil Nadu' , N'Krishnagiri' , N'Veppanapalli' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Alanganallur' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Chellampatti' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Kallikudi' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Kottampatti' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Madurai East' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Madurai West' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Melur' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Sedapatti' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Tirumangalam' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Tirupparangunram' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'T.Kallupatti' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Usilampatti' UNION ALL 
 Select 'Tamil Nadu' , N'Madurai' , N'Vadipatti' UNION ALL 
 Select 'Tamil Nadu' , N'Nagapattinam' , N'Keelaiyur' UNION ALL 
 Select 'Tamil Nadu' , N'Nagapattinam' , N'Kilvelur' UNION ALL 
 Select 'Tamil Nadu' , N'Nagapattinam' , N'Kollidam' UNION ALL 
 Select 'Tamil Nadu' , N'Nagapattinam' , N'Kuttalam' UNION ALL 
 Select 'Tamil Nadu' , N'Nagapattinam' , N'Mayiladuthurai' UNION ALL 
 Select 'Tamil Nadu' , N'Nagapattinam' , N'Nagappattinam' UNION ALL 
 Select 'Tamil Nadu' , N'Nagapattinam' , N'Sembanar Koil' UNION ALL 
 Select 'Tamil Nadu' , N'Nagapattinam' , N'Sirkazhi' UNION ALL 
 Select 'Tamil Nadu' , N'Nagapattinam' , N'Thalanayar' UNION ALL 
 Select 'Tamil Nadu' , N'Nagapattinam' , N'Thirumarugal' UNION ALL 
 Select 'Tamil Nadu' , N'Nagapattinam' , N'Vedaranyam' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Elacipalayam' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Erumapatty' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Kabilamalai' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Kolli Hills' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Mallasamudram' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Mohanur' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Namagiripet' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Namakkal' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Pallipalayam' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Paramathy' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Puduchatram' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Rasipuram' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Sendamangalam' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Tiruchengodu' UNION ALL 
 Select 'Tamil Nadu' , N'Namakkal' , N'Vennandur' UNION ALL 
 Select 'Tamil Nadu' , N'Perambalur' , N'Alathur' UNION ALL 
 Select 'Tamil Nadu' , N'Perambalur' , N'Perambalur' UNION ALL 
 Select 'Tamil Nadu' , N'Perambalur' , N'Veppanthattai' UNION ALL 
 Select 'Tamil Nadu' , N'Perambalur' , N'Veppur' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Annavasal' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Arantangi' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Arimalam' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Avadaiyarkovil' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Gandaravakottai' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Karambakudi' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Kunnandarkoil' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Manalmelkudi' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Ponnamaravati' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Pudukkottai' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Thiruvarankulam' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Tirumayam' UNION ALL 
 Select 'Tamil Nadu' , N'Pudukkottai' , N'Viralimalai' UNION ALL 
 Select 'Tamil Nadu' , N'Ramanathapuram' , N'Bogalur' UNION ALL 
 Select 'Tamil Nadu' , N'Ramanathapuram' , N'Kadaladi' UNION ALL 
 Select 'Tamil Nadu' , N'Ramanathapuram' , N'Kamudi' UNION ALL 
 Select 'Tamil Nadu' , N'Ramanathapuram' , N'Mandapam' UNION ALL 
 Select 'Tamil Nadu' , N'Ramanathapuram' , N'Mudukulathur' UNION ALL 
 Select 'Tamil Nadu' , N'Ramanathapuram' , N'Nainarkoil' UNION ALL 
 Select 'Tamil Nadu' , N'Ramanathapuram' , N'Paramakkudi' UNION ALL 
 Select 'Tamil Nadu' , N'Ramanathapuram' , N'Rajasingamangalam' UNION ALL 
 Select 'Tamil Nadu' , N'Ramanathapuram' , N'Ramanathapuram' UNION ALL 
 Select 'Tamil Nadu' , N'Ramanathapuram' , N'Tiruppullani' UNION ALL 
 Select 'Tamil Nadu' , N'Ramanathapuram' , N'Tiruvadanai' UNION ALL 
 Select 'Tamil Nadu' , N'Ranipet' , N'Arakkonam' UNION ALL 
 Select 'Tamil Nadu' , N'Ranipet' , N'Arcot' UNION ALL 
 Select 'Tamil Nadu' , N'Ranipet' , N'Kaveripakkam' UNION ALL 
 Select 'Tamil Nadu' , N'Ranipet' , N'Nemili' UNION ALL 
 Select 'Tamil Nadu' , N'Ranipet' , N'Sholinghur' UNION ALL 
 Select 'Tamil Nadu' , N'Ranipet' , N'Timiri' UNION ALL 
 Select 'Tamil Nadu' , N'Ranipet' , N'Walajapet' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Attur' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Ayodhiyapattinam' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Gangavalli' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Idappadi' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Kadaiyampatty' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Kolathur' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Konganapuram' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Macdonalds Choultry' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Mecheri' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Nangavalli' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Omalur' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Panamarathupatti' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Peddanaickenpalayam' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Salem' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Sankari' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Talavasal' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Taramangalam' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Valapady' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Veerapandi' UNION ALL 
 Select 'Tamil Nadu' , N'Salem' , N'Yercaud' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'Devakottai' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'Ilayankudi' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'Kalaiyarkoil' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'Kallal' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'Kannankudi' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'Manamadurai' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'Sakkottai' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'Singampunari' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'Sivaganga' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'S. Pudur' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'Tiruppathur' UNION ALL 
 Select 'Tamil Nadu' , N'Sivaganga' , N'Tiruppuvanam' UNION ALL 
 Select 'Tamil Nadu' , N'Tenkasi' , N'Alangulam' UNION ALL 
 Select 'Tamil Nadu' , N'Tenkasi' , N'Kadaiyanallur' UNION ALL 
 Select 'Tamil Nadu' , N'Tenkasi' , N'Kadayam' UNION ALL 
 Select 'Tamil Nadu' , N'Tenkasi' , N'Keelapavoor' UNION ALL 
 Select 'Tamil Nadu' , N'Tenkasi' , N'Kuruvikulam' UNION ALL 
 Select 'Tamil Nadu' , N'Tenkasi' , N'Melaneelithanallur' UNION ALL 
 Select 'Tamil Nadu' , N'Tenkasi' , N'Sankarankovil' UNION ALL 
 Select 'Tamil Nadu' , N'Tenkasi' , N'Shencottah' UNION ALL 
 Select 'Tamil Nadu' , N'Tenkasi' , N'Tenkasi' UNION ALL 
 Select 'Tamil Nadu' , N'Tenkasi' , N'Vasudevanallur' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Ammapettai' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Budalur' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Kumbakonam' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Madukkur' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Orattanadu' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Papanasam' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Pattukkottai' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Peravurani' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Sethubhavachatram' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Thanjavur' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Thiruppanandal' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Thiruvaiyaru' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Thiruvonam' UNION ALL 
 Select 'Tamil Nadu' , N'Thanjavur' , N'Tiruvidaimarudur' UNION ALL 
 Select 'Tamil Nadu' , N'Theni' , N'Andipatti' UNION ALL 
 Select 'Tamil Nadu' , N'Theni' , N'Bodinayakkanur' UNION ALL 
 Select 'Tamil Nadu' , N'Theni' , N'Chinnamanur' UNION ALL 
 Select 'Tamil Nadu' , N'Theni' , N'Kadamalaikundru Myladumparai' UNION ALL 
 Select 'Tamil Nadu' , N'Theni' , N'Kambam' UNION ALL 
 Select 'Tamil Nadu' , N'Theni' , N'Periyakulam' UNION ALL 
 Select 'Tamil Nadu' , N'Theni' , N'Theni' UNION ALL 
 Select 'Tamil Nadu' , N'Theni' , N'Uttamapalaiyam' UNION ALL 
 Select 'Tamil Nadu' , N'The Nilgiris' , N'Coonoor' UNION ALL 
 Select 'Tamil Nadu' , N'The Nilgiris' , N'Gudalur' UNION ALL 
 Select 'Tamil Nadu' , N'The Nilgiris' , N'Kotagiri' UNION ALL 
 Select 'Tamil Nadu' , N'The Nilgiris' , N'Udhagamandalam' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Ellapuram' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Gummidipundi' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Kadambathur' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Minjur' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Pallipattu' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Poonamallee' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Poondi' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Puzhal' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'R.K.Pet' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Sholavaram' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Tiruttani' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Tiruvallur' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Tiruvelangadu' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvallur' , N'Villivakkam' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvarur' , N'Kodavasal' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvarur' , N'Koradacherry' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvarur' , N'Kottur' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvarur' , N'Mannargudi' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvarur' , N'Muthupettai' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvarur' , N'Nannilam' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvarur' , N'Nidamangalam' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvarur' , N'Thiruvarur' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvarur' , N'Tirutturaippundi' UNION ALL 
 Select 'Tamil Nadu' , N'Thiruvarur' , N'Valangaiman' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Alwarthirunagari' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Karungulam' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Kayathar' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Kovilpatti' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Ottapidaram' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Pudur' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Sattankulam' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Srivaikundam' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Thoothukkudi' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Tiruchendur' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Udangudi' UNION ALL 
 Select 'Tamil Nadu' , N'Thoothukkudi' , N'Vilathikulam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Andanallur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Lalgudi' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Manachanellur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Manapparai' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Manikandam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Marungapuri' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Musiri' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Pullambadi' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Tattayyangarpettai' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Thiruverambur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Thottiam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Turaiyur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Uppiliapuram' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruchirappalli' , N'Vaiyampatti' UNION ALL 
 Select 'Tamil Nadu' , N'Tirunelveli' , N'Ambasamudram' UNION ALL 
 Select 'Tamil Nadu' , N'Tirunelveli' , N'Cheranmahadevi' UNION ALL 
 Select 'Tamil Nadu' , N'Tirunelveli' , N'Kalakadu' UNION ALL 
 Select 'Tamil Nadu' , N'Tirunelveli' , N'Manur' UNION ALL 
 Select 'Tamil Nadu' , N'Tirunelveli' , N'Nanguneri' UNION ALL 
 Select 'Tamil Nadu' , N'Tirunelveli' , N'Palayamkottai' UNION ALL 
 Select 'Tamil Nadu' , N'Tirunelveli' , N'Pappakudi' UNION ALL 
 Select 'Tamil Nadu' , N'Tirunelveli' , N'Radhapuram' UNION ALL 
 Select 'Tamil Nadu' , N'Tirunelveli' , N'Valliyoor' UNION ALL 
 Select 'Tamil Nadu' , N'Tirupathur' , N'Alangayan' UNION ALL 
 Select 'Tamil Nadu' , N'Tirupathur' , N'Jolarpet' UNION ALL 
 Select 'Tamil Nadu' , N'Tirupathur' , N'Kandili' UNION ALL 
 Select 'Tamil Nadu' , N'Tirupathur' , N'Madhanur' UNION ALL 
 Select 'Tamil Nadu' , N'Tirupathur' , N'Natrampalli' UNION ALL 
 Select 'Tamil Nadu' , N'Tirupathur' , N'Tiruppattur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Avanashi' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Dharapuram' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Gudimangalam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Kangayam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Kundadam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Madathukulam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Mulanur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Palladam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Pongalur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Tiruppur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Udumalpet' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Uttukkuli' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruppur' , N'Vellakoil' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Anakkavur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Arani' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Chengam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Chetput' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Cheyyar' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Jawathu Hills' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Kalasapakkam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Keelpennathur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Pernamallur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Polur' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Pudupalayam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Thandrampet' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Thellar' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Thurinjapuram' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Tiruvannamalai' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Vandavasi' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'Vembakkam' UNION ALL 
 Select 'Tamil Nadu' , N'Tiruvannamalai' , N'West Arani' UNION ALL 
 Select 'Tamil Nadu' , N'Vellore' , N'Anaicut' UNION ALL 
 Select 'Tamil Nadu' , N'Vellore' , N'Gudiyattam' UNION ALL 
 Select 'Tamil Nadu' , N'Vellore' , N'Kaniyambadi' UNION ALL 
 Select 'Tamil Nadu' , N'Vellore' , N'Katpadi' UNION ALL 
 Select 'Tamil Nadu' , N'Vellore' , N'K.V.Kuppam' UNION ALL 
 Select 'Tamil Nadu' , N'Vellore' , N'Peranambattu' UNION ALL 
 Select 'Tamil Nadu' , N'Vellore' , N'Vellore' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Gingee' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Kanai' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Kandamangalam' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Koliyanur' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Mailam' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Marakkanam' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Melmalayanur' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Mugaiyur' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Olakkur' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Thiruvennainallur' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Vallam' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Vanur' UNION ALL 
 Select 'Tamil Nadu' , N'Viluppuram' , N'Vikravandi' UNION ALL 
 Select 'Tamil Nadu' , N'Virudhunagar' , N'Aruppukottai' UNION ALL 
 Select 'Tamil Nadu' , N'Virudhunagar' , N'Kariapatti' UNION ALL 
 Select 'Tamil Nadu' , N'Virudhunagar' , N'Narikudi' UNION ALL 
 Select 'Tamil Nadu' , N'Virudhunagar' , N'Rajapalaiyam' UNION ALL 
 Select 'Tamil Nadu' , N'Virudhunagar' , N'Sattur' UNION ALL 
 Select 'Tamil Nadu' , N'Virudhunagar' , N'Sivakasi' UNION ALL 
 Select 'Tamil Nadu' , N'Virudhunagar' , N'Srivilliputtur' UNION ALL 
 Select 'Tamil Nadu' , N'Virudhunagar' , N'Tiruchuli' UNION ALL 
 Select 'Tamil Nadu' , N'Virudhunagar' , N'Vembakottai' UNION ALL 
 Select 'Tamil Nadu' , N'Virudhunagar' , N'Virudhunagar' UNION ALL 
 Select 'Tamil Nadu' , N'Virudhunagar' , N'Watrap'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Telangana' , N'Adilabad' , N'Adilabad Rural' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Adilabad Urban' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Bazarhatnoor' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Bela' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Bheempur' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Boath' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Gadiguda' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Gudihatnur' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Ichoda' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Indervelly' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Jainath' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Mavala' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Narnoor' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Neradigonda' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Sirikonda' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Talamadugu' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Tamsi' UNION ALL 
 Select 'Telangana' , N'Adilabad' , N'Utnoor' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Allapalli' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Annapureddypalli' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Aswapuram' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Aswaraopeta' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Bhadrachalam' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Burgampahad' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Chandrugonda' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Cherla' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Chunchupalli' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Dammapeta' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Dummugudem' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Gundala' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Julurupadu' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Karakagudem' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Kothagudem' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Laxmidevipalli' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Manugur' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Mulakalapally' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Palwancha' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Pinapaka' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Sujathanagar' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Tekulapally' UNION ALL 
 Select 'Telangana' , N'Bhadradri Kothagudem' , N'Yellandu' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Atmakur' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Bheemadevarapalli' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Damera' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Dharmasagar' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Elkathurthi' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Hanamkonda' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Hasanparthy' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Inavole' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Kamalapur' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Khazipet' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Nadikuda' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Parkal' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Shayampet' UNION ALL 
 Select 'Telangana' , N'Hanumakonda' , N'Velair' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Amberpet' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Ameerpet' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Asifnagar' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Bahadurpura' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Bandlaguda' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Charminar' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Golconda' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Himayathnagar' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Khairthabad' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Marredpally' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Musheerabad' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Nampally' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Saidabad' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Secunderabad' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Shaikpet' UNION ALL 
 Select 'Telangana' , N'Hyderabad' , N'Tirumalagiry' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Beerpur' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Buggaram' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Dharmapuri' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Gollapalli' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Ibrahimpatnam' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Jagitial Rural' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Jagtial' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Kathalapur' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Kodimial' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Korutla' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Mallapur' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Mallial' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Medipalli' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Metpalli' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Pegadapalli' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Raikal' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Sarangapur' UNION ALL 
 Select 'Telangana' , N'Jagitial' , N'Velgatoor' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Bachannapeta' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Chilpur' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Devaruppula' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Ghanpur(Station)' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Jangaon' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Kodakandla' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Lingalaghanpur' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Narmetta' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Palakurthi' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Raghunathpalle' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Tharigoppula' UNION ALL 
 Select 'Telangana' , N'Jangoan' , N'Zaffergadh' UNION ALL 
 Select 'Telangana' , N'Jayashankar Bhupalapally' , N'Bhupalpalle' UNION ALL 
 Select 'Telangana' , N'Jayashankar Bhupalapally' , N'Chityal' UNION ALL 
 Select 'Telangana' , N'Jayashankar Bhupalapally' , N'Ghanapur (Mulug)' UNION ALL 
 Select 'Telangana' , N'Jayashankar Bhupalapally' , N'Kataram' UNION ALL 
 Select 'Telangana' , N'Jayashankar Bhupalapally' , N'Mahadevpur' UNION ALL 
 Select 'Telangana' , N'Jayashankar Bhupalapally' , N'Malhar Rao' UNION ALL 
 Select 'Telangana' , N'Jayashankar Bhupalapally' , N'Mogullapalle' UNION ALL 
 Select 'Telangana' , N'Jayashankar Bhupalapally' , N'Mutharam (Mahadevpur)' UNION ALL 
 Select 'Telangana' , N'Jayashankar Bhupalapally' , N'Palimela' UNION ALL 
 Select 'Telangana' , N'Jayashankar Bhupalapally' , N'Regonda' UNION ALL 
 Select 'Telangana' , N'Jayashankar Bhupalapally' , N'Tekumatla' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Alampur' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Dharur' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Gadwal' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Ghattu' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Ieeja' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Itikyal' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Kaloor Thimmandoddi' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Maldakal' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Manopadu' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Rajoli' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Undavelly' UNION ALL 
 Select 'Telangana' , N'Jogulamba Gadwal' , N'Waddepalle' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Banswada' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Bhiknur' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Bibipet' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Bichkunda' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Birkoor' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Domakonda' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Gandhari' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Jukkal' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Kamareddy' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Lingampet' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Machareddy' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Madnur' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Nagireddypet' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Nasurullabad' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Nizamsagar' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Pedda Kodapgal' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Pitlam' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Rajampet' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Ramareddy' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Sadasivanagar' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Tadwai' UNION ALL 
 Select 'Telangana' , N'Kamareddy' , N'Yellareddy' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Chigurumamidi' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Choppadandi' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Ellandakunta' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Gangadhara' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Ganneruvaram' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Huzurabad' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Jammikunta' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Karimnagar Rural' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Karimnagar Rural I' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Kothapally' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Manakondur' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Ramadugu' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Shankarapatnam' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Thimmapur (L.M.D.)' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'Veenavanka' UNION ALL 
 Select 'Telangana' , N'Karimnagar' , N'V. Saidapur' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Bonakal' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Chinthakani' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Enkoor' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Kallur' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Kamepally' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Khammam (Rural)' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Khammam (Urban)' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Konijerla' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Kusumanchi' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Madhira' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Mudigonda' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Nelakondapally' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Penubally' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Raghunadhapalem' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Sathupally' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Singareni' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Thallada' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Thirumalayapalem' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Vemsoor' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Wyra' UNION ALL 
 Select 'Telangana' , N'Khammam' , N'Yerrupalem' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Asifabad' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Bejjur' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Chintalamanepally' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Dahegaon' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Jainoor' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Kagaznagar' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Kerameri' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Kouthala' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Lingapur' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Penchicalpet' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Rebbena' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Sirpur (T)' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Sirpur (U)' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Tiryani' UNION ALL 
 Select 'Telangana' , N'Kumuram Bheem Asifabad' , N'Wankidi' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Bayyaram' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Chinnagudur' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Danthalapalle' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Dornakal' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Gangaram' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Garla' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Gudur' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Kesamudram' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Kothagudem' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Kuravi' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Mahbubabad' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Maripeda' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Nallikudur' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Narsimhulapet' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Peddavangara' UNION ALL 
 Select 'Telangana' , N'Mahabubabad' , N'Thorrur' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Addakal' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Balanagar' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Bhoothpur' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Chinnachintakunta' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Devarakadara' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Gandeed' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Hanwada' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Jadcherla' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Koilkonda' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Mahabubnagar Urban' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Mahbubnagar Rural' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Midjil' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Mohammadabad' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Moosapet' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Nawabpet' UNION ALL 
 Select 'Telangana' , N'Mahabubnagar' , N'Rajapur' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Bellampally' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Bheemaram' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Bheemini' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Chennur' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Dandepally' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Hajipur' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Jaipur' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Jannaram' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Kannepally' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Kasipet' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Kotapally' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Luxettipet' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Mancherial' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Mandamarri' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Naspur' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Nennel' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Tandur' UNION ALL 
 Select 'Telangana' , N'Mancherial' , N'Vemanpally' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Alladurg' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Chegunta' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Chilpched' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Havelighanapur' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Kowdipalli' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Kulcharam' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Manoharabad' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Masaipet' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Medak' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Narsapur' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Narsingi' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Nizampet' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Papannapet' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Ramayampet' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Regode' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Shankarampet[A]' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Shankarampet[R]' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Shivampet' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Tekmal' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Tupran' UNION ALL 
 Select 'Telangana' , N'Medak' , N'Yeldurthy' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Alwal' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Bachupally' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Balanagar' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Dundigal Gandimaisamma' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Ghatkesar' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Kapra' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Keesara' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Kukatpally' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Malkajgiri' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Medchal' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Medipally' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Muduchinthalapally' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Quthbullapur' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Shamirpet' UNION ALL 
 Select 'Telangana' , N'Medchal Malkajgiri' , N'Uppal' UNION ALL 
 Select 'Telangana' , N'Mulugu' , N'Eturnagaram' UNION ALL 
 Select 'Telangana' , N'Mulugu' , N'Govindaraopet' UNION ALL 
 Select 'Telangana' , N'Mulugu' , N'Kannaigudem' UNION ALL 
 Select 'Telangana' , N'Mulugu' , N'Mangapet' UNION ALL 
 Select 'Telangana' , N'Mulugu' , N'Mulug' UNION ALL 
 Select 'Telangana' , N'Mulugu' , N'Tadvai' UNION ALL 
 Select 'Telangana' , N'Mulugu' , N'Venkatapur' UNION ALL 
 Select 'Telangana' , N'Mulugu' , N'Venkatapuram' UNION ALL 
 Select 'Telangana' , N'Mulugu' , N'Wazeed' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Achampeta' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Amrabad' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Balmoor' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Bijinapalle' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Charakonda' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Kalwakurthy' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Kodair' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Kollapur' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Lingal' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Nagarkurnool' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Padara' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Peddakothapalle' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Pentlavelli' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Tadoor' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Telkapalle' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Thimmajipeta' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Uppununthala' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Urkonda' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Vangoor' UNION ALL 
 Select 'Telangana' , N'Nagarkurnool' , N'Veldanda' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Adavidevulapalli' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Anumula' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Chandampet' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Chandur' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Chintha Pally' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Chityala' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Dameracherla' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Devarakonda' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Gundlapally (Dindi)' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Gurrampode' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Kanagal' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Kattangoor' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Kethe Pally' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Konda Mallepally' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Madugulapally' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Marriguda' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Miryalaguda' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Munugode' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Nakrekal' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Nalgonda' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Nampally' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Narketpally' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Neredugommu' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Nidamanoor' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Pedda Adiserlapally' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Peddavoora' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Shali Gouraram' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Thipparthi' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Tirumalagiri Sagar' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Tripuraram' UNION ALL 
 Select 'Telangana' , N'Nalgonda' , N'Vemula Pally' UNION ALL 
 Select 'Telangana' , N'Narayanpet' , N'Damaragidda' UNION ALL 
 Select 'Telangana' , N'Narayanpet' , N'Dhanwada' UNION ALL 
 Select 'Telangana' , N'Narayanpet' , N'Kosgi' UNION ALL 
 Select 'Telangana' , N'Narayanpet' , N'Krishna' UNION ALL 
 Select 'Telangana' , N'Narayanpet' , N'Maddur' UNION ALL 
 Select 'Telangana' , N'Narayanpet' , N'Maganoor' UNION ALL 
 Select 'Telangana' , N'Narayanpet' , N'Makthal' UNION ALL 
 Select 'Telangana' , N'Narayanpet' , N'Marikal' UNION ALL 
 Select 'Telangana' , N'Narayanpet' , N'Narayanpet' UNION ALL 
 Select 'Telangana' , N'Narayanpet' , N'Narva' UNION ALL 
 Select 'Telangana' , N'Narayanpet' , N'Utkoor' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Basar' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Bhainsa' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Dasturabad' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Dilawarpur' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Kaddam (Peddur)' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Khanapur' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Kubeer' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Kuntala' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Laxmanchanda' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Lokeswaram' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Mamda' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Mudhole' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Narsapur G' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Nirmal' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Nirmal Rural' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Pembi' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Sarangapur' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Soan' UNION ALL 
 Select 'Telangana' , N'Nirmal' , N'Tanur' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Armur' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Balkonda' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Bheemgal' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Bodhan' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Chandur' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Dharpalle' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Dichpalle' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Indalwai' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Jakranpalle' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Kammarapalle' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Kotgiri' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Makloor' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Mendora' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Mortad' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Mosara' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Mugpal' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Mupkal' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Nandipet' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Navipet' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Nizamabad North' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Nizamabad Rural' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Nizamabad South' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Renjal' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Rudrur' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Sirkonda' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Varni' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Velpur' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Yedapalle' UNION ALL 
 Select 'Telangana' , N'Nizamabad' , N'Yergatla' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Anthergaon' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Dharmaram' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Eligaid' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Julapalli' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Kamanpur' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Manthani' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Mutharam (Manthani)' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Odela' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Palakurthy' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Peddapalli' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Ramagiri' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Ramagundam' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Srirampur' UNION ALL 
 Select 'Telangana' , N'Peddapalli' , N'Sulthanabad' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Boinpalli' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Chandurthi' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Ellanthakunta' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Gambhiraopet' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Konaraopet' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Mustabad' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Rudrangi' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Sircilla' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Thangallapalli' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Veernapalli' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Vemulawada' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Vemulawada Rural' UNION ALL 
 Select 'Telangana' , N'Rajanna Sircilla' , N'Yellareddipet' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Abdullapurmet' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Amangal' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Balapur' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Chevella' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Farooqnagar' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Gandipet' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Hayathnagar' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Ibrahimpatnam' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Jilled Chowdergudem' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Kadthal' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Kandukur' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Keshampeta' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Kondurg' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Kothur' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Madgul' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Maheshwaram' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Manchal' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Moinabad' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Nandigama' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Rajendranagar' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Saroornagar' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Serilingampally' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Shabad' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Shamshabad' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Shankarpally' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Talakondapalle' UNION ALL 
 Select 'Telangana' , N'Ranga Reddy' , N'Yacharam' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Ameenpur' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Andole' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Chowtakur' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Gummadidala' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Hathnoora' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Jharasangam' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Jinnaram' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Kalher' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Kandi' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Kangti' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Kohir' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Kondapur' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Manoor' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Mogudampally' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Munipally' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Nagalgidda' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Narayankhed' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Nyalkal' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Patancheru' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Pulkal' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Raikode' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Ramchandrapuram' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Sadasivpet' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Sangareddy' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Sirgapoor' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Vatpally' UNION ALL 
 Select 'Telangana' , N'Sangareddy' , N'Zahirabad' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Akkannapet' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Bejjanki' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Cheriyal' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Chinnakodur' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Dhoolmitta' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Doultabad' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Dubbak' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Gajwel' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Husnabad' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Jagdevpur' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Koheda' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Komuravelli' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Kondapak' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Maddur' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Markook' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Mirdoddi' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Mulug' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Nanganoor' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Narayanaraopet' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Raipole' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Siddipet Rural' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Siddipet Urban' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Thoguta' UNION ALL 
 Select 'Telangana' , N'Siddipet' , N'Wargal' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Ananthagiri' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Atmakur(S)' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Chilkur' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Chinthalapalem Mallareddygudem' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Chivvemla' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Garide Pally' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Huzurnagar' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Jaji Reddi Gudem (Arvapally)' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Kodad' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Maddirala' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Mattam Pally' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Mella Chervu' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Mothey' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Munagala' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Nadigudem' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Nagaram' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Nereducherla' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Nuthankal' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Palakeedu' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Penpahad' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Suryapet' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Thirumalagiri' UNION ALL 
 Select 'Telangana' , N'Suryapet' , N'Thungathurthi' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Bantwaram' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Basheerabad' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Bomraspeta' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Chowdapur' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Dharur' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Doma' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Doulatabad' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Kodangal' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Kotepally' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Kulkacharla' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Marpally' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Mominpet' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Nawabpet' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Pargi' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Peddemul' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Pudur' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Tandur' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Vikarabad' UNION ALL 
 Select 'Telangana' , N'Vikarabad' , N'Yalal' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Amarachintha' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Atmakur' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Chinnambavi' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Ghanpur' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Gopalpeta' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Kothakota' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Madanapur' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Pangal' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Pebbair' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Peddamandadi' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Revally' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Srirangapur' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Wanaparthy' UNION ALL 
 Select 'Telangana' , N'Wanaparthy' , N'Weepangandla' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Chennaraopet' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Duggondi' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Geesugonda' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Khanapur' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Khila Warangal' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Nalla Belli' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Narsampet' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Nekkonda' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Parvathagiri' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Raiparthy' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Sangem' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Warangal' UNION ALL 
 Select 'Telangana' , N'Warangal' , N'Wardhanna Pet' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Addaguduru' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Alair' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Atmakur(M)' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Bhongir' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Bibinagar' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Bommala Ramaram' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'B.Pochampally' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Choutuppal' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Gundala' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Motakonduru' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Mothkur' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Narayanapur' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Rajapet' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Ramannapeta' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Thurkapally' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Valigonda' UNION ALL 
 Select 'Telangana' , N'Yadadri Bhuvanagiri' , N'Yadagirigutta'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Daman and Diu' , N'Dadra And Nagar Haveli' , N'Dadra Nagar Haveli' UNION ALL 
 Select 'Daman and Diu' , N'Daman' , N'Daman' UNION ALL 
 Select 'Daman and Diu' , N'Diu' , N'Diu'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Tripura' , N'Dhalai' , N'Ambassa' UNION ALL 
 Select 'Tripura' , N'Dhalai' , N'Chawmanu' UNION ALL 
 Select 'Tripura' , N'Dhalai' , N'Dumburnagar' UNION ALL 
 Select 'Tripura' , N'Dhalai' , N'Durgachowmuhani' UNION ALL 
 Select 'Tripura' , N'Dhalai' , N'Ganganagar' UNION ALL 
 Select 'Tripura' , N'Dhalai' , N'Manu' UNION ALL 
 Select 'Tripura' , N'Dhalai' , N'Raishyabari' UNION ALL 
 Select 'Tripura' , N'Dhalai' , N'Salema' UNION ALL 
 Select 'Tripura' , N'Gomati' , N'Amarpur' UNION ALL 
 Select 'Tripura' , N'Gomati' , N'Kakraban' UNION ALL 
 Select 'Tripura' , N'Gomati' , N'Karbook' UNION ALL 
 Select 'Tripura' , N'Gomati' , N'Killa' UNION ALL 
 Select 'Tripura' , N'Gomati' , N'Matabari' UNION ALL 
 Select 'Tripura' , N'Gomati' , N'Ompi' UNION ALL 
 Select 'Tripura' , N'Gomati' , N'Silachari' UNION ALL 
 Select 'Tripura' , N'Gomati' , N'Tepania' UNION ALL 
 Select 'Tripura' , N'Khowai' , N'Kalyanpur' UNION ALL 
 Select 'Tripura' , N'Khowai' , N'Khowai' UNION ALL 
 Select 'Tripura' , N'Khowai' , N'Mungiakami' UNION ALL 
 Select 'Tripura' , N'Khowai' , N'Padmabil' UNION ALL 
 Select 'Tripura' , N'Khowai' , N'Teliamura' UNION ALL 
 Select 'Tripura' , N'Khowai' , N'Tulashikhar' UNION ALL 
 Select 'Tripura' , N'North Tripura' , N'Damcherra' UNION ALL 
 Select 'Tripura' , N'North Tripura' , N'Dasda' UNION ALL 
 Select 'Tripura' , N'North Tripura' , N'Jampui Hills' UNION ALL 
 Select 'Tripura' , N'North Tripura' , N'Jubarajnagar' UNION ALL 
 Select 'Tripura' , N'North Tripura' , N'Kadamtala' UNION ALL 
 Select 'Tripura' , N'North Tripura' , N'Kalacherra' UNION ALL 
 Select 'Tripura' , N'North Tripura' , N'Laljuri' UNION ALL 
 Select 'Tripura' , N'North Tripura' , N'Panisagar' UNION ALL 
 Select 'Tripura' , N'Sepahijala' , N'Bishalgarh' UNION ALL 
 Select 'Tripura' , N'Sepahijala' , N'Boxanagar' UNION ALL 
 Select 'Tripura' , N'Sepahijala' , N'Charilam' UNION ALL 
 Select 'Tripura' , N'Sepahijala' , N'Jampuijala' UNION ALL 
 Select 'Tripura' , N'Sepahijala' , N'Kathalia' UNION ALL 
 Select 'Tripura' , N'Sepahijala' , N'Mohanbhog' UNION ALL 
 Select 'Tripura' , N'Sepahijala' , N'Nalchar' UNION ALL 
 Select 'Tripura' , N'South Tripura' , N'Bharat Chandra Nagar' UNION ALL 
 Select 'Tripura' , N'South Tripura' , N'Bokafa' UNION ALL 
 Select 'Tripura' , N'South Tripura' , N'Hrishyamukh' UNION ALL 
 Select 'Tripura' , N'South Tripura' , N'Jolaibari' UNION ALL 
 Select 'Tripura' , N'South Tripura' , N'Poangbari' UNION ALL 
 Select 'Tripura' , N'South Tripura' , N'Rajnagar' UNION ALL 
 Select 'Tripura' , N'South Tripura' , N'Rupaichari' UNION ALL 
 Select 'Tripura' , N'South Tripura' , N'Satchand' UNION ALL 
 Select 'Tripura' , N'Unakoti' , N'Chandipur' UNION ALL 
 Select 'Tripura' , N'Unakoti' , N'Gournagar' UNION ALL 
 Select 'Tripura' , N'Unakoti' , N'Kumarghat' UNION ALL 
 Select 'Tripura' , N'Unakoti' , N'Pecharthal' UNION ALL 
 Select 'Tripura' , N'West Tripura' , N'Bamutia' UNION ALL 
 Select 'Tripura' , N'West Tripura' , N'Belbari' UNION ALL 
 Select 'Tripura' , N'West Tripura' , N'Dukli' UNION ALL 
 Select 'Tripura' , N'West Tripura' , N'Hezamara' UNION ALL 
 Select 'Tripura' , N'West Tripura' , N'Jirania' UNION ALL 
 Select 'Tripura' , N'West Tripura' , N'Lefunga' UNION ALL 
 Select 'Tripura' , N'West Tripura' , N'Mandwai' UNION ALL 
 Select 'Tripura' , N'West Tripura' , N'Mohanpur' UNION ALL 
 Select 'Tripura' , N'West Tripura' , N'Old Agartala'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Uttar Pradesh' , N'Agra' , N'Achhnera' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Akola' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Bah' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Barauli Ahir' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Bichpuri' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Etmadpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Fatehabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Fatehpur Sikri' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Jagner' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Jaitpur Kalan' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Khandauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Kheragarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Pinahat' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Saiyan' UNION ALL 
 Select 'Uttar Pradesh' , N'Agra' , N'Shamsabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Akrabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Atrauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Bijauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Chandaus' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Dhanipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Gangiri' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Gonda' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Iglas' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Jawan Sikanderpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Khair' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Lodha' UNION ALL 
 Select 'Uttar Pradesh' , N'Aligarh' , N'Tappal' UNION ALL 
 Select 'Uttar Pradesh' , N'Ambedkar Nagar' , N'Akbarpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Ambedkar Nagar' , N'Baskhari' UNION ALL 
 Select 'Uttar Pradesh' , N'Ambedkar Nagar' , N'Bhiti' UNION ALL 
 Select 'Uttar Pradesh' , N'Ambedkar Nagar' , N'Bhiyawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Ambedkar Nagar' , N'Jahangir Ganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Ambedkar Nagar' , N'Jalal Pur' UNION ALL 
 Select 'Uttar Pradesh' , N'Ambedkar Nagar' , N'Katehari' UNION ALL 
 Select 'Uttar Pradesh' , N'Ambedkar Nagar' , N'Ram Nagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ambedkar Nagar' , N'Tanda' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Amethi' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Bahadurpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Bhadar' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Bhetua' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Gauriganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Jagdishpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Jamo' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Musafir Khana' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Sangrampur' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Shahgarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Shukul Bazar' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Singhpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Amethi' , N'Tiloi' UNION ALL 
 Select 'Uttar Pradesh' , N'Amroha' , N'Amroha' UNION ALL 
 Select 'Uttar Pradesh' , N'Amroha' , N'Dhanaura' UNION ALL 
 Select 'Uttar Pradesh' , N'Amroha' , N'Gajraula' UNION ALL 
 Select 'Uttar Pradesh' , N'Amroha' , N'Gangeshwari' UNION ALL 
 Select 'Uttar Pradesh' , N'Amroha' , N'Hasanpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Amroha' , N'Joya' UNION ALL 
 Select 'Uttar Pradesh' , N'Auraiya' , N'Achchalda' UNION ALL 
 Select 'Uttar Pradesh' , N'Auraiya' , N'Ajitmal' UNION ALL 
 Select 'Uttar Pradesh' , N'Auraiya' , N'Auraiya' UNION ALL 
 Select 'Uttar Pradesh' , N'Auraiya' , N'Bhagyanagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Auraiya' , N'Bidhuna' UNION ALL 
 Select 'Uttar Pradesh' , N'Auraiya' , N'Erwa Katra' UNION ALL 
 Select 'Uttar Pradesh' , N'Auraiya' , N'Sahar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ayodhya' , N'Amaniganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Ayodhya' , N'Bikapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Ayodhya' , N'Hariyangatanganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Ayodhya' , N'Masodha' UNION ALL 
 Select 'Uttar Pradesh' , N'Ayodhya' , N'Mawai' UNION ALL 
 Select 'Uttar Pradesh' , N'Ayodhya' , N'Maya Bazar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ayodhya' , N'Milkipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Ayodhya' , N'Pura Bazar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ayodhya' , N'Rudauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Ayodhya' , N'Sohawal' UNION ALL 
 Select 'Uttar Pradesh' , N'Ayodhya' , N'Tarun' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Ahiraula' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Atraulia' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Azmatgarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Bilariyaganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Haraiya' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Jahanaganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Koilsa' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Lalganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Mahrajganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Martinganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Mehnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Mirzapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Mohammadpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Palhana' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Palhani' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Pawai' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Phulpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Rani Ki Sarai' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Sathiyaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Tahbarpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Tarwa' UNION ALL 
 Select 'Uttar Pradesh' , N'Azamgarh' , N'Thekma' UNION ALL 
 Select 'Uttar Pradesh' , N'Baghpat' , N'Baghpat' UNION ALL 
 Select 'Uttar Pradesh' , N'Baghpat' , N'Baraut' UNION ALL 
 Select 'Uttar Pradesh' , N'Baghpat' , N'Binauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Baghpat' , N'Chhaprauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Baghpat' , N'Khekra' UNION ALL 
 Select 'Uttar Pradesh' , N'Baghpat' , N'Pilana' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Balaha' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Chitaura' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Huzoorpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Jarwal' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Kaisarganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Mahasi' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Mihinpurwa' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Nawabganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Payagpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Phakharpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Risia' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Shivpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Tejwapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bahraich' , N'Visheshwarganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Bairia' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Bansdih' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Belhari' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Beruarbari' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Chilkahar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Dubhar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Garwar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Hanumanganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Maniar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Murlichhapra' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Nagra' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Navanagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Pandah' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Rasra' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Reoti' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Siar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ballia' , N'Sohanv' UNION ALL 
 Select 'Uttar Pradesh' , N'Balrampur' , N'Balrampur' UNION ALL 
 Select 'Uttar Pradesh' , N'Balrampur' , N'Gaindas Bujurg' UNION ALL 
 Select 'Uttar Pradesh' , N'Balrampur' , N'Gaisri' UNION ALL 
 Select 'Uttar Pradesh' , N'Balrampur' , N'Harriya Satgharwa' UNION ALL 
 Select 'Uttar Pradesh' , N'Balrampur' , N'Pachpedwa' UNION ALL 
 Select 'Uttar Pradesh' , N'Balrampur' , N'Rehera Bazaar' UNION ALL 
 Select 'Uttar Pradesh' , N'Balrampur' , N'Shriduttganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Balrampur' , N'Tulsipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Balrampur' , N'Utraula' UNION ALL 
 Select 'Uttar Pradesh' , N'Banda' , N'Baberu' UNION ALL 
 Select 'Uttar Pradesh' , N'Banda' , N'Badokhar Khurd' UNION ALL 
 Select 'Uttar Pradesh' , N'Banda' , N'Bisanda' UNION ALL 
 Select 'Uttar Pradesh' , N'Banda' , N'Jaspura' UNION ALL 
 Select 'Uttar Pradesh' , N'Banda' , N'Kamasin' UNION ALL 
 Select 'Uttar Pradesh' , N'Banda' , N'Mahuva' UNION ALL 
 Select 'Uttar Pradesh' , N'Banda' , N'Naraini' UNION ALL 
 Select 'Uttar Pradesh' , N'Banda' , N'Tindwari' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Bani Kodar' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Banki' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Dariyabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Dewa' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Fatehpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Haidargarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Harakh' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Masauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Nindaura' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Puredalai' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Ramnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Sidhaur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Sirauli Gauspur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Suratganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Bara Banki' , N'Trivediganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Aalampur Jafarabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Baheri' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Bhadpura' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Bhojipura' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Bhuta' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Bithiri Chainpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Damkhauda' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Faridpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Fatehganj West' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Kyara' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Majhgawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Mirganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Nawabganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Ramnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Bareilly' , N'Shergarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Bahadurpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Bankati' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Basti' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Dubauliya' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Gaur' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Harraiya' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Kaptanganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Kudaraha' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Paras Rampur' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Ramnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Rudauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Saltaua Gopal Pur' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Sau Ghat' UNION ALL 
 Select 'Uttar Pradesh' , N'Basti' , N'Vikram Jot' UNION ALL 
 Select 'Uttar Pradesh' , N'Bhadohi' , N'Abhauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Bhadohi' , N'Aurai' UNION ALL 
 Select 'Uttar Pradesh' , N'Bhadohi' , N'Bhadohi' UNION ALL 
 Select 'Uttar Pradesh' , N'Bhadohi' , N'Deegh' UNION ALL 
 Select 'Uttar Pradesh' , N'Bhadohi' , N'Gyanpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bhadohi' , N'Suriyavan' UNION ALL 
 Select 'Uttar Pradesh' , N'Bijnor' , N'Afzalgarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Bijnor' , N'Budhanpur Seohara' UNION ALL 
 Select 'Uttar Pradesh' , N'Bijnor' , N'Dhampur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bijnor' , N'Haldaur(Khari Jhalu)' UNION ALL 
 Select 'Uttar Pradesh' , N'Bijnor' , N'Jalilpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bijnor' , N'Kiratpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bijnor' , N'Kotwali' UNION ALL 
 Select 'Uttar Pradesh' , N'Bijnor' , N'Mohammedpur Deomal' UNION ALL 
 Select 'Uttar Pradesh' , N'Bijnor' , N'Najibabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Bijnor' , N'Nehtaur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bijnor' , N'Noorpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Ambiapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Asafpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Bisauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Dahgavan' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Dataganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Islamnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Jagat' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Mion' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Qadar Chowk' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Sahaswan' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Salarpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Samrer' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Ujhani' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Usawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Budaun' , N'Wazirganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Agauta' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Anupshahr' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Araniya' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Bhawan Bahadur Nagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Bulandshahr' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Danpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Dibai' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Gulaothi' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Jahangirabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Khurja' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Lakhaothi' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Pahasu' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Shikarpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Sikandrabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Syana' UNION ALL 
 Select 'Uttar Pradesh' , N'Bulandshahr' , N'Unchagaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Chandauli' , N'Berahani' UNION ALL 
 Select 'Uttar Pradesh' , N'Chandauli' , N'Chahniya' UNION ALL 
 Select 'Uttar Pradesh' , N'Chandauli' , N'Chakiya' UNION ALL 
 Select 'Uttar Pradesh' , N'Chandauli' , N'Chandauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Chandauli' , N'Dhanapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Chandauli' , N'Naugarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Chandauli' , N'Niyamatabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Chandauli' , N'Sahabganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Chandauli' , N'Sakaldiha' UNION ALL 
 Select 'Uttar Pradesh' , N'Chitrakoot' , N'Karwi' UNION ALL 
 Select 'Uttar Pradesh' , N'Chitrakoot' , N'Manikpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Chitrakoot' , N'Mau' UNION ALL 
 Select 'Uttar Pradesh' , N'Chitrakoot' , N'Pahari' UNION ALL 
 Select 'Uttar Pradesh' , N'Chitrakoot' , N'Ramnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Baitalpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Bankata' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Barhaj' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Bhagalpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Bhaluani' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Bhatni' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Bhatpar Rani' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Deoria Sadar' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Desai Deoria' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Gauri Bazar' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Lar' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Pathar Dewa' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Rampur Karkhana' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Rudrapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Salempur' UNION ALL 
 Select 'Uttar Pradesh' , N'Deoria' , N'Tarkalua' UNION ALL 
 Select 'Uttar Pradesh' , N'Etah' , N'Aliganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Etah' , N'Awagarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Etah' , N'Jaithara' UNION ALL 
 Select 'Uttar Pradesh' , N'Etah' , N'Jalesar' UNION ALL 
 Select 'Uttar Pradesh' , N'Etah' , N'Marehra' UNION ALL 
 Select 'Uttar Pradesh' , N'Etah' , N'Nidhauli Kalan' UNION ALL 
 Select 'Uttar Pradesh' , N'Etah' , N'Sakit' UNION ALL 
 Select 'Uttar Pradesh' , N'Etah' , N'Shitalpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Etawah' , N'Barhpura' UNION ALL 
 Select 'Uttar Pradesh' , N'Etawah' , N'Basrehar' UNION ALL 
 Select 'Uttar Pradesh' , N'Etawah' , N'Bharthana' UNION ALL 
 Select 'Uttar Pradesh' , N'Etawah' , N'Chakarnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Etawah' , N'Jaswantnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Etawah' , N'Mahewa' UNION ALL 
 Select 'Uttar Pradesh' , N'Etawah' , N'Sefai' UNION ALL 
 Select 'Uttar Pradesh' , N'Etawah' , N'Takha' UNION ALL 
 Select 'Uttar Pradesh' , N'Farrukhabad' , N'Barhpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Farrukhabad' , N'Kaimganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Farrukhabad' , N'Kamalganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Farrukhabad' , N'Mohamdabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Farrukhabad' , N'Nawabganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Farrukhabad' , N'Rajepur' UNION ALL 
 Select 'Uttar Pradesh' , N'Farrukhabad' , N'Shamsabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Airayan' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Amauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Asothar' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Bahua' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Bhitaura' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Devmai' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Dhata' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Haswa' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Hathgaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Khajuha' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Malwan' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Telyani' UNION ALL 
 Select 'Uttar Pradesh' , N'Fatehpur' , N'Vijayipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Firozabad' , N'Araon' UNION ALL 
 Select 'Uttar Pradesh' , N'Firozabad' , N'Eka' UNION ALL 
 Select 'Uttar Pradesh' , N'Firozabad' , N'Firozabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Firozabad' , N'Hathwant' UNION ALL 
 Select 'Uttar Pradesh' , N'Firozabad' , N'Jasrana' UNION ALL 
 Select 'Uttar Pradesh' , N'Firozabad' , N'Madanpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Firozabad' , N'Narkhi' UNION ALL 
 Select 'Uttar Pradesh' , N'Firozabad' , N'Shikohabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Firozabad' , N'Tundla' UNION ALL 
 Select 'Uttar Pradesh' , N'Gautam Buddha Nagar' , N'Bisrakh' UNION ALL 
 Select 'Uttar Pradesh' , N'Gautam Buddha Nagar' , N'Dadri' UNION ALL 
 Select 'Uttar Pradesh' , N'Gautam Buddha Nagar' , N'Jewar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghaziabad' , N'Bhojpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghaziabad' , N'Loni' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghaziabad' , N'Muradnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghaziabad' , N'Rajapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Bhadaura' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Bhanwarkol' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Devkali' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Ghazipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Jakhania' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Karanda' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Kasimabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Manihari' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Mardah' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Mohammadabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Revatipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Sadat' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Saidpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Varachakwar' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Virno' UNION ALL 
 Select 'Uttar Pradesh' , N'Ghazipur' , N'Zamania' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Babhanjot' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Belsar' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Chhapia' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Colonelganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Haldharmau' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Itiathok' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Jhanjhari' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Katra Bazar' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Mankapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Mujehana' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Nawabganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Pandri Kripal' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Paraspur' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Rupaideeh' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Tarabganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Gonda' , N'Wazirganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Bansgaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Barhalganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Belghat' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Bharohiya' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Bhathat' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Brahmpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Campierganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Chargawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Gagaha' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Gola' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Jangal Kaudia' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Kauri Ram' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Khajni' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Khorabar' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Pali' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Pipraich' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Piprauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Sahjanawa' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Sardarnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Gorakhpur' , N'Uruwa' UNION ALL 
 Select 'Uttar Pradesh' , N'Hamirpur' , N'Gohand' UNION ALL 
 Select 'Uttar Pradesh' , N'Hamirpur' , N'Kurara' UNION ALL 
 Select 'Uttar Pradesh' , N'Hamirpur' , N'Maudaha' UNION ALL 
 Select 'Uttar Pradesh' , N'Hamirpur' , N'Muskara' UNION ALL 
 Select 'Uttar Pradesh' , N'Hamirpur' , N'Rath' UNION ALL 
 Select 'Uttar Pradesh' , N'Hamirpur' , N'Sarila' UNION ALL 
 Select 'Uttar Pradesh' , N'Hamirpur' , N'Sumerpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Hapur' , N'Dhaulana' UNION ALL 
 Select 'Uttar Pradesh' , N'Hapur' , N'Garh Mukteshwar' UNION ALL 
 Select 'Uttar Pradesh' , N'Hapur' , N'Hapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Hapur' , N'Simbhawali' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Ahirori' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Bawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Behendar' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Bharawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Bharkhani' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Bilgram' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Hariyawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Harpalpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Kachauna' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Kothawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Madhoganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Mallawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Pihani' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Sandi' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Sandila' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Shahabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Sursa' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Tandiyawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Hardoi' , N'Todarpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Hathras' , N'Hasayan' UNION ALL 
 Select 'Uttar Pradesh' , N'Hathras' , N'Hathras' UNION ALL 
 Select 'Uttar Pradesh' , N'Hathras' , N'Mursan' UNION ALL 
 Select 'Uttar Pradesh' , N'Hathras' , N'Sadabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Hathras' , N'Sasni' UNION ALL 
 Select 'Uttar Pradesh' , N'Hathras' , N'Sehpau' UNION ALL 
 Select 'Uttar Pradesh' , N'Hathras' , N'Sikandrarao' UNION ALL 
 Select 'Uttar Pradesh' , N'Jalaun' , N'Dakore' UNION ALL 
 Select 'Uttar Pradesh' , N'Jalaun' , N'Jalaun' UNION ALL 
 Select 'Uttar Pradesh' , N'Jalaun' , N'Kadaura' UNION ALL 
 Select 'Uttar Pradesh' , N'Jalaun' , N'Konch' UNION ALL 
 Select 'Uttar Pradesh' , N'Jalaun' , N'Kuthaund' UNION ALL 
 Select 'Uttar Pradesh' , N'Jalaun' , N'Madhogarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Jalaun' , N'Maheva' UNION ALL 
 Select 'Uttar Pradesh' , N'Jalaun' , N'Nadigaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Jalaun' , N'Rampura' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Badla Pur' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Baksha' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Barasathi' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Dharma Pur' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Dobhi' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Jalal Pur' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Karanja Kala' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Kerakat' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Khuthan' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Machchali Shahar' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Maharaj Ganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Mariyahu' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Mufti Ganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Mungra Badshah Pur' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Ram Nagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Ram Pur' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Shah Ganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Sikrara' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Sirkoni' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Suitha Kala' UNION ALL 
 Select 'Uttar Pradesh' , N'Jaunpur' , N'Sujan Ganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Jhansi' , N'Babina' UNION ALL 
 Select 'Uttar Pradesh' , N'Jhansi' , N'Badagaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Jhansi' , N'Bamaur' UNION ALL 
 Select 'Uttar Pradesh' , N'Jhansi' , N'Bangra' UNION ALL 
 Select 'Uttar Pradesh' , N'Jhansi' , N'Chirgaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Jhansi' , N'Gursarai' UNION ALL 
 Select 'Uttar Pradesh' , N'Jhansi' , N'Mauranipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Jhansi' , N'Moth' UNION ALL 
 Select 'Uttar Pradesh' , N'Kannauj' , N'Chhibramau' UNION ALL 
 Select 'Uttar Pradesh' , N'Kannauj' , N'Gughrapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kannauj' , N'Haseran' UNION ALL 
 Select 'Uttar Pradesh' , N'Kannauj' , N'Jalalabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Kannauj' , N'Kannauj' UNION ALL 
 Select 'Uttar Pradesh' , N'Kannauj' , N'Saurikh' UNION ALL 
 Select 'Uttar Pradesh' , N'Kannauj' , N'Talgram' UNION ALL 
 Select 'Uttar Pradesh' , N'Kannauj' , N'Umarda' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Dehat' , N'Akbarpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Dehat' , N'Amrodha' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Dehat' , N'Derapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Dehat' , N'Jhinjhak' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Dehat' , N'Maitha' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Dehat' , N'Malasa' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Dehat' , N'Rajpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Dehat' , N'Rasulabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Dehat' , N'Sandalpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Dehat' , N'Sarbankhera' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Nagar' , N'Bhitargaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Nagar' , N'Bilhaur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Nagar' , N'Chaubeypur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Nagar' , N'Ghatampur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Nagar' , N'Kakwan' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Nagar' , N'Kalyanpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Nagar' , N'Patara' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Nagar' , N'Sarsol' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Nagar' , N'Shivrajpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kanpur Nagar' , N'Vidhunu' UNION ALL 
 Select 'Uttar Pradesh' , N'Kasganj' , N'Amanpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kasganj' , N'Ganj Dundwara' UNION ALL 
 Select 'Uttar Pradesh' , N'Kasganj' , N'Kasganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Kasganj' , N'Patiyali' UNION ALL 
 Select 'Uttar Pradesh' , N'Kasganj' , N'Sahawar' UNION ALL 
 Select 'Uttar Pradesh' , N'Kasganj' , N'Sidhpura' UNION ALL 
 Select 'Uttar Pradesh' , N'Kasganj' , N'Soron' UNION ALL 
 Select 'Uttar Pradesh' , N'Kaushambi' , N'Chail' UNION ALL 
 Select 'Uttar Pradesh' , N'Kaushambi' , N'Kara' UNION ALL 
 Select 'Uttar Pradesh' , N'Kaushambi' , N'Kaushambi' UNION ALL 
 Select 'Uttar Pradesh' , N'Kaushambi' , N'Manjhanpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kaushambi' , N'Mooratganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Kaushambi' , N'Nevada' UNION ALL 
 Select 'Uttar Pradesh' , N'Kaushambi' , N'Sarsawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Kaushambi' , N'Sirathu' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Bankeyganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Behjam' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Bijuwa' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Dhaurhara' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Isanagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Kumbhigola' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Lakhimpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Mitauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Mohammadi' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Nakaha' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Nighasan' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Palia' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Pasgawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Phoolbehar' UNION ALL 
 Select 'Uttar Pradesh' , N'Kheri' , N'Ramia Behar' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Dudhahi' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Fazilnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Hata' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Kaptainganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Kasaya' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Khadda' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Motichak' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Nebua Naurangia' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Padrauna' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Ramkola' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Seorahi' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Sukrauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Tamkuhiraj' UNION ALL 
 Select 'Uttar Pradesh' , N'Kushinagar' , N'Vishunpura' UNION ALL 
 Select 'Uttar Pradesh' , N'Lalitpur' , N'Bar' UNION ALL 
 Select 'Uttar Pradesh' , N'Lalitpur' , N'Birdha' UNION ALL 
 Select 'Uttar Pradesh' , N'Lalitpur' , N'Jakhaura' UNION ALL 
 Select 'Uttar Pradesh' , N'Lalitpur' , N'Mandawara' UNION ALL 
 Select 'Uttar Pradesh' , N'Lalitpur' , N'Mehroni' UNION ALL 
 Select 'Uttar Pradesh' , N'Lalitpur' , N'Talbehat' UNION ALL 
 Select 'Uttar Pradesh' , N'Lucknow' , N'Bakshi-Ka-Talab' UNION ALL 
 Select 'Uttar Pradesh' , N'Lucknow' , N'Chinhat' UNION ALL 
 Select 'Uttar Pradesh' , N'Lucknow' , N'Gosaiganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Lucknow' , N'Kakori' UNION ALL 
 Select 'Uttar Pradesh' , N'Lucknow' , N'Mal' UNION ALL 
 Select 'Uttar Pradesh' , N'Lucknow' , N'Malihabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Lucknow' , N'Mohanlalganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Lucknow' , N'Sarojaninagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahoba' , N'Charkhari' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahoba' , N'Jaitpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahoba' , N'Kabrai' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahoba' , N'Panwari' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Bridgemanganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Dhani' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Ghughli' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Lakshmipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Mahrajganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Mithaura' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Nautanwa' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Nichlaul' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Paniyara' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Partawal' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Pharenda' UNION ALL 
 Select 'Uttar Pradesh' , N'Mahrajganj' , N'Siswa' UNION ALL 
 Select 'Uttar Pradesh' , N'Mainpuri' , N'Barnahal' UNION ALL 
 Select 'Uttar Pradesh' , N'Mainpuri' , N'Bewar' UNION ALL 
 Select 'Uttar Pradesh' , N'Mainpuri' , N'Ghiror' UNION ALL 
 Select 'Uttar Pradesh' , N'Mainpuri' , N'Jageer' UNION ALL 
 Select 'Uttar Pradesh' , N'Mainpuri' , N'Karhal' UNION ALL 
 Select 'Uttar Pradesh' , N'Mainpuri' , N'Kishni' UNION ALL 
 Select 'Uttar Pradesh' , N'Mainpuri' , N'Kuraoli' UNION ALL 
 Select 'Uttar Pradesh' , N'Mainpuri' , N'Mainpuri' UNION ALL 
 Select 'Uttar Pradesh' , N'Mainpuri' , N'Sultanganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Mathura' , N'Baldeo' UNION ALL 
 Select 'Uttar Pradesh' , N'Mathura' , N'Chaumuha' UNION ALL 
 Select 'Uttar Pradesh' , N'Mathura' , N'Chhata' UNION ALL 
 Select 'Uttar Pradesh' , N'Mathura' , N'Farah' UNION ALL 
 Select 'Uttar Pradesh' , N'Mathura' , N'Govardhan' UNION ALL 
 Select 'Uttar Pradesh' , N'Mathura' , N'Mat' UNION ALL 
 Select 'Uttar Pradesh' , N'Mathura' , N'Mathura' UNION ALL 
 Select 'Uttar Pradesh' , N'Mathura' , N'Nandgaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Mathura' , N'Nohjhil' UNION ALL 
 Select 'Uttar Pradesh' , N'Mathura' , N'Raya' UNION ALL 
 Select 'Uttar Pradesh' , N'Mau' , N'Badraon' UNION ALL 
 Select 'Uttar Pradesh' , N'Mau' , N'Dohri Ghat' UNION ALL 
 Select 'Uttar Pradesh' , N'Mau' , N'Fatehpur Madaun' UNION ALL 
 Select 'Uttar Pradesh' , N'Mau' , N'Ghosi' UNION ALL 
 Select 'Uttar Pradesh' , N'Mau' , N'Kopaganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Mau' , N'Mohammadabad Gohana' UNION ALL 
 Select 'Uttar Pradesh' , N'Mau' , N'Pardaha' UNION ALL 
 Select 'Uttar Pradesh' , N'Mau' , N'Ranipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Mau' , N'Ratanpura' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Daurala' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Hastinapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Janikhurd' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Kharkhoda' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Machra' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Mawana Kalan' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Meerut' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Parikshitgarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Rajpura' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Rohta' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Sardhana' UNION ALL 
 Select 'Uttar Pradesh' , N'Meerut' , N'Sarurpur Khurd' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Chhanvey' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Hallia' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Jamalpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Kon' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Lalganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Majhawa' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Nagar (City)' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Narainpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Pahari' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Patehra' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Rajgarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Mirzapur' , N'Shikhar' UNION ALL 
 Select 'Uttar Pradesh' , N'Moradabad' , N'Bhagatpur Tanda' UNION ALL 
 Select 'Uttar Pradesh' , N'Moradabad' , N'Bilari' UNION ALL 
 Select 'Uttar Pradesh' , N'Moradabad' , N'Chhajlet' UNION ALL 
 Select 'Uttar Pradesh' , N'Moradabad' , N'Dilari' UNION ALL 
 Select 'Uttar Pradesh' , N'Moradabad' , N'Kundarki' UNION ALL 
 Select 'Uttar Pradesh' , N'Moradabad' , N'Moradabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Moradabad' , N'Munda Pandey' UNION ALL 
 Select 'Uttar Pradesh' , N'Moradabad' , N'Thakurdwara' UNION ALL 
 Select 'Uttar Pradesh' , N'Muzaffarnagar' , N'Baghara' UNION ALL 
 Select 'Uttar Pradesh' , N'Muzaffarnagar' , N'Budhana' UNION ALL 
 Select 'Uttar Pradesh' , N'Muzaffarnagar' , N'Charthawal' UNION ALL 
 Select 'Uttar Pradesh' , N'Muzaffarnagar' , N'Jansath' UNION ALL 
 Select 'Uttar Pradesh' , N'Muzaffarnagar' , N'Khatauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Muzaffarnagar' , N'Morna' UNION ALL 
 Select 'Uttar Pradesh' , N'Muzaffarnagar' , N'Muzaffarnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Muzaffarnagar' , N'Purkaji' UNION ALL 
 Select 'Uttar Pradesh' , N'Muzaffarnagar' , N'Shahpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Pilibhit' , N'Amariya' UNION ALL 
 Select 'Uttar Pradesh' , N'Pilibhit' , N'Barkhera' UNION ALL 
 Select 'Uttar Pradesh' , N'Pilibhit' , N'Bilsanda' UNION ALL 
 Select 'Uttar Pradesh' , N'Pilibhit' , N'Bisalpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Pilibhit' , N'Lalaurikhera' UNION ALL 
 Select 'Uttar Pradesh' , N'Pilibhit' , N'Marori' UNION ALL 
 Select 'Uttar Pradesh' , N'Pilibhit' , N'Puranpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Aspur Deosara' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Baba Belkharnath Dham' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Babaganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Bihar' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Gaura' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Kalakankar' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Kunda' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Lakshamanpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Lalganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Magraura' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Mandhata' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Patti' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Pratapgarh (Sadar)' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Rampur Sanramgarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Sandwa Chandrika' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Sangipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Pratapgarh' , N'Shivgarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Bahadurpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Bahria' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Bhagwatpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Chaka' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Dhanupur' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Handia' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Holagarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Jasra' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Karchhana' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Kaudhiyara' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Kaurihar' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Koraon' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Manda' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Mauaima' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Meja' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Phulpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Pratappur' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Sahson' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Saidabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Shankargarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Soraon' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Sringverpur Dham' UNION ALL 
 Select 'Uttar Pradesh' , N'Prayagraj' , N'Uruwan' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Amawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Bachharawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Chhatoh' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Dalmau' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Deenshah Gaura' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Dih' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Harchandpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Jagatpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Khiron' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Lalganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Mahrajganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Rahi' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Rohania' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Salon' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Sareni' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Sataon' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Shivgarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Rae Bareli' , N'Unchahar' UNION ALL 
 Select 'Uttar Pradesh' , N'Rampur' , N'Bilaspur' UNION ALL 
 Select 'Uttar Pradesh' , N'Rampur' , N'Chamraon' UNION ALL 
 Select 'Uttar Pradesh' , N'Rampur' , N'Milak' UNION ALL 
 Select 'Uttar Pradesh' , N'Rampur' , N'Saidnagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Rampur' , N'Shahabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Rampur' , N'Suar' UNION ALL 
 Select 'Uttar Pradesh' , N'Saharanpur' , N'Ballia Kheri' UNION ALL 
 Select 'Uttar Pradesh' , N'Saharanpur' , N'Deoband' UNION ALL 
 Select 'Uttar Pradesh' , N'Saharanpur' , N'Gangoh' UNION ALL 
 Select 'Uttar Pradesh' , N'Saharanpur' , N'Muzaffarabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Saharanpur' , N'Nagal' UNION ALL 
 Select 'Uttar Pradesh' , N'Saharanpur' , N'Nakur' UNION ALL 
 Select 'Uttar Pradesh' , N'Saharanpur' , N'Nanauta' UNION ALL 
 Select 'Uttar Pradesh' , N'Saharanpur' , N'Puwarka' UNION ALL 
 Select 'Uttar Pradesh' , N'Saharanpur' , N'Rampur Maniharan' UNION ALL 
 Select 'Uttar Pradesh' , N'Saharanpur' , N'Sadauli Qadeem' UNION ALL 
 Select 'Uttar Pradesh' , N'Saharanpur' , N'Sarsawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Sambhal' , N'Asmauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Sambhal' , N'Bahjoi' UNION ALL 
 Select 'Uttar Pradesh' , N'Sambhal' , N'Baniyakhera' UNION ALL 
 Select 'Uttar Pradesh' , N'Sambhal' , N'Gunnaur' UNION ALL 
 Select 'Uttar Pradesh' , N'Sambhal' , N'Junawai' UNION ALL 
 Select 'Uttar Pradesh' , N'Sambhal' , N'Panwasa' UNION ALL 
 Select 'Uttar Pradesh' , N'Sambhal' , N'Rajpura' UNION ALL 
 Select 'Uttar Pradesh' , N'Sambhal' , N'Sambhal' UNION ALL 
 Select 'Uttar Pradesh' , N'Sant Kabir Nagar' , N'Baghauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Sant Kabir Nagar' , N'Belhar Kala' UNION ALL 
 Select 'Uttar Pradesh' , N'Sant Kabir Nagar' , N'Hainsar Bazar' UNION ALL 
 Select 'Uttar Pradesh' , N'Sant Kabir Nagar' , N'Khalilabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Sant Kabir Nagar' , N'Mehdawal' UNION ALL 
 Select 'Uttar Pradesh' , N'Sant Kabir Nagar' , N'Nath Nagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Sant Kabir Nagar' , N'Pauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Sant Kabir Nagar' , N'Santha' UNION ALL 
 Select 'Uttar Pradesh' , N'Sant Kabir Nagar' , N'Semariyawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Banda' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Bhawal Khera' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Dadrol' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Jaitipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Jalalabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Kalan' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Kanth' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Khudaganj Katra' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Khutar' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Madnapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Mirzapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Nigohi' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Powayan' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Sindhauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Shahjahanpur' , N'Tilhar' UNION ALL 
 Select 'Uttar Pradesh' , N'Shamli' , N'Kairana' UNION ALL 
 Select 'Uttar Pradesh' , N'Shamli' , N'Kandhla' UNION ALL 
 Select 'Uttar Pradesh' , N'Shamli' , N'Shamli' UNION ALL 
 Select 'Uttar Pradesh' , N'Shamli' , N'Thana Bhawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Shamli' , N'Un' UNION ALL 
 Select 'Uttar Pradesh' , N'Shrawasti' , N'Ekona' UNION ALL 
 Select 'Uttar Pradesh' , N'Shrawasti' , N'Gilaula' UNION ALL 
 Select 'Uttar Pradesh' , N'Shrawasti' , N'Hariharpur Rani' UNION ALL 
 Select 'Uttar Pradesh' , N'Shrawasti' , N'Jamunaha' UNION ALL 
 Select 'Uttar Pradesh' , N'Shrawasti' , N'Sirsiya' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Bansi' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Barhni' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Bhanwapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Birdpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Domariyaganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Itwa' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Jogia' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Khesraha' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Khuniyaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Lotan' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Mithwal' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Naugarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Shoharatgarh' UNION ALL 
 Select 'Uttar Pradesh' , N'Siddharthnagar' , N'Uska Bazar' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Ailiya' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Behta' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Biswan' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Gondlamau' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Hargaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Kasmanda' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Khairabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Laharpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Machhrehta' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Mahmudabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Maholi' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Misrikh' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Pahala' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Parsendi' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Pisawan' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Rampur Mathura' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Reusa' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Sakran' UNION ALL 
 Select 'Uttar Pradesh' , N'Sitapur' , N'Sidhauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Sonbhadra' , N'Babhani' UNION ALL 
 Select 'Uttar Pradesh' , N'Sonbhadra' , N'Chatra' UNION ALL 
 Select 'Uttar Pradesh' , N'Sonbhadra' , N'Chopan' UNION ALL 
 Select 'Uttar Pradesh' , N'Sonbhadra' , N'Dudhi' UNION ALL 
 Select 'Uttar Pradesh' , N'Sonbhadra' , N'Ghorawal' UNION ALL 
 Select 'Uttar Pradesh' , N'Sonbhadra' , N'Karma' UNION ALL 
 Select 'Uttar Pradesh' , N'Sonbhadra' , N'Kone' UNION ALL 
 Select 'Uttar Pradesh' , N'Sonbhadra' , N'Myorpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Sonbhadra' , N'Nagwa' UNION ALL 
 Select 'Uttar Pradesh' , N'Sonbhadra' , N'Robertsganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Akhand Nagar' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Baldirai' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Bhadaiya' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Dhanpatganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Dostpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Dubepur' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Jaisinghpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Kadipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Karaudikala' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Kurebhar' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Kurwar' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Lambhua' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'Motigarpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Sultanpur' , N'P.P.Kamaicha' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Asoha' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Auras' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Bangarmau' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Bichhiya' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Bighapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Fatehpur Chaurasi' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Ganj Moradabad' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Hasanganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Hilauli' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Mianganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Nawabganj' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Purwa' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Safipur' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Sikandarpur Karan' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Sikandarpur Sarausi' UNION ALL 
 Select 'Uttar Pradesh' , N'Unnao' , N'Sumerpur' UNION ALL 
 Select 'Uttar Pradesh' , N'Varanasi' , N'Arajiline' UNION ALL 
 Select 'Uttar Pradesh' , N'Varanasi' , N'Baragaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Varanasi' , N'Chiraigaon' UNION ALL 
 Select 'Uttar Pradesh' , N'Varanasi' , N'Cholapur' UNION ALL 
 Select 'Uttar Pradesh' , N'Varanasi' , N'Harahua' UNION ALL 
 Select 'Uttar Pradesh' , N'Varanasi' , N'Kashi Vidyapeeth' UNION ALL 
 Select 'Uttar Pradesh' , N'Varanasi' , N'Pindra' UNION ALL 
 Select 'Uttar Pradesh' , N'Varanasi' , N'Sevapuri'
)

INSERT INTO [dbo].[SubDist_Master]([State_Name], [Dist_Name], [SubDist_Name]) 
(
 Select 'Uttarakhand' , N'Almora' , N'Bhaisiya Chhana' UNION ALL 
 Select 'Uttarakhand' , N'Almora' , N'Bhikiyasain' UNION ALL 
 Select 'Uttarakhand' , N'Almora' , N'Chaukhutiya' UNION ALL 
 Select 'Uttarakhand' , N'Almora' , N'Dhauladevi' UNION ALL 
 Select 'Uttarakhand' , N'Almora' , N'Dwarahat' UNION ALL 
 Select 'Uttarakhand' , N'Almora' , N'Hawalbag' UNION ALL 
 Select 'Uttarakhand' , N'Almora' , N'Lamgara' UNION ALL 
 Select 'Uttarakhand' , N'Almora' , N'Sult' UNION ALL 
 Select 'Uttarakhand' , N'Almora' , N'Syaldey' UNION ALL 
 Select 'Uttarakhand' , N'Almora' , N'Takula' UNION ALL 
 Select 'Uttarakhand' , N'Almora' , N'Tarikhet' UNION ALL 
 Select 'Uttarakhand' , N'Bageshwar' , N'Bageshwar' UNION ALL 
 Select 'Uttarakhand' , N'Bageshwar' , N'Garur' UNION ALL 
 Select 'Uttarakhand' , N'Bageshwar' , N'Kapkote' UNION ALL 
 Select 'Uttarakhand' , N'Chamoli' , N'Dasholi' UNION ALL 
 Select 'Uttarakhand' , N'Chamoli' , N'Dewal' UNION ALL 
 Select 'Uttarakhand' , N'Chamoli' , N'Gairsain' UNION ALL 
 Select 'Uttarakhand' , N'Chamoli' , N'Ghat' UNION ALL 
 Select 'Uttarakhand' , N'Chamoli' , N'Joshimath' UNION ALL 
 Select 'Uttarakhand' , N'Chamoli' , N'Karnaprayag' UNION ALL 
 Select 'Uttarakhand' , N'Chamoli' , N'Narayanbagar' UNION ALL 
 Select 'Uttarakhand' , N'Chamoli' , N'Pokhari' UNION ALL 
 Select 'Uttarakhand' , N'Chamoli' , N'Tharali' UNION ALL 
 Select 'Uttarakhand' , N'Champawat' , N'Barakot' UNION ALL 
 Select 'Uttarakhand' , N'Champawat' , N'Champawat' UNION ALL 
 Select 'Uttarakhand' , N'Champawat' , N'Lohaghat' UNION ALL 
 Select 'Uttarakhand' , N'Champawat' , N'Pati' UNION ALL 
 Select 'Uttarakhand' , N'Dehradun' , N'Chakrata' UNION ALL 
 Select 'Uttarakhand' , N'Dehradun' , N'Doiwala' UNION ALL 
 Select 'Uttarakhand' , N'Dehradun' , N'Kalsi' UNION ALL 
 Select 'Uttarakhand' , N'Dehradun' , N'Raipur' UNION ALL 
 Select 'Uttarakhand' , N'Dehradun' , N'Sahaspur' UNION ALL 
 Select 'Uttarakhand' , N'Dehradun' , N'Vikasnagar' UNION ALL 
 Select 'Uttarakhand' , N'Haridwar' , N'Bahadrabad' UNION ALL 
 Select 'Uttarakhand' , N'Haridwar' , N'Bhagwanpur' UNION ALL 
 Select 'Uttarakhand' , N'Haridwar' , N'Khanpur' UNION ALL 
 Select 'Uttarakhand' , N'Haridwar' , N'Laksar' UNION ALL 
 Select 'Uttarakhand' , N'Haridwar' , N'Narsan' UNION ALL 
 Select 'Uttarakhand' , N'Haridwar' , N'Roorkee' UNION ALL 
 Select 'Uttarakhand' , N'Nainital' , N'Betalghat' UNION ALL 
 Select 'Uttarakhand' , N'Nainital' , N'Bhimtal' UNION ALL 
 Select 'Uttarakhand' , N'Nainital' , N'Dhari' UNION ALL 
 Select 'Uttarakhand' , N'Nainital' , N'Haldwani' UNION ALL 
 Select 'Uttarakhand' , N'Nainital' , N'Kotabag' UNION ALL 
 Select 'Uttarakhand' , N'Nainital' , N'Okhalkanda' UNION ALL 
 Select 'Uttarakhand' , N'Nainital' , N'Ramgarh' UNION ALL 
 Select 'Uttarakhand' , N'Nainital' , N'Ramnagar' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Bironkhal' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Duggada' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Dwarikhal' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Ekeshwar' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Kaljikhal' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Khirsu' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Kot' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Nainidanda' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Pabau' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Pauri' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Pokhra' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Rikhnikhal' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Thalisain' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Yamkeshwar' UNION ALL 
 Select 'Uttarakhand' , N'Pauri Garhwal' , N'Zahrikhal' UNION ALL 
 Select 'Uttarakhand' , N'Pithoragarh' , N'Berinag' UNION ALL 
 Select 'Uttarakhand' , N'Pithoragarh' , N'Dharchula' UNION ALL 
 Select 'Uttarakhand' , N'Pithoragarh' , N'Didihat' UNION ALL 
 Select 'Uttarakhand' , N'Pithoragarh' , N'Gangolihat' UNION ALL 
 Select 'Uttarakhand' , N'Pithoragarh' , N'Kanalichina' UNION ALL 
 Select 'Uttarakhand' , N'Pithoragarh' , N'Munakot' UNION ALL 
 Select 'Uttarakhand' , N'Pithoragarh' , N'Munsyari' UNION ALL 
 Select 'Uttarakhand' , N'Pithoragarh' , N'Pithoragarh' UNION ALL 
 Select 'Uttarakhand' , N'Rudra Prayag' , N'Augustmuni' UNION ALL 
 Select 'Uttarakhand' , N'Rudra Prayag' , N'Jakholi' UNION ALL 
 Select 'Uttarakhand' , N'Rudra Prayag' , N'Ukhimath' UNION ALL 
 Select 'Uttarakhand' , N'Tehri Garhwal' , N'Bhilangna' UNION ALL 
 Select 'Uttarakhand' , N'Tehri Garhwal' , N'Chamba' UNION ALL 
 Select 'Uttarakhand' , N'Tehri Garhwal' , N'Deoprayag' UNION ALL 
 Select 'Uttarakhand' , N'Tehri Garhwal' , N'Jakhnidhar' UNION ALL 
 Select 'Uttarakhand' , N'Tehri Garhwal' , N'Jaunpur' UNION ALL 
 Select 'Uttarakhand' , N'Tehri Garhwal' , N'Kirtinagar' UNION ALL 
 Select 'Uttarakhand' , N'Tehri Garhwal' , N'Narendra Nagar' UNION ALL 
 Select 'Uttarakhand' , N'Tehri Garhwal' , N'Pratapnagar' UNION ALL 
 Select 'Uttarakhand' , N'Tehri Garhwal' , N'Thauldhar' UNION ALL 
 Select 'Uttarakhand' , N'Udam Singh Nagar' , N'Bajpur' UNION ALL 
 Select 'Uttarakhand' , N'Udam Singh Nagar' , N'Gadarpur' UNION ALL 
 Select 'Uttarakhand' , N'Udam Singh Nagar' , N'Jaspur' UNION ALL 
 Select 'Uttarakhand' , N'Udam Singh Nagar' , N'Kashipur' UNION ALL 
 Select 'Uttarakhand' , N'Udam Singh Nagar' , N'Khatima' UNION ALL 
 Select 'Uttarakhand' , N'Udam Singh Nagar' , N'Rudrapur' UNION ALL 
 Select 'Uttarakhand' , N'Udam Singh Nagar' , N'Sitarganj' UNION ALL 
 Select 'Uttarakhand' , N'Uttar Kashi' , N'Bhatwari' UNION ALL 
 Select 'Uttarakhand' , N'Uttar Kashi' , N'Chinyalisaur' UNION ALL 
 Select 'Uttarakhand' , N'Uttar Kashi' , N'Dunda' UNION ALL 
 Select 'Uttarakhand' , N'Uttar Kashi' , N'Mori' UNION ALL 
 Select 'Uttarakhand' , N'Uttar Kashi' , N'Naugaon' UNION ALL 
 Select 'Uttarakhand' , N'Uttar Kashi' , N'Purola'
)
end
end

