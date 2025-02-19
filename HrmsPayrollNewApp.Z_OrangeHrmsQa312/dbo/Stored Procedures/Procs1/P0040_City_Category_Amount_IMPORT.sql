

CREATE PROCEDURE [dbo].[P0040_City_Category_Amount_IMPORT] 
	 @Cmp_Id		NUMERIC(18,0)
	,@Expense_Name   VARCHAR(100)		
	,@Category_Name   VARCHAR(100)
	,@Amount   numeric(18,2)	
	,@Effect_Date	Datetime
	,@Flag_grd_desig int
	,@Grade_Desig varchar(100)
	,@Row_No		INT = 0
	,@Log_Status	INT = 0 OUTPUT
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	DECLARE @Tran_ID	AS NUMERIC(18,0)
	DECLARE @Grd_Desig_ID as Numeric(18,0)	
	DECLARE @Expense_type_ID AS NUMERIC(18,0)
    declare @City_Cat_ID as numeric(18,0)
    
    Set @Tran_ID = 0
    Set @Expense_type_ID = 0
	set @Grd_Desig_ID=0
	set @City_Cat_ID=0
	
	if @Flag_grd_desig=1
	begin	
	select @Grd_Desig_ID=ISNULL(Grd_Id,0) from t0040_grade_master WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Grd_Name=@Grade_Desig		
	end
	else if @Flag_grd_desig=0
	begin
	select @Grd_Desig_ID=ISNULL(Desig_Id,0) from T0040_DESIGNATION_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	and Desig_Name=@Grade_Desig
	end
	
	select @City_Cat_ID=ISNULL(city_cat_ID,0) from T0040_City_Category_Master WITH (NOLOCK) where Cmp_ID=@Cmp_Id and City_Cat_Name=@Category_Name
	select @Expense_type_ID=isnull(Expense_type_id,0) from T0040_Expense_Type_Master WITH (NOLOCK) where CMP_ID=@Cmp_Id and Expense_Type_name=@Expense_Name
		
   
   if ISNULL(@Expense_type_ID,0)=0
   begin
			select @Expense_Type_ID = isnull(max(Expense_Type_ID),0) + 1 from T0040_Expense_Type_Master WITH (NOLOCK)

				INSERT INTO T0040_Expense_Type_Master
				                      (Expense_Type_ID, Expense_Type_name, Expense_Type_Group, Grade_Id_Multi,CMP_ID,Grade_Wise_ExAmount,Display_FromTime)
				VALUES     (@Expense_Type_ID,@Expense_Name,@Expense_Name +'_grp', '1',@CMP_ID,@Flag_grd_desig,0)	
   
   end
    --SELECT @Scheme_ID = ISNULL(Scheme_Id,0) FROM T0040_Scheme_Master WHERE Scheme_Name = @Scheme_Name and Scheme_Type = @Scheme_Type AND cmp_id = @cmp_id
    --SELECT @Emp_ID = ISNULL(EMP_ID,0) FROM t0080_EMP_MASTER WHERE Alpha_Emp_Code = @EMP_CODE AND cmp_id = @cmp_id
    
	
    IF isnull(@Grd_Desig_ID,0) = 0 
	BEGIN
		SET @Log_Status=1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Grade or Designation Doesn''t exists',@Grade_Desig,'Enter proper Grade or Designation Name',GETDATE(),'Grade or Designation', '')
		RAISERROR('@@Grade or Designation Name Doesn''t exists@@',16,2)
		RETURN
	END
	
	IF isnull(@City_Cat_ID,0) =0
	BEGIN
		SET @Log_Status=1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'City Category Doesn''t exists',0,'Enter proper City Category',GETDATE(),'City Category','')
		RAISERROR('@@City Category Doesn''t exists@@',16,2)
		RETURN
	END
	
	
	select @Tran_ID = isnull(max(tran_ID),0) + 1 from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK)
			
			INSERT INTO T0050_EXPENSE_TYPE_MAX_LIMIT
				           (TRAN_ID,CMP_ID,Expense_Type_ID,Grd_Id,Amount,Flag_Grd_Desig,City_Cat_ID,City_Cat_Amount,Desig_ID,Effective_Date,City_Cat_Flag)
				VALUES     (@Tran_ID,@Cmp_ID,@Expense_Type_ID,@Grd_Desig_ID,@Amount,@Flag_grd_desig,@City_Cat_ID,@Amount,@Grd_Desig_ID,@Effect_Date,1)	
	--IF EXISTS (SELECT 1 FROM T0050_EXPENSE_TYPE_MAX_LIMIT WHERE City_Cat_ID=@City_Cat_ID and Expense_Type_ID = @Expense_type_ID  and Effective_date = @Effect_Date)
	--	Begin
		
	--		--delete from T0050_EXPENSE_TYPE_MAX_LIMIT where Effective_Date=@Effect_Date and Cmp_ID=@Cmp_Id and Expense_Type_ID=@Expense_type_ID 
	--		select @Tran_ID = isnull(max(tran_ID),0) + 1 from T0050_EXPENSE_TYPE_MAX_LIMIT
			
	--		INSERT INTO T0050_EXPENSE_TYPE_MAX_LIMIT
	--			           (TRAN_ID,CMP_ID,Expense_Type_ID,Grd_Id,Amount,Flag_Grd_Desig,City_Cat_ID,City_Cat_Amount,Desig_ID,Effective_Date,City_Cat_Flag)
	--			VALUES     (@Tran_ID,@Cmp_ID,@Expense_Type_ID,@Grd_Desig_ID,@Amount,@Flag_grd_desig,@City_Cat_ID,@Amount,@Grd_Desig_ID,@Effect_Date,1)	
	--	End
	
	
return
