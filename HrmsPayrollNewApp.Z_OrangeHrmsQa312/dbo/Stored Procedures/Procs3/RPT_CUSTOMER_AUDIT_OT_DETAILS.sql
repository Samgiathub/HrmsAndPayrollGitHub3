


---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_CUSTOMER_AUDIT_OT_DETAILS]      
  @Cmp_ID    numeric      
 ,@From_Date   datetime      
 ,@To_Date    datetime       
 ,@Branch_ID   numeric      
 ,@Cat_ID    numeric       
 ,@Grd_ID    numeric      
 ,@Type_ID    numeric      
 ,@Dept_ID    numeric      
 ,@Desig_ID    numeric      
 ,@Emp_ID    numeric      
 ,@constraint   varchar(max)      
 ,@Return_Record_set numeric =1  
 ,@StrWeekoff_Date varchar(max) = ''     
 ,@PBranch_ID varchar(200) = '0'  
 ,@max_OTDaily numeric (18,2) = 0
 ,@max_OTMonthly numeric(18,2)  =0
 ,@Report_Type	tinyint = 0   -- Added by Gadriwala Muslim 30102015
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON        
         
Declare @Count   numeric       
Declare @Year_Start_Date datetime       
Declare @Year_End_Date datetime

set @Year_Start_Date = dbo.GET_YEAR_START_DATE(YEAR(@To_Date),Month(@To_Date),0)
  
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
        
 --IF @OT_Type = 'All'  --Added By Jaina 27-02-2016
--	set @OT_Type = NULL
   
   CREATE TABLE #Emp_OT_Setting_table
	(
	   cmp_ID numeric(18,0)
	  ,Branch_ID numeric(18,0)
	  ,Emp_ID numeric(18,0)
      ,Year_Start_Date	datetime
      ,Year_End_Date	datetime	
	)    
   
   
		Insert into #Emp_OT_Setting_table
				select @cmp_ID as cmp_ID,IE.Branch_ID,IE.Emp_ID,
				dbo.GET_YEAR_START_DATE(Year(@To_Date),month(@To_Date),GS.Validity_Period_Type),
				dbo.GET_YEAR_END_DATE(Year(@To_Date),month(@To_Date),GS.Validity_Period_Type)
				from T0080_EMP_MASTER EM WITH (NOLOCK) inner JOIN
				dbo.Split(@constraint,'#') SP ON SP.Data = EM.Emp_ID
				inner join T0095_Increment IE WITH (NOLOCK) on Em.Emp_ID = IE.Emp_ID Inner join
						(	
							select max(IEQ.Increment_Effective_Date) as Increment_Effective_Date,IEQ.Emp_ID  
							from T0095_INCREMENT IEQ WITH (NOLOCK)
							Inner join
								( select max(Increment_ID) as Increment_ID,IE_Qry.Emp_ID from T0095_Increment IE_Qry WITH (NOLOCK)
									where Cmp_ID = @cmp_ID group by Emp_ID,Increment_ID
								)Sub_Qry on sub_Qry.Increment_ID =IEQ.Increment_ID and sub_qry.Emp_ID = IEQ.Emp_ID
							where cmp_ID = @cmp_ID and  Increment_Effective_Date <= @To_Date  group by IEQ.Emp_ID								
						)Qry on Qry.Increment_Effective_Date = IE.Increment_Effective_Date and qry.Emp_ID = IE.Emp_ID
				inner join T0040_GENERAL_SETTING GS WITH (NOLOCK) on GS.Branch_ID = IE.Branch_ID Inner join 
						(
							select MAX(For_Date) as For_Date,Branch_ID from T0040_GENERAL_SETTING GS WITH (NOLOCK)
							where Cmp_ID = @cmp_ID and For_Date <= @To_Date Group by  Branch_ID
						)Qry_1 on Qry_1.Branch_ID = IE.Branch_ID and Qry_1.For_Date = GS.For_Date		
				where IE.Customer_Audit = 1 and IE.cmp_ID =@cmp_ID 
				
		
		--select * from #Emp_OT_Setting_table
		 select		OA.Emp_Id,OA.For_date,OA.Duration_in_sec,OA.Shift_ID,OA.Shift_Type,OA.Emp_OT,OA.Emp_OT_min_Limit,OA.Emp_OT_max_Limit,OA.P_days,
			 case when @max_OTDaily = 0 then OA.OT_Sec when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) else oa.OT_Sec end as OT_Sec   ,
			   E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
			  ,Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour ,
			  case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
			  E.Basic_Salary ,OA.Weekoff_OT_Sec,OA.Holiday_OT_Sec,
			  case when OA.WeekOFf_OT_Sec > 0 then dbo.F_Return_Hours(OA.WeekOff_OT_Sec) ELSE '00:00' END as Weekoff_OT_Hour, 
			  case when OA.Holiday_OT_Sec > 0 THEN dbo.F_Return_Hours(OA.Holiday_OT_Sec) ELSE '00:00' END as Holiday_OT_Hour,
			  DGM.Desig_Dis_No
			  ,case when OTA.Is_Approved = 1 then 'Approved' else  case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end end as OT_Status      
			  --, OTA.Comments,isnull(RM.Gate_Pass_Type,'-') as OT_Type
			  from T0010_Customer_Audit_Data   OA WITH (NOLOCK) 
				 inner JOIN			#Emp_OT_Setting_table EOT on  EOT.Emp_ID = OA.Emp_ID    
				 inner join			T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   
				 inner join			T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID AND E.Cmp_ID=SM.Cmp_ID 
				 inner join			T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID 
				 inner join			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I  WITH (NOLOCK)
				 inner join			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)  
									where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on    
									I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID  
				inner join			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
				LEFT OUTER JOIN		T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
				LEFT OUTER JOIN		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
				LEFT OUTER JOIN		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
				INNER JOIN			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
				Left OUTER JOIN	    T0160_OT_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date		
				--Left outer join     T0040_Reason_Master RM on RM.Res_Id = OTA.Reason_ID
				Where	
				(OA.OT_Sec > 0  or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0 )  and Is_Approved = 1   and 
									 OA.For_Date between EOT.Year_Start_Date AND EOT.Year_End_Date

									--and Isnull(RM.Gate_Pass_Type,'') = ISNULL(@OT_Type,isnull(RM.Gate_Pass_Type,''))  --Added By Jaina 27-02-2016    
				order by For_Date
			

   
RETURN      


