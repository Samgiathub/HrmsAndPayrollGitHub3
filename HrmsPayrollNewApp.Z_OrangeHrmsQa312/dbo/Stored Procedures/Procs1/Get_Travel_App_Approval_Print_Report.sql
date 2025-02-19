

---------Created by Sumit For Genrating PDF in Travel App_Approval Application 04082015------------------------------------------------------
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-------------------------------------------------------------

CREATE PROCEDURE [dbo].[Get_Travel_App_Approval_Print_Report]
@Cmp_ID numeric(18,0),
@Travel_App_ID numeric(18,0),
@Travel_Approval_ID numeric(18,0),
@Emp_ID numeric(18,0),
@To_Date datetime,
@Flag_ds int,
@is_foreign tinyint =0
--@Travel_Set_App_ID numeric(18,0)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
--TRAVEL AND EMPLOYEE DETAILS FLAG=1
BEGIN
	if @Flag_ds=0
		Begin
		 if @is_foreign =0
			Begin	
			if @Travel_Approval_ID=0
			begin 
			select distinct'Approved Copy' as Rpt_name, BD.BandName,0 as Approval_Code,TA.*,Em.Alpha_Emp_Code,Em.Emp_Full_Name,
				Cm.Cmp_Address,Cm.Cmp_Name--,cm.cmp_logo--,
				,dm.Dept_Name,dsm.Desig_Name,bm.Branch_Name--,
				,(Select Grd_Name from T0040_GRADE_MASTER where Grd_ID=qry.grd_id) as Grd_Name,
				(select Vertical_Name from T0040_Vertical_Segment where Vertical_ID=Qry.Vertical_ID) as 'Project Name'
				--tad.Place_Of_Visit
				
				--,TAD.Travel_Purpose--,
				--sm.State_Name,CITYM.City_Name,Emp_Instruct.Emp_Full_Name as Instruct_Emp--,--TAA.*
				,isnull((select abs(isnull(Closing_Amount,0)) as Adv_Closing from T0150_Travel_Settlement_Expense_Transaction 
			where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID and For_Date = (select MAX(For_date) from T0150_Travel_Settlement_Expense_Transaction where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID )	),0) as Outstanding_Advance
			,tra.Approval_Date
				--,case when TAO.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pays,TAO.*,TM.Travel_Mode_Name
				--TRA.*,LM.Leave_Name
				 into #EmployeeData from T0100_TRAVEL_APPLICATION TA WITH (NOLOCK)
				inner Join T0080_Emp_Master Em WITH (NOLOCK) on Em.Emp_ID=TA.emp_id
				inner join T0010_COMPANY_MASTER Cm WITH (NOLOCK) on Cm.Cmp_Id=TA.cmp_id
				
				--left join T0130_TRAVEL_APPROVAL_ADVDETAIL TAA on TAA.Travel_Approval_ID=TA.Travel_Approval_ID
				--left join T0130_Travel_Approval_Other_Detail TAO on TAO.Travel_Approval_ID=TA.Travel_Approval_ID
				--inner join T0030_TRAVEL_MODE_MASTER TM on TM.Travel_Mode_ID=TAO.Travel_Mode_Id and TAO.Cmp_ID=TM.Cmp_ID
				
				inner join
				( select Grd_ID,Emp_ID,Dept_ID,Desig_Id,Branch_ID,Band_Id,Vertical_ID From T0095_Increment I WITH (NOLOCK)
				where	i.Increment_ID =
				(select top 1 Increment_ID
				from T0095_INCREMENT i1 WITH (NOLOCK)
				where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
				and Increment_Effective_date <= @To_Date
				order by Increment_Effective_Date desc, Increment_ID desc)
				) Qry on Qry.Emp_ID=TA.emp_id
				left join tblBandMaster BD on qry.Band_Id=BD.BandId
				left join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on dm.Dept_Id=Qry.Dept_ID
				left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on Bm.Branch_ID=qry.branch_ID
				left join T0040_DESIGNATION_MASTER Dsm WITH (NOLOCK) on Dsm.Desig_ID=Qry.Desig_Id
				--left join T0130_TRAVEL_APPROVAL_DETAIL TA WITH (NOLOCK) on TA.Travel_Approval_ID=TSA.Travel_Approval_ID
				left join T0110_TRAVEL_APPLICATION_DETAIL TAD WITH (NOLOCK) on TAD.Travel_App_ID=TA.Travel_Application_ID
				--left join T0120_TRAVEL_APPROVAL TRA WITH (NOLOCK) on TRA.Travel_Approval_ID=TA.Travel_Approval_ID and TA.Cmp_ID=TRA.Cmp_ID
				left join T0020_State_master sm WITH (NOLOCK) on Sm.State_ID=TAD.State_ID AND SM.Cmp_ID=TAD.Cmp_ID
				left JOIN T0030_CITY_MASTER CITYM WITH (NOLOCK) on CITYM.City_ID=TAD.City_ID and CITYM.Cmp_ID=TAD.Cmp_ID
				left join T0080_EMP_MASTER Emp_Instruct WITH (NOLOCK) on Emp_Instruct.Emp_ID=TAD.Instruct_Emp_ID
				left join T0120_TRAVEL_APPROVAL TRA WITH (NOLOCK) on TRA.Travel_Application_ID=TA.Application_Date 
				--left join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=TA.Leave_ID and LM.Cmp_ID=TA.Cmp_ID
				where cm.Cmp_ID=@Cmp_ID and TA.Travel_Application_ID=@Travel_App_ID
				
				select *,(select cmp_logo from T0010_COMPANY_MASTER where Cmp_ID=@Cmp_ID)as cmp_logo from #EmployeeData
			end
			else 
			begin
			select distinct 'Approved Copy'as Rpt_name,BD.BandName,TA.*,Em.Alpha_Emp_Code,Em.Emp_Full_Name,
				Cm.Cmp_Address,Cm.Cmp_Name,--cm.cmp_logo,
				dm.Dept_Name,dsm.Desig_Name,bm.Branch_Name
				--TAD.*,
				,(Select Grd_Name from T0040_GRADE_MASTER where Grd_ID=qry.grd_id) as Grd_Name,
				(select Vertical_Name from T0040_Vertical_Segment where Vertical_ID=Qry.Vertical_ID) as 'Project Name'

				--sm.State_Name,CITYM.City_Name,Emp_Instruct.Emp_Full_Name as Instruct_Emp--,--TAA.*
				,isnull((select abs(isnull(Closing_Amount,0)) as Adv_Closing from T0150_Travel_Settlement_Expense_Transaction 
				where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID and For_Date = (select MAX(For_date) from T0150_Travel_Settlement_Expense_Transaction where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID )	),0) as Outstanding_Advance
				,tap.Application_Date
				,TAP.Application_Code
				--,case when TAO.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pays,TAO.*,TM.Travel_Mode_Name
				--TRA.*,LM.Leave_Name
				 into #EmployeeData1 from T0120_TRAVEL_APPROVAL TA WITH (NOLOCK)
				inner Join T0080_Emp_Master Em WITH (NOLOCK) on Em.Emp_ID=TA.emp_id
				inner join T0010_COMPANY_MASTER Cm WITH (NOLOCK) on Cm.Cmp_Id=TA.cmp_id
				
				--left join T0130_TRAVEL_APPROVAL_ADVDETAIL TAA on TAA.Travel_Approval_ID=TA.Travel_Approval_ID
				--left join T0130_Travel_Approval_Other_Detail TAO on TAO.Travel_Approval_ID=TA.Travel_Approval_ID
				--inner join T0030_TRAVEL_MODE_MASTER TM on TM.Travel_Mode_ID=TAO.Travel_Mode_Id and TAO.Cmp_ID=TM.Cmp_ID
				
				inner join
				( select Grd_ID,Emp_ID,Dept_ID,Desig_Id,Branch_ID,Band_Id,Vertical_ID From T0095_Increment I WITH (NOLOCK)
				where	i.Increment_ID =
				(select top 1 Increment_ID
				from T0095_INCREMENT i1 WITH (NOLOCK)
				where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
				and Increment_Effective_date <= @To_Date
				order by Increment_Effective_Date desc, Increment_ID desc)
				) Qry on Qry.Emp_ID=TA.emp_id
				left join tblBandMaster BD on qry.Band_Id=BD.BandId
				left join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on dm.Dept_Id=Qry.Dept_ID
				left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on Bm.Branch_ID=qry.branch_ID
				left join T0040_DESIGNATION_MASTER Dsm WITH (NOLOCK) on Dsm.Desig_ID=Qry.Desig_Id
				--left join T0130_TRAVEL_APPROVAL_DETAIL TA WITH (NOLOCK) on TA.Travel_Approval_ID=TSA.Travel_Approval_ID
				left join T0130_TRAVEL_APPROVAL_DETAIL TAD WITH (NOLOCK) on TAD.Travel_Approval_ID=TA.Travel_Approval_ID
				--left join T0120_TRAVEL_APPROVAL TRA WITH (NOLOCK) on TRA.Travel_Approval_ID=TA.Travel_Approval_ID and TA.Cmp_ID=TRA.Cmp_ID
				left join T0020_State_master sm WITH (NOLOCK) on Sm.State_ID=TAD.State_ID AND SM.Cmp_ID=TAD.Cmp_ID
				left JOIN T0030_CITY_MASTER CITYM WITH (NOLOCK) on CITYM.City_ID=TAD.City_ID and CITYM.Cmp_ID=TAD.Cmp_ID
				left join T0080_EMP_MASTER Emp_Instruct WITH (NOLOCK) on Emp_Instruct.Emp_ID=TAD.Instruct_Emp_ID
				left join T0100_TRAVEL_APPLICATION TAP on TAp.Travel_Application_ID=TA.Travel_Application_ID
				
				--left join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=TA.Leave_ID and LM.Cmp_ID=TA.Cmp_ID
				where cm.Cmp_ID=@Cmp_ID and TA.Travel_Approval_ID=@Travel_Approval_ID
				select *,(select cmp_logo from T0010_COMPANY_MASTER where Cmp_ID=@Cmp_ID)as cmp_logo from #EmployeeData1
			end

			
			End
		Else
			Begin
			
				
				select distinct BD.BandName,TA.*,Em.Alpha_Emp_Code,Em.Emp_Full_Name,
				Cm.Cmp_Address,Cm.Cmp_Name
				,dm.Dept_Name,dsm.Desig_Name,bm.Branch_Name,
				TAD.*,--sm.State_Name,--
				LM_1.Loc_Name,
				Emp_Instruct.Emp_Full_Name as Instruct_Emp--,--TAA.*
				
				--TRA.*,LM.Leave_Name
				 from T0120_TRAVEL_APPROVAL TA WITH (NOLOCK)
				inner Join T0080_Emp_Master Em WITH (NOLOCK) on Em.Emp_ID=TA.Emp_id
				inner join T0010_COMPANY_MASTER Cm WITH (NOLOCK) on Cm.Cmp_Id=TA.cmp_id
				inner join T0130_TRAVEL_APPROVAL_DETAIL TAD WITH (NOLOCK) on TA.Travel_Approval_ID=TA.Travel_Approval_ID
				--inner join T0120_TRAVEL_APPROVAL TRA WITH (NOLOCK) on TRA.Travel_Approval_ID=TAD.Travel_Approval_ID and TA.Cmp_ID=TRA.Cmp_ID
				--inner join T0020_State_master sm on Sm.State_ID=Ta.State_ID AND SM.Cmp_ID=tA.Cmp_ID
				INNER JOIN T0001_LOCATION_MASTER LM_1 WITH (NOLOCK) on LM_1.Loc_ID=TAD.Loc_ID --and CM.Cmp_ID=TA.Cmp_ID
				inner join T0080_EMP_MASTER Emp_Instruct WITH (NOLOCK) on Emp_Instruct.Emp_ID=TAD.Instruct_Emp_ID			
				--left join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=TAD.Leave_ID and LM.Cmp_ID=TA.Cmp_ID
				inner join
				( select Grd_ID,Emp_ID,Dept_ID,Desig_Id,Branch_ID,Band_Id From T0095_Increment I WITH (NOLOCK) 
				where	i.Increment_ID =
				(select top 1 Increment_ID
				from T0095_INCREMENT i1 WITH (NOLOCK)
				where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
				and Increment_Effective_date <= @To_Date
				order by Increment_Effective_Date desc, Increment_ID desc)
				) Qry on Qry.Emp_ID=TA.emp_id
				left join tblBandMaster BD on qry.Band_Id=BD.BandId
				left join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on dm.Dept_Id=Qry.Dept_ID
				left Join T0030_BRANCH_MASTER Bm WITH (NOLOCK) on Bm.Branch_ID=qry.branch_ID
				left join T0040_DESIGNATION_MASTER Dsm WITH (NOLOCK) on Dsm.Desig_ID=Qry.Desig_Id
				where cm.Cmp_ID=@Cmp_ID and TA.Travel_Approval_ID=@Travel_Approval_ID
			End	
	End

