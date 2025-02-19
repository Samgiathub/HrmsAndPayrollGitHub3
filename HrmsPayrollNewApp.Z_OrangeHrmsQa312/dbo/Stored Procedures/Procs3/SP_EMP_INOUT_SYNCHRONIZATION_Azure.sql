

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_Azure]  
 @EMP_ID NUMERIC ,      
 @CMP_ID NUMERIC ,  
 @For_date datetime,      
 @IO_In_DATETIME DATETIME ,      
 @IO_Out_DATETIME DATETIME ,      
 @IO_Duration numeric(18,0),  
 @IP_ADDRESS VARCHAR(50)  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF  
   
 declare @IO_Tran_ID numeric(18,0)    
    
 select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from T0150_emp_inout_Record WITH (NOLOCK)   
   
   
 if not exists(select 1 from T0150_emp_inout_Record WITH (NOLOCK) where Emp_ID=@EMP_ID and Cmp_ID =@CMP_ID and In_Time =@IO_In_DATETIME and Out_Time =@IO_Out_DATETIME)  
    
  Begin  
   INSERT INTO T0150_EMP_INOUT_RECORD      
   (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App)      
   VALUES       
   (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_In_DATETIME,@IO_Out_DATETIME,dbo.F_Return_Hours (@IO_Duration),'',@Ip_Address,null,null, 0, 0)      
  end    
         
    
RETURN

