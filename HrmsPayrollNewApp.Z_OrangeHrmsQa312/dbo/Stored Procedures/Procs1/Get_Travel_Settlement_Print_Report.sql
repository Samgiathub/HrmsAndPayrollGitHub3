
---------Created by Sumit For Genrating PDF in Travel Settlement Application 04082015------------------------------------------------------
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-------------------------------------------------------------
CREATE PROCEDURE [dbo].[Get_Travel_Settlement_Print_Report]
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

BEGIN
	if @Flag_ds=0
		Begin
		 if @is_foreign =0
			Begin	
				select distinct TSA.*,Em.Alpha_Emp_Code,Em.Emp_Full_Name,
				Cm.Cmp_Address,Cm.Cmp_Name,--cm.cmp_logo,
				dm.Dept_Name,dsm.Desig_Name,bm.Branch_Name,
				TA.*,sm.State_Name,CITYM.City_Name,Emp_Instruct.Emp_Full_Name as Instruct_Emp,--TAA.*
				--,case when TAO.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pays,TAO.*,TM.Travel_Mode_Name
				TRA.*,LM.Leave_Name
				,isnull(FSM.State_Name,'') as From_State_Name,isnull(FCTM.City_Name,'') as From_City_Name
				,isnull(RM.Reason_Name ,'') as Reason_Name
				 from T0140_Travel_Settlement_Application TSA WITH (NOLOCK)
				inner Join T0080_Emp_Master Em WITH (NOLOCK) on Em.Emp_ID=TSA.emp_id
				inner join T0010_COMPANY_MASTER Cm WITH (NOLOCK) on Cm.Cmp_Id=TSA.cmp_id
				
				--left join T0130_TRAVEL_APPROVAL_ADVDETAIL TAA on TAA.Travel_Approval_ID=TA.Travel_Approval_ID
				--left join T0130_Travel_Approval_Other_Detail TAO on TAO.Travel_Approval_ID=TA.Travel_Approval_ID
				--inner join T0030_TRAVEL_MODE_MASTER TM on TM.Travel_Mode_ID=TAO.Travel_Mode_Id and TAO.Cmp_ID=TM.Cmp_ID
				
				inner join
				( select Grd_ID,Emp_ID,Dept_ID,Desig_Id,Branch_ID From T0095_Increment I WITH (NOLOCK)
				where	i.Increment_ID =
				(select top 1 Increment_ID
				from T0095_INCREMENT i1 WITH (NOLOCK)
				where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
				and Increment_Effective_date <= @To_Date
				order by Increment_Effective_Date desc, Increment_ID desc)
				) Qry on Qry.Emp_ID=TSA.emp_id
				left join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on dm.Dept_Id=Qry.Dept_ID
				left Join T0030_BRANCH_MASTER Bm WITH (NOLOCK) on Bm.Branch_ID=qry.branch_ID
				left join T0040_DESIGNATION_MASTER Dsm WITH (NOLOCK) on Dsm.Desig_ID=Qry.Desig_Id
				left join T0130_TRAVEL_APPROVAL_DETAIL TA WITH (NOLOCK) on TA.Travel_Approval_ID=TSA.Travel_Approval_ID
				left join T0120_TRAVEL_APPROVAL TRA WITH (NOLOCK) on TRA.Travel_Approval_ID=TA.Travel_Approval_ID and TA.Cmp_ID=TRA.Cmp_ID
				left join T0020_State_master sm WITH (NOLOCK) on Sm.State_ID=Ta.State_ID AND SM.Cmp_ID=tA.Cmp_ID
				left JOIN T0030_CITY_MASTER CITYM WITH (NOLOCK) on CITYM.City_ID=TA.City_ID and CITYM.Cmp_ID=TA.Cmp_ID
				left join T0080_EMP_MASTER Emp_Instruct WITH (NOLOCK) on Emp_Instruct.Emp_ID=TA.Instruct_Emp_ID
				left join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=TA.Leave_ID and LM.Cmp_ID=TA.Cmp_ID
				left JOIN T0040_Reason_Master RM WITH (NOLOCK) on RM.Res_Id = TA.Reason_ID
				left join t0020_State_Master FSM WITH (NOLOCK) on FSM.State_ID=TA.From_State_id
				left join T0030_CITY_MASTER FCTM WITH (NOLOCK) on FCTM.City_ID=TA.From_City_id
				where cm.Cmp_ID=@Cmp_ID and Travel_Set_Application_id=@Travel_App_ID
			End
		Else
			Begin
			
				select distinct TSA.*,Em.Alpha_Emp_Code,Em.Emp_Full_Name,
				Cm.Cmp_Address,Cm.Cmp_Name,--cm.cmp_logo,
				dm.Dept_Name,dsm.Desig_Name,bm.Branch_Name,
				TA.*,--sm.State_Name,--
				LM_1.Loc_Name,
				Emp_Instruct.Emp_Full_Name as Instruct_Emp,--TAA.*
				
				TRA.*,LM.Leave_Name				
				 from T0140_Travel_Settlement_Application TSA WITH (NOLOCK)
				inner Join T0080_Emp_Master Em WITH (NOLOCK) on Em.Emp_ID=TSA.emp_id
				inner join T0010_COMPANY_MASTER Cm WITH (NOLOCK) on Cm.Cmp_Id=TSA.cmp_id
				inner join T0130_TRAVEL_APPROVAL_DETAIL TA WITH (NOLOCK) on TA.Travel_Approval_ID=TSA.Travel_Approval_ID
				inner join T0120_TRAVEL_APPROVAL TRA WITH (NOLOCK) on TRA.Travel_Approval_ID=TA.Travel_Approval_ID and TA.Cmp_ID=TRA.Cmp_ID
				--inner join T0020_State_master sm on Sm.State_ID=Ta.State_ID AND SM.Cmp_ID=tA.Cmp_ID
				INNER JOIN T0001_LOCATION_MASTER LM_1 WITH (NOLOCK) on LM_1.Loc_ID=TA.Loc_ID --and CM.Cmp_ID=TA.Cmp_ID
				inner join T0080_EMP_MASTER Emp_Instruct WITH (NOLOCK) on Emp_Instruct.Emp_ID=TA.Instruct_Emp_ID			
				left join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=TA.Leave_ID and LM.Cmp_ID=TA.Cmp_ID
				inner join
				( select Grd_ID,Emp_ID,Dept_ID,Desig_Id,Branch_ID From T0095_Increment I WITH (NOLOCK) 
				where	i.Increment_ID =
				(select top 1 Increment_ID
				from T0095_INCREMENT i1 WITH (NOLOCK)
				where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
				and Increment_Effective_date <= @To_Date
				order by Increment_Effective_Date desc, Increment_ID desc)
				) Qry on Qry.Emp_ID=TSA.emp_id
				left join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on dm.Dept_Id=Qry.Dept_ID
				left Join T0030_BRANCH_MASTER Bm WITH (NOLOCK) on Bm.Branch_ID=qry.branch_ID
				left join T0040_DESIGNATION_MASTER Dsm WITH (NOLOCK) on Dsm.Desig_ID=Qry.Desig_Id
				where cm.Cmp_ID=@Cmp_ID and Travel_Set_Application_id=@Travel_App_ID
			End	
	End

