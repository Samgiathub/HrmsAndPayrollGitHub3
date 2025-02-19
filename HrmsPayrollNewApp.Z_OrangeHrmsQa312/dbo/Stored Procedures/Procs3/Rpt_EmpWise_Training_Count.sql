

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_EmpWise_Training_Count]
	 @cmp_id as numeric(18,0)
	,@frmdate datetime
	,@todate datetime 
	,@condition as varchar(max)=''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
	if @condition = ''
	--set @condition =' and 1=1'

	declare @query as varchar(max) 
	declare @Emp_ID as NUMERIC(18,0)
	DECLARE @Training_type as VARCHAR(100)	
	DECLARE @Employee_Code as VARCHAR(50)	
	DECLARE @Emp_Full_Name as VARCHAR(250)	
	DECLARE @Department as VARCHAR(150)	
	DECLARE @Designation as VARCHAR(150)	
	
	set @query =''
		--(em.Alpha_Emp_Code + ''-'' + em.Emp_Full_Name)Emp_Full_Name
	CREATE table #TRAINING_DET
	(
	 Emp_ID  varchar(250),
	 Training_type	varchar(100),
	 Is_attend VARCHAR(10),
	 Employee_Code VARCHAR(50),
	 Emp_Full_Name VARCHAR(250),
	 Department VARCHAR(150),
	 Designation VARCHAR(150),
	 No_of_Training_Attended NUMERIC(18,0),
	 Training_Appr_id NUMERIC(18,0)
	 )
	 
	DECLARE @columns nVARCHAR(max)
	SELECT  @columns = COALESCE(@columns + ',[' + cast([Training_TypeName] as varchar) + ']',
			'[' + cast([Training_TypeName] as varchar)+ ']')
			 FROM T0030_Hrms_Training_Type WITH (NOLOCK) where cmp_id=@cmp_id and [Training_TypeName] is not NULL
			GROUP BY [Training_TypeName]			

	DECLARE TRAINING_DETAILS CURSOR FOR
				select DISTINCT Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) where cmp_id=@cmp_id AND Emp_Left='N'				
			OPEN TRAINING_DETAILS
							fetch next from TRAINING_DETAILS into @Emp_ID
								while @@fetch_status = 0
									Begin									
										if EXISTS(select tr.Emp_ID from V0130_HRMS_TRAINING_EMPLOYEE_DETAIL tr	
												inner join T0120_HRMS_TRAINING_Schedule TS WITH (NOLOCK) on tr.Training_App_ID=ts.Training_App_ID 
												  where --tr.Training_Date >= @frmdate and tr.Training_Date <= @todate 
												  TS.From_date >=@frmdate and TS.To_date <= @todate
												  and tr.Emp_ID=@Emp_ID and
												  tr.Cmp_id =@cmp_id and (tr.Emp_tran_status =1 or tr.Emp_tran_status =4)
												  and tr.Training_Apr_ID in(select Training_Apr_ID from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
												  where Emp_ID=tr.Emp_ID and tr.Emp_ID=@Emp_ID and cmp_id=@cmp_id))
											BEGIN
												select @Training_type=[Type],@Employee_Code=Alpha_Emp_Code,@Emp_Full_Name=Emp_Full_Name_new,
													@Department=Dept_Name,@Designation=Desig_Name
												from V0130_HRMS_TRAINING_EMPLOYEE_DETAIL where Emp_ID=@Emp_ID
												
												insert into #TRAINING_DET(Emp_ID,Training_type,Is_attend,Employee_Code,Emp_Full_Name,Department,Designation,No_of_Training_Attended,Training_Appr_id)
												select tr.Emp_ID,[Type],'Yes',tr.Alpha_Emp_Code,tr.Emp_Full_Name,tr.Dept_Name,Desig_Name,0,Training_Apr_ID		
												from V0130_HRMS_TRAINING_EMPLOYEE_DETAIL tr	
												inner join T0120_HRMS_TRAINING_Schedule TS WITH (NOLOCK) on tr.Training_App_ID=ts.Training_App_ID 
												where --tr.Training_Date >= @frmdate and tr.Training_Date <= @todate 
												TS.From_date >=@frmdate and TS.To_date <= @todate
												and tr.Emp_ID=@Emp_ID and
												tr.Cmp_id =@cmp_id and (tr.Emp_tran_status =1 or tr.Emp_tran_status =4)
												and tr.Training_Apr_ID in(select Training_Apr_ID from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
												where Emp_ID=tr.Emp_ID and Emp_ID=@Emp_ID and cmp_id=@cmp_id)
												--group by tr.Emp_ID,[Type],tr.Alpha_Emp_Code,tr.Emp_Full_Name,tr.Dept_Name,Desig_Name
			
											END
										ELSE
											BEGIN
												insert into #TRAINING_DET(Emp_ID,Training_type,Is_attend,Employee_Code,Emp_Full_Name,Department,Designation,No_of_Training_Attended,Training_Appr_id)
												--values(@Emp_ID,'','NO',@Employee_Code,@Emp_Full_Name,@Department,@Designation,0)
												select distinct i.Emp_ID,'','No',Alpha_Emp_Code,Emp_Full_Name,dm.Dept_Name,ds.Desig_Name,0,0
												from T0080_EMP_MASTER i WITH (NOLOCK)
												left join T0040_DESIGNATION_MASTER ds WITH (NOLOCK) on i.Desig_Id=ds.Desig_ID and i.Cmp_ID=ds.Cmp_Id
												left join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on i.Dept_ID=dm.Dept_Id and i.Cmp_ID=dm.Cmp_Id
												where Emp_ID=@Emp_ID
											END	
							fetch next from TRAINING_DETAILS into @Emp_ID
							End
					close TRAINING_DETAILS	
					deallocate TRAINING_DETAILS
					
	--select * from  #TRAINING_DET
	--/* GRAND TOTAL COLUMN */
	DECLARE @GrandTotalCol	NVARCHAR (MAX)
	SELECT @GrandTotalCol = COALESCE (@GrandTotalCol + 'ISNULL ([' + CAST ([Training_TypeName] AS VARCHAR) +'],0) + ', 'ISNULL([' + CAST([Training_TypeName] AS VARCHAR)+ '],0) + ')
	FROM	T0030_Hrms_Training_Type WITH (NOLOCK) where cmp_id=@cmp_id and [Training_TypeName] is not NULL ORDER BY [Training_TypeName]
	SET @GrandTotalCol = LEFT (@GrandTotalCol, LEN (@GrandTotalCol)-1)
	
		--select * from #TRAINING_DET where  Emp_ID=11
	set @query='SELECT *, ('+ @GrandTotalCol + ')
			AS [Grand Total] INTO #temp_training
			FROM
		(select tr.Emp_ID,tr.Training_type,tr.Employee_Code,tr.Emp_Full_Name,tr.Department,tr.Designation,
			i.branch_id,i.Dept_Id,i.Desig_Id,i.Grd_Id,i.Type_Id,i.Cat_id,em.cmp_id,tr.Training_Appr_id
			from #TRAINING_DET tr
			inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=tr.Emp_ID and em.Emp_Left=''N''	
			inner join T0095_INCREMENT I  WITH (NOLOCK) on i.emp_id= em.emp_id 
			and i.Increment_ID = (select max(Increment_ID) from T0095_INCREMENT i2 WITH (NOLOCK) where emp_id=em.emp_id and i2.Increment_Effective_Date=
			(select max(Increment_Effective_Date) from T0095_INCREMENT WITH (NOLOCK)  where emp_id=em.emp_id))
			where em.Cmp_id ='+ cast( @cmp_id  as varchar(18)) +'	
			group by tr.Emp_ID,tr.Training_type,tr.Employee_Code,tr.Emp_Full_Name,tr.Department,tr.Designation,
			i.branch_id,i.Dept_Id,i.Desig_Id,i.Grd_Id,i.Type_Id,i.Cat_id,em.cmp_id,tr.Training_Appr_id				
			) as s
		PIVOT
		(
			count(Training_Appr_id) 
			FOR [Training_type] IN (' + @columns + ')
		)AS m5
		
		SELECT * FROM #temp_training where cmp_id='+ cast( @cmp_id  as varchar(18)) +  @condition + ' order by [Grand Total] desc
		DROP table #temp_training'
		
		exec(@query)	
		--select * from #temp_training
END


