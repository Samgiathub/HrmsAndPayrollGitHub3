




-- =============================================
-- Author:		Mukti Chauhan
-- Create date: 25-07-2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0090_EmployeeGoalSetting_Import]
		 @Cmp_Id numeric(18,0)
		,@FinancialYr varchar(30)
		,@Emp_code varchar(30)
		,@KRA nvarchar(500)
		,@KPA nvarchar(500)
		,@Target nvarchar(500)
		,@Weightage numeric(18,2)=0
		,@KPA_Type varchar(250)
		,@User_Id	numeric(18,0) = 0
		,@IP_Address varchar(30)= '' 
		,@Row_No	 numeric(18,0)
		,@GUID Varchar(2000) = ''
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	declare @Emp_GoalSetting_Id	numeric(18,0) 
	declare @Emp_GoalSetting_Detail_Id	numeric(18,0) 
	declare @Emp_ID			numeric(18,0)
	declare @year  varchar(15)
	declare @Emp_GoalSetting_Id1 numeric(18,0)
	DECLARE @KPA_Type_Id INT
	
	set @Emp_GoalSetting_Id1=0
	
		DECLARE @temp_data table
		(	
			 Emp_Id numeric(18,0)
			,Emp_code	varchar(50)
			,Emp_GoalSetting_Id  varchar(50)
			,error_messge varchar(500)
			,error_Row numeric(18,0)
		)
--Validations(start)
		IF @Emp_Code=''
			BEGIN
				INSERT INTO @temp_data (Emp_Id,Emp_code,Emp_GoalSetting_Id,error_messge,error_Row) values(0,'',0,'Employee Code is required',0)
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Employee Code is required',0,'Enter Employee Code',GetDate(),'Employee Goal Setting',@GUID)						
				SELECT * FROM  @temp_data
				RETURN
			END	
		ELSE IF NOT EXISTS(select emp_id from  t0080_emp_master WITH (NOLOCK) where upper(Alpha_emp_code)=upper(@Emp_Code) and cmp_id=@cmp_id)
			BEGIN
				insert into @temp_data (Emp_Id,Emp_code,Emp_GoalSetting_Id,error_messge,error_Row) values(0,@Emp_code,0,'Employee Code does not Exist in System',0)
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code does not Exist in System',0,'Enter Proper Employee Code',GetDate(),'Employee Goal Setting',@GUID)						
				select * from  @temp_data
				RETURN
			END	
		ELSE
			BEGIN
				SELECT @emp_id=emp_id FROM T0080_EMP_MASTER WITH (NOLOCK) where upper(Alpha_emp_code)=upper(@Emp_Code) and cmp_id=@cmp_id
			END
		
		if @FinancialYr=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,Emp_GoalSetting_Id,error_messge,error_Row) values(0,'',0,'Financial Year is required',0)
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Financial Year is required',0,'Enter Financial Year',GetDate(),'Employee Goal Setting',@GUID)						
				select * from  @temp_data
				return
			end	
		else
			begin
				set @year= LEFT(@FinancialYr, charindex('-', @FinancialYr) - 1)
			end			
			
		IF @KPA_Type=''
			BEGIN
				insert into @temp_data (Emp_Id,Emp_code,Emp_GoalSetting_Id,error_messge,error_Row) values(@Emp_Id,@Emp_Code,0,'KRA Type is required',0)
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'KRA Type is required',0,'Enter KRA',GetDate(),'Employee Goal Setting',@GUID)						
				select * from  @temp_data
				return
			END	
		ELSE
			BEGIN
				IF NOT EXISTS(select KPA_Type_Id from T0040_HRMS_KPAType_Master WITH (NOLOCK) where upper(KPA_Type)=upper(@KPA_Type) and cmp_id=@cmp_id)
					BEGIN
						insert into @temp_data (Emp_Id,Emp_code,Emp_GoalSetting_Id,error_messge,error_Row) values(@Emp_Id,@Emp_Code,0,'Enter proper KRA Type',0)
						Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'KRA Type is not exist',0,'Enter KRA',GetDate(),'Employee Goal Setting',@GUID)						
						select * from  @temp_data
						return
					END
				ELSE
					BEGIN
						SELECT @KPA_Type_Id=KPA_Type_Id FROM T0040_HRMS_KPAType_Master WITH (NOLOCK) WHERE upper(KPA_Type)=upper(@KPA_Type) and cmp_id=@cmp_id
					END
			END
		 
			if @KRA=''
				begin
					insert into @temp_data (Emp_Id,Emp_code,Emp_GoalSetting_Id,error_messge,error_Row) values(@Emp_Id,@Emp_Code,0,'KRA is required',0)
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'KRA is required',0,'Enter KRA',GetDate(),'Employee Goal Setting',@GUID)						
					select * from  @temp_data
					return
				end	
				
			if @KPA=''
				begin
					insert into @temp_data (Emp_Id,Emp_code,Emp_GoalSetting_Id,error_messge,error_Row) values(@Emp_Id,@Emp_Code,0,'KPA is required',0)
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'KPA is required',0,'Enter KPA',GetDate(),'Employee Goal Setting',@GUID)						
					select * from  @temp_data
					return
				end	
			
			if @Target=''
				begin
					insert into @temp_data (Emp_Id,Emp_code,Emp_GoalSetting_Id,error_messge,error_Row) values(@Emp_Id,@Emp_Code,0,'Target is required',0)
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Target is required',0,'Enter Target',GetDate(),'Employee Goal Setting',@GUID)						
					select * from  @temp_data
					return
				end					
				
			if @Weightage=0
				begin
					insert into @temp_data (Emp_Id,Emp_code,Emp_GoalSetting_Id,error_messge,error_Row) values(@Emp_Id,@Emp_Code,0,'Weightage is required',0)
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Weightage is required',0,'Enter Weightage',GetDate(),'Employee Goal Setting',@GUID)						
					select * from  @temp_data
					return
				end	
