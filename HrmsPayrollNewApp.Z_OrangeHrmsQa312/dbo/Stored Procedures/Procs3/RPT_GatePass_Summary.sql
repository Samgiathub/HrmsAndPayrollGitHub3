


CREATE PROCEDURE [dbo].[RPT_GatePass_Summary] 
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max) 
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max) 
	,@Desig_ID		varchar(Max) 
	,@Emp_ID		Numeric
	,@Constraint	varchar(MAX)
	,@Report_Type	tinyint = 0
	,@GatePass_Type varchar(10) = 'All'
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )  


	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0    
	
	Update #Emp_Cons  set Branch_ID = a.Branch_ID from (
		SELECT DISTINCT VE.Emp_ID,VE.branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE inner join
					  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
		)a
	where a.Emp_ID = #Emp_Cons.Emp_ID
					  
	
	CREATE TABLE #Emp_GatePass_Deduction
	(
		Tran_ID numeric(18,0),
		Emp_ID numeric(18,0),
		For_date datetime,
		Deduct_Day numeric(18,2)
	)	
	

	declare @Upto_days numeric(18,2)
	declare @Upto_Hours varchar(25)
	declare @Deduct_Days numeric(18,2)
	declare @Above_Hours varchar(25)
	declare @Deduct_Above_days numeric(18,2)
	declare @Tran_id numeric(18,0)
	declare @Gate_Pass_Sec integer
	declare @Upto_days_Count numeric(18,0)
	Declare @Cur_Emp_ID numeric(18,0)
	Declare @Cur_Branch_ID numeric(18,0)
	Declare @Prev_Branch_ID numeric(18,0)
	Declare @Cur_For_Date datetime
	Declare @Cur_Tran_ID numeric(18,0)
	Declare @Half_Shift_Duration numeric(18,2)
	set @Half_Shift_Duration = 0
	
	 set @Upto_days = 0
	 set @Upto_Hours = ''
	 set @Deduct_Days= 0
	 set @Above_Hours = ''
	 set @Deduct_Above_days = 0
	 set @Upto_days_Count = 0		   
	 set @Gate_Pass_Sec = 0
	 set  @Cur_Emp_ID = 0
	 set @Cur_Branch_ID = 0
	 set @Prev_Branch_ID = 0
	 set @Cur_Tran_ID = 0
	
	
	 
	 declare CurEmployee cursor for
		select distinct EG.emp_ID,EC.Branch_ID from T0150_EMP_Gate_Pass_INOUT_RECORD EG  WITH (NOLOCK)
		    inner join T0040_Reason_Master r WITH (NOLOCK) on R.Res_Id = EG.Reason_id and Gate_Pass_Type = Case When @GatePass_Type = 'All' then Gate_Pass_Type else @GatePass_Type End
			inner join #Emp_Cons EC on EG.emp_id  = EC.Emp_ID  
			where Is_Approved = 1  and For_date >= @From_Date and For_date <= @To_Date  Group by EG.emp_id,EC.Branch_ID	
	 Open CurEmployee
	  
			Fetch Next from CurEmployee into @Cur_Emp_ID,@Cur_Branch_ID
				WHILE @@fetch_status = 0
					BEGIN
					Set @Upto_days_Count = 0
					If @Cur_Branch_ID <> @Prev_Branch_ID
						begin
														
							select @Upto_days = Upto_days
								  ,@Upto_Hours = Upto_Hours
								  ,@Deduct_Days = Deduct_days
								  ,@Above_Hours = Above_Hours
								  ,@Deduct_Above_days = Deduct_Above_days 	
							 from [dbo].[T0010_Gate_Pass_Settings] WITH (NOLOCK) where Branch_id = @Cur_Branch_ID
							
							if @Upto_Hours = '00:00'
								set  @Upto_Hours = ''
							if @Above_Hours = '00:00'
								set @Above_Hours = ''
							
						end		 
						
						
							 declare @Exempted as tinyint
								set @Exempted = 0
							Declare CurGatepass cursor for  
												select dbo.F_Return_Sec(Replace(Hours,'*','0')) as Hours,Exempted,For_date,EG.Tran_Id,isnull(DateDiff(S,Shift_St_Time,Shift_End_Time)/2,0) as Half_Shift_Duration from dbo.T0150_EMP_Gate_Pass_INOUT_RECORD EG WITH (NOLOCK) inner join 
														 T0040_Reason_Master r WITH (NOLOCK) on R.Res_Id = EG.Reason_id and Gate_Pass_Type = Case When @GatePass_Type = 'All' then Gate_Pass_Type else @GatePass_Type End  
														 where emp_id = @Cur_Emp_Id and cmp_Id = @cmp_Id and Is_Approved = 1  and For_date >= @From_Date and For_date <= @To_Date  	
															order by for_date
														   		
							 Open CurGatepass
							   Fetch Next from CurGatepass into @Gate_Pass_Sec,@Exempted,@Cur_For_Date,@Cur_Tran_ID,@Half_Shift_Duration
							   WHILE @@fetch_status = 0
								 BEGIN	
						         	
									if @Above_Hours <> '' and @Upto_Hours <> '' 
										begin	
										
											 if  @Gate_Pass_Sec > @Half_Shift_Duration and @Half_Shift_Duration > 0 
													begin
															set @Upto_days_Count = @Upto_days_Count + 1	
															If @Exempted = 0
																begin	
																	Insert into #Emp_GatePass_Deduction
																		select @Cur_Tran_ID,@Cur_Emp_ID,@Cur_For_date,1
																end
															
													end
											 else if  @Gate_Pass_Sec > dbo.F_Return_Sec(@Above_Hours) 
												begin
													set @Upto_days_Count = @Upto_days_Count + 1
													If @Exempted = 0
														begin
															Insert into #Emp_GatePass_Deduction
															 select @Cur_Tran_ID,@Cur_Emp_ID,@Cur_For_date,@Deduct_Above_days
														end
													
												end
											else if( @Gate_Pass_Sec <= dbo.F_Return_Sec(@Upto_Hours) or @Gate_Pass_Sec <= dbo.F_Return_Sec(@Above_Hours)  ) 
												begin
													
													set @Upto_days_Count = @Upto_days_Count + 1
													If @Exempted = 0
														begin
															
															if @Upto_days_Count > @Upto_days 
																begin
																Insert into #Emp_GatePass_Deduction
																	select @Cur_Tran_ID,@Cur_Emp_ID,@Cur_For_date,@Deduct_Days   
																end
														end
												end
										end
									else if @Upto_Hours <> '' and @Above_Hours = ''
										begin
											
											if @Gate_Pass_Sec >= 1
												begin
													set @Upto_days_Count = @Upto_days_Count + 1
													If @Exempted = 0
														begin
															If @Gate_Pass_Sec > @Half_Shift_Duration and @Half_Shift_Duration > 0
																begin
																		Insert into #Emp_GatePass_Deduction
																					select @Cur_Tran_ID,@Cur_Emp_ID,@Cur_For_date,1
																end
															else
																begin 
																		if @Upto_days_Count > @Upto_days 
																			begin	
																				Insert into #Emp_GatePass_Deduction
																					select @Cur_Tran_ID,@Cur_Emp_ID,@Cur_For_date,@Deduct_Days   
																			end
																end
														end
													
														
												end
										
										end
									else if @Above_Hours <> '' and @Upto_Hours = ''
										begin
											If @Exempted = 0 
												begin
													If @Gate_Pass_Sec > @Half_Shift_Duration and @Half_Shift_Duration > 0
														begin
															Insert into #Emp_GatePass_Deduction
															  select @Cur_Tran_ID,@Cur_Emp_ID,@Cur_For_date,1
														end	
													else if @Gate_Pass_Sec > dbo.F_Return_Sec(@Above_Hours) 
														begin
															Insert into #Emp_GatePass_Deduction
															 select @Cur_Tran_ID,@Cur_Emp_ID,@Cur_For_date,@Deduct_Above_days
														end
												end		
										end
								
								  Fetch next from CurGatepass into @Gate_Pass_Sec,@Exempted,@Cur_For_Date,@Cur_Tran_ID,@Half_Shift_Duration
								 END 
							 Close CurGatepass
							 Deallocate CurGatepass
		
		
						 Fetch next from CurEmployee into @Cur_Emp_ID,@Cur_Branch_ID
			End
			
	 close CurEmployee
	 deallocate CurEmployee	
	
	--SELECT * FROM #Emp_GatePass_Deduction
	
	--added by jimit 03082016
	DECLARE @GatePass_caption as Varchar(20)	
	SELECT @GatePass_caption = Isnull(Alias,'Gate Pass') from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and SortingNo = 33
	--ended
	
	
	--Ronakb010824 add vertical for groupby
	 If @Report_Type = 0
		begin

			Select  E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
						, Branch_Name ,V.Vertical_Name,SubVertical_Name,SubBranch_Name, Dept_Name ,Grd_Name , Desig_Name,REPLACE(CONVERT(VARCHAR(11),EGP.For_Date,103),' ','/') as For_date ,REPLACE(CONVERT(VARCHAR(11),@From_Date,103),' ','/') as P_From_Date,REPLACE(CONVERT(
VARCHAR(11),@To_Date,103),' ','/') as P_To_Date ,BM.BRANCH_ID
						 , cm.cmp_name , cm.cmp_address, EGP.In_Time,EGP.Out_Time,EGP.Hours,
						 cast(case when r.Reason_Name = 'Official' then 0.00 else isnull(ED.Deduct_Day, 0) end as numeric(18,2)) as Deduct_Day,r.Reason_Name
						 -- r.Reason_Name,cast(isnull(ED.Deduct_Day,0) as numeric(18,2)) as Deduct_Day ronakb291024
						 ,EGP.Shift_St_Time,EGP.Shift_End_Time,case when EGP.Exempted = 1 then 'Yes' else 'No' end Exempted 
						,@GatePass_caption as Caption --added by jimit 03082016
						from T0150_EMP_Gate_Pass_INOUT_RECORD EGP WITH (NOLOCK) Inner join
						T0040_Reason_Master r WITH (NOLOCK) on r.Res_Id = EGP.Reason_id and R.Gate_Pass_Type = Case When @GatePass_Type = 'All' then R.Gate_Pass_Type else @GatePass_Type End
						Left outer join
						#Emp_GatePass_Deduction ED on EGP.Emp_ID = ED.Emp_ID and EGP.For_date = ED.For_date and ED.Tran_ID = EGP.Tran_Id
						Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EGP.EMP_ID = E.EMP_ID
						INNER JOIN ( SELECT I.Branch_ID,Vertical_ID,SubVertical_ID,SubBranch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
						E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID   LEFT OUTER JOIN 
						T0040_Vertical_Segment V WITH (NOLOCK) ON Q_I.Vertical_ID = V.Vertical_ID LEFT OUTER JOIN 
					    T0050_SubVertical SV WITH (NOLOCK) ON Q_I.SubVertical_ID = SV.SubVertical_ID LEFT OUTER JOIN 
					    T0050_SubBranch SB  WITH (NOLOCK) ON Q_I.SubBranch_ID = SB.SubBranch_ID Inner join
						T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.cmp_id = EGP.cmp_id Inner join
						#Emp_Cons ec on ec.Emp_ID = EGP.Emp_ID
						where EGP.For_date >= @From_Date and EGP.For_date <=@To_Date and EGP.Is_Approved = 1 
						Order by Emp_code,EGP.For_date
		end
	else if @Report_Type = 1
		begin
					Select  E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
						, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,REPLACE(CONVERT(VARCHAR(11),EGP.For_Date,103),' ','/') as For_date ,REPLACE(CONVERT(VARCHAR(11),@From_Date,103),' ','/') as P_From_Date,REPLACE(CONVERT(VARCHAR(11),@To_Date,103),' ','/') as P_To_Date 
,BM.BRANCH_ID
						 , cm.cmp_name , cm.cmp_address, EGP.In_Time,EGP.Out_Time,EGP.Hours,r.Reason_Name,cast(isnull(ED.Deduct_Day,0) as numeric(18,2)) as Deduct_Day
						 ,EGP.Shift_St_Time,EGP.Shift_End_Time,case when EGP.Exempted = 1 then 'Yes' else 'No' end Exempted 
						,@GatePass_caption as Caption --added by jimit 03082016
						from T0150_EMP_Gate_Pass_INOUT_RECORD EGP WITH (NOLOCK) Inner join
						T0040_Reason_Master r WITH (NOLOCK) on r.Res_Id = EGP.Reason_id and R.Gate_Pass_Type = Case When @GatePass_Type = 'All' then R.Gate_Pass_Type else @GatePass_Type End 
						Left outer join
						#Emp_GatePass_Deduction ED on EGP.Emp_ID = ED.Emp_ID and EGP.For_date = ED.For_date and ED.Tran_ID = EGP.Tran_Id
						Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EGP.EMP_ID = E.EMP_ID
						INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
						E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID   Inner join 
						T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.cmp_id = EGP.cmp_id Inner join
						#Emp_Cons ec on ec.Emp_ID = EGP.Emp_ID
						where EGP.For_date >= @From_Date and EGP.For_date <=@To_Date and EGP.Is_Approved = 1 and isnull(ED.Deduct_Day,0) > 0
						Order by Emp_code,EGP.For_date
		end	
	else if @Report_Type = 2  -- Added by Gadriwala Muslim 08-09-2015/ For ESS User Show all official & Personal Reason Approved Gatepass Punch
		begin

				Select  E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
						, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,REPLACE(CONVERT(VARCHAR(11),EGP.For_Date,103),' ','/') as For_date ,REPLACE(CONVERT(VARCHAR(11),@From_Date,103),' ','/') as P_From_Date,REPLACE(CONVERT(VARCHAR(11),@To_Date,103),' ','/') as P_To_Date 
,BM.BRANCH_ID
						 , cm.cmp_name , cm.cmp_address, EGP.In_Time,EGP.Out_Time,EGP.Hours,r.Reason_Name,cast(isnull(ED.Deduct_Day,0) as numeric(18,2)) as Deduct_Day
						 ,EGP.Shift_St_Time,EGP.Shift_End_Time,case when EGP.Exempted = 1 then 'Yes' else 'No' end Exempted 
						,@GatePass_caption as Caption --added by jimit 03082016
						from T0150_EMP_Gate_Pass_INOUT_RECORD EGP WITH (NOLOCK) inner join
						T0040_Reason_Master r WITH (NOLOCK) on r.Res_Id = EGP.Reason_id and R.Gate_Pass_Type = 'Personal' Left outer join
						#Emp_GatePass_Deduction ED on EGP.Emp_ID = ED.Emp_ID and EGP.For_date = ED.For_date and ED.Tran_ID = EGP.Tran_Id
						Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EGP.EMP_ID = E.EMP_ID
						INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
						E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID   Inner join 
						T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.cmp_id = EGP.cmp_id Inner join
						#Emp_Cons ec on ec.Emp_ID = EGP.Emp_ID
						where EGP.For_date >= @From_Date and EGP.For_date <=@To_Date and EGP.Is_Approved = 1 
						union 
						Select  E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
						, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,REPLACE(CONVERT(VARCHAR(11),EGP.For_Date,103),' ','/') as For_date ,REPLACE(CONVERT(VARCHAR(11),@From_Date,103),' ','/') as P_From_Date,REPLACE(CONVERT(VARCHAR(11),@To_Date,103),' ','/') as P_To_Date 
,BM.BRANCH_ID
						 , cm.cmp_name , cm.cmp_address, EGP.In_Time,EGP.Out_Time,EGP.Hours,r.Reason_Name,0 as Deduct_Day
						 ,EGP.Shift_St_Time,EGP.Shift_End_Time, 'Yes' as Exempted ,@GatePass_caption as Caption --binal added 03032020
						from T0150_EMP_Gate_Pass_INOUT_RECORD EGP WITH (NOLOCK) Inner join
						T0040_Reason_Master r WITH (NOLOCK) on r.Res_Id = EGP.Reason_id and R.Gate_Pass_Type = 'Official' 
						Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EGP.EMP_ID = E.EMP_ID
						INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
						E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID   Inner join 
						T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.cmp_id = EGP.cmp_id Inner join
						#Emp_Cons ec on ec.Emp_ID = EGP.Emp_ID
						where EGP.For_date >= @From_Date and EGP.For_date <=@To_Date and EGP.Is_Approved = 1 
						Order by Emp_code,For_date
			end
	
				
END
