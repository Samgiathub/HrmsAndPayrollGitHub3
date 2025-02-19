
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Appraisal_Export_Format]
	 @cmp_id    as numeric(18,0)
	,@Initiation_Startdate   as datetime 
	,@Initiation_Todate   as datetime
	,@Dept_ID as numeric(18,0)
	,@Branch_ID as numeric(18,0)
	,@Desg_ID as numeric(18,0)
	,@Emp_ID as nvarchar(max)	
	,@flag as varchar(10)
	,@KPA_fill as numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @str1 as nvarchar(max)		
	DECLARE @emp_id1 as NUMERIC(18,0)
	DECLARE @kpacount as NUMERIC(18,0)
	
	if @flag = 'SA' OR @flag = 'ALL'
		BEGIN
		--print 'k'
		--RIGHT(convert(varchar(10), getdate(), 112), 6) + CAST(SM.SApparisal_ID AS VARCHAR(6)) AS [Content ID],
		--''="'' + em.Alpha_Emp_Code + ''"'' as[Alpha Emp Code],	
		--''="'' + RIGHT(convert(varchar(10), getdate(), 112), 6) + RIGHT(REPLICATE(''0'', 6) + CAST(SM.SApparisal_ID AS VARCHAR(6)), 6) + ''"'' as [Content ID],
			set @str1='select DISTINCT hi.EMP_ID,CONVERT(varchar(11),hi.SA_Startdate,103) as [Initiation Start Date],
			em.Alpha_Emp_Code as[Alpha Emp Code],	
			RIGHT(convert(varchar(10), getdate(), 112), 6) + RIGHT(REPLICATE(''0'', 6) + CAST(SM.SApparisal_ID AS VARCHAR(6)), 6) as [Content ID],
			CONVERT(varchar(11),sm.Effective_Date,103) as[Effective Date],sm.Content as[Content],'''' as Weightage,'''' as [Employee Score],'''' as Comments,'''' as [Manager Score],'''' as[Manager Comments]
			from T0050_HRMS_InitiateAppraisal hi WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=hi.Emp_Id 
			INNER JOIN	
					(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
					FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
						(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
						 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
							(
								SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
								FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = '+ CAST(@cmp_id as VARCHAR) +' GROUP BY EMP_ID
							) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
						 WHERE CMP_ID ='+ CAST(@cmp_id as VARCHAR) +'
						 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
					where I.Cmp_ID='+ CAST(@cmp_id as VARCHAR) +'
					)IE on ie.Emp_ID = em.Emp_ID
			INNER JOIN 
						(select m.SDept_Id,m.SApparisal_ID,M.SApparisal_Content,(m.SApparisal_Content +'':''+c.Criteria)as content,max(ISNULL(m.Effective_Date,co.From_Date))Effective_Date
						from T0040_SelfAppraisal_Master M WITH (NOLOCK)
						INNER join T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=m.Cmp_ID
						Inner join
						(SELECT
						SApparisal_ID,
						STUFF((
						SELECT  cast(ROW_NUMBER() OVER (order by SApparisal_ID) as VARCHAR) +''.''+ SAppCriteria_Content + '' ''
						FROM T0050_SA_SubCriteria WITH (NOLOCK)
						WHERE (SApparisal_ID = SE.SApparisal_ID)
						FOR XML PATH(''''),TYPE).value(''(./text())[1]'',''VARCHAR(MAX)''),1,0,'''') AS Criteria
						FROM T0050_SA_SubCriteria SE WITH (NOLOCK)
						GROUP BY SApparisal_ID)c on m.SApparisal_ID = c.SApparisal_ID						
						where m.Cmp_ID='+ CAST(@cmp_id as VARCHAR) +' group  by m.cmp_id,m.SDept_Id,m.SApparisal_ID,m.SApparisal_Content,c.Criteria)sm 
						on sm.Effective_Date <= hi.SA_Startdate	
			where hi.Cmp_Id ='+ CAST(@cmp_id as VARCHAR) +' 
			and hi.SA_Startdate between '''+ cast(@Initiation_Startdate as VARCHAR(50))+''' and
			'''+ CAST(@Initiation_Todate as VARCHAR(50))+''' and hi.Emp_Id in('+ CAST(@Emp_ID as NVARCHAR(MAX)) +')'	
			--PRINT @str1
			exec (@str1)
			--and ('''+ CONVERT(varchar(11),@Initiation_Startdate,103)+''' >= CONVERT(varchar(11),hi.SA_Startdate,103) or '''+ CONVERT(varchar(11),@Initiation_Todate,103)+''' <= CONVERT(varchar(11),hi.SA_Startdate,103))	
		END			
	if @flag = 'KPA' OR @flag = 'ALL'
		BEGIN
		--'''' as [KPA Content],'''' as [KPA Target],'''' as [KPA Weightage],'''' as [Justification for High Score]
		--''="'' +  em.Alpha_Emp_Code + ''"'' as[Alpha Emp Code],'''' as [Effective Date],			
		--''="'' + RIGHT(convert(varchar(10), getdate(), 112), 6) + RIGHT(REPLICATE(''0'', 6) + CAST(SM.KPA_ID AS VARCHAR(6)), 6) + ''"'' as [Content ID],
		if (@KPA_fill=1) --fill KPA from Master
			BEGIN
			print 'd'
			CREATE table #KPA_EMP
			(
			 Emp_ID  NUMERIC(18,0)
			 )
			 
			if @Emp_ID <> ''
			begin
				Insert Into #KPA_EMP
				select  cast(data  as numeric) from dbo.Split (@Emp_ID,',') 
			end
        	
        	CREATE table #KPA_Details
			(
			 EMP_ID  NUMERIC(18,0),
			 Initiation_Start_Date  VARCHAR(50),
			 Alpha_Emp_Code VARCHAR(250),
			 Content_ID VARCHAR(50),
			 Content VARCHAR(MAX),
			 [Target] VARCHAR(MAX),
			 Weightage  NUMERIC(18,2)
			 )
			 
        	DECLARE KPA_EMP CURSOR FOR
        		select Emp_ID from #KPA_EMP
			OPEN KPA_EMP
            fetch next from KPA_EMP into @emp_id1
            while @@fetch_status = 0
            Begin
            --print @emp_id1
                select @kpacount = count(*) FROM T0060_Appraisal_EmployeeKPA E WITH (NOLOCK) left join 
					 T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) on I.Emp_Id = e.Emp_Id inner JOIN
					 (select isnull(max(effective_date),
							(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))effective_date,
							Emp_Id
						from T0060_Appraisal_EmployeeKPA WITH (NOLOCK)
						where Emp_Id=@emp_id1
						GROUP by Emp_Id) E1 on E1.Emp_Id = e.Emp_Id and E.Effective_Date = e1.effective_date 
				WHERE e.emp_id =@emp_id1 and E.Effective_Date <= i.SA_Startdate and
				E.Effective_Date between @Initiation_Startdate and	@Initiation_Todate
				
				print @kpacount
				
				if @kpacount > 0
				BEGIN
				print 's'
				insert into #KPA_Details  
				select DISTINCT hi.EMP_ID,CONVERT(varchar(11),hi.SA_Startdate,103),
						em.Alpha_Emp_Code,RIGHT(convert(varchar(10), getdate(), 112), 6) + RIGHT(REPLICATE('0', 6) + CAST(SM.Emp_KPA_Id AS VARCHAR(6)), 6),
						KPA_Content,KPA_Target,KPA_Weightage
					from T0050_HRMS_InitiateAppraisal hi WITH (NOLOCK)
					INNER JOIN T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=hi.Emp_Id 
					INNER JOIN	
							(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
							FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
								(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
								 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
									(
										SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
										FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
									) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
								 WHERE CMP_ID =@cmp_id
								 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
							where I.Cmp_ID=@cmp_id
							)IE on ie.Emp_ID = em.Emp_ID
					INNER JOIN 
								(select A.cmp_id,A.Emp_KPA_Id,A.KPA_Content,A.KPA_Target,max(ISNULL(A.Effective_Date,co.From_Date))Effective_Date,A.KPA_Weightage
								from T0060_Appraisal_EmployeeKPA A WITH (NOLOCK) 
								INNER JOIN T0010_COMPANY_MASTER co WITH (NOLOCK) on A.Cmp_ID=co.Cmp_Id	
								where A.emp_ID=@emp_id1 and A.Effective_Date<= @Initiation_Startdate
								and A.Cmp_ID=@cmp_id group  by A.cmp_id,A.Emp_KPA_Id,A.KPA_Content,A.KPA_Weightage,A.KPA_Target)sm 
								on sm.Effective_Date <= hi.SA_Startdate
					where hi.Cmp_Id =@cmp_id
					and hi.SA_Startdate between @Initiation_Startdate and @Initiation_Todate and hi.Emp_ID in (@emp_id1)
					 --and hi.Emp_ID in ('+ CAST(@Emp_ID as NVARCHAR(MAX)) +')
					--PRINT @str1
					--exec (@str1)						
				END
			ELSE
				BEGIN
					print 'k'
					insert into #KPA_Details  
					select DISTINCT hi.EMP_ID,CONVERT(varchar(11),hi.SA_Startdate,103),
						em.Alpha_Emp_Code,		
						RIGHT(convert(varchar(10), getdate(), 112), 6) + RIGHT(REPLICATE('0', 6) + CAST(SM.KPA_ID AS VARCHAR(6)), 6),
						KPA_Content,KPA_Target,KPA_Weightage
					from T0050_HRMS_InitiateAppraisal hi WITH (NOLOCK)
					INNER JOIN T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=hi.Emp_Id 
					INNER JOIN	
							(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
							FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
								(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
								 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
									(
										SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
										FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID =@cmp_id GROUP BY EMP_ID
									) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
								 WHERE CMP_ID =@cmp_id
								 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
							where I.Cmp_ID=@cmp_id
							)IE on ie.Emp_ID = em.Emp_ID
					INNER JOIN 
								(select A.cmp_id,A.Dept_Id,A.Desig_Id,A.KPA_ID,A.KPA_Content,A.KPA_Target,max(ISNULL(A.Effective_Date,co.From_Date))Effective_Date,A.KPA_Weightage
								from T0051_KPA_Master A WITH (NOLOCK)
								INNER JOIN T0010_COMPANY_MASTER co WITH (NOLOCK) on A.Cmp_ID=co.Cmp_Id	
								where  A.Effective_Date <= @Initiation_Startdate
								and A.Cmp_ID=@cmp_id group  by A.cmp_id,A.Dept_Id,A.KPA_ID,A.KPA_Content,A.KPA_Weightage,A.Desig_Id,A.KPA_Target)sm 
								on sm.Effective_Date <= hi.SA_Startdate
					INNER JOIN T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on ie.Dept_ID=dm.Dept_Id and dm.Dept_Id in(select data from dbo.Split(sm.Dept_Id,'#'))	
					INNER JOIN T0040_DESIGNATION_MASTER ds WITH (NOLOCK) on ie.Desig_Id=ds.Desig_ID and ds.Desig_ID in(select data from dbo.Split(sm.Desig_Id,'#'))	
					where hi.Cmp_Id =@cmp_id and hi.SA_Startdate between @Initiation_Startdate and	@Initiation_Todate and hi.Emp_ID in (@emp_id1)
					--PRINT @str1					
					--exec (@str1)	
				END					
				fetch next from KPA_EMP into @emp_id1
                        End
                close KPA_EMP 
                deallocate KPA_EMP                
              
                select EMP_ID as [EMP_ID],Initiation_Start_Date as [Initiation Start Date],Alpha_Emp_Code as [Alpha Emp Code],
                Content_ID as [Content ID],'' as [Effective Date],Content,[Target],Weightage,'' as [Employee Score],
				'' as [Comments],'' as [Manager Score],'' as[Manager Comments] from #KPA_Details
			END		
			
		ELSE
			BEGIN
				set @str1='select DISTINCT hi.EMP_ID,CONVERT(varchar(11),hi.SA_Startdate,103) as [Initiation Start Date],
					em.Alpha_Emp_Code as[Alpha Emp Code],'''' as [Effective Date],			
					'''' as [Content],'''' as [Target],'''' as [Weightage],'''' as [Employee Score],
					'''' as [Comments],'''' as [Manager Score],'''' as[Manager Comments]
				from T0050_HRMS_InitiateAppraisal hi WITH (NOLOCK) 
				INNER JOIN T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=hi.Emp_Id 
				INNER JOIN	
						(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
						FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
							(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
							 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
								(
									SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
									FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = '+ CAST(@cmp_id as VARCHAR) +' GROUP BY EMP_ID
								) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
							 WHERE CMP_ID = '+ CAST(@cmp_id as VARCHAR) +'
							 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
						where I.Cmp_ID='+ CAST(@cmp_id as VARCHAR) +'
						)IE on ie.Emp_ID = em.Emp_ID
				where hi.Cmp_Id = '+ CAST(@cmp_id as VARCHAR) +' 
				and hi.SA_Startdate between '''+ CAST(@Initiation_Startdate as VARCHAR(50)) +''' and
				'''+ CAST(@Initiation_Todate as VARCHAR(50))+'''
				and hi.Emp_ID in ('+ CAST(@Emp_ID as NVARCHAR(MAX)) +')'
				
				exec (@str1)	
			END
			--and hi.SA_Startdate >=@Initiation_Startdate and hi.SA_Startdate<=@Initiation_Todate
		END
	if @flag = 'PA' OR @flag = 'ALL'
		BEGIN
		--'''' as [Employee Score],'''' as Comments,
			set @str1='select DISTINCT hi.EMP_ID,CONVERT(varchar(11),hi.SA_Startdate,103) as [Initiation Start Date],
				em.Alpha_Emp_Code as[Alpha Emp Code],			
				RIGHT(convert(varchar(10), getdate(), 112), 6) + RIGHT(REPLICATE(''0'', 6) + CAST(SM.PA_ID AS VARCHAR(6)), 6) as [Content ID],
				CONVERT(varchar(11),sm.Effective_Date,103) as[Effective Date],sm.PA_Title as[Content],
				sm.PA_Weightage as[Weightage],'''' as [Manager Rating],'''' as[Manager Comments]
			from T0050_HRMS_InitiateAppraisal hi WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=hi.Emp_Id 
			INNER JOIN	
					(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
					FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
						(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
						 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
							(
								SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
								FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = '+ CAST(@cmp_id as VARCHAR) +' GROUP BY EMP_ID
							) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
						 WHERE CMP_ID = '+ CAST(@cmp_id as VARCHAR) +'
						 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
					where I.Cmp_ID='+ CAST(@cmp_id as VARCHAR) +'
					)IE on ie.Emp_ID = em.Emp_ID
			INNER JOIN 
						(select A.cmp_id,A.PA_DeptId,A.PA_ID,A.PA_Title,max(ISNULL(A.PA_EffectiveDate,co.From_Date))Effective_Date,A.PA_Weightage
						from T0040_HRMS_AttributeMaster A WITH (NOLOCK)
						INNER JOIN T0010_COMPANY_MASTER co WITH (NOLOCK) on A.Cmp_ID=co.Cmp_Id	
						where A.Cmp_ID='+ CAST(@cmp_id as VARCHAR) +' and a.PA_Type=''PoA'' group  by A.cmp_id,A.PA_DeptId,A.PA_ID,A.PA_Title,A.PA_Weightage)sm 
						on sm.Effective_Date <= hi.SA_Startdate
			INNER JOIN T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on ie.Dept_ID=dm.Dept_Id and dm.Dept_Id in(select data from dbo.Split(sm.PA_DeptId,''#''))			
			where hi.Cmp_Id = '+ CAST(@cmp_id as VARCHAR) +' 
			and SA_Startdate between '''+ CAST(@Initiation_Startdate as VARCHAR(50)) +''' and '''+ CAST(@Initiation_Todate as VARCHAR(50)) + '''		
			and hi.Emp_ID in ('+ CAST(@Emp_ID as NVARCHAR(MAX)) +')'
			
			exec (@str1)	
			--and hi.SA_Startdate >=@Initiation_Startdate and hi.SA_Startdate<=@Initiation_Todate
		END
	
		
	--if @flag = 'ALL'
	--BEGIN
		set @str1='SELECT distinct hi.EMP_ID FROM T0050_HRMS_InitiateAppraisal hi WITH (NOLOCK)
		INNER JOIN T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=hi.Emp_Id 
		where hi.Cmp_Id = '+ CAST(@cmp_id as VARCHAR) +' and hi.Emp_ID in ('+ CAST(@Emp_ID as NVARCHAR(MAX)) +') 
		and hi.SA_Startdate between '''+ cast(@Initiation_Startdate as VARCHAR(50))+''' and
		'''+ CAST(@Initiation_Todate as VARCHAR(50))+''''
		
		exec (@str1)	
	--END
END

