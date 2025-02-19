

-- =============================================
-- Author:		<Jaina>
-- Create date: <14-04-2016>
-- Description:	<Get Exit Clearance Detail>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Rpt_Exit_Clearance_Get]
	@Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(max) = ''
	,@Cat_ID		varchar(max) = ''
	,@Grd_ID		varchar(max) = ''
	,@Type_ID		varchar(max) = ''
	,@Dept_ID		varchar(max) = ''
	,@Desig_ID		varchar(max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@Segment_Id		varchar(MAX) =''
	,@Vertical_Id		varchar(MAX)=''
	,@SubVertical_Id	varchar(MAX) =''
	,@SubBranch_Id		varchar(MAX) =''
	,@Hod_id numeric(18,0)  = 0  --Added By Jaina 06-06-2016	
	,@flag	int = 0 --Added by Mukti(10082018)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	if @Hod_id=0
		set @Hod_id=NULL

	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',0,0
	
	
	
	--if @Hod_id <> 0 
	--Begin
	--	print 'm'
	--	SELECT   ECA.Emp_ID,E.Emp_Full_Name,E.Emp_Second_Name,E.Alpha_Emp_Code,I_Q.Desig_ID,Desig_Name,
	--			DM.Dept_Name As E_Dept_Name,HDM.Dept_Name,HDM.Dept_Id,E.Date_Of_Join,EE.resignation_date,EE.last_date,
	--			C.Clearance_id,C.Item_name,ED.Recovery_Amt,ED.Remarks,case when ED.Not_Applicable = 1 THEN 'NA' ELSE '' END As Not_Applicable,
	--			CM.Cmp_Id,CM.Cmp_Name,CM.Cmp_Address,CM.Cmp_City,CM.cmp_logo,GM.Grd_Name,ETM.Type_Name,
	--			BM.Branch_ID,BM.Branch_Name,VS.Vertical_Name,S.SubVertical_Name,SB.SubBranch_Name,E.Father_name,
	--			isnull(UE.Emp_Full_Name,'Admin') As Authorize_Name,ECA.Sys_date,ED.Status,E.Gender,E.Initial,ELR.Reference_No,ELR.Issue_Date,
	--			ECA.Center_ID,ISNULL(CC.Center_Name,'')CENTER_Name
	--	  FROM T0095_Exit_Clearance AS EC 
 --            INNER JOIN ( SELECT MAX(Effective_Date)as Effective_Date,Emp_id 
	--							   FROM T0095_Exit_Clearance
	--							   GROUP BY Emp_id
	--					)Qry on Qry.Emp_id = EC.Emp_id AND Qry.Effective_Date = EC.Effective_Date
	--		 INNER JOIN dbo.T0300_Exit_Clearance_Approval AS ECA ON ECA.Hod_ID=Ec.Emp_id INNER JOIN
	--			 T0350_Exit_Clearance_Approval_Detail AS ED ON ED.Approval_id = ECA.Approval_Id inner JOIN
	--			 T0040_Clearance_Attribute As C ON C.Clearance_id = ED.Clearance_id LEFT JOIN
	--			 T0040_DEPARTMENT_MASTER HDM ON HDM.Dept_Id = ECA.Dept_id and HDM.Dept_Id  = EC.Dept_id  LEFT JOIN
	--			 T0040_COST_CENTER_MASTER CC ON CC.Center_ID = ECA.Center_ID and CC.Center_ID  = EC.Center_ID  LEFT JOIN
	--			 T0080_EMP_MASTER As E ON E.Emp_ID = ECA.Emp_ID  INNER JOIN
	--			 T0200_Emp_ExitApplication AS EE ON EE.emp_id = ECA.Emp_ID inner JOIN
	--			 #Emp_Cons AS EMC ON EMC.Emp_ID= E.Emp_ID inner JOIN
	--			 T0010_COMPANY_MASTER CM ON CM.Cmp_Id = EC.Cmp_ID	
	--			  inner join
	--					( select I.Emp_Id ,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID 
	--							from T0095_Increment I inner join 
	--								( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 10092014 for Same Date Increment
	--									where Increment_Effective_date <= @To_Date
	--									and Cmp_ID = @Cmp_Id
	--									group by emp_ID  
	--								) Qry on
	--							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
	--					) I_Q on E.Emp_ID = I_Q.Emp_ID  inner join						
	--			T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN 
	--			T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
	--			T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
	--			T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
	--			T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id  left OUTER JOIN
	--			T0040_Vertical_Segment VS on I_Q.Vertical_ID = VS.Vertical_ID left OUTER JOIN
	--			T0050_SubVertical S ON I_Q.SubVertical_ID = S.SubVertical_ID left OUTER JOIN
	--			T0050_SubBranch SB ON I_Q.subBranch_ID = SB.SubBranch_ID left OUTER JOIN
	--			T0080_EMP_MASTER UE ON UE.Emp_ID = ECA.Updated_By left join
	--			T0081_Emp_LetterRef_Details ELR on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='Exit Clearance Letter'--Mukti(06012017) 	 				
	--		WHERE   E.Cmp_ID = @Cmp_id and ECA.Hod_ID = @Hod_id
	--		Order by Case When IsNumeric(E.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + E.Alpha_Emp_Code, 20)
	--		When IsNumeric(E.Alpha_Emp_Code) = 0 then Left(E.Alpha_Emp_Code + Replicate('',21), 20)
	--			Else E.Alpha_Emp_Code END
	--End
	--Else
	
	--Added by Jaina 24-09-2018 Start
	Declare @Exit_CostCenterWise as Numeric(18,0)	
		set @Exit_CostCenterWise = 0
	
	Select @Exit_CostCenterWise = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_Id and Setting_Name ='Enable Exit Clearance Process Cost Center Wise'   					
	if @Exit_CostCenterWise = 1
		set @flag =1
	else
		set @flag = 0	
	--Added by Jaina 24-09-2018 End
	
	if @flag =0 
	BEGIN		
		SELECT   ECA.Emp_ID,E.Emp_Full_Name,E.Emp_Second_Name,E.Alpha_Emp_Code,I_Q.Desig_ID,Desig_Name,
					DM.Dept_Name As E_Dept_Name,HDM.Dept_Name,HDM.Dept_Id,E.Date_Of_Join,EE.resignation_date,EE.last_date,
					C.Clearance_id,C.Item_name,ED.Recovery_Amt,ED.Remarks,case when ED.Not_Applicable = 1 THEN 'NA' ELSE '' END As Not_Applicable,
					CM.Cmp_Id,CM.Cmp_Name,CM.Cmp_Address,CM.Cmp_City,CM.cmp_logo,GM.Grd_Name,ETM.Type_Name,
					BM.Branch_ID,BM.Branch_Name,VS.Vertical_Name,S.SubVertical_Name,SB.SubBranch_Name,E.Father_name,
					isnull(UE.Emp_Full_Name,'Admin') As Authorize_Name,ECA.Sys_date,ED.Status,E.Gender,E.Initial,ELR.Reference_No,ELR.Issue_Date,
					0 as Center_ID,'' as CENTER_Name ,'' as Manager_name
			  FROM T0095_Exit_Clearance AS EC WITH (NOLOCK)
				 INNER JOIN ( SELECT MAX(Effective_Date)as Effective_Date,Emp_id 
									   FROM T0095_Exit_Clearance WITH (NOLOCK)
									   GROUP BY Emp_id
							)Qry on Qry.Emp_id = EC.Emp_id AND Qry.Effective_Date = EC.Effective_Date
				 INNER JOIN dbo.T0300_Exit_Clearance_Approval AS ECA WITH (NOLOCK) ON ECA.Hod_ID=Ec.Emp_id left OUTER JOIN
					 T0350_Exit_Clearance_Approval_Detail AS ED WITH (NOLOCK) ON ED.Approval_id = ECA.Approval_Id inner JOIN					 
					 T0040_DEPARTMENT_MASTER HDM WITH (NOLOCK) ON HDM.Dept_Id = ECA.Dept_id and HDM.Dept_Id  = EC.Dept_id  left OUTER JOIN					 
					 T0040_Clearance_Attribute As C WITH (NOLOCK) ON (C.Clearance_id = ED.Clearance_id OR (C.Dept_id = HDM.Dept_Id AND ECA.Noc_Status='P')) INNER JOIN
					 T0080_EMP_MASTER As E WITH (NOLOCK) ON E.Emp_ID = ECA.Emp_ID  INNER JOIN
					 T0200_Emp_ExitApplication AS EE WITH (NOLOCK) ON EE.emp_id = ECA.Emp_ID inner JOIN
					 #Emp_Cons AS EMC ON EMC.Emp_ID= E.Emp_ID inner JOIN
					 T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = EC.Cmp_ID	
					  inner join
							( select I.Emp_Id ,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID 
									from T0095_Increment I WITH (NOLOCK) inner join 
										( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
											where Increment_Effective_date <= @To_Date
											and Cmp_ID = @Cmp_Id
											group by emp_ID  
										) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
							) I_Q on E.Emp_ID = I_Q.Emp_ID  inner join						
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN 
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id  left OUTER JOIN
					T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID left OUTER JOIN
					T0050_SubVertical S WITH (NOLOCK) ON I_Q.SubVertical_ID = S.SubVertical_ID left OUTER JOIN
					T0050_SubBranch SB WITH (NOLOCK) ON I_Q.subBranch_ID = SB.SubBranch_ID left OUTER JOIN
					T0080_EMP_MASTER UE WITH (NOLOCK) ON UE.Emp_ID = ECA.Updated_By left join
					T0081_Emp_LetterRef_Details ELR on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='Exit Clearance Letter'--Mukti(06012017) 	 	
				WHERE   E.Cmp_ID = @Cmp_id and ECA.Hod_ID = ISNULL(@Hod_id,ECA.Hod_ID)
				Order by Case When IsNumeric(E.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + E.Alpha_Emp_Code, 20)
				When IsNumeric(E.Alpha_Emp_Code) = 0 then Left(E.Alpha_Emp_Code + Replicate('',21), 20)
					Else E.Alpha_Emp_Code END
			End
	ELSE  --for Cost Center Wise
		BEGIN
			SELECT  ECA.Emp_ID,E.Emp_Full_Name,E.Emp_Second_Name,E.Alpha_Emp_Code,I_Q.Desig_ID,Desig_Name,
					DM.Dept_Name As E_Dept_Name,'' as Dept_Name,0 as Dept_Id,E.Date_Of_Join,EE.resignation_date,EE.last_date,
					C.Clearance_id,C.Item_name,isnull(ED.Recovery_Amt,0) as Recovery_Amt,ED.Remarks,case when ED.Not_Applicable = 1 THEN 'NA' ELSE '' END As Not_Applicable,
					CM.Cmp_Id,CM.Cmp_Name,CM.Cmp_Address,CM.Cmp_City,CM.cmp_logo,GM.Grd_Name,ETM.Type_Name,
					BM.Branch_ID,BM.Branch_Name,VS.Vertical_Name,S.SubVertical_Name,SB.SubBranch_Name,E.Father_name,
					isnull(UE.Emp_Full_Name,'Admin') As Authorize_Name,ECA.Sys_date,ED.Status,E.Gender,E.Initial,ELR.Reference_No,ELR.Issue_Date,
					ECA.Center_ID,ISNULL(CC.Center_Name,'')CENTER_Name,E1.Emp_Full_Name as Manger_Name
			  FROM T0095_Exit_Clearance AS EC WITH (NOLOCK)
				 INNER JOIN ( SELECT MAX(Effective_Date)as Effective_Date,Emp_id 
									   FROM T0095_Exit_Clearance WITH (NOLOCK)
									   GROUP BY Emp_id
							)Qry on Qry.Emp_id = EC.Emp_id AND Qry.Effective_Date = EC.Effective_Date
				 INNER JOIN dbo.T0300_Exit_Clearance_Approval AS ECA WITH (NOLOCK) ON ECA.Hod_ID=Ec.Emp_id left OUTER JOIN
					 T0350_Exit_Clearance_Approval_Detail AS ED WITH (NOLOCK) ON ED.Approval_id = ECA.Approval_Id inner JOIN					
					 T0040_COST_CENTER_MASTER CC WITH (NOLOCK) ON CC.Center_ID = ECA.Center_ID and CC.Center_ID  = EC.Center_ID  left JOIN
					 T0040_Clearance_Attribute As C WITH (NOLOCK) ON (C.Clearance_id = ED.Clearance_id OR (C.Cost_Center_ID = CC.Center_ID AND ECA.Noc_Status='P')) INNER JOIN
					 T0080_EMP_MASTER As E WITH (NOLOCK) ON E.Emp_ID = ECA.Emp_ID  INNER JOIN
					 T0080_EMP_MASTER As E1 WITH (NOLOCK) ON E1.Emp_ID = EC.Emp_ID  INNER JOIN
					 T0200_Emp_ExitApplication AS EE WITH (NOLOCK) ON EE.emp_id = ECA.Emp_ID inner JOIN
					 #Emp_Cons AS EMC ON EMC.Emp_ID= E.Emp_ID inner JOIN
					 T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = EC.Cmp_ID	
					  inner join
							( select I.Emp_Id ,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID 
									from T0095_Increment I WITH (NOLOCK) inner join 
										( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
											where Increment_Effective_date <= @To_Date
											and Cmp_ID = @Cmp_Id
											group by emp_ID  
										) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
							) I_Q on E.Emp_ID = I_Q.Emp_ID  inner join						
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN 
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id  left OUTER JOIN
					T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID left OUTER JOIN
					T0050_SubVertical S WITH (NOLOCK) ON I_Q.SubVertical_ID = S.SubVertical_ID left OUTER JOIN
					T0050_SubBranch SB WITH (NOLOCK) ON I_Q.subBranch_ID = SB.SubBranch_ID left OUTER JOIN
					T0080_EMP_MASTER UE WITH (NOLOCK) ON UE.Emp_ID = ECA.Updated_By left join
					T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='Exit Clearance Letter'--Mukti(06012017) 	 	
				WHERE   E.Cmp_ID = @Cmp_id and ECA.Hod_ID = ISNULL(@Hod_id,ECA.Hod_ID)
				Order by Case When IsNumeric(E.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + E.Alpha_Emp_Code, 20)
				When IsNumeric(E.Alpha_Emp_Code) = 0 then Left(E.Alpha_Emp_Code + Replicate('',21), 20)
					Else E.Alpha_Emp_Code END
				
				--select * from V0300_NOC_Approval_Cost_Centerwise 
				--where cmp_id =@Cmp_id  and emp_id in(select data from dbo.Split('" & dtExit.Rows(0).Item("Clearance_ManagerID") & "','#')) 
				--and Effective_Date <= '" & System.DateTime.Now().ToString("dd/MMM/yyyy") & "'
		END

END


