--05/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_SCHEME_DETAILS_ESS_GET_RECRUITMENT]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	,@Constraint	varchar(max)
	,@Report_Type	VARCHAR(20)	= ''	--Ankit 21012016

AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	IF @Branch_ID = 0  
		set @Branch_ID = null
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

		

set @To_Date=GETDATE()
	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
		
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#')
		end
	else
		begin
			Insert Into @Emp_Cons
			select distinct I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join
			dbo.T0095_emp_scheme MS WITH (NOLOCK) on MS.Emp_ID = I.Emp_ID	inner join
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where i.Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
		end
CREATE table #SCHEME
	(
	e_id		numeric,
	sc_type Varchar(50),
	scheme_ID numeric
	)
		
CREATE table #EMPSCHEME
	(
				cmp_id1 numeric,
				Cmp_Name Varchar(250),
				Cmp_Address Varchar(250),
				Emp_ID1		numeric,
				branch_id		numeric,
				Alpha_Emp_Code varchar(25),
				Emp_Full_Name varchar(250),
				Scheme_Id numeric,
				Leave varchar(250),
				Scheme_Type Varchar(50),
				Scheme_Name Varchar(50),
				Effective_Date datetime,
				rpt_level numeric,
				Rpt_Mgr_1 Varchar(500),
				Rpt_Mgr_2 Varchar(200),
				Rpt_Mgr_3 Varchar(200),
				Rpt_Mgr_4 Varchar(200),
				Rpt_Mgr_5 Varchar(200),
				Rpt_Mgr_6 Varchar(200),
				Rpt_Mgr_7 Varchar(200),
				Rpt_Mgr_8 Varchar(200),
				Emp_First_Name varchar(250),
				Max_Level Int
	)
	
	----------------------------------------------------------------
		
	Declare @Columns nvarchar(2000)
	Declare	@cmp_id1 numeric
	Declare	@Emp_ID1 numeric
	declare @Emp_Code varchar(25)
	declare	@Emp_Name varchar(250)
	declare @Scheme_Id numeric
	declare	@Leave varchar(250)
	Declare	@Scheme_Type Varchar(50)
	Declare	@rpt_level Varchar(50)
	Declare	@Effective_Date datetime
	declare @Cmp_Name Varchar(250)
	declare @Cmp_Address Varchar(250)
	Declare @Rpt_Mgr_1 Varchar(500)
	Declare @Rpt_Mgr_2 Varchar(200)
	Declare	@Rpt_Mgr_3 Varchar(200)
	Declare @Rpt_Mgr_4 Varchar(200)
	Declare	@Rpt_Mgr_5 Varchar(200)
	Declare	@Rpt_Mgr_6 Varchar(200)
	Declare	@Rpt_Mgr_7 Varchar(200)
	Declare	@Rpt_Mgr_8 Varchar(200)
	Declare	@emp_full_name Varchar(250)	
	Declare	@emp_First_Name Varchar(250)	
	Declare @val nvarchar(500)
	Declare	@Emp_ID2 numeric
	declare @leave1 varchar(250)
	declare @Scheme_Id1 numeric
	declare @branch_Id1 numeric
	declare @temp xml
	declare @temp1 xml
	
	declare @rm_name varchar(250)
	declare @e_id numeric
	declare @sc_type varchar(50)
	declare @scheme_name varchar(50)
	declare @HOD as numeric
	declare @e_scheme_ID numeric
	Set @Columns = '#'

	declare @non_mandatory bit --binal	
	Declare @Is_display_rpt_level as bit --binal
	
IF ISNULL(@Report_Type,'') <> ''	-- Get Trainee/Probation	-- Ankit 27022016
	BEGIN
	
		DECLARE Emp_Scheme CURSOR FOR
		select distinct es.emp_id,es.[Type],es.Scheme_ID from T0095_EMP_SCHEME es WITH (NOLOCK)
			inner join T0080_EMP_MASTER emp WITH (NOLOCK) on emp.Emp_ID=es.Emp_ID and emp.Cmp_ID=es.cmp_id
			inner join ( select max(effective_date) as effective_date,emp_id ,IES.Type from T0095_EMP_SCHEME IES WITH (NOLOCK)
							where Cmp_ID = @cmp_id and Emp_ID in (select * from @Emp_Cons) and effective_date <=@From_Date AND IES.Type = @Report_Type
							GROUP by emp_id,Type
						) Tbl1 ON Tbl1.Emp_ID = es.Emp_ID AND es.Effective_Date = Tbl1.effective_date And es.Type = Tbl1.Type
			where es.Emp_ID in (select * from @Emp_Cons) and es.Cmp_ID=@cmp_id and es.effective_date <=@From_Date AND es.Type = @Report_Type
	END
ELSE
	BEGIN	
		DECLARE Emp_Scheme CURSOR FOR
		--select distinct es.emp_id,es.[Type] from T0095_EMP_SCHEME es
		--					inner join T0080_EMP_MASTER emp on emp.Emp_ID=es.Emp_ID and emp.Cmp_ID=es.cmp_id
		--					inner join(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES
		--																where Cmp_ID = @cmp_id and Emp_ID in (select * from @Emp_Cons) and effective_date <=@From_Date
		--																GROUP by emp_id) Tbl1 ON Tbl1.Emp_ID = es.Emp_ID 
		--					where es.Emp_ID in (select * from @Emp_Cons) and es.Cmp_ID=@cmp_id and es.effective_date <=@From_Date
							
		select distinct es.emp_id,es.[Type],es.Scheme_ID from T0095_EMP_SCHEME es WITH (NOLOCK)
			inner join T0080_EMP_MASTER emp WITH (NOLOCK) on emp.Emp_ID=es.Emp_ID and emp.Cmp_ID=es.cmp_id
			inner join(select max(effective_date) as effective_date,emp_id ,IES.Type from T0095_EMP_SCHEME IES WITH (NOLOCK)
														where Cmp_ID = @cmp_id and Emp_ID in (select * from @Emp_Cons) and effective_date <=@From_Date
														GROUP by emp_id,Type) Tbl1 ON Tbl1.Emp_ID = es.Emp_ID AND es.Effective_Date = Tbl1.effective_date And es.Type = Tbl1.Type
			where es.Emp_ID in (select * from @Emp_Cons) and es.Cmp_ID=@cmp_id and es.effective_date <=@From_Date
	END			
OPEN Emp_Scheme
		fetch next from Emp_Scheme into @e_id,@sc_type,@e_scheme_ID
			while @@fetch_status = 0
				Begin
					set @Is_display_rpt_level =1--binal
				set @non_mandatory=0 --binal
				insert into #SCHEME values(@e_id,@sc_type,@e_scheme_ID)
				fetch next from Emp_Scheme into @e_id,@sc_type,@e_scheme_ID
			End
			--select * from #SCHEME				
	close Emp_Scheme	
	deallocate Emp_Scheme
