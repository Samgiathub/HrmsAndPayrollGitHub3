CREATE Procedure [dbo].[RPT_Grievance_Register_Customize_Report]
@Cmp_ID as int,
@From_Date as Datetime,
@To_Date as Datetime,
@Type as int,
@IsEmp as varchar(10) ='',
@Const as varchar(max) = ''

As
Begin

-- Created by ronakk 30042022


Declare @GrievRegi as table
(
     [SRNO] int 
	,[Case No] nvarchar(100)
	,[Application Done by] nvarchar(1000)
	,[Application From (EMP Code/Other)]  nvarchar(1000)
	,[Applicant Name] nvarchar(1000)
	,[Applicant Branch] nvarchar(1000)
	,[Applicant Sub Branch]  nvarchar(1000)
	,[Against Person(EMP Code/Other)]  nvarchar(1000)
	,[Against Person Name] nvarchar(1000)
	,[Against Person Branch] nvarchar(1000)
	,[Against Person Sub Branch] nvarchar(1000)
	,[Type of Grievance] nvarchar(1000)
	,[Date of Reporting Grievance]  nvarchar(1000)
	,[Enquiry Committee] nvarchar(1000)
	,[Enquiry Committee Office Order] nvarchar(1000)
	,[Nodel HR] nvarchar(1000)
	,[Chair Person] nvarchar(1000)
	,[Date of Enquiry] nvarchar(1000)
	,[TAT] int
	,[Hearing TAT] int
	,[Brief Description of Grievance] nvarchar(3000)
	,[Status] nvarchar(1000)

)    





if @Type =0 
Begin
--All Details Go with columns depend Date


						insert into @GrievRegi
						select   ROW_NUMBER() OVER (order by GHH.Last_HearingDate desc) SRNO,
						
						GA.App_No as [Case No]
						,isnull(EMPL.Emp_Full_Name_new,LD.Login_Name) as [Application Done by]
						
						,case when GA.Emp_IDF is not null then EMPF.Alpha_Emp_Code 
						when GA.Emp_IDF is null then 'Other'
						end as [Application From (EMP Code/Other)]
						
						,case when GA.Emp_IDF is not null then EMPF.Emp_Full_Name 
						when GA.Emp_IDF is null then GA.NameF
						end as [Applicant Name]
						
						,case when GA.Emp_IDF is not null then isnull(EMPF.Branch_Name,'-')
						when GA.Emp_IDF is null then '-'
						end as [Applicant Branch]
						
						,case when GA.Emp_IDF is not null then isnull(EMPF.SubBranch_Name,'-')
						when GA.Emp_IDF is null then GA.AddressF
						end as [Applicant Sub Branch]
						
						
						,case when GA.Emp_IDT is not null then EMPT.Alpha_Emp_Code 
						when GA.Emp_IDT is null then 'Other'
						end as [Against Person(EMP Code/Other)]
						
						,case when GA.Emp_IDT is not null then EMPT.Emp_Full_Name 
						when GA.Emp_IDT is null then GA.NameT
						end as [Against Person Name]
						
						,case when GA.Emp_IDT is not null then isnull(EMPT.Branch_Name,'-')
						when GA.Emp_IDT is null then '-'
						end as [Against Person Branch]
						
						,case when GA.Emp_IDT is not null then isnull(EMPT.SubBranch_Name,'-')
						when GA.Emp_IDT is null then GA.AddressT
						end as [Against Person Sub Branch]
						
						,GTM.GrievanceTypeTitle as [Type of Grievance]
						,Format(GA.CreatedDate,'dd-MM-yyyy') as [Date of Reporting Grievance]
						,GCM.CommMemText as [Enquiry Committee]
						,GCM.Com_Name as [Enquiry Committee Office Order]
						,EMPNHR.Emp_Full_Name_new AS [Nodel HR]
						,EMPCP.Emp_Full_Name_new as [Chair Person]
						,Format(GHH.Last_HearingDate,'dd-MM-yyyy HH:MM') as [Date of Enquiry]
						,DATEDIFF(DAY ,GA.CreatedDate,GETDATE()) as [TAT]
						,DATEDIFF(DAY ,GHH.Last_HearingDate,GETDATE()) as [Hearing TAT]
						,GHH.GHHComments as [Brief Description of Grievance]
						,GSC.S_Name as [Status]
						
						
						from T0080_Griev_Hearing_History GHH
						left join T0080_Griev_Application_Allocation GAA on GAA.G_Allocation_ID = GHH.G_AllocationID
						left join T0080_Griev_Application GA on GA.GA_ID = GAA.GrievAppID
						left join V0080_Employee_Master EMPF on EMPF.Emp_ID = GA.Emp_IDF
						left join V0080_Employee_Master EMPT on EMPT.Emp_ID = GA.Emp_IDT
						join T0011_LOGIN LD on LD.Login_ID = GA.[User ID]
						left join V0080_Employee_Master EMPL on EMPL.Emp_ID = LD.Emp_ID
						join T0040_Grievance_Type_Master GTM on GTM.GrievanceTypeID = GAA.Griev_TypeID
						join T0040_Griev_Committee_Master GCM on GCM.GC_ID =GAA.CommitteeID
						left join V0080_Employee_Master EMPCP on EMPCP.Emp_ID = GCM.Chairperson_id
						left join V0080_Employee_Master EMPNHR on EMPNHR.Emp_ID = GCM.NodelHR_id
						join T0030_Griev_Status_Common GSC on GSC.S_ID = GHH.G_StatusID
						where GA.Cmp_ID =@Cmp_ID and (GHH.Last_HearingDate between @From_Date and @To_Date)
						order by GHH.Last_HearingDate desc