--select * from T0130_Travel_Approval_Other_Detail where Cmp_ID=55 and Travel_Approval_ID=268
if @Flag_ds=1
Begin
	 --if @is_foreign =0
		--	Begin	
				Select distinct TAD.*
				 ,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name
				 --,Cmp_Name,Cmp_Address 
				 --,@From_Date as From_Date,@To_Date as To_Date
				,TAA.Travel_Approval_ID as TAA_Approval_Id,TAA.travel_mode_id as TAA_travel_mode_id,
				TAA.Description,TAA.Amount as Amount,
				case when TAA.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pay  
				,CONVERT(VARCHAR(11),TAA.For_date,103) as For_date 
				,right(convert(varchar,TAA.For_date),7) as From_Time
				,TM.Travel_mode_name,
				CRM.Curr_Symbol,CRM.Curr_Name
				from T0130_Travel_Approval_Other_Detail as TAA WITH (NOLOCK)
				 inner join T0140_Travel_Settlement_Application TAD WITH (NOLOCK) on TAD.Travel_Approval_ID =TAA.Travel_Approval_ID
				 --inner join T0140_Travel_Settlement_Application TSA ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id
				 --inner join  
				 --inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID 
				 inner join T0080_Emp_Master e WITH (NOLOCK) on TAD.Emp_ID = e.emp_ID 
				 INNER JOIN dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK) ON TM.Travel_Mode_ID = TAA.Travel_Mode_ID 
				 left join T0040_CURRENCY_MASTER CRM WITH (NOLOCK) on CRM.Curr_ID=TAA.Curr_ID and CRM.Cmp_ID=TAA.Cmp_ID
				 where TAD.Cmp_ID=@Cmp_ID and TAD.Travel_Approval_ID=@Travel_Approval_ID
			--End
	--Else
	--	Begin
			
	--	End		
 End   
 if @Flag_ds=2
 Begin
	 --Select distinct TAD.*,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name
	 --    ,Cmp_Name,Cmp_Address
		--,TSAE.*,TSAE.Amount as Expense_Amount
		--,ETM.Expense_Type_name,Etm.Expense_Type_Group,
		--CRM.Curr_Symbol,CRM.Curr_Name,
		--case when CRM.Curr_Major='Y' then Limit_Amount 
		--Else Limit_Amount * Exchange_Rate End as Limit_Amt_Rs		
		
  --       from T0140_Travel_Settlement_Application TAD 
  --       inner join T0140_Travel_Settlement_Application TSA ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id
  --       --inner Join T0130_TRAVEL_APPROVAL_DETAIL TAD1 ON TSA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TSA.Cmp_id =TAD1.Cmp_id
  --       inner Join T0140_Travel_Settlement_Expense as TSAE on TAD.Travel_Approval_ID =TSAE.Travel_Approval_Id and tad.emp_id = TSAE.Emp_ID          
  --       left join T0040_CURRENCY_MASTER CRM on CRM.Curr_ID=TSAE.Curr_ID --and CRM.Cmp_ID=TSAE.Cmp_ID
  --       inner join T0080_Emp_Master e on TAD.Emp_ID = e.emp_ID 
  --       inner join T0010_Company_Master CM on TAD.Cmp_ID= CM.CMP_ID
  --       inner join
		--			( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I inner join 
		--					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 10092014 for Same Date Increment
		--					where Increment_Effective_date <= @To_Date --'05-Aug-2015'
		--					and Cmp_ID = @Cmp_ID
		--					group by emp_ID  ) Qry on
		--					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
		--				on E.Emp_ID = I_Q.Emp_ID  
						
		--left Join T0040_Expense_Type_Master ETM on TSAE.Expense_Type_id=ETM.Expense_Type_ID
		
		--where TSA.Cmp_ID=@Cmp_ID and TSA.Travel_Approval_ID=@Travel_Approval_ID
		 Select distinct TAD.*,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name
	     ,Cmp_Name,Cmp_Address
		,TSAE.*,TSAE.Amount as Expense_Amount
		,ETM.Expense_Type_name,Etm.Expense_Type_Group,
		CRM.Curr_Symbol,CRM.Curr_Name,
		case when CRM.Curr_Major='Y' then Limit_Amount 
		Else Limit_Amount * Exchange_Rate End as Limit_Amt_Rs,CRM.Curr_Major			
		--,(select top 1 curr_rate from t0180_Currency_Conversion
		-- where-- CURR_ID= TSAE.Curr_ID 
		-- Curr_id in (select Curr_ID from T0040_CURRENCY_MASTER where Curr_Symbol = '$')
		--Added by Jaina 25-10-2017
		,(select top 1 isnull(c.Curr_Rate,0) 
		  from t0180_Currency_Conversion C WITH (NOLOCK) LEFT OUTER JOIN 
				T0040_CURRENCY_MASTER CM WITH (NOLOCK) ON C.CURR_ID = CM.Curr_ID
		  where CM.CURR_ID= TSAE.Curr_ID  AND
				CM.Curr_id in (select C.Curr_ID 
								from T0040_CURRENCY_MASTER C WITH (NOLOCK) where C.Cmp_ID=@Cmp_id)
		 and  FOR_DATE <= TAD.For_Date  
		 order by FOR_DATE desc)
		New_Ex_Rate
         from T0140_Travel_Settlement_Application TAD WITH (NOLOCK)
         --inner join T0140_Travel_Settlement_Application TSA ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id
         --inner Join T0130_TRAVEL_APPROVAL_DETAIL TAD1 ON TSA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TSA.Cmp_id =TAD1.Cmp_id
         inner Join T0140_Travel_Settlement_Expense as TSAE WITH (NOLOCK) on TAD.Travel_Approval_ID =TSAE.Travel_Approval_Id and tad.emp_id = TSAE.Emp_ID
         and TSAE.Travel_Set_Application_id=TAD.Travel_Set_Application_id          
         left join T0040_CURRENCY_MASTER CRM WITH (NOLOCK) on CRM.Curr_ID=TSAE.Curr_ID --and CRM.Cmp_ID=TSAE.Cmp_ID
         
         inner join T0080_Emp_Master e WITH (NOLOCK) on TAD.Emp_ID = e.emp_ID 
         inner join T0010_Company_Master CM WITH (NOLOCK) on TAD.Cmp_ID= CM.CMP_ID
         inner join
					( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
							where Increment_Effective_date <= @To_Date --'05-Aug-2015'
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  
						
		left Join T0040_Expense_Type_Master ETM WITH (NOLOCK) on TSAE.Expense_Type_id=ETM.Expense_Type_ID
		
		where TAD.Cmp_ID=@Cmp_ID 
		--and TSA.Travel_Approval_ID=@Travel_Approval_ID
		and TAD.Travel_Set_Application_id=@Travel_App_ID and TAD.emp_id=@Emp_ID
		
 End
if @Flag_ds=3
 Begin
	 declare @ex_rate as numeric(18,2)
	
	--select distinct ADV.Travel_Approval_AdvDetail_ID,ADV.Travel_Approval_ID,ADV.Cmp_ID,ADV.Expence_Type,
	-- ADv.Amount,isnull(ADv.Amount_Dollar,ADv.Amount) as Amount_Dollar,  --Change by Jaina 07-10-2017
	-- ADV.adv_detail_desc,ADV.Curr_ID
	-- ,CRM.Curr_Symbol,CRM.Curr_Name from T0130_TRAVEL_APPROVAL_ADVDETAIL ADV
	-- inner join T0120_TRAVEL_APPROVAL TA on TA.Travel_Approval_ID=ADv.Travel_Approval_ID	 
	-- and TA.Cmp_ID=ADV.Cmp_ID
	-- left join T0040_CURRENCY_MASTER CRM on CRM.Curr_ID=ADV.Curr_ID and CRM.Cmp_ID=ADV.Cmp_ID
	-- where TA.Cmp_ID=@Cmp_ID and ADV.Travel_Approval_ID=@Travel_Approval_ID
--	 select * from T0120_TRAVEL_APPROVAL
--select * from T0150_Travel_Settlement_Approval_Expense
--select * from T0150_Travel_Settlement_Approval
	  Select  ETM.Expense_Type_name,SUM(TSAE.Amount)Approved_Amount,TAD.Travel_Approval_ID
		 from T0140_Travel_Settlement_Application TAD WITH (NOLOCK)
         inner Join T0140_Travel_Settlement_Expense as TSAE WITH (NOLOCK) on TAD.Travel_Approval_ID =TSAE.Travel_Approval_Id and tad.emp_id = TSAE.Emp_ID
         left Join T0040_Expense_Type_Master ETM WITH (NOLOCK) on TSAE.Expense_Type_id=ETM.Expense_Type_ID and TSAE.Cmp_ID=ETM.CMP_ID
        -- inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID 
         where TAD.Cmp_ID = @Cmp_ID AND tad.Travel_Approval_ID=@Travel_Approval_ID
         GROUP BY Expense_Type_name,TAD.Travel_Approval_ID
 End 
END
return
