


-- Created By Rohit on 12032015 for Insert Default Reminder List.
-- ===============================================================
CREATE PROCEDURE [dbo].[InsertDefaultLanguageAlias] 
@CMP_ID as numeric(18,0)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
		
		Declare @Reminder_Mail Table(SORTID INT,ENGLISH varchar(MAX),LANGUAGES nvarchar(MAX),REMARK varchar(MAX))

		
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (1,'Employee Code',N'એમ્પ્લોઇ કોડ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (2,'Employee Name',N'કામદારનું નામ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (3,'Father Name',N'પિતાનું નામ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (4,'Branch Name',N'શાખા','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (5,'Department',N'ડીપાર્ટમેન્ટ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (6,'Place of Position',N'કામ નું સ્થળ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (7,'Grade Name',N'ગ્રેડ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (8,'ESIC No',N'ઈ.એસ.આઈ.સી.નંબર','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (9,'Date of Joining',N'દાખલ થયા તારીખ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (10,'PF A/c No.',N'પી.એફ.ખાતા નંબર','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (11,'PAN No',N'પાન નંબર','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (12,'Bank Name',N'બેંક નામ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (13,'Bank A/c No.',N'બેંક ખાતા નંબર','')
	    insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (14,'UAN No',N'યુ એ એન નંબર','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (15,'Month Day',N'માસના દિવસ','')
	    insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (16,'Working Days',N'કામ ના દિવસ ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (17,'On Duty/Tour',N'ઓંન ડ્યુટી/પ્રવાસ','')
	    insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (18,'Holiday',N'જાહેર રજા','')
	    insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (19,'Week Off',N'અઠવાડિક રજા','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (20,'Paid days',N'ચુકવેલ દિવસ ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (21,'Absent Days',N'ગેરહાજર દિવસ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (22,'Paid Leave',N'ચુકવેલ રજા','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (23,'Arrear Month',N'જાહેર રજાના હાજર દિવસ ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (24,'Arrear Days',N'એરીયર દિવસ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (25,'Late Day',N'ઓંવર ટાઇમ કલાક','')
        insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (26,'OT Hours',N'અઠવાડિક રજા ઓંવરટાઇમ ','')
        insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (27,'W.OT Hours',N'જાહેરરજા ઓંવર ટાઇમ કલાક','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (28,'H.OT Hours',N'એરિયર માસ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (29,'Gate Pass Days',N'ગેટ પાસ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (30,'Salary Components',N'પગાર વિગત ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (31,'Monthly Amount',N'માસિક દર રૂપિયા','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (32,'Earning Amount',N'ચુકવવા પાત્ર રૂપિયા','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (33,'Arrears Amount',N'એરિયર રૂપિયા','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (34,'Total',N'કુલ રૂપિયા','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (35,'Deduction',N'કપાત ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (36,'Deduction Amount',N'કપાત રૂપિયા','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (37,'Basic Salary',N'બેઝીક પગાર','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (38,'Claim Amount',N'દાવા રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (39,'Travel Amount',N'યાત્રા રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (40,'Travel Advance Amount',N'યાત્રા એડવાન્સ રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (41,'OT Amount',N'ઓંવર ટાઇમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (42,'Arrears',N'એદરયર','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (43,'Arrear Amount',N'બાકીનો રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (44,'Leave Encash Amount',N'એન્કેશમેન્ટ રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (45,'Advance Amount',N'એડવાન્સ રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (46,'Asset Installment Amount',N'એસેટ હપતો રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (47,'Loan Amount',N'લોન રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (48,'Loan Interest',N'લોન વ્યાજ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (49,'Bonus',N'બોનસ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (50,'Professional tax',N'વ્યાવસાયિક કર','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (51,'LWF Amount',N'શ્રમ કલ્યાણ રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (52,'Revenue Amount',N'મહેસૂલ રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (53,'Other Dedu',N'અન્ય કપાત','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (54,'Extra Absent Amount',N'વિશેષ ગેરહાજર રકમ','') ---added on 03 Mar 2016 sneha
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (55,'Deficit Dedu Amount',N'ડેફિસિટ કપાત રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (56,'Week Off Working',N'સપ્તાહ બંધ કામ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (57,'Holiday Working',N'હોલિડે કામ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (58,'Designation',N'હોદ્દો','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (59,'Month Day',N'માસના દિવસ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (60,'Absent Day',N'ગેરહાજર દિવસ:','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (61,'Late Days',N'ઓંવર ટાઇમ કલાક:','')
        insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (62,'OT Hours',N'અઠવાડિક રજા ઓંવરટાઇમ ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (63,'Unpaid Leave',N'','અવેતન રજા')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (64,'On Duty/Tour',N'ઓંન ડ્યુટી/પ્રવાસ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (65,'Unpaid Leave',N'','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (66,'W.OT Hours',N'જાહેરરજા ઓંવર ટાઇમ કલાક','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (67,'Holiday',N'જાહેર રજા','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (68,'Total (Gross Salary)',N'કુલ પગારની રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (69,'Net Payable',N'ચોખ્ખી ચુકવવા પાત્ર રકમ ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (70,'Arrears Amount',N'બાકી રકમ','')
	    insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (71,'Net Payable',N'નેટ ચૂકવવાપાત્ર','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (72,'Leave Status',N'રજા','')
        insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (73,'Leave',N'રજા','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (74,'Opening',N'પ્રારંભ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (75,'Availed',N'મેળવી','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (76,'Penalty',N'દંડ','')
	    insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (77,'Balance',N'બેલેન્સ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (78,'Loan Name',N'લોન નામ','')
        insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (79,'Loan Amount',N'લોન રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (80,'Paid Amount',N'ચૂકવેલ રકમ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (81,'Current EMI',N'વર્તમાન ઈએમઆઈ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (82,'Closing',N'બંધ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (83,'Other Components',N'અન્ય ઘટકો','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (84,'Comments',N'ટિપ્પણીઓ','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (85,'For the week/Fortnight/month','','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (86,'Name and Address of Contractor','','')
		insert into @Reminder_Mail (SORTID,ENGLISH,LANGUAGES,REMARK) values (87,'Nature and Location of Work','','')
		
		
		
		DECLARE @ENGLISH Nvarchar(max), 
				@LANGUAGES NVARCHAR(MAX),
				@REMARK Nvarchar(MAX),
				@SORTID INT


		DECLARE L_Master CURSOR fast_forward FOR SELECT ENGLISH,LANGUAGES,REMARK,SORTID FROM @Reminder_Mail
		OPEN L_Master
		FETCH NEXT FROM L_Master INTO @ENGLISH, @LANGUAGES,@REMARK,@SORTID
		WHILE @@FETCH_STATUS = 0
		BEGIN

			DECLARE @CNT as int
			SET @CNT = 0	
			SET @CNT = (Select COUNT(*) from T0040_LANGUAGE_DETAIL WITH (NOLOCK) WHERE UPPER(ENGLISH) = UPPER(@ENGLISH) and CMP_ID=@CMP_ID)
			IF @CNT = 0
			BEGIN
			   INSERT INTO T0040_LANGUAGE_DETAIL (CMP_ID,ENGLISH,LANGUAGES,REMARK,SORTID)VALUES(@CMP_ID,@ENGLISH, @LANGUAGES,@REMARK,@SORTID)
				
			END
		   FETCH NEXT FROM L_Master INTO @ENGLISH, @LANGUAGES,@REMARK,@SORTID
		   
		END

		CLOSE L_Master
		DEALLOCATE L_Master
END