--select * from T0130_Travel_Approval_Other_Detail where Cmp_ID=55 and Travel_Approval_ID=268

--OTHER DETAILS FLAG=1
if @Flag_ds=1
Begin
	 
	 if @Travel_Approval_ID=0 
	 begin
	 Select distinct 
		Tm.Travel_Mode_Name
		,tam.Travel_Mode
		,CONVERT(VARCHAR(11),TAA.For_date,103) as For_date 
				,right(convert(varchar,TAA.For_date),7) as From_Time
				,TAA.Description
				,TAA.Amount as Amount
				,case when TAA.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pay  
				,isnull(tam.From_Place,Tam.Pick_Up_Address) as 'From Place',isnull(TAM.To_Place,Tam.Drop_Address) as 'To Place'
				,tam.Pick_Up_Time
				,tam.Booking_Date,Tam.No_Passenger
				,TAM.City
				
				
		--into #test
				from T0110_Travel_Application_Other_Detail as TAA WITH (NOLOCK)
				inner join T0110_TRAVEL_APPLICATION_MODE_DETAIL TAM WITH (NOLOCK) on TAM.TRAVEL_APP_ID=taa.TRAVEL_APP_ID and tam.Travel_App_Other_Detail_ID=TAA.Travel_App_Other_Detail_Id
				 inner join T0100_TRAVEL_APPLICATION TA WITH (NOLOCK) on TA.Travel_Application_ID =TAA.Travel_App_ID
								 inner join T0080_Emp_Master e WITH (NOLOCK) on TA.Emp_ID = e.emp_ID 
				 INNER JOIN dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK) ON TM.Travel_Mode_ID = TAA.Travel_Mode_Id and tm.Cmp_ID=@Cmp_ID
				 left join T0040_CURRENCY_MASTER CRM WITH (NOLOCK) on CRM.Curr_ID=TAA.Curr_ID and CRM.Cmp_ID=TAA.Cmp_ID
				 where TA.Cmp_ID=@Cmp_ID and TA.Travel_Application_ID=@Travel_App_ID
	 end
	 else
	 begin
	 select Distinct
				Tm.Travel_Mode_Name
		,tam.Travel_Mode
		,CONVERT(VARCHAR(11),TAA.For_date,103) as For_date 
				,right(convert(varchar,TAA.For_date),7) as From_Time
				,TAA.Description
				,TAA.Amount as Amount
				,case when TAA.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pay  
				,isnull(tam.From_Place,Tam.Pick_Up_Address) as 'From Place',isnull(TAM.To_Place,Tam.Drop_Address) as 'To Place'
				,tam.Pick_Up_Time
				,tam.Booking_Date,Tam.No_Passenger
				,TAM.City
				from T0130_Travel_Approval_Other_Detail as TAA WITH (NOLOCK)
				inner join T0130_Travel_Approval_Other_Mode_Detail TAM WITH (NOLOCK) on TAM.Travel_Approval_ID=taa.Travel_Approval_ID
				and tam.Travel_Approval_Other_Detail_ID=TAA.Travel_Apr_Other_Detail_Id
				 inner join T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) on TA.Travel_Approval_ID =TAA.Travel_Approval_ID
				 --inner join T0140_Travel_Settlement_Application TSA ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id
				 --inner join  
				 --inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID 
				 inner join T0080_Emp_Master e WITH (NOLOCK) on TA.Emp_ID = e.emp_ID 
				 INNER JOIN dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK) ON TM.Travel_Mode_ID = TAA.Travel_Mode_ID and tm.Travel_Mode_ID=taa.Mode_Id
				 left join T0040_CURRENCY_MASTER CRM WITH (NOLOCK) on CRM.Curr_ID=TAA.Curr_ID and CRM.Cmp_ID=TAA.Cmp_ID
				 where TA.Cmp_ID=@Cmp_ID and TA.Travel_Approval_ID=@Travel_Approval_ID
	 end

				
				
 End   

 --ADVANCE DETAILS FLAG=2
 if @Flag_ds=2
 Begin
 if @Travel_Approval_ID=0 
 begin
 Select distinct TA.*
				 ,e.Emp_Full_name,e.Emp_Code
				 ,e.Alpha_Emp_Code,e.Emp_First_Name
				 --,Cmp_Name,Cmp_Address 
				 --,@From_Date as From_Date,@To_Date as To_Date
				,TAdv.Travel_App_ID as TAdv_App_Id
				,Tadv.Expence_Type
				,TAdv.Travel_Advance_Detail_ID as Travel_Advance_Detail_ID,
				TAdv.Adv_Detail_Desc
				,tadv.Amount as Amount,
				
				CRM.Curr_Symbol,CRM.Curr_Name
				,tad.Cmp_ID,TAD.Instruct_Emp_ID,TAD.Loc_ID,--tad.Period,
				TAD.Project_ID,
				tad.Travel_App_ID,tad.Travel_Mode_ID ,
				(select Sum(period) from T0110_TRAVEL_APPLICATION_DETAIL where Travel_App_ID=@Travel_App_ID) as Total_Period
				from T0110_TRAVEL_ADVANCE_DETAIL as TAdv WITH (NOLOCK)
				 inner join T0100_TRAVEL_APPLICATION TA WITH (NOLOCK) on TA.Travel_Application_ID =tadv.Travel_App_ID
				 inner join T0110_TRAVEL_APPLICATION_DETAIL TAD WITH (NOLOCK) on TAD.Travel_App_Id=tadv.Travel_App_ID
				 --inner join T0140_Travel_Settlement_Application TSA ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id
				 --inner join  
				 --inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID 
				 inner join T0080_Emp_Master e WITH (NOLOCK) on TA.Emp_ID = e.emp_ID 
				 --INNER JOIN dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK) ON TM.Travel_Mode_Name = tadv.Expence_Type 
				 left join T0040_CURRENCY_MASTER CRM WITH (NOLOCK) on CRM.Curr_ID=Tadv.Curr_ID and CRM.Cmp_ID=tadv.Cmp_ID
				 where TA.Cmp_ID=@Cmp_ID and TA.Travel_Application_ID=@Travel_App_ID
 end
 else
 begin
		Select distinct TA.*
				 ,e.Emp_Full_name,e.Emp_Code
				 ,e.Alpha_Emp_Code,e.Emp_First_Name
				 --,Cmp_Name,Cmp_Address 
				 --,@From_Date as From_Date,@To_Date as To_Date
				,TAdv.Travel_Approval_ID as TAdv_App_Id
				,Tadv.Expence_Type
				,TAdv.Travel_Approval_AdvDetail_ID as Travel_Advance_Detail_ID,
				TAdv.Adv_Detail_Desc
				,tadv.Amount as Amount,
				
				CRM.Curr_Symbol,CRM.Curr_Name
				,tad.Cmp_ID,TAD.Instruct_Emp_ID,TAD.Loc_ID,--tad.Period,
				TAD.Project_ID,
				tad.Travel_Approval_ID,tad.Travel_Mode_ID ,
				(select Sum(period) from T0130_TRAVEL_APPROVAL_DETAIL where Travel_Approval_ID=@Travel_Approval_ID) as Total_Period
				--,TAD.*
				from T0130_TRAVEL_APPROVAL_ADVDETAIL as TAdv WITH (NOLOCK)
				 inner join T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) on TA.Travel_Approval_ID =tadv.Travel_Approval_ID
				 inner join T0130_TRAVEL_APPROVAL_DETAIL TAD WITH (NOLOCK) on TAD.Travel_Approval_ID=tadv.Travel_Approval_ID
				 --inner join T0140_Travel_Settlement_Application TSA ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id
				 --inner join  
				 --inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID 
				 inner join T0080_Emp_Master e WITH (NOLOCK) on TA.Emp_ID = e.emp_ID 
				 --INNER JOIN dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK) ON TM.Travel_Mode_Name = tadv.Expence_Type 
				 left join T0040_CURRENCY_MASTER CRM WITH (NOLOCK) on CRM.Curr_ID=Tadv.Curr_ID and CRM.Cmp_ID=tadv.Cmp_ID
				 where TA.Cmp_ID=@Cmp_ID and TA.Travel_Approval_ID=@Travel_Approval_ID
		end
 End