select * from @GrievRegi

End
else if @Type =1
Begin

				if @IsEmp ='1'
				Begin
				
				       	                select  EMPF.Emp_ID,EMPF.Alpha_Emp_Code,EMPF.Emp_Full_Name,EMPF.Mobile_No
										from T0080_Griev_Hearing_History GHH
										left join T0080_Griev_Application_Allocation GAA on GAA.G_Allocation_ID = GHH.G_AllocationID
										left join T0080_Griev_Application GA on GA.GA_ID = GAA.GrievAppID
									    join V0080_Employee_Master EMPF on EMPF.Emp_ID = GA.Emp_IDF
										where GA.Cmp_ID =@Cmp_ID and (GHH.Last_HearingDate between @From_Date and @To_Date)
										order by GHH.Last_HearingDate desc
				end
				else
				begin
				
										select   ROW_NUMBER() OVER (order by GHH.Last_HearingDate desc) SRNO,
										
										GA.App_No as [Case No]
										,isnull(EMPL.Emp_Full_Name_new,LD.Login_Name) as [Application Done by]
										
										,case when GA.Emp_IDF is not null then EMPF.Alpha_Emp_Code 
										when GA.Emp_IDF is null then 'Other'
										end as [Application From (EMP Code/Other)]
										
										,case when GA.Emp_IDF is not null then EMPF.Emp_Full_Name 
										when GA.Emp_IDF is null then GA.NameF
										end as [Applicant Name]
										
										,case when GA.Emp_IDF is not null then isnull(EMPF.Branch_Name,'-')
										when GA.Emp_IDF is null then '-'
										end as [Applicant Branch]
										
										,case when GA.Emp_IDF is not null then isnull(EMPF.SubBranch_Name,'-')
										when GA.Emp_IDF is null then GA.AddressF
										end as [Applicant Sub Branch]
										
										
										,case when GA.Emp_IDT is not null then EMPT.Alpha_Emp_Code 
										when GA.Emp_IDT is null then 'Other'
										end as [Against Person(EMP Code/Other)]
										
										,case when GA.Emp_IDT is not null then EMPT.Emp_Full_Name 
										when GA.Emp_IDT is null then GA.NameT
										end as [Against Person Name]
										
										,case when GA.Emp_IDT is not null then isnull(EMPT.Branch_Name,'-')
										when GA.Emp_IDT is null then '-'
										end as [Against Person Branch]
										
										,case when GA.Emp_IDT is not null then isnull(EMPT.SubBranch_Name,'-')
										when GA.Emp_IDT is null then GA.AddressT
										end as [Against Person Sub Branch]
										
										,GTM.GrievanceTypeTitle as [Type of Grievance]
										,Format(GA.CreatedDate,'dd-MM-yyyy') as [Date of Reporting Grievance]
										,GCM.CommMemText as [Enquiry Committee]
										,GCM.Com_Name as [Enquiry Committee Office Order]
										,EMPNHR.Emp_Full_Name_new AS [Nodel HR]
										,EMPCP.Emp_Full_Name_new as [Chair Person]
										,Format(GHH.Last_HearingDate,'dd-MM-yyyy HH:MM') as [Date of Enquiry]
										,DATEDIFF(DAY ,GA.CreatedDate,GETDATE()) as [TAT]
										,DATEDIFF(DAY ,GHH.Last_HearingDate,GETDATE()) as [Hearing TAT]
										,GHH.GHHComments as [Brief Description of Grievance]
										,GSC.S_Name as [Status]
										
										
										from T0080_Griev_Hearing_History GHH
										left join T0080_Griev_Application_Allocation GAA on GAA.G_Allocation_ID = GHH.G_AllocationID
										left join T0080_Griev_Application GA on GA.GA_ID = GAA.GrievAppID
										left join V0080_Employee_Master EMPF on EMPF.Emp_ID = GA.Emp_IDF
										left join V0080_Employee_Master EMPT on EMPT.Emp_ID = GA.Emp_IDT
										join T0011_LOGIN LD on LD.Login_ID = GA.[User ID]
										left join V0080_Employee_Master EMPL on EMPL.Emp_ID = LD.Emp_ID
										join T0040_Grievance_Type_Master GTM on GTM.GrievanceTypeID = GAA.Griev_TypeID
										join T0040_Griev_Committee_Master GCM on GCM.GC_ID =GAA.CommitteeID
										left join V0080_Employee_Master EMPCP on EMPCP.Emp_ID = GCM.Chairperson_id
										left join V0080_Employee_Master EMPNHR on EMPNHR.Emp_ID = GCM.NodelHR_id
										join T0030_Griev_Status_Common GSC on GSC.S_ID = GHH.G_StatusID
										where GA.Cmp_ID =@Cmp_ID and (GHH.Last_HearingDate between @From_Date and @To_Date)
										and EMPF.Emp_ID in  (select cast(data  as numeric) from dbo.Split (@Const,'#')  T Where T.Data <> '' )
										order by GHH.Last_HearingDate desc
				
				
				
				end

