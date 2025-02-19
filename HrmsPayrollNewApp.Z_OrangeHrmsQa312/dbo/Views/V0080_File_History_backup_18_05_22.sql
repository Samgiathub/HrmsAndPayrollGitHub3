

CREATE View [dbo].[V0080_File_History_backup_18_05_22]
As

	select distinct fh.FH_Id,fh.File_App_Id,fh.Emp_Id,fh.File_Apr_Id,em.Alpha_Emp_Code,em.Emp_Full_Name,
	format(fa.Application_Date,'dd/MM/yyyy') as Application_Date,EMSUP.Emp_Full_Name as Reporting_Manager,
	bm.Branch_Name,dm.Dept_Name,ds.Desig_Name,fh.H_F_StatusId,fh.H_F_TypeId,
	(CASE
    WHEN fh.H_Trans_Type='I' THEN 'Inserted'
    WHEN fh.H_Trans_Type='U' THEN 'Updated'
    ELSE 'Deleted' END)as Trans_Type,fsc.S_Name   as Status,ft.TypeTitle as FileType,
	fh.H_File_Number,fh.H_Subject,isnull(fh.H_Description,'')as H_Description,
	format(fa.Process_Date,'dd/MM/yyyy') as Process_Date,
	fa.Branch_Id,fa.Dept_Id,fa.Desig_Id,fa.S_Emp_Id,fh.Cmp_ID,
	--fh.H_File_App_Doc,
	isnull(stuff(fh.H_File_App_Doc, 1, charindex('#', fh.H_File_App_Doc), '') ,'')as FileName--added on 27-04-22
	,fh.H_File_App_Doc
	 ,isnull(FH.H_Forward_Emp_Id,0)as H_Forward_Emp_Id,isnull(FH.H_Submit_Emp_Id,0)as H_Submit_Emp_Id,
	 isnull(FH.H_Review_Emp_Id,0)as H_Review_Emp_Id,isnull(FH.H_Reviewed_by_Emp_Id,0)as H_Reviewed_by_Emp_Id,
	 isnull(fh.H_S_Emp_Id,0)as H_S_Emp_Id,fh.Rpt_Level,fh.H_Approval_Comments,fh.H_Tran_Id,
	 fh.H_Trans_Type,eapp.Emp_Full_Name as updatedbyEmp
	 ,format(fh.CreatedDate,'dd/MM/yyyy') as UpdatedDate,fh.tbl_type,lgapp.Emp_ID as updatedbyEmp_Id
	 ,fw_emp.Alpha_Emp_Code as fw_Emp_Code,fw_emp.Emp_Full_Name as FW_Emp,rw_emp.Alpha_Emp_Code  as rw_Emp_Code,
	 rw_emp.Emp_Full_Name as RW_Emp
		 -- qry.S_emp_ID AS S_Emp_ID_A,qry.S_emp_ID,qry.APR_Status as F_StatusId,
   --        qry.Rpt_Level AS Rpt_Level,qry.Approval_Comments AS Approval_Comments
		 --  ,qry.Tran_Id
		 -- 	,qry.Scheme_ID--added
			--,qry.UpdatedEmp as updatedbyEmp--added
			--,qry.Review_Emp_Id,qry.Reviewed_by_Emp_Id

			from T0115_File_Level_Approval_History FH
			inner join T0080_File_Application fa on fa.File_App_Id=FH.File_App_Id

			inner join T0080_EMP_MASTER as em on em.Emp_ID = fa.Emp_ID
			left join T0080_EMP_MASTER as EMSUP on EMSUP.Emp_ID = fa.S_Emp_Id
			left join T0030_BRANCH_MASTER as bm on bm.Branch_ID = fa.Branch_ID
			left join T0040_DEPARTMENT_MASTER as dm on dm.Dept_Id = fa.Dept_Id
			left join T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = fa.Desig_ID
			left join T0030_File_Status_Common as fsc on fsc.S_ID = fh.H_F_StatusId
			--left join T0030_File_Status_Common as fapc on fapc.S_ID = app.F_StatusId
			--left join T0040_File_Status_Master as fs on fs.F_StatusID = fa.F_StatusId
			left join T0040_File_Type_Master as ft on ft.F_TypeID = fh.H_F_TypeId
			left join T0011_LOGIN as lgapp on lgapp.Login_ID=fh.[User ID]
			left join T0080_EMP_MASTER as eapp on eapp.Emp_ID = lgapp.Emp_ID
				left join T0080_EMP_MASTER as fw_emp on fw_emp.Emp_ID = fh.H_Forward_Emp_Id
				left join T0080_EMP_MASTER as rw_emp on rw_emp.Emp_ID = fh.H_Review_Emp_Id



