



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0011_COMPANY_MD_DETAIL]
	@MD_ID			AS NUMERIC output,
	@CMP_ID			AS NUMERIC,
	@MD_Name		AS VARCHAR(100),
	@MD_Designation AS VARCHAR(30),
	@MD_Street1		AS VARCHAR(50),
	@MD_Street2		AS VARCHAR(50),
	@MD_Street3		AS VARCHAR(50),
	@MD_City		AS VARCHAR(30),
	@MD_State		AS VARCHAR(30),
	@MD_Pincode		AS VARCHAR(30),
	@MD_Tel_Phone	AS VARCHAR(50),
	@MD_Email		AS VARCHAR(100),
	@MD_Share		AS NUMERIC(5,2),
	@MD_Type		AS TINYINT,
	@tran_type as varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @tran_type  = 'I'
		Begin
			if exists(select MD_ID from t0011_company_md_detail WITH (NOLOCK) where upper(MD_Name) = upper(@MD_Name) and Cmp_ID = @Cmp_ID and MD_Designation = @MD_Designation)
				begin
					set @MD_ID = 0
					Return 
				end

				select @MD_ID = Isnull(max(MD_ID),0) + 1 	From t0011_company_md_detail WITH (NOLOCK)
				
				INSERT INTO t0011_company_md_detail
				                      (MD_ID, Cmp_ID, MD_Name,MD_Designation,MD_Street_1,MD_Street_2,MD_Street_3,MD_City,MD_State,MD_Pin_Code,MD_Tel_No,MD_Email,MD_Share,MD_Type)
				VALUES					(@MD_ID, @Cmp_ID, @MD_Name,@MD_Designation,@MD_Street1,@MD_Street2,@MD_Street3,@MD_City,@MD_State,@MD_Pincode,@MD_Tel_Phone,@MD_Email,@MD_Share,@MD_Type)
		End
	Else if @Tran_Type = 'U'

		begin
				If exists(select MD_ID from t0011_company_md_detail WITH (NOLOCK) where upper(MD_Name) = upper(@MD_Name) and MD_ID <> @MD_ID and MD_Designation = @MD_Designation
								and Cmp_ID = @Cmp_ID )
					begin
						set @MD_ID = 0
						Return 
					end
					
				Update t0011_company_md_detail
				set MD_Name=@MD_Name,
					MD_Designation=@MD_Designation,
					MD_Street_1=@MD_Street1,
					MD_Street_2=@MD_Street2,
					MD_Street_3=@MD_Street3,
					MD_City=@MD_City,
					MD_State=@MD_State,
					MD_Pin_Code=@MD_Pincode,
					MD_Tel_No=@MD_Tel_Phone,
					MD_Email=@MD_Email,
					MD_Share=@MD_Share,
					MD_Type=@MD_Type
				where MD_ID = @MD_ID
		End
	Else if @Tran_Type = 'D'
		begin
				Delete From t0011_company_md_detail Where MD_ID = @MD_ID
		end

	RETURN




