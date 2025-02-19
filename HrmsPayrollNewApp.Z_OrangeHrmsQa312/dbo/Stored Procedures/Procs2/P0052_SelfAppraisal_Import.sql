
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0052_SelfAppraisal_Import]
    @cmp_id    as numeric(18,0)
   ,@Initiation_date datetime
   ,@Emp_code  varchar(100)
   ,@Content_ID varchar(100)
   --,@Effetcive_date datetime
   ,@Content varchar(max)
   ,@Weightage numeric(18,2) 
   ,@Employee_Score numeric(18,2) 
   ,@Employee_Comments varchar(max)
   ,@Manager_Score numeric(18,2) 
   ,@Manager_comments varchar(max)
   ,@flag  char(1)
   ,@GUID Varchar(2000) = ''
   ,@Row_No  Numeric(18,0)
   ,@filename  varchar(100)
   ,@Log_Status Int = 0 Output
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @SAppraisal_ID as NUMERIC(18,0)
	declare @InitiateId as NUMERIC(18,0)=0
	declare @Emp_id Numeric(18,0)=0
	declare @SelfApp_Id as NUMERIC(18,0)	
	declare @SAppCriteria_Content as varchar(max)
	declare @SA_Weightage Numeric(18,2)
	declare @tot_empweightage Numeric(18,2)
	declare @SWeight as NUMERIC(18,0)
	
	if @Emp_code=''
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee Code is required-' +@filename,'','Enter Employee Code',GetDate(),'Self Appraisal',@GUID)			
				RETURN	
			end	
		ELSE
			BEGIN
				select @Emp_id = emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_code  and Cmp_ID = @cmp_id
				if @Emp_id=0
					BEGIN
						Set @Log_Status = 1
						INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
						VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee code does not exist-' +@filename,'','Enter proper Employee Code',GetDate(),'Self Appraisal',@GUID)			
						RETURN	
					END
			END	
		
		if @Initiation_date=''
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Initiation Start Date is required-' +@filename,'','Enter Initiation Start Date',GetDate(),'Self Appraisal',@GUID)			
				RETURN	
			end	
		ELSE	
			BEGIN
				select @InitiateId = InitiateId  from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id = @Emp_id and SA_Startdate=@Initiation_date and Cmp_ID = @cmp_id
				if @InitiateId=0
				BEGIN
					Set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee not initiated-' +@filename,'','Enter proper Initiation Start Date',GetDate(),'Self Appraisal',@GUID)			
					RETURN	
				END
			END
			
		if @Content=''
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Content is required-' +@filename,'','Enter Content',GetDate(),'Self Appraisal',@GUID)			
			RETURN	
		end	
		print @Emp_id
		
		if @Content_ID <> ''
			BEGIN
			--select RIGHT('16112510', LEN('16112510') - 6)
				--select SApparisal_ID,SWeight from T0040_SelfAppraisal_Master where Cmp_ID=@Cmp_Id and SApparisal_ID=cast(RIGHT(@Content_ID, LEN(@Content_ID) - 6) as NUMERIC)				
				select @SAppraisal_ID=SApparisal_ID,@SWeight=SWeight from T0040_SelfAppraisal_Master where Cmp_ID=@Cmp_Id and SApparisal_ID=cast(RIGHT(@Content_ID, LEN(@Content_ID) - 6) as NUMERIC)				
			END
		ELSE
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Content ID not match with Master-' +@filename,'','Enter proper content',GetDate(),'Self Appraisal',@GUID)			
				RETURN	
			END
			
		if (@Weightage=0 and @SWeight=1)
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Weightage is required-' +@filename,'','Enter Weightage',GetDate(),'Self Appraisal',@GUID)			
				RETURN	
			end		
		--else if not(@Weightage>=0 and @Weightage<=100 and @SWeight=1)
		--	BEGIN
		--		Set @Log_Status = 1
		--		INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
		--		VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Weightage should be between 0 to 100-' +@filename,'','Enter proper Weightage',GetDate(),'Self Appraisal',@GUID)			
		--		RETURN	
		--	end		
		
		if (@Employee_Score=0 and @Manager_Score=0 and @SWeight=1)--@Employee_Score=0
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Score is required-' +@filename,'','Enter Employee/Manager Score',GetDate(),'Self Appraisal',@GUID)			
				RETURN	
			end		
		--else if not(@Employee_Score>=0 and @Employee_Score<=100)
		--	BEGIN
		--		Set @Log_Status = 1
		--		INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
		--		VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee Score should be between 0 to 100-' +@filename,@Emp_code,'Enter proper Employee Score',GetDate(),'Self Appraisal',@GUID)			
		--		RETURN	
		--	end	
			
		if (@Employee_Score > @Weightage and @SWeight=1)
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee Score sholud not be greater than weightage-' +@filename,'','Enter Employee Score',GetDate(),'Self Appraisal',@GUID)			
			RETURN	
		end		
		
			--print @SAppraisal_ID
			--print @SWeight
			if @SWeight=0 and @Weightage>0
				BEGIN			
					Set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Weightage not required for this Content-' +@filename,'','Weightage not required for this Content',GetDate(),'Self Appraisal',@GUID)			
					RETURN	
				END
			
			select @SA_Weightage=isnull(SA_Weightage,0) from T0060_Appraisal_EmpWeightage WITH (NOLOCK) where Cmp_Id=@Cmp_Id and emp_id=@Emp_id 
			       and isnull(SA_RestrictWeightage,0)=1 and Effective_Date =(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) 
			from T0060_Appraisal_EmpWeightage WITH (NOLOCK) where emp_id=@Emp_id and Cmp_Id=@Cmp_Id)
				--print @SA_Weightage
			create table #tempsum
			(
				empweighatge numeric(18,0),
				SAppraisal_ID numeric(18,0)
			)		
			
			insert into #tempsum
			SELECT DISTINCT Weightage,SAppraisal_ID FROM T0052_Emp_SelfAppraisal WITH (NOLOCK)
			WHERE CMP_ID = @Cmp_Id and InitiateId=@InitiateId and Emp_Id=@Emp_id
			
			set @tot_empweightage=(select sum(empweighatge) from #tempsum)				
			DROP TABLE #tempsum
			--print @tot_empweightage
			--select @tot_empweightage=sum(Weightage) from T0052_Emp_SelfAppraisal where Emp_Id=@Emp_id and InitiateId=@InitiateId GROUP by Emp_Id
			set @tot_empweightage=isnull(@tot_empweightage,0) + @Weightage
								
			if ((ISNULL(@SA_Weightage,0) >0)AND(isnull(@tot_empweightage,0) > ISNULL(@SA_Weightage,0)))
			  BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Total Weighatge should be equal to ' + cast(@SA_Weightage as VARCHAR(10))+'-' +@filename ,'','Weighatge exceed',GetDate(),'Self Appraisal',@GUID)			
				RETURN			
			  END
			
			if @Manager_Score > @Weightage
				BEGIN
					Set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					VALUES (@Row_No,@Cmp_Id,@Emp_code ,'RM Score sholud not be greater than weightage-' +@filename,'','Enter RM Score',GetDate(),'Self Appraisal',@GUID)			
					RETURN	
				end	
	--if @flag ='I'
		--BEGIN	
		--print @SAppraisal_ID
		--print @Emp_Id
			DECLARE Emp_SelfAppraisal CURSOR FOR
				SELECT DISTINCT SAppCriteria_Content from T0050_SA_SubCriteria WITH (NOLOCK)
				WHERE  Cmp_ID=@cmp_id and SApparisal_ID=@SAppraisal_ID
			OPEN Emp_SelfAppraisal
				fetch next from Emp_SelfAppraisal into @SAppCriteria_Content
			    		while @@fetch_status = 0
								Begin			
								--print @SAppCriteria_Content					
								--if not EXISTS(select 1 from T0052_Emp_SelfAppraisal where Emp_Id=@Emp_Id and InitiateId=@InitiateId and SAppraisal_ID=@SAppraisal_ID and Cmp_ID=@cmp_ID)
								--	BEGIN
										select @SelfApp_Id = isnull(max(SelfApp_Id),0) + 1 from T0052_Emp_SelfAppraisal	WITH (NOLOCK)
										Insert Into T0052_Emp_SelfAppraisal 
										(
											 SelfApp_Id
											,Cmp_ID
											,SAppraisal_ID
											,InitiateId
											,Emp_Id
											,Answer
											,Weightage
											,Emp_Score
											,Comments
											,Manager_Score
											,Manager_comments 
										)
										VALUES  
										(
											 @SelfApp_Id
											,@Cmp_ID
											,@SAppraisal_ID
											,@InitiateId
											,@Emp_Id
											,@SAppCriteria_Content
											,@Weightage
											,@Employee_Score
											,@Employee_Comments
											,@Manager_Score 
											,@Manager_comments 
										)	
											
										--update T0050_HRMS_InitiateAppraisal 
										--set SA_Status=0,SA_SubmissionDate=GETDATE()
										--where InitiateId=@InitiateId and Cmp_Id=@Cmp_Id
										if @Manager_Score >0
											BEGIN
												update T0050_HRMS_InitiateAppraisal 
												set SA_Status=1,SA_ApprovedDate=GETDATE(),SA_SubmissionDate=GETDATE()
												where InitiateId=@InitiateId and Cmp_Id=@Cmp_Id	and Emp_Id=@Emp_Id
												  
												exec Appraisal_Final_Score_Calculation @Cmp_Id,@Emp_id,@InitiateId
											END
										ELSE
											BEGIN
												update T0050_HRMS_InitiateAppraisal 
												set SA_Status=0,SA_SubmissionDate=GETDATE()
												where InitiateId=@InitiateId and Cmp_Id=@Cmp_Id and Emp_Id=@Emp_Id
											END
									--END
								--ELSE
								--	BEGIN
								--		Update T0052_Emp_SelfAppraisal
								--		Set  Weightage=@Weightage,Emp_Score=@Employee_Score,
								--			 Comments=@Employee_Comments,
								--			 Manager_Score =@Manager_Score,
								--			 Manager_comments = @Manager_comments
								--		Where  SAppraisal_ID = @SAppraisal_ID and InitiateId=@InitiateId  and Emp_Id=@Emp_Id and Cmp_Id=@Cmp_Id
										  
								--		update T0050_HRMS_InitiateAppraisal 
								--		set SA_Status=1,SA_ApprovedDate=GETDATE()
								--		where InitiateId=@InitiateId and Cmp_Id=@Cmp_Id	 and Emp_Id=@Emp_Id
										  
								--		exec Appraisal_Final_Score_Calculation @Cmp_Id,@Emp_id,@InitiateId
								--	END	
							
							fetch next from Emp_SelfAppraisal into @SAppCriteria_Content
							End
					close Emp_SelfAppraisal	
					deallocate Emp_SelfAppraisal
END

