



---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Sp_AdminPage_details]

	 @Sal_Exp_Id 		numeric(18) output
	,@Cmp_Id 		numeric(18)
	,@Vch_No		numeric(18)
	,@Vch_Type  		varchar(50)
	,@Month_Date 		datetime
	,@Vch_comments 	varchar(100)
	 ,@Trans_Type 		char
 AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	if @Trans_Type ='i' 
		begin

	                      if exists (Select Sal_Exp_Id  from t9999_salary_export WITH (NOLOCK)) 

				begin 
		                    set @Sal_Exp_Id = 0
				end
			else
				begin
					select @Sal_Exp_Id = isnull(max(Sal_Exp_Id),0) from t9999_salary_export WITH (NOLOCK)
					if @Sal_Exp_Id is null or @Sal_Exp_Id = 0
						set @Sal_Exp_Id =1
					else
						set @Sal_Exp_Id = @Sal_Exp_Id + 1			
						
					insert into t9999_salary_export(Sal_Exp_Id, Cmp_Id , Vch_No,Vch_Type, Vch_Date, Month_Date, Vch_comments)

					 values(@Sal_Exp_Id, @Cmp_Id ,  @Vch_No, @Vch_Type,  getdate(),  @Month_Date,@Vch_comments)
					
				end
		end 
	else if @Trans_Type ='u' 
		begin
			
				begin
					Update t9999_salary_export Set Vch_No = @Vch_No , Vch_Type = @Vch_Type ,  Month_Date =  @Month_Date,  Vch_comments = @Vch_comments where @Sal_Exp_Id = @Sal_Exp_Id 

				end
		end	
	else if 
	@Trans_Type ='d' or @Trans_Type ='D'
			delete  from t9999_salary_export where Sal_Exp_Id = @Sal_Exp_Id 
			

	RETURN




