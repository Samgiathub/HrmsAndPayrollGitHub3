

-- =============================================
-- Author:		<Author,,JIMIT SONI>
-- Create date: <Create Date,,20022019>
-- Description:	<Description,,For Marriage Anniversary SMS>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Marriage_Anniversary_SMS_Reminder]
	@CMP_ID		NUMERIC(18,0) = 0,
	@CC_EMAIL	NVARCHAR(MAX) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


    declare @curCMP_ID numeric
		DECLARE @Mobile_No as varchar(20)
		DECLARE @Date_Of_Anniversary as datetime
		DECLARE @Emp_First_Name as varchar(1000)
		DECLARE @Initial as varchar(1000)
		DECLARE @Emp_second_Name as varchar(1000)
		DECLARE @Emp_Last_Name as varchar(1000)
		DECLARE @Emp_code as varchar(1000)
		DECLARE @branch_id as numeric(18,0)
		DECLARE @Cmpid as numeric(18,0)
		Declare @birthday_text as varchar(2000)
		Declare @sResponse varchar(1000)
		declare @date as datetime

		set @date = GETDATE()

		Declare CusrCompanyMST cursor for
			select	EM.Mobile_No,Emp_Annivarsary_Date,EM.Emp_First_Name,EM.Emp_Second_Name,Em.Emp_Last_Name,Em.Initial,Alpha_Emp_Code,I.Branch_ID--,I.Cmp_ID 
			from	t0080_emp_master EM WITH (NOLOCK) inner join 
					T0095_INCREMENT I WITH (NOLOCK) on EM.Increment_ID = I.Increment_ID  INNER JOIN 
					(
						SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 	
						FROM	T0095_Increment I2 WITH (NOLOCK) INNER JOIN 
								T0080_EMP_MASTER E WITH (NOLOCK) ON I2.Emp_ID=E.Emp_ID INNER JOIN 
								(
									SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID	
									FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN 
											T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID 
									WHERE	I3.Increment_effective_Date <= @date AND I3.Cmp_ID = @CMP_ID	
									GROUP BY I3.EMP_ID 
								 ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID	
							GROUP BY I2.Emp_ID 
					) I_Q ON I.Emp_ID = I_Q.Emp_ID AND I_Q.Increment_ID = I.Increment_ID
			where	1= (case when Emp_Annivarsary_Date is not null and month(Actual_Date_Of_Birth)=month(@date) and day(Actual_Date_Of_Birth) = day(@date) then 1 when  Date_Of_Birth is not null and
					month(Date_Of_Birth)=month(@date) and day(Date_Of_Birth) = day(@date) and Actual_Date_Of_Birth is null then 1 else 0 end) and
					isnull(Emp_Left,'N')<>'Y' and
					EM.CMP_ID = @CMP_ID	
		Open CusrCompanyMST
		Fetch next from CusrCompanyMST into @Mobile_No,@Date_Of_Anniversary,@Emp_First_Name,@Emp_second_Name,@Emp_Last_Name,@Initial,@Emp_code,@branch_id --,@Cmpid
		While @@fetch_status = 0                    
		Begin     

			set @birthday_text=''
			set @sResponse = ''
			
			select @birthday_text = Anniversary_Text from T0040_Sms_Setting WITH (NOLOCK) where Cmp_Id = @Cmp_id and branch_id = @Branch_Id
			if 	isnull(@birthday_text,'') = ''
				begin
					select @birthday_text = Anniversary_Text from T0040_Sms_Setting WITH (NOLOCK) where Cmp_Id = @Cmp_id and isnull(branch_id,@Branch_Id) = @Branch_Id
				end
			if isnull(@birthday_text,'') = ''
				begin
					set @birthday_text = 'Happy Marriage Anniversary to #Initial# #First_Name# #Second_Name# #Last_Name# !! Wishing you great achievements in this career, And I hope that you have a great day today! From:- HR Team'
				end 
					
			
			set @birthday_text = replace(@birthday_text,'#Initial#',@Initial)			
			set @birthday_text = replace(@birthday_text,'#First_Name#',@Emp_First_Name)			
			set @birthday_text = replace(@birthday_text,'#Second_Name#',@Emp_second_Name)			
			set @birthday_text = replace(@birthday_text,'#Last_Name#',@Emp_Last_Name)			
			set @birthday_text = replace(@birthday_text,'#Emp_Code#',@Emp_code)		
						
			
	
			if isnull(@Mobile_No,'') <>''
				begin
				-- for send sms on mobile
					Exec pr_SendSmsSQL @Mobile_No,@birthday_text,@Cmpid,@sResponse Out,'Marriage Anniversary'
				end

		fetch next from CusrCompanyMST into @Mobile_No,@Date_Of_Anniversary,@Emp_First_Name,@Emp_second_Name,@Emp_Last_Name,@Initial,@Emp_code,@branch_id --,@Cmpid
		end
		close CusrCompanyMST  
		deallocate CusrCompanyMST

END