End
else if @Type =2
Begin
                 
				 if @IsEmp='1'
				 Begin

							select  EMPT.Emp_ID,EMPT.Alpha_Emp_Code,EMPT.Emp_Full_Name,EMPT.Mobile_No
										from T0080_Griev_Hearing_History GHH
										left join T0080_Griev_Application_Allocation GAA on GAA.G_Allocation_ID = GHH.G_AllocationID
										left join T0080_Griev_Application GA on GA.GA_ID = GAA.GrievAppID
										join V0080_Employee_Master EMPT on EMPT.Emp_ID = GA.Emp_IDT
										where GA.Cmp_ID =@Cmp_ID and (GHH.Last_HearingDate between @From_Date and @To_Date)
										order by GHH.Last_HearingDate desc



				 End
				 else
				 Begin
							
							select   ROW_NUMBER() OVER (order by GHH.Last_HearingDate desc) SRNO,
										
										GA.App_No as [Case No]
										,isnull(EMPL.Emp_Full_Name_new,LD.Login_Name) as [Application Done by]
										
										,case when GA.Emp_IDF is not null then EMPF.Alpha_Emp_Code 
										when GA.Emp_IDF is null then 'Other'
										end as [Application From (EMP Code/Other)]
										
										,case when GA.Emp_IDF is not null then EMPF.Emp_Full_Name 
										when GA.Emp_IDF is null then GA.NameF
										end as [Applicant Name]
										
										,case when GA.Emp_IDF is not null then isnull(EMPF.Branch_Name,'-')
										when GA.Emp_IDF is null then '-'
										end as [Applicant Branch]
										
										,case when GA.Emp_IDF is not null then isnull(EMPF.SubBranch_Name,'-')
										when GA.Emp_IDF is null then GA.AddressF
										end as [Applicant Sub Branch]
										
										
										,case when GA.Emp_IDT is not null then EMPT.Alpha_Emp_Code 
										when GA.Emp_IDT is null then 'Other'
										end as [Against Person(EMP Code/Other)]
										
										,case when GA.Emp_IDT is not null then EMPT.Emp_Full_Name 
										when GA.Emp_IDT is null then GA.NameT
										end as [Against Person Name]
										
										,case when GA.Emp_IDT is not null then isnull(EMPT.Branch_Name,'-')
										when GA.Emp_IDT is null then '-'
										end as [Against Person Branch]
										
										,case when GA.Emp_IDT is not null then isnull(EMPT.SubBranch_Name,'-')
										when GA.Emp_IDT is null then GA.AddressT
										end as [Against Person Sub Branch]
										
										,GTM.GrievanceTypeTitle as [Type of Grievance]
										,Format(GA.CreatedDate,'dd-MM-yyyy') as [Date of Reporting Grievance]
										,GCM.CommMemText as [Enquiry Committee]
										,GCM.Com_Name as [Enquiry Committee Office Order]
										,EMPNHR.Emp_Full_Name_new AS [Nodel HR]
										,EMPCP.Emp_Full_Name_new as [Chair Person]
										,Format(GHH.Last_HearingDate,'dd-MM-yyyy HH:MM') as [Date of Enquiry]
										,DATEDIFF(DAY ,GA.CreatedDate,GETDATE()) as [TAT]
										,DATEDIFF(DAY ,GHH.Last_HearingDate,GETDATE()) as [Hearing TAT]
										,GHH.GHHComments as [Brief Description of Grievance]
										,GSC.S_Name as [Status]
										
										
										from T0080_Griev_Hearing_History GHH
										left join T0080_Griev_Application_Allocation GAA on GAA.G_Allocation_ID = GHH.G_AllocationID
										left join T0080_Griev_Application GA on GA.GA_ID = GAA.GrievAppID
										left join V0080_Employee_Master EMPF on EMPF.Emp_ID = GA.Emp_IDF
										left join V0080_Employee_Master EMPT on EMPT.Emp_ID = GA.Emp_IDT
										join T0011_LOGIN LD on LD.Login_ID = GA.[User ID]
										left join V0080_Employee_Master EMPL on EMPL.Emp_ID = LD.Emp_ID
										join T0040_Grievance_Type_Master GTM on GTM.GrievanceTypeID = GAA.Griev_TypeID
										join T0040_Griev_Committee_Master GCM on GCM.GC_ID =GAA.CommitteeID
										left join V0080_Employee_Master EMPCP on EMPCP.Emp_ID = GCM.Chairperson_id
										left join V0080_Employee_Master EMPNHR on EMPNHR.Emp_ID = GCM.NodelHR_id
										join T0030_Griev_Status_Common GSC on GSC.S_ID = GHH.G_StatusID
										where GA.Cmp_ID =@Cmp_ID and (GHH.Last_HearingDate between @From_Date and @To_Date)
										and EMPT.Emp_ID  in  (select cast(data  as numeric) from dbo.Split (@Const,'#')  T Where T.Data <> '' )
										order by GHH.Last_HearingDate desc



				 End




End



End