
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Leave_Approval_Detail]         
 @Cmp_Id numeric,        
 @Branch_ID numeric,        
 @Emp_Id numeric,        
 @ST_Date dateTime,        
 @Leave_Status char(1),
 @From_time		time = null,
 @To_time		time = null       
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

   Declare @Emp_Cons Table        
   (        
    Start_Date dateTime,        
    End_Date  DateTime,
    Leave_Period Numeric(18,2),
    Half_Leave_Date DateTime,
    Leave_Assign_As varchar(100)        
   )        
     
   DECLARE @LEAVE_TYPE VARCHAR(50)
   declare @From_Date datetime
   declare @End_date datetime
   declare @Leave_Period numeric(18,2)
   declare @Half_Leave_Date datetime
   

       
   insert into  @Emp_Cons(Start_Date,End_Date , Leave_Period , Half_Leave_Date,Leave_Assign_As)            
         
   -- Declare  @End_Date as dateTime
   
   --Commented By Alpesh 12-Oct-2011        
   --Select From_Date,To_Date from T0130_Leave_Approval_Detail LAD         
   -- left outer join T0120_leave_Approval LA on LAD.Leave_Approval_ID=LA.Leave_Approval_ID         
   -- where LA.Emp_ID =@Emp_ID and LA.Cmp_ID=@Cmp_ID and @ST_Date between From_Date and To_Date and Approval_Status=@Leave_Status and Leave_Period <> 0.5       
      
    --Alpesh 12-Oct-2011  To Update Inout when there is a Half Leave for perticular day  
    --and Leave_Used feild is used to get actual leave count on that day 
    Select From_Date,To_Date , Leave_Period , Half_Leave_Date,LAD.Leave_Assign_As from T0130_Leave_Approval_Detail LAD WITH (NOLOCK)        
    left outer join T0120_leave_Approval LA WITH (NOLOCK) on LAD.Leave_Approval_ID=LA.Leave_Approval_ID
    left outer join T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) on LT.Emp_ID = LA.Emp_ID and LT.For_Date = @ST_Date          
    inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=LT.Leave_ID and LM.Cmp_ID=LT.Cmp_ID --Added by Sumit on 30122016
    where LA.Emp_ID =@Emp_ID and LA.Cmp_ID=@Cmp_ID and 
		 @ST_Date between From_Date and To_Date and 
		 Approval_Status=@Leave_Status and 
		 --LT.Leave_Used <> 0.5      --Comment by Jaina 19-06-2017  
      not exists(select 1 from T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) where  LC.cmp_id=@Cmp_ID and LC.Emp_ID = @Emp_ID and LC.For_Date = @ST_Date and LC.Is_Approve=1) 
     and isnull(LM.Apply_Hourly,0)= 0 --Added by Sumit on 30122016 because If any short leave there we need to allow change In Out from Employee In Out Form 
     
    --select * from @Emp_Cons
    Select  @From_Date = Start_Date,
			@End_date = End_Date, 
			@Leave_Period = Leave_Period,
			@Half_Leave_Date=Half_Leave_Date,
			@Leave_Type = Leave_Assign_As 
	from @Emp_Cons  order by Start_Date    
          
         if @Leave_Type = 'Part Day'
         begin
          set @Leave_Period = @Leave_Period / 0.125
          SET @Half_Leave_Date = NULL
         end
         
          
    IF @Leave_Status = 'A'
	Begin
		
		--For Full Day/ First Half / Second Half Leave Availability 
		begin try
			
			exec P_Check_Leave_Availability @Cmp_Id=@Cmp_Id,@Emp_ID=@Emp_ID,@From_Date=@From_Date,@To_Date=@End_date,@Half_Date=@Half_Leave_Date,@Leave_Type=@Leave_Type,@Raise_Error=1,@From_time=@From_time,@To_time=@To_time,@Leave_Period=@Leave_Period
		end try
		BEGIN catch
			SELECT  'You Can''t do Inout Entry because your Leave Exist.' As [Status]
		end catch
		
	END  
 RETURN        
      
    
  

