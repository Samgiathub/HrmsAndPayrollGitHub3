



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_MinimumWages_Master]
	@Wages_id AS NUMERIC output,
	@CMP_ID AS NUMERIC,
	@State_ID AS Numeric,
	@SkillType_ID as Numeric,	
	@Wages_Value as Numeric(18,2),
	@Effective_Date as Datetime, 
	@tran_type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @tran_type  = 'I'
		Begin
				
				select @Wages_id = Isnull(max(Wages_ID),0) + 1 	From T0050_Minimum_Wages_Master WITH (NOLOCK)
				
				INSERT INTO T0050_Minimum_Wages_Master(Wages_ID,cmp_ID,State_ID,skilltype_ID,Wages_Value,Effective_Date)
				                      
				VALUES     (@Wages_id,@CMP_ID,@State_ID,@SkillType_ID,@Wages_Value,@Effective_Date)
		End
	Else if @Tran_Type = 'U'
		begin
				If Exists(Select Wages_ID From T0050_Minimum_Wages_Master WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and Wages_ID <> @Wages_id) 
					begin
						set @Wages_ID = 0
						Return 
					end

				Update T0050_Minimum_Wages_Master
				set State_ID=@State_ID
				    ,SkillType_ID=@SkillType_ID
				    ,Wages_Value = @Wages_Value
				    ,Effective_Date = @Effective_Date
				where Wages_ID = @Wages_id
				
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0050_Minimum_Wages_Master Where State_ID = @State_ID and Replace(Convert(varchar(25),Effective_Date,103),' ','/') = REPLACE(Convert(varchar(25),@Effective_Date,103),' ','/')
		end

	RETURN




