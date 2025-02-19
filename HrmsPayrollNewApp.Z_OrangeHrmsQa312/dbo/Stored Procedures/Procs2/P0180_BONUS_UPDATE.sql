
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0180_BONUS_UPDATE]
		@Bonus_ID	numeric(18, 0) output
		,@Cmp_ID	numeric(18, 0)
		,@Emp_ID	numeric(18, 0)
		,@From_Date	datetime
		,@To_Date	datetime
		,@Bonus_Calculated_On	varchar(20)
		,@Bonus_Percentage	numeric(18, 2)
		,@Bonus_Fix_Amount	numeric(18, 0)
		,@Bonus_Effect_on_Sal	numeric(18, 0)
		,@Bonus_Effect_Month	numeric(18, 0)
		,@Bonus_Effect_Year	numeric(18, 0)
		,@Bonus_Comments	varchar(250)
		,@tran_type varchar(1)
		,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016
		,@IP_Address varchar(30)= '' -- Add By Mukti 11072016 
 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Bonus_Amount as 	numeric(18, 0)
	DECLARE @Bonus_Calculated_Amount as numeric(18, 0)
     
    -- Add By Mukti 11072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
	-- Add By Mukti 11072016(end)
		begin
			
					If exists(select Bonus_ID From T0180_BONUS WITH (NOLOCK) where Cmp_ID = @Cmp_ID and emp_ID = @EMP_ID and from_date = @From_Date and to_date = @To_Date)
					begin
							select @BONUS_ID = Bonus_ID From T0180_BONUS WITH (NOLOCK) where Cmp_ID = @Cmp_ID and emp_ID = @EMP_ID and from_date = @From_Date and to_date = @To_Date
							
																			
							IF @Bonus_Calculated_On ='Basic'
							BEGIN
							select @Bonus_Calculated_Amount = isnull(sum(basic_salary) ,0) from t0200_MONTHLY_SALARY WITH (NOLOCK) where cmp_id=@Cmp_ID and emp_id=@Emp_ID and month_st_date >= @From_Date and month_end_date <=@To_Date
							SET @Bonus_Amount = ((@Bonus_Calculated_Amount * @Bonus_Percentage )/100)
							END
							ELSE IF @Bonus_Calculated_On ='Gross'
							BEGIN
								select @Bonus_Calculated_Amount = isnull(sum(GROSS_salary) ,0) from t0200_MONTHLY_SALARY WITH (NOLOCK) where cmp_id=@Cmp_ID and emp_id=@Emp_ID and month_st_date >= @From_Date and month_end_date <=@To_Date
								SET @Bonus_Amount = ((@Bonus_Calculated_Amount * @Bonus_Percentage )/100)
							END
					ELSE
						BEGIN
							SET @Bonus_Calculated_Amount = 0
							SET @Bonus_Amount = @Bonus_Fix_Amount
						END
					
					DELETE FROM T0190_BONUS_DETAIL WHERE BONUS_ID = @BONUS_ID
					
					-- Add By Mukti 11072016(start)
						exec P9999_Audit_get @table='T0180_BONUS' ,@key_column='Bonus_ID',@key_Values=@Bonus_ID,@String=@String_val output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
					-- Add By Mukti 11072016(end)
			
					UPDATE  T0180_BONUS
						SET        
										From_Date = @From_Date
										,To_Date = @To_Date
										,Bonus_Calculated_On = @Bonus_Calculated_On
										,Bonus_Percentage = @Bonus_Percentage
										,Bonus_Amount = @Bonus_Amount
										,Bonus_Fix_Amount = @Bonus_Fix_Amount
										,Bonus_Effect_on_Sal = @Bonus_Effect_on_Sal
										,Bonus_Effect_Month = @Bonus_Effect_Month 
										,Bonus_Effect_Year = @Bonus_Effect_Year
										,Bonus_Comments = @Bonus_Comments
				         where Bonus_ID = @Bonus_ID and CMP_ID = @CMP_ID and EMP_ID =@EMP_ID	
				            
				        -- Add By Mukti 11072016(start)
							exec P9999_Audit_get @table = 'T0180_BONUS' ,@key_column='Bonus_ID',@key_Values=@Bonus_ID,@String=@String_val output
							set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
						-- Add By Mukti 11072016(end)        
						end
				else
					BEGIN
						set @Bonus_ID = 0
						return
					END
		exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Bonus Details',@OldValue,@Emp_ID,@User_Id,@IP_Address,1	
end




