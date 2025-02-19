

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_LEAVE_APPROVAL_DETAILS_GET]
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
	,@Leave_Status  varchar(1)
	,@Constraint	varchar(max)
	,@Format varchar(100) = 'Default' 
	,@Format_Excel Numeric(2,0) = 0
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
		
	if @Format = 'Leave with Absent Days'
		Begin
			if	exists (select * from [tempdb].dbo.sysobjects where name like '#Att_Muster_Absent' )		
				begin
					drop table #Att_Muster
				end
			
				CREATE TABLE #Att_Muster_Absent
				(
					Emp_Id		numeric , 
					Cmp_ID		numeric,
					For_Date	datetime,
					[Status]	varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
					Leave_Count	numeric(12,3),--numeric(5,2),
					WO_HO		varchar(3), --2 to 3 char changed by Sumit for showing 'OHO' optional Holiday on 9/11/2016
					Status_2	varchar(20),
					Row_ID		numeric ,
					WO_HO_Day	numeric(3,2) default 0,
					P_days		numeric(12,3) default 0, 
					A_days		numeric(12,3) default 0,
					Join_Date	Datetime default null,
					Left_Date	Datetime default null,
					GatePass_Days numeric(18,2) default 0, --Added by Gadriwala Muslim 07042015
					Late_deduct_Days numeric(18,2) default 0,  --Added by Gadriwala Muslim 07042015
					Early_deduct_Days numeric(18,2) default 0,  --Added by Gadriwala Muslim 07042015
					Leave_Type Varchar(100) default ''
			    )	
			  
			if exists (select * from [tempdb].dbo.sysobjects where name like '#Att_Muster_Leave' )		
				 begin
					drop table #Att_Muster_Leave
				 end
			
			Create Table #Att_Muster_Leave
			 (
				Cmp_ID numeric,
				Emp_ID numeric,
				From_Date Datetime,
				To_Date DateTime,
				Leave_Name Varchar(200),
				Leave_Period Numeric(10,2),
				Leave_Type Varchar(50),
				Leave_Type_Date Datetime,
				Leave_Reason Varchar(500),
				Approval_Status Varchar(100),
				Cancel_Date Varchar(1000)
			 )									
		End

	IF @Leave_Status = 'S' or 	@Leave_Status =''
		set @Leave_Status = null
		

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

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
			Where Cmp_ID = @Cmp_ID 
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
		
		if @Format = 'Leave with Absent Days'
			BEGIN
				exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,'ABSENT','5',0,0,0,'','','','',1
				
				Insert INTO #Att_Muster_Leave(Cmp_ID,Emp_ID,From_Date,To_Date,Leave_Name,Leave_Period,Leave_Type,Leave_Type_Date,Leave_Reason,Approval_Status,Cancel_Date)
				  Select la.Cmp_ID,la.Emp_ID,
				  Lad.From_Date,Lad.To_Date,
				  LM.Leave_Name,
				  lad.Leave_Period,
				  case when lad.Leave_Assign_As='First Half' then 'First Half'
				  when lad.Leave_Assign_As='Second Half' then 'Second Half'
				  when lad.Leave_Period=0.5 Then lad.Leave_Assign_As end as Leave_Type,
				  case when lad.Leave_Assign_As='First Half' Then lad.Half_Leave_Date
				  when lad.Leave_Assign_As='Second Half' then lad.Half_Leave_Date 
				  when lad.Leave_Period=0.5 Then lad.From_Date end as Leave_Type_Date,
			      isnull(Lad.Leave_Reason,'') Leave_Reason,
			      la.Approval_Status 	                      
			       ,(SELECT (STUFF(( SELECT '; ' +  Convert(Varchar(11),For_date,103) + '-' + Convert(varchar(20),Leave_period) FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)	--Ankit 05042016
								WHERE LC.Leave_Approval_ID = la.Leave_Approval_ID FOR XML PATH('')  ), 1, 2, ''))) AS Cancel_Date
				 from T0120_Leave_Approval la WITH (NOLOCK)
				 inner join @Emp_cons ec on la.emp_ID = ec.emp_ID 
				 Inner join  T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
				 inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
				 left outer join T0110_Leave_Application_Detail LAPD WITH (NOLOCK) on LAPD.Leave_Application_ID=la.Leave_Application_ID -- added by Hafeef on 15032012 for leave reason
				 left outer join T0100_LEAVE_APPLICATION lpp WITH (NOLOCK) on LAPD.Leave_Application_ID = lpp.Leave_Application_ID -- Added By Ali 28042014 
				 where  la.cmp_ID=@Cmp_ID  and Approval_Status=isnull(@Leave_Status,Approval_Status)
					and  ((lad.From_Date >=@From_Date and lad.From_Date <= @To_Date)
									OR
								  (lad.To_Date >= @From_Date and lad.To_Date <= @To_Date)
						 )
					--and lad.From_Date >=@From_Date and lad.to_Date <=@To_Date 	 
				
				Update AM
					SET AM.Leave_Type = (CASE WHEN AL.Leave_Type ='First Half' then 'Second Half' WHEN AL.Leave_Type ='Second Half' then 'First Half' END)
				From #Att_Muster_Absent AM Inner join #Att_Muster_Leave AL
				ON AM.Emp_ID = AL.Emp_ID and AM.For_Date = AL.Leave_Type_Date 
				where AM.A_days <> 0 and AM.A_days < 1
				
				Insert INTO #Att_Muster_Leave(Cmp_ID,Emp_ID,From_Date,To_Date,Leave_Name,Leave_Period,Leave_Type,Leave_Type_Date,Leave_Reason,Approval_Status,Cancel_Date)
				Select Cmp_ID,Emp_Id,For_Date,For_Date,'LWP',A_days,Leave_Type,'','','A','' 
				From #Att_Muster_Absent 
				
				
				if @Format_Excel = 0
					Begin
						Select e.Alpha_Emp_Code,e.Emp_Full_name,AM.Leave_Name,AM.From_Date,AM.To_Date,AM.Leave_Period,AM.Leave_Type,
						 AM.Leave_Type_Date,AM.Leave_Reason,
						 AM.Approval_Status,AM.Cancel_Date,
						 e.Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name
						,Dept_Name,Desig_Name,type_Name,Cmp_Name,Cmp_Address ,comp_name,Branch_address
						,vs.Vertical_Name,Sv.SubVertical_Name 
						From #Att_Muster_Leave AM
						inner join T0080_Emp_Master e WITH (NOLOCK) on AM.emp_ID= e.emp_ID 
						inner join T0010_Company_Master CM WITH (NOLOCK) on AM.CMP_ID= CM.CMP_ID
						inner join
							( 
								select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,I.Vertical_ID,I.SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join 
									( 
										select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date
										and Cmp_ID = @Cmp_ID
										group by emp_ID  
									) 
								Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
							) I_Q on E.Emp_ID = I_Q.Emp_ID  
						inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
						LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
						LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
						LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
						Inner join T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
						LEFT outer JOIN T0040_Vertical_Segment vs WITH (NOLOCK) on  I_Q.Vertical_ID = vs.Vertical_ID 
						LEFT outer JOIN T0050_SubVertical Sv WITH (NOLOCK) On I_Q.SubVertical_ID = sv.SubVertical_ID 
						order by AM.Emp_ID,AM.From_Date
					
					End
				Else
					BEGIN
						Select 
						e.Alpha_Emp_Code as "Emp Code",
						e.Emp_Full_name as "Emp Full Name",
						Branch_Name as "Branch",
						Dept_Name as "Department",
						Desig_Name as "Desination",
						AM.Leave_Name as "Leave Name",
						'="' + CONVERT(varchar(11),AM.From_Date,103) + '"' as "From Date",
						'="' + CONVERT(varchar(11),AM.To_Date,103) + '"' as "To Date",
						AM.Leave_Period as "Leave Period",
						AM.Leave_Type as "Leave Type",
						(Case When Leave_Type_Date <> '1900-01-01 00:00:00.000' Then '="' + CONVERT(varchar(11),AM.Leave_Type_Date,103) + '"' ELSE '' END) as "Half Day Date",
						--AM.Leave_Type_Date,
						AM.Leave_Reason as "Leave Reason",
						(Case When AM.Approval_Status = 'A' THEN 'Approved' ELSE '' END) as "Status",
						AM.Cancel_Date as "Cancel Date"--,
						-- e.Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name
						--,Dept_Name,Desig_Name,type_Name,Cmp_Name,Cmp_Address ,comp_name,Branch_address
						--,vs.Vertical_Name,Sv.SubVertical_Name 
						From #Att_Muster_Leave AM
						inner join T0080_Emp_Master e WITH (NOLOCK) on AM.emp_ID= e.emp_ID 
						inner join T0010_Company_Master CM WITH (NOLOCK) on AM.CMP_ID= CM.CMP_ID
						inner join
							( 
								select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,I.Vertical_ID,I.SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join 
									( 
										select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date
										and Cmp_ID = @Cmp_ID
										group by emp_ID  
									) 
								Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
							) I_Q on E.Emp_ID = I_Q.Emp_ID  
						inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
						LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
						LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
						LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
						Inner join T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
						LEFT outer JOIN T0040_Vertical_Segment vs WITH (NOLOCK) on  I_Q.Vertical_ID = vs.Vertical_ID 
						LEFT outer JOIN T0050_SubVertical Sv WITH (NOLOCK) On I_Q.SubVertical_ID = sv.SubVertical_ID 
						order by AM.Emp_ID,AM.From_Date
					End
				Return
			End
		Else
		--Ronakb010824 add vertical for groupby
			Begin
				if @Format_Excel = 0
					Begin
						Select la.*,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name,
							 Lad.From_Date,Lad.To_Date,lad.Leave_Assign_As,
								 case when lad.Leave_Assign_As='First Half' then 'First Half'
								 when lad.Leave_Assign_As='Second Half' then 'Second Half'
								 when lad.Leave_Period=0.5 Then lad.Leave_Assign_As 
								 end as Leave_Type,
								 
								 case when lad.Leave_Assign_As='First Half' Then lad.Half_Leave_Date
								 when lad.Leave_Assign_As='Second Half' then lad.Half_Leave_Date 
								  when lad.Leave_Period=0.5 Then lad.From_Date end as Leave_Type_Date
								  
								,Dept_Name,Desig_Name,type_Name,Leave_Name,
								lad.Leave_Period,
								Cmp_Name,Cmp_Address ,comp_name,Branch_address,
								--Case When isnull(lpp.Application_Comments,'') <> '' Then isnull(lpp.Application_Comments,'') Else isnull(Lad.Leave_Reason,'') End As Leave_Reason -- Condition changed by Hardik 20/06/2018 for Aculife, to get application reason
								isnull(Lad.Leave_Reason,'') Leave_Reason,@From_Date as From_Date,@To_Date as To_Date, 
								BM.Branch_ID,Lad.Leave_ID --Lad.Leave_ID Added by Ripal 17jan2014, changed Lapd.Leave_reason to Lad.Leave_Reason by jimit 15062015
								,CASE WHEN ISNULL(lpp.is_backdated_application,0) = 0 THEN 'Regular' ELSE 'Back Dated' END as 'Type' -- Added By Ali 28042014 	                      
								,( SELECT (STUFF(( SELECT '; ' +  Convert(Varchar(11),For_date,103) + '-' + Convert(varchar(20),Leave_period) FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)	--Ankit 05042016
													WHERE LC.Leave_Approval_ID = la.Leave_Approval_ID FOR XML PATH('')  ), 1, 2, ''))) AS Cancel_Date
								,vs.Vertical_Name,Sv.SubVertical_Name  --added jimit 29042016
								,SB.SubBranch_Name --Ronakb
								,LPP.Application_Date	--added by Krushna 11-12-2018
								,isnull(E1.Emp_Full_name,'Admin') as Leave_Approver		--added by Krushna 11-12-2018
								,Lad.Leave_out_time as Hours_leave_from		--added by Krushna 21-01-2019
								,Lad.Leave_In_Time as Hours_leave_to		--added by Krushna 21-01-2019
							 from T0120_Leave_Approval la WITH (NOLOCK)
							 inner join @Emp_cons ec on la.emp_ID = ec.emp_ID 
							 Inner join  T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
							 inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID
							 LEFT join T0080_Emp_Master E1 WITH (NOLOCK) on la.S_Emp_ID = E1.Emp_ID	--added by Krushna 11-12-2018 
							 inner join T0010_Company_Master CM WITH (NOLOCK) on la.CMP_ID= CM.CMP_ID
							 inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
							 left outer join T0110_Leave_Application_Detail LAPD WITH (NOLOCK) on LAPD.Leave_Application_ID=la.Leave_Application_ID -- added by Hafeef on 15032012 for leave reason
							 left outer join T0100_LEAVE_APPLICATION lpp WITH (NOLOCK) on LAPD.Leave_Application_ID = lpp.Leave_Application_ID -- Added By Ali 28042014 
							 inner join
										( 
											select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,I.Vertical_ID,I.SubVertical_ID,SubBranch_ID from T0095_Increment I WITH (NOLOCK) inner join 
												( 
													select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
													where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
													group by emp_ID  
												) Qry on
												I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
										) I_Q on E.Emp_ID = I_Q.Emp_ID  
							inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
							LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
							LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
							LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
							Inner join T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
							LEFT outer JOIN T0040_Vertical_Segment vs WITH (NOLOCK) on  I_Q.Vertical_ID = vs.Vertical_ID 
							LEFT outer JOIN T0050_SubVertical Sv WITH (NOLOCK) On I_Q.SubVertical_ID = sv.SubVertical_ID 
							LEFT outer JOIN T0050_SubBranch SB  WITH (NOLOCK) ON I_Q.SubBranch_ID = SB.SubBranch_ID
							where  la.cmp_ID=@Cmp_ID  and Approval_Status=isnull(@Leave_Status,Approval_Status)
							and  ((lad.From_Date >=@From_Date and lad.From_Date <= @To_Date)
									OR
								  (lad.To_Date >= @From_Date and lad.To_Date <= @To_Date)
								 )
								--and lad.From_Date >=@From_Date and lad.to_Date <=@To_Date 
								 --and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC where  LC.cmp_id=@Cmp_ID and LC.For_Date >= @From_Date and LC.For_Date <= @To_Date  and LC.Is_Approve=1)	--Comment By Ankit 05042016
							Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
								When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
									Else e.Alpha_Emp_Code
								End
					END
				ELSE
					BEGIN
					
						Select E.Alpha_Emp_Code as "Emp Code",
						E.Emp_Full_name as "Emp Full Name",
						ISNULL(Qry_Reporting.Alpha_Emp_Code, '') AS "Reporting Manager Code",
						ISNULL(Qry_Reporting.Emp_Full_Name, '') AS "Reporting Manager Name",
						BM.Branch_Name as "Branch",
						DM.Dept_Name as "Department",
						DGM.Desig_Name as "Designation",
						VS.Vertical_Name as "Vertical",
						SV.SubVertical_Name as "SubVertical",
						BS.Segment_Name as "Business Segment",
						LM.leave_Name as "Leave Name",
						CONVERT(varchar(11),lad.From_Date,103) as "From Date",
						CONVERT(varchar(11),lad.To_Date,103) as "To Date",
						lad.Leave_Period as "Leave Period", lad.Leave_Assign_As as "Leave Assign As",
						(Case When LAD.Half_Leave_Date <> '1900-01-01 00:00:00.000' Then '="' + CONVERT(varchar(11),LAD.Half_Leave_Date,103) + '"' ELSE '' END) as "Half Day Date",
						lad.Leave_Reason as "Leave Reason" , 
						CASE 
							WHEN LA.Approval_Status = 'A' THEN 'Approved'
							WHEN LA.Approval_Status = 'R' THEN 'Rejected'
							WHEN LA.Approval_Status = 'P' THEN 'Pending'
						END as "Approval Status" ,
						CASE 
							WHEN ISNULL(lpp.is_backdated_application,0) = 0 THEN 'Regular' 
							ELSE 'Back Dated' 
						END as "Leave Type",
						(
							SELECT (STUFF((	SELECT '; ' +  Convert(Varchar(11),For_date,103) + '-' + Convert(varchar(20),Leave_period) 
											FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)
											WHERE LC.Leave_Approval_ID = la.Leave_Approval_ID FOR XML PATH('')), 1, 2, ''))
						) AS Cancel_Date
						FROM T0120_Leave_Approval la WITH (NOLOCK)
							 inner join @Emp_cons ec on la.emp_ID = ec.emp_ID 
							 Inner join  T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
							 inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID 
							 inner join T0010_Company_Master CM WITH (NOLOCK) on la.CMP_ID= CM.CMP_ID
							 inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
							 left outer join T0110_Leave_Application_Detail LAPD WITH (NOLOCK) on LAPD.Leave_Application_ID=la.Leave_Application_ID
							 left outer join T0100_LEAVE_APPLICATION lpp WITH (NOLOCK) on LAPD.Leave_Application_ID = lpp.Leave_Application_ID
							 inner join
										( 
											select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,
											Increment_effective_Date,I.Vertical_ID,I.SubVertical_ID , I.Segment_ID
											from T0095_Increment I WITH (NOLOCK) inner join 
												( 
													select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
													where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
													group by emp_ID  
												) Qry on
												I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
										) I_Q on E.Emp_ID = I_Q.Emp_ID  
							inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
							LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
							LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
							LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
							Inner join T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
							LEFT outer JOIN T0040_Vertical_Segment vs WITH (NOLOCK) on  I_Q.Vertical_ID = vs.Vertical_ID 
							LEFT outer JOIN T0050_SubVertical Sv WITH (NOLOCK) On I_Q.SubVertical_ID = sv.SubVertical_ID 
							LEFT outer JOIN T0040_Business_Segment Bs WITH (NOLOCK) On I_Q.Segment_ID = bs.Segment_ID
							LEFT OUTER JOIN  (SELECT	R1.Emp_ID, R1.Effect_Date, R1.R_Emp_ID, Em.Emp_Full_Name , Em.Alpha_EMP_Code
								  FROM      dbo.T0090_EMP_REPORTING_DETAIL AS R1 WITH (NOLOCK)
											INNER JOIN (SELECT	MAX(R2.Row_ID) AS ROW_ID, R2.Emp_ID
                                                        FROM    dbo.T0090_EMP_REPORTING_DETAIL AS R2 WITH (NOLOCK)
																INNER JOIN (SELECT     MAX(Effect_Date) AS Effect_Date, Emp_ID
                                                                            FROM          dbo.T0090_EMP_REPORTING_DETAIL AS R3 WITH (NOLOCK)
                                                                            WHERE      (Effect_Date < GETDATE())
                       GROUP BY Emp_ID) AS R3_1 ON R2.Emp_ID = R3_1.Emp_ID AND R2.Effect_Date = R3_1.Effect_Date
                                                         GROUP BY R2.Emp_ID) AS R2_1 ON R1.Row_ID = R2_1.ROW_ID AND R1.Emp_ID = R2_1.Emp_ID 
											INNER JOIN dbo.T0080_EMP_MASTER AS Em WITH (NOLOCK) ON R1.R_Emp_ID = Em.Emp_ID
								) AS Qry_Reporting ON E.Emp_ID = Qry_Reporting.Emp_ID
						WHERE  la.cmp_ID=@Cmp_ID  and Approval_Status=isnull(@Leave_Status,Approval_Status)
							and  ((lad.From_Date >=@From_Date and lad.From_Date <= @To_Date)
									OR
								  (lad.To_Date >= @From_Date and lad.To_Date <= @To_Date)
								 )
								--and lad.From_Date >=@From_Date and lad.to_Date <=@To_Date 
							Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
								When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
									Else e.Alpha_Emp_Code
								End
					END
			END
         
         
    	RETURN 




