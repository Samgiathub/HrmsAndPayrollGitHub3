




CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_AUTO_RK]
--@CMP_ID NUMERIC 

as

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

DECLARE @Emp_ID NUMERIC(18,0)
DECLARE @Cmp_ID int
DECLARE @IO_DateTime datetime
DECLARE @IP_Address nvarchar(50)

declare cmp cursor for
select cmp_id from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id in (2,3,4)
  
OPEN cmp

FETCH NEXT FROM cmp INTO @Cmp_Id

WHILE @@FETCH_STATUS = 0
BEGIN



DECLARE Emp_InOut_cursor CURSOR FOR 

 Select MaxDt.Emp_ID,MaxDt.Cmp_ID,InOut.IO_DateTime,InOut.IP_Address from T9999_DEVICE_INOUT_DETAIL  as InOut WITH (NOLOCK)
 inner join (
 select e.Cmp_Id,e.Emp_ID,E.Enroll_No , 
  isnull(case when isnull(In_Time,'01-01-1900')  > isnull(Out_Time,'01-01-1900') then    
   In_Time   
  else  
   Out_Time   
  end,'01-01-1900') as InOut_Time 
 From T0080_Emp_Master e WITH (NOLOCK) left outer join   
 ( select eir.Emp_ID ,max(In_Time)In_Time,max(Out_time)Out_Time from T0150_Emp_Inout_Record eir WITH (NOLOCK) group by emp_ID ) q on e.emp_ID = q.emp_ID  
 where isnull(emp_Left,'N') <> 'Y'  
 ) as MaxDt on InOut.Enroll_No = MaxDt.Enroll_No 
 where InOut.IO_DateTime > MaxDt.InOut_Time
  order by InOut.Enroll_No,InOut.IO_DateTime
  
OPEN Emp_InOut_cursor

FETCH NEXT FROM Emp_InOut_cursor INTO @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address

WHILE @@FETCH_STATUS = 0
BEGIN

Set @IO_DATETIME = cast(@IO_DATETIME as varchar(11)) + ' ' + dbo.F_GET_AMPM(@IO_DATETIME)
	exec SP_EMP_INOUT_SYNCHRONIZATION  @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address ,0,0


   FETCH NEXT FROM Emp_InOut_cursor INTO  @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address
END 
CLOSE Emp_InOut_cursor
DEALLOCATE Emp_InOut_cursor



FETCH NEXT FROM cmp INTO @Cmp_Id
End

CLOSE cmp
DEALLOCATE cmp

