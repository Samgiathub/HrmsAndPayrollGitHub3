






CREATE VIEW [dbo].[V0200_Emp_EXITAPPLICATION]
AS
		--SELECT     x.exit_id, e.Alpha_Emp_Code, x.resignation_date, x.sup_ack, x.status, e.Emp_Full_Name, x.last_date, B.Branch_ID, B.Vertical_ID, B.SubVertical_ID, B.Dept_ID, 
		--                      x.emp_id, x.interview_date, x.interview_time, x.Is_Process,B.Cmp_ID
		--FROM         dbo.T0200_Emp_ExitApplication AS x INNER JOIN
		--                      dbo.T0080_EMP_MASTER AS e ON x.emp_id = e.Emp_ID AND x.cmp_id = e.Cmp_ID INNER JOIN
		--                          (SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID, Dept_ID
		--                            FROM          dbo.T0095_INCREMENT AS I
		--                            WHERE      (Increment_ID =
		--                                                       (SELECT     TOP (1) Increment_ID
		--                                                         FROM          dbo.T0095_INCREMENT AS I1
		--                                                         WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)
		--                                                         ORDER BY Increment_Effective_Date DESC, Increment_ID DESC))) AS B ON B.Emp_ID = e.Emp_ID AND B.Cmp_ID = e.Cmp_ID
	
	--Added By Jaina 03-06-2016
 	Select distinct E.exit_id,E.emp_id,B.cmp_id,B.branch_id,B.desig_id,E.resignation_date,
					E.last_date,E.reason,E.comments,E.status,E.is_rehirable,Isnull(E.s_emp_id,0)as s_emp_id,'Admin' as Emp_Superior,
					E.feedback,E.sup_ack,E.interview_date,E.Rpt_Mng_ID,
					E.interview_time,E.Is_process,Email_ForwardTo,DriveData_ForwardTo,EM.Emp_Full_Name ,EM.Alpha_Emp_Code,
					E.Application_date,GETDATE() as Approval_date,B.Vertical_ID, B.SubVertical_ID, B.Dept_ID,  --Added By Jaina 11-05-2016
					BM.Branch_Name,D.Desig_Name,Exit_App_Doc -- Exit_App_Doc Added by rajput on 14052018 
			From T0200_Emp_ExitApplication as E WITH (NOLOCK)
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = E.emp_id
						INNER JOIN
						(SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID, Dept_ID,Desig_Id
		                 FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK)
		                 WHERE      (Increment_ID =       (SELECT     TOP (1) Increment_ID
		                                                         FROM          dbo.T0095_INCREMENT AS I1 WITH (NOLOCK)
		                                                         WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)
		                                                         ORDER BY Increment_Effective_Date DESC, Increment_ID DESC)
		                                                    )
		                ) AS B ON B.Emp_ID = EM.Emp_ID AND B.Cmp_ID = EM.Cmp_ID
		                INNER JOIN T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.Desig_ID = B.Desig_Id
		                INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = B.Branch_ID
		                                                 
						


