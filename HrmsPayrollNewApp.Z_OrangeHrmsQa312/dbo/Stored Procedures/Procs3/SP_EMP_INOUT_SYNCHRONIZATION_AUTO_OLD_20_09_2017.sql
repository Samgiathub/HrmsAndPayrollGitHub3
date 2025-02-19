



CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_AUTO_OLD_20_09_2017]
@CMP_ID NUMERIC 

as

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
		SET ANSI_WARNINGS OFF;

begin
	  
	
DECLARE @Emp_ID NUMERIC(18,0)
--DECLARE @Cmp_ID int
DECLARE @IO_DateTime datetime
DECLARE @IP_Address nvarchar(50)
Declare @In_Out_Flag as tinyint
 --Added by Hardik 16/12/2016
 Declare @In_Out_Flag_SP tinyint


DECLARE Emp_InOut_cursor cursor Fast_forward for

 Select MaxDt.Emp_ID,MaxDt.Cmp_ID,InOut.IO_DateTime,InOut.IP_Address,
 
 --In_Out_Flag 
------ Modify jignesh 18-Apr-2017-----------
--(CASE WHEN  ISNULL(InOut.In_Out_flag,'') = '' THEN 0 ELSE InOut.In_Out_Flag END) AS In_Out_flag
(CASE WHEN (ISNULL(InOut.In_Out_flag,'') = '' OR ISNULL(InOut.In_Out_flag,'I') = 'I') THEN 0 ELSE 
Case When InOut.In_Out_Flag = 'O' THEN 1 ELSE InOut.In_Out_Flag End END) AS In_Out_flag
	
 from T9999_DEVICE_INOUT_DETAIL  as InOut WITH (NOLOCK)
 inner join (
 select e.Cmp_Id,e.Emp_ID,E.Enroll_No , 
  isnull(case when isnull(In_Time,'01-01-1900')  > isnull(Out_Time,'01-01-1900') then    
   In_Time   
  else  
   Out_Time   
  end,'01-01-1900') as InOut_Time  , Date_Of_Join,Emp_Left_Date
 From T0080_Emp_Master e WITH (NOLOCK) left outer join   
 ( select eir.Emp_ID ,max(In_Time)In_Time,max(Out_time)Out_Time from T0150_Emp_Inout_Record eir group by emp_ID ) q on e.emp_ID = q.emp_ID  

------ Modify jignesh 18-Apr-2017----------- 
---- where isnull(emp_Left,'N') <> 'Y' 
  
 ) as MaxDt on InOut.Enroll_No = MaxDt.Enroll_No 
where cast(cast(InOut.IO_DateTime as varchar(11)) + ' ' + dbo.F_GET_AMPM(InOut.IO_DateTime) as datetime) > cast(cast(MaxDt.InOut_Time as varchar(11)) + ' ' + dbo.F_GET_AMPM(MaxDt.InOut_Time) as datetime)
 -- InOut.IO_DateTime > MaxDt.InOut_Time
------Added By Jigensh 18-Apr-2017
And Date_Of_Join < InOut.IO_DateTime and InOut.IO_DateTime <= ISNULL(Emp_Left_Date+1,GETDATE() )
--------------- End----------------
---------- Add by jignesh 04-May-2017-----------
And  InOut.Enroll_No >0 
------------- End ----------- 
  order by InOut.Enroll_No,InOut.IO_DateTime
  
OPEN Emp_InOut_cursor

FETCH NEXT FROM Emp_InOut_cursor INTO @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address,@In_Out_Flag

WHILE @@FETCH_STATUS = 0
BEGIN
	 Set @In_Out_Flag_SP = 0
	 SELECT @In_Out_Flag_SP = ISNULL(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) where Setting_Name='In and Out Punch depends on Device In-Out Flag' and Cmp_ID = @Cmp_ID

	Set @IO_DATETIME = cast(@IO_DATETIME as varchar(11)) + ' ' + dbo.F_GET_AMPM(@IO_DATETIME)


	If @In_Out_Flag_SP = 1 --Added by Hardik 15/06/2016
		exec SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address ,@in_out_flag,0 --------------Sp will Execute for HNG Halol 17022016----------------------------------
	ELSE if @In_Out_Flag_SP = 2
		exec SP_EMP_INOUT_SYNCHRONIZATION_12AM_SHIFT_TIME @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address ,@in_out_flag,0 --- Added for Aculife 
	Else	
		Exec SP_EMP_INOUT_SYNCHRONIZATION @EMP_ID, @CMP_ID, @IO_DATETIME, @IP_ADDRESS,@In_Out_flag,0

   FETCH NEXT FROM Emp_InOut_cursor INTO  @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address,@In_Out_Flag
END 
CLOSE Emp_InOut_cursor
DEALLOCATE Emp_InOut_cursor

end




