
CREATE PROCEDURE [dbo].[P_RPT_LEAVE_APPLICATION_DETAILS_GET]
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
	,@Leave_Status  varchar(20)
	,@Constraint	varchar(max)	
	,@Format_Excel Numeric(2,0) = 0
	,@Order_By		Varchar(32) = 'Code'
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
		
	
	
	IF @Leave_Status = 'S' or 	@Leave_Status =''
		set @Leave_Status = null
	
		CREATE TABLE #EMP_CONS 
			(      
				EMP_ID NUMERIC ,     
				BRANCH_ID NUMERIC ,
				INCREMENT_ID NUMERIC
			)
			
		EXEC SP_RPT_FILL_EMP_CONS 	@Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint		
									,0, 0 ,0 ,0 ,0 ,0 ,0 ,0,0,'0',0,0
		
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

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
	--		Where Cmp_ID = @Cmp_ID 
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
		
				--DECLARE @Branch_Cap as  Varchar(20)
				----DECLARE @Desig_Cap as  Varchar(20)
				--DECLARE @Vertical_Cap as  Varchar(20)
				
				
				--SELECT @Branch_Cap = Alias from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_Id and Caption = 'Branch'
				----SELECT @Desig_Cap = Alias from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_Id and Caption = 'Designation'
				--SELECT @Vertical_Cap = Alias from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_Id and Caption = 'Vertical'
				--print @Format_Excel--mansi
				if @Format_Excel = 0
					Begin
					
							Select	la.Leave_Approval_ID,la.Cmp_ID,la.Emp_ID,la.S_Emp_ID,la.Approval_Date,la.Approval_Status as Application_Status,la.Approval_Comments
									,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name,
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
									isnull(Lad.Leave_Reason,'') Leave_Reason ,@From_Date as From_Date1,@To_Date as To_Date1, 
									BM.Branch_ID,Lad.Leave_ID 
									,CASE WHEN ISNULL(lpp.is_backdated_application,0) = 0 THEN 'Regular' ELSE 'Back Dated' END as 'Type'
								
									,(SELECT (STUFF(( SELECT '; ' +  Convert(Varchar(11),For_date,103) + '-' + Convert(varchar(20),Leave_period) 
									FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)	
									WHERE LC.Leave_Approval_ID = la.Leave_Approval_ID and  Lc.Is_Approve = 1  FOR XML PATH('')  ), 1, 2, ''))) AS Cancel_Date
									
									,vs.Vertical_Name,Sv.SubVertical_Name  --added jimit 29042016
							 INTO	#TMP_LEAVE
							 from	 T0120_Leave_Approval la WITH (NOLOCK)
									 inner join #EMP_CONS ec on la.emp_ID = ec.emp_ID 
									 Inner join  T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
									 inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID 
									 inner join T0010_Company_Master CM WITH (NOLOCK) on la.CMP_ID= CM.CMP_ID
									 inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
									 left outer join T0110_Leave_Application_Detail LAPD WITH (NOLOCK) on LAPD.Leave_Application_ID=la.Leave_Application_ID -- added by Hafeef on 15032012 for leave reason
									 left outer join T0100_LEAVE_APPLICATION lpp WITH (NOLOCK) on LAPD.Leave_Application_ID = lpp.Leave_Application_ID -- Added By Ali 28042014 
									 inner join
												( 
													select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,I.Vertical_ID,I.SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join 
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
							where   la.cmp_ID=@Cmp_ID  and Approval_Status = --isnull(@Leave_Status,Approval_Status)
																			case WHEN @Leave_Status = 'Approve' then  'A' 
																				 WHEN @Leave_Status = 'Pending' then 'P'	--isnull(@Leave_Status,la.Application_Status)
																				 WHEN @Leave_Status = 'Reject' then 'R'
																				 ELSE Approval_Status
																			 END
								--and lad.From_Date >=@From_Date and lad.to_Date <=@To_Date 
									and ((@FROM_DATE BETWEEN LAD.from_date and LAD.To_Date) OR
										 (@To_date BETWEEN LAD.from_date and LAD.To_Date) OR
										 (LAD.from_date BETWEEN @FROM_DATE and @To_date) OR 
										 (LAD.To_Date BETWEEN @FROM_DATE and @To_date))
							
								If @Leave_status = 'Pending' or  @Leave_status = 'All'
									BEGIN
										
											INSERT  INTO	#TMP_LEAVE
											Select	la.Leave_Application_ID,la.Cmp_ID,la.Emp_ID,la.S_Emp_ID,la.Application_Date,la.Application_Status,la.Application_Comments
													,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name,
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
													isnull(Lad.Leave_Reason,'') Leave_Reason ,@From_Date as From_Date1,@To_Date as To_Date1, 
													BM.Branch_ID,Lad.Leave_ID 
													,CASE WHEN ISNULL(lpp.is_backdated_application,0) = 0 THEN 'Regular' ELSE 'Back Dated' END as 'Type' 
													,( SELECT (STUFF(( SELECT '; ' +  Convert(Varchar(11),For_date,103) + '-' + Convert(varchar(20),Leave_period)
													FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)	
													--added by mansi start 
													 inner join #EMP_CONS ec on ec.EMP_ID=lc.Emp_Id
													--added by mansi end
											WHERE	LC.Leave_Approval_ID = la.Leave_Application_ID and  Lc.Is_Approve = 1  FOR XML PATH('')  ), 1, 2, ''))) AS Cancel_Date
													,vs.Vertical_Name,Sv.SubVertical_Name  --added jimit 29042016
											
											
											from	T0100_LEAVE_APPLICATION la WITH (NOLOCK)
													inner join #EMP_CONS ec on la.emp_ID = ec.emp_ID 
													Inner join  T0110_LEAVE_APPLICATION_DETAIL Lad WITH (NOLOCK) on la.Leave_Application_ID = lad.Leave_Application_ID 
													inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID 
													inner join T0010_Company_Master CM WITH (NOLOCK) on la.CMP_ID= CM.CMP_ID
													inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
													left outer join T0110_Leave_Application_Detail LAPD WITH (NOLOCK) on LAPD.Leave_Application_ID=la.Leave_Application_ID -- added by Hafeef on 15032012 for leave reason
													left outer join T0100_LEAVE_APPLICATION lpp WITH (NOLOCK) on LAPD.Leave_Application_ID = lpp.Leave_Application_ID -- Added By Ali 28042014 
													inner join
														( 
															select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,I.Vertical_ID,I.SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join 
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
											where	la.cmp_ID=@Cmp_ID  and la.Application_Status = 'P'
													and ((@FROM_DATE BETWEEN LAD.from_date and LAD.To_Date) OR
														 (@To_date BETWEEN LAD.from_date and LAD.To_Date) OR
														 (LAD.from_date BETWEEN @FROM_DATE and @To_date) OR 
														 (LAD.To_Date BETWEEN @FROM_DATE and @To_date))
										END
						
							
					 							
							SELECT *
								 FROM	#TMP_LEAVE
								 order by CASE WHEN @Order_By = 'Code' THEN
																			(CASE	WHEN ISNUMERIC(Alpha_Emp_Code) = 1 
																		THEN RIGHT(REPLICATE('0',21) + Alpha_Emp_Code, 20)										
																	ELSE 
																		Alpha_Emp_Code
																		END)
												When @Order_By = 'EmployeeName'	then
																	Emp_Full_name
															
											END
											
								
						
					End
				Else
					BEGIN	
							
							
							
										Select DISTINCT E.Alpha_Emp_Code,
										E.Emp_Full_name,
										--ISNULL(Qry_Reporting.Alpha_Emp_Code, '') AS "Reporting_Manager_Code",
										--ISNULL(Qry_Reporting.Emp_Full_Name, '') AS "Reporting_Manager_Name",
										BM.Branch_Name as "Branch",
										DM.Dept_Name as "Department",
										DGM.Desig_Name as "Designation",
										VS.Vertical_Name as "Vertical",
										SV.SubVertical_Name as "SubVertical",
										BS.Segment_Name as "Business_Segment",
										LM.leave_Name as "Leave_Name",
										CONVERT(varchar(11),lad.From_Date,103) as From_Date,
										CONVERT(varchar(11),lad.To_Date,103) as "To_Date",
										lad.Leave_Period as "Leave_Period",lad.Leave_Assign_As,

										--case when lad.Leave_Assign_As='First Half' then 'First Half'
										--				 when lad.Leave_Assign_As='Second Half' then 'Second Half'
										--				 when lad.Leave_Period=0.5 Then lad.Leave_Assign_As 
										--			end as "Leave_Assign_As",	
													
										--(Case When LAD.Half_Leave_Date <> '1900-01-01 00:00:00.000' Then '="' + CONVERT(varchar(11),LAD.Half_Leave_Date,103) + '"' ELSE '' END) as "Half_Day_Date",
										case when lad.Leave_Assign_As='First Half' Then lad.Half_Leave_Date
														 when lad.Leave_Assign_As='Second Half' then lad.Half_Leave_Date 
														 when lad.Leave_Period=0.5 Then lad.From_Date end as Half_Day_Date,
										lad.Leave_Reason as "Leave_Reason" , 
										CASE 
											WHEN LA.Approval_Status = 'A' THEN 'Approved'
											WHEN LA.Approval_Status = 'R' THEN 'Rejected'
											WHEN LA.Approval_Status = 'P' THEN 'Pending'
										END as "Approval_Status" ,
										CASE 
											WHEN ISNULL(lpp.is_backdated_application,0) = 0 THEN 'Regular' 
											ELSE 'Back Dated' 
										END as "Leave_Type",
										(
											SELECT (STUFF((	SELECT '; ' +  Convert(Varchar(11),For_date,103) + '-' + Convert(varchar(20),Leave_period) 
															FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)
															WHERE LC.Leave_Approval_ID = la.Leave_Approval_ID and  Lc.Is_Approve = 1 FOR XML PATH('')), 1, 2, ''))
										) AS Cancel_Date 
							INTO #TMP_LEAVE1
							FROM T0120_Leave_Approval la WITH (NOLOCK)
								 inner join #EMP_CONS ec on la.emp_ID = ec.emp_ID 
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
								LEFT OUTER JOIN  
								(	SELECT	R1.Emp_ID, Em.Emp_Full_Name , Em.Alpha_EMP_Code
									FROM      dbo.T0090_EMP_REPORTING_DETAIL AS R1 WITH (NOLOCK)
									INNER JOIN (
													SELECT	MAX(R2.Row_ID) AS ROW_ID, R2.Emp_ID
													FROM    dbo.T0090_EMP_REPORTING_DETAIL AS R2 WITH (NOLOCK)
														INNER JOIN (
																		SELECT     MAX(Effect_Date) AS Effect_Date, Emp_ID
																		FROM          dbo.T0090_EMP_REPORTING_DETAIL AS R3 WITH (NOLOCK)
																		WHERE      Effect_Date < GETDATE()
																		GROUP BY Emp_ID
																	) AS R3_1 ON R2.Emp_ID = R3_1.Emp_ID AND R2.Effect_Date = R3_1.Effect_Date
													GROUP BY R2.Emp_ID
												) AS R2_1 ON R1.Row_ID = R2_1.ROW_ID AND R1.Emp_ID = R2_1.Emp_ID 
									INNER JOIN dbo.T0080_EMP_MASTER AS Em ON R1.R_Emp_ID = Em.Emp_ID
									) AS Qry_Reporting ON E.Emp_ID = Qry_Reporting.Emp_ID
								where  la.cmp_ID=@Cmp_ID  and Approval_Status = --isnull(@Leave_Status,Approval_Status)
																			case WHEN @Leave_Status = 'Approve' then  'A' 
																				 WHEN @Leave_Status = 'Pending' then 'P'	--isnull(@Leave_Status,la.Application_Status)
																				 WHEN @Leave_Status = 'Reject' then 'R'
																				 ELSE Approval_Status
																			 END
									--and lad.From_Date >=@From_Date and lad.to_Date <=@To_Date 
									and ((@FROM_DATE BETWEEN LAD.from_date and LAD.To_Date) OR 
											(@To_date BETWEEN LAD.from_date and LAD.To_Date) OR
											(LAD.from_date BETWEEN @FROM_DATE and @To_date) OR
											 (LAD.To_Date BETWEEN @FROM_DATE and @To_date))
							
							
							
							If @Leave_status = 'Pending' or  @Leave_status = 'All'
									BEGIN
											INSERT INTO #TMP_LEAVE1
											Select DISTINCT E.Alpha_Emp_Code,
											E.Emp_Full_name,
											--ISNULL(Qry_Reporting.Alpha_Emp_Code, '') AS "Reporting_Manager_Code",
											--ISNULL(Qry_Reporting.Emp_Full_Name, '') AS "Reporting_Manager_Name",
											BM.Branch_Name as "Branch",
											DM.Dept_Name as "Department",
											DGM.Desig_Name as "Designation",
											VS.Vertical_Name as "Vertical",
											SV.SubVertical_Name as "SubVertical",
											BS.Segment_Name as "Business_Segment",
											LM.leave_Name as "Leave_Name",
											CONVERT(varchar(11),lad.From_Date,103) as From_Date,
											CONVERT(varchar(11),lad.To_Date,103) as "To_Date",
											lad.Leave_Period as "Leave_Period",lad.Leave_Assign_As,

											--case when lad.Leave_Assign_As='First Half' then 'First Half'
											--			 when lad.Leave_Assign_As='Second Half' then 'Second Half'
											--			 when lad.Leave_Period=0.5 Then lad.Leave_Assign_As 
											--		end as "Leave_Assign_As",
										
											--case when lad.Leave_Assign_As='First Half' then 'First Half'
											--			 when lad.Leave_Assign_As='Second Half' then 'Second Half'
											--			 when lad.Leave_Period=0.5 Then lad.Leave_Assign_As ELSE '' END as Leave_Assign_As,

											-- lad.Leave_Assign_As as "Leave_Assign_As",
											--(Case When LAD.Half_Leave_Date <> '1900-01-01 00:00:00.000' Then '="' + CONVERT(varchar(11),LAD.Half_Leave_Date,103) + '"' ELSE '' END) as "Half_Day_Date",
											
											case when lad.Leave_Assign_As='First Half' Then lad.Half_Leave_Date
														 when lad.Leave_Assign_As='Second Half' then lad.Half_Leave_Date 
														 when lad.Leave_Period=0.5 Then lad.From_Date end as Half_Day_Date,
											lad.Leave_Reason as "Leave_Reason" , 
											CASE 
												WHEN LA.Application_Status = 'A' THEN 'Approved'
												WHEN LA.Application_Status = 'R' THEN 'Rejected'
												WHEN LA.Application_Status = 'P' THEN 'Pending'
											END as "Approval_Status" ,
											CASE 
												WHEN ISNULL(lpp.is_backdated_application,0) = 0 THEN 'Regular' 
												ELSE 'Back Dated' 
											END as "Leave_Type",
											(
												SELECT (STUFF((	SELECT '; ' +  Convert(Varchar(11),For_date,103) + '-' + Convert(varchar(20),Leave_period) 
																FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)

																WHERE LC.Leave_Approval_ID = la.Leave_Application_ID and Lc.Is_Approve = 1 FOR XML PATH('')), 1, 2, ''))
											) AS Cancel_Date 
											
											
											
											FROM T0100_LEAVE_APPLICATION la WITH (NOLOCK)
												 inner join #EMP_CONS ec on la.emp_ID = ec.emp_ID 
												 Inner join  T0110_LEAVE_APPLICATION_DETAIL Lad WITH (NOLOCK) on la.Leave_Application_ID = lad.Leave_Application_ID 
												 inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID 
												 inner join T0010_Company_Master CM WITH (NOLOCK) on la.CMP_ID= CM.CMP_ID
												 inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
												 left outer join T0110_Leave_Application_Detail LAPD WITH (NOLOCK) on LAPD.Leave_Application_ID=la.Leave_Application_ID
												left outer join T0100_LEAVE_APPLICATION lpp WITH (NOLOCK) on LA.Leave_Application_ID = lpp.Leave_Application_ID
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
												LEFT OUTER JOIN  
													(	
														SELECT	R1.Emp_ID, Em.Emp_Full_Name , Em.Alpha_EMP_Code
														FROM      dbo.T0090_EMP_REPORTING_DETAIL AS R1 WITH (NOLOCK) INNER JOIN 
																(
																	SELECT	MAX(R2.Row_ID) AS ROW_ID, R2.Emp_ID
																	FROM    dbo.T0090_EMP_REPORTING_DETAIL AS R2 WITH (NOLOCK)
																		INNER JOIN (
																						SELECT     MAX(Effect_Date) AS Effect_Date, Emp_ID
																						FROM          dbo.T0090_EMP_REPORTING_DETAIL AS R3 WITH (NOLOCK)
																						WHERE      Effect_Date < GETDATE()
																						GROUP BY Emp_ID
																					) AS R3_1 ON R2.Emp_ID = R3_1.Emp_ID AND R2.Effect_Date = R3_1.Effect_Date
																	GROUP BY R2.Emp_ID
																) AS R2_1 ON R1.Row_ID = R2_1.ROW_ID AND R1.Emp_ID = R2_1.Emp_ID 
													INNER JOIN dbo.T0080_EMP_MASTER AS Em ON R1.R_Emp_ID = Em.Emp_ID
													) AS Qry_Reporting ON E.Emp_ID = Qry_Reporting.Emp_ID
												
												where  la.cmp_ID = @Cmp_ID  and la.Application_Status = 'P'
														and ((@FROM_DATE BETWEEN LAD.from_date and LAD.To_Date) OR
															(@To_date BETWEEN LAD.from_date and LAD.To_Date) OR
															(LAD.from_date BETWEEN @FROM_DATE and @To_date) OR 
															(LAD.To_Date BETWEEN @FROM_DATE and @To_date))
									END	
							
							 
								
								 SELECT  Alpha_Emp_Code as "Employee Code",
								 Emp_Full_name as "Emp Full Name",
								 --Reporting_Manager_Code as "Reporting Manager Code",
								-- Reporting_Manager_Name as "Reporting Manager Name",
											Branch ,
											Department,Designation,Vertical,SubVertical,Business_Segment as "Business Segment",Leave_Name as "Leave Name",
											From_Date as "From Date",To_Date as "To Date",Leave_Period as "Leave Period", Leave_Assign_As as "Leave Assign As",Half_Day_Date as "Half Day Date",
											Leave_Reason as "Leave Reason",Approval_Status as "Approval Status",Leave_Type as "Leave Type",Cancel_Date as "Cancel Date"
								 FROM	#TMP_LEAVE1
								 order by CASE WHEN @Order_By = 'Code' THEN
																			(CASE	WHEN ISNUMERIC(Alpha_Emp_Code) = 1 
																		THEN RIGHT(REPLICATE('0',21) + Alpha_Emp_Code, 20)										
																	ELSE 
																		Alpha_Emp_Code
																		END)
												When @Order_By = 'EmployeeName'	then
																	Emp_Full_name
															
											END
								
								
									
					END
			
         
         
    	RETURN 




