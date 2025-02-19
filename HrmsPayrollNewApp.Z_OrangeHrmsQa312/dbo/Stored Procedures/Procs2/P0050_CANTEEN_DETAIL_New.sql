


-- Created by rohit on 01102015
--- Created for Xml Entry Grade Wise.
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_CANTEEN_DETAIL_New]  
@Cmp_ID Numeric(18,0),
@Cnt_ID Numeric(18,0) Output,
@effective_Date Datetime,
@tran_Type varchar(1), 
@XmlDetail xml

AS  

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF OBJECT_ID('tempdb..#temp_Table') IS NOT NULL
BEGIN
	DROP TABLE #temp_Table
END


--CREATE TABLE #Grade
--(
--	Grd_ID numeric,
--	Rate numeric(18,0),
--	Subsidy numeric(18,2),
--	Total_Amount numeric(18,2)
--)


select ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS Row_ID,
	   CanteenDetail.detail.value('(Grd_ID/text())[1]','numeric(18,2)') as Grd_ID, 
       CanteenDetail.detail.value('(Rate/text())[1]','numeric(18,2)') as Rate, 
       CanteenDetail.detail.value('(Subsidy/text())[1]','numeric(18,2)') as Subsidy, 
       CanteenDetail.detail.value('(total_Amount/text())[1]','numeric(18,2)') as Total_Amount
    into #Temptable from @XmlDetail.nodes('/dsDetail/tblDetail') as CanteenDetail(detail)


if (@Tran_Type = 'I' or   @Tran_Type = 'U')
begin  
	Delete from  T0050_CANTEEN_DETAIL where cnt_Id = @Cnt_ID and Cmp_ID = @Cmp_ID  and Effective_Date=@effective_Date
	Declare @tran_Id as numeric(18,0)
	set @tran_Id  = 0
	select @tran_Id = isnull(max(tran_id),0) from T0050_CANTEEN_DETAIL WITH (NOLOCK)
	
	insert into T0050_CANTEEN_DETAIL (Cmp_Id,Cnt_Id,Tran_Id,Effective_Date,Amount,grd_id,Subsidy_Amount,Total_Amount)
	select @Cmp_ID,@Cnt_ID,(@tran_Id + Row_ID),@effective_Date,rate,grd_id,Subsidy,Total_Amount from #Temptable
	
end

if @Tran_Type = 'D'  
 Begin  
	Delete from  T0050_CANTEEN_DETAIL where @cnt_Id = @Cnt_ID and Cmp_ID = @Cmp_ID  
 End  
  
RETURN  
  



