

-- Created by rohit for Birthday Sms Alert on 19012017
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Birthday_Sms_reminder]
	@cmp_id_Pass Numeric(18,0) = 0,
	@CC_Email Nvarchar(max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN 

declare @curCMP_ID numeric
declare @curEMP_ID numeric
DECLARE @Mobile_No as varchar(20)
DECLARE @Date_Of_Birth as datetime
DECLARE @Emp_Full_Name as varchar(1000)
DECLARE @branch_id as numeric(18,0)
DECLARE @Cmp_id as numeric(18,0)
Declare @birthday_text as varchar(2000)
Declare @sResponse varchar(1000)
declare @date as datetime

		--Added By Jimit 22022019
		DECLARE @Emp_First_Name as varchar(100)
		DECLARE @Initial as varchar(100)
		DECLARE @Emp_second_Name as varchar(100)
		DECLARE @Emp_Last_Name as varchar(100)
		DECLARE @Emp_code as varchar(100)
		DECLARE @Date_Of_Anniversary as datetime
		Declare @Anniversary_text as varchar(2000)
		--ended

		set @date = GETDATE()

		Declare CusrCompanyMST cursor for	
			select	Em.Emp_Id,EM.Mobile_No,isnull(Actual_Date_Of_Birth,EM.Date_Of_Birth) as Date_Of_Birth,Emp_Annivarsary_Date,EM.Emp_First_Name,EM.Emp_Second_Name,Em.Emp_Last_Name,Em.Initial,
					Alpha_Emp_Code,I.Branch_ID,I.Cmp_ID 
			from	t0080_emp_master EM WITH (NOLOCK) inner join 
					T0095_INCREMENT I WITH (NOLOCK) on EM.Increment_ID = I.Increment_ID INNER JOIN 
					(
						SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 	
						FROM	T0095_Increment I2 WITH (NOLOCK) INNER JOIN 
								T0080_EMP_MASTER E WITH (NOLOCK) ON I2.Emp_ID=E.Emp_ID INNER JOIN 
								(
									SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID	
									FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN 
											T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID 
									WHERE	I3.Increment_effective_Date <= @date AND I3.Cmp_ID = @cmp_id_Pass	
									GROUP BY I3.EMP_ID 
									) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID	
							GROUP BY I2.Emp_ID 
					) I_Q ON I.Emp_ID = I_Q.Emp_ID AND I_Q.Increment_ID = I.Increment_ID	
			where	(1 = (case when Actual_Date_Of_Birth is not null and month(Actual_Date_Of_Birth)=month(@date) and day(Actual_Date_Of_Birth) = day(@date) then 1 when  Date_Of_Birth is not null and month(Date_Of_Birth)=month(@date) and day(Date_Of_Birth) = day(@date) and Actual_Date_Of_Birth is null then 1 else 0 end) OR
					 1 = (case when Emp_Annivarsary_Date is not null and month(Emp_Annivarsary_Date)=month(@date) and day(Emp_Annivarsary_Date) = day(@date) then 1 else 0 end)
					 ) and isnull(Emp_Left,'N') <> 'Y' and I.cmp_id = @cmp_id_Pass and 
					 Isnull(Em.mobile_NO,'') <> ''
		Open CusrCompanyMST
		Fetch next from CusrCompanyMST into @curEMP_ID,@Mobile_No,@Date_Of_Birth,@Date_Of_Anniversary,@Emp_First_Name,@Emp_second_Name,@Emp_Last_Name,@Initial,@Emp_code,@branch_id ,@curCMP_ID
		While @@fetch_status = 0                    
		Begin     

			set @birthday_text=''
			set @Anniversary_text = ''
			set @sResponse = ''

			
			--if 	isnull(@birthday_text,'') = ''
			--begin
			--	select @birthday_text = Message_Text from T0040_Sms_Setting where Cmp_Id = @Cmp_id and isnull(branch_id,@Branch_Id) = @Branch_Id
			--end
				IF @DATE_OF_BIRTH IS NOT NULL 
					BEGIN
						SELECT @BIRTHDAY_TEXT = MESSAGE_TEXT FROM T0040_SMS_SETTING WITH (NOLOCK) WHERE CMP_ID = @curCMP_ID AND BRANCH_ID = @BRANCH_ID
						IF ISNULL(@BIRTHDAY_TEXT,'') = ''
							BEGIN
								SET @BIRTHDAY_TEXT = 'Happy Birthday to #Initial# #First_Name# #Second_Name# #Last_Name# !! Wishing you great achievements in this career, And I hope that you have a great day today! From:- HR Team'
							END
						SET @BIRTHDAY_TEXT = REPLACE(@BIRTHDAY_TEXT,'#DATE_OF_BIRTH#',@DATE_OF_BIRTH)
					END	 
			
				IF @DATE_OF_ANNIVERSARY IS NOT NULL 
					BEGIN
						SELECT @ANNIVERSARY_TEXT = ANNIVERSARY_TEXT FROM T0040_SMS_SETTING WITH (NOLOCK) WHERE CMP_ID = @curCMP_ID AND BRANCH_ID = @BRANCH_ID
						IF ISNULL(@ANNIVERSARY_TEXT,'') = ''
							BEGIN
								SET @ANNIVERSARY_TEXT = 'Happy Marriage Anniversary to #Initial# #First_Name# #Second_Name# #Last_Name# !! From:- HR Team'
							END 
					END
	
					--Changed by jimit 22022019					
					SET @BIRTHDAY_TEXT = REPLACE(@BIRTHDAY_TEXT,'#MOBILE_NO#',@MOBILE_NO)			SET @ANNIVERSARY_TEXT = REPLACE(@ANNIVERSARY_TEXT,'#MOBILE_NO#',@MOBILE_NO)
					SET @BIRTHDAY_TEXT = REPLACE(@BIRTHDAY_TEXT,'#INITIAL#',@INITIAL)	 			SET @ANNIVERSARY_TEXT = REPLACE(@ANNIVERSARY_TEXT,'#INITIAL#',@INITIAL)		
					SET @BIRTHDAY_TEXT = REPLACE(@BIRTHDAY_TEXT,'#FIRST_NAME#',@EMP_FIRST_NAME)		SET @ANNIVERSARY_TEXT = REPLACE(@ANNIVERSARY_TEXT,'#FIRST_NAME#',@EMP_FIRST_NAME)			
					SET @BIRTHDAY_TEXT = REPLACE(@BIRTHDAY_TEXT,'#SECOND_NAME#',@EMP_SECOND_NAME)	SET @ANNIVERSARY_TEXT = REPLACE(@ANNIVERSARY_TEXT,'#SECOND_NAME#',@EMP_SECOND_NAME)			
					SET @BIRTHDAY_TEXT = REPLACE(@BIRTHDAY_TEXT,'#LAST_NAME#',@EMP_LAST_NAME)		SET @ANNIVERSARY_TEXT = REPLACE(@ANNIVERSARY_TEXT,'#LAST_NAME#',@EMP_LAST_NAME)				
					SET @BIRTHDAY_TEXT = REPLACE(@BIRTHDAY_TEXT,'#EMP_CODE#',@EMP_CODE)				SET @ANNIVERSARY_TEXT = REPLACE(@ANNIVERSARY_TEXT,'#EMP_CODE#',@EMP_CODE)		
					--ended

					--set @birthday_text = replace(@birthday_text,'#Emp_Name#',@Emp_Full_Name)
					--set @birthday_text = replace(@birthday_text,'#Date_Of_Birth#',@Date_Of_Birth)
					--set @birthday_text = replace(@birthday_text,'#Mobile_No#',@Mobile_No)
					--SELECT @ANNIVERSARY_TEXT,@BIRTHDAY_TEXT
			IF ISNULL(@MOBILE_NO,'') <>'' AND @DATE_OF_BIRTH IS NOT NULL
				BEGIN
				-- FOR SEND SMS ON MOBILE
					INSERT INTO t0000_SMS_LOGs
						values (@curEMP_ID,@BIRTHDAY_TEXT,'BIRTHDAY',@Mobile_No,getdate())

					EXEC PR_SENDSMSSQL @MOBILE_NO,@BIRTHDAY_TEXT,@curCMP_ID,@SRESPONSE OUT,'BIRTHDAY'
				END
			
			IF ISNULL(@MOBILE_NO,'') <>'' AND @DATE_OF_ANNIVERSARY IS NOT NULL
				BEGIN
				-- FOR SEND SMS ON MOBILE
					INSERT INTO t0000_SMS_LOGs
							values (@curEMP_ID,@ANNIVERSARY_TEXT,'MARRIAGE ANNIVERSARY',@Mobile_No,getdate())

					EXEC PR_SENDSMSSQL @MOBILE_NO,@ANNIVERSARY_TEXT,@curCMP_ID,@SRESPONSE OUT,'MARRIAGE ANNIVERSARY'
				END

		fetch next from CusrCompanyMST into @curEMP_ID,@Mobile_No,@Date_Of_Birth,@Date_Of_Anniversary,@Emp_First_Name,@Emp_second_Name,@Emp_Last_Name,@Initial,@Emp_code,@branch_id ,@curCMP_ID
		end
close CusrCompanyMST                    
deallocate CusrCompanyMST

End