if @Flag_ds=3
 Begin

-- Declare @Travel_Application_ID1 as numeric(18,0)=( select Travel_Application_ID from T0120_TRAVEL_APPROVAL where Travel_Approval_ID=@Travel_Approval_ID and Cmp_ID=@Cmp_ID)
---- SELECT Scheme_Id FROM T0050_Scheme_Detail where Scheme_Id = (SELECT Top 1 T.Scheme_Id from T0095_EMP_SCHEME T Inner Join T0050_Scheme_Detail T1 ON T.Scheme_ID = T1.Scheme_Id where Emp_ID = 28201 And Type = 'Travel' AND Effective_Date = (SELECT max(Effective_Date) from T0095_EMP_SCHEME where Emp_ID = 28201 And Type = 'Travel' AND Effective_Date <= getdate() ) AND (SELECT distinct Travel_Type_Id from V0110_TRAVEL_APPLICATION_DETAIL where Travel_Application_ID = 246) IN (select data from dbo.split(leave,'#'))) AND (SELECT distinct Travel_Type_Id from V0110_TRAVEL_APPLICATION_DETAIL where Travel_Application_ID = @Travel_Application_ID1) IN (select data from dbo.split(leave,'#')) GROUP BY Scheme_Id	
--SELECT isnull(max(Rpt_Level),0) as max_level,Scheme_Id into #scheme_data FROM T0050_Scheme_Detail where Scheme_Id = (SELECT Top 1 T.Scheme_Id from T0095_EMP_SCHEME T Inner Join T0050_Scheme_Detail T1 ON T.Scheme_ID = T1.Scheme_Id where Emp_ID = @Emp_ID And Type = 'Travel' AND Effective_Date = (SELECT max(Effective_Date) from T0095_EMP_SCHEME where Emp_ID = @Emp_ID And Type = 'Travel' AND Effective_Date <= getdate() ) AND (SELECT distinct Travel_Type_Id from V0110_TRAVEL_APPLICATION_DETAIL where Travel_Application_ID = @Travel_Application_ID1) IN (select data from dbo.split(leave,'#'))) AND (SELECT distinct Travel_Type_Id from V0110_TRAVEL_APPLICATION_DETAIL where Travel_Application_ID = @Travel_Application_ID1) IN (select data from dbo.split(leave,'#')) GROUP BY Scheme_Id	

