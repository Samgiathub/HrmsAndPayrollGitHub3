

CREATE VIEW [dbo].[View_Att_mansi]
AS
SELECT   
       LAD.IO_Tran_Id, LAD.Emp_ID, LAD.For_Date, 
			--LAD.In_Time
			isnull(qry.In_Time, lad.In_Time) AS In_Time
			, LAD.Reason, LAD.Cmp_ID
			, LAD.Branch_ID, LAD.App_Date
				, LAD.Emp_code, LAD.Emp_Full_Name, 
                      LAD.Alpha_Emp_Code, LAD.Alpha_Code, lad.Chk_By_Superior, LAD.Half_Full_day, LAD.Sup_Comment
					  , LAD.Emp_Name, LAD.Is_Cancel_Late_In, 
                      LAD.Is_Cancel_Early_Out, 
					  --LAD.Out_Time
					  isnull(qry.Out_Time,lad.Out_Time) as Out_Time
					  --,qry.Out_Time as OT1
					  , LAD.Superior, qry.S_Emp_Id AS S_Emp_ID_A
                      ,LAD.Other_Reason,LAD.Actual_In_Time,LAD.Actual_Out_Time  --Added By Jimit 03082018
FROM         dbo.View_Late_Emp AS LAD WITH (NOLOCK) INNER JOIN
                          (SELECT     lla.IO_Tran_ID, lla.S_Emp_Id, lla.Chk_By_Superior
							, lla.In_Time, lla.Out_Time
                            FROM          dbo.T0115_AttendanceRegu_Level_Approval AS lla WITH (NOLOCK) 
							INNER JOIN
                                                       (SELECT    MAX(Rpt_Level) AS Rpt_Level, IO_Tran_ID
                                                         FROM          dbo.T0115_AttendanceRegu_Level_Approval WITH (NOLOCK) 
                                                         GROUP BY IO_Tran_ID) AS Qry_1 
													ON Qry_1.Rpt_Level = lla.Rpt_Level AND Qry_1.IO_Tran_ID = lla.IO_Tran_ID 
														 INNER JOIN
                                                   dbo.View_Late_Emp AS LA WITH (NOLOCK) ON LA.IO_Tran_Id = lla.IO_Tran_ID
                            WHERE      (lla.Chk_By_Superior = 1) OR
                                                   (lla.Chk_By_Superior = 0) OR
                                                   (lla.Chk_By_Superior = 2)) AS qry 
												   ON LAD.IO_Tran_Id = qry.IO_Tran_ID -- and lad.Chk_By_Superior=qry.Chk_By_Superior
												  
												    
