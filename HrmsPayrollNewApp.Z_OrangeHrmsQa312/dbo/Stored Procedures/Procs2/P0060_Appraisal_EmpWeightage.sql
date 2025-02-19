
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0060_Appraisal_EmpWeightage]
	 @Emp_Weightage_Id		numeric(18,0) out
	,@Cmp_Id				numeric(18,0)
	,@Emp_Id				numeric(18,0)
	,@EKPA_Weightage		numeric(18,2)
	,@SA_Weightage			numeric(18,2)
	,@Effective_Date		datetime = null --19 Sep 2016
	,@PA_Weightage			numeric(18,2) = 0 --26 sep 2016
	,@PoA_Weightage			numeric(18,2) = 0 --26 sep 2016
	,@EKPA_RestrictWeightage integer = 0 -- 29 Sep 2016
	,@SA_RestrictWeightage   integer = 0 -- 29 Sep 2016
	,@tran_type				varchar(1) 
	,@User_Id				numeric(18,0) = 0
	,@IP_Address			varchar(30)= '' 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
    
		If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		BEGIN
			If @Emp_Id = 0
				BEGIN
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'No employee Id',0,'Enter Employee',GetDate(),'Appraisal')						
					Return
				END
		END	
		If Upper(@tran_type) ='I'
			BEGIN
				if exists(select Emp_Id from T0060_Appraisal_EmpWeightage WITH (NOLOCK) where Emp_Id = @Emp_Id and Effective_Date=@Effective_Date)
				BEGIN
					delete from T0060_Appraisal_EmpWeightage where Emp_Id = @Emp_Id and Effective_Date=@Effective_Date
				END
								
				SELECT @Emp_Weightage_Id = isnull(max(Emp_Weightage_Id),0) + 1 FROM T0060_Appraisal_EmpWeightage WITH (NOLOCK)	
				INSERT INTO T0060_Appraisal_EmpWeightage
				(
					 Emp_Weightage_Id
					,Cmp_Id
					,Emp_Id
					,EKPA_Weightage
					,SA_Weightage
					,Effective_Date --19 Sep 2016
					,PA_Weightage   --26 sep 2016
					,PoA_Weightage  --26 sep 2016
					,EKPA_RestrictWeightage -- 29 Sep 2016
					,SA_RestrictWeightage	-- 29 Sep 2016
				)
				Values
				(
					 @Emp_Weightage_Id
					,@Cmp_Id
					,@Emp_Id
					,@EKPA_Weightage
					,@SA_Weightage
					,@Effective_Date --19 Sep 2016
					,@PA_Weightage	 --26 sep 2016
					,@PoA_Weightage  --26 sep 2016
					,@EKPA_RestrictWeightage -- 29 Sep 2016
					,@SA_RestrictWeightage	-- 29 Sep 2016
				)
			END
		Else If  Upper(@tran_type) ='U' 
			BEGIN
				  Update T0060_Appraisal_EmpWeightage
				  Set    EKPA_Weightage = @EKPA_Weightage,
						 SA_Weightage = @SA_Weightage,
						 Effective_Date = @Effective_Date--19 Sep 2016
						,PA_Weightage  = @PA_Weightage --26 sep 2016
					    ,PoA_Weightage = @PoA_Weightage --26 sep 2016
					    ,EKPA_RestrictWeightage = @EKPA_RestrictWeightage -- 29 Sep 2016
					    ,SA_RestrictWeightage	= @SA_RestrictWeightage -- 29 Sep 2016
				  Where  Emp_Id = @Emp_Id and Emp_Weightage_Id = @Emp_Weightage_Id
			END
		Else If  Upper(@tran_type) ='D'
			Begin 
				delete from T0060_Appraisal_EmpWeightage where Emp_Weightage_Id = @Emp_Weightage_Id
			End
END
---------------------

