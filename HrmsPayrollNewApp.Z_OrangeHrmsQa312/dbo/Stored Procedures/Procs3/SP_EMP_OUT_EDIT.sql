






-- =============================================
-- Author:		<Alpesh>
-- ALTER date: <19-May-2011>
-- Description:	<It is for adding OUT TIME in table "dbo.T0150_EMP_INOUT_RECORD" when any employee logs out>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_EMP_OUT_EDIT]
	@Emp_Id As Numeric,
	@CMP_ID As NUMERIC,
	@IP_Add As Varchar(50)	
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @IO_Tran_ID numeric(18,0)   	
	Declare @For_Date Datetime
	Declare @In_Time Datetime 
	Declare @Out_Time Datetime
	
    Set @For_Date = Convert(varchar(10),GETDATE(),120) 
		
	
If Exists (Select Max(In_time) From dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID And In_time <  GetDate() And Convert(varchar(10),For_Date,120)=@For_Date)
 Begin    
	Select @In_Time=Max(In_time) From dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And In_time <  GetDate() And Convert(varchar(10),For_Date,120)=@For_Date
	If @In_Time is null    
	Begin    
		
		 Select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from dbo.T0150_emp_inout_Record WITH (NOLOCK)
			
		 INSERT INTO dbo.T0150_EMP_INOUT_RECORD
				(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,Late_Calc_Not_App)    
		 VALUES (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,GetDate(),'','','',null,null, 0, 0)    

	End    
	Else
	Begin
		Select @Out_Time=Out_Time from dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID=@Emp_ID and In_Time=In_Time 
		If @Out_Time is null  
			Begin  
			  Update dbo.T0150_EMP_INOUT_RECORD    
			  Set  Out_Time = GetDate()
			  where Emp_ID =@Emp_ID And In_Time = @In_Time 
			 End  
		Else					
			Begin    
				  Select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from dbo.T0150_emp_inout_Record WITH (NOLOCK)
					
				  INSERT INTO dbo.T0150_EMP_INOUT_RECORD    
						  (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,Late_Calc_Not_App)
				  VALUES  (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,GetDate(),'','','',null,null, 0, 0)
			End    						                  							   
	 End 
	 
				Update dbo.T0150_EMP_INOUT_RECORD     
				 Set  Duration = dbo.F_Return_Hours (datediff(s,In_time,Out_Time))      
				 Where Emp_ID =@Emp_ID  and not in_time  is null and not out_Time is null		
				 
			
				
 End  
    
 
		  
END




