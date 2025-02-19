


---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_IT_Acknowledge_No]
     @Row_ID 	numeric(18,0)=0  
	,@Cmp_ID 	numeric(18,0)
	,@LoginID 	numeric(18,0)
    ,@TranID 	numeric(18,0)
    ,@Financial_Year 	nvarchar(50)=''
	,@First_Qaur_No 	nvarchar(200)=''
	,@Second_Qaur_No 	nvarchar(200)=''
	,@Third_Qaur_No 	nvarchar(200)=''
	,@Fourth_Qaur_No 	nvarchar(200)=''
	,@Sys_Date 		datetime=''
	,@Type 		varchar(20)=''
	 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    if(@Type='Select')
     begin
      declare @tblAck table(Tmp_RowNO numeric(18,0) identity,Row_ID numeric(18,0),Login_Id numeric(18,0),Transaction_Id numeric(18,0),Qaurter_Name nvarchar(200),Qaurter_No nvarchar(200)) 
      if exists(select 1 from T0250_IT_Acknowledge_No WITH (NOLOCK) where Cmp_Id=@Cmp_ID  and  Financial_Year=@Financial_Year )
       begin
		  insert into @tblAck(Row_ID,Login_Id,Transaction_Id,Qaurter_Name,Qaurter_No) select Row_Id,@LoginID,Transaction_Id,'First Quarter',isnull(First_Qaurter_No,'')   -- Changed by Gadriwala Muslim 26-Jun-2015 Spelling Mistak First Qaurter to First Quarter
		  from T0250_IT_Acknowledge_No where Cmp_Id=@Cmp_ID and Financial_Year=@Financial_Year  --and isnull(First_Qaurter_No,'')<>''
		  insert into @tblAck(Row_ID,Login_Id,Transaction_Id,Qaurter_Name,Qaurter_No) select Row_Id,@LoginID,Transaction_Id,'Second Quarter',isnull(Second_Qaurter_No,'')  -- Changed by Gadriwala Muslim 26-Jun-2015 Spelling Mistak First Qaurter to First Quarter
		  from T0250_IT_Acknowledge_No where Cmp_Id=@Cmp_ID and Financial_Year=@Financial_Year --and isnull(Second_Qaurter_No,'')<>''
		  insert into @tblAck(Row_ID,Login_Id,Transaction_Id,Qaurter_Name,Qaurter_No) select Row_Id,@LoginID,Transaction_Id,'Third Quarter',isnull(Third_Qaurter_No,'')  -- Changed by Gadriwala Muslim 26-Jun-2015 Spelling Mistak First Qaurter to First Quarter
		  from T0250_IT_Acknowledge_No where Cmp_Id=@Cmp_ID and Financial_Year=@Financial_Year --and isnull(Third_Qaurter_No,'')<>''
		  insert into @tblAck(Row_ID,Login_Id,Transaction_Id,Qaurter_Name,Qaurter_No) select Row_Id,@LoginID,Transaction_Id,'Fourth Quarter',isnull(Fourth_Qaurter_No,'')  -- Changed by Gadriwala Muslim 26-Jun-2015 Spelling Mistak First Qaurter to First Quarter
		  from T0250_IT_Acknowledge_No where Cmp_Id=@Cmp_ID and Financial_Year=@Financial_Year --and isnull(Fourth_Qaurter_No,'')<>'' 
       end
      else
        begin
          insert into @tblAck(Row_ID,Login_Id,Transaction_Id,Qaurter_Name,Qaurter_No) select 0,@LoginID,0,'First Quarter',''   -- Changed by Gadriwala Muslim 26-Jun-2015 Spelling Mistak First Qaurter to First Quarter
		  insert into @tblAck(Row_ID,Login_Id,Transaction_Id,Qaurter_Name,Qaurter_No) select 0,@LoginID,0,'Second Quarter',''  -- Changed by Gadriwala Muslim 26-Jun-2015 Spelling Mistak First Qaurter to First Quarter
		  insert into @tblAck(Row_ID,Login_Id,Transaction_Id,Qaurter_Name,Qaurter_No) select 0,@LoginID,0,'Third Quarter',''    -- Changed by Gadriwala Muslim 26-Jun-2015 Spelling Mistak First Qaurter to First Quarter
		  insert into @tblAck(Row_ID,Login_Id,Transaction_Id,Qaurter_Name,Qaurter_No) select 0,@LoginID,0,'Fourth Quarter',''   -- Changed by Gadriwala Muslim 26-Jun-2015 Spelling Mistak First Qaurter to First Quarter
		   
      end
      select Tmp_RowNO,Row_ID,Login_Id,Transaction_Id,Qaurter_Name,Qaurter_No from @tblAck
     end
	
	
					
	RETURN 