--select * from #SCHEME	
	DECLARE @Manager_HR INT	
		
	DECLARE Emp_Scheme_Cursor CURSOR FOR
		--(select * from @Emp_Cons)
		(select * from #SCHEME)			
	OPEN Emp_Scheme_Cursor
			fetch next from Emp_Scheme_Cursor into @emp_id1,@sc_type,@e_scheme_ID
		
			while @@fetch_status = 0
				Begin
				set @Is_display_rpt_level =1--binal
				set @non_mandatory=0 --binal

					insert into #EMPSCHEME (emp_id1,Scheme_Type,Scheme_Id,Rpt_Mgr_1,Rpt_Mgr_2,Rpt_Mgr_3,Rpt_Mgr_4,Rpt_Mgr_5,Rpt_Mgr_6,Rpt_Mgr_7,Rpt_Mgr_8,Max_Level)
					values	(@emp_id1,@sc_type,@e_scheme_ID,'','','','','','','','',1)
				
								
				select @Scheme_Id1=es.Scheme_ID,@Effective_Date=es.Effective_Date,@Scheme_Type=es.[Type],@Emp_Code=emp.Alpha_Emp_Code,@Emp_Name=Emp_Full_Name,
				@cmp_name=c.Cmp_Name,@cmp_address=Cmp_Address,@branch_Id1=emp.Branch_ID,@scheme_name=sm.Scheme_Name from T0095_EMP_SCHEME es WITH (NOLOCK)
				inner join T0040_Scheme_Master sm WITH (NOLOCK) on es.Scheme_ID=sm.Scheme_Id and es.Cmp_ID=sm.Cmp_Id
				inner join T0080_EMP_MASTER emp WITH (NOLOCK) on emp.Emp_ID=es.Emp_ID and emp.Cmp_ID=es.cmp_id
				inner join T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id=emp.Cmp_ID 
				where es.Emp_ID=@emp_id1 and es.Cmp_ID=@cmp_id and es.[Type]=@sc_type  and es.effective_date <=@From_Date and es.Scheme_ID = @e_scheme_ID
								
				set @emp_full_name=''
				set @emp_First_Name=''
				set @temp=''
				set @temp1=''
				set @emp_id2=0
				set @rm_name=''
				
								
				update 	#EMPSCHEME
				set  Scheme_Id=@Scheme_Id1,Effective_Date=@Effective_Date,Alpha_Emp_Code=@Emp_Code,Emp_Full_Name=@Emp_Name,Scheme_Type=@Scheme_Type,
				Cmp_Name=@Cmp_Name,Cmp_Address=@Cmp_Address,cmp_id1=@cmp_id,branch_Id=@branch_Id1,Scheme_Name=@scheme_name
				where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
					set @emp_full_name=''	
					set @emp_First_Name=''	
					
							
				
				if exists(select 1 from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and ( Is_RM = 1 or  Is_PRM=1)  and Scheme_Id=@Scheme_Id1 and Rpt_Level=1)
						begin
								set @temp=''
								set @rm_name=''	
								declare @Is_PRM_level1 as tinyint
								set @Is_PRM_level1=0
								
								select @Is_PRM_level1 = Is_PRM from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Is_PRM=1 and Rpt_Level=1
															
								if (@Is_PRM_level1 = 1)
									Begin	
								
										SET @temp = (SELECT DISTINCT ((convert(nvarchar,E.Alpha_Emp_Code)) + '-' + (convert(nvarchar,E.EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E WITH (NOLOCK)  INNER JOIN 
											t0080_emp_master ERD WITH (NOLOCK) on Erd.manager_Probation = E.Emp_id
										WHERE ERD.EMP_ID =@Emp_ID1  for xml path (''))
									End	
								else
									begin
										SET @temp=(SELECT DISTINCT ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
											T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN	--Ankit 28012015
											(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												 WHERE Effect_Date <= GETDATE()
												 GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
											ON E.EMP_ID= ERD.R_EMP_ID 
											WHERE ERD.EMP_ID =@Emp_ID1  for xml path (''))								
									end								
								
								set @rm_name=LEFT(cast(@temp as varchar(500)), LEN(cast(@temp as varchar(500))) - 1)
								
								if @rm_name is null or @rm_name=''
									set @rm_name='Reporting Manager'
								
								update 	#EMPSCHEME
								set  Rpt_Mgr_1=@rm_name
								where Emp_ID1=@Emp_ID1  and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID								
							end
					else if exists(select 1 from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Is_HOD=1 and Scheme_Id=@Scheme_Id1 and Rpt_Level=1)
							begin							
								declare @Is_Hod_lvl1 as tinyint
								set @Is_Hod_lvl1=0									
								set @temp=''	
								set @temp1=''
								set @rm_name=''	
								
								select @HOD=Dept_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1	
								select @Is_Hod_lvl1=Is_HOD from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Is_HOD=1 and Rpt_Level=3
								
								if 	@Is_Hod_lvl1=0
									Begin		
										select @branch_Id1=Branch_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1		
										set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E WITH (NOLOCK)
										INNER JOIN T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
										(select max(effective_date) as effective_date,Branch_ID from T0095_MANAGERS IES WITH (NOLOCK)
																	where Cmp_ID = @cmp_id and Branch_ID =@branch_Id1  
																	GROUP by Branch_ID) Tbl1 ON Tbl1.Branch_ID = @branch_Id1 and erd.effective_date=tbl1.effective_date
				        				WHERE ERD.Branch_ID=@branch_Id1 for xml path (''))
				        			End				        		
				        		Else
				        			Begin
				        				set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E WITH (NOLOCK) 
										INNER JOIN T0095_Department_Manager ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
										(select max(effective_date) as effective_date,Dept_ID from T0095_Department_Manager IES WITH (NOLOCK)
																	where Cmp_ID = @cmp_id and Dept_ID =@HOD  
																	GROUP by Dept_ID) Tbl1 ON Tbl1.Dept_ID = @HOD and erd.effective_date=tbl1.effective_date
				        				WHERE ERD.Dept_ID=@HOD for xml path (''))
				        			End
								set @rm_name=LEFT(cast(@temp as varchar(200)), LEN(cast(@temp as varchar(200))) - 1)
											if @rm_name is null or @rm_name=''
												set @rm_name='Department Manager'
										
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
												else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal											
				        						update 	#EMPSCHEME
												set  Rpt_Mgr_3=@rm_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
											end	
										end
					else if exists(select * from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Is_HR = 1 and Scheme_Id=@Scheme_Id1 and Rpt_Level=1)--Added by Mukti(05072019)to Select HR for Recruitment scheme
							begin
								IF exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) WHERE Is_HR = 1 and cmp_id=@cmp_id AND ISNULL(branch_id_multi,'') <> '' and Branch_id_multi <> 0)
									BEGIN			 	
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)
										where Is_HR = 1 and cmp_id=@cmp_id AND  ISNULL(branch_id_multi,'') <> '' AND
										@branch_Id1	 IN (SELECT     cast(data AS numeric(18, 0))
												 FROM          dbo.Split(ISNULL(branch_id_multi, ''), '#')
												 WHERE      data <> '')
									END
								ELSE
									BEGIN
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK) where Is_HR = 1 and cmp_id=@cmp_id										
									END			 
								set @emp_full_name=''	
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM  dbo.T0080_EMP_MASTER em WITH (NOLOCK) WHERE em.Emp_ID=@Manager_HR														
					  		
					     		update 	#EMPSCHEME
								set  Rpt_Mgr_1=@emp_full_name
								where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
							END		
						else
								begin								
										set @emp_full_name=''	
										set @emp_first_name=''	
											SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, '')), @emp_First_Name=Emp_First_Name
											FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
											WHERE      (em.Emp_ID =
											(SELECT    App_Emp_ID
											FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK)
					     					WHERE      Scheme_Id = @Scheme_Id1 and Cmp_ID=@cmp_id  and rpt_level=1))
					  		
					     					update 	#EMPSCHEME
											set  Rpt_Mgr_1=@emp_full_name
											where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
									end
																
					if exists(select 1 from T0050_Scheme_Detail  WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and (Is_BM=1 or Is_HOD=1 or Is_PRM=1 or Is_RMToRM =1) and Rpt_Level=2)
							begin
								declare @Is_Hod_chk as tinyint
								declare @Is_PRM as Tinyint
								declare @Is_RMToRM as Tinyint
								DECLARE @Is_BM	as TINYINT
							
								set @Is_PRM = 0
								set @Is_Hod_chk=0
								set @temp1=''
								set @temp=''
								set @rm_name=''	
									select @HOD=Dept_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1	
									select @Is_Hod_chk=Is_HOD,@Is_PRM = Is_PRM
											,@Is_RMToRM = Is_RMToRM,@Is_BM = Is_BM
									from   T0050_Scheme_Detail  WITH (NOLOCK)
									where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 
											and (Is_BM=1 or Is_HOD=1 or Is_PRM=1 or Is_RMToRM =1) and Rpt_Level=2								
								
								
									if 	(@Is_Hod_chk=0 and @Is_PRM = 0 and @Is_BM = 1)
									Begin	
								
										--select @branch_Id1=Branch_ID from T0080_emp_master where Emp_ID=@Emp_ID1		
										--Added by Jaina 18-03-2017
										select	@branch_Id1 = Branch_ID 
										FROM	T0095_INCREMENT I1 WITH (NOLOCK)
												INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
															FROM	T0095_INCREMENT I2 WITH (NOLOCK)
																	INNER JOIN (
																				SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																				FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																				WHERE	I3.Increment_Effective_Date <= @To_Date
																				GROUP BY I3.Emp_ID
																			) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
														WHERE	I2.Cmp_ID = @Cmp_Id 
														GROUP BY I2.Emp_ID
														) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
										WHERE	I1.Cmp_ID=@Cmp_Id and i1.Emp_ID = @Emp_ID1
									
										set @temp1=	(
															SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
															FROM	T0080_EMP_MASTER E WITH (NOLOCK) 	INNER JOIN 
																	T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
																	(
																		select	max(effective_date) as effective_date,Branch_ID 
																		from	T0095_MANAGERS IES WITH (NOLOCK)
																		where	Cmp_ID = @cmp_id and Branch_ID =@branch_Id1  
																		GROUP by Branch_ID
																	) Tbl1 ON Tbl1.Branch_ID = @branch_Id1 and erd.effective_date=tbl1.effective_date
		        											WHERE	ERD.Branch_ID=@branch_Id1 for xml path ('')
		        									)
									End	
									else if (@Is_PRM = 1)
											Begin	
										
													SET @temp1=(SELECT	DISTINCT ((convert(nvarchar,E.Alpha_Emp_Code)) + '-' + (convert(nvarchar,E.EMP_FULL_NAME))) + ', ' 
																FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
																		t0080_emp_master ERD WITH (NOLOCK) on Erd.manager_Probation = E.Emp_id
																WHERE	ERD.EMP_ID =@Emp_ID1  for xml path (''))
											End	
										-------------Added By Jimit 16122017  For RMTORM-----------
											ELse If (@Is_Hod_chk=0 and @Is_PRM = 0 and @Is_RMToRM = 1)
													Begin
																											
															Declare @Emp_Id_Level1 as NUMERIC = 0															
														
																SET @Emp_Id_Level1 = (
																						SELECT	Top 1 E.Emp_ID   --Distinct
																						FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
																								T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN
																								(
																									SELECT	 MAX(Effect_Date) as Effect_Date, Emp_ID 
																									from	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
																									WHERE	 Effect_Date <= GETDATE()
																									GROUP BY emp_ID
																								) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
																						ON		E.EMP_ID = ERD.R_EMP_ID 
																						WHERE	ERD.EMP_ID = @Emp_ID1 
																						ORDER By ERD.Row_ID DESC
																					  )
														
															If @Emp_Id_Level1 <> 0
																BEGIN
																
																	SET @temp1 = (
																					SELECT	DISTINCT ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
																					FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
																							T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN	
																							(
																								SELECT	 MAX(Effect_Date) as Effect_Date, Emp_ID 
																								FROM	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
																								WHERE	 Effect_Date <= GETDATE()
																								GROUP BY emp_ID
																							) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
																				   ON E.EMP_ID = ERD.R_EMP_ID 
																				   WHERE ERD.EMP_ID = @Emp_Id_Level1  for xml path ('')																			   
																				  )
																END														
														
														
											END
									--------------ended----------------------------	
								Else
									Begin
									
										set @temp1 =(
														 SELECT ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
														 FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
																T0095_Department_Manager ERD WITH (NOLOCK) ON E.EMP_ID = ERD.Emp_id inner join
																	(
																		select	max(effective_date) as effective_date,Dept_ID
																		from	T0095_Department_Manager IES WITH (NOLOCK)
																		where	Cmp_ID = @cmp_id and Dept_ID =@HOD  
																		GROUP by Dept_ID
																	) Tbl1 ON Tbl1.Dept_ID = @HOD and erd.effective_date=tbl1.effective_date
				        								 WHERE ERD.Dept_ID=@HOD for xml path ('')
				        							)
									End
								--if @temp1<>''
								--Begin
								
								set @rm_name=LEFT(cast(@temp1 as varchar(200)), LEN(cast(@temp1 as varchar(200))) - 1)
								--End
									if 	(@Is_Hod_chk=0 and @Is_PRM = 0 and @Is_BM = 1)
										Begin			
											if @rm_name is null or @rm_name=''
												set @rm_name='Branch Manager'
										End
									else if 	(@Is_Hod_chk=0 and @Is_PRM = 1)
										begin
												if @rm_name is null or @rm_name=''
												set @rm_name='Manager'
										end
									else if 	(@Is_Hod_chk=0 and @Is_PRM = 0 and @Is_RMToRM = 1)
										begin
												if @rm_name is null or @rm_name=''
												set @rm_name='Reporting to Reporting Manager'
										end
									Else			
										Begin
											if @rm_name is null or @rm_name=''
												set @rm_name='Department Manager'
										End		
										
										
									--binal
											select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal
				        						update 	#EMPSCHEME
												set  Rpt_Mgr_2=@rm_name							 
												where Emp_ID1=@Emp_ID1  and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
											end --binal
							 end
					else if exists(select * from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Is_HR = 1 and Scheme_Id=@Scheme_Id1 and Rpt_Level=2)--Added by Mukti(05072019)to Select HR for Recruitment scheme
							begin
								IF exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK)  WHERE Is_HR = 1 and cmp_id=@cmp_id AND ISNULL(branch_id_multi,'') <> '' and Branch_id_multi <> 0)
									BEGIN		
									print @branch_Id1	 	
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN  WITH (NOLOCK)
										where Is_HR = 1 and cmp_id=@cmp_id AND  ISNULL(branch_id_multi,'') <> '' AND
										@branch_Id1	 IN (SELECT     cast(data AS numeric(18, 0))
												 FROM          dbo.Split(ISNULL(branch_id_multi, ''), '#')
												 WHERE      data <> '')
									END
								ELSE
									BEGIN
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)	where Is_HR = 1 and cmp_id=@cmp_id										
									END			 
								set @emp_full_name=''	
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM    dbo.T0080_EMP_MASTER em WITH (NOLOCK)	WHERE em.Emp_ID=@Manager_HR														
					  		
										--binal
											select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal

					     						update 	#EMPSCHEME
												set  Rpt_Mgr_2=@emp_full_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
											END		
							END		
					else
						begin
							set @emp_full_name=''
								set @emp_First_Name=''
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, '')),@emp_First_Name=em.Emp_First_Name
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =
								(SELECT    App_Emp_ID
								FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK)
					     		WHERE      Scheme_Id = @Scheme_Id1 and Cmp_ID=@cmp_id and rpt_level=2))
					     		
								--binal
											select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal

					     						update 	#EMPSCHEME
												set  Rpt_Mgr_2=@emp_full_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
					     					 end
							end
							
					-----------------------------------------------------------------------		 																
					 if exists(select 1 from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and (Is_BM=1 or Is_HOD=1 or Is_PRM=1)and Scheme_Id=@Scheme_Id1 and Rpt_Level=3)
							begin							
								declare @Is_Hod_lvl3 as tinyint
								set @Is_Hod_lvl3=0	
								declare @Is_Prm_3 as tinyint
								set @Is_Prm_3=0			
								set @temp=''	
								set @temp1=''
								set @rm_name=''	
								
								select @HOD=Dept_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1	
								select @Is_Hod_lvl3=Is_HOD,@Is_Prm_3=Is_PRM from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Is_HOD=1 and Rpt_Level=3
								
								if 	@Is_Hod_lvl3=0
								Begin		
									select @branch_Id1=Branch_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1		
									set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
									FROM T0080_EMP_MASTER E WITH (NOLOCK)
									INNER JOIN T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
									(select max(effective_date) as effective_date,Branch_ID from T0095_MANAGERS IES WITH (NOLOCK)
																where Cmp_ID = @cmp_id and Branch_ID =@branch_Id1  
																GROUP by Branch_ID) Tbl1 ON Tbl1.Branch_ID = @branch_Id1 and erd.effective_date=tbl1.effective_date
				        			WHERE ERD.Branch_ID=@branch_Id1 for xml path (''))
				        		End
				        		else if (@Is_Prm_3 = 1)
								Begin	
								
								SET @temp=(SELECT DISTINCT ((convert(nvarchar,E.Alpha_Emp_Code)) + '-' + (convert(nvarchar,E.EMP_FULL_NAME))) + ', ' 
								FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
									t0080_emp_master ERD WITH (NOLOCK) on Erd.manager_Probation = E.Emp_id
								
								WHERE ERD.EMP_ID =@Emp_ID1  for xml path (''))
								End	
				        		Else
				        			Begin
				        				set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E  WITH (NOLOCK)
										INNER JOIN T0095_Department_Manager ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
										(select max(effective_date) as effective_date,Dept_ID from T0095_Department_Manager IES WITH (NOLOCK)
																	where Cmp_ID = @cmp_id and Dept_ID =@HOD  
																	GROUP by Dept_ID) Tbl1 ON Tbl1.Dept_ID = @HOD and erd.effective_date=tbl1.effective_date
				        				WHERE ERD.Dept_ID=@HOD for xml path (''))
				        			End
								set @rm_name=LEFT(cast(@temp as varchar(200)), LEN(cast(@temp as varchar(200))) - 1)
									if 	@Is_Hod_chk=0 --Added by Sumit for HOD 25092015
										Begin			
											if @rm_name is null or @rm_name=''
												set @rm_name='Branch Manager'
										End
									Else			
										Begin
											if @rm_name is null or @rm_name=''
												set @rm_name='Department Manager'
										End
								--if @rm_name is null or @rm_name=''
								--	set @rm_name='Branch Manager'
									--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												End
												else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal											
				        						update 	#EMPSCHEME
												set  Rpt_Mgr_3=@rm_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
											end
							end	
					else if exists(select * from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Is_HR = 1 and Scheme_Id=@Scheme_Id1 and Rpt_Level=3)--Added by Mukti(05072019)to Select HR for Recruitment scheme
							begin
								IF exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) WHERE Is_HR = 1 and cmp_id=@cmp_id AND ISNULL(branch_id_multi,'') <> '' and Branch_id_multi <> 0)
									BEGIN			 	
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)
										where Is_HR = 1 and cmp_id=@cmp_id AND  ISNULL(branch_id_multi,'') <> '' AND
										@branch_Id1	 IN (SELECT     cast(data AS numeric(18, 0))
												 FROM          dbo.Split(ISNULL(branch_id_multi, ''), '#')
												 WHERE      data <> '')
									END
								ELSE
									BEGIN
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)	where Is_HR = 1 and cmp_id=@cmp_id										
									END			 
								set @emp_full_name=''	
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM  dbo.T0080_EMP_MASTER em WITH (NOLOCK) WHERE em.Emp_ID=@Manager_HR														
					  			--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												End
												else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal			

					     						update 	#EMPSCHEME
												set  Rpt_Mgr_3=@emp_full_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
										  END
							END		
					else
							begin							
							set @emp_full_name=''	
							set @emp_First_Name=''
							
							
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, '')),@emp_First_Name=em.Emp_First_Name
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =
								(SELECT    App_Emp_ID
								FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK)
					     		WHERE Scheme_Id = @Scheme_Id1 and Cmp_ID=@cmp_id   and rpt_level=3))
					     		--PRINT @emp_full_name
					     		--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												End
												else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal			

					     						update 	#EMPSCHEME
												set  Rpt_Mgr_3=@emp_full_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
										   end
					     	end
					
					---------Added by Mukti(start)31082020---------------------------------------------------------
					------For 4th Level----------------------------------------------------------------------------
					if exists(select 1 from T0050_Scheme_Detail WITH (NOLOCK) where cmp_id=@cmp_id and (Is_BM=1 or Is_HOD=1 or Is_PRM=1)and Scheme_Id=@Scheme_Id1 and Rpt_Level=4)
							begin							
								declare @Is_Hod_lvl4 as tinyint
								set @Is_Hod_lvl4=0									
								set @temp=''	
								set @temp1=''
								set @rm_name=''	
								
								select @HOD=Dept_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1	
								select @Is_Hod_lvl4=Is_HOD from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Is_HOD=1 and Rpt_Level=4
								
								if 	@Is_Hod_lvl4=0
									Begin		
										select @branch_Id1=Branch_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1		
										set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E  WITH (NOLOCK) 
										INNER JOIN T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
										(select max(effective_date) as effective_date,Branch_ID from T0095_MANAGERS IES WITH (NOLOCK)
																	where Cmp_ID = @cmp_id and Branch_ID =@branch_Id1  
																	GROUP by Branch_ID) Tbl1 ON Tbl1.Branch_ID = @branch_Id1 and erd.effective_date=tbl1.effective_date
				        				WHERE ERD.Branch_ID=@branch_Id1 for xml path (''))
				        			End				        		
				        		Else
				        			Begin
				        				set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E WITH (NOLOCK)
										INNER JOIN T0095_Department_Manager ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
										(select max(effective_date) as effective_date,Dept_ID from T0095_Department_Manager IES WITH (NOLOCK)
																	where Cmp_ID = @cmp_id and Dept_ID =@HOD  
																	GROUP by Dept_ID) Tbl1 ON Tbl1.Dept_ID = @HOD and erd.effective_date=tbl1.effective_date
				        				WHERE ERD.Dept_ID=@HOD for xml path (''))
				        			End
								set @rm_name=LEFT(cast(@temp as varchar(200)), LEN(cast(@temp as varchar(200))) - 1)
									--if 	@Is_Hod_chk=0 --Added by Sumit for HOD 25092015
									--	Begin			
									--		if @rm_name is null or @rm_name=''
									--			set @rm_name='Branch Manager'
									--	End
									--Else			
										--Begin
											if @rm_name is null or @rm_name=''
												set @rm_name='Department Manager'
										--End
								--if @rm_name is null or @rm_name=''
								--	set @rm_name='Branch Manager'
									--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												End
												else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal											
				        						update 	#EMPSCHEME
												set  Rpt_Mgr_4=@rm_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
											end
							end	
					else if exists(select * from T0050_Scheme_Detail WITH (NOLOCK)where  cmp_id=@cmp_id and Is_HR = 1 and Scheme_Id=@Scheme_Id1 and Rpt_Level=4)--Added by Mukti(05072019)to Select HR for Recruitment scheme
							begin
								IF exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) WHERE Is_HR = 1 and cmp_id=@cmp_id AND ISNULL(branch_id_multi,'') <> '' and Branch_id_multi <> 0)
									BEGIN			 	
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)
										where Is_HR = 1 and cmp_id=@cmp_id AND  ISNULL(branch_id_multi,'') <> '' AND
										@branch_Id1	 IN (SELECT     cast(data AS numeric(18, 0))
												 FROM          dbo.Split(ISNULL(branch_id_multi, ''), '#')
												 WHERE      data <> '')
									END
								ELSE
									BEGIN
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)	where Is_HR = 1 and cmp_id=@cmp_id										
									END			 
								set @emp_full_name=''	
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM  dbo.T0080_EMP_MASTER em WITH (NOLOCK) WHERE em.Emp_ID=@Manager_HR														
					  			--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK)where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												End
												else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal			

					     						update 	#EMPSCHEME
												set  Rpt_Mgr_4=@emp_full_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
										  END
							END		
					else
							begin							
							set @emp_full_name=''	
							set @emp_First_Name=''							
							
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, '')),@emp_First_Name=em.Emp_First_Name
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =
								(SELECT    App_Emp_ID
								FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK)
					     		WHERE Scheme_Id = @Scheme_Id1 and Cmp_ID=@cmp_id   and rpt_level=4))
					     		--PRINT @emp_full_name
					     		--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												End
												else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal			

					     						update 	#EMPSCHEME
												set  Rpt_Mgr_4=@emp_full_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
										   end
					     	end						
					------For 5th Level----------------------------------------------------------------------------
					 if exists(select 1 from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and (Is_BM=1 or Is_HOD=1 or Is_PRM=1)and Scheme_Id=@Scheme_Id1 and Rpt_Level=5)
							begin							
								declare @Is_Hod_lvl5 as tinyint
								set @Is_Hod_lvl5=0									
								set @temp=''	
								set @temp1=''
								set @rm_name=''	
								
								select @HOD=Dept_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1	
								select @Is_Hod_lvl5=Is_HOD from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Is_HOD=1 and Rpt_Level=5
								
								if 	@Is_Hod_lvl5=0
								Begin		
									select @branch_Id1=Branch_ID from T0080_emp_master  WITH (NOLOCK) where Emp_ID=@Emp_ID1		
									set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
									FROM T0080_EMP_MASTER E  WITH (NOLOCK) 
									INNER JOIN T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
									(select max(effective_date) as effective_date,Branch_ID from T0095_MANAGERS IES WITH (NOLOCK)
																where Cmp_ID = @cmp_id and Branch_ID =@branch_Id1  
																GROUP by Branch_ID) Tbl1 ON Tbl1.Branch_ID = @branch_Id1 and erd.effective_date=tbl1.effective_date
				        			WHERE ERD.Branch_ID=@branch_Id1 for xml path (''))
				        		End				        		
				        		Else
				        			Begin
				        				set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E WITH (NOLOCK)
										INNER JOIN T0095_Department_Manager ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
										(select max(effective_date) as effective_date,Dept_ID from T0095_Department_Manager IES WITH (NOLOCK)
																	where Cmp_ID = @cmp_id and Dept_ID =@HOD  
																	GROUP by Dept_ID) Tbl1 ON Tbl1.Dept_ID = @HOD and erd.effective_date=tbl1.effective_date
				        				WHERE ERD.Dept_ID=@HOD for xml path (''))
				        			End
								set @rm_name=LEFT(cast(@temp as varchar(200)), LEN(cast(@temp as varchar(200))) - 1)
									--if 	@Is_Hod_chk=0 --Added by Sumit for HOD 25092015
									--	Begin			
									--		if @rm_name is null or @rm_name=''
									--			set @rm_name='Branch Manager'
									--	End
									--Else			
									--	Begin
											if @rm_name is null or @rm_name=''
												set @rm_name='Department Manager'
										--End
								--if @rm_name is null or @rm_name=''
								--	set @rm_name='Branch Manager'
									--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												End
												else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal											
				        						update 	#EMPSCHEME
												set  Rpt_Mgr_5=@rm_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
											end
							end	
					else if exists(select * from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Is_HR = 1 and Scheme_Id=@Scheme_Id1 and Rpt_Level=5)
							begin
								IF exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) WHERE Is_HR = 1 and cmp_id=@cmp_id AND ISNULL(branch_id_multi,'') <> '' and Branch_id_multi <> 0)
									BEGIN			 	
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)
										where Is_HR = 1 and cmp_id=@cmp_id AND  ISNULL(branch_id_multi,'') <> '' AND
										@branch_Id1	 IN (SELECT     cast(data AS numeric(18, 0))
												 FROM          dbo.Split(ISNULL(branch_id_multi, ''), '#')
												 WHERE      data <> '')
									END
								ELSE
									BEGIN
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)	where Is_HR = 1 and cmp_id=@cmp_id										
									END			 
								set @emp_full_name=''	
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM  dbo.T0080_EMP_MASTER em WITH (NOLOCK) WHERE em.Emp_ID=@Manager_HR														
					  			--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												End
												else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal			

					     						update 	#EMPSCHEME
												set  Rpt_Mgr_5=@emp_full_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
										  END
							END		
					else
							begin							
							set @emp_full_name=''	
							set @emp_First_Name=''
							
							
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, '')),@emp_First_Name=em.Emp_First_Name
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =
								(SELECT    App_Emp_ID
								FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK)
					     		WHERE Scheme_Id = @Scheme_Id1 and Cmp_ID=@cmp_id   and rpt_level=5))
					     		--PRINT @emp_full_name
					     		--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
											begin
												Set @Is_display_rpt_level=0
											end
											else
											begin
												select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
												if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												End
												else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
												end 
											end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal	
					     						update 	#EMPSCHEME
												set  Rpt_Mgr_5=@emp_full_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
										   end
					     	end
					------For 6th Level----------------------------------------------------------------------------
					 if exists(select 1 from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and (Is_BM=1 or Is_HOD=1 or Is_PRM=1)and Scheme_Id=@Scheme_Id1 and Rpt_Level=6)
							begin							
								declare @Is_Hod_lvl6 as tinyint
								set @Is_Hod_lvl6=0									
								set @temp=''	
								set @temp1=''
								set @rm_name=''	
								
								select @HOD=Dept_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1	
								select @Is_Hod_lvl6=Is_HOD from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Is_HOD=1 and Rpt_Level=6
								
								if 	@Is_Hod_lvl6=0
								Begin		
									select @branch_Id1=Branch_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1		
									set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
									FROM T0080_EMP_MASTER E WITH (NOLOCK)
									INNER JOIN T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
									(select max(effective_date) as effective_date,Branch_ID from T0095_MANAGERS IES WITH (NOLOCK)
																where Cmp_ID = @cmp_id and Branch_ID =@branch_Id1  
																GROUP by Branch_ID) Tbl1 ON Tbl1.Branch_ID = @branch_Id1 and erd.effective_date=tbl1.effective_date
				        			WHERE ERD.Branch_ID=@branch_Id1 for xml path (''))
				        		End				        		
				        		Else
				        			Begin
				        				set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E WITH (NOLOCK)
										INNER JOIN T0095_Department_Manager ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
										(select max(effective_date) as effective_date,Dept_ID from T0095_Department_Manager IES WITH (NOLOCK)
																	where Cmp_ID = @cmp_id and Dept_ID =@HOD  
																	GROUP by Dept_ID) Tbl1 ON Tbl1.Dept_ID = @HOD and erd.effective_date=tbl1.effective_date
				        				WHERE ERD.Dept_ID=@HOD for xml path (''))
				        			End
								set @rm_name=LEFT(cast(@temp as varchar(200)), LEN(cast(@temp as varchar(200))) - 1)
									--if 	@Is_Hod_chk=0 --Added by Sumit for HOD 25092015
									--	Begin			
									--		if @rm_name is null or @rm_name=''
									--			set @rm_name='Branch Manager'
									--	End
									--Else			
									--	Begin
											if @rm_name is null or @rm_name=''
												set @rm_name='Department Manager'
										--End
								--if @rm_name is null or @rm_name=''
								--	set @rm_name='Branch Manager'
									--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end
											else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
													if (@non_mandatory =1)
														begin
															Set @Is_display_rpt_level=0
														End
													else
														begin
															select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
															if (@non_mandatory =1)
															begin
																Set @Is_display_rpt_level=0
															End
														end 
												end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
												begin --binal											
				        							update 	#EMPSCHEME
													set  Rpt_Mgr_6=@rm_name
													where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
												end
							end	
					else if exists(select * from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Is_HR = 1 and Scheme_Id=@Scheme_Id1 and Rpt_Level=6)
							begin
								IF exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) WHERE Is_HR = 1 and cmp_id=@cmp_id AND ISNULL(branch_id_multi,'') <> '' and Branch_id_multi <> 0)
									BEGIN			 	
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)
										where Is_HR = 1 and cmp_id=@cmp_id AND  ISNULL(branch_id_multi,'') <> '' AND
										@branch_Id1	 IN (SELECT     cast(data AS numeric(18, 0))
												 FROM          dbo.Split(ISNULL(branch_id_multi, ''), '#')
												 WHERE      data <> '')
									END
								ELSE
									BEGIN
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK) 	where Is_HR = 1 and cmp_id=@cmp_id										
									END			 
								set @emp_full_name=''	
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM  dbo.T0080_EMP_MASTER em WITH (NOLOCK) WHERE em.Emp_ID=@Manager_HR														
					  			--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end
											else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
													else
													begin
														select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
														if (@non_mandatory =1)
														begin
															Set @Is_display_rpt_level=0
														End
													end 
												end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal
					     						update 	#EMPSCHEME
												set  Rpt_Mgr_6=@emp_full_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
										  END
							END		
					else
							begin							
							set @emp_full_name=''	
							set @emp_First_Name=''							
							
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, '')),@emp_First_Name=em.Emp_First_Name
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =
								(SELECT    App_Emp_ID
								FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK)
					     		WHERE Scheme_Id = @Scheme_Id1 and Cmp_ID=@cmp_id   and rpt_level=6))
					     		--PRINT @emp_full_name
					     		--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end
											else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
													else
													begin
														select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
														if (@non_mandatory =1)
														begin
															Set @Is_display_rpt_level=0
														End
													end 
												end	
													--binal	
												if (@Is_display_rpt_level=1) --binal
												begin --binal	
					     							update 	#EMPSCHEME
													set  Rpt_Mgr_6=@emp_full_name
													where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
											   end
										end
					------For 7th Level----------------------------------------------------------------------------
					 if exists(select 1 from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and (Is_BM=1 or Is_HOD=1 or Is_PRM=1)and Scheme_Id=@Scheme_Id1 and Rpt_Level=7)
							begin							
								declare @Is_Hod_lvl7 as tinyint
								set @Is_Hod_lvl7=0									
								set @temp=''	
								set @temp1=''
								set @rm_name=''	
								
								select @HOD=Dept_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1	
								select @Is_Hod_lvl7=Is_HOD from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Is_HOD=1 and Rpt_Level=7
								
								if 	@Is_Hod_lvl7=0
									Begin		
										select @branch_Id1=Branch_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1		
										set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E WITH (NOLOCK)
										INNER JOIN T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
										(select max(effective_date) as effective_date,Branch_ID from T0095_MANAGERS IES WITH (NOLOCK)
																	where Cmp_ID = @cmp_id and Branch_ID =@branch_Id1  
																	GROUP by Branch_ID) Tbl1 ON Tbl1.Branch_ID = @branch_Id1 and erd.effective_date=tbl1.effective_date
				        				WHERE ERD.Branch_ID=@branch_Id1 for xml path (''))
				        			End				        		
				        		Else
				        			Begin
				        				set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E WITH (NOLOCK)
										INNER JOIN T0095_Department_Manager ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
										(select max(effective_date) as effective_date,Dept_ID from T0095_Department_Manager IES WITH (NOLOCK)
																	where Cmp_ID = @cmp_id and Dept_ID =@HOD  
																	GROUP by Dept_ID) Tbl1 ON Tbl1.Dept_ID = @HOD and erd.effective_date=tbl1.effective_date
				        				WHERE ERD.Dept_ID=@HOD for xml path (''))
				        			End
								set @rm_name=LEFT(cast(@temp as varchar(200)), LEN(cast(@temp as varchar(200))) - 1)
									--if 	@Is_Hod_chk=0 --Added by Sumit for HOD 25092015
									--	Begin			
									--		if @rm_name is null or @rm_name=''
									--			set @rm_name='Branch Manager'
									--	End
									--Else			
										Begin
											if @rm_name is null or @rm_name=''
												set @rm_name='Department Manager'
										End
								--if @rm_name is null or @rm_name=''
								--	set @rm_name='Branch Manager'
									--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end
											else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
													if (@non_mandatory =1)
														begin
															Set @Is_display_rpt_level=0
														End
													else
														begin
															select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
															if (@non_mandatory =1)
															begin
																Set @Is_display_rpt_level=0
															End
														end 
												end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
												begin --binal											
				        							update 	#EMPSCHEME
													set  Rpt_Mgr_7=@rm_name
													where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
												end
							end	
					else if exists(select * from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Is_HR = 1 and Scheme_Id=@Scheme_Id1 and Rpt_Level=7)
							begin
								IF exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) WHERE Is_HR = 1 and cmp_id=@cmp_id AND ISNULL(branch_id_multi,'') <> '' and Branch_id_multi <> 0)
									BEGIN			 	
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)
										where Is_HR = 1 and cmp_id=@cmp_id AND  ISNULL(branch_id_multi,'') <> '' AND
										@branch_Id1	 IN (SELECT     cast(data AS numeric(18, 0))
												 FROM          dbo.Split(ISNULL(branch_id_multi, ''), '#')
												 WHERE      data <> '')
									END
								ELSE
									BEGIN
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)	where Is_HR = 1 and cmp_id=@cmp_id										
									END			 
								set @emp_full_name=''	
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM  dbo.T0080_EMP_MASTER em WITH (NOLOCK) WHERE em.Emp_ID=@Manager_HR														
					  			--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end
											else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
													else
													begin
														select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
														if (@non_mandatory =1)
														begin
															Set @Is_display_rpt_level=0
														End
													end 
												end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal
					     						update 	#EMPSCHEME
												set  Rpt_Mgr_7=@emp_full_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
										  END
							END		
					else
							begin							
							set @emp_full_name=''	
							set @emp_First_Name=''							
							
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, '')),@emp_First_Name=em.Emp_First_Name
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =
								(SELECT    App_Emp_ID
								FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK)
					     		WHERE Scheme_Id = @Scheme_Id1 and Cmp_ID=@cmp_id   and rpt_level=7))
					     		--PRINT @emp_full_name
					     		--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end
											else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
													else
													begin
														select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
														if (@non_mandatory =1)
														begin
															Set @Is_display_rpt_level=0
														End
													end 
												end	
													--binal	
												if (@Is_display_rpt_level=1) --binal
												begin --binal	
					     							update 	#EMPSCHEME
													set  Rpt_Mgr_7=@emp_full_name
													where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
											   end
										end
					------For 8th Level----------------------------------------------------------------------------
					 if exists(select 1 from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and (Is_BM=1 or Is_HOD=1 or Is_PRM=1)and Scheme_Id=@Scheme_Id1 and Rpt_Level=8)
							begin							
								declare @Is_Hod_lvl8 as tinyint
								set @Is_Hod_lvl8=0									
								set @temp=''	
								set @temp1=''
								set @rm_name=''	
								
								select @HOD=Dept_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1	
								select @Is_Hod_lvl8=Is_HOD from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Is_HOD=1 and Rpt_Level=8
								
								if 	@Is_Hod_lvl8=0
									Begin		
										select @branch_Id1=Branch_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1		
										set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E WITH (NOLOCK) 
										INNER JOIN T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
										(select max(effective_date) as effective_date,Branch_ID from T0095_MANAGERS IES WITH (NOLOCK)
																	where Cmp_ID = @cmp_id and Branch_ID =@branch_Id1  
																	GROUP by Branch_ID) Tbl1 ON Tbl1.Branch_ID = @branch_Id1 and erd.effective_date=tbl1.effective_date
				        				WHERE ERD.Branch_ID=@branch_Id1 for xml path (''))
				        			End				        		
				        		Else
				        			Begin
				        				set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
										FROM T0080_EMP_MASTER E WITH (NOLOCK)
										INNER JOIN T0095_Department_Manager ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
										(select max(effective_date) as effective_date,Dept_ID from T0095_Department_Manager IES WITH (NOLOCK)
																	where Cmp_ID = @cmp_id and Dept_ID =@HOD  
																	GROUP by Dept_ID) Tbl1 ON Tbl1.Dept_ID = @HOD and erd.effective_date=tbl1.effective_date
				        				WHERE ERD.Dept_ID=@HOD for xml path (''))
				        			End
								set @rm_name=LEFT(cast(@temp as varchar(200)), LEN(cast(@temp as varchar(200))) - 1)
									--if 	@Is_Hod_chk=0 --Added by Sumit for HOD 25092015
									--	Begin			
									--		if @rm_name is null or @rm_name=''
									--			set @rm_name='Branch Manager'
									--	End
									--Else			
									--	Begin
											if @rm_name is null or @rm_name=''
												set @rm_name='Department Manager'
										--End
								--if @rm_name is null or @rm_name=''
								--	set @rm_name='Branch Manager'
									--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end
											else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
													if (@non_mandatory =1)
														begin
															Set @Is_display_rpt_level=0
														End
													else
														begin
															select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
															if (@non_mandatory =1)
															begin
																Set @Is_display_rpt_level=0
															End
														end 
												end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
												begin --binal											
				        							update 	#EMPSCHEME
													set  Rpt_Mgr_8=@rm_name
													where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
												end
							end	
					else if exists(select * from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Is_HR = 1 and Scheme_Id=@Scheme_Id1 and Rpt_Level=8)
							begin
								IF exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) WHERE Is_HR = 1 and cmp_id=@cmp_id AND ISNULL(branch_id_multi,'') <> '' and Branch_id_multi <> 0)
									BEGIN			 	
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK)
										where Is_HR = 1 and cmp_id=@cmp_id AND  ISNULL(branch_id_multi,'') <> '' AND
										@branch_Id1	 IN (SELECT     cast(data AS numeric(18, 0))
												 FROM          dbo.Split(ISNULL(branch_id_multi, ''), '#')
												 WHERE      data <> '')
									END
								ELSE
									BEGIN
										SELECT @Manager_HR=Emp_ID from T0011_LOGIN WITH (NOLOCK) 	where Is_HR = 1 and cmp_id=@cmp_id										
									END			 
								set @emp_full_name=''	
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM  dbo.T0080_EMP_MASTER em WITH (NOLOCK) WHERE em.Emp_ID=@Manager_HR														
					  			--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end
											else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
													else
													begin
														select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
														if (@non_mandatory =1)
														begin
															Set @Is_display_rpt_level=0
														End
													end 
												end	
												--binal	
											if (@Is_display_rpt_level=1) --binal
											begin --binal
					     						update 	#EMPSCHEME
												set  Rpt_Mgr_8=@emp_full_name
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
										  END
							END		
					else
							begin							
							set @emp_full_name=''	
							set @emp_First_Name=''							
							
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, '')),@emp_First_Name=em.Emp_First_Name
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =
								(SELECT    App_Emp_ID
								FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK)
					     		WHERE Scheme_Id = @Scheme_Id1 and Cmp_ID=@cmp_id   and rpt_level=8))
					     		--PRINT @emp_full_name
					     		--binal
									select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=1
											
											if (@non_mandatory =1)
												begin
													Set @Is_display_rpt_level=0
												end
											else
												begin
													select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=2
													if (@non_mandatory =1)
													begin
														Set @Is_display_rpt_level=0
													End
													else
													begin
														select @non_mandatory= ISNULL(not_mandatory,0) from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=3
														if (@non_mandatory =1)
														begin
															Set @Is_display_rpt_level=0
														End
													end 
												end	
													--binal	
												if (@Is_display_rpt_level=1) --binal
												begin --binal	
					     							update 	#EMPSCHEME
													set  Rpt_Mgr_8=@emp_full_name
													where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID
											   end
										end
					---------Added by Mukti(end)31082020---------------------------------------------------------
								 update 	#EMPSCHEME
												set 
													 Max_Level=(SELECT 
																	  ((CASE WHEN ISNULL(Rpt_Mgr_1,'')<>'' THEN 1 ELSE 0 END)
																	  + (CASE WHEN ISNULL(Rpt_Mgr_2,'')<>'' THEN 1 ELSE 0 END)
																	  + (CASE WHEN ISNULL(Rpt_Mgr_3,'')<>''  THEN 1 ELSE 0 END)
																	  + (CASE WHEN ISNULL(Rpt_Mgr_4,'')<>''  THEN 1 ELSE 0 END)
																	  + (CASE WHEN ISNULL(Rpt_Mgr_5,'')<>''  THEN 1 ELSE 0 END)
																	  + (CASE WHEN ISNULL(Rpt_Mgr_6,'')<>''  THEN 1 ELSE 0 END)
																	  + (CASE WHEN ISNULL(Rpt_Mgr_7,'')<>''  THEN 1 ELSE 0 END)
																	  + (CASE WHEN ISNULL(Rpt_Mgr_8,'')<>''  THEN 1 ELSE 0 END)) 
																	FROM #EMPSCHEME
																	WHERE Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID)
												where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type and Scheme_Id= @e_scheme_ID	
													
				fetch next from Emp_Scheme_Cursor into @emp_id1,@sc_type,@e_scheme_ID
			End
		
	close Emp_Scheme_Cursor	
	deallocate Emp_Scheme_Cursor
	
	IF @Report_Type <> ''
		BEGIN
			
			


			select Emp_ID1,Rpt_Mgr_1,Rpt_Mgr_2,Rpt_Mgr_3,Rpt_Mgr_4,Rpt_Mgr_5,Rpt_Mgr_6,Rpt_Mgr_7,Rpt_Mgr_8,Max_Level from #EMPSCHEME --WHERE Scheme_Type = 'Trainee' order by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)
		END
	ELSE
		BEGIN
			select * from #EMPSCHEME order by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)
		END	
	

RETURN 

