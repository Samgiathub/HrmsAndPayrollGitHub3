


---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_NEW]
 @EMP_ID NUMERIC ,    
 @CMP_ID NUMERIC ,    
 @IO_DATETIME DATETIME ,    
 @IP_ADDRESS VARCHAR(50),
 @In_Out_flag numeric = 0,
 @Flag int = 0
 
 AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	SET ANSI_WARNINGS OFF
 
if @Flag = 1
Begin
 
 Declare @TranMax_Date datetime
 select @TranMax_Date =  max(For_Date )  from T0150_Emp_Inout_Record WITH (NOLOCK)  where   emp_id  = @EMP_ID 
 

DECLARE @dIO_DateTime datetime
DECLARE @dIP_Address Varchar(50)
DECLARE @dIn_Out_Flag int
DECLARE @intCount BigInt
DECLARE @oldIO_DateTime datetime
set @intCount =1
	
	DECLARE CURINOUT_DETAIL CURSOR
	FOR
 	
 	 select distinct IO_DateTime,IP_Address,In_Out_Flag from 
 	 (
	 select  
     IO_DateTime,IP_Address,In_Out_Flag
	 from T9999_DEVICE_INOUT_DETAIL as a WITH (NOLOCK) inner join T0080_Emp_Master  as e WITH (NOLOCK)
	 on  a.Enroll_No = e.Enroll_No 
	 where cast(a.Enroll_No as varchar(50))+cast(cast(IO_DateTime as varchar(11))  as varchar(50)) In
	 (
	 select cast(Enroll_No as varchar(50)) +cast(cast(For_Date as varchar(11)) as varchar(50)) 
	 from T0150_Emp_Inout_Record as i WITH (NOLOCK) inner join T0080_Emp_Master  as e WITH (NOLOCK)
	 on i.Cmp_ID = e.Cmp_ID and  i.Emp_ID = e.Emp_ID 
	 where isnull(emp_Left,'N') <> 'Y' 
	 And i.emp_id = @EMP_ID
	 --and ISNULL(out_time,'01-01-1900') = '01-01-1900'  
     --and isnull(reason,'') = ''
	 ) 
      and e.emp_id = @EMP_ID	 
     and (
     isnull(@TranMax_Date,'01-Jan-1900') = '01-Jan-1900' 
     Or cast(cast(IO_DateTime as varchar(11)) as datetime) 
     >  cast(cast(dateadd(day,-15,@TranMax_Date) as varchar(11)) as datetime)
     )

     union all

      select  
     IO_DateTime,IP_Address,In_Out_Flag
	 from T9999_DEVICE_INOUT_DETAIL as a WITH (NOLOCK) inner join T0080_Emp_Master  as e WITH (NOLOCK)
	 on  a.Enroll_No = e.Enroll_No 
	 where cast(a.Enroll_No as varchar(50))+cast(cast(IO_DateTime as varchar(11))  as varchar(50)) Not In
	 (
	 select cast(Enroll_No as varchar(50)) +cast(cast(For_Date as varchar(11)) as varchar(50)) 
	 from T0150_Emp_Inout_Record as i WITH (NOLOCK) inner join T0080_Emp_Master  as e WITH (NOLOCK)
	 on i.Cmp_ID = e.Cmp_ID and  i.Emp_ID = e.Emp_ID 
	 where isnull(emp_Left,'N') <> 'Y' 
	 And i.emp_id = @EMP_ID
	 --and ISNULL(out_time,'01-01-1900') = '01-01-1900'  
     --and isnull(reason,'') = ''
	 ) 
      and e.emp_id = @EMP_ID	 
     and (
     isnull(@TranMax_Date,'01-Jan-1900') = '01-Jan-1900' 
     Or cast(cast(IO_DateTime as varchar(11)) as datetime) 
     >  cast(cast(dateadd(day,-15,@TranMax_Date) as varchar(11)) as datetime)
     )
       
     union all
     
    select
    IO_DateTime,IP_Address,In_Out_Flag from T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK)
	where Enroll_No  in (select Enroll_No from T0080_Emp_master WITH (NOLOCK) where emp_id  = @EMP_ID )			 
	and (isnull(@TranMax_Date,'01-Jan-1900') = '01-Jan-1900' 
	Or 
	cast(cast(IO_DateTime as varchar(11)) as datetime) >= cast(cast(@TranMax_Date as varchar(11)) as datetime))

	)  as Qry Order By IO_DateTime
	 
	 
	 OPEN CURINOUT_DETAIL
		
	FETCH NEXT FROM CURINOUT_DETAIL INTO @dIO_DateTime,@dIP_Address,@dIn_Out_Flag
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		if Cast(cast(@oldIO_DateTime as varchar(11)) as Datetime) <> CAST(CAST(@dIO_DateTime as varchar(11)) as Datetime)
 		begin
 			set @intCount = 1
 			set @oldIO_DateTime = null 
 		end  
 		 
	  begin
 	    if @intCount  = 1
 	    begin
 			Begin 
				 Delete from T0150_emp_inout_Record where Cmp_ID = @CMP_ID and emp_id  = @EMP_ID 
				 and For_Date  = CAST(CAST(@dIO_DateTime as varchar(11)) as datetime)
				 and isnull(reason,'') = ''
			End
		end
        begin
			exec SP_EMP_INOUT_SYNCHRONIZATION @EMP_ID,@CMP_ID,@dIO_DateTime,@dIP_Address,@dIn_Out_Flag,@Flag
		end

 		set @intCount =@intCount+1  
 		set @oldIO_DateTime = @dIO_DateTime   
 		
	  end
	FETCH NEXT FROM CURINOUT_DETAIL INTO @dIO_DateTime,@dIP_Address,@dIn_Out_Flag
	END
	CLOSE CURINOUT_DETAIL
	DEALLOCATE CURINOUT_DETAIL
End
							
		
RETURN



