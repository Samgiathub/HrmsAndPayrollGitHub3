

---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0040_Self_Assessment_Import] 
	@Effective_date Datetime
	,@Designation Varchar(100) 
	,@Department Varchar(100) 
	,@Branch Varchar(100) 
	,@Cmp_Id     Numeric(18,0)
	,@Content varchar(1000)
	,@Weightage Numeric(18,2)=0		
	,@GUID Varchar(2000) = ''
	,@Row_No  Numeric(18,0)
	,@Log_Status Int = 0 Output
		
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Desig_id VARCHAR(max)=''
	DECLARE @Dept_id VARCHAR(max)=''
	DECLARE @Branch_id VARCHAR(max)=''
	DECLARE @SApparisal_ID as Numeric(18,0)
	DECLARE @SAppraisal_Sort as numeric(18,0)
	
		if ISNULL(@Effective_date,'') = ''
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,0 ,'Effective Date is required','','Enter Effective Date',GetDate(),'Self Assessment Import',@GUID)			
				RETURN	
			end		
			
			
		if ISNULL(@Content,'') = ''
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,0 ,'KPA Content is required','','Enter KPA Content',GetDate(),'Self Assessment Import',@GUID)			
				RETURN	
			end		
			
			
		if not(@Weightage>=0 and @Weightage<=100)
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,0 ,'Weightage should be between 0 to 100','','Enter proper Weightage',GetDate(),'Self Assessment Import',@GUID)			
			RETURN	
		end									
				
		if ISNULL(@Designation,'') = '' and ISNULL(@Department,'') = '' and ISNULL(@Branch,'') = ''
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,'','Enter Designation/Department/Branch is required','','Enter Designation/Department/Branch is required',GetDate(),'Self Assessment Import',@GUID)			
				RETURN	
			END
							
		if (ISNULL(@Designation,'') <> '')
				BEGIN
					--select @Desig_id = Desig_ID  from T0040_DESIGNATION_MASTER where Desig_Name = @Designation  and Cmp_ID = @cmp_id
					SELECT Desig_ID,Desig_Name
					into #tblDesignation FROM T0040_DESIGNATION_MASTER WITH (NOLOCK)
					WHERE cmp_id=@cmp_id and Desig_Name IN (select  cast(data  as varchar(30)) from dbo.Split (@Designation,',')) 
					
					--select * from #tblDesignation
					SELECT @Desig_id = COALESCE(@Desig_id + '#', '') + cast(Desig_ID as VARCHAR(30)) FROM #tblDesignation 
					--PRINT @Desig_id
					
					if @Desig_id=''
						BEGIN
							Set @Log_Status = 1
							INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
							VALUES (@Row_No,@Cmp_Id,'','Designation does not exist','','Enter proper Designation',GetDate(),'Self Assessment Import',@GUID)			
							RETURN	
						END
				end	
					
		if (ISNULL(@Department,'') <> '')
			BEGIN
					--select @Dept_id = Dept_id  from T0040_DEPARTMENT_MASTER where Dept_Name = @Department  and Cmp_ID = @cmp_id
				SELECT Dept_Id,Dept_Name
				into #tblDepartment FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) 
				WHERE cmp_id=@cmp_id and Dept_Name IN (select  cast(data  as varchar(30)) from dbo.Split (@Department,',')) 
				
				SELECT @Dept_id = COALESCE(@Dept_id + '#', '') + cast(Dept_Id as VARCHAR(30)) FROM #tblDepartment 
				
				if @Dept_id=''
					BEGIN
						Set @Log_Status = 1
						INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
						VALUES (@Row_No,@Cmp_Id,'','Department does not exist','','Enter proper Department',GetDate(),'Self Assessment Import',@GUID)			
						RETURN	
					END				
			END
					
		 if (ISNULL(@Branch,'') <> '')
			BEGIN
				SELECT Branch_ID,Branch_Name
				into #tblBranch FROM T0030_BRANCH_MASTER WITH (NOLOCK)
				WHERE cmp_id=@cmp_id and Branch_Name IN (select  cast(data  as varchar(30)) from dbo.Split (@Branch,',')) 
				
				--select * from #tblBranch
				SELECT @Branch_ID = COALESCE(@Branch_ID + '#', '') + cast(Branch_ID as VARCHAR(30)) FROM #tblBranch 
				
				if @Branch_id=''
					BEGIN
						Set @Log_Status = 1
						INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
						VALUES (@Row_No,@Cmp_Id,'','Branch does not exist','','Enter proper Branch',GetDate(),'Self Assessment Import',@GUID)			
						RETURN	
					END
			END
		
			set @Desig_id=right(@Desig_id, len(@Desig_id)-1)
			set @Dept_id=right(@Dept_id, len(@Dept_id)-1)
			set @Branch_id=right(@Branch_id, len(@Branch_id)-1)
			
			--select @Dept_id,@Desig_id,@Branch_id,@Content		
			--print @Branch_id
			--PRINT @Desig_id
			--PRINT @Dept_id
			--PRINT @Content
			
		if EXISTS(SELECT SApparisal_ID from T0040_SelfAppraisal_Master WITH (NOLOCK) where SBranch_Id=@Branch_id and SDept_Id=@Dept_id and SCateg_Id=@Desig_id and SApparisal_Content=@Content)
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,'','Record Already Exist','','Duplicate Entry',GetDate(),'Self Assessment Import',@GUID)			
				RETURN	
			END
			
		--ELSE
		--	BEGIN
		--		set @Branch_id = 0
		--		Set @Log_Status = 1
		--		INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
		--		VALUES (@Row_No,@Cmp_Id,'','Branch does not exist','','Enter proper Branch',GetDate(),'Self Assessment Import',@GUID)			
		--		RETURN
		--	END
			
				--if EXISTS(SELECT 1 from T0040_SelfAppraisal_Master where SDept_Id=ISNULL(@Dept_id,SDept_Id))
				--	BEGIN
				--		Set @Log_Status = 1
				--		INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				--		VALUES (@Row_No,@Cmp_Id,@parameter ,'KPA Content is required','','Enter KPA Content',GetDate(),'Self Assessment Import',@GUID)			
				--		RETURN	
				--	END
			
			
			--begin
				select @SApparisal_ID = isnull(max(SApparisal_ID),0) + 1 from T0040_SelfAppraisal_Master WITH (NOLOCK)
				select @SAppraisal_Sort = isnull(max(SAppraisal_Sort),0) + 1 from T0040_SelfAppraisal_Master WITH (NOLOCK) where Cmp_ID=@cmp_id
				
				INSERT INTO T0040_SelfAppraisal_Master
				(SApparisal_ID,Cmp_ID,SApparisal_Content,SAppraisal_Sort,SDept_Id,SIsMandatory,SType,SWeight,Effective_Date,Ref_SID,SKPAWeight,SCateg_Id,SBranch_Id)
				VAlUES
				(@SApparisal_ID,@Cmp_ID,@Content,@SAppraisal_Sort,@Dept_id,1,1,0,@Effective_Date,null,@Weightage,@Desig_id,@Branch_id)		
			--end
		
RETURN


