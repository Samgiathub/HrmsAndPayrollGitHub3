  
						
CREATE PROCEDURE [dbo].[P0150_EMP_INOUT_RECORD_DELETE]  
  @IO_Tran_Id numeric(18)    
     ,@Emp_ID   numeric(18)      
     ,@Cmp_Id   numeric(18)   
     ,@S_Emp_ID numeric(18)  = 0 
     ,@Is_Final_Approve numeric(18) = 0   
AS  
  
        SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
BEGIN  
  
 declare @For_Date Datetime    
 declare @Max_IO_Tran_Id numeric(18)   
 declare @Is_Default_In tinyint  
 declare @Is_Default_Out tinyint  
 declare @Is_Cancel_Late_In tinyint  
 declare @Is_Cancel_Early_Out tinyint  
 DECLARE @in_time_temp AS DATETIME  ----Added by Sid 31032014  
 DECLARE @out_time_temp AS DATETIME  ----Added by Sid 31032014  
   
   
 --Select @For_Date = For_Date, @Is_Default_In = Is_Default_In from dbo.t0150_Emp_Inout_Record where Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and IO_Tran_Id=@IO_Tran_Id  
 --Select @Max_IO_Tran_Id = max(IO_Tran_Id) from T0150_EMP_INOUT_RECORD where Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date  
 --Select @Is_Default_Out = Is_Default_Out from T0150_EMP_INOUT_RECORD where Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and IO_Tran_Id = @Max_IO_Tran_Id  
 Select @For_Date = For_Date, @Is_Default_In = Is_Default_In from dbo.t0150_Emp_Inout_Record WITH (NOLOCK) where Emp_ID=@Emp_ID and IO_Tran_Id=@IO_Tran_Id  
 Select @Max_IO_Tran_Id = max(IO_Tran_Id) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID=@Emp_ID and For_Date=@For_Date  
 Select @Is_Default_Out = Is_Default_Out,@in_time_temp = In_Time,@out_time_temp = Out_Time from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID=@Emp_ID and IO_Tran_Id = @Max_IO_Tran_Id  
   
 if Exists (Select Sal_Tran_ID from T0200_MONTHLY_SALARY WITH (NOLOCK) where Month_St_Date <=@For_Date and isnull(Cutoff_Date,Month_End_Date) >=@For_Date and emp_id=@Emp_ID And Isnull(Is_Monthly_Salary,0)=1 )  
 begin  
  Raiserror('@@This Months Salary Exists@@',16,2)  
  return -1  
 end  

 Declare @forDate as Date = NULL
 SELECT @forDate = cast(For_Date as Date) FROM   T0150_EMP_INOUT_RECORD where IO_Tran_Id = @IO_Tran_Id and Emp_id = @Emp_ID and Cmp_Id = @Cmp_Id
 
 If ((SELECT count(1) FROM T0150_EMP_INOUT_RECORD E 
 inner join T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID 
 WHERE E.CMP_ID = @CMP_ID and SPE.Emp_Id = @Emp_ID and IO_Tran_Id = @IO_Tran_Id and @forDate between From_Date and To_Date) > 0)
 BEGIN
 	Raiserror('@@ Attendance Lock for this Period. @@',16,2)
 	return -1								
 END
   
   
 ----Ankit 16062014  
 declare @Tran_id as numeric(18,0)  
 declare @Rm_emp_id as numeric(18,0)  
 set @Rm_emp_id = 0  
 set @Tran_id = 0  
   
 Select @Rm_emp_id = S_Emp_ID,@Tran_id = Tran_ID from T0115_AttendanceRegu_Level_Approval WITH (NOLOCK) where  IO_Tran_Id = @IO_Tran_Id AND Rpt_Level IN (SELECT max(Rpt_Level) from T0115_AttendanceRegu_Level_Approval WITH (NOLOCK) where IO_Tran_Id = @IO_Tran_Id )  
  
 If @Rm_emp_id = @S_Emp_ID   
  Begin  
   Delete T0115_AttendanceRegu_Level_Approval where Tran_ID = @Tran_id and IO_Tran_Id = @IO_Tran_Id  
  End  
 Else  
  Begin  
   Delete T0115_AttendanceRegu_Level_Approval where IO_Tran_Id = @IO_Tran_Id  
  End   
 ----Ankit 16062014  
  
 if @Is_Final_Approve = 1   
  Begin  
     
	 ----added by mansi start 081021
  -- If @Is_Default_In = 1  
  --  update T0150_EMP_INOUT_RECORD set   
  --    --In_Time = In_Date_Time  
  --    In_Time = null  
  --    --,In_Date_Time = NULL --Added by Jaina 01-04-2017  
  --    --,In_Date_Time = @in_time_temp   
  --   ,Is_Default_In = 0  
  ----  Where IO_Tran_Id = @IO_Tran_Id And Cmp_Id=@Cmp_Id   
  --  Where IO_Tran_Id = @IO_Tran_Id And Emp_ID=@Emp_ID    

   --If @Is_Default_Out = 1  
   -- update T0150_EMP_INOUT_RECORD set   
   --   --Out_Time = Out_Date_Time + Case When Out_Date_Time < In_Time AND Out_Date_Time IS NOT NULL THEN 1 ELSE 0 END  
   --   Out_Time = null  
   --   ,Out_Date_Time = NULL  --Added by Jaina 01-04-2017  
   --   --,Out_Date_Time = @out_time_temp   
   --  ,Is_Default_Out = 0     
   -- --Where IO_Tran_Id = @Max_IO_Tran_Id And Cmp_Id=@Cmp_Id   
	   -- Where IO_Tran_Id = @Max_IO_Tran_Id And Emp_ID=@Emp_ID  
     
      ----added by mansi end 081021
     
   Update dbo.T0150_EMP_INOUT_RECORD set    
       Sup_Comment = Null  
      ,Chk_By_Superior = 0  
      --,Is_Cancel_Late_In = 0  
      ,Apr_Date = Null  
         --,Out_Date_Time = NULL  --Mukti(20062017)  
      --,In_Date_Time = NULL   --Mukti(20062017)   
       --,Out_Time = case when @S_Emp_ID >= 0  then Out_Date_Time else  NULL  END --Deepal (01/01/2021)  
       --,In_Time = case when @S_Emp_ID >= 0  then In_Date_Time else  NULL  END --Deepal (01/01/2021)  
	    ,Out_Time = case when ManualEntryFlag = 'Abs'  then null else Out_Time  END 
        ,In_Time = case when  ManualEntryFlag = 'Abs'  then null  else In_Time END
		,In_Date_Time= case when In_Admin_Time = 'A' then In_Date_Time Else NULL end
		,Out_Date_Time = case when Out_Admin_Time = 'A' then Out_Date_Time Else NULL end 
   Where IO_Tran_Id = @IO_Tran_Id And Emp_ID=@Emp_ID  
   --Where IO_Tran_Id = @IO_Tran_Id And Cmp_Id=@Cmp_Id  
     
   -- Comment by nilesh patel 11072015 -Star  
    --update T0150_EMP_INOUT_RECORD set   
    --   Is_Cancel_Early_Out = 0  
    --Where IO_Tran_Id = @Max_IO_Tran_Id And Emp_ID=@Emp_ID  
    --Where IO_Tran_Id = @Max_IO_Tran_Id And Cmp_Id=@Cmp_Id   
   -- Comment by nilesh patel 11072015 -End   
     
   ---  
   Update dbo.T0150_EMP_INOUT_RECORD set    
    Chk_By_Superior = 0  
   --Where Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date  
   Where  Emp_ID=@Emp_ID and For_Date=@For_Date  
     
   Update dbo.T0150_EMP_INOUT_RECORD set  
   Duration=0  
   --Where Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and IO_Tran_Id=@IO_Tran_Id and ((isnull(In_Time,'')='') or (isnull(Out_Time,'')=''))  
   Where Emp_ID=@Emp_ID and IO_Tran_Id=@IO_Tran_Id and ((isnull(In_Time,'')='') or (isnull(Out_Time,'')=''))  
  End   
   
  --CHANGED BY GADRIWALA MUSLIM 30092016 (CHK_BY_SUPERIOR = 2 OR CHK_BY_SUPERIOR = 1) IN-FINAL APPROVAL CASE CHK_BY_SUPERIOR NOT UPDATED  -    
  if Exists(SELECT 1 From T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where IO_Tran_Id = @IO_Tran_Id And Emp_ID=@Emp_ID and (Chk_By_Superior = 2 or Chk_By_Superior = 1))   
   BEGIN  
    Update dbo.T0150_EMP_INOUT_RECORD set    
    Chk_By_Superior = 0  
    Where   IO_Tran_Id = @IO_Tran_Id and Emp_ID=@Emp_ID and For_Date=@For_Date  
   END  
END  
  
  
  
  