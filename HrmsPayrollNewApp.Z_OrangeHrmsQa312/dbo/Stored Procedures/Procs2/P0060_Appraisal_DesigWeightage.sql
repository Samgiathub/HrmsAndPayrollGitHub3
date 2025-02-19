
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0060_Appraisal_DesigWeightage]
	 @Desig_weightage_Id		numeric(18,0) out
	,@Cmp_Id				numeric(18,0)
	,@Desig_Id				numeric(18,0)
	,@EKPA_Weightage		numeric(18,2)
	,@SA_Weightage			numeric(18,2)
	,@Effective_Date		datetime = null --19 sep 2016
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
SET ANSI_WARNINGS OFF;
 
	declare @Emp_Id as NUMERIC(18,0)
	declare @Emp_Weightage_Id as NUMERIC(18,0)	
BEGIN
		If Upper(@tran_type) ='I'
			BEGIN
				SELECT @Desig_weightage_Id = isnull(max(Desig_weightage_Id),0) + 1 FROM T0060_Appraisal_DesigWeightage	WITH (NOLOCK)
					
					INSERT INTO T0060_Appraisal_DesigWeightage
						(
						 Desig_weightage_Id
						,Cmp_Id
						,Desig_Id
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
						 @Desig_weightage_Id
						,@Cmp_Id
						,@Desig_Id
						,@EKPA_Weightage
						,@SA_Weightage
						,@Effective_Date --19 Sep 2016
						,@PA_Weightage	 --26 sep 2016
					    ,@PoA_Weightage  --26 sep 2016
					    ,@EKPA_RestrictWeightage -- 29 Sep 2016
					    ,@SA_RestrictWeightage	-- 29 Sep 2016
						)				
										
			DECLARE Appraisal_EmpWeightage CURSOR FOR
				SELECT i.Emp_ID FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0095_INCREMENT AS I ON I.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND I.Increment_ID =
                          (SELECT     MAX(Increment_ID) AS Expr1
                            FROM          dbo.T0095_INCREMENT WITH (NOLOCK)
                            WHERE      (Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID and Cmp_ID=dbo.T0080_EMP_MASTER.Cmp_ID)) 
				WHERE     (dbo.T0080_EMP_MASTER.Emp_Left <> 'Y' and i.Desig_Id=@Desig_Id and i.Cmp_ID=@cmp_id)				
			OPEN Appraisal_EmpWeightage
				fetch next from Appraisal_EmpWeightage into @Emp_Id
			    		while @@fetch_status = 0
								Begin
								if NOT EXISTS(select 1 from T0060_Appraisal_EmpWeightage WITH (NOLOCK) where Emp_Id=@Emp_Id and isnull(Effective_Date,(select 1 from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id))=@Effective_Date)
									BEGIN
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
											,@PA_Weightage   --26 sep 2016
											,@PoA_Weightage  --26 sep 2016
											,@EKPA_RestrictWeightage -- 29 Sep 2016
											,@SA_RestrictWeightage	-- 29 Sep 2016	
										)
									END
								ELSE
									BEGIN
										Update T0060_Appraisal_EmpWeightage
										Set    EKPA_Weightage = @EKPA_Weightage,
										SA_Weightage = @SA_Weightage,
										Effective_Date = @Effective_Date --19 Sep 2016
										,PA_Weightage = @PA_Weightage	  --26 sep 2016
										,PoA_Weightage  = @PoA_Weightage --26 sep 2016
										,EKPA_RestrictWeightage=@EKPA_RestrictWeightage -- 29 Sep 2016
										,SA_RestrictWeightage	= @SA_RestrictWeightage-- 29 Sep 2016
										Where  Emp_Id = @Emp_Id 
									END
								--END
							fetch next from Appraisal_EmpWeightage into @Emp_Id
							End
					close Appraisal_EmpWeightage	
					deallocate Appraisal_EmpWeightage			
				
			END
		Else If  Upper(@tran_type) ='U' 
			BEGIN
				  Update T0060_Appraisal_DesigWeightage
				  Set    EKPA_Weightage = @EKPA_Weightage,
						 SA_Weightage = @SA_Weightage,
						 Effective_Date = @Effective_Date --19 Sep 2016
						 ,PA_Weightage = @PA_Weightage	  --26 sep 2016
						,PoA_Weightage  = @PoA_Weightage --26 sep 2016
						,EKPA_RestrictWeightage=@EKPA_RestrictWeightage -- 29 Sep 2016
						,SA_RestrictWeightage	= @SA_RestrictWeightage-- 29 Sep 2016
				  Where  Desig_Id = @Desig_Id and Desig_weightage_Id = @Desig_weightage_Id
				  
			DECLARE Appraisal_EmpWeightage CURSOR FOR
				SELECT i.Emp_ID FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0095_INCREMENT AS I WITH (NOLOCK) ON I.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND I.Increment_ID =
                          (SELECT     MAX(Increment_ID) AS Expr1
                            FROM          dbo.T0095_INCREMENT WITH (NOLOCK)
                            WHERE      (Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID and Cmp_ID=dbo.T0080_EMP_MASTER.Cmp_ID)) 
				WHERE     (dbo.T0080_EMP_MASTER.Emp_Left <> 'Y' and i.Desig_Id=@Desig_Id and i.Cmp_ID=@cmp_id)				
			OPEN Appraisal_EmpWeightage
				fetch next from Appraisal_EmpWeightage into @Emp_Id
			    		while @@fetch_status = 0
								Begin
								if NOT EXISTS(select 1 from T0060_Appraisal_EmpWeightage WITH (NOLOCK) where Emp_Id=@Emp_Id and isnull(Effective_Date,(select 1 from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id))=@Effective_Date)
									BEGIN
										SELECT @Emp_Weightage_Id = isnull(max(Emp_Weightage_Id),0) + 1 FROM T0060_Appraisal_EmpWeightage WITH (NOLOCK)	
										INSERT INTO T0060_Appraisal_EmpWeightage
										(
											 Emp_Weightage_Id
											,Cmp_Id
											,Emp_Id
											,EKPA_Weightage
											,SA_Weightage	
											,Effective_Date --19 Sep 2016	
											,PA_Weightage  	  --26 sep 2016
											,PoA_Weightage    --26 sep 2016	
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
											,@PA_Weightage
											,@PoA_Weightage
											,@EKPA_RestrictWeightage -- 29 Sep 2016
											,@SA_RestrictWeightage	-- 29 Sep 2016	
										)
									END
								ELSE
									BEGIN
										Update T0060_Appraisal_EmpWeightage
										Set    EKPA_Weightage = @EKPA_Weightage,
										SA_Weightage = @SA_Weightage,
										Effective_Date = @Effective_Date --19 Sep 2016
										,PA_Weightage = @PA_Weightage	  --26 sep 2016
										,PoA_Weightage  = @PoA_Weightage --26 sep 2016
										,EKPA_RestrictWeightage=@EKPA_RestrictWeightage -- 29 Sep 2016
										,SA_RestrictWeightage	= @SA_RestrictWeightage-- 29 Sep 2016
										Where  Emp_Id = @Emp_Id 
									END
								--END
							fetch next from Appraisal_EmpWeightage into @Emp_Id
							End
					close Appraisal_EmpWeightage	
					deallocate Appraisal_EmpWeightage	
			END
		Else If  Upper(@tran_type) ='D'
			Begin 
				delete from T0060_Appraisal_DesigWeightage where Desig_weightage_Id = @Desig_weightage_Id
			End
END
----------------------

