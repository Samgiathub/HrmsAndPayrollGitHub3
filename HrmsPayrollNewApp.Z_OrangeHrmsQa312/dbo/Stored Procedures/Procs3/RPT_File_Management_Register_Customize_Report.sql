


CREATE Procedure [dbo].[RPT_File_Management_Register_Customize_Report]
@Cmp_ID as int,
@From_Date as Datetime,
@To_Date as Datetime,
--@Type as int,
@Const as varchar(max) = ''

As
Begin

-- Created by mansi 250822


--Declare @FileRegi as table
--(
--     [SRNO] int 
--	,[Case No] nvarchar(100)
--	,[Application Done by] nvarchar(1000)
--	,[Application From (EMP Code/Other)]  nvarchar(1000)
--	,[Applicant Name] nvarchar(1000)
--	,[Applicant Branch] nvarchar(1000)
--	,[Applicant Sub Branch]  nvarchar(1000)
--	,[Against Person(EMP Code/Other)]  nvarchar(1000)
--	,[Against Person Name] nvarchar(1000)
--	,[Against Person Branch] nvarchar(1000)
--	,[Against Person Sub Branch] nvarchar(1000)
--	,[Type of Grievance] nvarchar(1000)
--	,[Date of Reporting Grievance]  nvarchar(1000)
--	,[Enquiry Committee] nvarchar(1000)
--	,[Enquiry Committee Office Order] nvarchar(1000)
--	,[Nodel HR] nvarchar(1000)
--	,[Chair Person] nvarchar(1000)
--	,[Date of Enquiry] nvarchar(1000)
--	,[TAT] int
--	,[Hearing TAT] int
--	,[Brief Description of Grievance] nvarchar(3000)
--	,[Status] nvarchar(1000)

--)    





--if @Type =0 
Begin
--All Details Go with columns depend Date


						--insert into @FileRegi
						select  ROW_NUMBER() OVER (order by fapp.File_App_Id desc) SRNO
						--,fapp.File_App_Id as [File App Id]
						,isnull(ft.File_Type_Number,'') as [File Number],isnull(ft.TypeTitle,'') as [file Type],isnull(Format(ft.TypeCDTM,'dd-MM-yyyy'),'')as [File Created Date] 
						,( '="' + isnull(fapp.File_Number,'') + '"') as [Document Number],
						--,isnull(fapp.File_Number,'')as [Document Number],
						isnull(fh.Rpt_Level,'') as [Document Transaction Level Wise],--fh.H_Trans_Type,
						(CASE  WHEN fh.H_Trans_Type='I' THEN 'Inserted' WHEN fh.H_Trans_Type='U' THEN 'Updated' ELSE 'Deleted' END)as [Transaction Type],
						Format(fapp.CreatedDate,'dd-MM-yyyy HH:MM')as [Document Created Date] ,
						isnull(Format(fapp.UpdatedDate,'dd-MM-yyyy HH:MM'),'')as [Document Updated Date],
						isnull(fh.H_Subject,'')as [Subject],
						--lgcr.Login_Name,
						isnull(emcr.Emp_Full_Name,'admin')as [Document Created by Whom],
						isnull(em.Emp_Full_Name,'admin')as [Document Updated By Whom],
						fsc.S_Name   as [Document Status]
						--,lg.Login_Name,fh.[User ID],fh.H_F_StatusId,fh.Tbl_Type
						,'' as [Signature]
						from T0080_File_Application fapp
						inner join T0115_File_Level_Approval_History fh on fapp.File_App_Id=fh.File_App_Id
						
						left join T0040_File_Type_Master ft on ft.F_TypeID=fh.H_F_TypeId
						left join T0011_LOGIN lg on lg.Login_ID=fh.[User ID]
						left join T0030_File_Status_Common as fsc on fsc.S_ID = fh.H_F_StatusId
						left join T0080_EMP_MASTER as em on em.Emp_ID = lg.Emp_ID
					    left join T0011_LOGIN lgcr on lgcr.Login_ID=fapp.[User ID]
						left join T0080_EMP_MASTER as emcr on emcr.Emp_ID = lgcr.Emp_ID
						where fapp.Cmp_ID =@Cmp_ID and (fapp.CreatedDate between @From_Date and @To_Date)
						--order by fapp.CreatedDate  desc
						order by [File Number],[Document Number]




--select * from @FileRegi

End




End
