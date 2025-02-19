CREATE PROCEDURE [dbo].[P0130_TRAVEL_APPROVAL_DETAIL]    
  @Travel_Approval_Detail_ID NUMERIC(18,0) OUTPUT    
 ,@Cmp_ID     NUMERIC(18,0)    
 ,@Travel_Approval_ID  NUMERIC(18,0)    
 ,@Place_Of_Visit   Varchar(100)    
 ,@Travel_Purpose   Varchar(200)    
 ,@Instruct_Emp_ID   NUMERIC(18,0)    
 ,@Travel_Mode_ID   NUMERIC(18,0)    
 ,@From_Date     Datetime    
 ,@Period     NUMERIC(18,2)    
 ,@To_Date     Datetime    
 ,@Remarks     Nvarchar(500)    
 ,@Leave_Approval_ID   Numeric(18,0)    
 ,@Leave_ID     Numeric(18,0)    
 ,@State_ID     numeric(18,0)    
 ,@City_ID     numeric(18,0)    
 ,@Loc_ID     numeric(18,0)=0    
 ,@Project_ID    numeric(18,0)=0    
 ,@Tran_Type     Char(1)     
 ,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016    
 ,@IP_Address varchar(30)= '' -- Add By Mukti 11072016    
 ,@Half_Leave_Date   Datetime = Null --Added by Jaina 09-10-2017    
 ,@LeaveType     varchar(50) = '' --Added by Jaina 09-10-2017    
 ,@Night_Day     numeric(18,0) = 0 --Added by Jaina 12-10-2017    
 ,@Reason_ID    numeric(18,0)=0 -- Added by Yogesh on 050902023    
 ,@From_State_ID numeric(18,0)   
 ,@From_City_ID numeric(18,0)    
AS    
BEGIN    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
 -- Add By Mukti 11072016(start)    
 declare @OldValue as  varchar(max)    
 Declare @String_val as varchar(max)    
 set @String_val=''    
 set @OldValue =''    
 -- Add By Mukti 11072016(end)     
     
 if(@Loc_ID=0)    
  begin    
   set @Loc_ID=null;    
  End     
 if(@project_ID=0)    
  begin    
   set @project_ID=null;    
  End      
 SELECT @Cmp_ID = Cmp_ID FROM T0120_TRAVEL_APPROVAL WITH (NOLOCK) WHERE Travel_Approval_ID = @Travel_Approval_ID     
     
 If (UPPER(@Tran_Type) = 'I' or UPPER(@Tran_Type) = 'U' )    
  Begin    
   Select @Travel_Approval_Detail_ID = ISNULL(MAX(Travel_Approval_Detail_ID),0) + 1 From T0130_TRAVEL_APPROVAL_DETAIL WITH (NOLOCK)    
   --Select  @Travel_Approval_ID= ISNULL(MAX(Travel_Approval_ID),0)  from T0120_TRAVEL_APPROVAL    
   if Not Exists(select 1 from T0130_TRAVEL_APPROVAL_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Travel_Approval_ID=@Travel_Approval_ID and Place_Of_Visit=@Place_Of_Visit and Instruct_Emp_ID=@Instruct_Emp_ID and from_date=@from_date and To_Date=@To_Date
  
 and State_ID=@State_ID and City_ID=@City_ID)    
   Begin    
    Insert Into T0130_TRAVEL_APPROVAL_DETAIL    
     (Travel_Approval_Detail_ID, Cmp_ID, Travel_Approval_ID, Place_Of_Visit, Travel_Purpose, Instruct_Emp_ID, Travel_Mode_ID,     
      From_Date, Period, To_Date, Remarks,Leave_Approval_ID,Leave_ID,State_ID,City_ID,Loc_ID,Project_ID,Half_Leave_Date,Leavetype,Night_Day,Reason_ID,From_State_id,From_City_id)    
    Values (@Travel_Approval_Detail_ID, @Cmp_ID, @Travel_Approval_ID, @Place_Of_Visit, @Travel_Purpose, @Instruct_Emp_ID, @Travel_Mode_ID,    
      @From_Date, @Period, @To_Date, @Remarks,@Leave_Approval_ID,@Leave_ID,@State_ID,@City_ID,@Loc_ID,@Project_ID,@Half_Leave_Date,@Leavetype,@Night_Day,@Reason_ID,@From_State_ID,@From_City_ID)    
          
   -- Add By Mukti 11072016(start)    
    exec P9999_Audit_get @table = 'T0130_TRAVEL_APPROVAL_DETAIL' ,@key_column='Travel_Approval_Detail_ID',@key_Values=@Travel_Approval_Detail_ID,@String=@String_val output    
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))      
   -- Add By Mukti 11072016(end)    
   End       
          
          
  End    
 --Else if UPPER(@Tran_Type) = 'U'    
 -- Begin    
 --  Select @Travel_Approval_Detail_ID = ISNULL(MAX(Travel_Approval_Detail_ID),0) + 1 From T0130_TRAVEL_APPROVAL_DETAIL      
 --  if Not Exists(select 1 from T0130_TRAVEL_APPROVAL_DETAIL where Cmp_ID=@Cmp_ID and Travel_Approval_ID=@Travel_Approval_ID and Place_Of_Visit=@Place_Of_Visit and Instruct_Emp_ID=@Instruct_Emp_ID and from_date=@from_date and To_Date=@To_Date and State_I
  
--D=@State_ID and City_ID=@City_ID)    
 --  Begin    
 --   Insert Into T0130_TRAVEL_APPROVAL_DETAIL    
 --    (Travel_Approval_Detail_ID, Cmp_ID, Travel_Approval_ID, Place_Of_Visit, Travel_Purpose, Instruct_Emp_ID, Travel_Mode_ID,     
 --     From_Date, Period, To_Date, Remarks,Leave_Approval_ID,Leave_ID,State_ID,City_ID,Loc_ID)    
 --   Values (@Travel_Approval_Detail_ID, @Cmp_ID, @Travel_Approval_ID, @Place_Of_Visit, @Travel_Purpose, @Instruct_Emp_ID, @Travel_Mode_ID,    
 --     @From_Date, @Period, @To_Date, @Remarks,@Leave_Approval_ID,@Leave_ID,@State_ID,@City_ID,@Loc_ID)    
 --  End       
 -- End    
 exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Travel Approval Details',@OldValue,@Travel_Approval_Detail_ID,@User_Id,@IP_Address    
END    
    