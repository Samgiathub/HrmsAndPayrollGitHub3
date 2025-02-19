



--zalak for get emp lta medical d etail of financial year
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EMP_LTA_Medical_Detail]
	 @LM_ID	numeric(18, 0)	output
	,@Cmp_ID	numeric(18, 0)	
	,@Emp_ID	numeric(18, 0)	
	,@From_Date	datetime	
	,@To_Date	datetime	
	,@Mode		char(1)	
	,@Amount	numeric(18, 2)	
	,@Type_ID	int
	,@Carry_fw_amount	numeric(18, 2)	
	,@no_IT_claims	int	
	,@tran_type varchar(1)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		If @tran_type  = 'I' 
			Begin
				If Exists(select LM_ID From T0100_EMP_LTA_Medical_Detail  WITH (NOLOCK) Where cmp_ID = @Cmp_ID and
									Emp_ID = @Emp_ID  and type_id=@type_id and
							((@From_Date >= from_date and @From_Date <= to_date) or 
		
							(@To_Date >= from_date and 	@To_Date <= to_date) or 
							(from_date >= @From_Date and from_date <= @To_Date) or
							(to_date >= @From_Date and to_date <= @To_Date)))
					Begin
						select @LM_ID =LM_ID From T0100_EMP_LTA_Medical_Detail WITH (NOLOCK) Where cmp_ID = @Cmp_ID and
									Emp_ID = @Emp_ID  and type_id=@type_id and
							((@From_Date >= from_date and @From_Date <= to_date) or 
		
							(@To_Date >= from_date and 	@To_Date <= to_date) or 
							(from_date >= @From_Date and from_date <= @To_Date) or
							(to_date >= @From_Date and to_date <= @To_Date))
							
						Update T0100_EMP_LTA_Medical_Detail
						 set 
							Mode=@Mode
						   ,Amount=@Amount
						   ,Carry_fw_amount=@Carry_fw_amount
				           ,no_IT_claims=@no_IT_claims
							where LM_ID = @LM_ID
						Return 
					end
	
				select @LM_ID = Isnull(max(LM_ID),0) + 1 	From T0100_EMP_LTA_Medical_Detail WITH (NOLOCK)
				
				INSERT INTO T0100_EMP_LTA_Medical_Detail
				                      (
										     LM_ID
											,Cmp_ID
											,Emp_ID
											,From_Date
											,To_Date
											,Mode
											,Amount
											,Type_ID
											,Carry_fw_amount
											,no_IT_claims
									 )
								VALUES     
								(
									         @LM_ID
											,@Cmp_ID
											,@Emp_ID
											,@From_Date
											,@To_Date
											,@Mode
											,@Amount
											,@Type_ID
											,@Carry_fw_amount
											,@no_IT_claims
								)
				End
	Else if @Tran_Type = 'U' 
		begin
				Update T0100_EMP_LTA_Medical_Detail
				set 
							Mode=@Mode
						   ,Amount=@Amount
						   ,Carry_fw_amount=@Carry_fw_amount
				           ,no_IT_claims=@no_IT_claims
				where Emp_ID = @Emp_ID  and type_id=@type_id and From_Date=@From_Date and To_Date=@To_Date
		end
	Else if @Tran_Type = 'D' 
		begin
				delete T0240_LTA_Medical_Transaction where isnull(sal_tran_id,0)=0
				If not Exists(select LM_Tran_ID From T0240_LTA_Medical_Transaction  WITH (NOLOCK) Where cmp_ID = @Cmp_ID and
									Emp_ID = @Emp_ID  and
							((@From_Date >= for_date and @From_Date <= for_date) or 
							(@To_Date >= for_date and 	@To_Date <= for_date) or 
							(for_date >= @From_Date and for_date <= @To_Date) or
							(for_date >= @From_Date and for_date <= @To_Date)))
					begin
						Delete From T0100_EMP_LTA_Medical_Detail Where LM_ID  = @LM_ID
					end
		end
	RETURN



