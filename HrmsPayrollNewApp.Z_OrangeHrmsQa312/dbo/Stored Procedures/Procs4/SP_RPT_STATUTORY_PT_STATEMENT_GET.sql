---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_PT_STATEMENT_GET]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Report_call	varchar(30) ='PT Statement'
	,@PT_Interest	Numeric(18,0) = 0  ----Parameter Pass From FronEnd value -- PT Form 5 Report -- Ankit 12012015
	,@PT_Penalty	Numeric(18,0) = 0  ----Parameter Pass From FronEnd value -- PT Form 5 Report -- Ankit 12012015
	,@Challan_Id    numeric =0 --Added By Jaina 18-09-2015
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	--set @Branch_ID= 234
	
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

	Declare @Emp_Cons Table
	(
		Emp_ID	numeric(18,0),
		Branch_ID numeric(18,0), --Added By Jaina 11-02-2016
		Increment_ID numeric(18,0) --Added By Jaina 11-02-2016
	)
	
	Select @From_Date = dbo.GET_MONTH_ST_DATE(month(@To_Date), Year(@To_Date))
	Select @To_Date = dbo.GET_MONTH_END_DATE(month(@To_Date), Year(@To_Date))
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons (Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
			
			--Added by Jaina 11-02-2016 (Base on Max Increment Date and Max Increment ID)
			UPDATE	@Emp_Cons
			SET		BRANCH_ID = I.BRANCH_ID,
					INCREMENT_ID = I.INCREMENT_ID
			FROM	@Emp_Cons E INNER JOIN (
												SELECT	EMP_ID, INCREMENT_ID, BRANCH_ID
												FROM	T0095_INCREMENT I1 WITH (NOLOCK)
												WHERE	I1.Increment_ID=(
																			SELECT	MAX(INCREMENT_ID)
																			FROM	T0095_INCREMENT I2 WITH (NOLOCK) 
																			WHERE	I2.Increment_Effective_Date = (
																													SELECT	MAX(INCREMENT_EFFECTIVE_DATE)
																													FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																													WHERE	I3.Emp_ID=I2.Emp_ID 
																															AND Increment_Effective_Date <= @To_Date
																												   )
																					AND I2.Emp_ID=I1.Emp_ID
																		)
											) I ON E.EMP_ID=I.Emp_ID
			
		end
	else
		begin
			
			Insert Into @Emp_Cons
			SELECT	distinct I.Emp_Id ,I.Branch_ID,I.Increment_ID
			--FROM	T0095_Increment I INNER JOIN T0200_MONTHLY_SALARY MS ON I.Increment_ID=MS.Increment_ID AND I.Cmp_ID=MS.Cmp_ID			
			--Added by Jaina 11-02-2016 (Base on Max Increment Date and Max Increment ID)
			from T0200_MONTHLY_SALARY MS WITH (NOLOCK)
				INNER JOIN (
								SELECT	EMP_ID, INCREMENT_ID, BRANCH_ID,I1.Cmp_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK)
								WHERE	I1.Increment_ID=(
															SELECT	MAX(INCREMENT_ID)
															FROM	T0095_INCREMENT I2 WITH (NOLOCK)
															WHERE	I2.Increment_Effective_Date = (
																									SELECT	MAX(INCREMENT_EFFECTIVE_DATE)
																									FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																									WHERE	I3.Emp_ID=I2.Emp_ID 
																									AND Increment_Effective_Date <= @To_Date
																								   )
															AND I2.Emp_ID=I1.Emp_ID
														)
							) I ON MS.EMP_ID=I.Emp_ID
			WHERE	I.Cmp_ID = @Cmp_ID and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 						
					AND Month(Month_End_date) >= Month(@TO_Date) And Year(Month_End_date) >= Year(@TO_Date)	--Ankit 25122014 
					and Month(Month_End_Date) <=Month(@To_Date) and Year(Month_End_Date) <=Year(@To_Date)	--Ankit 25122014
					--and PT_Amount > 0
					and I.Emp_ID in ( select Emp_Id from (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
							where cmp_ID = @Cmp_ID   and  
							(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
							or ( @To_Date  >= join_Date  and @To_Date <= left_date )
							or Left_date is null and @To_Date >= Join_Date)
							or @To_Date >= left_date  and  @From_Date <= left_date )
					--and I.Branch_ID in (232,234)  --Comment By Jaina 23-11-2015
					
			
				
			--Insert Into @Emp_Cons

			--select I.Emp_Id from T0095_Increment I inner join 
			--		(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI inner join
			--	(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment
			--	Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
			--	on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
			--	Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on
			--		I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
			--Where Cmp_ID = @Cmp_ID 
			--and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			--and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			--and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			--and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			--and I.Emp_ID in 
			--	( select Emp_Id from
			--	(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
			--	where cmp_ID = @Cmp_ID   and  
			--	(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
			--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )
			--	or Left_date is null and @To_Date >= Join_Date)
			--	or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
Declare @Sal_St_Date   Datetime    
  Declare @Sal_end_Date   Datetime  
  
  
  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End    
       
 if isnull(@Sal_St_Date,'') = ''    
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	begin    
	   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
	   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
	   set @From_Date = @Sal_St_Date
	   Set @To_Date = @Sal_end_Date   
	End 

		
	if @Report_Call ='PT Statement'
		begin
			
			
			-- Changed By Ali 23112013 EmpName_Alias
			Select ms.Emp_Id,MS.Pt_Calculated_Amount,Ms.PT_Amount,ISNULL(EmpName_Alias_PT,Emp_Full_Name) as Emp_full_Name,Grd_Name,Month(Month_End_Date)as Month,YEar(Month_End_Date)as Year 
					,EMP_CODE,Type_Name,Dept_Name,Desig_Name ,CMP_NAME,CMP_ADDRESS,PT_F_T_Limit,Comp_Name,Branch_Address,Branch_name,BM.Branch_ID,E.Alpha_Emp_Code
					,VS.Vertical_Name,SB.SubBranch_Name,SV.SubVertical_Name		
					,E.Emp_First_Name    --added jimit 09062015
					,DGM.Desig_Dis_No    --added jimit 24082015
				 From T0200_MONTHLY_SALARY MS WITH (NOLOCK) Inner join 
				T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID INNER  JOIN 
					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
					--T0095_Increment I_Q on Ms.Increment_ID = I_Q.Increment_ID 

				(select I.Emp_Id,I.Branch_ID,I.Grd_ID,I.Cat_ID,I.Dept_ID,I.SubVertical_ID,I.subBranch_ID,i.Vertical_ID,I.Desig_Id,I.Type_ID,I.Emp_PT from T0095_Increment I WITH (NOLOCK) inner join 
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID) I_Q on EC.Emp_ID = I_Q.Emp_Id
						and I_Q.Emp_PT = 1 --add by chetan 24-10-16				
					inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  INNER JOIN 
							T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID left join
							T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=I_Q.subBranch_ID left join
							T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=I_Q.Vertical_ID left join
							T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID=I_Q.SubVertical_ID					
											
				WHERE E.Cmp_ID = @Cmp_Id	
					--and Month_St_Date >=@From_Date and Month_End_Date <=@To_Date 
					And MONTH(month_end_date)=Month(@To_Date) And Year(Month_End_Date) = Year(@to_Date)
					--and PT_Amount > 0 --Comment Ankit For GTPL Display All Employee in Report
				
		End
	else if @Report_call = 'PT Statement SlabWise'
		begin 
				
				
				Declare @PT_Challan_SlabWise Table
				  ( 
					Cmp_ID		numeric ,
					Branch_ID 		numeric ,
					PT_L_T_Limit  	varchar(50),
					A_PT_Amount		numeric(18,2) default 0,
					PT_Amount		numeric(18,2) default 0,
					P_month		numeric ,
					P_Year		numeric,
					PT_calculated_Amount  numeric	default 0				
					,Challan_ID	numeric default 0 
					,From_Limit	numeric default 0 
					,To_Limit   numeric default 0 
				  )	
					
															  
			
				insert into @PT_Challan_SlabWise (Cmp_Id,Branch_Id,A_PT_Amount,PT_L_T_Limit,P_Month,P_Year)
				select distinct p.Cmp_ID,p.Branch_ID ,Amount ,cast(From_Limit as varchar(20)) + '-' +  Case When Cast(p.To_Limit as VARCHAR(20)) like '999%' Then 'To Above' ELSE cast(To_Limit as varchar(20)) END  ,Month(@To_Date) ,year(@To_Date)

				from T0040_professional_setting p WITH (NOLOCK) inner join 
				( select max(for_Date)For_Date ,Branch_ID from T0040_professional_setting WITH (NOLOCK)
					where Cmp_ID = @cmp_ID and (Branch_ID = ISNULL(@Branch_ID,Branch_ID) or isnull(Branch_ID,0) = 0 ) and For_Date <= @To_Date      --add branch_Id,For_date condition Mihir 06092011 -- branch condition altered by mitesh on 23072012
				group by branch_ID) q on p.For_Date = q.for_Date and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
				Where p.Cmp_Id =@Cmp_ID and isnull(P.Branch_ID,0) = isnull(q.Branch_ID,0)
				
				
				
				Select ms.Emp_Id,MS.Pt_Calculated_Amount,P.PT_L_T_Limit,Ms.PT_Amount,ISNULL(EmpName_Alias_PT,Emp_Full_Name) as Emp_full_Name,Grd_Name,Month(Month_End_Date)as Month,YEar(Month_End_Date)as Year 
					,EMP_CODE,Type_Name,Dept_Name,Desig_Name ,CMP_NAME,CMP_ADDRESS,PT_F_T_Limit,Comp_Name,Branch_Address,Branch_name,BM.Branch_ID,E.Alpha_Emp_Code
					,VS.Vertical_Name,SB.SubBranch_Name,SV.SubVertical_Name		
					,E.Emp_First_Name    --added jimit 09062015
					,DGM.Desig_Dis_No    --added jimit 24082015
					
				 From T0200_MONTHLY_SALARY MS WITH (NOLOCK) Inner join 
				T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID INNER  JOIN 
					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
					--T0095_Increment I_Q on Ms.Increment_ID = I_Q.Increment_ID 

				(select I.Emp_Id,I.Branch_ID,I.Grd_ID,I.Cat_ID,I.Dept_ID,I.SubVertical_ID,I.subBranch_ID,i.Vertical_ID,I.Desig_Id,I.Type_ID,I.Emp_PT from T0095_Increment I WITH (NOLOCK) inner join 
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID) I_Q on EC.Emp_ID = I_Q.Emp_Id
						and I_Q.Emp_PT = 1 --add by chetan 24-10-16				
					inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  INNER JOIN 
							T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID left join
							T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=I_Q.subBranch_ID left join
							T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=I_Q.Vertical_ID left join
							T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID=I_Q.SubVertical_ID
					Inner join 
							@PT_Challan_SlabWise  P ON p.Branch_ID = EC.Branch_ID and p.A_PT_Amount = MS.PT_Amount				
											
				WHERE E.Cmp_ID = @Cmp_Id	
					--and Month_St_Date >=@From_Date and Month_End_Date <=@To_Date 
					And MONTH(month_end_date)=Month(@To_Date) And Year(Month_End_Date) = Year(@to_Date)
				order By PT_Amount
				--select * from @PT_Challan_SlabWise
				
			
		end
	else
		Begin
		
						 Declare @PT_Challan Table
							  ( 
  								Cmp_ID		numeric ,
								Branch_ID 		numeric ,
								PT_L_T_Limit  	varchar(50),
								A_PT_Amount		numeric(18,2) default 0,
								PT_Amount		numeric(18,2) default 0,
								P_month		numeric ,
								P_Year		numeric,
								PT_calculated_Amount  numeric	default 0,
								Emp_Count	numeric default 0 ,
								PT_NA       numeric default 0,
								Total_PT    numeric default 0
								,Gender		Varchar(10) default null	--Ankit 04032016
								,Challan_ID	numeric default 0 -- Ankit 12082016
								,From_Limit	numeric default 0 -- Ankit 12082016
								,To_Limit   numeric default 0 -- Ankit 12082016
							  )	
							  
				 
				
				Declare @MultiBranch as varchar(max)
				if @Challan_Id > 0  --Added By Jaina 10-02-2016
					Begin
					
						Select @MultiBranch = Isnull(Branch_ID_Multi,Branch_Id) 
						From T0220_PT_CHALLAN WITH (NOLOCK) Where Cmp_ID = @Cmp_Id And Challan_Id=@Challan_Id
						
					End
				Else
					Begin
						-- set @MultiBranch = @branch_Id
						 
						 -------
						 IF ISNULL(@Branch_ID,0) = 0
							BEGIN
								 SELECT @MultiBranch = --Isnull(Branch_ID_Multi,Branch_Id) 
											COALESCE(@MultiBranch , '#') + Branch_ID_Multi + '#'
								 FROM T0220_PT_CHALLAN WITH (NOLOCK) WHERE Cmp_ID = @Cmp_Id	AND MONTH = MONTH(@To_Date) AND YEAR = YEAR(@To_Date)
								 -------
								 SET @MultiBranch = RIGHT(@MultiBranch, LEN(@MultiBranch)-1)
								 SET @MultiBranch = LEFT(@MultiBranch, LEN (@MultiBranch)-1) 
							END
						ELSE
							BEGIN
								 SET @MultiBranch = CAST(@Branch_ID AS VARCHAR(5))
							END	
						 
					End
			
			--------
			
			
			Declare @Branch_ID_Temp		Varchar(20)
			Declare @Challan_ID_temp	Varchar(20)
			--------
			DECLARE @Flag_Gender NUMERIC
			SET @Flag_Gender = 0
			Declare @State_Name varchar(50)
			set @State_Name = 0
			
			If Isnull(@MultiBranch,'0') = '0' --Added this condition by Hardik 11/08/2016 as Form 5 report is not opening for all branch
				BEGIN
					Declare CurBranch cursor Fast_forward for	                  
						SELECT DISTINCT Branch_Id From @Emp_Cons
					Open CurBranch                      
				END
			
			ELSE
				BEGIN
					Declare CurBranch cursor Fast_forward for	                  
						select Data From dbo.Split(@MultiBranch,'#')
					Open CurBranch                      
				END 
			Fetch next from CurBranch into @branch_Id
				While @@fetch_status = 0                    
					Begin  
						
						--------Ankit 12082016 --------
						SET @Challan_ID_temp = 0
						SELECT @Challan_ID_temp = Challan_Id FROM T0220_PT_CHALLAN WITH (NOLOCK)
						WHERE Cmp_ID = @Cmp_ID AND CHARINDEX('#' + CAST(@branch_Id AS VARCHAR(10)) + '#','#' + Branch_ID_Multi + '#') <> 0
								AND MONTH = Month(@To_Date) AND YEAR = year(@To_Date)
						--------Ankit 12082016 --------
						
						SET @State_Name = 0
								
						SELECT @State_Name = SM.State_Name FROM T0030_BRANCH_MASTER BM WITH (NOLOCK) INNER JOIN T0020_STATE_MASTER SM WITH (NOLOCK) ON BM.State_ID = SM.State_ID
						WHERE Branch_ID = @branch_Id and BM.Cmp_ID = @cmp_ID
						
						IF ISNULL(@State_Name,0) = 'Maharashtra'	--Ankit 04032016
							BEGIN
								SET @Flag_Gender = 1
								
								insert into @PT_Challan (Cmp_Id,Branch_Id,A_PT_Amount,PT_L_T_Limit,P_Month,P_Year,Gender,cHALLAN_ID,From_Limit ,To_Limit)
								select /*distinct*/ p.Cmp_ID,p.Branch_ID ,Amount ,cast(From_Limit as varchar(20)) + '-' +  Case When Cast(p.To_Limit as VARCHAR(20)) like '999%' Then 'To Above' ELSE cast(To_Limit as varchar(20)) END + ' (' + left(p.Applicable_PT_Male_Female,1) + ') '  ,Month(@To_Date) ,year(@To_Date),p.Applicable_PT_Male_Female
								,@Challan_ID_temp ,From_Limit ,To_Limit
								from T0040_professional_setting p WITH (NOLOCK) inner join 
								( select max(for_Date)For_Date ,Branch_ID from T0040_professional_setting WITH (NOLOCK)
									where Cmp_ID =@cmp_ID and (Branch_ID = ISNULL(@Branch_ID,Branch_ID) or isnull(Branch_ID,0) = 0 ) and For_Date <= @To_Date      --add branch_Id,For_date condition Mihir 06092011 -- branch condition altered by mitesh on 23072012
									group by branch_ID 
								) q on p.For_Date = q.for_Date and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
								Where p.Cmp_Id =@Cmp_ID 
								and isnull(P.Branch_ID,0) = isnull(q.Branch_ID,0)
							END
						ELSE	
							BEGIN
								insert into @PT_Challan (Cmp_Id,Branch_Id,A_PT_Amount,PT_L_T_Limit,P_Month,P_Year,Gender,cHALLAN_ID,From_Limit ,To_Limit)
								select distinct p.Cmp_ID,p.Branch_ID ,Amount ,cast(From_Limit as varchar(20)) + '-' +  Case When Cast(p.To_Limit as VARCHAR(20)) like '999%' Then 'To Above' ELSE cast(To_Limit as varchar(20)) END  ,Month(@To_Date) ,year(@To_Date),p.Applicable_PT_Male_Female
								,@Challan_ID_temp ,From_Limit ,To_Limit
								from T0040_professional_setting p WITH (NOLOCK) inner join 
								( select max(for_Date)For_Date ,Branch_ID from T0040_professional_setting WITH (NOLOCK)
									where Cmp_ID =@cmp_ID and (Branch_ID = ISNULL(@Branch_ID,Branch_ID) or isnull(Branch_ID,0) = 0 ) and For_Date <= @To_Date      --add branch_Id,For_date condition Mihir 06092011 -- branch condition altered by mitesh on 23072012
								group by branch_ID
								) q on p.For_Date = q.for_Date and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
								Where p.Cmp_Id =@Cmp_ID 
								and isnull(P.Branch_ID,0) = isnull(q.Branch_ID,0)
							END 
							
						--insert into @PT_Challan (Cmp_Id,Branch_Id,A_PT_Amount,PT_L_T_Limit,P_Month,P_Year,cHALLAN_ID,From_Limit ,To_Limit)
						--select distinct p.Cmp_ID,p.Branch_ID ,Amount ,cast(From_Limit as varchar(20)) + '-' +  cast(To_Limit as varchar(20))  ,Month(@To_Date) ,year(@To_Date),@Challan_ID_temp
						--			,From_Limit ,To_Limit
						--from T0040_professional_setting p inner join 
						--( select max(for_Date)For_Date ,Branch_ID from T0040_professional_setting 
						--	where Cmp_ID =@cmp_ID and (Branch_ID = ISNULL(@Branch_ID,Branch_ID) or isnull(Branch_ID,0) = 0 ) and For_Date <= @To_Date      --add branch_Id,For_date condition Mihir 06092011 -- branch condition altered by mitesh on 23072012
						--group by branch_ID) q on p.For_Date = q.for_Date and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
						--Where p.Cmp_Id =@Cmp_ID 
						--and isnull(P.Branch_ID,0) = @branch_Id-- isnull(q.Branch_ID,0)
						
						
				fetch next from CurBranch into @branch_Id
					end                    
			close CurBranch                    
			deallocate CurBranch
			
				DELETE FROM @PT_Challan WHERE Challan_ID = 0
				DELETE FROM @PT_Challan WHERE Branch_ID IS NULL
				
				 
				IF @Flag_Gender = 1	--Ankit 04032016
					BEGIN
						UPDATE @PT_Challan 
						SET PT_Amount = q.Sum_PT_Amount ,
							PT_calculated_Amount = q.sum_PT_calculated_Amount,
							Emp_Count = q.Emp_Count
						FROM @PT_Challan  P INNER JOIN 
							( 
								SELECT ec.Branch_Id,From_Limit,COUNT(ms.emp_Id)Emp_Count,SUM(MS.PT_Amount) Sum_PT_Amount,SUM(MS.PT_calculated_Amount ) sum_PT_calculated_Amount 
								FROM	T0200_MONTHLY_SALARY ms WITH (NOLOCK)
									INNER JOIN @emp_Cons ec ON ms.emp_ID = ec.emp_ID 
									INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ec.Emp_ID AND EM.Gender = 'M'
									INNER JOIN 
									@PT_Challan PC ON PC.Branch_ID = ec.Branch_ID AND ms.PT_calculated_Amount BETWEEN PC.From_Limit AND PC.To_Limit AND	PC.Gender = 'MALE'
								WHERE 
									MONTH(month_end_date)=MONTH(@To_Date) AND YEAR(Month_End_Date) = YEAR(@to_Date)
								GROUP BY ec.Branch_ID ,PC.From_Limit
								
							 ) q ON p.Branch_ID =q.Branch_ID AND q.From_Limit = p.From_Limit
						WHERE  ISNULL(p.Branch_ID,0) >0  AND	p.Gender = 'MALE'		
						
						UPDATE @PT_Challan 
						SET PT_Amount = q.Sum_PT_Amount ,
							PT_calculated_Amount = q.sum_PT_calculated_Amount,
							Emp_Count = q.Emp_Count
						FROM @PT_Challan  P INNER JOIN 
							( 
								SELECT ec.Branch_Id,From_Limit,COUNT(ms.emp_Id)Emp_Count,SUM(MS.PT_Amount) Sum_PT_Amount,SUM(MS.PT_calculated_Amount ) sum_PT_calculated_Amount 
								FROM	T0200_MONTHLY_SALARY ms WITH (NOLOCK)
									INNER JOIN @emp_Cons ec ON ms.emp_ID = ec.emp_ID 
									INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ec.Emp_ID AND EM.Gender = 'F'
									INNER JOIN 
									@PT_Challan PC ON PC.Branch_ID = ec.Branch_ID AND ms.PT_calculated_Amount BETWEEN PC.From_Limit AND PC.To_Limit AND	PC.Gender = 'FEMALE'	
								WHERE 
									MONTH(month_end_date)=MONTH(@To_Date) AND YEAR(Month_End_Date) = YEAR(@to_Date)
								GROUP BY ec.Branch_ID ,PC.From_Limit
								
							 ) q ON p.Branch_ID =q.Branch_ID AND q.From_Limit = p.From_Limit
						WHERE  ISNULL(p.Branch_ID,0) >0  AND	p.Gender = 'FEMALE'		
						
						UPDATE @PT_Challan 
						SET PT_Amount = q.Sum_PT_Amount ,
							PT_calculated_Amount = q.sum_PT_calculated_Amount,
							Emp_Count = q.Emp_Count
						FROM @PT_Challan  P INNER JOIN 
							( 
								SELECT ec.Branch_Id,From_Limit,COUNT(ms.emp_Id)Emp_Count,SUM(MS.PT_Amount) Sum_PT_Amount,SUM(MS.PT_calculated_Amount ) sum_PT_calculated_Amount 
								FROM	T0200_MONTHLY_SALARY ms WITH (NOLOCK) 
									INNER JOIN @emp_Cons ec ON ms.emp_ID = ec.emp_ID 
									--INNER JOIN T0080_EMP_MASTER EM ON Em.Emp_ID = ec.Emp_ID 
									INNER JOIN 
									@PT_Challan PC ON PC.Branch_ID = ec.Branch_ID AND ms.PT_calculated_Amount BETWEEN PC.From_Limit AND PC.To_Limit AND	PC.Gender = 'ALL'
								WHERE 
									MONTH(month_end_date)=MONTH(@To_Date) AND YEAR(Month_End_Date) = YEAR(@to_Date)
								GROUP BY ec.Branch_ID ,PC.From_Limit
								
							 ) q ON p.Branch_ID =q.Branch_ID AND q.From_Limit = p.From_Limit
						WHERE  ISNULL(p.Branch_ID,0) >0  AND ISNULL(p.Gender,'ALL') = 'ALL'
						
						--update @PT_Challan 
						--set PT_Amount = q.Sum_PT_Amount ,
						--	PT_calculated_Amount = q.sum_PT_calculated_Amount,
						--	Emp_Count = q.Emp_Count
						--From @PT_Challan  P inner join 
						--	( Select ec.Branch_Id,count(ms.emp_Id)Emp_Count,PT_Amount,sum(PT_Amount) Sum_PT_Amount,Sum(PT_calculated_Amount ) sum_PT_calculated_Amount 
						--		From	T0200_MONTHLY_SALARY ms 
						--			inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
						--			INNER JOIN T0080_EMP_MASTER EM ON Em.Emp_ID = ec.Emp_ID AND EM.Gender = 'M'
						--		Where 
						--			MONTH(month_end_date)=Month(@To_Date) And Year(Month_End_Date) = Year(@to_Date)
						--			group by ec.Branch_ID ,PT_Amount
						--	 ) q on p.Branch_ID =q.Branch_ID and p.A_PT_Amount = q.PT_Amount and q.sum_PT_calculated_Amount between p.From_Limit and P.To_Limit
						--Where  isnull(p.Branch_ID,0) >0  
						--		AND	p.Gender = 'MALE'	
								
						--update @PT_Challan 
						--set PT_Amount = q.Sum_PT_Amount ,
						--	PT_calculated_Amount = q.sum_PT_calculated_Amount,
						--	Emp_Count = q.Emp_Count
						--From @PT_Challan  P inner join 
						--	( Select ec.Branch_Id,count(ms.emp_Id)Emp_Count,PT_Amount,sum(PT_Amount) Sum_PT_Amount,Sum(PT_calculated_Amount ) sum_PT_calculated_Amount 
						--		From	T0200_MONTHLY_SALARY ms 
						--			inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
						--			INNER JOIN T0080_EMP_MASTER EM ON Em.Emp_ID = ec.Emp_ID AND EM.Gender = 'F'	
						--		Where 
						--			MONTH(month_end_date)=Month(@To_Date) And Year(Month_End_Date) = Year(@to_Date)
						--		group by ec.Branch_ID ,PT_Amount
						--	 ) q on p.Branch_ID =q.Branch_ID and p.A_PT_Amount = q.PT_Amount and q.sum_PT_calculated_Amount between p.From_Limit and P.To_Limit
						--Where  isnull(p.Branch_ID,0) >0  
						--		AND	p.Gender = 'FEMALE'	

						--update @PT_Challan 
						--set PT_Amount = q.Sum_PT_Amount ,
						--	PT_calculated_Amount = q.sum_PT_calculated_Amount,
						--	Emp_Count = q.Emp_Count
						--From @PT_Challan  P inner join 
						--	( Select ec.Branch_Id,count(ms.emp_Id)Emp_Count,PT_Amount,sum(PT_Amount) Sum_PT_Amount,Sum(PT_calculated_Amount ) sum_PT_calculated_Amount 
						--		From	T0200_MONTHLY_SALARY ms --inner join T0095_Increment I on ms.Increment_ID =i.Increment_ID 
						--			inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
						--		Where --ms.PT_Amount > 0 AND  --Added By Jaina 5-10-2015
						--		--Month_St_date >=@From_Date and Month_End_Date <=@To_Date   --
						--		MONTH(month_end_date)=Month(@To_Date) And Year(Month_End_Date) = Year(@to_Date)
						--		group by ec.Branch_ID ,PT_Amount
						--	 ) q on p.Branch_ID =q.Branch_ID and p.A_PT_Amount = q.PT_Amount and q.sum_PT_calculated_Amount between p.From_Limit and P.To_Limit
						--Where  isnull(p.Branch_ID,0) >0 AND	ISNULL(p.Gender,'ALL') = 'ALL'
													
					END
				ELSE
					BEGIN
						
						UPDATE @PT_Challan 
						SET PT_Amount = q.Sum_PT_Amount ,
							PT_calculated_Amount = q.sum_PT_calculated_Amount,
							Emp_Count = q.Emp_Count
						FROM @PT_Challan  P INNER JOIN 
							( 
								SELECT ec.Branch_Id,From_Limit,COUNT(ms.emp_Id)Emp_Count,SUM(MS.PT_Amount) Sum_PT_Amount,SUM(MS.PT_calculated_Amount ) sum_PT_calculated_Amount 
								FROM	T0200_MONTHLY_SALARY ms WITH (NOLOCK)
								INNER JOIN @emp_Cons ec ON ms.emp_ID = ec.emp_ID INNER JOIN 
								@PT_Challan PC ON PC.Branch_ID = ec.Branch_ID AND ms.PT_calculated_Amount BETWEEN PC.From_Limit AND PC.To_Limit
								WHERE 
									MONTH(month_end_date)=MONTH(@To_Date) AND YEAR(Month_End_Date) = YEAR(@to_Date)
								GROUP BY ec.Branch_ID ,PC.From_Limit
								--Select Branch_Id,count(ms.emp_Id)Emp_Count,PT_Amount,sum(PT_Amount) Sum_PT_Amount,Sum(PT_calculated_Amount ) sum_PT_calculated_Amount 
								--From	T0200_MONTHLY_SALARY ms --inner join T0095_Increment I on ms.Increment_ID =i.Increment_ID 
								--inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
								--Where --ms.PT_Amount > 0 AND  --Added By Jaina 5-10-2015
								----Month_St_date >=@From_Date and Month_End_Date <=@To_Date   --
								--MONTH(month_end_date)=Month(@To_Date) And Year(Month_End_Date) = Year(@to_Date)
								--group by Branch_ID ,PT_Amount
							 ) q ON p.Branch_ID =q.Branch_ID AND q.From_Limit = p.From_Limit
						WHERE  ISNULL(p.Branch_ID,0) >0 	
								
					END
		
				--update @PT_Challan 
				--set PT_Amount = q.Sum_PT_Amount ,
				--	PT_calculated_Amount = q.sum_PT_calculated_Amount,
				--	Emp_Count = q.Emp_Count
				--From @PT_Challan  P inner join 
				--	( Select Branch_Id,count(ms.emp_Id)Emp_Count,PT_Amount,sum(PT_Amount) Sum_PT_Amount,Sum(PT_calculated_Amount ) sum_PT_calculated_Amount 
				--		From	T0200_MONTHLY_SALARY ms --inner join T0095_Increment I on ms.Increment_ID =i.Increment_ID 
				--		inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
				--		Where --ms.PT_Amount > 0 AND  --Added By Jaina 5-10-2015
				--		--Month_St_date >=@From_Date and Month_End_Date <=@To_Date   --
				--		MONTH(month_end_date)=Month(@To_Date) And Year(Month_End_Date) = Year(@to_Date)
				--		group by Branch_ID ,PT_Amount
				--	 ) q on p.Branch_ID =q.Branch_ID and p.A_PT_Amount = q.PT_Amount and q.sum_PT_calculated_Amount between p.From_Limit and P.To_Limit
				--Where  isnull(p.Branch_ID,0) >0 			

			
				
			 	update @PT_Challan 
				set PT_Amount = q.Sum_PT_Amount ,
					PT_calculated_Amount = q.sum_PT_calculated_Amount,
					Emp_Count = q.Emp_Count
				From @PT_Challan  P inner join 
					( Select PT_Amount,count(ms.emp_Id)Emp_Count,sum(PT_Amount) Sum_PT_Amount,Sum(PT_calculated_Amount ) sum_PT_calculated_Amount 
						From	T0200_MONTHLY_SALARY ms WITH (NOLOCK) --inner join T0095_Increment I on ms.Increment_ID =i.Increment_ID 
						inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
						Where --Month_St_date >=@From_Date and Month_End_Date <=@To_Date 
						MONTH(month_end_date)=Month(@To_Date) And Year(Month_End_Date) = Year(@to_Date)
						group by PT_Amount) q on isnull(p.Branch_ID,0) =0 and p.A_PT_Amount = q.PT_Amount
				Where  isnull(p.Branch_ID,0) =0
				
				
				
				update @PT_Challan 
				set  PT_NA = q.PT_NA
				From @PT_Challan  P inner join 
					(Select count(ms.Emp_ID) PT_NA 
						From	T0200_MONTHLY_SALARY ms WITH (NOLOCK) --inner join T0095_Increment I on ms.Increment_ID =i.Increment_ID 
						inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
						Where --Month_St_date >=@From_Date and Month_End_Date <=@To_Date
						MONTH(month_end_date)=Month(@To_Date) And Year(Month_End_Date) = Year(@to_Date)
						group by PT_Amount) q on isnull(p.Branch_ID,0) =0 and p.A_PT_Amount = 0
				Where  isnull(p.Branch_ID,0) =0
				
			
			--Added By Jaina 29-09-2015 Start			
			 Create table #Branch_Cons 
			 (      
      
				Branch_Name_Multi varchar(max),
				Cmp_ID numeric,
				Challan_ID	Numeric
			 )     
			  
			 if @Challan_Id > 0  --Added By Jaina 10-02-2016
				  Begin
						Insert Into #Branch_Cons(Branch_Name_Multi,Cmp_ID,Challan_Id)
						SELECT Branch_Name_Multi,Cmp_ID,Challan_Id from V0220_PT_Challan where Cmp_ID=@Cmp_Id	and Challan_Id=@Challan_Id	
				  End
			  Else
				  Begin
						Insert Into #Branch_Cons(Branch_Name_Multi,Cmp_ID,Challan_Id)
						SELECT Branch_Name_Multi,Cmp_ID,Challan_Id from V0220_PT_Challan 
						where Cmp_ID=@Cmp_Id --and Branch_ID_Multi =@MultiBranch	
							AND [Month] = Month(@From_date) AND [Year] = Year(@From_date) --Ankit 29022016
							and Challan_Id IN ( SELECT distinct Challan_Id from @PT_Challan ) --Ankit 29022016
							
				  End
			--Added By Jaina 29-09-2015 End		
			
			
			select p.* ,bm.Branch_NAme,bm.Branch_Address as Branch_Address ,Cmp_Phone,--Cmp_Address,Cmp_Name,
				Case When bm.Comp_Name <> '' Then bm.Comp_Name Else CM.Cmp_Name End As Cmp_Name, --- Change Alias Cmp_Name to Cmp_Name1, PT Form 5 Report has issue in Gallops, Change By Hardik 12/04/2019
				Case When bm.Branch_Address <> '' Then bm.Branch_Address Else CM.Cmp_Address End As Cmp_Address, --- Change Alias Cmp_Address to Cmp_Address1, PT Form 5 Report has issue in Gallops, Change By Hardik 12/04/2019
				@From_Date as Month_Start_Date,
				@To_Date as Month_End_Date,
				(case when @Report_call = 'PT Challan' then 
				(select [dbo].[F_Number_TO_Word](sum(PT_Amount) + Pc.Interest_Amount + Pc.Penalty_Amount) from @PT_Challan)
				else
					(select [dbo].[F_Number_TO_Word](sum(PT_Amount) + @PT_Interest + @PT_Penalty) from @PT_Challan)
				end)
				 as Total_PT_inWord ,
				BM.Branch_ID ,
				bm.PT_RC_NO,bm.PT_Zone,bm.PT_Ward_No,BM.PT_Census_No , SM.PT_Enroll_Cert_No,b.Branch_Name_Multi
				,SM.State_Name
				,Pc.Interest_Amount,Pc.Penalty_Amount
			from @PT_Challan	p left outer Join T0030_Branch_MAster bm  WITH (NOLOCK) on p.Branch_ID = bm.Branch_ID
			Inner join T0010_COMPANY_MASTER CM  WITH (NOLOCK) on p.Cmp_Id = cm.Cmp_ID 
			Left Outer Join T0020_State_Master SM WITH (NOLOCK) ON bm.State_ID = SM.State_ID	--Ankit 12012015
			inner JOIN #Branch_Cons as B ON B.Cmp_ID=p.Cmp_ID and b.Challan_ID = p.Challan_ID  --Added By Jaina 29-09-2015
			INNER JOIN T0220_PT_CHALLAN Pc WITH (NOLOCK) on Pc.Cmp_ID = P.Cmp_ID and Pc.Challan_Id = P.Challan_ID
			--inner JOIN T0220_PT_CHALLAN PT ON PT.Branch_ID = bm.Branch_ID 
			--inner JOIN
			--PT.Branch_ID_Multi IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(PT.Branch_ID_Multi, '#'))as p on  = bm.Branch_ID  --Added By Jaina 18-09-2015
			
			--where PT.Challan_Id = @Challan_Id 
			-- In Above Select after Cmp_Name fields added by Mihir 06092011	

			
		End			
RETURN
