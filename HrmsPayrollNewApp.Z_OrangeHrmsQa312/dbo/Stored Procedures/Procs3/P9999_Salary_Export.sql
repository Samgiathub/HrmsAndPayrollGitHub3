



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_Salary_Export]
	 @Sal_Exp_Id 		numeric(18) output
	,@Cmp_Id 			numeric(18)
	,@Vch_No			numeric(18)	output
	,@Vch_type  		varchar(50)
	,@Month_Date 		datetime
	,@Vch_Comments 		varchar(100)
	,@Trans_Type 		char(1)
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Trans_Type ='I' 
		begin

			if exists (Select Sal_Exp_Id  from T9999_Salary_Export WITH (NOLOCK) Where Vch_No = @Vch_No and Cmp_ID = @Cmp_ID) 
				begin
					set @Sal_Exp_Id = 0
				end
			else
				begin

		
					select @Sal_Exp_Id =  Isnull(max(Sal_Exp_Id),0) + 1  from T9999_Salary_Export WITH (NOLOCK)
					
					insert into T9999_Salary_Export(Sal_Exp_Id, Cmp_Id , Vch_No, Vch_Type,  Vch_Date, Month_Date, Vch_Comments)

					 values(@Sal_Exp_Id, @Cmp_Id , @Vch_No , @Vch_Type, getdate(), @Month_Date, @Vch_Comments)
					 					
			end
		end
	else if @Trans_Type ='u' 
		begin
				Update T9999_Salary_Export Set  Month_Date = @Month_Date , Vch_Comments = @Vch_Comments  where Sal_Exp_Id = @Sal_Exp_Id 
		end	
	else if @Trans_Type ='d' 
		begin
		
			delete  from T9999_Salary_Export_detail where Sal_Exp_Id = @Sal_Exp_Id 

			delete  from T9999_Salary_Export where Sal_Exp_Id = @Sal_Exp_Id 
			
		end
			

	RETURN




