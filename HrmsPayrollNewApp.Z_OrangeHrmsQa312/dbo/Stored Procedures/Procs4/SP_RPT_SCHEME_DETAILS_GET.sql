

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_SCHEME_DETAILS_GET]
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
	,@Constraint	varchar(MAX)
	,@SchemeType	Varchar(50) = '--Select--' --Added By Jimit 09102018
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

		
set @From_Date=GETDATE()
set @To_Date=GETDATE()
	
	
	
	--Declare @Emp_Cons Table
	--	(
	--		Emp_ID	numeric
	--	)
		
	--if @Constraint <> ''
	--	begin
	--		Insert Into @Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#')
	--	end
	--else
	--	begin
	--		Insert Into @Emp_Cons
	--		select distinct I.Emp_Id from T0095_Increment I inner join
	--		dbo.T0095_emp_scheme MS on MS.Emp_ID = I.Emp_ID	inner join
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
	--		Where i.Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date ) 
	--	end


	--Above code commented by Jimit 09102018

		CREATE TABLE #Emp_Cons 
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )    
   
		EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0 ,0 ,0 ,0 



CREATE table #SCHEME
	(
	e_id		numeric,
	sc_type Varchar(50),
	
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
				Rpt_Mgr_1 Varchar(max),
				Rpt_Mgr_2 Varchar(max),
				Rpt_Mgr_3 Varchar(max),
				Rpt_Mgr_4 Varchar(max),
				Rpt_Mgr_5 Varchar(max),
				Rpt_Mgr_6 Varchar(max), --added ronak
				Rpt_Mgr_7 Varchar(max),
				Rpt_Mgr_8 Varchar(max),
				Emp_First_Name varchar(100)  --added jimit 20052015
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
	Declare @Rpt_Mgr_1 Varchar(200)
	Declare @Rpt_Mgr_2 Varchar(200)
	Declare	@Rpt_Mgr_3 Varchar(200)
	Declare @Rpt_Mgr_4 Varchar(200)
	Declare	@Rpt_Mgr_5 Varchar(200) 
	Declare	@Rpt_Mgr_6 Varchar(200) --added ronak
	Declare	@Rpt_Mgr_7 Varchar(200)
	Declare	@Rpt_Mgr_8 Varchar(200)
	Declare	@emp_full_name Varchar(250)	
	Declare @val nvarchar(500)
	Declare	@Emp_ID2 numeric
	declare @leave1 varchar(250)
	declare @Scheme_Id1 numeric
	declare @branch_Id1 numeric
	declare @temp xml
	declare @temp1 xml
	declare @emp_first_name varchar(100)  --added jimit 20052015
	
	declare @rm_name varchar(250)
	declare @e_id numeric
	declare @sc_type varchar(50)
	declare @scheme_name varchar(50)
	declare @HOD as numeric --Added by Sumit 25092015
	
	Set @Columns = '#'

DECLARE Emp_Scheme CURSOR FOR
	--select distinct es.emp_id,es.[Type] from T0095_EMP_SCHEME es
	--					inner join T0080_EMP_MASTER emp on emp.Emp_ID=es.Emp_ID and emp.Cmp_ID=es.cmp_id
	--					inner join(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES
	--																where Cmp_ID = @cmp_id and Emp_ID in (select * from @Emp_Cons)
	--																GROUP by emp_id) Tbl1 ON Tbl1.Emp_ID = es.Emp_ID 
	--					where es.Emp_ID in (select * from @Emp_Cons) and es.Cmp_ID=@cmp_id

	SELECT DISTINCT ES.EMP_ID,ES.[TYPE] 
	FROM			T0095_EMP_SCHEME ES WITH (NOLOCK) INNER JOIN
					T0080_EMP_MASTER EMP WITH (NOLOCK) ON EMP.EMP_ID=ES.EMP_ID AND EMP.CMP_ID=ES.CMP_ID INNER JOIN
					(
										SELECT	MAX(EFFECTIVE_DATE) AS EFFECTIVE_DATE,EMP_ID 
										FROM	T0095_EMP_SCHEME IES WITH (NOLOCK)
										WHERE	CMP_ID = @CMP_ID AND 
												--EMP_ID IN (SELECT * FROM #EMP_CONS)
												EXISTS (SELECT 1 FROM #EMP_CONS EC WHERE EC.EMP_ID = IES.EMP_ID) --ADDED BY JIMIT 09102018
										GROUP BY EMP_ID
					) TBL1 ON TBL1.EMP_ID = ES.EMP_ID 
	 WHERE			--ES.EMP_ID IN (SELECT * FROM #EMP_CONS) AND								
					EXISTS (SELECT 1 FROM #EMP_CONS EC WHERE EC.EMP_ID = ES.EMP_ID)  AND  ES.CMP_ID=@CMP_ID --ADDED BY JIMIT 09102018
					AND ES.TYPE = (CASE WHEN @SCHEMETYPE <> '--Select--' THEN @SCHEMETYPE ELSE ES.TYPE END)  --Added By jimit 09102018
					and isnull(ES.IsMakerChecker,0) <> 1 --Added by ronakk 17092022
	
	
	

OPEN Emp_Scheme
		fetch next from Emp_Scheme into @e_id,@sc_type
			while @@fetch_status = 0
				Begin
					
				insert into #SCHEME values(@e_id,@sc_type)
				fetch next from Emp_Scheme into @e_id,@sc_type
			End
			--select * from #SCHEME				
	close Emp_Scheme	
	deallocate Emp_Scheme




	DECLARE Emp_Scheme_Cursor CURSOR FOR
		--(select * from @Emp_Cons)
		(select * from #SCHEME)			
	OPEN Emp_Scheme_Cursor
			fetch next from Emp_Scheme_Cursor into @emp_id1,@sc_type
		
			while @@fetch_status = 0
				Begin
				
					insert into #EMPSCHEME (emp_id1,Scheme_Type)
					values	(@emp_id1,@sc_type)
		
				select @Scheme_Id1=es.Scheme_ID,@Effective_Date=es.Effective_Date,@Scheme_Type=es.[Type],@Emp_Code=emp.Alpha_Emp_Code,@Emp_Name=Emp_Full_Name,
				@cmp_name=c.Cmp_Name,@cmp_address=Cmp_Address,@branch_Id1=emp.Branch_ID,@scheme_name=sm.Scheme_Name,@emp_first_name = emp.Emp_First_Name 
				from T0095_EMP_SCHEME es WITH (NOLOCK)
				inner join T0040_Scheme_Master sm WITH (NOLOCK) on es.Scheme_ID=sm.Scheme_Id and es.Cmp_ID=sm.Cmp_Id
				inner join T0080_EMP_MASTER emp WITH (NOLOCK) on emp.Emp_ID=es.Emp_ID and emp.Cmp_ID=es.cmp_id
				inner join T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id=emp.Cmp_ID 
				where es.Emp_ID=@emp_id1 and es.Cmp_ID=@cmp_id and es.[Type]=@sc_type  and isnull(es.IsMakerChecker,0) <> 1   --Added by ronakk 17092022 
				
				
				set @emp_full_name=''
				set @temp=''
				set @temp1=''
				set @emp_id2=0
				--set @branch_Id1=0
				set @rm_name=''
								
				update 	#EMPSCHEME
				set  Scheme_Id=@Scheme_Id1,Effective_Date=@Effective_Date,Alpha_Emp_Code=@Emp_Code,Emp_Full_Name=@Emp_Name,Scheme_Type=@Scheme_Type,
				Cmp_Name=@Cmp_Name,Cmp_Address=@Cmp_Address,cmp_id1=@cmp_id,branch_Id=@branch_Id1,Scheme_Name=@scheme_name,Emp_First_Name = @emp_first_name  --added emp_first_name jimit 20052015
				where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type
					set @emp_full_name=''	
				if exists(select * from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Is_RM = 1 and Scheme_Id=@Scheme_Id1 and Rpt_Level=1)
							begin
								set @temp=''
								set @rm_name=''	
								
						  		set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
								FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) ON E.EMP_ID= ERD.R_EMP_ID 
								WHERE ERD.EMP_ID =@Emp_ID1  for xml path (''))
								
								set @rm_name=LEFT(cast(@temp as varchar(max)), LEN(cast(@temp as varchar(max))) - 1)
								
								if @rm_name is null or @rm_name=''
									set @rm_name='Reporting Manager'
								
								update 	#EMPSCHEME
								set  Rpt_Mgr_1=@rm_name
								where Emp_ID1=@Emp_ID1  and Scheme_Type=@sc_type
							end
					else
							begin
							set @emp_full_name=''	
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =
								(SELECT    App_Emp_ID
								FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK)
					     		WHERE      Scheme_Id = @Scheme_Id1 and Cmp_ID=@cmp_id  and rpt_level=1))
					  		
					     		update 	#EMPSCHEME
								set  Rpt_Mgr_1=@emp_full_name
								where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type
						end
																
					if exists(select * from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and (Is_BM=1 or Is_HOD=1 or Is_RMToRM = 1) and Rpt_Level=2)
							begin
									declare @Is_Hod_chk as tinyint
									DECLARE @IS_RM_TO_RM AS TINYINT
									DECLARE @Emp_Id_Level1 AS INT
							
									set @Is_Hod_chk=0
									set @temp1=''
									set @temp=''
									set @rm_name=''	
									SET @IS_RM_TO_RM = 0
									SET @Emp_Id_Level1 = 0
									
									
								select	@HOD=Dept_ID 
								from	T0080_emp_master WITH (NOLOCK)
								where	Emp_ID=@Emp_ID1	
								
								
								select	@Is_Hod_chk=Is_HOD 
								from	T0050_Scheme_Detail WITH (NOLOCK)
								where	cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Is_HOD=1 and Rpt_Level=2
								
								
								--ADDED BY JIMIT 01092018
									SELECT	@IS_RM_TO_RM=IS_RMTORM 
									FROM	T0050_SCHEME_DETAIL WITH (NOLOCK)
									WHERE	CMP_ID=@CMP_ID AND SCHEME_ID=@SCHEME_ID1 AND IS_RMTORM=1 AND RPT_LEVEL=2	
								--ENDED
								
								if 	@Is_Hod_chk=0 and @IS_RM_TO_RM = 0
									Begin						
											select	@branch_Id1=Branch_ID 
											from	T0080_emp_master WITH (NOLOCK)
											where	Emp_ID=@Emp_ID1		
											
							
											
											set @temp1=(
															SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
															FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
																	T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
																	(
																		select	max(effective_date) as effective_date,Branch_ID 
																		from	T0095_MANAGERS IES WITH (NOLOCK)
																		where	Cmp_ID = @cmp_id and Branch_ID =@branch_Id1  
																		GROUP by Branch_ID
																	 ) Tbl1 ON Tbl1.Branch_ID = @branch_Id1 and erd.effective_date=tbl1.effective_date
				        									WHERE ERD.Branch_ID=@branch_Id1 for xml path ('')
				        								)
				        			End
				        		Else IF @IS_RM_TO_RM = 1  --Added By Jimit 01092018
				        				BEGIN				        					
										
						  					SELECT	@Emp_Id_Level1 = E.Emp_ID
						  					FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
													T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) ON E.EMP_ID= ERD.R_EMP_ID 
											WHERE	ERD.EMP_ID =@Emp_ID1 
														
														
											IF @Emp_Id_Level1 <> 0
												BEGIN
												
													 SET @temp1 = (
						  											SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
																	FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
																			T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) ON E.EMP_ID= ERD.R_EMP_ID 
																	WHERE	ERD.EMP_ID = @Emp_Id_Level1  for xml path ('')
																)																											
												END
				        				END      --Ended	
				        		Else
									Begin
									
									
											set @temp1=(
															SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', ' 
															FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
																	T0095_Department_Manager ERD WITH (NOLOCK) ON E.EMP_ID= ERD.Emp_id inner join
																	(
																		select	max(effective_date) as effective_date,Dept_ID 
																		from	T0095_Department_Manager IES WITH (NOLOCK)
																		where	Cmp_ID = @cmp_id and Dept_ID =@HOD  
																		GROUP by Dept_ID
																	) Tbl1 ON Tbl1.Dept_ID = @HOD and erd.effective_date=tbl1.effective_date
				        									WHERE ERD.Dept_ID=@HOD for xml path ('')
				        								)
									End	

									--Change  by ronakk 17092022 added condtion 
								if cast(@temp1 as varchar(max)) <> ''
								Begin		 
								    set @rm_name=LEFT(cast(@temp1 as varchar(max)), LEN(cast(@temp1 as varchar(max))) - 1)
								End

								if @rm_name is null or @rm_name=''
									BEGIN
											if 	@Is_Hod_chk=0 and @IS_RM_TO_RM = 0
												Begin	
													set @rm_name='Branch Manager'
												End
											Else If @IS_RM_TO_RM = 1
												Begin	
													set @rm_name='Reporting To Reporting Manager'
												End
											Else			
												Begin
													if @rm_name is null or @rm_name=''
														set @rm_name='Department Manager'
												End	
									  END			
																
				        		update 	#EMPSCHEME
								set  Rpt_Mgr_2=@rm_name
								where Emp_ID1=@Emp_ID1  and Scheme_Type=@sc_type
							 end
					else
							begin
							set @emp_full_name=''	
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =
								(SELECT    App_Emp_ID
								FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK)
					     		WHERE      Scheme_Id = @Scheme_Id1 and Cmp_ID=@cmp_id and rpt_level=2))
					     		
					     		update 	#EMPSCHEME
								set  Rpt_Mgr_2=@emp_full_name
								where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type
					     		
							end
										
					 if exists(select * from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and (Is_BM=1 or Is_HOD=1) and Scheme_Id=@Scheme_Id1 and Rpt_Level=3)
							begin
								declare @Is_Hod_lvl3 as tinyint
								set @Is_Hod_lvl3=0					
								set @temp=''	
								set @temp1=''
								set @rm_name=''	
								select @HOD=Dept_ID from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID1	
								select @Is_Hod_lvl3=Is_HOD from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Is_HOD=1 and Rpt_Level=3
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
				        		
								set @rm_name=LEFT(cast(@temp as varchar(max)), LEN(cast(@temp as varchar(max))) - 1)
							
								if @rm_name is null or @rm_name=''
									if 	@Is_Hod_chk=0
										Begin	
											set @rm_name='Branch Manager'
										End
									Else			
										Begin
											if @rm_name is null or @rm_name=''
												set @rm_name='Department Manager'
										End		
										
				        		update 	#EMPSCHEME
								set  Rpt_Mgr_3=@rm_name
								where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type
							end		
					else
							begin
							set @emp_full_name=''	
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =
								(SELECT    App_Emp_ID
								FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK)
					     		WHERE      Scheme_Id = @Scheme_Id1 and Cmp_ID=@cmp_id   and rpt_level=3))
					     		
					     		update 	#EMPSCHEME
								set  Rpt_Mgr_3=@emp_full_name
								where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type
					     	end
							 	
					set @Emp_ID2=0		
					select @Emp_ID2=App_Emp_ID,@leave1=Leave from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=4
					 if (@Emp_ID2 > 0)
							begin
							set @emp_full_name=''
						
							
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =@Emp_ID2) 
									
								update 	#EMPSCHEME
								set  Rpt_Mgr_4=@emp_full_name
								where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type
							end
					
					set @Emp_ID2=0		
					select @Emp_ID2=App_Emp_ID,@leave1=Leave from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=5
					 if (@Emp_ID2 > 0)
							begin
							set @emp_full_name=''
							
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =@Emp_ID2)
													
								update 	#EMPSCHEME
								set  Rpt_Mgr_5=@emp_full_name
								where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type
							end
							--Ronakb300724--
                    set @Emp_ID2=0		
					select @Emp_ID2=App_Emp_ID,@leave1=Leave from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=6
					 if (@Emp_ID2 > 0)
							begin
							set @emp_full_name=''
							
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =@Emp_ID2)
													
								update 	#EMPSCHEME
								set  Rpt_Mgr_6=@emp_full_name
								where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type
							end
					set @Emp_ID2=0		
					select @Emp_ID2=App_Emp_ID,@leave1=Leave from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=7
					 if (@Emp_ID2 > 0)
							begin
							set @emp_full_name=''
							
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =@Emp_ID2)
													
								update 	#EMPSCHEME
								set  Rpt_Mgr_7=@emp_full_name
								where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type
							end	
					set @Emp_ID2=0		
					select @Emp_ID2=App_Emp_ID,@leave1=Leave from T0050_Scheme_Detail WITH (NOLOCK) where  cmp_id=@cmp_id and Scheme_Id=@Scheme_Id1 and Rpt_Level=8
					 if (@Emp_ID2 > 0)
							begin
							set @emp_full_name=''
							
						
								SELECT  @emp_full_name=(Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
								FROM          dbo.T0080_EMP_MASTER em WITH (NOLOCK)
								WHERE      (em.Emp_ID =@Emp_ID2)
													
								update 	#EMPSCHEME
								set  Rpt_Mgr_8=@emp_full_name
								where Emp_ID1=@Emp_ID1 and Scheme_Type=@sc_type
							end			
				fetch next from Emp_Scheme_Cursor into @emp_id1,@sc_type
			End
		
	close Emp_Scheme_Cursor	
	deallocate Emp_Scheme_Cursor
	
	
    select * from #EMPSCHEME order by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)

RETURN 
