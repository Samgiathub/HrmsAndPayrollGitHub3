

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Rpt_ApprisalNew_Summary_Format2]
	@cmp_id    as numeric(18,0)
	,@deptId    as numeric(18,0)=null
	,@emp_id    as numeric(18,0)=null
	,@frmdate   as datetime 
	,@enddate   as datetime = getdate
	,@Constraint	varchar(max)
	,@dyQuery   varchar(max)=''
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN
	

	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		BEGIN
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		END
	ELSE
		BEGIN
			INSERT INTO @Emp_Cons
			SELECT emp_id FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE Cmp_ID=@cmp_id and  SA_Startdate between @frmdate and @enddate
		END
	
	DECLARE @selected_Year  INT
		set @selected_Year = DATEPART(YEAR,@frmdate)
	DECLARE @empid  NUMERIC(18,0)
	DECLARE @columnname VARCHAR(MAX)
	set @columnname = ''
	DECLARE	@SqlQuery  VARCHAR(MAX)	
	set @SqlQuery =''
	
	declare @Incid as INTEGER 
	
	declare @year as INTEGER 
	declare @Srno as INTEGER 
	set @Srno = 1
		
	CREATE TABLE #FinalTable
	(
		 Emp_Id			NUMERIC(18,0)
		,EmployeeCode	VARCHAR(100)
		,EmployeeName	VARCHAR(100)
		,Department		VARCHAR(100)
		,JoiningDate	VARCHAR(12)
		,Srno			INT
		,Year			INT
	)
		
	
	set @columnname = CAST(@selected_Year-2 as VARCHAR )
	set @SqlQuery = ' Alter  Table  #FinalTable ADD
					  Designation$' + @columnname + ' Varchar(100),' +
					 'Increment_Percentage$' + @columnname + ' Numeric(18,2),' +
					 'Salary_With_Perks_PM$' + @columnname + ' Numeric(18,2),' +
					 'Increase_In_CTC_PM$' + @columnname + ' Numeric(18,2)'
	EXEC(@SqlQuery)
	
	set @columnname = ''
	set @SqlQuery =''
	set @columnname = CAST(@selected_Year-1 as VARCHAR )
	set @SqlQuery = ' Alter  Table  #FinalTable ADD
					  Designation$' + @columnname + ' Varchar(100),' +
					 'Increment_Percentage$' + @columnname + ' Numeric(18,2),' +
					 'Salary_With_Perks_PM$' + @columnname + ' Numeric(18,2),' +
					 'Increase_In_CTC_PM$' + @columnname + ' Numeric(18,2)'
	EXEC(@SqlQuery)			 
					 
					 
	set @columnname = ''
	set @SqlQuery =''
	set @columnname = CAST(@selected_Year as VARCHAR )
	set @SqlQuery = ' Alter  Table  #FinalTable ADD
					  Designation$' + @columnname + ' Varchar(100),' +
					 'Increment_Percentage$' + @columnname + ' Numeric(18,2),' +
					 'Salary_With_Perks_PM$' + @columnname + ' Numeric(18,2),' +
					 'Increase_In_CTC_PM$' + @columnname + ' Numeric(18,2)'
	EXEC(@SqlQuery)	
	
	set @columnname = ''
	set @SqlQuery =''
	set @columnname = 'EFP'
	set @SqlQuery = ' Alter  Table  #FinalTable ADD
					  YorN$' + @columnname + ' Varchar(10),' +
					 'UpgradationPromotion$' + @columnname + ' Varchar(100),' +
					 'Salary_With_Perks_PM$' + @columnname + ' Numeric(18,2),' +
					 'Hike_DiffAmt$' + @columnname + ' Numeric(18,2),' +
					 'Hiked_CTC_PM$' + @columnname + ' Numeric(18,2)'
	EXEC(@SqlQuery)	
	set @SqlQuery = ''		
		 
	DECLARE cur CURSOR
		FOR
			select Emp_Id 
			from @Emp_Cons 
	OPEN cur
		Fetch next from cur into @empid
		While @@fetch_status = 0
			BEGIN		
				set @Srno = 1
				declare inicur CURSOR
					for 
						select DATEPART(YYYY,Increment_Effective_Date),Increment_ID from T0095_INCREMENT WITH (NOLOCK) where Emp_ID= @empid and DATEPART(yyyy,Increment_Effective_Date)>=(@selected_Year-2)
						order by Increment_Effective_Date
					open inicur
					fetch next from inicur into @year,@Incid
					while @@fetch_status =0 
						BEGIN
						
							if NOT EXISTS(select 1 from #FinalTable where Emp_Id = @empid)
								BEGIN
									set @columnname = CAST(@year as VARCHAR )
									set @SqlQuery ='INSERT INTO #FinalTable (Emp_Id,EmployeeCode,EmployeeName,Department,JoiningDate,Year,Srno,Designation$' + @columnname +',Increment_Percentage$'+ @columnname +'
													,Salary_With_Perks_PM$'+ @columnname +',Increase_In_CTC_PM$'+ @columnname +')
													SELECT  E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,D.Dept_Name,CONVERT(VARCHAR(12),E.Date_Of_Join,103),'+ cast(@year as varchar) +','+ cast(@Srno as varchar) +',dg.Desig_Name,oIn.Increment_Per,
													oIn.Incerment_Amount_Gross,oIn.CTC
													FROM T0080_EMP_MASTER E WITH (NOLOCK)  INNER JOIN --ON E.Emp_ID = EC.Emp_ID
														 T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = E.Emp_ID and I.Increment_Effective_Date = (SELECT max(Increment_Effective_Date) FROM T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = E.Emp_Id) Left JOIN
														 T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = I.Dept_ID INNER JOIN
														 T0095_INCREMENT oIn WITH (NOLOCK) on oIn.Emp_ID ='+ cast(@empid  as VARCHAR(18)) + ' and oIn.increment_id ='+ CAST(@Incid as VARCHAR(18)) +' INNER JOIN
														 T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = oIn.Desig_Id 
													WHERE E.Emp_ID ='+ cast(@empid  as VARCHAR(18)) 
															
								END
							ELSE
								BEGIN  
									set @columnname = 'Designation$' +CAST(@year as VARCHAR )									
									if Not EXISTS (select * from #FinalTable where year = @year and Emp_Id=@empid)
										BEGIN 
											set @columnname=''
											set @columnname = CAST(@year as VARCHAR )
											set @SqlQuery ='Update #FinalTable
															set Designation$' + @columnname + '= n.Desig_Name
																,Increment_Percentage$'+ @columnname +'= n.Increment_Per
																,Salary_With_Perks_PM$'+ @columnname +'= n.Incerment_Amount_Gross
																,Increase_In_CTC_PM$'+ @columnname +'= n.CTC
																,year = '+ CAST(@year as VARCHAR ) +'
															From (SELECT  DG.Desig_Name,oIn.Increment_Per,oIn.Incerment_Amount_Gross,oIn.CTC
																  From T0095_INCREMENT oIn WITH (NOLOCK) INNER  JOIN
																	   T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = oIn.Desig_Id 
																  WHERE emp_id='+ CAST(@empid as VARCHAR(18)) +'  and oIn.increment_id ='+ CAST(@Incid as VARCHAR(18))+')n
															WHERE emp_id = '+ CAST(@empid as VARCHAR(18)) +' and Srno=(select min(srno) from #FinalTable where emp_id = '+ CAST(@empid as VARCHAR(18)) +' and Designation$' + @columnname + ' is null)' 
												--exec (@SqlQuery)
										END
									Else
										BEGIN
											set @columnname=''
											set @columnname = CAST(@year as VARCHAR )
											set @SqlQuery ='INSERT INTO #FinalTable (Emp_Id,EmployeeCode,EmployeeName,Department,JoiningDate,Year,Srno,Designation$' + @columnname +',Increment_Percentage$'+ @columnname +'
													,Salary_With_Perks_PM$'+ @columnname +',Increase_In_CTC_PM$'+ @columnname +')
													SELECT  E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,D.Dept_Name,CONVERT(VARCHAR(12),E.Date_Of_Join,103),'+ cast(@year as varchar)+','+ cast(@Srno as varchar) +',dg.Desig_Name,oIn.Increment_Per,
													oIn.Incerment_Amount_Gross,oIn.CTC
													FROM T0080_EMP_MASTER E WITH (NOLOCK)  INNER JOIN --ON E.Emp_ID = EC.Emp_ID
														 T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = E.Emp_ID and I.Increment_Effective_Date = (SELECT max(Increment_Effective_Date) FROM T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = E.Emp_Id) Left JOIN
														 T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = I.Dept_ID INNER JOIN
														 T0095_INCREMENT oIn WITH (NOLOCK) on oIn.Emp_ID ='+ cast(@empid  as VARCHAR(18)) + ' and oIn.increment_id ='+ CAST(@Incid as VARCHAR(18)) +' INNER JOIN
														 T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = oIn.Desig_Id 
													WHERE E.Emp_ID ='+ cast(@empid  as VARCHAR(18)) 
											--print (@SqlQuery)
										END
								END
								exec (@SqlQuery)
								set @Srno = @Srno +1
								--print (@SqlQuery)	
								set @SqlQuery=''
								set @columnname =''										
							fetch next from inicur into @year,@Incid
						END
					close inicur
					DEALLOCATE inicur	
					
					set @columnname = 'EFP'
					set @SqlQuery ='Update #FinalTable
									set YorN$' + @columnname + '= n.Promo_YesNo
										,UpgradationPromotion$'+ @columnname +'= n.Desig_Name																
									From (SELECT  DG.Desig_Name,case when Promo_YesNo = 1 then ''Yes'' else ''No'' end Promo_YesNo
										  From T0050_HRMS_InitiateAppraisal oIn WITH (NOLOCK) INNER  JOIN
											   T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = oIn.Promo_Desig 
										  WHERE emp_id='+ CAST(@empid as VARCHAR(18)) +' and SA_Startdate between '''+ CONVERT(VARCHAR,@frmdate,106) +''' and '''+ CONVERT(VARCHAR,@enddate,106) +''')n
									WHERE emp_id = '+ CAST(@empid as VARCHAR(18)) +' and Srno=1' 
					print (@SqlQuery)
					exec (@SqlQuery)
					set @SqlQuery=''
					set @columnname =''				
				Fetch next from cur into @empid
			END
	close cur
	DEALLOCATE cur
	
	update #FinalTable
	set emp_id=NULL
	    ,EmployeeCode = NULL
	    ,EmployeeName = NULL
	    ,Department   = NULL
	    ,JoiningDate  = NULL
	Where Srno<>1
	
	SELECT * 
	FROM #FinalTable
	
	DROP TABLE #FinalTable
END