--Validations(end)

			if NOT EXISTS(select 1 from T0090_EmployeeGoalSetting WITH (NOLOCK) where Emp_Id=@Emp_Id and FinYear=@year)
				BEGIN 		
					select @Emp_GoalSetting_Id = isnull(max(Emp_GoalSetting_Id),0)+1 from T0090_EmployeeGoalSetting
					INSERT INTO T0090_EmployeeGoalSetting
					(
						 Emp_GoalSetting_Id
						,Cmp_Id
						,Emp_Id
						,EGS_Status
						,FinYear
						,Emp_Comment
						,Manager_Comment
						,CreatedDate
						,CreatedBy
					)VALUES
					(
						@Emp_GoalSetting_Id
						,@Cmp_Id
						,@Emp_Id
						,3
						,@year
						,''
						,''
						,GETDATE()
						,@User_Id
					)
				End		
			
			declare @TotWeightage as NUMERIC(18,2)
			declare @Weightage1 as NUMERIC(18,2)
			
			select @Emp_GoalSetting_Id1 = Emp_GoalSetting_Id from T0090_EmployeeGoalSetting	WITH (NOLOCK)
			where Emp_ID=@Emp_ID and Cmp_Id=@cmp_id and FinYear=@year			
			
			SELECT @Weightage1 = sum([weight]) from T0095_EmployeeGoalSetting_Details WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_Id=@cmp_id and Emp_GoalSetting_Id=@Emp_GoalSetting_Id1
			set @TotWeightage = @Weightage1+@Weightage
			print @TotWeightage
			
			if(@TotWeightage > 100)
				BEGIN
					insert into @temp_data (Emp_Id,Emp_code,Emp_GoalSetting_Id,error_messge,error_Row) values(@Emp_Id,@Emp_Code,0,'Weightage should not be greater than 100',@Row_No)
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Weightage should not be greater than 100',0,'Weightage should not be greater than 100',GetDate(),'Employee Goal Setting','')						
					select * from  @temp_data										
					return
				END
			
			if(isnull(@Emp_GoalSetting_Id1,0) > 0)
			BEGIN
				SELECT @Emp_GoalSetting_Detail_Id = isnull(max(Emp_GoalSetting_Detail_Id),0)+1 from T0095_EmployeeGoalSetting_Details WITH (NOLOCK)
					INSERT INTO T0095_EmployeeGoalSetting_Details	
					(
						 [Emp_GoalSetting_Detail_Id]
						,[Cmp_Id]
						,[Emp_GoalSetting_Id]
						,[Emp_Id]
						,[KRA]
						,[KPI]
						,[Target]
						,[Weight]
						,KPA_Type_ID
					)VALUES
					(
						@Emp_GoalSetting_Detail_Id
					   ,@Cmp_Id
					   ,@Emp_GoalSetting_Id1
					   ,@Emp_Id
					   ,@KRA
					   ,@KPA
					   ,@Target
					   ,@Weightage	
					   ,@KPA_Type_ID
					)	
					
			--declare @error_msg varchar(25)				
			--if ((SELECT sum([weight]) from T0095_EmployeeGoalSetting_Details where Emp_ID=@Emp_ID and Cmp_Id=@cmp_id and Emp_GoalSetting_Id=@Emp_GoalSetting_Id1) >100)
			--	begin	
			--	print 'm'
			--		set @ctr_row=0
			--		select @ctr_row=count(Emp_GoalSetting_Id) from T0095_EmployeeGoalSetting_Details where Emp_ID=@Emp_ID and Cmp_Id=@cmp_id and Emp_GoalSetting_Id=@Emp_GoalSetting_Id1
			--		--if (@ctr_row > 0)
			--		--	BEGIN
			--		--		set @error_msg= cast(@ctr_row as varchar(10)) +'no. of row already exist'					
			--		--	END
			--		--ELSE
			--		--	BEGIN
			--		--		set @error_msg= 'Weightage should not be greater than 100'					
			--		--	END						
			--			set @error_msg= 'Weightage should not be greater than 100'	
												
			--		insert into @temp_data (Emp_Id,Emp_code,Emp_GoalSetting_Id,error_messge,error_Row) values(@Emp_Id,@Emp_Code,0,'Weightage should not be greater than 100',@ctr_row)
			--		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Weightage should not be greater than 100',0,CAST(@error_msg as VARCHAR(MAX)),GetDate(),'Employee Goal Setting','')						
			--		select * from  @temp_data					
			--		delete from T0095_EmployeeGoalSetting_Details where Emp_ID=@Emp_ID and Cmp_Id=@cmp_id and Emp_GoalSetting_Id=@Emp_GoalSetting_Id1
			--		--delete from T0090_EmployeeGoalSetting where Emp_ID=@Emp_ID and Cmp_Id=@cmp_id and Emp_GoalSetting_Id=@Emp_GoalSetting_Id1					
			--		return
			--	end				
			END
END

