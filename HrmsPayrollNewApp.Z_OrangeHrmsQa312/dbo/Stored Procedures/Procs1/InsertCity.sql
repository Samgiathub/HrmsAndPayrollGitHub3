


-- Created By Tejas for insert default Dist on 17052024

CREATE PROCEDURE [dbo].[InsertCity] 
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN


if not Exists(select 1 from City_Master WITH (NOLOCK) where city_name='Alipur')
begin

INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) 
(
SELECT N'Andaman and Nicobar Islands', N'Alipur' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Andaman Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Anderson Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Arainj-laka-punga' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Austinabad' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Bamboo Flat' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Barren Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Beadonabad' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Betapur' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Bindraban' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Bonington' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Brookesabad' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Cadell Point' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Calicut' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Chetamale' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Cinque Islands' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Defence Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Digilpur' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Dolyganj' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Flat Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Geinyale' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Great Coco Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Haddo' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Havelock Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Henry Lawrence Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Herbertabad' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Hobdaypur' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Ilichar' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Ingoie' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Inteview Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Jangli Ghat' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Jhon Lawrence Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Karen' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Kartara' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'KYD Islannd' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Landfall Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Little Andmand' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Little Coco Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Long Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Maimyo' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Malappuram' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Manglutan' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Manpur' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Mitha Khari' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Neill Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Nicobar Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'North Brother Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'North Passage Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'North Sentinel Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Nothen Reef Island'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name])
 (
SELECT N'Andaman and Nicobar Islands', N'Outram Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Pahlagaon' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Palalankwe' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Passage Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Phaiapong' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Phoenix Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Port Blair' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Preparis Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Protheroepur' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Rangachang' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Rongat' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Rutland Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Sabari' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Saddle Peak' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Shadipur' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Smith Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Sound Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'South Sentinel Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Spike Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Tarmugli Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Taylerabad' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Titaije' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Toibalawe' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Tusonabad' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'West Island' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Wimberleyganj' UNION ALL
SELECT N'Andaman and Nicobar Islands', N'Yadita' UNION ALL
SELECT N'Andhra Pradesh', N'Achampet' UNION ALL
SELECT N'Andhra Pradesh', N'Adilabad' UNION ALL
SELECT N'Andhra Pradesh', N'Adoni' UNION ALL
SELECT N'Andhra Pradesh', N'Alampur' UNION ALL
SELECT N'Andhra Pradesh', N'Allagadda' UNION ALL
SELECT N'Andhra Pradesh', N'Alur' UNION ALL
SELECT N'Andhra Pradesh', N'Amalapuram' UNION ALL
SELECT N'Andhra Pradesh', N'Amangallu' UNION ALL
SELECT N'Andhra Pradesh', N'Anakapalle' UNION ALL
SELECT N'Andhra Pradesh', N'Anantapur' UNION ALL
SELECT N'Andhra Pradesh', N'Andole' UNION ALL
SELECT N'Andhra Pradesh', N'Araku' UNION ALL
SELECT N'Andhra Pradesh', N'Armoor' UNION ALL
SELECT N'Andhra Pradesh', N'Asifabad' UNION ALL
SELECT N'Andhra Pradesh', N'Aswaraopet' UNION ALL
SELECT N'Andhra Pradesh', N'Atmakur' UNION ALL
SELECT N'Andhra Pradesh', N'B. Kothakota' UNION ALL
SELECT N'Andhra Pradesh', N'Badvel' UNION ALL
SELECT N'Andhra Pradesh', N'Banaganapalle' UNION ALL
SELECT N'Andhra Pradesh', N'Bandar' UNION ALL
SELECT N'Andhra Pradesh', N'Bangarupalem' UNION ALL
SELECT N'Andhra Pradesh', N'Banswada' UNION ALL
SELECT N'Andhra Pradesh', N'Bapatla')
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) 
(
SELECT N'Andhra Pradesh', N'Bellampalli' UNION ALL
SELECT N'Andhra Pradesh', N'Bhadrachalam' UNION ALL
SELECT N'Andhra Pradesh', N'Bhainsa' UNION ALL
SELECT N'Andhra Pradesh', N'Bheemunipatnam' UNION ALL
SELECT N'Andhra Pradesh', N'Bhimadole' UNION ALL
SELECT N'Andhra Pradesh', N'Bhimavaram' UNION ALL
SELECT N'Andhra Pradesh', N'Bhongir' UNION ALL
SELECT N'Andhra Pradesh', N'Bhooragamphad' UNION ALL
SELECT N'Andhra Pradesh', N'Boath' UNION ALL
SELECT N'Andhra Pradesh', N'Bobbili' UNION ALL
SELECT N'Andhra Pradesh', N'Bodhan' UNION ALL
SELECT N'Andhra Pradesh', N'Chandoor' UNION ALL
SELECT N'Andhra Pradesh', N'Chavitidibbalu' UNION ALL
SELECT N'Andhra Pradesh', N'Chejerla' UNION ALL
SELECT N'Andhra Pradesh', N'Chepurupalli' UNION ALL
SELECT N'Andhra Pradesh', N'Cherial' UNION ALL
SELECT N'Andhra Pradesh', N'Chevella' UNION ALL
SELECT N'Andhra Pradesh', N'Chinnor' UNION ALL
SELECT N'Andhra Pradesh', N'Chintalapudi' UNION ALL
SELECT N'Andhra Pradesh', N'Chintapalle' UNION ALL
SELECT N'Andhra Pradesh', N'Chirala' UNION ALL
SELECT N'Andhra Pradesh', N'Chittoor' UNION ALL
SELECT N'Andhra Pradesh', N'Chodavaram' UNION ALL
SELECT N'Andhra Pradesh', N'Cuddapah' UNION ALL
SELECT N'Andhra Pradesh', N'Cumbum' UNION ALL
SELECT N'Andhra Pradesh', N'Darsi' UNION ALL
SELECT N'Andhra Pradesh', N'Devarakonda' UNION ALL
SELECT N'Andhra Pradesh', N'Dharmavaram' UNION ALL
SELECT N'Andhra Pradesh', N'Dichpalli' UNION ALL
SELECT N'Andhra Pradesh', N'Divi' UNION ALL
SELECT N'Andhra Pradesh', N'Donakonda' UNION ALL
SELECT N'Andhra Pradesh', N'Dronachalam' UNION ALL
SELECT N'Andhra Pradesh', N'East Godavari' UNION ALL
SELECT N'Andhra Pradesh', N'Eluru' UNION ALL
SELECT N'Andhra Pradesh', N'Eturnagaram' UNION ALL
SELECT N'Andhra Pradesh', N'Gadwal' UNION ALL
SELECT N'Andhra Pradesh', N'Gajapathinagaram' UNION ALL
SELECT N'Andhra Pradesh', N'Gajwel' UNION ALL
SELECT N'Andhra Pradesh', N'Garladinne' UNION ALL
SELECT N'Andhra Pradesh', N'Giddalur' UNION ALL
SELECT N'Andhra Pradesh', N'Godavari' UNION ALL
SELECT N'Andhra Pradesh', N'Gooty' UNION ALL
SELECT N'Andhra Pradesh', N'Gudivada' UNION ALL
SELECT N'Andhra Pradesh', N'Gudur' UNION ALL
SELECT N'Andhra Pradesh', N'Guntur' UNION ALL
SELECT N'Andhra Pradesh', N'Hindupur' UNION ALL
SELECT N'Andhra Pradesh', N'Hunsabad' UNION ALL
SELECT N'Andhra Pradesh', N'Huzurabad' UNION ALL
SELECT N'Andhra Pradesh', N'Huzurnagar' UNION ALL
SELECT N'Andhra Pradesh', N'Hyderabad'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) 
(
SELECT N'Andhra Pradesh', N'Ibrahimpatnam' UNION ALL
SELECT N'Andhra Pradesh', N'Jaggayyapet' UNION ALL
SELECT N'Andhra Pradesh', N'Jagtial' UNION ALL
SELECT N'Andhra Pradesh', N'Jammalamadugu' UNION ALL
SELECT N'Andhra Pradesh', N'Jangaon' UNION ALL
SELECT N'Andhra Pradesh', N'Jangareddygudem' UNION ALL
SELECT N'Andhra Pradesh', N'Jannaram' UNION ALL
SELECT N'Andhra Pradesh', N'Kadiri' UNION ALL
SELECT N'Andhra Pradesh', N'Kaikaluru' UNION ALL
SELECT N'Andhra Pradesh', N'Kakinada' UNION ALL
SELECT N'Andhra Pradesh', N'Kalwakurthy' UNION ALL
SELECT N'Andhra Pradesh', N'Kalyandurg' UNION ALL
SELECT N'Andhra Pradesh', N'Kamalapuram' UNION ALL
SELECT N'Andhra Pradesh', N'Kamareddy' UNION ALL
SELECT N'Andhra Pradesh', N'Kambadur' UNION ALL
SELECT N'Andhra Pradesh', N'Kanaganapalle' UNION ALL
SELECT N'Andhra Pradesh', N'Kandukuru' UNION ALL
SELECT N'Andhra Pradesh', N'Kanigiri' UNION ALL
SELECT N'Andhra Pradesh', N'Karimnagar' UNION ALL
SELECT N'Andhra Pradesh', N'Kavali' UNION ALL
SELECT N'Andhra Pradesh', N'Khammam' UNION ALL
SELECT N'Andhra Pradesh', N'Khanapur (AP)' UNION ALL
SELECT N'Andhra Pradesh', N'Kodangal' UNION ALL
SELECT N'Andhra Pradesh', N'Koduru' UNION ALL
SELECT N'Andhra Pradesh', N'Koilkuntla' UNION ALL
SELECT N'Andhra Pradesh', N'Kollapur' UNION ALL
SELECT N'Andhra Pradesh', N'Kothagudem' UNION ALL
SELECT N'Andhra Pradesh', N'Kovvur' UNION ALL
SELECT N'Andhra Pradesh', N'Krishna' UNION ALL
SELECT N'Andhra Pradesh', N'Krosuru' UNION ALL
SELECT N'Andhra Pradesh', N'Kuppam' UNION ALL
SELECT N'Andhra Pradesh', N'Kurnool' UNION ALL
SELECT N'Andhra Pradesh', N'Lakkireddipalli' UNION ALL
SELECT N'Andhra Pradesh', N'Madakasira' UNION ALL
SELECT N'Andhra Pradesh', N'Madanapalli' UNION ALL
SELECT N'Andhra Pradesh', N'Madhira' UNION ALL
SELECT N'Andhra Pradesh', N'Madnur' UNION ALL
SELECT N'Andhra Pradesh', N'Mahabubabad' UNION ALL
SELECT N'Andhra Pradesh', N'Mahabubnagar' UNION ALL
SELECT N'Andhra Pradesh', N'Mahadevapur' UNION ALL
SELECT N'Andhra Pradesh', N'Makthal' UNION ALL
SELECT N'Andhra Pradesh', N'Mancherial' UNION ALL
SELECT N'Andhra Pradesh', N'Mandapeta' UNION ALL
SELECT N'Andhra Pradesh', N'Mangalagiri' UNION ALL
SELECT N'Andhra Pradesh', N'Manthani' UNION ALL
SELECT N'Andhra Pradesh', N'Markapur' UNION ALL
SELECT N'Andhra Pradesh', N'Marturu' UNION ALL
SELECT N'Andhra Pradesh', N'Medachal' UNION ALL
SELECT N'Andhra Pradesh', N'Medak' UNION ALL
SELECT N'Andhra Pradesh', N'Medarmetla'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Andhra Pradesh', N'Metpalli' UNION ALL
SELECT N'Andhra Pradesh', N'Mriyalguda' UNION ALL
SELECT N'Andhra Pradesh', N'Mulug' UNION ALL
SELECT N'Andhra Pradesh', N'Mylavaram' UNION ALL
SELECT N'Andhra Pradesh', N'Nagarkurnool' UNION ALL
SELECT N'Andhra Pradesh', N'Nalgonda' UNION ALL
SELECT N'Andhra Pradesh', N'Nallacheruvu' UNION ALL
SELECT N'Andhra Pradesh', N'Nampalle' UNION ALL
SELECT N'Andhra Pradesh', N'Nandigama' UNION ALL
SELECT N'Andhra Pradesh', N'Nandikotkur' UNION ALL
SELECT N'Andhra Pradesh', N'Nandyal' UNION ALL
SELECT N'Andhra Pradesh', N'Narasampet' UNION ALL
SELECT N'Andhra Pradesh', N'Narasaraopet' UNION ALL
SELECT N'Andhra Pradesh', N'Narayanakhed' UNION ALL
SELECT N'Andhra Pradesh', N'Narayanpet' UNION ALL
SELECT N'Andhra Pradesh', N'Narsapur' UNION ALL
SELECT N'Andhra Pradesh', N'Narsipatnam' UNION ALL
SELECT N'Andhra Pradesh', N'Nazvidu' UNION ALL
SELECT N'Andhra Pradesh', N'Nelloe' UNION ALL
SELECT N'Andhra Pradesh', N'Nellore' UNION ALL
SELECT N'Andhra Pradesh', N'Nidamanur' UNION ALL
SELECT N'Andhra Pradesh', N'Nirmal' UNION ALL
SELECT N'Andhra Pradesh', N'Nizamabad' UNION ALL
SELECT N'Andhra Pradesh', N'Nuguru' UNION ALL
SELECT N'Andhra Pradesh', N'Ongole' UNION ALL
SELECT N'Andhra Pradesh', N'Outsarangapalle' UNION ALL
SELECT N'Andhra Pradesh', N'Paderu' UNION ALL
SELECT N'Andhra Pradesh', N'Pakala' UNION ALL
SELECT N'Andhra Pradesh', N'Palakonda' UNION ALL
SELECT N'Andhra Pradesh', N'Paland' UNION ALL
SELECT N'Andhra Pradesh', N'Palmaneru' UNION ALL
SELECT N'Andhra Pradesh', N'Pamuru' UNION ALL
SELECT N'Andhra Pradesh', N'Pargi' UNION ALL
SELECT N'Andhra Pradesh', N'Parkal' UNION ALL
SELECT N'Andhra Pradesh', N'Parvathipuram' UNION ALL
SELECT N'Andhra Pradesh', N'Pathapatnam' UNION ALL
SELECT N'Andhra Pradesh', N'Pattikonda' UNION ALL
SELECT N'Andhra Pradesh', N'Peapalle' UNION ALL
SELECT N'Andhra Pradesh', N'Peddapalli' UNION ALL
SELECT N'Andhra Pradesh', N'Peddapuram' UNION ALL
SELECT N'Andhra Pradesh', N'Penukonda' UNION ALL
SELECT N'Andhra Pradesh', N'Piduguralla' UNION ALL
SELECT N'Andhra Pradesh', N'Piler' UNION ALL
SELECT N'Andhra Pradesh', N'Pithapuram' UNION ALL
SELECT N'Andhra Pradesh', N'Podili' UNION ALL
SELECT N'Andhra Pradesh', N'Polavaram' UNION ALL
SELECT N'Andhra Pradesh', N'Prakasam' UNION ALL
SELECT N'Andhra Pradesh', N'Proddatur' UNION ALL
SELECT N'Andhra Pradesh', N'Pulivendla' UNION ALL
SELECT N'Andhra Pradesh', N'Punganur'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Andhra Pradesh', N'Putturu' UNION ALL
SELECT N'Andhra Pradesh', N'Rajahmundri' UNION ALL
SELECT N'Andhra Pradesh', N'Rajampeta' UNION ALL
SELECT N'Andhra Pradesh', N'Ramachandrapuram' UNION ALL
SELECT N'Andhra Pradesh', N'Ramannapet' UNION ALL
SELECT N'Andhra Pradesh', N'Rampachodavaram' UNION ALL
SELECT N'Andhra Pradesh', N'Rangareddy' UNION ALL
SELECT N'Andhra Pradesh', N'Rapur' UNION ALL
SELECT N'Andhra Pradesh', N'Rayachoti' UNION ALL
SELECT N'Andhra Pradesh', N'Rayadurg' UNION ALL
SELECT N'Andhra Pradesh', N'Razole' UNION ALL
SELECT N'Andhra Pradesh', N'Repalle' UNION ALL
SELECT N'Andhra Pradesh', N'Saluru' UNION ALL
SELECT N'Andhra Pradesh', N'Sangareddy' UNION ALL
SELECT N'Andhra Pradesh', N'Sathupalli' UNION ALL
SELECT N'Andhra Pradesh', N'Sattenapalle' UNION ALL
SELECT N'Andhra Pradesh', N'Satyavedu' UNION ALL
SELECT N'Andhra Pradesh', N'Shadnagar' UNION ALL
SELECT N'Andhra Pradesh', N'Siddavattam' UNION ALL
SELECT N'Andhra Pradesh', N'Siddipet' UNION ALL
SELECT N'Andhra Pradesh', N'Sileru' UNION ALL
SELECT N'Andhra Pradesh', N'Sircilla' UNION ALL
SELECT N'Andhra Pradesh', N'Sirpur Kagaznagar' UNION ALL
SELECT N'Andhra Pradesh', N'Sodam' UNION ALL
SELECT N'Andhra Pradesh', N'Sompeta' UNION ALL
SELECT N'Andhra Pradesh', N'Srikakulam' UNION ALL
SELECT N'Andhra Pradesh', N'Srikalahasthi' UNION ALL
SELECT N'Andhra Pradesh', N'Srisailam' UNION ALL
SELECT N'Andhra Pradesh', N'Srungavarapukota' UNION ALL
SELECT N'Andhra Pradesh', N'Sudhimalla' UNION ALL
SELECT N'Andhra Pradesh', N'Sullarpet' UNION ALL
SELECT N'Andhra Pradesh', N'Tadepalligudem' UNION ALL
SELECT N'Andhra Pradesh', N'Tadipatri' UNION ALL
SELECT N'Andhra Pradesh', N'Tanduru' UNION ALL
SELECT N'Andhra Pradesh', N'Tanuku' UNION ALL
SELECT N'Andhra Pradesh', N'Tekkali' UNION ALL
SELECT N'Andhra Pradesh', N'Tenali' UNION ALL
SELECT N'Andhra Pradesh', N'Thungaturthy' UNION ALL
SELECT N'Andhra Pradesh', N'Tirivuru' UNION ALL
SELECT N'Andhra Pradesh', N'Tirupathi' UNION ALL
SELECT N'Andhra Pradesh', N'Tuni' UNION ALL
SELECT N'Andhra Pradesh', N'Udaygiri' UNION ALL
SELECT N'Andhra Pradesh', N'Ulvapadu' UNION ALL
SELECT N'Andhra Pradesh', N'Uravakonda' UNION ALL
SELECT N'Andhra Pradesh', N'Utnor' UNION ALL
SELECT N'Andhra Pradesh', N'V.R. Puram' UNION ALL
SELECT N'Andhra Pradesh', N'Vaimpalli' UNION ALL
SELECT N'Andhra Pradesh', N'Vayalpad' UNION ALL
SELECT N'Andhra Pradesh', N'Venkatgiri' UNION ALL
SELECT N'Andhra Pradesh', N'Venkatgirikota'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Andhra Pradesh', N'Vijayawada' UNION ALL
SELECT N'Andhra Pradesh', N'Vikrabad' UNION ALL
SELECT N'Andhra Pradesh', N'Vinjamuru' UNION ALL
SELECT N'Andhra Pradesh', N'Vinukonda' UNION ALL
SELECT N'Andhra Pradesh', N'Visakhapatnam' UNION ALL
SELECT N'Andhra Pradesh', N'Vizayanagaram' UNION ALL
SELECT N'Andhra Pradesh', N'Vizianagaram' UNION ALL
SELECT N'Andhra Pradesh', N'Vuyyuru' UNION ALL
SELECT N'Andhra Pradesh', N'Wanaparthy' UNION ALL
SELECT N'Andhra Pradesh', N'Warangal' UNION ALL
SELECT N'Andhra Pradesh', N'Wardhannapet' UNION ALL
SELECT N'Andhra Pradesh', N'Yelamanchili' UNION ALL
SELECT N'Andhra Pradesh', N'Yelavaram' UNION ALL
SELECT N'Andhra Pradesh', N'Yeleswaram' UNION ALL
SELECT N'Andhra Pradesh', N'Yellandu' UNION ALL
SELECT N'Andhra Pradesh', N'Yellanuru' UNION ALL
SELECT N'Andhra Pradesh', N'Yellareddy' UNION ALL
SELECT N'Andhra Pradesh', N'Yerragondapalem' UNION ALL
SELECT N'Andhra Pradesh', N'Zahirabad' UNION ALL
SELECT N'Arunachal Pradesh', N'Along' UNION ALL
SELECT N'Arunachal Pradesh', N'Anini' UNION ALL
SELECT N'Arunachal Pradesh', N'Anjaw' UNION ALL
SELECT N'Arunachal Pradesh', N'Bameng' UNION ALL
SELECT N'Arunachal Pradesh', N'Basar' UNION ALL
SELECT N'Arunachal Pradesh', N'Changlang' UNION ALL
SELECT N'Arunachal Pradesh', N'Chowkhem' UNION ALL
SELECT N'Arunachal Pradesh', N'Daporizo' UNION ALL
SELECT N'Arunachal Pradesh', N'Dibang Valley' UNION ALL
SELECT N'Arunachal Pradesh', N'Dirang' UNION ALL
SELECT N'Arunachal Pradesh', N'Hayuliang' UNION ALL
SELECT N'Arunachal Pradesh', N'Huri' UNION ALL
SELECT N'Arunachal Pradesh', N'Itanagar' UNION ALL
SELECT N'Arunachal Pradesh', N'Jairampur' UNION ALL
SELECT N'Arunachal Pradesh', N'Kalaktung' UNION ALL
SELECT N'Arunachal Pradesh', N'Kameng' UNION ALL
SELECT N'Arunachal Pradesh', N'Khonsa' UNION ALL
SELECT N'Arunachal Pradesh', N'Kolaring' UNION ALL
SELECT N'Arunachal Pradesh', N'Kurung Kumey' UNION ALL
SELECT N'Arunachal Pradesh', N'Lohit' UNION ALL
SELECT N'Arunachal Pradesh', N'Lower Dibang Valley' UNION ALL
SELECT N'Arunachal Pradesh', N'Lower Subansiri' UNION ALL
SELECT N'Arunachal Pradesh', N'Mariyang' UNION ALL
SELECT N'Arunachal Pradesh', N'Mechuka' UNION ALL
SELECT N'Arunachal Pradesh', N'Miao' UNION ALL
SELECT N'Arunachal Pradesh', N'Nefra' UNION ALL
SELECT N'Arunachal Pradesh', N'Pakkekesang' UNION ALL
SELECT N'Arunachal Pradesh', N'Pangin' UNION ALL
SELECT N'Arunachal Pradesh', N'Papum Pare' UNION ALL
SELECT N'Arunachal Pradesh', N'Passighat' UNION ALL
SELECT N'Arunachal Pradesh', N'Roing'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Arunachal Pradesh', N'Sagalee' UNION ALL
SELECT N'Arunachal Pradesh', N'Seppa' UNION ALL
SELECT N'Arunachal Pradesh', N'Siang' UNION ALL
SELECT N'Arunachal Pradesh', N'Tali' UNION ALL
SELECT N'Arunachal Pradesh', N'Taliha' UNION ALL
SELECT N'Arunachal Pradesh', N'Tawang' UNION ALL
SELECT N'Arunachal Pradesh', N'Tezu' UNION ALL
SELECT N'Arunachal Pradesh', N'Tirap' UNION ALL
SELECT N'Arunachal Pradesh', N'Tuting' UNION ALL
SELECT N'Arunachal Pradesh', N'Upper Siang' UNION ALL
SELECT N'Arunachal Pradesh', N'Upper Subansiri' UNION ALL
SELECT N'Arunachal Pradesh', N'Yiang Kiag' UNION ALL
SELECT N'Assam', N'Abhayapuri' UNION ALL
SELECT N'Assam', N'Baithalangshu' UNION ALL
SELECT N'Assam', N'Barama' UNION ALL
SELECT N'Assam', N'Barpeta Road' UNION ALL
SELECT N'Assam', N'Bihupuria' UNION ALL
SELECT N'Assam', N'Bijni' UNION ALL
SELECT N'Assam', N'Bilasipara' UNION ALL
SELECT N'Assam', N'Bokajan' UNION ALL
SELECT N'Assam', N'Bokakhat' UNION ALL
SELECT N'Assam', N'Boko' UNION ALL
SELECT N'Assam', N'Bongaigaon' UNION ALL
SELECT N'Assam', N'Cachar' UNION ALL
SELECT N'Assam', N'Cachar Hills' UNION ALL
SELECT N'Assam', N'Darrang' UNION ALL
SELECT N'Assam', N'Dhakuakhana' UNION ALL
SELECT N'Assam', N'Dhemaji' UNION ALL
SELECT N'Assam', N'Dhubri' UNION ALL
SELECT N'Assam', N'Dibrugarh' UNION ALL
SELECT N'Assam', N'Digboi' UNION ALL
SELECT N'Assam', N'Diphu' UNION ALL
SELECT N'Assam', N'Goalpara' UNION ALL
SELECT N'Assam', N'Gohpur' UNION ALL
SELECT N'Assam', N'Golaghat' UNION ALL
SELECT N'Assam', N'Guwahati' UNION ALL
SELECT N'Assam', N'Hailakandi' UNION ALL
SELECT N'Assam', N'Hajo' UNION ALL
SELECT N'Assam', N'Halflong' UNION ALL
SELECT N'Assam', N'Hojai' UNION ALL
SELECT N'Assam', N'Howraghat' UNION ALL
SELECT N'Assam', N'Jorhat' UNION ALL
SELECT N'Assam', N'Kamrup' UNION ALL
SELECT N'Assam', N'Karbi Anglong' UNION ALL
SELECT N'Assam', N'Karimganj' UNION ALL
SELECT N'Assam', N'Kokarajhar' UNION ALL
SELECT N'Assam', N'Kokrajhar' UNION ALL
SELECT N'Assam', N'Lakhimpur' UNION ALL
SELECT N'Assam', N'Maibong' UNION ALL
SELECT N'Assam', N'Majuli'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Assam', N'Mangaldoi' UNION ALL
SELECT N'Assam', N'Mariani' UNION ALL
SELECT N'Assam', N'Marigaon' UNION ALL
SELECT N'Assam', N'Moranhat' UNION ALL
SELECT N'Assam', N'Morigaon' UNION ALL
SELECT N'Assam', N'Nagaon' UNION ALL
SELECT N'Assam', N'Nalbari' UNION ALL
SELECT N'Assam', N'Rangapara' UNION ALL
SELECT N'Assam', N'Sadiya' UNION ALL
SELECT N'Assam', N'Sibsagar' UNION ALL
SELECT N'Assam', N'Silchar' UNION ALL
SELECT N'Assam', N'Sivasagar' UNION ALL
SELECT N'Assam', N'Sonitpur' UNION ALL
SELECT N'Assam', N'Tarabarihat' UNION ALL
SELECT N'Assam', N'Tezpur' UNION ALL
SELECT N'Assam', N'Tinsukia' UNION ALL
SELECT N'Assam', N'Udalgiri' UNION ALL
SELECT N'Assam', N'Udalguri' UNION ALL
SELECT N'Assam', N'UdarbondhBarpeta' UNION ALL
SELECT N'Bihar', N'Adhaura' UNION ALL
SELECT N'Bihar', N'Amarpur' UNION ALL
SELECT N'Bihar', N'Araria' UNION ALL
SELECT N'Bihar', N'Areraj' UNION ALL
SELECT N'Bihar', N'Arrah' UNION ALL
SELECT N'Bihar', N'Arwal' UNION ALL
SELECT N'Bihar', N'Aurangabad' UNION ALL
SELECT N'Bihar', N'Bagaha' UNION ALL
SELECT N'Bihar', N'Banka' UNION ALL
SELECT N'Bihar', N'Banmankhi' UNION ALL
SELECT N'Bihar', N'Barachakia' UNION ALL
SELECT N'Bihar', N'Barauni' UNION ALL
SELECT N'Bihar', N'Barh' UNION ALL
SELECT N'Bihar', N'Barosi' UNION ALL
SELECT N'Bihar', N'Begusarai' UNION ALL
SELECT N'Bihar', N'Benipatti' UNION ALL
SELECT N'Bihar', N'Benipur' UNION ALL
SELECT N'Bihar', N'Bettiah' UNION ALL
SELECT N'Bihar', N'Bhabhua' UNION ALL
SELECT N'Bihar', N'Bhagalpur' UNION ALL
SELECT N'Bihar', N'Bhojpur' UNION ALL
SELECT N'Bihar', N'Bidupur' UNION ALL
SELECT N'Bihar', N'Biharsharif' UNION ALL
SELECT N'Bihar', N'Bikram' UNION ALL
SELECT N'Bihar', N'Bikramganj' UNION ALL
SELECT N'Bihar', N'Birpur' UNION ALL
SELECT N'Bihar', N'Buxar' UNION ALL
SELECT N'Bihar', N'Chakai' UNION ALL
SELECT N'Bihar', N'Champaran' UNION ALL
SELECT N'Bihar', N'Chapara' UNION ALL
SELECT N'Bihar', N'Dalsinghsarai'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Bihar', N'Danapur' UNION ALL
SELECT N'Bihar', N'Darbhanga' UNION ALL
SELECT N'Bihar', N'Daudnagar' UNION ALL
SELECT N'Bihar', N'Dhaka' UNION ALL
SELECT N'Bihar', N'Dhamdaha' UNION ALL
SELECT N'Bihar', N'Dumraon' UNION ALL
SELECT N'Bihar', N'Ekma' UNION ALL
SELECT N'Bihar', N'Forbesganj' UNION ALL
SELECT N'Bihar', N'Gaya' UNION ALL
SELECT N'Bihar', N'Gogri' UNION ALL
SELECT N'Bihar', N'Gopalganj' UNION ALL
SELECT N'Bihar', N'H.Kharagpur' UNION ALL
SELECT N'Bihar', N'Hajipur' UNION ALL
SELECT N'Bihar', N'Hathua' UNION ALL
SELECT N'Bihar', N'Hilsa' UNION ALL
SELECT N'Bihar', N'Imamganj' UNION ALL
SELECT N'Bihar', N'Jahanabad' UNION ALL
SELECT N'Bihar', N'Jainagar' UNION ALL
SELECT N'Bihar', N'Jamshedpur' UNION ALL
SELECT N'Bihar', N'Jamui' UNION ALL
SELECT N'Bihar', N'Jehanabad' UNION ALL
SELECT N'Bihar', N'Jhajha' UNION ALL
SELECT N'Bihar', N'Jhanjharpur' UNION ALL
SELECT N'Bihar', N'Kahalgaon' UNION ALL
SELECT N'Bihar', N'Kaimur (Bhabua)' UNION ALL
SELECT N'Bihar', N'Katihar' UNION ALL
SELECT N'Bihar', N'Katoria' UNION ALL
SELECT N'Bihar', N'Khagaria' UNION ALL
SELECT N'Bihar', N'Kishanganj' UNION ALL
SELECT N'Bihar', N'Korha' UNION ALL
SELECT N'Bihar', N'Lakhisarai' UNION ALL
SELECT N'Bihar', N'Madhepura' UNION ALL
SELECT N'Bihar', N'Madhubani' UNION ALL
SELECT N'Bihar', N'Maharajganj' UNION ALL
SELECT N'Bihar', N'Mahua' UNION ALL
SELECT N'Bihar', N'Mairwa' UNION ALL
SELECT N'Bihar', N'Mallehpur' UNION ALL
SELECT N'Bihar', N'Masrakh' UNION ALL
SELECT N'Bihar', N'Mohania' UNION ALL
SELECT N'Bihar', N'Monghyr' UNION ALL
SELECT N'Bihar', N'Motihari' UNION ALL
SELECT N'Bihar', N'Motipur' UNION ALL
SELECT N'Bihar', N'Munger' UNION ALL
SELECT N'Bihar', N'Muzaffarpur' UNION ALL
SELECT N'Bihar', N'Nabinagar' UNION ALL
SELECT N'Bihar', N'Nalanda' UNION ALL
SELECT N'Bihar', N'Narkatiaganj' UNION ALL
SELECT N'Bihar', N'Naugachia' UNION ALL
SELECT N'Bihar', N'Nawada' UNION ALL
SELECT N'Bihar', N'Pakribarwan'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Bihar', N'Pakridayal' UNION ALL
SELECT N'Bihar', N'Patna' UNION ALL
SELECT N'Bihar', N'Phulparas' UNION ALL
SELECT N'Bihar', N'Piro' UNION ALL
SELECT N'Bihar', N'Pupri' UNION ALL
SELECT N'Bihar', N'Purena' UNION ALL
SELECT N'Bihar', N'Purnia' UNION ALL
SELECT N'Bihar', N'Rafiganj' UNION ALL
SELECT N'Bihar', N'Rajauli' UNION ALL
SELECT N'Bihar', N'Ramnagar' UNION ALL
SELECT N'Bihar', N'Raniganj' UNION ALL
SELECT N'Bihar', N'Raxaul' UNION ALL
SELECT N'Bihar', N'Rohtas' UNION ALL
SELECT N'Bihar', N'Rosera' UNION ALL
SELECT N'Bihar', N'S.Bakhtiarpur' UNION ALL
SELECT N'Bihar', N'Saharsa' UNION ALL
SELECT N'Bihar', N'Samastipur' UNION ALL
SELECT N'Bihar', N'Saran' UNION ALL
SELECT N'Bihar', N'Sasaram' UNION ALL
SELECT N'Bihar', N'Seikhpura' UNION ALL
SELECT N'Bihar', N'Sheikhpura' UNION ALL
SELECT N'Bihar', N'Sheohar' UNION ALL
SELECT N'Bihar', N'Sherghati' UNION ALL
SELECT N'Bihar', N'Sidhawalia' UNION ALL
SELECT N'Bihar', N'Singhwara' UNION ALL
SELECT N'Bihar', N'Sitamarhi' UNION ALL
SELECT N'Bihar', N'Siwan' UNION ALL
SELECT N'Bihar', N'Sonepur' UNION ALL
SELECT N'Bihar', N'Supaul' UNION ALL
SELECT N'Bihar', N'Thakurganj' UNION ALL
SELECT N'Bihar', N'Triveniganj' UNION ALL
SELECT N'Bihar', N'Udakishanganj' UNION ALL
SELECT N'Bihar', N'Vaishali' UNION ALL
SELECT N'Bihar', N'Wazirganj' UNION ALL
SELECT N'Chandigarh', N'Chandigarh' UNION ALL
SELECT N'Chandigarh', N'Mani Marja' UNION ALL
SELECT N'Chhattisgarh', N'Ambikapur' UNION ALL
SELECT N'Chhattisgarh', N'Antagarh' UNION ALL
SELECT N'Chhattisgarh', N'Arang' UNION ALL
SELECT N'Chhattisgarh', N'Bacheli' UNION ALL
SELECT N'Chhattisgarh', N'Bagbahera' UNION ALL
SELECT N'Chhattisgarh', N'Bagicha' UNION ALL
SELECT N'Chhattisgarh', N'Baikunthpur' UNION ALL
SELECT N'Chhattisgarh', N'Balod' UNION ALL
SELECT N'Chhattisgarh', N'Balodabazar' UNION ALL
SELECT N'Chhattisgarh', N'Balrampur' UNION ALL
SELECT N'Chhattisgarh', N'Barpalli' UNION ALL
SELECT N'Chhattisgarh', N'Basana' UNION ALL
SELECT N'Chhattisgarh', N'Bastanar' UNION ALL
SELECT N'Chhattisgarh', N'Bastar'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Chhattisgarh', N'Bderajpur' UNION ALL
SELECT N'Chhattisgarh', N'Bemetara' UNION ALL
SELECT N'Chhattisgarh', N'Berla' UNION ALL
SELECT N'Chhattisgarh', N'Bhairongarh' UNION ALL
SELECT N'Chhattisgarh', N'Bhanupratappur' UNION ALL
SELECT N'Chhattisgarh', N'Bharathpur' UNION ALL
SELECT N'Chhattisgarh', N'Bhatapara' UNION ALL
SELECT N'Chhattisgarh', N'Bhilai' UNION ALL
SELECT N'Chhattisgarh', N'Bhilaigarh' UNION ALL
SELECT N'Chhattisgarh', N'Bhopalpatnam' UNION ALL
SELECT N'Chhattisgarh', N'Bijapur' UNION ALL
SELECT N'Chhattisgarh', N'Bilaspur' UNION ALL
SELECT N'Chhattisgarh', N'Bodla' UNION ALL
SELECT N'Chhattisgarh', N'Bokaband' UNION ALL
SELECT N'Chhattisgarh', N'Chandipara' UNION ALL
SELECT N'Chhattisgarh', N'Chhinagarh' UNION ALL
SELECT N'Chhattisgarh', N'Chhuriakala' UNION ALL
SELECT N'Chhattisgarh', N'Chingmut' UNION ALL
SELECT N'Chhattisgarh', N'Chuikhadan' UNION ALL
SELECT N'Chhattisgarh', N'Dabhara' UNION ALL
SELECT N'Chhattisgarh', N'Dallirajhara' UNION ALL
SELECT N'Chhattisgarh', N'Dantewada' UNION ALL
SELECT N'Chhattisgarh', N'Deobhog' UNION ALL
SELECT N'Chhattisgarh', N'Dhamda' UNION ALL
SELECT N'Chhattisgarh', N'Dhamtari' UNION ALL
SELECT N'Chhattisgarh', N'Dharamjaigarh' UNION ALL
SELECT N'Chhattisgarh', N'Dongargarh' UNION ALL
SELECT N'Chhattisgarh', N'Durg' UNION ALL
SELECT N'Chhattisgarh', N'Durgakondal' UNION ALL
SELECT N'Chhattisgarh', N'Fingeshwar' UNION ALL
SELECT N'Chhattisgarh', N'Gariaband' UNION ALL
SELECT N'Chhattisgarh', N'Garpa' UNION ALL
SELECT N'Chhattisgarh', N'Gharghoda' UNION ALL
SELECT N'Chhattisgarh', N'Gogunda' UNION ALL
SELECT N'Chhattisgarh', N'Ilamidi' UNION ALL
SELECT N'Chhattisgarh', N'Jagdalpur' UNION ALL
SELECT N'Chhattisgarh', N'Janjgir' UNION ALL
SELECT N'Chhattisgarh', N'Janjgir-Champa' UNION ALL
SELECT N'Chhattisgarh', N'Jarwa' UNION ALL
SELECT N'Chhattisgarh', N'Jashpur' UNION ALL
SELECT N'Chhattisgarh', N'Jashpurnagar' UNION ALL
SELECT N'Chhattisgarh', N'Kabirdham-Kawardha' UNION ALL
SELECT N'Chhattisgarh', N'Kanker' UNION ALL
SELECT N'Chhattisgarh', N'Kasdol' UNION ALL
SELECT N'Chhattisgarh', N'Kathdol' UNION ALL
SELECT N'Chhattisgarh', N'Kathghora' UNION ALL
SELECT N'Chhattisgarh', N'Kawardha' UNION ALL
SELECT N'Chhattisgarh', N'Keskal' UNION ALL
SELECT N'Chhattisgarh', N'Khairgarh' UNION ALL
SELECT N'Chhattisgarh', N'Kondagaon'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Chhattisgarh', N'Konta' UNION ALL
SELECT N'Chhattisgarh', N'Korba' UNION ALL
SELECT N'Chhattisgarh', N'Korea' UNION ALL
SELECT N'Chhattisgarh', N'Kota' UNION ALL
SELECT N'Chhattisgarh', N'Koyelibeda' UNION ALL
SELECT N'Chhattisgarh', N'Kuakunda' UNION ALL
SELECT N'Chhattisgarh', N'Kunkuri' UNION ALL
SELECT N'Chhattisgarh', N'Kurud' UNION ALL
SELECT N'Chhattisgarh', N'Lohadigundah' UNION ALL
SELECT N'Chhattisgarh', N'Lormi' UNION ALL
SELECT N'Chhattisgarh', N'Luckwada' UNION ALL
SELECT N'Chhattisgarh', N'Mahasamund' UNION ALL
SELECT N'Chhattisgarh', N'Makodi' UNION ALL
SELECT N'Chhattisgarh', N'Manendragarh' UNION ALL
SELECT N'Chhattisgarh', N'Manpur' UNION ALL
SELECT N'Chhattisgarh', N'Marwahi' UNION ALL
SELECT N'Chhattisgarh', N'Mohla' UNION ALL
SELECT N'Chhattisgarh', N'Mungeli' UNION ALL
SELECT N'Chhattisgarh', N'Nagri' UNION ALL
SELECT N'Chhattisgarh', N'Narainpur' UNION ALL
SELECT N'Chhattisgarh', N'Narayanpur' UNION ALL
SELECT N'Chhattisgarh', N'Neora' UNION ALL
SELECT N'Chhattisgarh', N'Netanar' UNION ALL
SELECT N'Chhattisgarh', N'Odgi' UNION ALL
SELECT N'Chhattisgarh', N'Padamkot' UNION ALL
SELECT N'Chhattisgarh', N'Pakhanjur' UNION ALL
SELECT N'Chhattisgarh', N'Pali' UNION ALL
SELECT N'Chhattisgarh', N'Pandaria' UNION ALL
SELECT N'Chhattisgarh', N'Pandishankar' UNION ALL
SELECT N'Chhattisgarh', N'Parasgaon' UNION ALL
SELECT N'Chhattisgarh', N'Pasan' UNION ALL
SELECT N'Chhattisgarh', N'Patan' UNION ALL
SELECT N'Chhattisgarh', N'Pathalgaon' UNION ALL
SELECT N'Chhattisgarh', N'Pendra' UNION ALL
SELECT N'Chhattisgarh', N'Pratappur' UNION ALL
SELECT N'Chhattisgarh', N'Premnagar' UNION ALL
SELECT N'Chhattisgarh', N'Raigarh' UNION ALL
SELECT N'Chhattisgarh', N'Raipur' UNION ALL
SELECT N'Chhattisgarh', N'Rajnandgaon' UNION ALL
SELECT N'Chhattisgarh', N'Rajpur' UNION ALL
SELECT N'Chhattisgarh', N'Ramchandrapur' UNION ALL
SELECT N'Chhattisgarh', N'Saraipali' UNION ALL
SELECT N'Chhattisgarh', N'Saranggarh' UNION ALL
SELECT N'Chhattisgarh', N'Sarona' UNION ALL
SELECT N'Chhattisgarh', N'Semaria' UNION ALL
SELECT N'Chhattisgarh', N'Shakti' UNION ALL
SELECT N'Chhattisgarh', N'Sitapur' UNION ALL
SELECT N'Chhattisgarh', N'Sukma' UNION ALL
SELECT N'Chhattisgarh', N'Surajpur' UNION ALL
SELECT N'Chhattisgarh', N'Surguja'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Chhattisgarh', N'Tapkara' UNION ALL
SELECT N'Chhattisgarh', N'Toynar' UNION ALL
SELECT N'Chhattisgarh', N'Udaipur' UNION ALL
SELECT N'Chhattisgarh', N'Uproda' UNION ALL
SELECT N'Chhattisgarh', N'Wadrainagar' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Amal' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Amli' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Bedpa' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Chikhli' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Dahikhed' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Dolara' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Galonda' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Kanadi' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Karchond' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Khadoli' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Kharadpada' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Kherabari' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Kherdi' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Kothar' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Luari' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Mashat' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Rakholi' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Rudana' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Saili' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Sili' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Silvassa' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Sindavni' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Udva' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Umbarkoi' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Vansda' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Vasona' UNION ALL
SELECT N'Dadra and Nagar Haveli', N'Velugam' UNION ALL
SELECT N'Daman and Diu', N'Brancavare' UNION ALL
SELECT N'Daman and Diu', N'Dagasi' UNION ALL
SELECT N'Daman and Diu', N'Daman' UNION ALL
SELECT N'Daman and Diu', N'Diu' UNION ALL
SELECT N'Daman and Diu', N'Magarvara' UNION ALL
SELECT N'Daman and Diu', N'Nagwa' UNION ALL
SELECT N'Daman and Diu', N'Pariali' UNION ALL
SELECT N'Daman and Diu', N'Passo Covo' UNION ALL
SELECT N'Delhi', N'East Delhi' UNION ALL
SELECT N'Delhi', N'New Delhi' UNION ALL
SELECT N'Delhi', N'North Delhi' UNION ALL
SELECT N'Delhi', N'Old Delhi' UNION ALL
SELECT N'Delhi', N'South Delhi' UNION ALL
SELECT N'Delhi', N'West Delhi' UNION ALL
SELECT N'Goa', N'Canacona' UNION ALL
SELECT N'Goa', N'Candolim' UNION ALL
SELECT N'Goa', N'Chinchinim' UNION ALL
SELECT N'Goa', N'Cortalim'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Goa', N'Goa' UNION ALL
SELECT N'Goa', N'Jua' UNION ALL
SELECT N'Goa', N'Madgaon' UNION ALL
SELECT N'Goa', N'Mahem' UNION ALL
SELECT N'Goa', N'Mapuca' UNION ALL
SELECT N'Goa', N'Marmagao' UNION ALL
SELECT N'Goa', N'Panji' UNION ALL
SELECT N'Goa', N'Ponda' UNION ALL
SELECT N'Goa', N'Sanvordem' UNION ALL
SELECT N'Goa', N'Terekhol' UNION ALL
SELECT N'Gujarat', N'Ahmedabad' UNION ALL
SELECT N'Gujarat', N'Ahwa' UNION ALL
SELECT N'Gujarat', N'Amod' UNION ALL
SELECT N'Gujarat', N'Amreli' UNION ALL
SELECT N'Gujarat', N'Anand' UNION ALL
SELECT N'Gujarat', N'Anjar' UNION ALL
SELECT N'Gujarat', N'Ankaleshwar' UNION ALL
SELECT N'Gujarat', N'Babra' UNION ALL
SELECT N'Gujarat', N'Balasinor' UNION ALL
SELECT N'Gujarat', N'Banaskantha' UNION ALL
SELECT N'Gujarat', N'Bansada' UNION ALL
SELECT N'Gujarat', N'Bardoli' UNION ALL
SELECT N'Gujarat', N'Bareja' UNION ALL
SELECT N'Gujarat', N'Baroda' UNION ALL
SELECT N'Gujarat', N'Barwala' UNION ALL
SELECT N'Gujarat', N'Bayad' UNION ALL
SELECT N'Gujarat', N'Bhachav' UNION ALL
SELECT N'Gujarat', N'Bhanvad' UNION ALL
SELECT N'Gujarat', N'Bharuch' UNION ALL
SELECT N'Gujarat', N'Bhavnagar' UNION ALL
SELECT N'Gujarat', N'Bhiloda' UNION ALL
SELECT N'Gujarat', N'Bhuj' UNION ALL
SELECT N'Gujarat', N'Billimora' UNION ALL
SELECT N'Gujarat', N'Borsad' UNION ALL
SELECT N'Gujarat', N'Botad' UNION ALL
SELECT N'Gujarat', N'Chanasma' UNION ALL
SELECT N'Gujarat', N'Chhota Udaipur' UNION ALL
SELECT N'Gujarat', N'Chotila' UNION ALL
SELECT N'Gujarat', N'Dabhoi' UNION ALL
SELECT N'Gujarat', N'Dahod' UNION ALL
SELECT N'Gujarat', N'Damnagar' UNION ALL
SELECT N'Gujarat', N'Dang' UNION ALL
SELECT N'Gujarat', N'Danta' UNION ALL
SELECT N'Gujarat', N'Dasada' UNION ALL
SELECT N'Gujarat', N'Dediapada' UNION ALL
SELECT N'Gujarat', N'Deesa' UNION ALL
SELECT N'Gujarat', N'Dehgam' UNION ALL
SELECT N'Gujarat', N'Deodar' UNION ALL
SELECT N'Gujarat', N'Devgadhbaria' UNION ALL
SELECT N'Gujarat', N'Dhandhuka'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Gujarat', N'Dhanera' UNION ALL
SELECT N'Gujarat', N'Dharampur' UNION ALL
SELECT N'Gujarat', N'Dhari' UNION ALL
SELECT N'Gujarat', N'Dholka' UNION ALL
SELECT N'Gujarat', N'Dhoraji' UNION ALL
SELECT N'Gujarat', N'Dhrangadhra' UNION ALL
SELECT N'Gujarat', N'Dhrol' UNION ALL
SELECT N'Gujarat', N'Dwarka' UNION ALL
SELECT N'Gujarat', N'Fortsongadh' UNION ALL
SELECT N'Gujarat', N'Gadhada' UNION ALL
SELECT N'Gujarat', N'Gandhi Nagar' UNION ALL
SELECT N'Gujarat', N'Gariadhar' UNION ALL
SELECT N'Gujarat', N'Godhra' UNION ALL
SELECT N'Gujarat', N'Gogodar' UNION ALL
SELECT N'Gujarat', N'Gondal' UNION ALL
SELECT N'Gujarat', N'Halol' UNION ALL
SELECT N'Gujarat', N'Halvad' UNION ALL
SELECT N'Gujarat', N'Harij' UNION ALL
SELECT N'Gujarat', N'Himatnagar' UNION ALL
SELECT N'Gujarat', N'Idar' UNION ALL
SELECT N'Gujarat', N'Jambusar' UNION ALL
SELECT N'Gujarat', N'Jamjodhpur' UNION ALL
SELECT N'Gujarat', N'Jamkalyanpur' UNION ALL
SELECT N'Gujarat', N'Jamnagar' UNION ALL
SELECT N'Gujarat', N'Jasdan' UNION ALL
SELECT N'Gujarat', N'Jetpur' UNION ALL
SELECT N'Gujarat', N'Jhagadia' UNION ALL
SELECT N'Gujarat', N'Jhalod' UNION ALL
SELECT N'Gujarat', N'Jodia' UNION ALL
SELECT N'Gujarat', N'Junagadh' UNION ALL
SELECT N'Gujarat', N'Junagarh' UNION ALL
SELECT N'Gujarat', N'Kalawad' UNION ALL
SELECT N'Gujarat', N'Kalol' UNION ALL
SELECT N'Gujarat', N'Kapad Wanj' UNION ALL
SELECT N'Gujarat', N'Keshod' UNION ALL
SELECT N'Gujarat', N'Khambat' UNION ALL
SELECT N'Gujarat', N'Khambhalia' UNION ALL
SELECT N'Gujarat', N'Khavda' UNION ALL
SELECT N'Gujarat', N'Kheda' UNION ALL
SELECT N'Gujarat', N'Khedbrahma' UNION ALL
SELECT N'Gujarat', N'Kheralu' UNION ALL
SELECT N'Gujarat', N'Kodinar' UNION ALL
SELECT N'Gujarat', N'Kotdasanghani' UNION ALL
SELECT N'Gujarat', N'Kunkawav' UNION ALL
SELECT N'Gujarat', N'Kutch' UNION ALL
SELECT N'Gujarat', N'Kutchmandvi' UNION ALL
SELECT N'Gujarat', N'Kutiyana' UNION ALL
SELECT N'Gujarat', N'Lakhpat' UNION ALL
SELECT N'Gujarat', N'Lakhtar' UNION ALL
SELECT N'Gujarat', N'Lalpur'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Gujarat', N'Limbdi' UNION ALL
SELECT N'Gujarat', N'Limkheda' UNION ALL
SELECT N'Gujarat', N'Lunavada' UNION ALL
SELECT N'Gujarat', N'M.M.Mangrol' UNION ALL
SELECT N'Gujarat', N'Mahuva' UNION ALL
SELECT N'Gujarat', N'Malia-Hatina' UNION ALL
SELECT N'Gujarat', N'Maliya' UNION ALL
SELECT N'Gujarat', N'Malpur' UNION ALL
SELECT N'Gujarat', N'Manavadar' UNION ALL
SELECT N'Gujarat', N'Mandvi' UNION ALL
SELECT N'Gujarat', N'Mangrol' UNION ALL
SELECT N'Gujarat', N'Mehmedabad' UNION ALL
SELECT N'Gujarat', N'Mehsana' UNION ALL
SELECT N'Gujarat', N'Miyagam' UNION ALL
SELECT N'Gujarat', N'Modasa' UNION ALL
SELECT N'Gujarat', N'Morvi' UNION ALL
SELECT N'Gujarat', N'Muli' UNION ALL
SELECT N'Gujarat', N'Mundra' UNION ALL
SELECT N'Gujarat', N'Nadiad' UNION ALL
SELECT N'Gujarat', N'Nakhatrana' UNION ALL
SELECT N'Gujarat', N'Nalia' UNION ALL
SELECT N'Gujarat', N'Narmada' UNION ALL
SELECT N'Gujarat', N'Naswadi' UNION ALL
SELECT N'Gujarat', N'Navasari' UNION ALL
SELECT N'Gujarat', N'Nizar' UNION ALL
SELECT N'Gujarat', N'Okha' UNION ALL
SELECT N'Gujarat', N'Paddhari' UNION ALL
SELECT N'Gujarat', N'Padra' UNION ALL
SELECT N'Gujarat', N'Palanpur' UNION ALL
SELECT N'Gujarat', N'Palitana' UNION ALL
SELECT N'Gujarat', N'Panchmahals' UNION ALL
SELECT N'Gujarat', N'Patan' UNION ALL
SELECT N'Gujarat', N'Pavijetpur' UNION ALL
SELECT N'Gujarat', N'Porbandar' UNION ALL
SELECT N'Gujarat', N'Prantij' UNION ALL
SELECT N'Gujarat', N'Radhanpur' UNION ALL
SELECT N'Gujarat', N'Rahpar' UNION ALL
SELECT N'Gujarat', N'Rajaula' UNION ALL
SELECT N'Gujarat', N'Rajkot' UNION ALL
SELECT N'Gujarat', N'Rajpipla' UNION ALL
SELECT N'Gujarat', N'Ranavav' UNION ALL
SELECT N'Gujarat', N'Sabarkantha' UNION ALL
SELECT N'Gujarat', N'Sanand' UNION ALL
SELECT N'Gujarat', N'Sankheda' UNION ALL
SELECT N'Gujarat', N'Santalpur' UNION ALL
SELECT N'Gujarat', N'Santrampur' UNION ALL
SELECT N'Gujarat', N'Savarkundla' UNION ALL
SELECT N'Gujarat', N'Savli' UNION ALL
SELECT N'Gujarat', N'Sayan' UNION ALL
SELECT N'Gujarat', N'Sayla'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Gujarat', N'Shehra' UNION ALL
SELECT N'Gujarat', N'Sidhpur' UNION ALL
SELECT N'Gujarat', N'Sihor' UNION ALL
SELECT N'Gujarat', N'Sojitra' UNION ALL
SELECT N'Gujarat', N'Sumrasar' UNION ALL
SELECT N'Gujarat', N'Surat' UNION ALL
SELECT N'Gujarat', N'Surendranagar' UNION ALL
SELECT N'Gujarat', N'Talaja' UNION ALL
SELECT N'Gujarat', N'Thara' UNION ALL
SELECT N'Gujarat', N'Tharad' UNION ALL
SELECT N'Gujarat', N'Thasra' UNION ALL
SELECT N'Gujarat', N'Una-Diu' UNION ALL
SELECT N'Gujarat', N'Upleta' UNION ALL
SELECT N'Gujarat', N'Vadgam' UNION ALL
SELECT N'Gujarat', N'Vadodara' UNION ALL
SELECT N'Gujarat', N'Valia' UNION ALL
SELECT N'Gujarat', N'Vallabhipur' UNION ALL
SELECT N'Gujarat', N'Valod' UNION ALL
SELECT N'Gujarat', N'Valsad' UNION ALL
SELECT N'Gujarat', N'Vanthali' UNION ALL
SELECT N'Gujarat', N'Vapi' UNION ALL
SELECT N'Gujarat', N'Vav' UNION ALL
SELECT N'Gujarat', N'Veraval' UNION ALL
SELECT N'Gujarat', N'Vijapur' UNION ALL
SELECT N'Gujarat', N'Viramgam' UNION ALL
SELECT N'Gujarat', N'Visavadar' UNION ALL
SELECT N'Gujarat', N'Visnagar' UNION ALL
SELECT N'Gujarat', N'Vyara' UNION ALL
SELECT N'Gujarat', N'Waghodia' UNION ALL
SELECT N'Gujarat', N'Wankaner' UNION ALL
SELECT N'Haryana', N'Adampur Mandi' UNION ALL
SELECT N'Haryana', N'Ambala' UNION ALL
SELECT N'Haryana', N'Assandh' UNION ALL
SELECT N'Haryana', N'Bahadurgarh' UNION ALL
SELECT N'Haryana', N'Barara' UNION ALL
SELECT N'Haryana', N'Barwala' UNION ALL
SELECT N'Haryana', N'Bawal' UNION ALL
SELECT N'Haryana', N'Bawanikhera' UNION ALL
SELECT N'Haryana', N'Bhiwani' UNION ALL
SELECT N'Haryana', N'Charkhidadri' UNION ALL
SELECT N'Haryana', N'Cheeka' UNION ALL
SELECT N'Haryana', N'Chhachrauli' UNION ALL
SELECT N'Haryana', N'Dabwali' UNION ALL
SELECT N'Haryana', N'Ellenabad' UNION ALL
SELECT N'Haryana', N'Faridabad' UNION ALL
SELECT N'Haryana', N'Fatehabad' UNION ALL
SELECT N'Haryana', N'Ferojpur Jhirka' UNION ALL
SELECT N'Haryana', N'Gharaunda' UNION ALL
SELECT N'Haryana', N'Gohana' UNION ALL
SELECT N'Haryana', N'Gurgaon'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Haryana', N'Hansi' UNION ALL
SELECT N'Haryana', N'Hisar' UNION ALL
SELECT N'Haryana', N'Jagadhari' UNION ALL
SELECT N'Haryana', N'Jatusana' UNION ALL
SELECT N'Haryana', N'Jhajjar' UNION ALL
SELECT N'Haryana', N'Jind' UNION ALL
SELECT N'Haryana', N'Julana' UNION ALL
SELECT N'Haryana', N'Kaithal' UNION ALL
SELECT N'Haryana', N'Kalanaur' UNION ALL
SELECT N'Haryana', N'Kalanwali' UNION ALL
SELECT N'Haryana', N'Kalka' UNION ALL
SELECT N'Haryana', N'Karnal' UNION ALL
SELECT N'Haryana', N'Kosli' UNION ALL
SELECT N'Haryana', N'Kurukshetra' UNION ALL
SELECT N'Haryana', N'Loharu' UNION ALL
SELECT N'Haryana', N'Mahendragarh' UNION ALL
SELECT N'Haryana', N'Meham' UNION ALL
SELECT N'Haryana', N'Mewat' UNION ALL
SELECT N'Haryana', N'Mohindergarh' UNION ALL
SELECT N'Haryana', N'Naraingarh' UNION ALL
SELECT N'Haryana', N'Narnaul' UNION ALL
SELECT N'Haryana', N'Narwana' UNION ALL
SELECT N'Haryana', N'Nilokheri' UNION ALL
SELECT N'Haryana', N'Nuh' UNION ALL
SELECT N'Haryana', N'Palwal' UNION ALL
SELECT N'Haryana', N'Panchkula' UNION ALL
SELECT N'Haryana', N'Panipat' UNION ALL
SELECT N'Haryana', N'Pehowa' UNION ALL
SELECT N'Haryana', N'Ratia' UNION ALL
SELECT N'Haryana', N'Rewari' UNION ALL
SELECT N'Haryana', N'Rohtak' UNION ALL
SELECT N'Haryana', N'Safidon' UNION ALL
SELECT N'Haryana', N'Sirsa' UNION ALL
SELECT N'Haryana', N'Siwani' UNION ALL
SELECT N'Haryana', N'Sonipat' UNION ALL
SELECT N'Haryana', N'Tohana' UNION ALL
SELECT N'Haryana', N'Tohsam' UNION ALL
SELECT N'Haryana', N'Yamunanagar' UNION ALL
SELECT N'Himachal Pradesh', N'Amb' UNION ALL
SELECT N'Himachal Pradesh', N'Arki' UNION ALL
SELECT N'Himachal Pradesh', N'Banjar' UNION ALL
SELECT N'Himachal Pradesh', N'Bharmour' UNION ALL
SELECT N'Himachal Pradesh', N'Bilaspur' UNION ALL
SELECT N'Himachal Pradesh', N'Chamba' UNION ALL
SELECT N'Himachal Pradesh', N'Churah' UNION ALL
SELECT N'Himachal Pradesh', N'Dalhousie' UNION ALL
SELECT N'Himachal Pradesh', N'Dehra Gopipur' UNION ALL
SELECT N'Himachal Pradesh', N'Hamirpur' UNION ALL
SELECT N'Himachal Pradesh', N'Jogindernagar' UNION ALL
SELECT N'Himachal Pradesh', N'Kalpa'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Himachal Pradesh', N'Kangra' UNION ALL
SELECT N'Himachal Pradesh', N'Kinnaur' UNION ALL
SELECT N'Himachal Pradesh', N'Kullu' UNION ALL
SELECT N'Himachal Pradesh', N'Lahaul' UNION ALL
SELECT N'Himachal Pradesh', N'Mandi' UNION ALL
SELECT N'Himachal Pradesh', N'Nahan' UNION ALL
SELECT N'Himachal Pradesh', N'Nalagarh' UNION ALL
SELECT N'Himachal Pradesh', N'Nirmand' UNION ALL
SELECT N'Himachal Pradesh', N'Nurpur' UNION ALL
SELECT N'Himachal Pradesh', N'Palampur' UNION ALL
SELECT N'Himachal Pradesh', N'Pangi' UNION ALL
SELECT N'Himachal Pradesh', N'Paonta' UNION ALL
SELECT N'Himachal Pradesh', N'Pooh' UNION ALL
SELECT N'Himachal Pradesh', N'Rajgarh' UNION ALL
SELECT N'Himachal Pradesh', N'Rampur Bushahar' UNION ALL
SELECT N'Himachal Pradesh', N'Rohru' UNION ALL
SELECT N'Himachal Pradesh', N'Shimla' UNION ALL
SELECT N'Himachal Pradesh', N'Sirmaur' UNION ALL
SELECT N'Himachal Pradesh', N'Solan' UNION ALL
SELECT N'Himachal Pradesh', N'Spiti' UNION ALL
SELECT N'Himachal Pradesh', N'Sundernagar' UNION ALL
SELECT N'Himachal Pradesh', N'Theog' UNION ALL
SELECT N'Himachal Pradesh', N'Udaipur' UNION ALL
SELECT N'Himachal Pradesh', N'Una' UNION ALL
SELECT N'Jammu and Kashmir', N'Akhnoor' UNION ALL
SELECT N'Jammu and Kashmir', N'Anantnag' UNION ALL
SELECT N'Jammu and Kashmir', N'Badgam' UNION ALL
SELECT N'Jammu and Kashmir', N'Bandipur' UNION ALL
SELECT N'Jammu and Kashmir', N'Baramulla' UNION ALL
SELECT N'Jammu and Kashmir', N'Basholi' UNION ALL
SELECT N'Jammu and Kashmir', N'Bedarwah' UNION ALL
SELECT N'Jammu and Kashmir', N'Budgam' UNION ALL
SELECT N'Jammu and Kashmir', N'Doda' UNION ALL
SELECT N'Jammu and Kashmir', N'Gulmarg' UNION ALL
SELECT N'Jammu and Kashmir', N'Jammu' UNION ALL
SELECT N'Jammu and Kashmir', N'Kalakot' UNION ALL
SELECT N'Jammu and Kashmir', N'Kargil' UNION ALL
SELECT N'Jammu and Kashmir', N'Karnah' UNION ALL
SELECT N'Jammu and Kashmir', N'Kathua' UNION ALL
SELECT N'Jammu and Kashmir', N'Kishtwar' UNION ALL
SELECT N'Jammu and Kashmir', N'Kulgam' UNION ALL
SELECT N'Jammu and Kashmir', N'Kupwara' UNION ALL
SELECT N'Jammu and Kashmir', N'Leh' UNION ALL
SELECT N'Jammu and Kashmir', N'Mahore' UNION ALL
SELECT N'Jammu and Kashmir', N'Nagrota' UNION ALL
SELECT N'Jammu and Kashmir', N'Nobra' UNION ALL
SELECT N'Jammu and Kashmir', N'Nowshera' UNION ALL
SELECT N'Jammu and Kashmir', N'Nyoma' UNION ALL
SELECT N'Jammu and Kashmir', N'Padam' UNION ALL
SELECT N'Jammu and Kashmir', N'Pahalgam'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Jammu and Kashmir', N'Patnitop' UNION ALL
SELECT N'Jammu and Kashmir', N'Poonch' UNION ALL
SELECT N'Jammu and Kashmir', N'Pulwama' UNION ALL
SELECT N'Jammu and Kashmir', N'Rajouri' UNION ALL
SELECT N'Jammu and Kashmir', N'Ramban' UNION ALL
SELECT N'Jammu and Kashmir', N'Ramnagar' UNION ALL
SELECT N'Jammu and Kashmir', N'Reasi' UNION ALL
SELECT N'Jammu and Kashmir', N'Samba' UNION ALL
SELECT N'Jammu and Kashmir', N'Srinagar' UNION ALL
SELECT N'Jammu and Kashmir', N'Udhampur' UNION ALL
SELECT N'Jammu and Kashmir', N'Vaishno Devi' UNION ALL
SELECT N'Jharkhand', N'Bagodar' UNION ALL
SELECT N'Jharkhand', N'Baharagora' UNION ALL
SELECT N'Jharkhand', N'Balumath' UNION ALL
SELECT N'Jharkhand', N'Barhi' UNION ALL
SELECT N'Jharkhand', N'Barkagaon' UNION ALL
SELECT N'Jharkhand', N'Barwadih' UNION ALL
SELECT N'Jharkhand', N'Basia' UNION ALL
SELECT N'Jharkhand', N'Bermo' UNION ALL
SELECT N'Jharkhand', N'Bhandaria' UNION ALL
SELECT N'Jharkhand', N'Bhawanathpur' UNION ALL
SELECT N'Jharkhand', N'Bishrampur' UNION ALL
SELECT N'Jharkhand', N'Bokaro' UNION ALL
SELECT N'Jharkhand', N'Bolwa' UNION ALL
SELECT N'Jharkhand', N'Bundu' UNION ALL
SELECT N'Jharkhand', N'Chaibasa' UNION ALL
SELECT N'Jharkhand', N'Chainpur' UNION ALL
SELECT N'Jharkhand', N'Chakardharpur' UNION ALL
SELECT N'Jharkhand', N'Chandil' UNION ALL
SELECT N'Jharkhand', N'Chatra' UNION ALL
SELECT N'Jharkhand', N'Chavparan' UNION ALL
SELECT N'Jharkhand', N'Daltonganj' UNION ALL
SELECT N'Jharkhand', N'Deoghar' UNION ALL
SELECT N'Jharkhand', N'Dhanbad' UNION ALL
SELECT N'Jharkhand', N'Dumka' UNION ALL
SELECT N'Jharkhand', N'Dumri' UNION ALL
SELECT N'Jharkhand', N'Garhwa' UNION ALL
SELECT N'Jharkhand', N'Garu' UNION ALL
SELECT N'Jharkhand', N'Ghaghra' UNION ALL
SELECT N'Jharkhand', N'Ghatsila' UNION ALL
SELECT N'Jharkhand', N'Giridih' UNION ALL
SELECT N'Jharkhand', N'Godda' UNION ALL
SELECT N'Jharkhand', N'Gomia' UNION ALL
SELECT N'Jharkhand', N'Govindpur' UNION ALL
SELECT N'Jharkhand', N'Gumla' UNION ALL
SELECT N'Jharkhand', N'Hazaribagh' UNION ALL
SELECT N'Jharkhand', N'Hunterganj' UNION ALL
SELECT N'Jharkhand', N'Ichak' UNION ALL
SELECT N'Jharkhand', N'Itki' UNION ALL
SELECT N'Jharkhand', N'Jagarnathpur'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Jharkhand', N'Jamshedpur' UNION ALL
SELECT N'Jharkhand', N'Jamtara' UNION ALL
SELECT N'Jharkhand', N'Japla' UNION ALL
SELECT N'Jharkhand', N'Jharmundi' UNION ALL
SELECT N'Jharkhand', N'Jhinkpani' UNION ALL
SELECT N'Jharkhand', N'Jhumaritalaiya' UNION ALL
SELECT N'Jharkhand', N'Kathikund' UNION ALL
SELECT N'Jharkhand', N'Kharsawa' UNION ALL
SELECT N'Jharkhand', N'Khunti' UNION ALL
SELECT N'Jharkhand', N'Koderma' UNION ALL
SELECT N'Jharkhand', N'Kolebira' UNION ALL
SELECT N'Jharkhand', N'Latehar' UNION ALL
SELECT N'Jharkhand', N'Lohardaga' UNION ALL
SELECT N'Jharkhand', N'Madhupur' UNION ALL
SELECT N'Jharkhand', N'Mahagama' UNION ALL
SELECT N'Jharkhand', N'Maheshpur Raj' UNION ALL
SELECT N'Jharkhand', N'Mandar' UNION ALL
SELECT N'Jharkhand', N'Mandu' UNION ALL
SELECT N'Jharkhand', N'Manoharpur' UNION ALL
SELECT N'Jharkhand', N'Muri' UNION ALL
SELECT N'Jharkhand', N'Nagarutatri' UNION ALL
SELECT N'Jharkhand', N'Nala' UNION ALL
SELECT N'Jharkhand', N'Noamundi' UNION ALL
SELECT N'Jharkhand', N'Pakur' UNION ALL
SELECT N'Jharkhand', N'Palamu' UNION ALL
SELECT N'Jharkhand', N'Palkot' UNION ALL
SELECT N'Jharkhand', N'Patan' UNION ALL
SELECT N'Jharkhand', N'Rajdhanwar' UNION ALL
SELECT N'Jharkhand', N'Rajmahal' UNION ALL
SELECT N'Jharkhand', N'Ramgarh' UNION ALL
SELECT N'Jharkhand', N'Ranchi' UNION ALL
SELECT N'Jharkhand', N'Sahibganj' UNION ALL
SELECT N'Jharkhand', N'Saraikela' UNION ALL
SELECT N'Jharkhand', N'Simaria' UNION ALL
SELECT N'Jharkhand', N'Simdega' UNION ALL
SELECT N'Jharkhand', N'Singhbhum' UNION ALL
SELECT N'Jharkhand', N'Tisri' UNION ALL
SELECT N'Jharkhand', N'Torpa' UNION ALL
SELECT N'Karnataka', N'Afzalpur' UNION ALL
SELECT N'Karnataka', N'Ainapur' UNION ALL
SELECT N'Karnataka', N'Aland' UNION ALL
SELECT N'Karnataka', N'Alur' UNION ALL
SELECT N'Karnataka', N'Anekal' UNION ALL
SELECT N'Karnataka', N'Ankola' UNION ALL
SELECT N'Karnataka', N'Arsikere' UNION ALL
SELECT N'Karnataka', N'Athani' UNION ALL
SELECT N'Karnataka', N'Aurad' UNION ALL
SELECT N'Karnataka', N'Bableshwar' UNION ALL
SELECT N'Karnataka', N'Badami' UNION ALL
SELECT N'Karnataka', N'Bagalkot'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Karnataka', N'Bagepalli' UNION ALL
SELECT N'Karnataka', N'Bailhongal' UNION ALL
SELECT N'Karnataka', N'Bangalore' UNION ALL
SELECT N'Karnataka', N'Bangalore Rural' UNION ALL
SELECT N'Karnataka', N'Bangarpet' UNION ALL
SELECT N'Karnataka', N'Bantwal' UNION ALL
SELECT N'Karnataka', N'Basavakalyan' UNION ALL
SELECT N'Karnataka', N'Basavanabagewadi' UNION ALL
SELECT N'Karnataka', N'Basavapatna' UNION ALL
SELECT N'Karnataka', N'Belgaum' UNION ALL
SELECT N'Karnataka', N'Bellary' UNION ALL
SELECT N'Karnataka', N'Belthangady' UNION ALL
SELECT N'Karnataka', N'Belur' UNION ALL
SELECT N'Karnataka', N'Bhadravati' UNION ALL
SELECT N'Karnataka', N'Bhalki' UNION ALL
SELECT N'Karnataka', N'Bhatkal' UNION ALL
SELECT N'Karnataka', N'Bidar' UNION ALL
SELECT N'Karnataka', N'Bijapur' UNION ALL
SELECT N'Karnataka', N'Biligi' UNION ALL
SELECT N'Karnataka', N'Chadchan' UNION ALL
SELECT N'Karnataka', N'Challakere' UNION ALL
SELECT N'Karnataka', N'Chamrajnagar' UNION ALL
SELECT N'Karnataka', N'Channagiri' UNION ALL
SELECT N'Karnataka', N'Channapatna' UNION ALL
SELECT N'Karnataka', N'Channarayapatna' UNION ALL
SELECT N'Karnataka', N'Chickmagalur' UNION ALL
SELECT N'Karnataka', N'Chikballapur' UNION ALL
SELECT N'Karnataka', N'Chikkaballapur' UNION ALL
SELECT N'Karnataka', N'Chikkanayakanahalli' UNION ALL
SELECT N'Karnataka', N'Chikkodi' UNION ALL
SELECT N'Karnataka', N'Chikmagalur' UNION ALL
SELECT N'Karnataka', N'Chincholi' UNION ALL
SELECT N'Karnataka', N'Chintamani' UNION ALL
SELECT N'Karnataka', N'Chitradurga' UNION ALL
SELECT N'Karnataka', N'Chittapur' UNION ALL
SELECT N'Karnataka', N'Cowdahalli' UNION ALL
SELECT N'Karnataka', N'Davanagere' UNION ALL
SELECT N'Karnataka', N'Deodurga' UNION ALL
SELECT N'Karnataka', N'Devangere' UNION ALL
SELECT N'Karnataka', N'Devarahippargi' UNION ALL
SELECT N'Karnataka', N'Dharwad' UNION ALL
SELECT N'Karnataka', N'Doddaballapur' UNION ALL
SELECT N'Karnataka', N'Gadag' UNION ALL
SELECT N'Karnataka', N'Gangavathi' UNION ALL
SELECT N'Karnataka', N'Gokak' UNION ALL
SELECT N'Karnataka', N'Gowribdanpur' UNION ALL
SELECT N'Karnataka', N'Gubbi' UNION ALL
SELECT N'Karnataka', N'Gulbarga' UNION ALL
SELECT N'Karnataka', N'Gundlupet' UNION ALL
SELECT N'Karnataka', N'H.B.Halli'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Karnataka', N'H.D. Kote' UNION ALL
SELECT N'Karnataka', N'Haliyal' UNION ALL
SELECT N'Karnataka', N'Hampi' UNION ALL
SELECT N'Karnataka', N'Hangal' UNION ALL
SELECT N'Karnataka', N'Harapanahalli' UNION ALL
SELECT N'Karnataka', N'Hassan' UNION ALL
SELECT N'Karnataka', N'Haveri' UNION ALL
SELECT N'Karnataka', N'Hebri' UNION ALL
SELECT N'Karnataka', N'Hirekerur' UNION ALL
SELECT N'Karnataka', N'Hiriyur' UNION ALL
SELECT N'Karnataka', N'Holalkere' UNION ALL
SELECT N'Karnataka', N'Holenarsipur' UNION ALL
SELECT N'Karnataka', N'Honnali' UNION ALL
SELECT N'Karnataka', N'Honnavar' UNION ALL
SELECT N'Karnataka', N'Hosadurga' UNION ALL
SELECT N'Karnataka', N'Hosakote' UNION ALL
SELECT N'Karnataka', N'Hosanagara' UNION ALL
SELECT N'Karnataka', N'Hospet' UNION ALL
SELECT N'Karnataka', N'Hubli' UNION ALL
SELECT N'Karnataka', N'Hukkeri' UNION ALL
SELECT N'Karnataka', N'Humnabad' UNION ALL
SELECT N'Karnataka', N'Hungund' UNION ALL
SELECT N'Karnataka', N'Hunsagi' UNION ALL
SELECT N'Karnataka', N'Hunsur' UNION ALL
SELECT N'Karnataka', N'Huvinahadagali' UNION ALL
SELECT N'Karnataka', N'Indi' UNION ALL
SELECT N'Karnataka', N'Jagalur' UNION ALL
SELECT N'Karnataka', N'Jamkhandi' UNION ALL
SELECT N'Karnataka', N'Jewargi' UNION ALL
SELECT N'Karnataka', N'Joida' UNION ALL
SELECT N'Karnataka', N'K.R. Nagar' UNION ALL
SELECT N'Karnataka', N'Kadur' UNION ALL
SELECT N'Karnataka', N'Kalghatagi' UNION ALL
SELECT N'Karnataka', N'Kamalapur' UNION ALL
SELECT N'Karnataka', N'Kanakapura' UNION ALL
SELECT N'Karnataka', N'Kannada' UNION ALL
SELECT N'Karnataka', N'Kargal' UNION ALL
SELECT N'Karnataka', N'Karkala' UNION ALL
SELECT N'Karnataka', N'Karwar' UNION ALL
SELECT N'Karnataka', N'Khanapur' UNION ALL
SELECT N'Karnataka', N'Kodagu' UNION ALL
SELECT N'Karnataka', N'Kolar' UNION ALL
SELECT N'Karnataka', N'Kollegal' UNION ALL
SELECT N'Karnataka', N'Koppa' UNION ALL
SELECT N'Karnataka', N'Koppal' UNION ALL
SELECT N'Karnataka', N'Koratageri' UNION ALL
SELECT N'Karnataka', N'Krishnarajapet' UNION ALL
SELECT N'Karnataka', N'Kudligi' UNION ALL
SELECT N'Karnataka', N'Kumta' UNION ALL
SELECT N'Karnataka', N'Kundapur'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Karnataka', N'Kundgol' UNION ALL
SELECT N'Karnataka', N'Kunigal' UNION ALL
SELECT N'Karnataka', N'Kurugodu' UNION ALL
SELECT N'Karnataka', N'Kustagi' UNION ALL
SELECT N'Karnataka', N'Lingsugur' UNION ALL
SELECT N'Karnataka', N'Madikeri' UNION ALL
SELECT N'Karnataka', N'Madugiri' UNION ALL
SELECT N'Karnataka', N'Malavalli' UNION ALL
SELECT N'Karnataka', N'Malur' UNION ALL
SELECT N'Karnataka', N'Mandya' UNION ALL
SELECT N'Karnataka', N'Mangalore' UNION ALL
SELECT N'Karnataka', N'Manipal' UNION ALL
SELECT N'Karnataka', N'Manvi' UNION ALL
SELECT N'Karnataka', N'Mashal' UNION ALL
SELECT N'Karnataka', N'Molkalmuru' UNION ALL
SELECT N'Karnataka', N'Mudalgi' UNION ALL
SELECT N'Karnataka', N'Muddebihal' UNION ALL
SELECT N'Karnataka', N'Mudhol' UNION ALL
SELECT N'Karnataka', N'Mudigere' UNION ALL
SELECT N'Karnataka', N'Mulbagal' UNION ALL
SELECT N'Karnataka', N'Mundagod' UNION ALL
SELECT N'Karnataka', N'Mundargi' UNION ALL
SELECT N'Karnataka', N'Murugod' UNION ALL
SELECT N'Karnataka', N'Mysore' UNION ALL
SELECT N'Karnataka', N'Nagamangala' UNION ALL
SELECT N'Karnataka', N'Nanjangud' UNION ALL
SELECT N'Karnataka', N'Nargund' UNION ALL
SELECT N'Karnataka', N'Narsimrajapur' UNION ALL
SELECT N'Karnataka', N'Navalgund' UNION ALL
SELECT N'Karnataka', N'Nelamangala' UNION ALL
SELECT N'Karnataka', N'Nimburga' UNION ALL
SELECT N'Karnataka', N'Pandavapura' UNION ALL
SELECT N'Karnataka', N'Pavagada' UNION ALL
SELECT N'Karnataka', N'Puttur' UNION ALL
SELECT N'Karnataka', N'Raibag' UNION ALL
SELECT N'Karnataka', N'Raichur' UNION ALL
SELECT N'Karnataka', N'Ramdurg' UNION ALL
SELECT N'Karnataka', N'Ranebennur' UNION ALL
SELECT N'Karnataka', N'Ron' UNION ALL
SELECT N'Karnataka', N'Sagar' UNION ALL
SELECT N'Karnataka', N'Sakleshpur' UNION ALL
SELECT N'Karnataka', N'Salkani' UNION ALL
SELECT N'Karnataka', N'Sandur' UNION ALL
SELECT N'Karnataka', N'Saundatti' UNION ALL
SELECT N'Karnataka', N'Savanur' UNION ALL
SELECT N'Karnataka', N'Sedam' UNION ALL
SELECT N'Karnataka', N'Shahapur' UNION ALL
SELECT N'Karnataka', N'Shankarnarayana' UNION ALL
SELECT N'Karnataka', N'Shikaripura' UNION ALL
SELECT N'Karnataka', N'Shimoga'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Karnataka', N'Shirahatti' UNION ALL
SELECT N'Karnataka', N'Shorapur' UNION ALL
SELECT N'Karnataka', N'Siddapur' UNION ALL
SELECT N'Karnataka', N'Sidlaghatta' UNION ALL
SELECT N'Karnataka', N'Sindagi' UNION ALL
SELECT N'Karnataka', N'Sindhanur' UNION ALL
SELECT N'Karnataka', N'Sira' UNION ALL
SELECT N'Karnataka', N'Sirsi' UNION ALL
SELECT N'Karnataka', N'Siruguppa' UNION ALL
SELECT N'Karnataka', N'Somwarpet' UNION ALL
SELECT N'Karnataka', N'Sorab' UNION ALL
SELECT N'Karnataka', N'Sringeri' UNION ALL
SELECT N'Karnataka', N'Sriniwaspur' UNION ALL
SELECT N'Karnataka', N'Srirangapatna' UNION ALL
SELECT N'Karnataka', N'Sullia' UNION ALL
SELECT N'Karnataka', N'T. Narsipur' UNION ALL
SELECT N'Karnataka', N'Tallak' UNION ALL
SELECT N'Karnataka', N'Tarikere' UNION ALL
SELECT N'Karnataka', N'Telgi' UNION ALL
SELECT N'Karnataka', N'Thirthahalli' UNION ALL
SELECT N'Karnataka', N'Tiptur' UNION ALL
SELECT N'Karnataka', N'Tumkur' UNION ALL
SELECT N'Karnataka', N'Turuvekere' UNION ALL
SELECT N'Karnataka', N'Udupi' UNION ALL
SELECT N'Karnataka', N'Virajpet' UNION ALL
SELECT N'Karnataka', N'Wadi' UNION ALL
SELECT N'Karnataka', N'Yadgiri' UNION ALL
SELECT N'Karnataka', N'Yelburga' UNION ALL
SELECT N'Karnataka', N'Yellapur' UNION ALL
SELECT N'Kerala', N'Adimaly' UNION ALL
SELECT N'Kerala', N'Adoor' UNION ALL
SELECT N'Kerala', N'Agathy' UNION ALL
SELECT N'Kerala', N'Alappuzha' UNION ALL
SELECT N'Kerala', N'Alathur' UNION ALL
SELECT N'Kerala', N'Alleppey' UNION ALL
SELECT N'Kerala', N'Alwaye' UNION ALL
SELECT N'Kerala', N'Amini' UNION ALL
SELECT N'Kerala', N'Androth' UNION ALL
SELECT N'Kerala', N'Attingal' UNION ALL
SELECT N'Kerala', N'Badagara' UNION ALL
SELECT N'Kerala', N'Bitra' UNION ALL
SELECT N'Kerala', N'Calicut' UNION ALL
SELECT N'Kerala', N'Cannanore' UNION ALL
SELECT N'Kerala', N'Chetlet' UNION ALL
SELECT N'Kerala', N'Ernakulam' UNION ALL
SELECT N'Kerala', N'Idukki' UNION ALL
SELECT N'Kerala', N'Irinjalakuda' UNION ALL
SELECT N'Kerala', N'Kadamath' UNION ALL
SELECT N'Kerala', N'Kalpeni' UNION ALL
SELECT N'Kerala', N'Kalpetta'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Kerala', N'Kanhangad' UNION ALL
SELECT N'Kerala', N'Kanjirapally' UNION ALL
SELECT N'Kerala', N'Kannur' UNION ALL
SELECT N'Kerala', N'Karungapally' UNION ALL
SELECT N'Kerala', N'Kasargode' UNION ALL
SELECT N'Kerala', N'Kavarathy' UNION ALL
SELECT N'Kerala', N'Kiltan' UNION ALL
SELECT N'Kerala', N'Kochi' UNION ALL
SELECT N'Kerala', N'Koduvayur' UNION ALL
SELECT N'Kerala', N'Kollam' UNION ALL
SELECT N'Kerala', N'Kottayam' UNION ALL
SELECT N'Kerala', N'Kovalam' UNION ALL
SELECT N'Kerala', N'Kozhikode' UNION ALL
SELECT N'Kerala', N'Kunnamkulam' UNION ALL
SELECT N'Kerala', N'Malappuram' UNION ALL
SELECT N'Kerala', N'Mananthodi' UNION ALL
SELECT N'Kerala', N'Manjeri' UNION ALL
SELECT N'Kerala', N'Mannarghat' UNION ALL
SELECT N'Kerala', N'Mavelikkara' UNION ALL
SELECT N'Kerala', N'Minicoy' UNION ALL
SELECT N'Kerala', N'Munnar' UNION ALL
SELECT N'Kerala', N'Muvattupuzha' UNION ALL
SELECT N'Kerala', N'Nedumandad' UNION ALL
SELECT N'Kerala', N'Nedumgandam' UNION ALL
SELECT N'Kerala', N'Nilambur' UNION ALL
SELECT N'Kerala', N'Palai' UNION ALL
SELECT N'Kerala', N'Palakkad' UNION ALL
SELECT N'Kerala', N'Palghat' UNION ALL
SELECT N'Kerala', N'Pathaanamthitta' UNION ALL
SELECT N'Kerala', N'Pathanamthitta' UNION ALL
SELECT N'Kerala', N'Payyanur' UNION ALL
SELECT N'Kerala', N'Peermedu' UNION ALL
SELECT N'Kerala', N'Perinthalmanna' UNION ALL
SELECT N'Kerala', N'Perumbavoor' UNION ALL
SELECT N'Kerala', N'Punalur' UNION ALL
SELECT N'Kerala', N'Quilon' UNION ALL
SELECT N'Kerala', N'Ranni' UNION ALL
SELECT N'Kerala', N'Shertallai' UNION ALL
SELECT N'Kerala', N'Shoranur' UNION ALL
SELECT N'Kerala', N'Taliparamba' UNION ALL
SELECT N'Kerala', N'Tellicherry' UNION ALL
SELECT N'Kerala', N'Thiruvananthapuram' UNION ALL
SELECT N'Kerala', N'Thodupuzha' UNION ALL
SELECT N'Kerala', N'Thrissur' UNION ALL
SELECT N'Kerala', N'Tirur' UNION ALL
SELECT N'Kerala', N'Tiruvalla' UNION ALL
SELECT N'Kerala', N'Trichur' UNION ALL
SELECT N'Kerala', N'Trivandrum' UNION ALL
SELECT N'Kerala', N'Uppala' UNION ALL
SELECT N'Kerala', N'Vadakkanchery'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Kerala', N'Vikom' UNION ALL
SELECT N'Kerala', N'Wayanad' UNION ALL
SELECT N'Lakshadweep', N'Agatti Island' UNION ALL
SELECT N'Lakshadweep', N'Bingaram Island' UNION ALL
SELECT N'Lakshadweep', N'Bitra Island' UNION ALL
SELECT N'Lakshadweep', N'Chetlat Island' UNION ALL
SELECT N'Lakshadweep', N'Kadmat Island' UNION ALL
SELECT N'Lakshadweep', N'Kalpeni Island' UNION ALL
SELECT N'Lakshadweep', N'Kavaratti Island' UNION ALL
SELECT N'Lakshadweep', N'Kiltan Island' UNION ALL
SELECT N'Lakshadweep', N'Lakshadweep Sea' UNION ALL
SELECT N'Lakshadweep', N'Minicoy Island' UNION ALL
SELECT N'Lakshadweep', N'North Island' UNION ALL
SELECT N'Lakshadweep', N'South Island' UNION ALL
SELECT N'Madhya Pradesh', N'Agar' UNION ALL
SELECT N'Madhya Pradesh', N'Ajaigarh' UNION ALL
SELECT N'Madhya Pradesh', N'Alirajpur' UNION ALL
SELECT N'Madhya Pradesh', N'Amarpatan' UNION ALL
SELECT N'Madhya Pradesh', N'Amarwada' UNION ALL
SELECT N'Madhya Pradesh', N'Ambah' UNION ALL
SELECT N'Madhya Pradesh', N'Anuppur' UNION ALL
SELECT N'Madhya Pradesh', N'Arone' UNION ALL
SELECT N'Madhya Pradesh', N'Ashoknagar' UNION ALL
SELECT N'Madhya Pradesh', N'Ashta' UNION ALL
SELECT N'Madhya Pradesh', N'Atner' UNION ALL
SELECT N'Madhya Pradesh', N'Babaichichli' UNION ALL
SELECT N'Madhya Pradesh', N'Badamalhera' UNION ALL
SELECT N'Madhya Pradesh', N'Badarwsas' UNION ALL
SELECT N'Madhya Pradesh', N'Badnagar' UNION ALL
SELECT N'Madhya Pradesh', N'Badnawar' UNION ALL
SELECT N'Madhya Pradesh', N'Badwani' UNION ALL
SELECT N'Madhya Pradesh', N'Bagli' UNION ALL
SELECT N'Madhya Pradesh', N'Baihar' UNION ALL
SELECT N'Madhya Pradesh', N'Balaghat' UNION ALL
SELECT N'Madhya Pradesh', N'Baldeogarh' UNION ALL
SELECT N'Madhya Pradesh', N'Baldi' UNION ALL
SELECT N'Madhya Pradesh', N'Bamori' UNION ALL
SELECT N'Madhya Pradesh', N'Banda' UNION ALL
SELECT N'Madhya Pradesh', N'Bandhavgarh' UNION ALL
SELECT N'Madhya Pradesh', N'Bareli' UNION ALL
SELECT N'Madhya Pradesh', N'Baroda' UNION ALL
SELECT N'Madhya Pradesh', N'Barwaha' UNION ALL
SELECT N'Madhya Pradesh', N'Barwani' UNION ALL
SELECT N'Madhya Pradesh', N'Batkakhapa' UNION ALL
SELECT N'Madhya Pradesh', N'Begamganj' UNION ALL
SELECT N'Madhya Pradesh', N'Beohari' UNION ALL
SELECT N'Madhya Pradesh', N'Berasia' UNION ALL
SELECT N'Madhya Pradesh', N'Berchha' UNION ALL
SELECT N'Madhya Pradesh', N'Betul' UNION ALL
SELECT N'Madhya Pradesh', N'Bhainsdehi'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Madhya Pradesh', N'Bhander' UNION ALL
SELECT N'Madhya Pradesh', N'Bhanpura' UNION ALL
SELECT N'Madhya Pradesh', N'Bhikangaon' UNION ALL
SELECT N'Madhya Pradesh', N'Bhimpur' UNION ALL
SELECT N'Madhya Pradesh', N'Bhind' UNION ALL
SELECT N'Madhya Pradesh', N'Bhitarwar' UNION ALL
SELECT N'Madhya Pradesh', N'Bhopal' UNION ALL
SELECT N'Madhya Pradesh', N'Biaora' UNION ALL
SELECT N'Madhya Pradesh', N'Bijadandi' UNION ALL
SELECT N'Madhya Pradesh', N'Bijawar' UNION ALL
SELECT N'Madhya Pradesh', N'Bijaypur' UNION ALL
SELECT N'Madhya Pradesh', N'Bina' UNION ALL
SELECT N'Madhya Pradesh', N'Birsa' UNION ALL
SELECT N'Madhya Pradesh', N'Birsinghpur' UNION ALL
SELECT N'Madhya Pradesh', N'Budhni' UNION ALL
SELECT N'Madhya Pradesh', N'Burhanpur' UNION ALL
SELECT N'Madhya Pradesh', N'Buxwaha' UNION ALL
SELECT N'Madhya Pradesh', N'Chachaura' UNION ALL
SELECT N'Madhya Pradesh', N'Chanderi' UNION ALL
SELECT N'Madhya Pradesh', N'Chaurai' UNION ALL
SELECT N'Madhya Pradesh', N'Chhapara' UNION ALL
SELECT N'Madhya Pradesh', N'Chhatarpur' UNION ALL
SELECT N'Madhya Pradesh', N'Chhindwara' UNION ALL
SELECT N'Madhya Pradesh', N'Chicholi' UNION ALL
SELECT N'Madhya Pradesh', N'Chitrangi' UNION ALL
SELECT N'Madhya Pradesh', N'Churhat' UNION ALL
SELECT N'Madhya Pradesh', N'Dabra' UNION ALL
SELECT N'Madhya Pradesh', N'Damoh' UNION ALL
SELECT N'Madhya Pradesh', N'Datia' UNION ALL
SELECT N'Madhya Pradesh', N'Deori' UNION ALL
SELECT N'Madhya Pradesh', N'Deosar' UNION ALL
SELECT N'Madhya Pradesh', N'Depalpur' UNION ALL
SELECT N'Madhya Pradesh', N'Dewas' UNION ALL
SELECT N'Madhya Pradesh', N'Dhar' UNION ALL
SELECT N'Madhya Pradesh', N'Dharampuri' UNION ALL
SELECT N'Madhya Pradesh', N'Dindori' UNION ALL
SELECT N'Madhya Pradesh', N'Gadarwara' UNION ALL
SELECT N'Madhya Pradesh', N'Gairatganj' UNION ALL
SELECT N'Madhya Pradesh', N'Ganjbasoda' UNION ALL
SELECT N'Madhya Pradesh', N'Garoth' UNION ALL
SELECT N'Madhya Pradesh', N'Ghansour' UNION ALL
SELECT N'Madhya Pradesh', N'Ghatia' UNION ALL
SELECT N'Madhya Pradesh', N'Ghatigaon' UNION ALL
SELECT N'Madhya Pradesh', N'Ghorandogri' UNION ALL
SELECT N'Madhya Pradesh', N'Ghughari' UNION ALL
SELECT N'Madhya Pradesh', N'Gogaon' UNION ALL
SELECT N'Madhya Pradesh', N'Gohad' UNION ALL
SELECT N'Madhya Pradesh', N'Goharganj' UNION ALL
SELECT N'Madhya Pradesh', N'Gopalganj' UNION ALL
SELECT N'Madhya Pradesh', N'Gotegaon'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Madhya Pradesh', N'Gourihar' UNION ALL
SELECT N'Madhya Pradesh', N'Guna' UNION ALL
SELECT N'Madhya Pradesh', N'Gunnore' UNION ALL
SELECT N'Madhya Pradesh', N'Gwalior' UNION ALL
SELECT N'Madhya Pradesh', N'Gyraspur' UNION ALL
SELECT N'Madhya Pradesh', N'Hanumana' UNION ALL
SELECT N'Madhya Pradesh', N'Harda' UNION ALL
SELECT N'Madhya Pradesh', N'Harrai' UNION ALL
SELECT N'Madhya Pradesh', N'Harsud' UNION ALL
SELECT N'Madhya Pradesh', N'Hatta' UNION ALL
SELECT N'Madhya Pradesh', N'Hoshangabad' UNION ALL
SELECT N'Madhya Pradesh', N'Ichhawar' UNION ALL
SELECT N'Madhya Pradesh', N'Indore' UNION ALL
SELECT N'Madhya Pradesh', N'Isagarh' UNION ALL
SELECT N'Madhya Pradesh', N'Itarsi' UNION ALL
SELECT N'Madhya Pradesh', N'Jabalpur' UNION ALL
SELECT N'Madhya Pradesh', N'Jabera' UNION ALL
SELECT N'Madhya Pradesh', N'Jagdalpur' UNION ALL
SELECT N'Madhya Pradesh', N'Jaisinghnagar' UNION ALL
SELECT N'Madhya Pradesh', N'Jaithari' UNION ALL
SELECT N'Madhya Pradesh', N'Jaitpur' UNION ALL
SELECT N'Madhya Pradesh', N'Jaitwara' UNION ALL
SELECT N'Madhya Pradesh', N'Jamai' UNION ALL
SELECT N'Madhya Pradesh', N'Jaora' UNION ALL
SELECT N'Madhya Pradesh', N'Jatara' UNION ALL
SELECT N'Madhya Pradesh', N'Jawad' UNION ALL
SELECT N'Madhya Pradesh', N'Jhabua' UNION ALL
SELECT N'Madhya Pradesh', N'Jobat' UNION ALL
SELECT N'Madhya Pradesh', N'Jora' UNION ALL
SELECT N'Madhya Pradesh', N'Kakaiya' UNION ALL
SELECT N'Madhya Pradesh', N'Kannod' UNION ALL
SELECT N'Madhya Pradesh', N'Kannodi' UNION ALL
SELECT N'Madhya Pradesh', N'Karanjia' UNION ALL
SELECT N'Madhya Pradesh', N'Kareli' UNION ALL
SELECT N'Madhya Pradesh', N'Karera' UNION ALL
SELECT N'Madhya Pradesh', N'Karhal' UNION ALL
SELECT N'Madhya Pradesh', N'Karpa' UNION ALL
SELECT N'Madhya Pradesh', N'Kasrawad' UNION ALL
SELECT N'Madhya Pradesh', N'Katangi' UNION ALL
SELECT N'Madhya Pradesh', N'Katni' UNION ALL
SELECT N'Madhya Pradesh', N'Keolari' UNION ALL
SELECT N'Madhya Pradesh', N'Khachrod' UNION ALL
SELECT N'Madhya Pradesh', N'Khajuraho' UNION ALL
SELECT N'Madhya Pradesh', N'Khakner' UNION ALL
SELECT N'Madhya Pradesh', N'Khalwa' UNION ALL
SELECT N'Madhya Pradesh', N'Khandwa' UNION ALL
SELECT N'Madhya Pradesh', N'Khaniadhana' UNION ALL
SELECT N'Madhya Pradesh', N'Khargone' UNION ALL
SELECT N'Madhya Pradesh', N'Khategaon' UNION ALL
SELECT N'Madhya Pradesh', N'Khetia'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Madhya Pradesh', N'Khilchipur' UNION ALL
SELECT N'Madhya Pradesh', N'Khirkiya' UNION ALL
SELECT N'Madhya Pradesh', N'Khurai' UNION ALL
SELECT N'Madhya Pradesh', N'Kolaras' UNION ALL
SELECT N'Madhya Pradesh', N'Kotma' UNION ALL
SELECT N'Madhya Pradesh', N'Kukshi' UNION ALL
SELECT N'Madhya Pradesh', N'Kundam' UNION ALL
SELECT N'Madhya Pradesh', N'Kurwai' UNION ALL
SELECT N'Madhya Pradesh', N'Kusmi' UNION ALL
SELECT N'Madhya Pradesh', N'Laher' UNION ALL
SELECT N'Madhya Pradesh', N'Lakhnadon' UNION ALL
SELECT N'Madhya Pradesh', N'Lamta' UNION ALL
SELECT N'Madhya Pradesh', N'Lanji' UNION ALL
SELECT N'Madhya Pradesh', N'Lateri' UNION ALL
SELECT N'Madhya Pradesh', N'Laundi' UNION ALL
SELECT N'Madhya Pradesh', N'Maheshwar' UNION ALL
SELECT N'Madhya Pradesh', N'Mahidpurcity' UNION ALL
SELECT N'Madhya Pradesh', N'Maihar' UNION ALL
SELECT N'Madhya Pradesh', N'Majhagwan' UNION ALL
SELECT N'Madhya Pradesh', N'Majholi' UNION ALL
SELECT N'Madhya Pradesh', N'Malhargarh' UNION ALL
SELECT N'Madhya Pradesh', N'Manasa' UNION ALL
SELECT N'Madhya Pradesh', N'Manawar' UNION ALL
SELECT N'Madhya Pradesh', N'Mandla' UNION ALL
SELECT N'Madhya Pradesh', N'Mandsaur' UNION ALL
SELECT N'Madhya Pradesh', N'Manpur' UNION ALL
SELECT N'Madhya Pradesh', N'Mauganj' UNION ALL
SELECT N'Madhya Pradesh', N'Mawai' UNION ALL
SELECT N'Madhya Pradesh', N'Mehgaon' UNION ALL
SELECT N'Madhya Pradesh', N'Mhow' UNION ALL
SELECT N'Madhya Pradesh', N'Morena' UNION ALL
SELECT N'Madhya Pradesh', N'Multai' UNION ALL
SELECT N'Madhya Pradesh', N'Mungaoli' UNION ALL
SELECT N'Madhya Pradesh', N'Nagod' UNION ALL
SELECT N'Madhya Pradesh', N'Nainpur' UNION ALL
SELECT N'Madhya Pradesh', N'Narsingarh' UNION ALL
SELECT N'Madhya Pradesh', N'Narsinghpur' UNION ALL
SELECT N'Madhya Pradesh', N'Narwar' UNION ALL
SELECT N'Madhya Pradesh', N'Nasrullaganj' UNION ALL
SELECT N'Madhya Pradesh', N'Nateran' UNION ALL
SELECT N'Madhya Pradesh', N'Neemuch' UNION ALL
SELECT N'Madhya Pradesh', N'Niwari' UNION ALL
SELECT N'Madhya Pradesh', N'Niwas' UNION ALL
SELECT N'Madhya Pradesh', N'Nowgaon' UNION ALL
SELECT N'Madhya Pradesh', N'Pachmarhi' UNION ALL
SELECT N'Madhya Pradesh', N'Pandhana' UNION ALL
SELECT N'Madhya Pradesh', N'Pandhurna' UNION ALL
SELECT N'Madhya Pradesh', N'Panna' UNION ALL
SELECT N'Madhya Pradesh', N'Parasia' UNION ALL
SELECT N'Madhya Pradesh', N'Patan'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Madhya Pradesh', N'Patera' UNION ALL
SELECT N'Madhya Pradesh', N'Patharia' UNION ALL
SELECT N'Madhya Pradesh', N'Pawai' UNION ALL
SELECT N'Madhya Pradesh', N'Petlawad' UNION ALL
SELECT N'Madhya Pradesh', N'Pichhore' UNION ALL
SELECT N'Madhya Pradesh', N'Piparia' UNION ALL
SELECT N'Madhya Pradesh', N'Pohari' UNION ALL
SELECT N'Madhya Pradesh', N'Prabhapattan' UNION ALL
SELECT N'Madhya Pradesh', N'Punasa' UNION ALL
SELECT N'Madhya Pradesh', N'Pushprajgarh' UNION ALL
SELECT N'Madhya Pradesh', N'Raghogarh' UNION ALL
SELECT N'Madhya Pradesh', N'Raghunathpur' UNION ALL
SELECT N'Madhya Pradesh', N'Rahatgarh' UNION ALL
SELECT N'Madhya Pradesh', N'Raisen' UNION ALL
SELECT N'Madhya Pradesh', N'Rajgarh' UNION ALL
SELECT N'Madhya Pradesh', N'Rajpur' UNION ALL
SELECT N'Madhya Pradesh', N'Ratlam' UNION ALL
SELECT N'Madhya Pradesh', N'Rehli' UNION ALL
SELECT N'Madhya Pradesh', N'Rewa' UNION ALL
SELECT N'Madhya Pradesh', N'Sabalgarh' UNION ALL
SELECT N'Madhya Pradesh', N'Sagar' UNION ALL
SELECT N'Madhya Pradesh', N'Sailana' UNION ALL
SELECT N'Madhya Pradesh', N'Sanwer' UNION ALL
SELECT N'Madhya Pradesh', N'Sarangpur' UNION ALL
SELECT N'Madhya Pradesh', N'Sardarpur' UNION ALL
SELECT N'Madhya Pradesh', N'Satna' UNION ALL
SELECT N'Madhya Pradesh', N'Saunsar' UNION ALL
SELECT N'Madhya Pradesh', N'Sehore' UNION ALL
SELECT N'Madhya Pradesh', N'Sendhwa' UNION ALL
SELECT N'Madhya Pradesh', N'Seondha' UNION ALL
SELECT N'Madhya Pradesh', N'Seoni' UNION ALL
SELECT N'Madhya Pradesh', N'Seonimalwa' UNION ALL
SELECT N'Madhya Pradesh', N'Shahdol' UNION ALL
SELECT N'Madhya Pradesh', N'Shahnagar' UNION ALL
SELECT N'Madhya Pradesh', N'Shahpur' UNION ALL
SELECT N'Madhya Pradesh', N'Shajapur' UNION ALL
SELECT N'Madhya Pradesh', N'Sheopur' UNION ALL
SELECT N'Madhya Pradesh', N'Sheopurkalan' UNION ALL
SELECT N'Madhya Pradesh', N'Shivpuri' UNION ALL
SELECT N'Madhya Pradesh', N'Shujalpur' UNION ALL
SELECT N'Madhya Pradesh', N'Sidhi' UNION ALL
SELECT N'Madhya Pradesh', N'Sihora' UNION ALL
SELECT N'Madhya Pradesh', N'Silwani' UNION ALL
SELECT N'Madhya Pradesh', N'Singrauli' UNION ALL
SELECT N'Madhya Pradesh', N'Sirmour' UNION ALL
SELECT N'Madhya Pradesh', N'Sironj' UNION ALL
SELECT N'Madhya Pradesh', N'Sitamau' UNION ALL
SELECT N'Madhya Pradesh', N'Sohagpur' UNION ALL
SELECT N'Madhya Pradesh', N'Sondhwa' UNION ALL
SELECT N'Madhya Pradesh', N'Sonkatch'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Madhya Pradesh', N'Susner' UNION ALL
SELECT N'Madhya Pradesh', N'Tamia' UNION ALL
SELECT N'Madhya Pradesh', N'Tarana' UNION ALL
SELECT N'Madhya Pradesh', N'Tendukheda' UNION ALL
SELECT N'Madhya Pradesh', N'Teonthar' UNION ALL
SELECT N'Madhya Pradesh', N'Thandla' UNION ALL
SELECT N'Madhya Pradesh', N'Tikamgarh' UNION ALL
SELECT N'Madhya Pradesh', N'Timarani' UNION ALL
SELECT N'Madhya Pradesh', N'Udaipura' UNION ALL
SELECT N'Madhya Pradesh', N'Ujjain' UNION ALL
SELECT N'Madhya Pradesh', N'Umaria' UNION ALL
SELECT N'Madhya Pradesh', N'Umariapan' UNION ALL
SELECT N'Madhya Pradesh', N'Vidisha' UNION ALL
SELECT N'Madhya Pradesh', N'Vijayraghogarh' UNION ALL
SELECT N'Madhya Pradesh', N'Waraseoni' UNION ALL
SELECT N'Madhya Pradesh', N'Zhirnia' UNION ALL
SELECT N'Maharashtra', N'Achalpur' UNION ALL
SELECT N'Maharashtra', N'Aheri' UNION ALL
SELECT N'Maharashtra', N'Ahmednagar' UNION ALL
SELECT N'Maharashtra', N'Ahmedpur' UNION ALL
SELECT N'Maharashtra', N'Ajara' UNION ALL
SELECT N'Maharashtra', N'Akkalkot' UNION ALL
SELECT N'Maharashtra', N'Akola' UNION ALL
SELECT N'Maharashtra', N'Akole' UNION ALL
SELECT N'Maharashtra', N'Akot' UNION ALL
SELECT N'Maharashtra', N'Alibagh' UNION ALL
SELECT N'Maharashtra', N'Amagaon' UNION ALL
SELECT N'Maharashtra', N'Amalner' UNION ALL
SELECT N'Maharashtra', N'Ambad' UNION ALL
SELECT N'Maharashtra', N'Ambejogai' UNION ALL
SELECT N'Maharashtra', N'Amravati' UNION ALL
SELECT N'Maharashtra', N'Arjuni Merogaon' UNION ALL
SELECT N'Maharashtra', N'Arvi' UNION ALL
SELECT N'Maharashtra', N'Ashti' UNION ALL
SELECT N'Maharashtra', N'Atpadi' UNION ALL
SELECT N'Maharashtra', N'Aurangabad' UNION ALL
SELECT N'Maharashtra', N'Ausa' UNION ALL
SELECT N'Maharashtra', N'Babhulgaon' UNION ALL
SELECT N'Maharashtra', N'Balapur' UNION ALL
SELECT N'Maharashtra', N'Baramati' UNION ALL
SELECT N'Maharashtra', N'Barshi Takli' UNION ALL
SELECT N'Maharashtra', N'Barsi' UNION ALL
SELECT N'Maharashtra', N'Basmatnagar' UNION ALL
SELECT N'Maharashtra', N'Bassein' UNION ALL
SELECT N'Maharashtra', N'Beed' UNION ALL
SELECT N'Maharashtra', N'Bhadrawati' UNION ALL
SELECT N'Maharashtra', N'Bhamregadh' UNION ALL
SELECT N'Maharashtra', N'Bhandara' UNION ALL
SELECT N'Maharashtra', N'Bhir' UNION ALL
SELECT N'Maharashtra', N'Bhiwandi'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Maharashtra', N'Bhiwapur' UNION ALL
SELECT N'Maharashtra', N'Bhokar' UNION ALL
SELECT N'Maharashtra', N'Bhokardan' UNION ALL
SELECT N'Maharashtra', N'Bhoom' UNION ALL
SELECT N'Maharashtra', N'Bhor' UNION ALL
SELECT N'Maharashtra', N'Bhudargad' UNION ALL
SELECT N'Maharashtra', N'Bhusawal' UNION ALL
SELECT N'Maharashtra', N'Billoli' UNION ALL
SELECT N'Maharashtra', N'Brahmapuri' UNION ALL
SELECT N'Maharashtra', N'Buldhana' UNION ALL
SELECT N'Maharashtra', N'Butibori' UNION ALL
SELECT N'Maharashtra', N'Chalisgaon' UNION ALL
SELECT N'Maharashtra', N'Chamorshi' UNION ALL
SELECT N'Maharashtra', N'Chandgad' UNION ALL
SELECT N'Maharashtra', N'Chandrapur' UNION ALL
SELECT N'Maharashtra', N'Chandur' UNION ALL
SELECT N'Maharashtra', N'Chanwad' UNION ALL
SELECT N'Maharashtra', N'Chhikaldara' UNION ALL
SELECT N'Maharashtra', N'Chikhali' UNION ALL
SELECT N'Maharashtra', N'Chinchwad' UNION ALL
SELECT N'Maharashtra', N'Chiplun' UNION ALL
SELECT N'Maharashtra', N'Chopda' UNION ALL
SELECT N'Maharashtra', N'Chumur' UNION ALL
SELECT N'Maharashtra', N'Dahanu' UNION ALL
SELECT N'Maharashtra', N'Dapoli' UNION ALL
SELECT N'Maharashtra', N'Darwaha' UNION ALL
SELECT N'Maharashtra', N'Daryapur' UNION ALL
SELECT N'Maharashtra', N'Daund' UNION ALL
SELECT N'Maharashtra', N'Degloor' UNION ALL
SELECT N'Maharashtra', N'Delhi Tanda' UNION ALL
SELECT N'Maharashtra', N'Deogad' UNION ALL
SELECT N'Maharashtra', N'Deolgaonraja' UNION ALL
SELECT N'Maharashtra', N'Deori' UNION ALL
SELECT N'Maharashtra', N'Desaiganj' UNION ALL
SELECT N'Maharashtra', N'Dhadgaon' UNION ALL
SELECT N'Maharashtra', N'Dhanora' UNION ALL
SELECT N'Maharashtra', N'Dharani' UNION ALL
SELECT N'Maharashtra', N'Dhiwadi' UNION ALL
SELECT N'Maharashtra', N'Dhule' UNION ALL
SELECT N'Maharashtra', N'Dhulia' UNION ALL
SELECT N'Maharashtra', N'Digras' UNION ALL
SELECT N'Maharashtra', N'Dindori' UNION ALL
SELECT N'Maharashtra', N'Edalabad' UNION ALL
SELECT N'Maharashtra', N'Erandul' UNION ALL
SELECT N'Maharashtra', N'Etapalli' UNION ALL
SELECT N'Maharashtra', N'Gadhchiroli' UNION ALL
SELECT N'Maharashtra', N'Gadhinglaj' UNION ALL
SELECT N'Maharashtra', N'Gaganbavada' UNION ALL
SELECT N'Maharashtra', N'Gangakhed' UNION ALL
SELECT N'Maharashtra', N'Gangapur'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Maharashtra', N'Gevrai' UNION ALL
SELECT N'Maharashtra', N'Ghatanji' UNION ALL
SELECT N'Maharashtra', N'Golegaon' UNION ALL
SELECT N'Maharashtra', N'Gondia' UNION ALL
SELECT N'Maharashtra', N'Gondpipri' UNION ALL
SELECT N'Maharashtra', N'Goregaon' UNION ALL
SELECT N'Maharashtra', N'Guhagar' UNION ALL
SELECT N'Maharashtra', N'Hadgaon' UNION ALL
SELECT N'Maharashtra', N'Hatkangale' UNION ALL
SELECT N'Maharashtra', N'Hinganghat' UNION ALL
SELECT N'Maharashtra', N'Hingoli' UNION ALL
SELECT N'Maharashtra', N'Hingua' UNION ALL
SELECT N'Maharashtra', N'Igatpuri' UNION ALL
SELECT N'Maharashtra', N'Indapur' UNION ALL
SELECT N'Maharashtra', N'Islampur' UNION ALL
SELECT N'Maharashtra', N'Jalgaon' UNION ALL
SELECT N'Maharashtra', N'Jalna' UNION ALL
SELECT N'Maharashtra', N'Jamkhed' UNION ALL
SELECT N'Maharashtra', N'Jamner' UNION ALL
SELECT N'Maharashtra', N'Jath' UNION ALL
SELECT N'Maharashtra', N'Jawahar' UNION ALL
SELECT N'Maharashtra', N'Jintdor' UNION ALL
SELECT N'Maharashtra', N'Junnar' UNION ALL
SELECT N'Maharashtra', N'Kagal' UNION ALL
SELECT N'Maharashtra', N'Kaij' UNION ALL
SELECT N'Maharashtra', N'Kalamb' UNION ALL
SELECT N'Maharashtra', N'Kalamnuri' UNION ALL
SELECT N'Maharashtra', N'Kallam' UNION ALL
SELECT N'Maharashtra', N'Kalmeshwar' UNION ALL
SELECT N'Maharashtra', N'Kalwan' UNION ALL
SELECT N'Maharashtra', N'Kalyan' UNION ALL
SELECT N'Maharashtra', N'Kamptee' UNION ALL
SELECT N'Maharashtra', N'Kandhar' UNION ALL
SELECT N'Maharashtra', N'Kankavali' UNION ALL
SELECT N'Maharashtra', N'Kannad' UNION ALL
SELECT N'Maharashtra', N'Karad' UNION ALL
SELECT N'Maharashtra', N'Karjat' UNION ALL
SELECT N'Maharashtra', N'Karmala' UNION ALL
SELECT N'Maharashtra', N'Katol' UNION ALL
SELECT N'Maharashtra', N'Kavathemankal' UNION ALL
SELECT N'Maharashtra', N'Kedgaon' UNION ALL
SELECT N'Maharashtra', N'Khadakwasala' UNION ALL
SELECT N'Maharashtra', N'Khamgaon' UNION ALL
SELECT N'Maharashtra', N'Khed' UNION ALL
SELECT N'Maharashtra', N'Khopoli' UNION ALL
SELECT N'Maharashtra', N'Khultabad' UNION ALL
SELECT N'Maharashtra', N'Kinwat' UNION ALL
SELECT N'Maharashtra', N'Kolhapur' UNION ALL
SELECT N'Maharashtra', N'Kopargaon' UNION ALL
SELECT N'Maharashtra', N'Koregaon'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Maharashtra', N'Kudal' UNION ALL
SELECT N'Maharashtra', N'Kuhi' UNION ALL
SELECT N'Maharashtra', N'Kurkheda' UNION ALL
SELECT N'Maharashtra', N'Kusumba' UNION ALL
SELECT N'Maharashtra', N'Lakhandur' UNION ALL
SELECT N'Maharashtra', N'Langa' UNION ALL
SELECT N'Maharashtra', N'Latur' UNION ALL
SELECT N'Maharashtra', N'Lonar' UNION ALL
SELECT N'Maharashtra', N'Lonavala' UNION ALL
SELECT N'Maharashtra', N'Madangad' UNION ALL
SELECT N'Maharashtra', N'Madha' UNION ALL
SELECT N'Maharashtra', N'Mahabaleshwar' UNION ALL
SELECT N'Maharashtra', N'Mahad' UNION ALL
SELECT N'Maharashtra', N'Mahagaon' UNION ALL
SELECT N'Maharashtra', N'Mahasala' UNION ALL
SELECT N'Maharashtra', N'Mahaswad' UNION ALL
SELECT N'Maharashtra', N'Malegaon' UNION ALL
SELECT N'Maharashtra', N'Malgaon' UNION ALL
SELECT N'Maharashtra', N'Malgund' UNION ALL
SELECT N'Maharashtra', N'Malkapur' UNION ALL
SELECT N'Maharashtra', N'Malsuras' UNION ALL
SELECT N'Maharashtra', N'Malwan' UNION ALL
SELECT N'Maharashtra', N'Mancher' UNION ALL
SELECT N'Maharashtra', N'Mangalwedha' UNION ALL
SELECT N'Maharashtra', N'Mangaon' UNION ALL
SELECT N'Maharashtra', N'Mangrulpur' UNION ALL
SELECT N'Maharashtra', N'Manjalegaon' UNION ALL
SELECT N'Maharashtra', N'Manmad' UNION ALL
SELECT N'Maharashtra', N'Maregaon' UNION ALL
SELECT N'Maharashtra', N'Mehda' UNION ALL
SELECT N'Maharashtra', N'Mekhar' UNION ALL
SELECT N'Maharashtra', N'Mohadi' UNION ALL
SELECT N'Maharashtra', N'Mohol' UNION ALL
SELECT N'Maharashtra', N'Mokhada' UNION ALL
SELECT N'Maharashtra', N'Morshi' UNION ALL
SELECT N'Maharashtra', N'Mouda' UNION ALL
SELECT N'Maharashtra', N'Mukhed' UNION ALL
SELECT N'Maharashtra', N'Mul' UNION ALL
SELECT N'Maharashtra', N'Mumbai' UNION ALL
SELECT N'Maharashtra', N'Murbad' UNION ALL
SELECT N'Maharashtra', N'Murtizapur' UNION ALL
SELECT N'Maharashtra', N'Murud' UNION ALL
SELECT N'Maharashtra', N'Nagbhir' UNION ALL
SELECT N'Maharashtra', N'Nagpur' UNION ALL
SELECT N'Maharashtra', N'Nahavara' UNION ALL
SELECT N'Maharashtra', N'Nanded' UNION ALL
SELECT N'Maharashtra', N'Nandgaon' UNION ALL
SELECT N'Maharashtra', N'Nandnva' UNION ALL
SELECT N'Maharashtra', N'Nandurbar' UNION ALL
SELECT N'Maharashtra', N'Narkhed'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Maharashtra', N'Nashik' UNION ALL
SELECT N'Maharashtra', N'Navapur' UNION ALL
SELECT N'Maharashtra', N'Ner' UNION ALL
SELECT N'Maharashtra', N'Newasa' UNION ALL
SELECT N'Maharashtra', N'Nilanga' UNION ALL
SELECT N'Maharashtra', N'Niphad' UNION ALL
SELECT N'Maharashtra', N'Omerga' UNION ALL
SELECT N'Maharashtra', N'Osmanabad' UNION ALL
SELECT N'Maharashtra', N'Pachora' UNION ALL
SELECT N'Maharashtra', N'Paithan' UNION ALL
SELECT N'Maharashtra', N'Palghar' UNION ALL
SELECT N'Maharashtra', N'Pali' UNION ALL
SELECT N'Maharashtra', N'Pandharkawada' UNION ALL
SELECT N'Maharashtra', N'Pandharpur' UNION ALL
SELECT N'Maharashtra', N'Panhala' UNION ALL
SELECT N'Maharashtra', N'Paranda' UNION ALL
SELECT N'Maharashtra', N'Parbhani' UNION ALL
SELECT N'Maharashtra', N'Parner' UNION ALL
SELECT N'Maharashtra', N'Parola' UNION ALL
SELECT N'Maharashtra', N'Parseoni' UNION ALL
SELECT N'Maharashtra', N'Partur' UNION ALL
SELECT N'Maharashtra', N'Patan' UNION ALL
SELECT N'Maharashtra', N'Pathardi' UNION ALL
SELECT N'Maharashtra', N'Pathari' UNION ALL
SELECT N'Maharashtra', N'Patoda' UNION ALL
SELECT N'Maharashtra', N'Pauni' UNION ALL
SELECT N'Maharashtra', N'Peint' UNION ALL
SELECT N'Maharashtra', N'Pen' UNION ALL
SELECT N'Maharashtra', N'Phaltan' UNION ALL
SELECT N'Maharashtra', N'Pimpalner' UNION ALL
SELECT N'Maharashtra', N'Pirangut' UNION ALL
SELECT N'Maharashtra', N'Poladpur' UNION ALL
SELECT N'Maharashtra', N'Pune' UNION ALL
SELECT N'Maharashtra', N'Pusad' UNION ALL
SELECT N'Maharashtra', N'Pusegaon' UNION ALL
SELECT N'Maharashtra', N'Radhanagar' UNION ALL
SELECT N'Maharashtra', N'Rahuri' UNION ALL
SELECT N'Maharashtra', N'Raigad' UNION ALL
SELECT N'Maharashtra', N'Rajapur' UNION ALL
SELECT N'Maharashtra', N'Rajgurunagar' UNION ALL
SELECT N'Maharashtra', N'Rajura' UNION ALL
SELECT N'Maharashtra', N'Ralegaon' UNION ALL
SELECT N'Maharashtra', N'Ramtek' UNION ALL
SELECT N'Maharashtra', N'Ratnagiri' UNION ALL
SELECT N'Maharashtra', N'Raver' UNION ALL
SELECT N'Maharashtra', N'Risod' UNION ALL
SELECT N'Maharashtra', N'Roha' UNION ALL
SELECT N'Maharashtra', N'Sakarwadi' UNION ALL
SELECT N'Maharashtra', N'Sakoli' UNION ALL
SELECT N'Maharashtra', N'Sakri'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Maharashtra', N'Salekasa' UNION ALL
SELECT N'Maharashtra', N'Samudrapur' UNION ALL
SELECT N'Maharashtra', N'Sangamner' UNION ALL
SELECT N'Maharashtra', N'Sanganeshwar' UNION ALL
SELECT N'Maharashtra', N'Sangli' UNION ALL
SELECT N'Maharashtra', N'Sangola' UNION ALL
SELECT N'Maharashtra', N'Sanguem' UNION ALL
SELECT N'Maharashtra', N'Saoner' UNION ALL
SELECT N'Maharashtra', N'Saswad' UNION ALL
SELECT N'Maharashtra', N'Satana' UNION ALL
SELECT N'Maharashtra', N'Satara' UNION ALL
SELECT N'Maharashtra', N'Sawantwadi' UNION ALL
SELECT N'Maharashtra', N'Seloo' UNION ALL
SELECT N'Maharashtra', N'Shahada' UNION ALL
SELECT N'Maharashtra', N'Shahapur' UNION ALL
SELECT N'Maharashtra', N'Shahuwadi' UNION ALL
SELECT N'Maharashtra', N'Shevgaon' UNION ALL
SELECT N'Maharashtra', N'Shirala' UNION ALL
SELECT N'Maharashtra', N'Shirol' UNION ALL
SELECT N'Maharashtra', N'Shirpur' UNION ALL
SELECT N'Maharashtra', N'Shirur' UNION ALL
SELECT N'Maharashtra', N'Shirwal' UNION ALL
SELECT N'Maharashtra', N'Sholapur' UNION ALL
SELECT N'Maharashtra', N'Shri Rampur' UNION ALL
SELECT N'Maharashtra', N'Shrigonda' UNION ALL
SELECT N'Maharashtra', N'Shrivardhan' UNION ALL
SELECT N'Maharashtra', N'Sillod' UNION ALL
SELECT N'Maharashtra', N'Sinderwahi' UNION ALL
SELECT N'Maharashtra', N'Sindhudurg' UNION ALL
SELECT N'Maharashtra', N'Sindkheda' UNION ALL
SELECT N'Maharashtra', N'Sindkhedaraja' UNION ALL
SELECT N'Maharashtra', N'Sinnar' UNION ALL
SELECT N'Maharashtra', N'Sironcha' UNION ALL
SELECT N'Maharashtra', N'Soyegaon' UNION ALL
SELECT N'Maharashtra', N'Surgena' UNION ALL
SELECT N'Maharashtra', N'Talasari' UNION ALL
SELECT N'Maharashtra', N'Talegaon S.Ji Pant' UNION ALL
SELECT N'Maharashtra', N'Taloda' UNION ALL
SELECT N'Maharashtra', N'Tasgaon' UNION ALL
SELECT N'Maharashtra', N'Thane' UNION ALL
SELECT N'Maharashtra', N'Tirora' UNION ALL
SELECT N'Maharashtra', N'Tiwasa' UNION ALL
SELECT N'Maharashtra', N'Trimbak' UNION ALL
SELECT N'Maharashtra', N'Tuljapur' UNION ALL
SELECT N'Maharashtra', N'Tumsar' UNION ALL
SELECT N'Maharashtra', N'Udgir' UNION ALL
SELECT N'Maharashtra', N'Umarkhed' UNION ALL
SELECT N'Maharashtra', N'Umrane' UNION ALL
SELECT N'Maharashtra', N'Umrer' UNION ALL
SELECT N'Maharashtra', N'Urlikanchan'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Maharashtra', N'Vaduj' UNION ALL
SELECT N'Maharashtra', N'Velhe' UNION ALL
SELECT N'Maharashtra', N'Vengurla' UNION ALL
SELECT N'Maharashtra', N'Vijapur' UNION ALL
SELECT N'Maharashtra', N'Vita' UNION ALL
SELECT N'Maharashtra', N'Wada' UNION ALL
SELECT N'Maharashtra', N'Wai' UNION ALL
SELECT N'Maharashtra', N'Walchandnagar' UNION ALL
SELECT N'Maharashtra', N'Wani' UNION ALL
SELECT N'Maharashtra', N'Wardha' UNION ALL
SELECT N'Maharashtra', N'Warlydwarud' UNION ALL
SELECT N'Maharashtra', N'Warora' UNION ALL
SELECT N'Maharashtra', N'Washim' UNION ALL
SELECT N'Maharashtra', N'Wathar' UNION ALL
SELECT N'Maharashtra', N'Yavatmal' UNION ALL
SELECT N'Maharashtra', N'Yawal' UNION ALL
SELECT N'Maharashtra', N'Yeola' UNION ALL
SELECT N'Maharashtra', N'Yeotmal' UNION ALL
SELECT N'Manipur', N'Bishnupur' UNION ALL
SELECT N'Manipur', N'Chakpikarong' UNION ALL
SELECT N'Manipur', N'Chandel' UNION ALL
SELECT N'Manipur', N'Chattrik' UNION ALL
SELECT N'Manipur', N'Churachandpur' UNION ALL
SELECT N'Manipur', N'Imphal' UNION ALL
SELECT N'Manipur', N'Jiribam' UNION ALL
SELECT N'Manipur', N'Kakching' UNION ALL
SELECT N'Manipur', N'Kalapahar' UNION ALL
SELECT N'Manipur', N'Mao' UNION ALL
SELECT N'Manipur', N'Mulam' UNION ALL
SELECT N'Manipur', N'Parbung' UNION ALL
SELECT N'Manipur', N'Sadarhills' UNION ALL
SELECT N'Manipur', N'Saibom' UNION ALL
SELECT N'Manipur', N'Sempang' UNION ALL
SELECT N'Manipur', N'Senapati' UNION ALL
SELECT N'Manipur', N'Sochumer' UNION ALL
SELECT N'Manipur', N'Taloulong' UNION ALL
SELECT N'Manipur', N'Tamenglong' UNION ALL
SELECT N'Manipur', N'Thinghat' UNION ALL
SELECT N'Manipur', N'Thoubal' UNION ALL
SELECT N'Manipur', N'Ukhrul' UNION ALL
SELECT N'Meghalaya', N'Amlaren' UNION ALL
SELECT N'Meghalaya', N'Baghmara' UNION ALL
SELECT N'Meghalaya', N'Cherrapunjee' UNION ALL
SELECT N'Meghalaya', N'Dadengiri' UNION ALL
SELECT N'Meghalaya', N'Garo Hills' UNION ALL
SELECT N'Meghalaya', N'Jaintia Hills' UNION ALL
SELECT N'Meghalaya', N'Jowai' UNION ALL
SELECT N'Meghalaya', N'Khasi Hills' UNION ALL
SELECT N'Meghalaya', N'Khliehriat' UNION ALL
SELECT N'Meghalaya', N'Mariang'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Meghalaya', N'Mawkyrwat' UNION ALL
SELECT N'Meghalaya', N'Nongpoh' UNION ALL
SELECT N'Meghalaya', N'Nongstoin' UNION ALL
SELECT N'Meghalaya', N'Resubelpara' UNION ALL
SELECT N'Meghalaya', N'Ri Bhoi' UNION ALL
SELECT N'Meghalaya', N'Shillong' UNION ALL
SELECT N'Meghalaya', N'Tura' UNION ALL
SELECT N'Meghalaya', N'Williamnagar' UNION ALL
SELECT N'Mizoram', N'Aizawl' UNION ALL
SELECT N'Mizoram', N'Champhai' UNION ALL
SELECT N'Mizoram', N'Demagiri' UNION ALL
SELECT N'Mizoram', N'Kolasib' UNION ALL
SELECT N'Mizoram', N'Lawngtlai' UNION ALL
SELECT N'Mizoram', N'Lunglei' UNION ALL
SELECT N'Mizoram', N'Mamit' UNION ALL
SELECT N'Mizoram', N'Saiha' UNION ALL
SELECT N'Mizoram', N'Serchhip' UNION ALL
SELECT N'Nagaland', N'Dimapur' UNION ALL
SELECT N'Nagaland', N'Jalukie' UNION ALL
SELECT N'Nagaland', N'Kiphire' UNION ALL
SELECT N'Nagaland', N'Kohima' UNION ALL
SELECT N'Nagaland', N'Mokokchung' UNION ALL
SELECT N'Nagaland', N'Mon' UNION ALL
SELECT N'Nagaland', N'Phek' UNION ALL
SELECT N'Nagaland', N'Tuensang' UNION ALL
SELECT N'Nagaland', N'Wokha' UNION ALL
SELECT N'Nagaland', N'Zunheboto' UNION ALL
SELECT N'Orissa', N'Anandapur' UNION ALL
SELECT N'Orissa', N'Angul' UNION ALL
SELECT N'Orissa', N'Anugul' UNION ALL
SELECT N'Orissa', N'Aska' UNION ALL
SELECT N'Orissa', N'Athgarh' UNION ALL
SELECT N'Orissa', N'Athmallik' UNION ALL
SELECT N'Orissa', N'Attabira' UNION ALL
SELECT N'Orissa', N'Bagdihi' UNION ALL
SELECT N'Orissa', N'Balangir' UNION ALL
SELECT N'Orissa', N'Balasore' UNION ALL
SELECT N'Orissa', N'Baleswar' UNION ALL
SELECT N'Orissa', N'Baliguda' UNION ALL
SELECT N'Orissa', N'Balugaon' UNION ALL
SELECT N'Orissa', N'Banaigarh' UNION ALL
SELECT N'Orissa', N'Bangiriposi' UNION ALL
SELECT N'Orissa', N'Barbil' UNION ALL
SELECT N'Orissa', N'Bargarh' UNION ALL
SELECT N'Orissa', N'Baripada' UNION ALL
SELECT N'Orissa', N'Barkot' UNION ALL
SELECT N'Orissa', N'Basta' UNION ALL
SELECT N'Orissa', N'Berhampur' UNION ALL
SELECT N'Orissa', N'Betanati' UNION ALL
SELECT N'Orissa', N'Bhadrak'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Orissa', N'Bhanjanagar' UNION ALL
SELECT N'Orissa', N'Bhawanipatna' UNION ALL
SELECT N'Orissa', N'Bhubaneswar' UNION ALL
SELECT N'Orissa', N'Birmaharajpur' UNION ALL
SELECT N'Orissa', N'Bisam Cuttack' UNION ALL
SELECT N'Orissa', N'Boriguma' UNION ALL
SELECT N'Orissa', N'Boudh' UNION ALL
SELECT N'Orissa', N'Buguda' UNION ALL
SELECT N'Orissa', N'Chandbali' UNION ALL
SELECT N'Orissa', N'Chhatrapur' UNION ALL
SELECT N'Orissa', N'Chhendipada' UNION ALL
SELECT N'Orissa', N'Cuttack' UNION ALL
SELECT N'Orissa', N'Daringbadi' UNION ALL
SELECT N'Orissa', N'Daspalla' UNION ALL
SELECT N'Orissa', N'Deodgarh' UNION ALL
SELECT N'Orissa', N'Deogarh' UNION ALL
SELECT N'Orissa', N'Dhanmandal' UNION ALL
SELECT N'Orissa', N'Dharamgarh' UNION ALL
SELECT N'Orissa', N'Dhenkanal' UNION ALL
SELECT N'Orissa', N'Digapahandi' UNION ALL
SELECT N'Orissa', N'Dunguripali' UNION ALL
SELECT N'Orissa', N'G. Udayagiri' UNION ALL
SELECT N'Orissa', N'Gajapati' UNION ALL
SELECT N'Orissa', N'Ganjam' UNION ALL
SELECT N'Orissa', N'Ghatgaon' UNION ALL
SELECT N'Orissa', N'Gudari' UNION ALL
SELECT N'Orissa', N'Gunupur' UNION ALL
SELECT N'Orissa', N'Hemgiri' UNION ALL
SELECT N'Orissa', N'Hindol' UNION ALL
SELECT N'Orissa', N'Jagatsinghapur' UNION ALL
SELECT N'Orissa', N'Jajpur' UNION ALL
SELECT N'Orissa', N'Jamankira' UNION ALL
SELECT N'Orissa', N'Jashipur' UNION ALL
SELECT N'Orissa', N'Jayapatna' UNION ALL
SELECT N'Orissa', N'Jeypur' UNION ALL
SELECT N'Orissa', N'Jharigan' UNION ALL
SELECT N'Orissa', N'Jharsuguda' UNION ALL
SELECT N'Orissa', N'Jujumura' UNION ALL
SELECT N'Orissa', N'Kalahandi' UNION ALL
SELECT N'Orissa', N'Kalimela' UNION ALL
SELECT N'Orissa', N'Kamakhyanagar' UNION ALL
SELECT N'Orissa', N'Kandhamal' UNION ALL
SELECT N'Orissa', N'Kantabhanji' UNION ALL
SELECT N'Orissa', N'Kantamal' UNION ALL
SELECT N'Orissa', N'Karanjia' UNION ALL
SELECT N'Orissa', N'Kashipur' UNION ALL
SELECT N'Orissa', N'Kendrapara' UNION ALL
SELECT N'Orissa', N'Kendujhar' UNION ALL
SELECT N'Orissa', N'Keonjhar' UNION ALL
SELECT N'Orissa', N'Khalikote'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Orissa', N'Khordha' UNION ALL
SELECT N'Orissa', N'Khurda' UNION ALL
SELECT N'Orissa', N'Komana' UNION ALL
SELECT N'Orissa', N'Koraput' UNION ALL
SELECT N'Orissa', N'Kotagarh' UNION ALL
SELECT N'Orissa', N'Kuchinda' UNION ALL
SELECT N'Orissa', N'Lahunipara' UNION ALL
SELECT N'Orissa', N'Laxmipur' UNION ALL
SELECT N'Orissa', N'M. Rampur' UNION ALL
SELECT N'Orissa', N'Malkangiri' UNION ALL
SELECT N'Orissa', N'Mathili' UNION ALL
SELECT N'Orissa', N'Mayurbhanj' UNION ALL
SELECT N'Orissa', N'Mohana' UNION ALL
SELECT N'Orissa', N'Motu' UNION ALL
SELECT N'Orissa', N'Nabarangapur' UNION ALL
SELECT N'Orissa', N'Naktideul' UNION ALL
SELECT N'Orissa', N'Nandapur' UNION ALL
SELECT N'Orissa', N'Narlaroad' UNION ALL
SELECT N'Orissa', N'Narsinghpur' UNION ALL
SELECT N'Orissa', N'Nayagarh' UNION ALL
SELECT N'Orissa', N'Nimapara' UNION ALL
SELECT N'Orissa', N'Nowparatan' UNION ALL
SELECT N'Orissa', N'Nowrangapur' UNION ALL
SELECT N'Orissa', N'Nuapada' UNION ALL
SELECT N'Orissa', N'Padampur' UNION ALL
SELECT N'Orissa', N'Paikamal' UNION ALL
SELECT N'Orissa', N'Palla Hara' UNION ALL
SELECT N'Orissa', N'Papadhandi' UNION ALL
SELECT N'Orissa', N'Parajang' UNION ALL
SELECT N'Orissa', N'Pardip' UNION ALL
SELECT N'Orissa', N'Parlakhemundi' UNION ALL
SELECT N'Orissa', N'Patnagarh' UNION ALL
SELECT N'Orissa', N'Pattamundai' UNION ALL
SELECT N'Orissa', N'Phiringia' UNION ALL
SELECT N'Orissa', N'Phulbani' UNION ALL
SELECT N'Orissa', N'Puri' UNION ALL
SELECT N'Orissa', N'Puruna Katak' UNION ALL
SELECT N'Orissa', N'R. Udayigiri' UNION ALL
SELECT N'Orissa', N'Rairakhol' UNION ALL
SELECT N'Orissa', N'Rairangpur' UNION ALL
SELECT N'Orissa', N'Rajgangpur' UNION ALL
SELECT N'Orissa', N'Rajkhariar' UNION ALL
SELECT N'Orissa', N'Rayagada' UNION ALL
SELECT N'Orissa', N'Rourkela' UNION ALL
SELECT N'Orissa', N'Sambalpur' UNION ALL
SELECT N'Orissa', N'Sohela' UNION ALL
SELECT N'Orissa', N'Sonapur' UNION ALL
SELECT N'Orissa', N'Soro' UNION ALL
SELECT N'Orissa', N'Subarnapur' UNION ALL
SELECT N'Orissa', N'Sunabeda'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Orissa', N'Sundergarh' UNION ALL
SELECT N'Orissa', N'Surada' UNION ALL
SELECT N'Orissa', N'T. Rampur' UNION ALL
SELECT N'Orissa', N'Talcher' UNION ALL
SELECT N'Orissa', N'Telkoi' UNION ALL
SELECT N'Orissa', N'Titlagarh' UNION ALL
SELECT N'Orissa', N'Tumudibandha' UNION ALL
SELECT N'Orissa', N'Udala' UNION ALL
SELECT N'Orissa', N'Umerkote' UNION ALL
SELECT N'Puducherry', N'Bahur' UNION ALL
SELECT N'Puducherry', N'Karaikal' UNION ALL
SELECT N'Puducherry', N'Mahe' UNION ALL
SELECT N'Puducherry', N'Pondicherry' UNION ALL
SELECT N'Puducherry', N'Purnankuppam' UNION ALL
SELECT N'Puducherry', N'Valudavur' UNION ALL
SELECT N'Puducherry', N'Villianur' UNION ALL
SELECT N'Puducherry', N'Yanam' UNION ALL
SELECT N'Punjab', N'Abohar' UNION ALL
SELECT N'Punjab', N'Ajnala' UNION ALL
SELECT N'Punjab', N'Amritsar' UNION ALL
SELECT N'Punjab', N'Balachaur' UNION ALL
SELECT N'Punjab', N'Barnala' UNION ALL
SELECT N'Punjab', N'Batala' UNION ALL
SELECT N'Punjab', N'Bathinda' UNION ALL
SELECT N'Punjab', N'Chandigarh' UNION ALL
SELECT N'Punjab', N'Dasua' UNION ALL
SELECT N'Punjab', N'Dinanagar' UNION ALL
SELECT N'Punjab', N'Faridkot' UNION ALL
SELECT N'Punjab', N'Fatehgarh Sahib' UNION ALL
SELECT N'Punjab', N'Fazilka' UNION ALL
SELECT N'Punjab', N'Ferozepur' UNION ALL
SELECT N'Punjab', N'Garhashanker' UNION ALL
SELECT N'Punjab', N'Goindwal' UNION ALL
SELECT N'Punjab', N'Gurdaspur' UNION ALL
SELECT N'Punjab', N'Guruharsahai' UNION ALL
SELECT N'Punjab', N'Hoshiarpur' UNION ALL
SELECT N'Punjab', N'Jagraon' UNION ALL
SELECT N'Punjab', N'Jalandhar' UNION ALL
SELECT N'Punjab', N'Jugial' UNION ALL
SELECT N'Punjab', N'Kapurthala' UNION ALL
SELECT N'Punjab', N'Kharar' UNION ALL
SELECT N'Punjab', N'Kotkapura' UNION ALL
SELECT N'Punjab', N'Ludhiana' UNION ALL
SELECT N'Punjab', N'Malaut' UNION ALL
SELECT N'Punjab', N'Malerkotla' UNION ALL
SELECT N'Punjab', N'Mansa' UNION ALL
SELECT N'Punjab', N'Moga' UNION ALL
SELECT N'Punjab', N'Muktasar' UNION ALL
SELECT N'Punjab', N'Nabha' UNION ALL
SELECT N'Punjab', N'Nakodar'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Punjab', N'Nangal' UNION ALL
SELECT N'Punjab', N'Nawanshahar' UNION ALL
SELECT N'Punjab', N'Nawanshahr' UNION ALL
SELECT N'Punjab', N'Pathankot' UNION ALL
SELECT N'Punjab', N'Patiala' UNION ALL
SELECT N'Punjab', N'Patti' UNION ALL
SELECT N'Punjab', N'Phagwara' UNION ALL
SELECT N'Punjab', N'Phillaur' UNION ALL
SELECT N'Punjab', N'Phulmandi' UNION ALL
SELECT N'Punjab', N'Quadian' UNION ALL
SELECT N'Punjab', N'Rajpura' UNION ALL
SELECT N'Punjab', N'Raman' UNION ALL
SELECT N'Punjab', N'Rayya' UNION ALL
SELECT N'Punjab', N'Ropar' UNION ALL
SELECT N'Punjab', N'Rupnagar' UNION ALL
SELECT N'Punjab', N'Samana' UNION ALL
SELECT N'Punjab', N'Samrala' UNION ALL
SELECT N'Punjab', N'Sangrur' UNION ALL
SELECT N'Punjab', N'Sardulgarh' UNION ALL
SELECT N'Punjab', N'Sarhind' UNION ALL
SELECT N'Punjab', N'SAS Nagar' UNION ALL
SELECT N'Punjab', N'Sultanpur Lodhi' UNION ALL
SELECT N'Punjab', N'Sunam' UNION ALL
SELECT N'Punjab', N'Tanda Urmar' UNION ALL
SELECT N'Punjab', N'Taran Taran' UNION ALL
SELECT N'Punjab', N'Zira' UNION ALL
SELECT N'Rajasthan', N'Abu Road' UNION ALL
SELECT N'Rajasthan', N'Ahore' UNION ALL
SELECT N'Rajasthan', N'Ajmer' UNION ALL
SELECT N'Rajasthan', N'Aklera' UNION ALL
SELECT N'Rajasthan', N'Alwar' UNION ALL
SELECT N'Rajasthan', N'Amber' UNION ALL
SELECT N'Rajasthan', N'Amet' UNION ALL
SELECT N'Rajasthan', N'Anupgarh' UNION ALL
SELECT N'Rajasthan', N'Asind' UNION ALL
SELECT N'Rajasthan', N'Aspur' UNION ALL
SELECT N'Rajasthan', N'Atru' UNION ALL
SELECT N'Rajasthan', N'Bagidora' UNION ALL
SELECT N'Rajasthan', N'Bali' UNION ALL
SELECT N'Rajasthan', N'Bamanwas' UNION ALL
SELECT N'Rajasthan', N'Banera' UNION ALL
SELECT N'Rajasthan', N'Bansur' UNION ALL
SELECT N'Rajasthan', N'Banswara' UNION ALL
SELECT N'Rajasthan', N'Baran' UNION ALL
SELECT N'Rajasthan', N'Bari' UNION ALL
SELECT N'Rajasthan', N'Barisadri' UNION ALL
SELECT N'Rajasthan', N'Barmer' UNION ALL
SELECT N'Rajasthan', N'Baseri' UNION ALL
SELECT N'Rajasthan', N'Bassi' UNION ALL
SELECT N'Rajasthan', N'Baswa'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Rajasthan', N'Bayana' UNION ALL
SELECT N'Rajasthan', N'Beawar' UNION ALL
SELECT N'Rajasthan', N'Begun' UNION ALL
SELECT N'Rajasthan', N'Behror' UNION ALL
SELECT N'Rajasthan', N'Bhadra' UNION ALL
SELECT N'Rajasthan', N'Bharatpur' UNION ALL
SELECT N'Rajasthan', N'Bhilwara' UNION ALL
SELECT N'Rajasthan', N'Bhim' UNION ALL
SELECT N'Rajasthan', N'Bhinmal' UNION ALL
SELECT N'Rajasthan', N'Bikaner' UNION ALL
SELECT N'Rajasthan', N'Bilara' UNION ALL
SELECT N'Rajasthan', N'Bundi' UNION ALL
SELECT N'Rajasthan', N'Chhabra' UNION ALL
SELECT N'Rajasthan', N'Chhipaborad' UNION ALL
SELECT N'Rajasthan', N'Chirawa' UNION ALL
SELECT N'Rajasthan', N'Chittorgarh' UNION ALL
SELECT N'Rajasthan', N'Chohtan' UNION ALL
SELECT N'Rajasthan', N'Churu' UNION ALL
SELECT N'Rajasthan', N'Dantaramgarh' UNION ALL
SELECT N'Rajasthan', N'Dausa' UNION ALL
SELECT N'Rajasthan', N'Deedwana' UNION ALL
SELECT N'Rajasthan', N'Deeg' UNION ALL
SELECT N'Rajasthan', N'Degana' UNION ALL
SELECT N'Rajasthan', N'Deogarh' UNION ALL
SELECT N'Rajasthan', N'Deoli' UNION ALL
SELECT N'Rajasthan', N'Desuri' UNION ALL
SELECT N'Rajasthan', N'Dhariawad' UNION ALL
SELECT N'Rajasthan', N'Dholpur' UNION ALL
SELECT N'Rajasthan', N'Digod' UNION ALL
SELECT N'Rajasthan', N'Dudu' UNION ALL
SELECT N'Rajasthan', N'Dungarpur' UNION ALL
SELECT N'Rajasthan', N'Dungla' UNION ALL
SELECT N'Rajasthan', N'Fatehpur' UNION ALL
SELECT N'Rajasthan', N'Gangapur' UNION ALL
SELECT N'Rajasthan', N'Gangdhar' UNION ALL
SELECT N'Rajasthan', N'Gerhi' UNION ALL
SELECT N'Rajasthan', N'Ghatol' UNION ALL
SELECT N'Rajasthan', N'Girwa' UNION ALL
SELECT N'Rajasthan', N'Gogunda' UNION ALL
SELECT N'Rajasthan', N'Hanumangarh' UNION ALL
SELECT N'Rajasthan', N'Hindaun' UNION ALL
SELECT N'Rajasthan', N'Hindoli' UNION ALL
SELECT N'Rajasthan', N'Hurda' UNION ALL
SELECT N'Rajasthan', N'Jahazpur' UNION ALL
SELECT N'Rajasthan', N'Jaipur' UNION ALL
SELECT N'Rajasthan', N'Jaisalmer' UNION ALL
SELECT N'Rajasthan', N'Jalore' UNION ALL
SELECT N'Rajasthan', N'Jhalawar' UNION ALL
SELECT N'Rajasthan', N'Jhunjhunu' UNION ALL
SELECT N'Rajasthan', N'Jodhpur'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Rajasthan', N'Kaman' UNION ALL
SELECT N'Rajasthan', N'Kapasan' UNION ALL
SELECT N'Rajasthan', N'Karauli' UNION ALL
SELECT N'Rajasthan', N'Kekri' UNION ALL
SELECT N'Rajasthan', N'Keshoraipatan' UNION ALL
SELECT N'Rajasthan', N'Khandar' UNION ALL
SELECT N'Rajasthan', N'Kherwara' UNION ALL
SELECT N'Rajasthan', N'Khetri' UNION ALL
SELECT N'Rajasthan', N'Kishanganj' UNION ALL
SELECT N'Rajasthan', N'Kishangarh' UNION ALL
SELECT N'Rajasthan', N'Kishangarhbas' UNION ALL
SELECT N'Rajasthan', N'Kolayat' UNION ALL
SELECT N'Rajasthan', N'Kota' UNION ALL
SELECT N'Rajasthan', N'Kotputli' UNION ALL
SELECT N'Rajasthan', N'Kotra' UNION ALL
SELECT N'Rajasthan', N'Kotri' UNION ALL
SELECT N'Rajasthan', N'Kumbalgarh' UNION ALL
SELECT N'Rajasthan', N'Kushalgarh' UNION ALL
SELECT N'Rajasthan', N'Ladnun' UNION ALL
SELECT N'Rajasthan', N'Ladpura' UNION ALL
SELECT N'Rajasthan', N'Lalsot' UNION ALL
SELECT N'Rajasthan', N'Laxmangarh' UNION ALL
SELECT N'Rajasthan', N'Lunkaransar' UNION ALL
SELECT N'Rajasthan', N'Mahuwa' UNION ALL
SELECT N'Rajasthan', N'Malpura' UNION ALL
SELECT N'Rajasthan', N'Malvi' UNION ALL
SELECT N'Rajasthan', N'Mandal' UNION ALL
SELECT N'Rajasthan', N'Mandalgarh' UNION ALL
SELECT N'Rajasthan', N'Mandawar' UNION ALL
SELECT N'Rajasthan', N'Mangrol' UNION ALL
SELECT N'Rajasthan', N'Marwar-Jn' UNION ALL
SELECT N'Rajasthan', N'Merta' UNION ALL
SELECT N'Rajasthan', N'Nadbai' UNION ALL
SELECT N'Rajasthan', N'Nagaur' UNION ALL
SELECT N'Rajasthan', N'Nainwa' UNION ALL
SELECT N'Rajasthan', N'Nasirabad' UNION ALL
SELECT N'Rajasthan', N'Nathdwara' UNION ALL
SELECT N'Rajasthan', N'Nawa' UNION ALL
SELECT N'Rajasthan', N'Neem Ka Thana' UNION ALL
SELECT N'Rajasthan', N'Newai' UNION ALL
SELECT N'Rajasthan', N'Nimbahera' UNION ALL
SELECT N'Rajasthan', N'Nohar' UNION ALL
SELECT N'Rajasthan', N'Nokha' UNION ALL
SELECT N'Rajasthan', N'Onli' UNION ALL
SELECT N'Rajasthan', N'Osian' UNION ALL
SELECT N'Rajasthan', N'Pachpadara' UNION ALL
SELECT N'Rajasthan', N'Pachpahar' UNION ALL
SELECT N'Rajasthan', N'Padampur' UNION ALL
SELECT N'Rajasthan', N'Pali' UNION ALL
SELECT N'Rajasthan', N'Parbatsar'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Rajasthan', N'Phagi' UNION ALL
SELECT N'Rajasthan', N'Phalodi' UNION ALL
SELECT N'Rajasthan', N'Pilani' UNION ALL
SELECT N'Rajasthan', N'Pindwara' UNION ALL
SELECT N'Rajasthan', N'Pipalda' UNION ALL
SELECT N'Rajasthan', N'Pirawa' UNION ALL
SELECT N'Rajasthan', N'Pokaran' UNION ALL
SELECT N'Rajasthan', N'Pratapgarh' UNION ALL
SELECT N'Rajasthan', N'Raipur' UNION ALL
SELECT N'Rajasthan', N'Raisinghnagar' UNION ALL
SELECT N'Rajasthan', N'Rajgarh' UNION ALL
SELECT N'Rajasthan', N'Rajsamand' UNION ALL
SELECT N'Rajasthan', N'Ramganj Mandi' UNION ALL
SELECT N'Rajasthan', N'Ramgarh' UNION ALL
SELECT N'Rajasthan', N'Rashmi' UNION ALL
SELECT N'Rajasthan', N'Ratangarh' UNION ALL
SELECT N'Rajasthan', N'Reodar' UNION ALL
SELECT N'Rajasthan', N'Rupbas' UNION ALL
SELECT N'Rajasthan', N'Sadulshahar' UNION ALL
SELECT N'Rajasthan', N'Sagwara' UNION ALL
SELECT N'Rajasthan', N'Sahabad' UNION ALL
SELECT N'Rajasthan', N'Salumber' UNION ALL
SELECT N'Rajasthan', N'Sanchore' UNION ALL
SELECT N'Rajasthan', N'Sangaria' UNION ALL
SELECT N'Rajasthan', N'Sangod' UNION ALL
SELECT N'Rajasthan', N'Sapotra' UNION ALL
SELECT N'Rajasthan', N'Sarada' UNION ALL
SELECT N'Rajasthan', N'Sardarshahar' UNION ALL
SELECT N'Rajasthan', N'Sarwar' UNION ALL
SELECT N'Rajasthan', N'Sawai Madhopur' UNION ALL
SELECT N'Rajasthan', N'Shahapura' UNION ALL
SELECT N'Rajasthan', N'Sheo' UNION ALL
SELECT N'Rajasthan', N'Sheoganj' UNION ALL
SELECT N'Rajasthan', N'Shergarh' UNION ALL
SELECT N'Rajasthan', N'Sikar' UNION ALL
SELECT N'Rajasthan', N'Sirohi' UNION ALL
SELECT N'Rajasthan', N'Siwana' UNION ALL
SELECT N'Rajasthan', N'Sojat' UNION ALL
SELECT N'Rajasthan', N'Sri Dungargarh' UNION ALL
SELECT N'Rajasthan', N'Sri Ganganagar' UNION ALL
SELECT N'Rajasthan', N'Sri Karanpur' UNION ALL
SELECT N'Rajasthan', N'Sri Madhopur' UNION ALL
SELECT N'Rajasthan', N'Sujangarh' UNION ALL
SELECT N'Rajasthan', N'Taranagar' UNION ALL
SELECT N'Rajasthan', N'Thanaghazi' UNION ALL
SELECT N'Rajasthan', N'Tibbi' UNION ALL
SELECT N'Rajasthan', N'Tijara' UNION ALL
SELECT N'Rajasthan', N'Todaraisingh' UNION ALL
SELECT N'Rajasthan', N'Tonk' UNION ALL
SELECT N'Rajasthan', N'Udaipur'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Rajasthan', N'Udaipurwati' UNION ALL
SELECT N'Rajasthan', N'Uniayara' UNION ALL
SELECT N'Rajasthan', N'Vallabhnagar' UNION ALL
SELECT N'Rajasthan', N'Viratnagar' UNION ALL
SELECT N'Sikkim', N'Barmiak' UNION ALL
SELECT N'Sikkim', N'Be' UNION ALL
SELECT N'Sikkim', N'Bhurtuk' UNION ALL
SELECT N'Sikkim', N'Chhubakha' UNION ALL
SELECT N'Sikkim', N'Chidam' UNION ALL
SELECT N'Sikkim', N'Chubha' UNION ALL
SELECT N'Sikkim', N'Chumikteng' UNION ALL
SELECT N'Sikkim', N'Dentam' UNION ALL
SELECT N'Sikkim', N'Dikchu' UNION ALL
SELECT N'Sikkim', N'Dzongri' UNION ALL
SELECT N'Sikkim', N'Gangtok' UNION ALL
SELECT N'Sikkim', N'Gauzing' UNION ALL
SELECT N'Sikkim', N'Gyalshing' UNION ALL
SELECT N'Sikkim', N'Hema' UNION ALL
SELECT N'Sikkim', N'Kerung' UNION ALL
SELECT N'Sikkim', N'Lachen' UNION ALL
SELECT N'Sikkim', N'Lachung' UNION ALL
SELECT N'Sikkim', N'Lema' UNION ALL
SELECT N'Sikkim', N'Lingtam' UNION ALL
SELECT N'Sikkim', N'Lungthu' UNION ALL
SELECT N'Sikkim', N'Mangan' UNION ALL
SELECT N'Sikkim', N'Namchi' UNION ALL
SELECT N'Sikkim', N'Namthang' UNION ALL
SELECT N'Sikkim', N'Nanga' UNION ALL
SELECT N'Sikkim', N'Nantang' UNION ALL
SELECT N'Sikkim', N'Naya Bazar' UNION ALL
SELECT N'Sikkim', N'Padamachen' UNION ALL
SELECT N'Sikkim', N'Pakhyong' UNION ALL
SELECT N'Sikkim', N'Pemayangtse' UNION ALL
SELECT N'Sikkim', N'Phensang' UNION ALL
SELECT N'Sikkim', N'Rangli' UNION ALL
SELECT N'Sikkim', N'Rinchingpong' UNION ALL
SELECT N'Sikkim', N'Sakyong' UNION ALL
SELECT N'Sikkim', N'Samdong' UNION ALL
SELECT N'Sikkim', N'Singtam' UNION ALL
SELECT N'Sikkim', N'Singtam' UNION ALL
SELECT N'Sikkim', N'Siniolchu' UNION ALL
SELECT N'Sikkim', N'Sombari' UNION ALL
SELECT N'Sikkim', N'Soreng' UNION ALL
SELECT N'Sikkim', N'Sosing' UNION ALL
SELECT N'Sikkim', N'Tekhug' UNION ALL
SELECT N'Sikkim', N'Temi' UNION ALL
SELECT N'Sikkim', N'Tsetang' UNION ALL
SELECT N'Sikkim', N'Tsomgo' UNION ALL
SELECT N'Sikkim', N'Tumlong' UNION ALL
SELECT N'Sikkim', N'Yangang'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Sikkim', N'Yumtang' UNION ALL
SELECT N'Tamil Nadu', N'Ambasamudram' UNION ALL
SELECT N'Tamil Nadu', N'Anamali' UNION ALL
SELECT N'Tamil Nadu', N'Arakandanallur' UNION ALL
SELECT N'Tamil Nadu', N'Arantangi' UNION ALL
SELECT N'Tamil Nadu', N'Aravakurichi' UNION ALL
SELECT N'Tamil Nadu', N'Ariyalur' UNION ALL
SELECT N'Tamil Nadu', N'Arkonam' UNION ALL
SELECT N'Tamil Nadu', N'Arni' UNION ALL
SELECT N'Tamil Nadu', N'Aruppukottai' UNION ALL
SELECT N'Tamil Nadu', N'Attur' UNION ALL
SELECT N'Tamil Nadu', N'Avanashi' UNION ALL
SELECT N'Tamil Nadu', N'Batlagundu' UNION ALL
SELECT N'Tamil Nadu', N'Bhavani' UNION ALL
SELECT N'Tamil Nadu', N'Chengalpattu' UNION ALL
SELECT N'Tamil Nadu', N'Chengam' UNION ALL
SELECT N'Tamil Nadu', N'Chennai' UNION ALL
SELECT N'Tamil Nadu', N'Chidambaram' UNION ALL
SELECT N'Tamil Nadu', N'Chingleput' UNION ALL
SELECT N'Tamil Nadu', N'Coimbatore' UNION ALL
SELECT N'Tamil Nadu', N'Courtallam' UNION ALL
SELECT N'Tamil Nadu', N'Cuddalore' UNION ALL
SELECT N'Tamil Nadu', N'Cumbum' UNION ALL
SELECT N'Tamil Nadu', N'Denkanikoitah' UNION ALL
SELECT N'Tamil Nadu', N'Devakottai' UNION ALL
SELECT N'Tamil Nadu', N'Dharampuram' UNION ALL
SELECT N'Tamil Nadu', N'Dharmapuri' UNION ALL
SELECT N'Tamil Nadu', N'Dindigul' UNION ALL
SELECT N'Tamil Nadu', N'Erode' UNION ALL
SELECT N'Tamil Nadu', N'Gingee' UNION ALL
SELECT N'Tamil Nadu', N'Gobichettipalayam' UNION ALL
SELECT N'Tamil Nadu', N'Gudalur' UNION ALL
SELECT N'Tamil Nadu', N'Gudiyatham' UNION ALL
SELECT N'Tamil Nadu', N'Harur' UNION ALL
SELECT N'Tamil Nadu', N'Hosur' UNION ALL
SELECT N'Tamil Nadu', N'Jayamkondan' UNION ALL
SELECT N'Tamil Nadu', N'Kallkurichi' UNION ALL
SELECT N'Tamil Nadu', N'Kanchipuram' UNION ALL
SELECT N'Tamil Nadu', N'Kangayam' UNION ALL
SELECT N'Tamil Nadu', N'Kanyakumari' UNION ALL
SELECT N'Tamil Nadu', N'Karaikal' UNION ALL
SELECT N'Tamil Nadu', N'Karaikudi' UNION ALL
SELECT N'Tamil Nadu', N'Karur' UNION ALL
SELECT N'Tamil Nadu', N'Keeranur' UNION ALL
SELECT N'Tamil Nadu', N'Kodaikanal' UNION ALL
SELECT N'Tamil Nadu', N'Kodumudi' UNION ALL
SELECT N'Tamil Nadu', N'Kotagiri' UNION ALL
SELECT N'Tamil Nadu', N'Kovilpatti' UNION ALL
SELECT N'Tamil Nadu', N'Krishnagiri' UNION ALL
SELECT N'Tamil Nadu', N'Kulithalai'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Tamil Nadu', N'Kumbakonam' UNION ALL
SELECT N'Tamil Nadu', N'Kuzhithurai' UNION ALL
SELECT N'Tamil Nadu', N'Madurai' UNION ALL
SELECT N'Tamil Nadu', N'Madurantgam' UNION ALL
SELECT N'Tamil Nadu', N'Manamadurai' UNION ALL
SELECT N'Tamil Nadu', N'Manaparai' UNION ALL
SELECT N'Tamil Nadu', N'Mannargudi' UNION ALL
SELECT N'Tamil Nadu', N'Mayiladuthurai' UNION ALL
SELECT N'Tamil Nadu', N'Mayiladutjurai' UNION ALL
SELECT N'Tamil Nadu', N'Mettupalayam' UNION ALL
SELECT N'Tamil Nadu', N'Metturdam' UNION ALL
SELECT N'Tamil Nadu', N'Mudukulathur' UNION ALL
SELECT N'Tamil Nadu', N'Mulanur' UNION ALL
SELECT N'Tamil Nadu', N'Musiri' UNION ALL
SELECT N'Tamil Nadu', N'Nagapattinam' UNION ALL
SELECT N'Tamil Nadu', N'Nagarcoil' UNION ALL
SELECT N'Tamil Nadu', N'Namakkal' UNION ALL
SELECT N'Tamil Nadu', N'Nanguneri' UNION ALL
SELECT N'Tamil Nadu', N'Natham' UNION ALL
SELECT N'Tamil Nadu', N'Neyveli' UNION ALL
SELECT N'Tamil Nadu', N'Nilgiris' UNION ALL
SELECT N'Tamil Nadu', N'Oddanchatram' UNION ALL
SELECT N'Tamil Nadu', N'Omalpur' UNION ALL
SELECT N'Tamil Nadu', N'Ootacamund' UNION ALL
SELECT N'Tamil Nadu', N'Ooty' UNION ALL
SELECT N'Tamil Nadu', N'Orathanad' UNION ALL
SELECT N'Tamil Nadu', N'Palacode' UNION ALL
SELECT N'Tamil Nadu', N'Palani' UNION ALL
SELECT N'Tamil Nadu', N'Palladum' UNION ALL
SELECT N'Tamil Nadu', N'Papanasam' UNION ALL
SELECT N'Tamil Nadu', N'Paramakudi' UNION ALL
SELECT N'Tamil Nadu', N'Pattukottai' UNION ALL
SELECT N'Tamil Nadu', N'Perambalur' UNION ALL
SELECT N'Tamil Nadu', N'Perundurai' UNION ALL
SELECT N'Tamil Nadu', N'Pollachi' UNION ALL
SELECT N'Tamil Nadu', N'Polur' UNION ALL
SELECT N'Tamil Nadu', N'Pondicherry' UNION ALL
SELECT N'Tamil Nadu', N'Ponnamaravathi' UNION ALL
SELECT N'Tamil Nadu', N'Ponneri' UNION ALL
SELECT N'Tamil Nadu', N'Pudukkottai' UNION ALL
SELECT N'Tamil Nadu', N'Rajapalayam' UNION ALL
SELECT N'Tamil Nadu', N'Ramanathapuram' UNION ALL
SELECT N'Tamil Nadu', N'Rameshwaram' UNION ALL
SELECT N'Tamil Nadu', N'Ranipet' UNION ALL
SELECT N'Tamil Nadu', N'Rasipuram' UNION ALL
SELECT N'Tamil Nadu', N'Salem' UNION ALL
SELECT N'Tamil Nadu', N'Sankagiri' UNION ALL
SELECT N'Tamil Nadu', N'Sankaran' UNION ALL
SELECT N'Tamil Nadu', N'Sathiyamangalam' UNION ALL
SELECT N'Tamil Nadu', N'Sivaganga'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Tamil Nadu', N'Sivakasi' UNION ALL
SELECT N'Tamil Nadu', N'Sriperumpudur' UNION ALL
SELECT N'Tamil Nadu', N'Srivaikundam' UNION ALL
SELECT N'Tamil Nadu', N'Tenkasi' UNION ALL
SELECT N'Tamil Nadu', N'Thanjavur' UNION ALL
SELECT N'Tamil Nadu', N'Theni' UNION ALL
SELECT N'Tamil Nadu', N'Thirumanglam' UNION ALL
SELECT N'Tamil Nadu', N'Thiruraipoondi' UNION ALL
SELECT N'Tamil Nadu', N'Thoothukudi' UNION ALL
SELECT N'Tamil Nadu', N'Thuraiyure' UNION ALL
SELECT N'Tamil Nadu', N'Tindivanam' UNION ALL
SELECT N'Tamil Nadu', N'Tiruchendur' UNION ALL
SELECT N'Tamil Nadu', N'Tiruchengode' UNION ALL
SELECT N'Tamil Nadu', N'Tiruchirappalli' UNION ALL
SELECT N'Tamil Nadu', N'Tirunelvelli' UNION ALL
SELECT N'Tamil Nadu', N'Tirupathur' UNION ALL
SELECT N'Tamil Nadu', N'Tirupur' UNION ALL
SELECT N'Tamil Nadu', N'Tiruttani' UNION ALL
SELECT N'Tamil Nadu', N'Tiruvallur' UNION ALL
SELECT N'Tamil Nadu', N'Tiruvannamalai' UNION ALL
SELECT N'Tamil Nadu', N'Tiruvarur' UNION ALL
SELECT N'Tamil Nadu', N'Tiruvellore' UNION ALL
SELECT N'Tamil Nadu', N'Tiruvettipuram' UNION ALL
SELECT N'Tamil Nadu', N'Trichy' UNION ALL
SELECT N'Tamil Nadu', N'Tuticorin' UNION ALL
SELECT N'Tamil Nadu', N'Udumalpet' UNION ALL
SELECT N'Tamil Nadu', N'Ulundurpet' UNION ALL
SELECT N'Tamil Nadu', N'Usiliampatti' UNION ALL
SELECT N'Tamil Nadu', N'Uthangarai' UNION ALL
SELECT N'Tamil Nadu', N'Valapady' UNION ALL
SELECT N'Tamil Nadu', N'Valliyoor' UNION ALL
SELECT N'Tamil Nadu', N'Vaniyambadi' UNION ALL
SELECT N'Tamil Nadu', N'Vedasandur' UNION ALL
SELECT N'Tamil Nadu', N'Vellore' UNION ALL
SELECT N'Tamil Nadu', N'Velur' UNION ALL
SELECT N'Tamil Nadu', N'Vilathikulam' UNION ALL
SELECT N'Tamil Nadu', N'Villupuram' UNION ALL
SELECT N'Tamil Nadu', N'Virudhachalam' UNION ALL
SELECT N'Tamil Nadu', N'Virudhunagar' UNION ALL
SELECT N'Tamil Nadu', N'Wandiwash' UNION ALL
SELECT N'Tamil Nadu', N'Yercaud' UNION ALL
SELECT N'Tripura', N'Agartala' UNION ALL
SELECT N'Tripura', N'Ambasa' UNION ALL
SELECT N'Tripura', N'Bampurbari' UNION ALL
SELECT N'Tripura', N'Belonia' UNION ALL
SELECT N'Tripura', N'Dhalai' UNION ALL
SELECT N'Tripura', N'Dharam Nagar' UNION ALL
SELECT N'Tripura', N'Kailashahar' UNION ALL
SELECT N'Tripura', N'Kamal Krishnabari' UNION ALL
SELECT N'Tripura', N'Khopaiyapara'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Tripura', N'Khowai' UNION ALL
SELECT N'Tripura', N'Phuldungsei' UNION ALL
SELECT N'Tripura', N'Radha Kishore Pur' UNION ALL
SELECT N'Tripura', N'Tripura' UNION ALL
SELECT N'Uttar Pradesh', N'Achhnera' UNION ALL
SELECT N'Uttar Pradesh', N'Agra' UNION ALL
SELECT N'Uttar Pradesh', N'Akbarpur' UNION ALL
SELECT N'Uttar Pradesh', N'Aliganj' UNION ALL
SELECT N'Uttar Pradesh', N'Aligarh' UNION ALL
SELECT N'Uttar Pradesh', N'Allahabad' UNION ALL
SELECT N'Uttar Pradesh', N'Ambedkar Nagar' UNION ALL
SELECT N'Uttar Pradesh', N'Amethi' UNION ALL
SELECT N'Uttar Pradesh', N'Amiliya' UNION ALL
SELECT N'Uttar Pradesh', N'Amroha' UNION ALL
SELECT N'Uttar Pradesh', N'Anola' UNION ALL
SELECT N'Uttar Pradesh', N'Atrauli' UNION ALL
SELECT N'Uttar Pradesh', N'Auraiya' UNION ALL
SELECT N'Uttar Pradesh', N'Azamgarh' UNION ALL
SELECT N'Uttar Pradesh', N'Baberu' UNION ALL
SELECT N'Uttar Pradesh', N'Badaun' UNION ALL
SELECT N'Uttar Pradesh', N'Baghpat' UNION ALL
SELECT N'Uttar Pradesh', N'Bagpat' UNION ALL
SELECT N'Uttar Pradesh', N'Baheri' UNION ALL
SELECT N'Uttar Pradesh', N'Bahraich' UNION ALL
SELECT N'Uttar Pradesh', N'Ballia' UNION ALL
SELECT N'Uttar Pradesh', N'Balrampur' UNION ALL
SELECT N'Uttar Pradesh', N'Banda' UNION ALL
SELECT N'Uttar Pradesh', N'Bansdeeh' UNION ALL
SELECT N'Uttar Pradesh', N'Bansgaon' UNION ALL
SELECT N'Uttar Pradesh', N'Bansi' UNION ALL
SELECT N'Uttar Pradesh', N'Barabanki' UNION ALL
SELECT N'Uttar Pradesh', N'Bareilly' UNION ALL
SELECT N'Uttar Pradesh', N'Basti' UNION ALL
SELECT N'Uttar Pradesh', N'Bhadohi' UNION ALL
SELECT N'Uttar Pradesh', N'Bharthana' UNION ALL
SELECT N'Uttar Pradesh', N'Bharwari' UNION ALL
SELECT N'Uttar Pradesh', N'Bhogaon' UNION ALL
SELECT N'Uttar Pradesh', N'Bhognipur' UNION ALL
SELECT N'Uttar Pradesh', N'Bidhuna' UNION ALL
SELECT N'Uttar Pradesh', N'Bijnore' UNION ALL
SELECT N'Uttar Pradesh', N'Bikapur' UNION ALL
SELECT N'Uttar Pradesh', N'Bilari' UNION ALL
SELECT N'Uttar Pradesh', N'Bilgram' UNION ALL
SELECT N'Uttar Pradesh', N'Bilhaur' UNION ALL
SELECT N'Uttar Pradesh', N'Bindki' UNION ALL
SELECT N'Uttar Pradesh', N'Bisalpur' UNION ALL
SELECT N'Uttar Pradesh', N'Bisauli' UNION ALL
SELECT N'Uttar Pradesh', N'Biswan' UNION ALL
SELECT N'Uttar Pradesh', N'Budaun' UNION ALL
SELECT N'Uttar Pradesh', N'Budhana'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Uttar Pradesh', N'Bulandshahar' UNION ALL
SELECT N'Uttar Pradesh', N'Bulandshahr' UNION ALL
SELECT N'Uttar Pradesh', N'Capianganj' UNION ALL
SELECT N'Uttar Pradesh', N'Chakia' UNION ALL
SELECT N'Uttar Pradesh', N'Chandauli' UNION ALL
SELECT N'Uttar Pradesh', N'Charkhari' UNION ALL
SELECT N'Uttar Pradesh', N'Chhata' UNION ALL
SELECT N'Uttar Pradesh', N'Chhibramau' UNION ALL
SELECT N'Uttar Pradesh', N'Chirgaon' UNION ALL
SELECT N'Uttar Pradesh', N'Chitrakoot' UNION ALL
SELECT N'Uttar Pradesh', N'Chunur' UNION ALL
SELECT N'Uttar Pradesh', N'Dadri' UNION ALL
SELECT N'Uttar Pradesh', N'Dalmau' UNION ALL
SELECT N'Uttar Pradesh', N'Dataganj' UNION ALL
SELECT N'Uttar Pradesh', N'Debai' UNION ALL
SELECT N'Uttar Pradesh', N'Deoband' UNION ALL
SELECT N'Uttar Pradesh', N'Deoria' UNION ALL
SELECT N'Uttar Pradesh', N'Derapur' UNION ALL
SELECT N'Uttar Pradesh', N'Dhampur' UNION ALL
SELECT N'Uttar Pradesh', N'Domariyaganj' UNION ALL
SELECT N'Uttar Pradesh', N'Dudhi' UNION ALL
SELECT N'Uttar Pradesh', N'Etah' UNION ALL
SELECT N'Uttar Pradesh', N'Etawah' UNION ALL
SELECT N'Uttar Pradesh', N'Faizabad' UNION ALL
SELECT N'Uttar Pradesh', N'Farrukhabad' UNION ALL
SELECT N'Uttar Pradesh', N'Fatehpur' UNION ALL
SELECT N'Uttar Pradesh', N'Firozabad' UNION ALL
SELECT N'Uttar Pradesh', N'Garauth' UNION ALL
SELECT N'Uttar Pradesh', N'Garhmukteshwar' UNION ALL
SELECT N'Uttar Pradesh', N'Gautam Buddha Nagar' UNION ALL
SELECT N'Uttar Pradesh', N'Ghatampur' UNION ALL
SELECT N'Uttar Pradesh', N'Ghaziabad' UNION ALL
SELECT N'Uttar Pradesh', N'Ghazipur' UNION ALL
SELECT N'Uttar Pradesh', N'Ghosi' UNION ALL
SELECT N'Uttar Pradesh', N'Gonda' UNION ALL
SELECT N'Uttar Pradesh', N'Gorakhpur' UNION ALL
SELECT N'Uttar Pradesh', N'Gunnaur' UNION ALL
SELECT N'Uttar Pradesh', N'Haidergarh' UNION ALL
SELECT N'Uttar Pradesh', N'Hamirpur' UNION ALL
SELECT N'Uttar Pradesh', N'Hapur' UNION ALL
SELECT N'Uttar Pradesh', N'Hardoi' UNION ALL
SELECT N'Uttar Pradesh', N'Harraiya' UNION ALL
SELECT N'Uttar Pradesh', N'Hasanganj' UNION ALL
SELECT N'Uttar Pradesh', N'Hasanpur' UNION ALL
SELECT N'Uttar Pradesh', N'Hathras' UNION ALL
SELECT N'Uttar Pradesh', N'Jalalabad' UNION ALL
SELECT N'Uttar Pradesh', N'Jalaun' UNION ALL
SELECT N'Uttar Pradesh', N'Jalesar' UNION ALL
SELECT N'Uttar Pradesh', N'Jansath' UNION ALL
SELECT N'Uttar Pradesh', N'Jarar'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Uttar Pradesh', N'Jasrana' UNION ALL
SELECT N'Uttar Pradesh', N'Jaunpur' UNION ALL
SELECT N'Uttar Pradesh', N'Jhansi' UNION ALL
SELECT N'Uttar Pradesh', N'Jyotiba Phule Nagar' UNION ALL
SELECT N'Uttar Pradesh', N'Kadipur' UNION ALL
SELECT N'Uttar Pradesh', N'Kaimganj' UNION ALL
SELECT N'Uttar Pradesh', N'Kairana' UNION ALL
SELECT N'Uttar Pradesh', N'Kaisarganj' UNION ALL
SELECT N'Uttar Pradesh', N'Kalpi' UNION ALL
SELECT N'Uttar Pradesh', N'Kannauj' UNION ALL
SELECT N'Uttar Pradesh', N'Kanpur' UNION ALL
SELECT N'Uttar Pradesh', N'Karchhana' UNION ALL
SELECT N'Uttar Pradesh', N'Karhal' UNION ALL
SELECT N'Uttar Pradesh', N'Karvi' UNION ALL
SELECT N'Uttar Pradesh', N'Kasganj' UNION ALL
SELECT N'Uttar Pradesh', N'Kaushambi' UNION ALL
SELECT N'Uttar Pradesh', N'Kerakat' UNION ALL
SELECT N'Uttar Pradesh', N'Khaga' UNION ALL
SELECT N'Uttar Pradesh', N'Khair' UNION ALL
SELECT N'Uttar Pradesh', N'Khalilabad' UNION ALL
SELECT N'Uttar Pradesh', N'Kheri' UNION ALL
SELECT N'Uttar Pradesh', N'Konch' UNION ALL
SELECT N'Uttar Pradesh', N'Kumaon' UNION ALL
SELECT N'Uttar Pradesh', N'Kunda' UNION ALL
SELECT N'Uttar Pradesh', N'Kushinagar' UNION ALL
SELECT N'Uttar Pradesh', N'Lalganj' UNION ALL
SELECT N'Uttar Pradesh', N'Lalitpur' UNION ALL
SELECT N'Uttar Pradesh', N'Lucknow' UNION ALL
SELECT N'Uttar Pradesh', N'Machlishahar' UNION ALL
SELECT N'Uttar Pradesh', N'Maharajganj' UNION ALL
SELECT N'Uttar Pradesh', N'Mahoba' UNION ALL
SELECT N'Uttar Pradesh', N'Mainpuri' UNION ALL
SELECT N'Uttar Pradesh', N'Malihabad' UNION ALL
SELECT N'Uttar Pradesh', N'Mariyahu' UNION ALL
SELECT N'Uttar Pradesh', N'Math' UNION ALL
SELECT N'Uttar Pradesh', N'Mathura' UNION ALL
SELECT N'Uttar Pradesh', N'Mau' UNION ALL
SELECT N'Uttar Pradesh', N'Maudaha' UNION ALL
SELECT N'Uttar Pradesh', N'Maunathbhanjan' UNION ALL
SELECT N'Uttar Pradesh', N'Mauranipur' UNION ALL
SELECT N'Uttar Pradesh', N'Mawana' UNION ALL
SELECT N'Uttar Pradesh', N'Meerut' UNION ALL
SELECT N'Uttar Pradesh', N'Mehraun' UNION ALL
SELECT N'Uttar Pradesh', N'Meja' UNION ALL
SELECT N'Uttar Pradesh', N'Mirzapur' UNION ALL
SELECT N'Uttar Pradesh', N'Misrikh' UNION ALL
SELECT N'Uttar Pradesh', N'Modinagar' UNION ALL
SELECT N'Uttar Pradesh', N'Mohamdabad' UNION ALL
SELECT N'Uttar Pradesh', N'Mohamdi' UNION ALL
SELECT N'Uttar Pradesh', N'Moradabad'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Uttar Pradesh', N'Musafirkhana' UNION ALL
SELECT N'Uttar Pradesh', N'Muzaffarnagar' UNION ALL
SELECT N'Uttar Pradesh', N'Nagina' UNION ALL
SELECT N'Uttar Pradesh', N'Najibabad' UNION ALL
SELECT N'Uttar Pradesh', N'Nakur' UNION ALL
SELECT N'Uttar Pradesh', N'Nanpara' UNION ALL
SELECT N'Uttar Pradesh', N'Naraini' UNION ALL
SELECT N'Uttar Pradesh', N'Naugarh' UNION ALL
SELECT N'Uttar Pradesh', N'Nawabganj' UNION ALL
SELECT N'Uttar Pradesh', N'Nighasan' UNION ALL
SELECT N'Uttar Pradesh', N'Noida' UNION ALL
SELECT N'Uttar Pradesh', N'Orai' UNION ALL
SELECT N'Uttar Pradesh', N'Padrauna' UNION ALL
SELECT N'Uttar Pradesh', N'Pahasu' UNION ALL
SELECT N'Uttar Pradesh', N'Patti' UNION ALL
SELECT N'Uttar Pradesh', N'Pharenda' UNION ALL
SELECT N'Uttar Pradesh', N'Phoolpur' UNION ALL
SELECT N'Uttar Pradesh', N'Phulpur' UNION ALL
SELECT N'Uttar Pradesh', N'Pilibhit' UNION ALL
SELECT N'Uttar Pradesh', N'Pitamberpur' UNION ALL
SELECT N'Uttar Pradesh', N'Powayan' UNION ALL
SELECT N'Uttar Pradesh', N'Pratapgarh' UNION ALL
SELECT N'Uttar Pradesh', N'Puranpur' UNION ALL
SELECT N'Uttar Pradesh', N'Purwa' UNION ALL
SELECT N'Uttar Pradesh', N'Raibareli' UNION ALL
SELECT N'Uttar Pradesh', N'Rampur' UNION ALL
SELECT N'Uttar Pradesh', N'Ramsanehi Ghat' UNION ALL
SELECT N'Uttar Pradesh', N'Rasara' UNION ALL
SELECT N'Uttar Pradesh', N'Rath' UNION ALL
SELECT N'Uttar Pradesh', N'Robertsganj' UNION ALL
SELECT N'Uttar Pradesh', N'Sadabad' UNION ALL
SELECT N'Uttar Pradesh', N'Safipur' UNION ALL
SELECT N'Uttar Pradesh', N'Sagri' UNION ALL
SELECT N'Uttar Pradesh', N'Saharanpur' UNION ALL
SELECT N'Uttar Pradesh', N'Sahaswan' UNION ALL
SELECT N'Uttar Pradesh', N'Sahjahanpur' UNION ALL
SELECT N'Uttar Pradesh', N'Saidpur' UNION ALL
SELECT N'Uttar Pradesh', N'Salempur' UNION ALL
SELECT N'Uttar Pradesh', N'Salon' UNION ALL
SELECT N'Uttar Pradesh', N'Sambhal' UNION ALL
SELECT N'Uttar Pradesh', N'Sandila' UNION ALL
SELECT N'Uttar Pradesh', N'Sant Kabir Nagar' UNION ALL
SELECT N'Uttar Pradesh', N'Sant Ravidas Nagar' UNION ALL
SELECT N'Uttar Pradesh', N'Sardhana' UNION ALL
SELECT N'Uttar Pradesh', N'Shahabad' UNION ALL
SELECT N'Uttar Pradesh', N'Shahganj' UNION ALL
SELECT N'Uttar Pradesh', N'Shahjahanpur' UNION ALL
SELECT N'Uttar Pradesh', N'Shikohabad' UNION ALL
SELECT N'Uttar Pradesh', N'Shravasti' UNION ALL
SELECT N'Uttar Pradesh', N'Siddharthnagar'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'Uttar Pradesh', N'Sidhauli' UNION ALL
SELECT N'Uttar Pradesh', N'Sikandra Rao' UNION ALL
SELECT N'Uttar Pradesh', N'Sikandrabad' UNION ALL
SELECT N'Uttar Pradesh', N'Sitapur' UNION ALL
SELECT N'Uttar Pradesh', N'Siyana' UNION ALL
SELECT N'Uttar Pradesh', N'Sonbhadra' UNION ALL
SELECT N'Uttar Pradesh', N'Soraon' UNION ALL
SELECT N'Uttar Pradesh', N'Sultanpur' UNION ALL
SELECT N'Uttar Pradesh', N'Tanda' UNION ALL
SELECT N'Uttar Pradesh', N'Tarabganj' UNION ALL
SELECT N'Uttar Pradesh', N'Tilhar' UNION ALL
SELECT N'Uttar Pradesh', N'Unnao' UNION ALL
SELECT N'Uttar Pradesh', N'Utraula' UNION ALL
SELECT N'Uttar Pradesh', N'Varanasi' UNION ALL
SELECT N'Uttar Pradesh', N'Zamania' UNION ALL
SELECT N'Uttarakhand', N'Almora' UNION ALL
SELECT N'Uttarakhand', N'Bageshwar' UNION ALL
SELECT N'Uttarakhand', N'Bhatwari' UNION ALL
SELECT N'Uttarakhand', N'Chakrata' UNION ALL
SELECT N'Uttarakhand', N'Chamoli' UNION ALL
SELECT N'Uttarakhand', N'Champawat' UNION ALL
SELECT N'Uttarakhand', N'Dehradun' UNION ALL
SELECT N'Uttarakhand', N'Deoprayag' UNION ALL
SELECT N'Uttarakhand', N'Dharchula' UNION ALL
SELECT N'Uttarakhand', N'Dunda' UNION ALL
SELECT N'Uttarakhand', N'Haldwani' UNION ALL
SELECT N'Uttarakhand', N'Haridwar' UNION ALL
SELECT N'Uttarakhand', N'Joshimath' UNION ALL
SELECT N'Uttarakhand', N'Karan Prayag' UNION ALL
SELECT N'Uttarakhand', N'Kashipur' UNION ALL
SELECT N'Uttarakhand', N'Khatima' UNION ALL
SELECT N'Uttarakhand', N'Kichha' UNION ALL
SELECT N'Uttarakhand', N'Lansdown' UNION ALL
SELECT N'Uttarakhand', N'Munsiari' UNION ALL
SELECT N'Uttarakhand', N'Mussoorie' UNION ALL
SELECT N'Uttarakhand', N'Nainital' UNION ALL
SELECT N'Uttarakhand', N'Pantnagar' UNION ALL
SELECT N'Uttarakhand', N'Partapnagar' UNION ALL
SELECT N'Uttarakhand', N'Pauri Garhwal' UNION ALL
SELECT N'Uttarakhand', N'Pithoragarh' UNION ALL
SELECT N'Uttarakhand', N'Purola' UNION ALL
SELECT N'Uttarakhand', N'Rajgarh' UNION ALL
SELECT N'Uttarakhand', N'Ranikhet' UNION ALL
SELECT N'Uttarakhand', N'Roorkee' UNION ALL
SELECT N'Uttarakhand', N'Rudraprayag' UNION ALL
SELECT N'Uttarakhand', N'Tehri Garhwal' UNION ALL
SELECT N'Uttarakhand', N'Udham Singh Nagar' UNION ALL
SELECT N'Uttarakhand', N'Ukhimath' UNION ALL
SELECT N'Uttarakhand', N'Uttarkashi' UNION ALL
SELECT N'West Bengal', N'Adra'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'West Bengal', N'Alipurduar' UNION ALL
SELECT N'West Bengal', N'Amlagora' UNION ALL
SELECT N'West Bengal', N'Arambagh' UNION ALL
SELECT N'West Bengal', N'Asansol' UNION ALL
SELECT N'West Bengal', N'Balurghat' UNION ALL
SELECT N'West Bengal', N'Bankura' UNION ALL
SELECT N'West Bengal', N'Bardhaman' UNION ALL
SELECT N'West Bengal', N'Basirhat' UNION ALL
SELECT N'West Bengal', N'Berhampur' UNION ALL
SELECT N'West Bengal', N'Bethuadahari' UNION ALL
SELECT N'West Bengal', N'Birbhum' UNION ALL
SELECT N'West Bengal', N'Birpara' UNION ALL
SELECT N'West Bengal', N'Bishanpur' UNION ALL
SELECT N'West Bengal', N'Bolpur' UNION ALL
SELECT N'West Bengal', N'Bongoan' UNION ALL
SELECT N'West Bengal', N'Bulbulchandi' UNION ALL
SELECT N'West Bengal', N'Burdwan' UNION ALL
SELECT N'West Bengal', N'Calcutta' UNION ALL
SELECT N'West Bengal', N'Canning' UNION ALL
SELECT N'West Bengal', N'Champadanga' UNION ALL
SELECT N'West Bengal', N'Contai' UNION ALL
SELECT N'West Bengal', N'Cooch Behar' UNION ALL
SELECT N'West Bengal', N'Daimond Harbour' UNION ALL
SELECT N'West Bengal', N'Dalkhola' UNION ALL
SELECT N'West Bengal', N'Dantan' UNION ALL
SELECT N'West Bengal', N'Darjeeling' UNION ALL
SELECT N'West Bengal', N'Dhaniakhali' UNION ALL
SELECT N'West Bengal', N'Dhuliyan' UNION ALL
SELECT N'West Bengal', N'Dinajpur' UNION ALL
SELECT N'West Bengal', N'Dinhata' UNION ALL
SELECT N'West Bengal', N'Durgapur' UNION ALL
SELECT N'West Bengal', N'Gangajalghati' UNION ALL
SELECT N'West Bengal', N'Gangarampur' UNION ALL
SELECT N'West Bengal', N'Ghatal' UNION ALL
SELECT N'West Bengal', N'Guskara' UNION ALL
SELECT N'West Bengal', N'Habra' UNION ALL
SELECT N'West Bengal', N'Haldia' UNION ALL
SELECT N'West Bengal', N'Harirampur' UNION ALL
SELECT N'West Bengal', N'Harishchandrapur' UNION ALL
SELECT N'West Bengal', N'Hooghly' UNION ALL
SELECT N'West Bengal', N'Howrah' UNION ALL
SELECT N'West Bengal', N'Islampur' UNION ALL
SELECT N'West Bengal', N'Jagatballavpur' UNION ALL
SELECT N'West Bengal', N'Jalpaiguri' UNION ALL
SELECT N'West Bengal', N'Jhalda' UNION ALL
SELECT N'West Bengal', N'Jhargram' UNION ALL
SELECT N'West Bengal', N'Kakdwip' UNION ALL
SELECT N'West Bengal', N'Kalchini' UNION ALL
SELECT N'West Bengal', N'Kalimpong' UNION ALL
SELECT N'West Bengal', N'Kalna'
)
INSERT INTO [dbo].[City_Master]([State_Name], [City_Name]) (
SELECT N'West Bengal', N'Kandi' UNION ALL
SELECT N'West Bengal', N'Karimpur' UNION ALL
SELECT N'West Bengal', N'Katwa' UNION ALL
SELECT N'West Bengal', N'Kharagpur' UNION ALL
SELECT N'West Bengal', N'Khatra' UNION ALL
SELECT N'West Bengal', N'Krishnanagar' UNION ALL
SELECT N'West Bengal', N'Mal Bazar' UNION ALL
SELECT N'West Bengal', N'Malda' UNION ALL
SELECT N'West Bengal', N'Manbazar' UNION ALL
SELECT N'West Bengal', N'Mathabhanga' UNION ALL
SELECT N'West Bengal', N'Medinipur' UNION ALL
SELECT N'West Bengal', N'Mekhliganj' UNION ALL
SELECT N'West Bengal', N'Mirzapur' UNION ALL
SELECT N'West Bengal', N'Murshidabad' UNION ALL
SELECT N'West Bengal', N'Nadia' UNION ALL
SELECT N'West Bengal', N'Nagarakata' UNION ALL
SELECT N'West Bengal', N'Nalhati' UNION ALL
SELECT N'West Bengal', N'Nayagarh' UNION ALL
SELECT N'West Bengal', N'Parganas' UNION ALL
SELECT N'West Bengal', N'Purulia' UNION ALL
SELECT N'West Bengal', N'Raiganj' UNION ALL
SELECT N'West Bengal', N'Rampur Hat' UNION ALL
SELECT N'West Bengal', N'Ranaghat' UNION ALL
SELECT N'West Bengal', N'Seharabazar' UNION ALL
SELECT N'West Bengal', N'Siliguri' UNION ALL
SELECT N'West Bengal', N'Suri' UNION ALL
SELECT N'West Bengal', N'Takipur' UNION ALL
SELECT N'West Bengal', N'Tamluk'
)

end
end

