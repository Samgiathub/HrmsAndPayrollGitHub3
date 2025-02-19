
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_Quarter_Details]
	 @Qtr_ID		as	numeric(18,0) Output
	,@Cmp_ID			as	numeric(18,0)
	,@Qtr_Name as	varchar(150)
	,@From_Month  as	int
	,@To_Month  as	int
	,@Effective_Date	as	datetime	
	,@tran_type			as	varchar(1) 
	,@User_Id			as	numeric(18,0) = 0
	,@IP_Address		as	varchar(30)= '' 
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		
	If Upper(@tran_type) ='I' --Or Upper(@tran_type) ='U'
		Begin
			If @Qtr_Name = ''
				BEGIN
					SET @Qtr_ID=0
					Return
				END
			if exists(select 1 from T0040_Quarter_Details WITH (NOLOCK) where Qtr_Name =@Qtr_Name and Cmp_ID=@Cmp_ID and From_Month=@From_Month AND To_Month=@To_Month and Effective_Date = @Effective_Date)--added effective date 19 sep 2016
				begin
					SET @Qtr_ID= 0 						
					Return
				End
			if exists(select 1 from T0040_Quarter_Details WITH (NOLOCK) where Qtr_Name =@Qtr_Name and Cmp_ID=@Cmp_ID and (From_Month=@From_Month or To_Month=@To_Month) and Effective_Date = @Effective_Date)--added effective date 19 sep 2016
				begin
					SET @Qtr_ID= 0 						
					Return
				End
		End
	If Upper(@tran_type) ='I'	
		Begin
			select @Qtr_ID = isnull(max(Qtr_ID),0) + 1 from T0040_Quarter_Details WITH (NOLOCK)
			INSERT INTO T0040_Quarter_Details
			(
				Qtr_ID,Cmp_ID,Effective_date,Qtr_Name,From_Month,To_Month
			)
			VAlUES
			(
				@Qtr_ID,@Cmp_ID,@Effective_date,@Qtr_Name,@From_Month,@To_Month
			)
		End
	Else If  Upper(@tran_type) ='U' 
		Begin
			UPDATE    T0040_Quarter_Details
			SET       Qtr_Name = @Qtr_Name,
					  From_Month = @From_Month,
					  To_Month = @To_Month,
					  Effective_Date = @Effective_Date
			WHERE     Qtr_ID  = @Qtr_ID
		
		End
	Else If  Upper(@tran_type) ='D'
		Begin		
			DELETE FROM T0040_Quarter_Details WHERE Qtr_ID = @Qtr_ID					
			
		End

--return	@Qtr_ID	
END
-------------
