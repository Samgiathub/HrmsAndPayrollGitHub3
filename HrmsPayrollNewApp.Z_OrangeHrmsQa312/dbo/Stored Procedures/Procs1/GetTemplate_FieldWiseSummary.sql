-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 12/06/2023
-- Description:	Get Template Field wise Summary
-- =============================================
CREATE PROCEDURE GetTemplate_FieldWiseSummary
	@Cmp_Id		numeric(18,0)
	,@T_ID		numeric(18,0)
	,@F_ID	numeric(18,0)
	,@Field_Type	nvarchar(50)
	,@emp_code		varchar(200)=''
	,@Branch_Id		VARCHAR(MAX) = ''
	,@Desig_Id		VARCHAR(MAX) = ''
	,@Dept_Id		VARCHAR(MAX) = ''
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;
	create table #Table1
	(
		 Question_Option	nvarchar(800)
		,Response			numeric(18,2)	
		,Res_Count			numeric(18,0)
		,Employee_name		varchar(MAX)
		,Emp_id				varchar(MAX)
	)
	
	declare @optionstr as nvarchar(800) 
	declare @col1 as nvarchar(800)
	declare @tot_cnt as int
	declare @res_cnt as int
	declare @empid as numeric(18,0)
	declare @col2 as numeric(18,0)
	declare @e_name as varchar(100)
	declare @q_option as nvarchar(800)
	declare @chkcnt as numeric(18,0)
	set @chkcnt = 0
	SET @optionstr = ''
	
	IF @Branch_Id='0' OR @Branch_Id=''
		SET @Branch_Id=NULL
	IF @Desig_Id='0' OR @Desig_Id=''
		SET @Desig_Id=NULL
	IF @Dept_Id='0' OR @Dept_Id=''
		SET @Dept_Id=NULL
	IF @emp_code=''
		SET @emp_code=NULL

	SELECT EM.Emp_ID,(EM.Alpha_Emp_Code +'-'+ EM.Emp_Full_Name)Emp_Full_Name,REPLACE(Answer,'~~','#')Answer,EM.Alpha_Emp_Code
	INTO #FINAL_EMP
	FROM T0080_EMP_MASTER EM WITH (NOLOCK)
	INNER JOIN T0100_Employee_Template_Response TR WITH (NOLOCK) ON TR.Emp_Id=EM.Emp_ID 	
	INNER JOIN V0080_EMP_MASTER_INCREMENT_GET I WITH (NOLOCK) ON I.Emp_ID = EM.Emp_ID 
	WHERE  TR.F_Id=@F_ID and TR.T_Id = @T_ID AND (EM.Alpha_Emp_Code=ISNULL(@emp_code,EM.Alpha_Emp_Code) or EM.Emp_First_Name like ISNULL(@emp_code,EM.Emp_First_Name))
	and ISNULL(I.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(I.Branch_ID,0)),',') ) 
	AND ISNULL(I.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(I.Dept_ID,0)),',') ) 
	AND ISNULL(I.Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(I.Desig_ID,0)),',') ) 

	--select * from #FINAL_EMP
	If @Field_Type = 'Multiple Choice' or @Field_Type = 'Radiobutton List' or @Field_Type='DropdownList' or @Field_Type='CheckBoxList'
		Begin
			select @optionstr = Options from T0050_Template_Field_Master WITH (NOLOCK) where F_ID=@F_ID and T_ID = @T_ID
			insert into #Table1 (Question_Option)
			select  CAST(DATA  AS nvarchar(800)) from dbo.Split (@optionstr,'#')  			
			-- get total count			
			select @tot_cnt = COUNT(emp_id) FROM #FINAL_EMP
			
			declare cur cursor
			for 
				select Question_Option from #Table1 where isnull(Question_Option,'') <> ''
			open cur
				fetch next from cur into @col1
				while @@FETCH_STATUS = 0
					Begin
								IF @Field_Type = 'CheckBoxList'
								begin
									select @res_cnt =  COUNT(emp_id) from #FINAL_EMP where CHARINDEX(@col1,Answer ) > 0 						
								
									update #Table1 
									set Res_Count = @res_cnt,Response = case when @tot_cnt > 0 then (CAST((@res_cnt * 100) AS numeric(18,2)) / @tot_cnt) else 0 end
									Where Question_Option = @col1	

									UPDATE #Table1
									SET Employee_name =  SUBSTRING((SELECT ',' + cast(Emp_Full_Name as varchar(100))								
											  FROM #FINAL_EMP
											  WHERE CHARINDEX(@col1,Answer) > 0 	
											  ORDER BY emp_id
											  FOR XML PATH('')),2,10000)								
									WHERE Question_Option = @col1
							

									UPDATE #Table1
									SET Emp_id =  SUBSTRING((SELECT ',' + cast(Emp_ID as varchar(100))
											  FROM #FINAL_EMP
											  WHERE CHARINDEX(@col1,Answer) > 0 	
											  ORDER BY emp_id
											  FOR XML PATH('')),2,10000)								
									WHERE Question_Option = @col1	
								END
							ELSE
								BEGIN
									select @res_cnt =  COUNT(emp_id) from #FINAL_EMP where Answer=@col1
									--select  *,@col1 from #FINAL_EMP --where Answer=@col1

									update #Table1 
									set Res_Count = @res_cnt,Response = case when @tot_cnt > 0 then (CAST((@res_cnt * 100) AS numeric(18,2)) / @tot_cnt) else 0 end
									Where Question_Option = @col1	

									UPDATE #Table1
									SET Employee_name =  SUBSTRING((SELECT ',' + cast(Emp_Full_Name as varchar(100))								
											  FROM #FINAL_EMP
											  WHERE  Answer=@col1
											  ORDER BY emp_id
											 FOR XML PATH('')),2,10000)								
									WHERE Question_Option = @col1
							

									UPDATE #Table1
									SET Emp_id =  SUBSTRING((SELECT ',' + cast(Emp_ID as varchar(100))
											  FROM #FINAL_EMP
											  WHERE Answer=@col1
											  ORDER BY emp_id
											 FOR XML PATH('')),2,10000)								
									WHERE Question_Option = @col1	
								END
									
						fetch next from cur into @col1
					End
			close cur
			deallocate cur
		End
		
	Select  Question_Option,ISNULL(Response,0)Response,ISNULL(Res_Count,0)Res_Count,isnull(Employee_name,'')Employee_name,Emp_id
	from #Table1 where isnull(emp_id,'')<>''
	
	select sum(Res_Count)res_count from #Table1 
	drop table #Table1
END
