

--//**  Created By :- Shaikh Ramiz
--//**  Created On :- 07/07/2015

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Daily_Absent_Reminder_SMS]
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN   
	
	Declare @cmp_id_Pass  Numeric(18,0) = 0
	Declare @From_Date  as datetime
	Declare @From_Date_1 datetime
	Declare @SMS_Text Varchar(1000)
	Declare @Cur_SMS_Send_Mobile_No Varchar(50)
	Declare @Cur_SMS_Send_For_Date datetime
	Declare @Cur_SMS_Send_Emp_Name Varchar(200)
	Declare @sResponse varchar(1000)
	
	
	set @From_Date  =  CONVERT(VARCHAR(11),GETDATE(),106)
	--set @From_Date = '06-Jul-2015'		--\\For Testing any Day Record

	Set @From_Date_1 = DATEADD(dd,-1,@From_Date)
	Set @SMS_Text = ''       
      

      IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
     CREATE TABLE #Temp 
(
	Cmp_Id Numeric,
	Emp_Id numeric,
	Emp_Code varchar(100),
	Emp_Name varchar(200),
	Desig_Name varchar(100),
	Dept_Name Varchar(100),
	For_Date Datetime,
	Status varchar(10),
	Branch_name varchar(100)
) 
 
	---Cursor of Selecting All Company One By One  -----
     Declare Cur_cmp_id Cursor For
		Select Cmp_id from T0010_Company_master WITH (NOLOCK) --where cmp_id = 1
	Open Cur_cmp_id
	Fetch Next from Cur_cmp_id into @cmp_id_Pass
	While @@FETCH_STATUS = 0
		Begin
			INSERT    INTO #Temp
			exec [SP_Get_Present_Absent_Emp_List] @cmp_id_Pass,@From_Date_1
			
			Fetch Next from Cur_cmp_id into @cmp_id_Pass
		End
	Close Cur_cmp_id
	Deallocate Cur_cmp_id
	
	---- Cursor Ends Here  -------------
	
	 Delete #Temp Where Status <> 'A'	
	
	-------Cursor for Selecting Mobile NMumber & Name of all Employees in Temp table ---------
	Declare Cur_SMS_Send Cursor	For 
		Select Mobile_No,For_date,Emp_First_Name
		from
		 (Select distinct (Case When E.Mobile_No = '' THEN '0' ELSE E.Mobile_No END) as Mobile_No ,@From_Date_1 as For_date,E.Emp_First_Name,E.Emp_Code 
		From  T0080_EMP_MASTER E WITH (NOLOCK) inner join #Temp T on T.Emp_ID = E.Emp_ID
		and  cast((Case When E.Mobile_No = '' THEN '0' ELSE E.Mobile_No END) as varchar(50)) <> '0'
		) Qry order by Qry.Emp_Code
	open Cur_SMS_Send
	Fetch next From Cur_SMS_Send into @Cur_SMS_Send_Mobile_No,@Cur_SMS_Send_For_Date,@Cur_SMS_Send_Emp_Name
	While @@Fetch_Status = 0
		Begin		
		
			Set @SMS_Text = 'Dear ' + @Cur_SMS_Send_Emp_Name + ', Your In Time and Out Time Both are missing on ' + CONVERT(VARCHAR(11),@Cur_SMS_Send_For_Date,103) + ', Please Contact to HR/Admin.'
			--print @SMS_Text
			Exec pr_SendSmsSQL @Cur_SMS_Send_Mobile_No,@SMS_Text,@sResponse Out
			--Exec pr_SendSmsSQL '9824302520',@SMS_Text,@sResponse Out
		Fetch next From Cur_SMS_Send into @Cur_SMS_Send_Mobile_No,@Cur_SMS_Send_For_Date,@Cur_SMS_Send_Emp_Name
	End 
	Close Cur_SMS_Send
	Deallocate Cur_SMS_Send
	
END