-- select (Select max_level from #scheme_data)as Rpt_level,Concat(Alpha_Emp_Code,'-', Emp_Full_Name) as name from T0050_Scheme_Detail SD inner join T0080_EMP_MASTER em on SD.App_Emp_ID=em.Emp_ID where Scheme_Id=(Select Scheme_Id from #scheme_data) and Rpt_Level=(Select max_level from #scheme_data)
--  Drop table #scheme_data
 -- Select  0 As Rpt_Level, 
 --(EM.Alpha_Emp_Code + '-'+ EM.Emp_Full_Name) as name 
 --into #App_Manager From V0100_TRAVEL_APPLICATION TA Inner JOIN T0080_EMP_MASTER EM ON TA.Emp_ID = EM.Emp_ID 
 --Where Travel_Application_ID = @Travel_App_ID and Application_Status='A'
 --Union Select  Rpt_Level
 --,(EM.Alpha_Emp_Code + '-'+ EM.Emp_Full_Name) as name 
 -- From T0115_TRAVEL_LEVEL_APPROVAL TLA Inner JOIN T0080_EMP_MASTER EM ON TLA.S_Emp_ID = EM.Emp_ID 
 --Where Travel_Application_ID = @Travel_App_ID
 --Order By Rpt_Level
 --select Rpt_Level,name from  #App_Manager where Rpt_Level=(select max(Rpt_Level) from #App_Manager)
 --Drop table #App_Manager
 Select  0 As Rpt_Level, 
 (EM.Alpha_Emp_Code + '-'+ EM.Emp_Full_Name) as name 
 into #App_Manager From V0100_TRAVEL_APPLICATION TA Inner JOIN T0080_EMP_MASTER EM ON TA.Emp_ID = EM.Emp_ID 
 Where travel_approval_id= @Travel_Approval_ID and Application_Status='A'
 Union Select  Rpt_Level
 ,(EM.Alpha_Emp_Code + '-'+ EM.Emp_Full_Name) as name 
  From T0115_TRAVEL_LEVEL_APPROVAL TLA Inner JOIN T0080_EMP_MASTER EM ON TLA.S_Emp_ID = EM.Emp_ID 
  inner join V0100_TRAVEL_APPLICATION VTA on vta.Travel_Application_ID=TLA.Travel_Application_ID
 Where vta.travel_approval_id = @Travel_Approval_ID
 Order By Rpt_Level

 select Rpt_Level,name from  #App_Manager where Rpt_Level=(select max(Rpt_Level) from #App_Manager)
 Drop table #App_Manager


 End 

 if @Flag_ds=4
		Begin
		 if @is_foreign =0
			Begin	
			if @Travel_Approval_ID=0 
			begin 
			select distinct'Approved Copy' as Rpt_name, BD.BandName,0 as Travel_Approval_Id,TA.*,Em.Alpha_Emp_Code,Em.Emp_Full_Name,
				Cm.Cmp_Address,Cm.Cmp_Name--,cm.cmp_logo--,
				,dm.Dept_Name,dsm.Desig_Name,bm.Branch_Name,
				--tad.Place_Of_Visit,
				--(select * from T0030_CITY_MASTER where City_ID=TAD.)
				TAD.*--,
				,TRA.Approval_Date
				,(select City_Name from T0030_CITY_MASTER where City_ID=tad.City_ID and Cmp_Id=@Cmp_ID)as City_Name
				,(select State_Name from T0020_STATE_MASTER where State_ID=tad.State_ID and Cmp_Id=@Cmp_ID)as State_Name
				--sm.State_Name,CITYM.City_Name,Emp_Instruct.Emp_Full_Name as Instruct_Emp--,--TAA.*
				,isnull((select abs(isnull(Closing_Amount,0)) as Adv_Closing 
				
				from T0150_Travel_Settlement_Expense_Transaction 
where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID and For_Date = (select MAX(For_date) from T0150_Travel_Settlement_Expense_Transaction where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID )	),0) as Outstanding_Advance
				,(select City_Name from T0030_CITY_MASTER where City_ID=tad.From_City_Id and Cmp_Id=@Cmp_ID)as From_City_Name  
				,(select State_Name from T0020_STATE_MASTER where State_ID=tad.From_State_id and Cmp_Id=@Cmp_ID)as From_State_Name
				,isnull(RM.Reason_Name ,'') as Reason_Name
				--,case when TAO.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pays,TAO.*,TM.Travel_Mode_Name
				--TRA.*,LM.Leave_Name
				  from T0100_TRAVEL_APPLICATION TA WITH (NOLOCK)
				inner Join T0080_Emp_Master Em WITH (NOLOCK) on Em.Emp_ID=TA.emp_id
				inner join T0010_COMPANY_MASTER Cm WITH (NOLOCK) on Cm.Cmp_Id=TA.cmp_id
				
				--left join T0130_TRAVEL_APPROVAL_ADVDETAIL TAA on TAA.Travel_Approval_ID=TA.Travel_Approval_ID
				--left join T0130_Travel_Approval_Other_Detail TAO on TAO.Travel_Approval_ID=TA.Travel_Approval_ID
				--inner join T0030_TRAVEL_MODE_MASTER TM on TM.Travel_Mode_ID=TAO.Travel_Mode_Id and TAO.Cmp_ID=TM.Cmp_ID
				
				left join
				( select Grd_ID,Emp_ID,Dept_ID,Desig_Id,Branch_ID,Band_Id From T0095_Increment I WITH (NOLOCK)
				where	i.Increment_ID =
				(select top 1 Increment_ID
				from T0095_INCREMENT i1 WITH (NOLOCK)
				where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
				and Increment_Effective_date <= @To_Date
				order by Increment_Effective_Date desc, Increment_ID desc)
				) Qry on Qry.Emp_ID=TA.emp_id
				left join tblBandMaster BD on qry.Band_Id=BD.BandId
				left join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on dm.Dept_Id=Qry.Dept_ID
				left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on Bm.Branch_ID=qry.branch_ID
				left join T0040_DESIGNATION_MASTER Dsm WITH (NOLOCK) on Dsm.Desig_ID=Qry.Desig_Id
				--left join T0130_TRAVEL_APPROVAL_DETAIL TA WITH (NOLOCK) on TA.Travel_Approval_ID=TSA.Travel_Approval_ID
				left join T0110_TRAVEL_APPLICATION_DETAIL TAD WITH (NOLOCK) on TAD.Travel_App_ID=TA.Travel_Application_ID
				LEFT JOIN T0040_Reason_Master RM WITH (NOLOCK) on RM.Res_Id = TAD.Reason_ID
				--left join T0120_TRAVEL_APPROVAL TRA WITH (NOLOCK) on TRA.Travel_Approval_ID=TA.Travel_Approval_ID and TA.Cmp_ID=TRA.Cmp_ID
				left join T0020_State_master sm WITH (NOLOCK) on Sm.State_ID=TAD.State_ID AND SM.Cmp_ID=TAD.Cmp_ID
				left JOIN T0030_CITY_MASTER CITYM WITH (NOLOCK) on CITYM.City_ID=TAD.City_ID and CITYM.Cmp_ID=TAD.Cmp_ID
				left join T0080_EMP_MASTER Emp_Instruct WITH (NOLOCK) on Emp_Instruct.Emp_ID=TAD.Instruct_Emp_ID
				left join T0120_TRAVEL_APPROVAL TRA WITH (NOLOCK) on TRA.Travel_Application_ID=TA.Application_Date 
				--left join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=TA.Leave_ID and LM.Cmp_ID=TA.Cmp_ID
				where cm.Cmp_ID=@Cmp_ID and TA.Travel_Application_ID=@Travel_App_ID
			end
			else
			begin




						select  'Approved Copy'as Rpt_name,BD.BandName,TA.*,Em.Alpha_Emp_Code,Em.Emp_Full_Name,
				Cm.Cmp_Address,Cm.Cmp_Name,cm.cmp_logo,
				dm.Dept_Name,dsm.Desig_Name,bm.Branch_Name,
				TAD.*,tap.Application_Date,
				sm.State_Name,CITYM.City_Name,Emp_Instruct.Emp_Full_Name as Instruct_Emp--,--TAA.*
				,isnull((select abs(isnull(Closing_Amount,0)) as Adv_Closing from T0150_Travel_Settlement_Expense_Transaction 
				where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID and For_Date = (select MAX(For_date) from T0150_Travel_Settlement_Expense_Transaction where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID )	),0) as Outstanding_Advance
				,(select City_Name from T0030_CITY_MASTER where City_ID=tad.From_City_Id and Cmp_Id=@Cmp_ID)as From_City_Name  
				,(select State_Name from T0020_STATE_MASTER where State_ID=tad.From_State_id and Cmp_Id=@Cmp_ID)as From_State_Name
				,isnull(RM.Reason_Name ,'') as Reason_Name
				--,case when TAO.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pays,TAO.*,TM.Travel_Mode_Name
				--TRA.*,LM.Leave_Name
				 from T0120_TRAVEL_APPROVAL TA WITH (NOLOCK)
				inner Join T0080_Emp_Master Em WITH (NOLOCK) on Em.Emp_ID=TA.emp_id
				inner join T0010_COMPANY_MASTER Cm WITH (NOLOCK) on Cm.Cmp_Id=TA.cmp_id
				
				--left join T0130_TRAVEL_APPROVAL_ADVDETAIL TAA on TAA.Travel_Approval_ID=TA.Travel_Approval_ID
				--left join T0130_Travel_Approval_Other_Detail TAO on TAO.Travel_Approval_ID=TA.Travel_Approval_ID
				--inner join T0030_TRAVEL_MODE_MASTER TM on TM.Travel_Mode_ID=TAO.Travel_Mode_Id and TAO.Cmp_ID=TM.Cmp_ID
				
				inner join
				( select Grd_ID,Emp_ID,Dept_ID,Desig_Id,Branch_ID,Band_Id From T0095_Increment I WITH (NOLOCK)
				where	i.Increment_ID =
				(select top 1 Increment_ID
				from T0095_INCREMENT i1 WITH (NOLOCK)
				where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
				and Increment_Effective_date <= @To_Date
				order by Increment_Effective_Date desc, Increment_ID desc)
				) Qry on Qry.Emp_ID=TA.emp_id
				left join tblBandMaster BD on qry.Band_Id=BD.BandId
				left join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on dm.Dept_Id=Qry.Dept_ID
				left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on Bm.Branch_ID=qry.branch_ID
				left join T0040_DESIGNATION_MASTER Dsm WITH (NOLOCK) on Dsm.Desig_ID=Qry.Desig_Id
				--left join T0130_TRAVEL_APPROVAL_DETAIL TA WITH (NOLOCK) on TA.Travel_Approval_ID=TSA.Travel_Approval_ID
				left join T0130_TRAVEL_APPROVAL_DETAIL TAD WITH (NOLOCK) on TAD.Travel_Approval_ID=TA.Travel_Approval_ID
				LEFT JOIN T0040_Reason_Master RM WITH (NOLOCK) on RM.Res_Id = TAD.Reason_ID
				--left join T0120_TRAVEL_APPROVAL TRA WITH (NOLOCK) on TRA.Travel_Approval_ID=TA.Travel_Approval_ID and TA.Cmp_ID=TRA.Cmp_ID
				left join T0020_State_master sm WITH (NOLOCK) on Sm.State_ID=TAD.State_ID AND SM.Cmp_ID=TAD.Cmp_ID
				left JOIN T0030_CITY_MASTER CITYM WITH (NOLOCK) on CITYM.City_ID=TAD.City_ID and CITYM.Cmp_ID=TAD.Cmp_ID
				left join T0080_EMP_MASTER Emp_Instruct WITH (NOLOCK) on Emp_Instruct.Emp_ID=TAD.Instruct_Emp_ID
				left join T0100_TRAVEL_APPLICATION TAP on TAp.Travel_Application_ID=TA.Travel_Application_ID
				--left join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=TA.Leave_ID and LM.Cmp_ID=TA.Cmp_ID
				where cm.Cmp_ID=@Cmp_ID and TA.Travel_Approval_ID=@Travel_Approval_ID
				end
--				select distinct'Approved Copy' as Rpt_name, BD.BandName,TA.*,Em.Alpha_Emp_Code,Em.Emp_Full_Name,
--				Cm.Cmp_Address,Cm.Cmp_Name--,cm.cmp_logo--,
--				,dm.Dept_Name,dsm.Desig_Name,bm.Branch_Name,
--				--tad.Place_Of_Visit,
--				--(select * from T0030_CITY_MASTER where City_ID=TAD.)
--				TAD.*--,
--				,(select City_Name from T0030_CITY_MASTER where City_ID=tad.City_ID and Cmp_Id=@Cmp_ID)as City_Name
--				,(select State_Name from T0020_STATE_MASTER where State_ID=tad.State_ID and Cmp_Id=@Cmp_ID)as State_Name
--				--sm.State_Name,CITYM.City_Name,Emp_Instruct.Emp_Full_Name as Instruct_Emp--,--TAA.*
--				,isnull((select abs(isnull(Closing_Amount,0)) as Adv_Closing 
				
--				from T0150_Travel_Settlement_Expense_Transaction 
--where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID and For_Date = (select MAX(For_date) from T0150_Travel_Settlement_Expense_Transaction where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID )	),0) as Outstanding_Advance
--				--,case when TAO.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pays,TAO.*,TM.Travel_Mode_Name
--				--TRA.*,LM.Leave_Name
--				  from T0120_TRAVEL_APPROVAL TA WITH (NOLOCK)
--				inner Join T0080_Emp_Master Em WITH (NOLOCK) on Em.Emp_ID=TA.emp_id
--				inner join T0010_COMPANY_MASTER Cm WITH (NOLOCK) on Cm.Cmp_Id=TA.cmp_id
				
--				--left join T0130_TRAVEL_APPROVAL_ADVDETAIL TAA on TAA.Travel_Approval_ID=TA.Travel_Approval_ID
--				--left join T0130_Travel_Approval_Other_Detail TAO on TAO.Travel_Approval_ID=TA.Travel_Approval_ID
--				--inner join T0030_TRAVEL_MODE_MASTER TM on TM.Travel_Mode_ID=TAO.Travel_Mode_Id and TAO.Cmp_ID=TM.Cmp_ID
				
--				left join
--				( select Grd_ID,Emp_ID,Dept_ID,Desig_Id,Branch_ID,Band_Id From T0095_Increment I WITH (NOLOCK)
--				where	i.Increment_ID =
--				(select top 1 Increment_ID
--				from T0095_INCREMENT i1 WITH (NOLOCK)
--				where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
--				and Increment_Effective_date <= @To_Date
--				order by Increment_Effective_Date desc, Increment_ID desc)
--				) Qry on Qry.Emp_ID=TA.emp_id
--				left join tblBandMaster BD on qry.Band_Id=BD.BandId
--				left join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on dm.Dept_Id=Qry.Dept_ID
--				left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on Bm.Branch_ID=qry.branch_ID
--				left join T0040_DESIGNATION_MASTER Dsm WITH (NOLOCK) on Dsm.Desig_ID=Qry.Desig_Id
--				--left join T0130_TRAVEL_APPROVAL_DETAIL TA WITH (NOLOCK) on TA.Travel_Approval_ID=TSA.Travel_Approval_ID
--				left join T0130_TRAVEL_APPROVAL_DETAIL TAD WITH (NOLOCK) on TAD.Travel_Approval_Id=TA.Travel_Application_ID
--				--left join T0120_TRAVEL_APPROVAL TRA WITH (NOLOCK) on TRA.Travel_Approval_ID=TA.Travel_Approval_ID and TA.Cmp_ID=TRA.Cmp_ID
--				left join T0020_State_master sm WITH (NOLOCK) on Sm.State_ID=TAD.State_ID AND SM.Cmp_ID=TAD.Cmp_ID
--				left JOIN T0030_CITY_MASTER CITYM WITH (NOLOCK) on CITYM.City_ID=TAD.City_ID and CITYM.Cmp_ID=TAD.Cmp_ID
--				left join T0080_EMP_MASTER Emp_Instruct WITH (NOLOCK) on Emp_Instruct.Emp_ID=TAD.Instruct_Emp_ID
--				--left join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=TA.Leave_ID and LM.Cmp_ID=TA.Cmp_ID
--				where cm.Cmp_ID=@Cmp_ID and TA.Travel_Application_ID=@Travel_App_ID
			End
		Else
			Begin
			
				
				select distinct BD.BandName,TA.*,Em.Alpha_Emp_Code,Em.Emp_Full_Name,
				Cm.Cmp_Address,Cm.Cmp_Name
				,dm.Dept_Name,dsm.Desig_Name,bm.Branch_Name,
				TAD.*,--sm.State_Name,--
				LM_1.Loc_Name,
				Emp_Instruct.Emp_Full_Name as Instruct_Emp--,--TAA.*
				
				--TRA.*,LM.Leave_Name
				 from T0120_TRAVEL_APPROVAL TA WITH (NOLOCK)
				inner Join T0080_Emp_Master Em WITH (NOLOCK) on Em.Emp_ID=TA.Emp_id
				inner join T0010_COMPANY_MASTER Cm WITH (NOLOCK) on Cm.Cmp_Id=TA.cmp_id
				inner join T0130_TRAVEL_APPROVAL_DETAIL TAD WITH (NOLOCK) on TA.Travel_Approval_ID=TA.Travel_Approval_ID
				--inner join T0120_TRAVEL_APPROVAL TRA WITH (NOLOCK) on TRA.Travel_Approval_ID=TAD.Travel_Approval_ID and TA.Cmp_ID=TRA.Cmp_ID
				--inner join T0020_State_master sm on Sm.State_ID=Ta.State_ID AND SM.Cmp_ID=tA.Cmp_ID
				INNER JOIN T0001_LOCATION_MASTER LM_1 WITH (NOLOCK) on LM_1.Loc_ID=TAD.Loc_ID --and CM.Cmp_ID=TA.Cmp_ID
				inner join T0080_EMP_MASTER Emp_Instruct WITH (NOLOCK) on Emp_Instruct.Emp_ID=TAD.Instruct_Emp_ID			
				--left join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=TAD.Leave_ID and LM.Cmp_ID=TA.Cmp_ID
				inner join
				( select Grd_ID,Emp_ID,Dept_ID,Desig_Id,Branch_ID,Band_Id From T0095_Increment I WITH (NOLOCK) 
				where	i.Increment_ID =
				(select top 1 Increment_ID
				from T0095_INCREMENT i1 WITH (NOLOCK)
				where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
				and Increment_Effective_date <= @To_Date
				order by Increment_Effective_Date desc, Increment_ID desc)
				) Qry on Qry.Emp_ID=TA.emp_id
				left join tblBandMaster BD on qry.Band_Id=BD.BandId
				left join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on dm.Dept_Id=Qry.Dept_ID
				left Join T0030_BRANCH_MASTER Bm WITH (NOLOCK) on Bm.Branch_ID=qry.branch_ID
				left join T0040_DESIGNATION_MASTER Dsm WITH (NOLOCK) on Dsm.Desig_ID=Qry.Desig_Id
				where cm.Cmp_ID=@Cmp_ID and TA.Travel_Approval_ID=@Travel_Approval_ID
			End	
	End
	if @Flag_ds=5
	begin
	if @Travel_Approval_ID=0 
	begin
	Select distinct 
		Tm.Travel_Mode_Name
		,tam.Travel_Mode
		,CONVERT(VARCHAR(11),TAA.For_date,103) as For_date 
				,right(convert(varchar,TAA.For_date),7) as From_Time
				,TAA.Description
				,TAA.Amount as Amount
				,case when TAA.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pay  
				,isnull(tam.From_Place,Tam.Pick_Up_Address) as 'From Place',isnull(TAM.To_Place,Tam.Drop_Address) as 'To Place'
				,tam.Pick_Up_Time
				,tam.Booking_Date,Tam.No_Passenger
				,TAM.City
				
				
		--into #test
				from T0110_Travel_Application_Other_Detail as TAA WITH (NOLOCK)
				inner join T0110_TRAVEL_APPLICATION_MODE_DETAIL TAM WITH (NOLOCK) on TAM.TRAVEL_APP_ID=taa.TRAVEL_APP_ID and tam.Travel_App_Other_Detail_ID=TAA.Travel_App_Other_Detail_Id
				 inner join T0100_TRAVEL_APPLICATION TA WITH (NOLOCK) on TA.Travel_Application_ID =TAA.Travel_App_ID
								 inner join T0080_Emp_Master e WITH (NOLOCK) on TA.Emp_ID = e.emp_ID 
				 INNER JOIN dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK) ON TM.Travel_Mode_ID = TAA.Travel_Mode_Id and tm.Cmp_ID=@Cmp_ID
				 left join T0040_CURRENCY_MASTER CRM WITH (NOLOCK) on CRM.Curr_ID=TAA.Curr_ID and CRM.Cmp_ID=TAA.Cmp_ID
				 where TA.Cmp_ID=@Cmp_ID and TA.Travel_Application_ID=@Travel_App_ID
	end
	else
	begin

		select Distinct
				Tm.Travel_Mode_Name
		,tam.Travel_Mode
		,CONVERT(VARCHAR(11),TAA.For_date,103) as For_date 
				,right(convert(varchar,TAA.For_date),7) as From_Time
				,TAA.Description
				,TAA.Amount as Amount
				,case when TAA.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pay  
				,isnull(tam.From_Place,Tam.Pick_Up_Address) as 'From Place',isnull(TAM.To_Place,Tam.Drop_Address) as 'To Place'
				,tam.Pick_Up_Time
				,tam.Booking_Date,Tam.No_Passenger
				,TAM.City
				from T0130_Travel_Approval_Other_Detail as TAA WITH (NOLOCK)
				inner join T0130_Travel_Approval_Other_Mode_Detail TAM WITH (NOLOCK) on TAM.Travel_Approval_ID=taa.Travel_Approval_ID
				 inner join T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) on TA.Travel_Approval_ID =TAA.Travel_Approval_ID
				 --inner join T0140_Travel_Settlement_Application TSA ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id
				 --inner join  
				 --inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID 
				 inner join T0080_Emp_Master e WITH (NOLOCK) on TA.Emp_ID = e.emp_ID 
				 INNER JOIN dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK) ON TM.Travel_Mode_ID = TAA.Travel_Mode_ID 
				 left join T0040_CURRENCY_MASTER CRM WITH (NOLOCK) on CRM.Curr_ID=TAA.Curr_ID and CRM.Cmp_ID=TAA.Cmp_ID
				 where TA.Cmp_ID=@Cmp_ID and TA.Travel_Approval_ID=@Travel_Approval_ID
	end
	end
END
return
