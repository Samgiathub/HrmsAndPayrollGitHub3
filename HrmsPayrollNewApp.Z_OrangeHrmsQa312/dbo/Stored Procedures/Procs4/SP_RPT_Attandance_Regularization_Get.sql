---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_Attandance_Regularization_Get]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(max)
	,@Status numeric = 4
	,@PBranch_ID varchar ='0'
	,@Format_Type tinyint = 0 --Added by Sumit for getting Excel format 18102016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Begin

	
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
		
	declare @Check_By_Sup numeric 
	set @Check_By_Sup = 0
	
	IF @Status = 0
		set @Check_By_Sup=0
	ELSE IF @Status=1
		set @check_By_Sup=0
	ELSE IF @Status=2
		set @check_By_Sup=1
	ELSE IF @Status=3
		set @check_By_Sup=2
	END 
	

	CREATE TABLE #Emp_Cons 	-- Ankit 08092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 	


	---- Added by rajput on 21062019
	--IF (@Status = 4)
	--	BEGIN		
			
	--		exec	SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,
	--				@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,
	--				@Emp_ID=@Emp_ID,@Constraint=@constraint,@Report_For='Att Reg Report'
			
			
	--		RETURN
	--	END

	--Declare #Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons(Emp_ID)
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
	--		Insert Into #Emp_Cons(Emp_ID)

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		AND I.Emp_ID in (select emp_Id from
	--				(select emp_id, Cmp_ID, join_Date, isnull(left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--				where Cmp_ID = @Cmp_ID   and  
	--				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--				or ( @From_Date <= join_Date  and @To_Date >= left_date )	
	--				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--				or left_date is null and  @To_Date >= Join_Date)) 
	--	end
	-- Deepal 17-04-24 #28344 Help Ronak
						Select E1.* 
						INTO #TMP 
						from T0090_EMP_REPORTING_DETAIL E1  WITH (NOLOCK) 
						inner join (
											select MAX(Effect_Date) as Effect_date, D.EMP_ID 
											from T0090_EMP_REPORTING_DETAIL D WITH (NOLOCK)
											Inner join #Emp_Cons E on E.Emp_ID = D.Emp_ID  
											where Effect_Date<= @To_Date GROUP BY D.Emp_ID 
						) E3 on E1.Emp_ID = E3.Emp_ID and  E1.Effect_Date = E3.Effect_date

		if @Status =0
		begin
			if(@Format_Type =4) --Added by Sumit for proper Excel format for Attendance regularization on 21102016
						Begin
							select Alpha_Emp_Code as [Employee Code],Emp_Name as [Employee Name],BM.Branch_Name as [Branch Name]
							,GM.Grd_name as [Grade Name],DM.Dept_name as [Department Name],DGM.desig_name as [Designation Name],TM.type_name as [Employee Type]
							,convert(varchar(12),VLM.App_Date,103) as [Application Date],convert(varchar(12),VLM.For_Date,103) as [For Date]
							,substring(CONVERT(VARCHAR, VLM.In_Time, 108),0,6) AS [In Time]
							,substring(CONVERT(VARCHAR, VLM.Out_Time, 108),0,6) AS [Out Time]					
							,VLM.Half_Full_day AS [Half Full Day]
							,case when VLM.Other_Reason is null then VLM.Reason Else (VLM.Reason + ' -- ' + VLM.Other_Reason) End as Reason,
							VLM.Sup_Comment as [Superior Comment]
							,case when VLM.Chk_By_Superior=0 then 'Pending' 
								  when VLM.Chk_By_Superior=2 then 'Reject'
							 Else 'Approve' End as Status	  
							from View_Late_Emp VLM
							inner join #Emp_Cons as ES on VLM.Emp_ID = ES.Emp_ID
							inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on VLM.Branch_ID =BM.Branch_ID
							inner Join T0010_COMPANY_MASTER CM WITH (NOLOCK) on VLM.Cmp_ID=CM.Cmp_Id						
							INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON VLM.Grd_Id = gm.Grd_ID left outer join
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON VLM.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON VLM.DESIG_ID = DGM.DESIG_ID left join 
							t0040_type_master TM WITH (NOLOCK) on VLM.type_id = Tm.type_id
							 
							where VLM.Cmp_id = @Cmp_ID and (For_Date)>= @From_Date and For_Date <= @To_Date
							order by RIGHT(REPLICATE(N' ', 500) + VLM.ALPHA_EMP_CODE, 500)
						End
			Else
				Begin			
						
						
						SELECT VLM.IO_Tran_Id, VLM.Emp_ID, VLM.For_Date, VLM.In_Time, VLM.Reason, VLM.Cmp_ID, VLM.Branch_ID, VLM.subBranch_ID, VLM.Branch_Name
						, VLM.Grd_ID, VLM.Dept_ID, VLM.Desig_Id, VLM.Type_ID, VLM.Emp_code, VLM.Emp_Full_Name, VLM.Alpha_Emp_Code
						, VLM.Alpha_Code, VLM.Emp_Superior, VLM.Chk_By_Superior
						, VLM.Half_Full_day, VLM.Sup_Comment, VLM.Emp_Name, VLM.Is_Cancel_Late_In
						, VLM.Is_Cancel_Early_Out, VLM.Out_Time
						, Case when VLM.Chk_By_Superior = 0 then VLM.Superior else (E.ALPHA_EMP_CODE + ' - ' + E.EMP_FULL_NAME) END as Superior
						, Case when VLM.Chk_By_Superior = 0 then VLM.Superior_Code else E.Alpha_Emp_Code END as Superior_Code
						, VLM.App_Date
						, VLM.Other_Reason, VLM.Vertical_ID, VLM.SubVertical_ID, VLM.Actual_In_Time, VLM.Actual_Out_Time, VLM.Shift_End_Time, VLM.Shift_St_Time
						, BM.Branch_Name,Cm.Cmp_Name ,cm.cmp_address,@From_Date as P_From_Date,@To_Date as P_To_Date
						, GM.Grd_name,BM.branch_name,DM.Dept_name,DGM.desig_name,TM.type_name,DGM.Desig_Dis_No ,vs.Vertical_Name,sv.SubVertical_Name 
						from View_Late_Emp VLM
						inner join #Emp_Cons as ES on VLM.Emp_ID = ES.Emp_ID
						inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on VLM.Branch_ID =BM.Branch_ID
						inner Join T0010_COMPANY_MASTER CM WITH (NOLOCK) on VLM.Cmp_ID=CM.Cmp_Id							
						INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON VLM.Grd_Id = gm.Grd_ID
						left outer join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON VLM.DEPT_ID = DM.DEPT_ID 
						LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON VLM.DESIG_ID = DGM.DESIG_ID 
						left join t0040_type_master TM WITH (NOLOCK) on VLM.type_id = Tm.type_id 
						LEFT outer JOIN T0040_Vertical_Segment vs WITH (NOLOCK) On VLM.Vertical_ID = vs.Vertical_ID  
						LEFT Outer JOIN T0050_SubVertical sv WITH (NOLOCK) On vlm.SubVertical_ID = sv.SubVertical_ID
						inner join #TMP t on T.emp_id = ES.Emp_ID
						inner join T0080_EMP_MASTER E on E.Emp_ID = t.R_Emp_ID
						where VLM.Cmp_id = @Cmp_ID and (For_Date)>= @From_Date and For_Date <= @To_Date
						order by RIGHT(REPLICATE(N' ', 500) + VLM.ALPHA_EMP_CODE, 500)

						-- Deepal 17-04-24 #28344 Help Ronak
				
				End		
		end
		else  
		begin
		
			if(@Format_Type =4) --Added by Sumit for proper Excel format for Attendance regularization on 21102016
				Begin
					
					select Alpha_Emp_Code as [Employee Code],Emp_Name as [Employee Name],BM.Branch_Name as [Branch Name]
					,GM.Grd_name as [Grade Name],DM.Dept_name as [Department Name],DGM.desig_name as [Designation Name],TM.type_name as [Employee Type]
					,convert(varchar(12),VLM.App_Date,103) as [Application Date],convert(varchar(12),VLM.For_Date,103) as [For Date],
					--,VLM.In_Time as [In Time]
					--,VLM.Out_Time as [Out Time]					
					 substring(CONVERT(VARCHAR, VLM.In_Time, 108),0,6) AS [In Time],
					 substring(CONVERT(VARCHAR, VLM.Out_Time, 108),0,6) AS [Out Time]
					,VLM.Half_Full_day AS [Half Full Day]
					,case when VLM.Other_Reason is null then VLM.Reason Else (VLM.Reason + ' -- ' + VLM.Other_Reason) End as Reason,
					VLM.Sup_Comment as [Superior Comment]
					,case when VLM.Chk_By_Superior = 0 then 'Pending' 
						  when VLM.Chk_By_Superior = 2 then 'Reject'
					 Else 'Approve' End as Status
						from View_Late_Emp VLM
						inner join #Emp_Cons as ES on VLM.Emp_ID = ES.Emp_ID
						inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on VLM.Branch_ID =BM.Branch_ID
						inner Join T0010_COMPANY_MASTER CM WITH (NOLOCK) on VLM.Cmp_ID=CM.Cmp_Id 
						INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON VLM.Grd_Id = gm.Grd_ID left outer join
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON VLM.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON VLM.DESIG_ID = DGM.DESIG_ID left join 
					t0040_type_master TM WITH (NOLOCK) on VLM.type_id = Tm.type_id
						where VLM.Cmp_id = @Cmp_ID And Chk_By_Superior = @Check_By_Sup and (For_Date)>= @From_Date and For_Date <= @To_Date
						order by RIGHT(REPLICATE(N' ', 500) + VLM.ALPHA_EMP_CODE, 500)
				End
			Else
				Begin	
					
					--select *,BM.Branch_Name,Cm.Cmp_Name ,cm.cmp_address,@From_Date as P_From_Date,@To_Date as P_To_Date
					--,GM.Grd_name,BM.branch_name,DM.dept_name,DGM.desig_name,TM.type_name
					--,vs.Vertical_Name,sv.SubVertical_Name    --added jimit 29042016
					--from View_Late_Emp VLM
					--inner join #Emp_Cons as ES on VLM.Emp_ID = ES.Emp_ID
					--inner Join T0030_BRANCH_MASTER BM on VLM.Branch_ID =BM.Branch_ID
					--inner Join T0010_COMPANY_MASTER CM on VLM.Cmp_ID=CM.Cmp_Id 
					--INNER JOIN T0040_GRADE_MASTER GM ON VLM.Grd_Id = gm.Grd_ID left outer join
					--T0040_DEPARTMENT_MASTER DM ON VLM.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
					--T0040_DESIGNATION_MASTER DGM ON VLM.DESIG_ID = DGM.DESIG_ID left join 
					--t0040_type_master TM on VLM.type_id = Tm.type_id  LEFT outer JOIN
					--T0040_Vertical_Segment vs On VLM.Vertical_ID = vs.Vertical_ID  LEFT Outer JOIN
					--T0050_SubVertical sv On vlm.SubVertical_ID = sv.SubVertical_ID
					--where VLM.Cmp_id = @Cmp_ID And Chk_By_Superior = @Check_By_Sup and (For_Date)>= @From_Date and For_Date <= @To_Date
					--order by RIGHT(REPLICATE(N' ', 500) + VLM.ALPHA_EMP_CODE, 500)
					
					
					SELECT VLM.EMP_ID,VLM.IO_TRAN_ID,CM.CMP_NAME,VLM.FOR_DATE,VLM.IN_TIME,VLM.REASON,VLM.BRANCH_NAME,VLM.ALPHA_EMP_CODE,VLM.CHK_BY_SUPERIOR,VLM.HALF_FULL_DAY,VLM.SUP_COMMENT,VLM.EMP_FULL_NAME,VLM.EMP_NAME,
					VLM.OUT_TIME,VLM.SUPERIOR,VLM.OTHER_REASON,BM.BRANCH_NAME AS BRANCH_NAME1,CM.CMP_ADDRESS,@FROM_DATE AS P_FROM_DATE,@TO_DATE AS P_TO_DATE,GM.GRD_NAME,
					DM.DEPT_NAME,DGM.DESIG_NAME,TM.TYPE_NAME,DGM.DESIG_DIS_NO,VS.VERTICAL_NAME,SV.SUBVERTICAL_NAME,VLM.EMP_SUPERIOR,VLM.SUPERIOR_CODE
					into #View_Late_Emp
					from View_Late_Emp VLM
					inner join #Emp_Cons as ES on VLM.Emp_ID = ES.Emp_ID
					inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on VLM.Branch_ID =BM.Branch_ID
					inner Join T0010_COMPANY_MASTER CM WITH (NOLOCK) on VLM.Cmp_ID=CM.Cmp_Id 
					INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON VLM.Grd_Id = gm.Grd_ID left outer join
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON VLM.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON VLM.DESIG_ID = DGM.DESIG_ID left join 
					t0040_type_master TM WITH (NOLOCK) on VLM.type_id = Tm.type_id  LEFT outer JOIN
					T0040_Vertical_Segment vs WITH (NOLOCK) On VLM.Vertical_ID = vs.Vertical_ID  LEFT Outer JOIN
					T0050_SubVertical sv WITH (NOLOCK) On vlm.SubVertical_ID = sv.SubVertical_ID
					where VLM.Cmp_id = @Cmp_ID And Chk_By_Superior = @Check_By_Sup and (For_Date)>= @From_Date and For_Date <= @To_Date
					order by RIGHT(REPLICATE(N' ', 500) + VLM.ALPHA_EMP_CODE, 500)
					
					
					
					Select		DISTINCT EMP.EMP_ID,SD.APP_EMP_ID,SD.RPT_LEVEL AS RPT_LEVEL,SD.SCHEME_ID,LLA.IO_TRAN_ID
					INTO		#TBL_SCHEME_WISE_REPORTING_MANAGER
					From		T0050_Scheme_Detail SD WITH (NOLOCK)
								inner join T0095_EMP_SCHEME ES WITH (NOLOCK) ON SD.SCHEME_ID = ES.SCHEME_ID
								Inner Join
										 (
												select	MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
												where Effective_Date<=GETDATE() And Type = 'Attendance Regularization'
												GROUP BY emp_ID
										 ) QES on ES.Emp_ID = QES.Emp_ID and ES.Effective_Date = QES.For_Date and 
										 Type = 'Attendance Regularization'									  
								AND  ES.Scheme_ID=SD.Scheme_Id and ES.Type='Attendance Regularization'		
								inner join #Emp_Cons EMP on EMP.Emp_ID=ES.Emp_ID		
								left Outer join T0150_EMP_INOUT_RECORD LAD WITH (NOLOCK) on EMP.Emp_ID=LAD.Emp_ID 
								Left join T0115_AttendanceRegu_Level_Approval LLA WITH (NOLOCK) ON LLA.Emp_ID=ES.Emp_ID and LLA.IO_TRAN_ID=LAD.IO_TRAN_ID 
								LEFT JOIN 
								(
								
									SELECT (MAX(AA.RPT_LEVEL) + (case when @Status = 2 then 0 else 1 end)) AS RPT_LEVEL,SD.SCHEME_ID,ES.EMP_ID
									FROM T0050_SCHEME_DETAIL SD WITH (NOLOCK)
									INNER JOIN T0095_EMP_SCHEME ES WITH (NOLOCK) ON SD.SCHEME_ID = ES.SCHEME_ID
									LEFT JOIN T0115_ATTENDANCEREGU_LEVEL_APPROVAL AA WITH (NOLOCK) ON ES.EMP_ID = AA.EMP_ID
									GROUP BY SD.SCHEME_ID,ES.EMP_ID
									
								) QRY ON SD.SCHEME_ID = QRY.SCHEME_ID AND ES.EMP_ID = QRY.EMP_ID
								left Outer JOIN T0080_EMP_MASTER RM WITH (NOLOCK) ON RM.Emp_ID=SD.App_Emp_ID
					where		LLA.FOR_DATE BETWEEN @From_Date AND @TO_DATE  AND SD.RPT_LEVEL = QRY.RPT_LEVEL

					
					
					UPDATE A
					SET A.EMP_SUPERIOR = ISNULL(SD.APP_EMP_ID,A.EMP_SUPERIOR),
					A.SUPERIOR = (EM.ALPHA_EMP_CODE + ' - ' + EM.EMP_FULL_NAME),
					A.SUPERIOR_CODE = EM.ALPHA_EMP_CODE
					FROM #View_Late_Emp A INNER JOIN #TBL_SCHEME_WISE_REPORTING_MANAGER B ON A.IO_TRAN_ID = B.IO_TRAN_ID AND A.EMP_ID = B.EMP_ID
					INNER JOIN T0050_Scheme_Detail SD ON B.SCHEME_ID = SD.SCHEME_ID AND B.RPT_LEVEL = SD.RPT_LEVEL
					INNER JOIN T0080_EMP_MASTER EM ON SD.APP_EMP_ID = EM.EMP_ID
					
					
					SELECT A.EMP_ID, A.IO_TRAN_ID, A.CMP_NAME, A.FOR_DATE, A.IN_TIME, A.REASON, A.BRANCH_NAME, A.ALPHA_EMP_CODE, A.CHK_BY_SUPERIOR, A.HALF_FULL_DAY, A.SUP_COMMENT
					, A.EMP_FULL_NAME, A.EMP_NAME, A.OUT_TIME
					--, A.SUPERIOR
					, Case when A.Chk_By_Superior = 0 then A.Superior else (E.ALPHA_EMP_CODE + ' - ' + E.EMP_FULL_NAME) END as Superior
					, A.OTHER_REASON, A.BRANCH_NAME1, A.CMP_ADDRESS, A.P_FROM_DATE, A.P_TO_DATE, A.GRD_NAME
					, A.DEPT_NAME, A.DESIG_NAME
					, A.TYPE_NAME, A.DESIG_DIS_NO, A.VERTICAL_NAME, A.SUBVERTICAL_NAME
					--, A.EMP_SUPERIOR
					,T.R_Emp_ID as  EMP_SUPERIOR
					--, A.SUPERIOR_CODE
					, Case when A.Chk_By_Superior = 0 then A.Superior_Code else E.Alpha_Emp_Code END as Superior_Code
					FROM #View_Late_Emp A LEFT JOIN #TBL_SCHEME_WISE_REPORTING_MANAGER B ON A.IO_TRAN_ID = B.IO_TRAN_ID AND A.EMP_ID = B.EMP_ID
					LEFT JOIN T0050_Scheme_Detail SD WITH (NOLOCK) ON B.SCHEME_ID = SD.SCHEME_ID AND B.RPT_LEVEL = SD.RPT_LEVEL
					inner join #TMP t on T.emp_id = A.Emp_ID
						inner join T0080_EMP_MASTER E on E.Emp_ID = t.R_Emp_ID
				
					
				End		
		end
