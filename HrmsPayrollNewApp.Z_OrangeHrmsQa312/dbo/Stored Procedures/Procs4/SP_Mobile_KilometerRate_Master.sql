-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 08/09/2023
-- Description:	To Get Kilometer Rate Master Data
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_KilometerRate_Master]
	@Cmp_ID NUMERIC(18,0),
	@Emp_Category nvarchar(50),
	@Vehicle_Type nvarchar(50)
	--@Effective_Date nvarchar(20) = ''
AS
BEGIN
	Select top 1 KR_Id,Cmp_ID,Effective_Date,Emp_Category,Vehicle_Type,RatePer_Km,Created_By,Created_Date 
		from T0040_KilometerRate_Master		
		where Cmp_ID = @Cmp_ID
		and	Emp_Category = @Emp_Category
		and Vehicle_Type = @Vehicle_Type
		and CONVERT(varchar, Effective_Date, 112) <= CONVERT(varchar,GETDATE(), 112)
	order by Created_Date desc
		--group by KR_Id,Cmp_ID,Emp_Category,Vehicle_Type,RatePer_Km,Created_By,Created_Date
		--order by KR_Id desc
		
END
