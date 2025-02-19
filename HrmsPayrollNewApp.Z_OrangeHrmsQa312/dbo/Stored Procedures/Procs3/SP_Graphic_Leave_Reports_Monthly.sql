
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Graphic_Leave_Reports_Monthly]        
  @Cmp_ID  numeric        
 ,@From_Date Datetime        
 ,@To_Date  Datetime        
 ,@Emp_ID  numeric      
 ,@Type   numeric=0      
 ,@Month  numeric      
 ,@Year   numeric      
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    
       
      
              
 Declare @Emp_leave Table      
 (      
  leave_name nvarchar(50),      
  leave_code nvarchar(10),      
  leave_opening numeric(5,2),      
  leave_credit numeric(5,2),      
  leave_used numeric(5,2),      
  leave_remain numeric(5,2),      
  Emp_id numeric      
 )      
      
 declare @leaveid numeric      
        
 declare @leave_name nvarchar(50)      
 declare @leave_code nvarchar(10)      
 declare @leave_opening numeric(5,2)      
 declare @leave_remain numeric(5,2)      
 declare @leave_used numeric(5,2)      
 declare @leave_credit nvarchar(50)      
      
 declare @Max_ForDate datetime  -- Added by mihir 13012012      
          
 set @leave_name = 0      
 set @leave_code = 0      
 --set @leave_opening = 0  
 --set @leave_remain = 0  
 set @leave_used = 0      
 set @leave_credit = 0      
      
     
 DECLARE @Leave_Bal_Display_FixOpening NUMERIC /*TMS - For Electrothem requirement  (Email Dated :  Apr 12, 2016) --Ankit 12042016 */
 SELECT @Leave_Bal_Display_FixOpening = Leave_Balance_Display_FixOpening FROM T0010_COMPANY_MASTER WITH (NOLOCK) WHERE Cmp_Id = @cmp_Id
 DECLARE @Leave_Opening_First	NUMERIC(18,2)
 SET @Leave_Opening_First = 0
 DECLARE @TMS_Module NUMERIC
 SET @TMS_Module = 1 -- 0 For TMS,
 SELECT @TMS_Module = module_status FROM T0011_module_detail WITH (NOLOCK) WHERE module_name = 'Payroll' AND Cmp_id = @Cmp_ID 
      
  declare Cur_Allow   cursor for      
  select lt.leave_id from T0140_LEave_Transaction lt WITH (NOLOCK) inner join t0040_leave_master lm WITH (NOLOCK) on lt.Leave_Id=lm.Leave_Id  and isnull(Lm.Default_Short_Name,'') <> 'COMP'     -- Changed by Gadriwala Muslim 01102014    
  where lt.cmp_id=@Cmp_ID and lt.Emp_ID = @Emp_ID and lm.Display_leave_balance =1 group by lt.Leave_ID       
  open cur_allow      
  fetch next from cur_allow  into @leaveid      
  while @@fetch_status = 0      
   begin      
        IF @Leave_Bal_Display_FixOpening = 1 AND @TMS_Module = 0	
			BEGIN
				
				--SELECT @Leave_Opening_First = ISNULL(leave_negative_max_limit,0) FROM T0040_LEAVE_MASTER WHERE Cmp_ID = @Cmp_ID AND Leave_ID = @leaveid
				SELECT TOP 1 @Leave_Opening_First = ISNULL(Leave_Opening,0) FROM T0140_LEave_Transaction WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND leave_id = @leaveid AND YEar(FOR_DATE) = YEAR(dbo.GET_MONTH_ST_DATE(@Month,@Year))  ORDER BY For_Date ASC
			
				select @leave_used = isnull(SUM(leave_used),0)  + ISNULL(Sum(Back_Dated_Leave),0) --added by jimit 01122016
						,@leave_credit =isnull(SUM(Leave_Credit),0) 
				from T0140_LEave_Transaction WITH (NOLOCK)
				where Emp_ID = @Emp_ID and leave_id = @leaveid and MONTH(For_Date) <= @Month AND YEAR(FOR_DATE) <= @Year
						AND YEAR(FOR_DATE) >= Year(@To_Date) --Privious Month Credited and Used all leave
				
				select @leave_code = Leave_Code,@leave_name = Leave_Name from T0040_Leave_Master WITH (NOLOCK) where Leave_ID = @leaveid      
			          
				If isnull(@leave_opening,999) = 999    
				 select top 1 @leave_opening = isnull(Leave_Closing,0) from T0140_LEave_Transaction WITH (NOLOCK) where Emp_ID = @Emp_ID and leave_id = @leaveid and For_Date < dbo.GET_MONTH_ST_DATE(@Month,@Year)  
					And (Leave_Opening >0 or Leave_Credit >0 or Leave_Used > 0 or Leave_Closing > 0) order by For_Date desc      
			           
				If isnull(@leave_remain,999) = 999    
					select top 1 @leave_remain = Leave_Closing  
					from	T0140_LEave_Transaction WITH (NOLOCK) where Emp_ID = @Emp_ID and leave_id = @leaveid and For_Date <= dbo.GET_MONTH_END_DATE(@Month,@Year) 
					--and Leave_Closing > 0 
					order by For_Date desc      
			    
			    SET @leave_remain =  ISNULL(@leave_credit,0) - ISNULL(@leave_used,0)
			      
				insert into @Emp_leave       
				select @leave_name,@leave_code,isnull(@Leave_Opening_First,0),isnull(@leave_credit,0),isnull(@leave_used,0),isnull(@leave_remain,0),@Emp_ID      
    
			END
		ELSE
			BEGIN	
				
				select @leave_used = isnull(SUM(leave_used),0) + ISNULL(Sum(Back_Dated_Leave),0) --added by jimit 01122016
						,@leave_credit =isnull(SUM(Leave_Credit),0) from T0140_LEave_Transaction WITH (NOLOCK) where Emp_ID = @Emp_ID and leave_id = @leaveid and MONTH(For_Date) = @Month AND YEAR(FOR_DATE) = @Year      
				select top 1 @leave_opening = Leave_Opening from T0140_LEave_Transaction WITH (NOLOCK) where Emp_ID = @Emp_ID and leave_id = @leaveid and MONTH(For_Date) = @Month AND YEAR(FOR_DATE) = @Year order by For_Date      
				select top 1 @leave_remain = Leave_Closing from T0140_LEave_Transaction WITH (NOLOCK) where Emp_ID = @Emp_ID and leave_id = @leaveid and MONTH(For_Date) = @Month AND YEAR(FOR_DATE) = @Year order by For_Date desc      
				select @leave_code = Leave_Code,@leave_name = Leave_Name from T0040_Leave_Master WITH (NOLOCK) where Leave_ID = @leaveid      
			    
				If isnull(@leave_opening,999) = 999    
				 select top 1 @leave_opening = isnull(Leave_Closing,0) from T0140_LEave_Transaction WITH (NOLOCK) where Emp_ID = @Emp_ID and leave_id = @leaveid and For_Date < dbo.GET_MONTH_ST_DATE(@Month,@Year)  
					And (Leave_Opening >0 or Leave_Credit >0 or Leave_Used > 0 or Leave_Closing > 0) order by For_Date desc      
			        
				If isnull(@leave_remain,999) = 999    
					select	top 1 @leave_remain = Leave_Closing  
					from	T0140_LEave_Transaction WITH (NOLOCK)
					where	Emp_ID = @Emp_ID and leave_id = @leaveid 
							and For_Date <= dbo.GET_MONTH_END_DATE(@Month,@Year) --and Leave_Closing > 0 
							order by For_Date desc      
			 
				insert into @Emp_leave       
				select @leave_name,@leave_code,isnull(@leave_opening,0),isnull(@leave_credit,0),isnull(@leave_used,0),isnull(@leave_remain,0),@Emp_ID      
    
			END	
          
    set @leave_opening = null  
    set @leave_credit = 0      
    set @leave_used = 0      
    set @leave_remain = NUll  
          
    fetch next from cur_allow  into @leaveid      
   end      
  close cur_Allow      
  deallocate Cur_Allow      
         
               
    select * from @Emp_leave       
             
 RETURN      
      
      


