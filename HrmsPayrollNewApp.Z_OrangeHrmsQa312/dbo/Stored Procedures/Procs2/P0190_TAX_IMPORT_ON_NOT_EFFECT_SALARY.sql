


/*Added by Sumit on 11012017 for import Tax on Other Components*/
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0190_TAX_IMPORT_ON_NOT_EFFECT_SALARY] 
	 @Tran_ID		numeric(18,0)=0 output,
	 @Cmp_Id		NUMERIC(18,0)=0
	,@Emp_ID		numeric(18,0)=0
	,@Ad_name		varchar(200)=''
	,@Month			int =0
	,@Year			int=0
	,@TDS_Amount    numeric(18,2)=0
	,@isRepeat      tinyint=0
	,@loginID		numeric(18,0)=0
	,@Row_No		INT = 0
	,@Log_Status	INT = 0 OUTPUT	
	,@GUID  varchar(2000) = ''
	,@Comments		varchar(200)=''
	,@flag              char = 'I'
AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @AD_ID as Numeric(18,0)
	declare @Inc_ID as numeric(18,0)
	declare @EmpCode as varchar(200)
	
	select @EmpCode=isnull(Alpha_Emp_Code,'0') from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_Id
	
		
	--select @AD_ID=isnull(Ad_ID,0) from T0050_AD_MASTER where CMP_ID=@Cmp_Id and AD_NAME=@Ad_name and AD_ACTIVE=1 
	--						and AD_NOT_EFFECT_SALARY=1 and (Auto_Ded_TDS=1 or Ad_Effect_On_Esic=1 or Hide_In_Reports=1)
	
	
	if (@flag='I')
		Begin
					if Exists(select 1 from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_Id and AD_NAME=@Ad_name and AD_ACTIVE=1)
						Begin
							select @AD_ID=isnull(Ad_ID,0) from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_Id and AD_NAME=@Ad_name and AD_ACTIVE=1 
							and AD_NOT_EFFECT_SALARY=1 and (Auto_Ded_TDS=1 or Ad_Effect_On_Esic=1 or Hide_In_Reports=1)
						End
					Else
						Begin
							SET @Log_Status=1
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EmpCode,'Allowance Name Doesn''t exists',@Ad_name,'Enter proper Allowance',GETDATE(),'Tax on Other Components',@GUID)				
							RETURN
						End
												
				if @Ad_name = '' 
					Begin
						SET @Log_Status=1
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EmpCode,'Allowance Name Doesn''t exists',@Ad_name,'Enter proper Allowance Name',GETDATE(),'Tax on Other Components',@GUID)
						RETURN	
					End	
					select @AD_ID
				   if ISNULL(@AD_ID,0)=0
						begin
							SET @Log_Status=1
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EmpCode,'Allowance Should be Auto deduct TDS or Effect on ESIC',@Ad_name,'Enter proper Allowance',GETDATE(),'Tax on Other Components',@GUID)				
							RETURN	
						end
				   Else if ISNULL(@Emp_ID,0)=0
						begin
							SET @Log_Status=1
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EmpCode,'Employee Doesn''t Exists',@Ad_name,'Enter proper Employee Code',GETDATE(),'Tax on Other Components',@GUID)				
							RETURN	
						end
						
				  select @Inc_ID= Max(TI.Increment_ID) from t0095_increment TI WITH (NOLOCK) inner join
							(
								Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
										Where month(Increment_effective_Date) <= @Month
												and YEAR(Increment_Effective_Date) <= @Year
												and Emp_ID=@Emp_ID
												Group by emp_ID) new_inc
							on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where month(TI.Increment_effective_Date) <=@Month AND YEAR(ti.Increment_Effective_Date)<=@year
				and Ti.Emp_ID=@Emp_ID
						
				
				 if Not EXISTS (select 1 from T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where CMP_ID=@Cmp_Id and INCREMENT_ID=ISNULL(@Inc_ID,0) and EMP_ID=@Emp_ID and AD_ID=@AD_ID)
						begin
							SET @Log_Status=1
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EmpCode,'Allowance is not Assigned to Employee',@Ad_name,'Allocate Allowance to Employee',GETDATE(),'Tax on Other Components',@GUID)				
							RETURN	
						end
			
			
				IF EXISTS (SELECT 1 FROM T0190_TAX_IMPORT_ON_NOT_EFFECT_SALARY WITH (NOLOCK) WHERE Ad_Id=@AD_ID and Month=@Month and YEAR=@Year and Emp_id=@Emp_ID and Cmp_id=@Cmp_Id)
					Begin
						SET @Log_Status=1
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EmpCode,'Allowance is Already Exists for this Month',@Ad_name,'Enter proper Allowance',GETDATE(),'Tax on Other Components',@GUID)			
						RETURN
					End
				Else
					Begin
						INSERT INTO T0190_TAX_IMPORT_ON_NOT_EFFECT_SALARY
											   (Cmp_id,Emp_id,Ad_Id,Month,Year,TDS_Amount,Is_Repeat,Login_Id,SystemDatetime,Comments)
									VALUES     (@Cmp_Id,@Emp_ID,@AD_ID,@Month,@Year,@TDS_Amount,@isRepeat,@loginID,GETDATE(),@Comments)	
							
					End
		End
	Else if (@flag='U')
		Begin
			
			UPDATE T0190_TAX_IMPORT_ON_NOT_EFFECT_SALARY
							SET Month=@Month,Year=@Year,TDS_Amount=@TDS_Amount,Comments=@Comments
							,Is_Repeat=@isRepeat
						WHERE  EMP_ID =@EMP_ID AND AD_ID =@AD_ID AND Tran_Id=@Tran_Id
		End
	Else if (@flag='D')
		Begin
			
			SELECT @EMP_ID=EMP_ID,@AD_ID=AD_ID,@MONTH=MONTH,@YEAR=YEAR,@CMP_ID=CMP_ID FROM T0190_TAX_IMPORT_ON_NOT_EFFECT_SALARY WITH (NOLOCK) WHERE TRAN_ID=@TRAN_ID
			
			if Exists (select 1 from T0210_ESIC_On_Not_Effect_on_Salary WITH (NOLOCK) where Emp_Id=@Emp_ID and Ad_Id=@AD_ID and Cmp_Id=@Cmp_Id and For_Date >= dbo.GET_MONTH_END_DATE(@Month,@Year))
				Begin					
						Raiserror('@@Reference Exists. You Can''t delete Record@@',18,2)
						Return -1
						--SET @Log_Status=1
						--INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EmpCode,'Reference Exists. You Cannot delete',@Ad_name,'',GETDATE(),'Tax on Other Components',@GUID)			
						
				End
			delete from T0190_TAX_IMPORT_ON_NOT_EFFECT_SALARY where Tran_Id=@Tran_ID
		
		End		
return			



