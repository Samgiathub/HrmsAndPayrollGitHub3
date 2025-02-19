



---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_Acknowledge_No_Insert]  
     @Row_ID 	numeric(18,0) =0 output 
    ,@Cmp_ID 	numeric(18,0)
	,@LoginID 	numeric(18,0)
	,@Transaction_Id numeric(18,0)
    ,@Financial_Year 	nvarchar(50)=''
	,@str_Qaur 	nvarchar(max)=''
	,@Sys_Date 		datetime=''
  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @TranID numeric(18,0)
	declare @First_Qaur_No nvarchar(200)
	declare @Second_Qaur_No nvarchar(200)
	declare @Third_Qaur_No nvarchar(200)
	declare @Fourth_Qaur_No nvarchar(200)
	
	set @TranID =0
	set @First_Qaur_No=''
	set @Second_Qaur_No=''
	set @Third_Qaur_No=''
	set @Fourth_Qaur_No=''

    
   select  @First_Qaur_No=cast(data  as nvarchar(250))  from dbo.Split (@str_Qaur,'@') where ID=1
   select  @Second_Qaur_No=cast(data  as nvarchar(250)) from dbo.Split (@str_Qaur,'@') where ID=2
   select  @Third_Qaur_No=cast(data  as nvarchar(250)) from dbo.Split (@str_Qaur,'@') where ID=3
   select  @Fourth_Qaur_No=cast(data  as nvarchar(250)) from dbo.Split (@str_Qaur,'@') where ID=4
  
   if not exists(select 1 from T0250_IT_Acknowledge_No WITH (NOLOCK) where Cmp_Id=@Cmp_ID and Financial_Year=@Financial_Year)
    begin
        insert into T0250_IT_Acknowledge_No
        (Cmp_Id,Login_Id,Transaction_Id,Financial_Year,First_Qaurter_No,Second_Qaurter_No,Third_Qaurter_No,Fourth_Qaurter_No,Sysdate)
        values(@Cmp_ID,@LoginID,@Transaction_Id,@Financial_Year,@First_Qaur_No,@Second_Qaur_No,@Third_Qaur_No,@Fourth_Qaur_No,@Sys_Date)
        set @Row_ID=1
    end
  else if exists(select 1 from T0250_IT_Acknowledge_No WITH (NOLOCK) where Cmp_Id=@Cmp_ID and Financial_Year=@Financial_Year )
    begin
       update T0250_IT_Acknowledge_No set 
		   Login_Id=@LoginID,
		   --Transaction_Id=@Transaction_Id,
		   First_Qaurter_No=@First_Qaur_No,
		   Second_Qaurter_No=@Second_Qaur_No,
		   Third_Qaurter_No=@Third_Qaur_No,
		   Fourth_Qaurter_No=@Fourth_Qaur_No,
		   Sysdate=@Sys_Date
       where Cmp_Id=@Cmp_ID and Financial_Year=@Financial_Year
       set @Row_ID=2
       
    end
   else 
       set @Row_ID=0
      
  
    --select GETDATE()   
      --end
    
    
 -- End  
  



