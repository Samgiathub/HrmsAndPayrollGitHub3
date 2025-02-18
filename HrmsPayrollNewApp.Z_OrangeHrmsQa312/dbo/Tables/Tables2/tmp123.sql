﻿CREATE TABLE [dbo].[tmp123] (
    [Sr_No]                         BIGINT          NULL,
    [emp_id]                        NUMERIC (18)    NULL,
    [for_Date]                      DATETIME        NULL,
    [Dept_id]                       NUMERIC (18)    NULL,
    [Grd_ID]                        NUMERIC (18)    NULL,
    [Type_ID]                       NUMERIC (18)    NULL,
    [Desig_ID]                      NUMERIC (18)    NULL,
    [Shift_ID]                      NUMERIC (18)    NULL,
    [In_Time]                       DATETIME        NULL,
    [Out_Time]                      DATETIME        NULL,
    [Duration]                      VARCHAR (20)    NULL,
    [Duration_sec]                  NUMERIC (18)    NULL,
    [Late_In]                       VARCHAR (20)    NULL,
    [Late_Out]                      VARCHAR (20)    NULL,
    [Early_In]                      VARCHAR (20)    NULL,
    [Early_Out]                     VARCHAR (20)    NULL,
    [Leave]                         VARCHAR (10)    NULL,
    [Shift_Sec]                     NUMERIC (18)    NULL,
    [Shift_Dur]                     VARCHAR (20)    NULL,
    [Total_work]                    VARCHAR (20)    NULL,
    [Less_Work]                     VARCHAR (20)    NULL,
    [More_Work]                     VARCHAR (20)    NULL,
    [Reason]                        VARCHAR (1000)  NULL,
    [Other_Reason]                  VARCHAR (1000)  NULL,
    [AB_LEAVE]                      VARCHAR (MAX)   NULL,
    [Late_In_Sec]                   NUMERIC (18)    NULL,
    [Late_In_count]                 NUMERIC (18)    NULL,
    [Early_Out_sec]                 NUMERIC (18)    NULL,
    [Early_Out_Count]               NUMERIC (18)    NULL,
    [Total_Less_work_Sec]           NUMERIC (18)    NULL,
    [Shift_St_Datetime]             DATETIME        NULL,
    [Shift_en_Datetime]             DATETIME        NULL,
    [Working_Sec_AfterShift]        NUMERIC (18)    NULL,
    [Working_AfterShift_Count]      NUMERIC (18)    NULL,
    [Leave_Reason]                  VARCHAR (1000)  NULL,
    [Inout_Reason]                  VARCHAR (1000)  NULL,
    [SysDate]                       DATETIME        NULL,
    [Total_Work_Sec]                NUMERIC (18)    NULL,
    [Late_Out_Sec]                  NUMERIC (18)    NULL,
    [Early_In_sec]                  NUMERIC (18)    NULL,
    [Total_More_work_Sec]           NUMERIC (18)    NULL,
    [Is_OT_Applicable]              TINYINT         NULL,
    [Monthly_Deficit_Adjust_OT_Hrs] TINYINT         NULL,
    [Late_Comm_sec]                 NUMERIC (18)    NULL,
    [Branch_Id]                     NUMERIC (18)    NULL,
    [P_days]                        NUMERIC (5, 2)  NULL,
    [vertical_Id]                   NUMERIC (18)    NULL,
    [subvertical_Id]                NUMERIC (18)    NULL,
    [Leave_FromDate]                DATETIME        NULL,
    [Leave_ToDate]                  DATETIME        NULL,
    [Break_Start_Time]              DATETIME        NULL,
    [Break_End_Time]                DATETIME        NULL,
    [Break_Duration]                VARCHAR (10)    NULL,
    [Rest_Duration_Sec]             NUMERIC (18)    NULL,
    [Rest_Duration]                 VARCHAR (10)    NULL,
    [A_days]                        NUMERIC (18, 2) NULL,
    [Leave_Days]                    NUMERIC (18, 2) NULL,
    [WeekOff_Days]                  NUMERIC (18, 2) NULL,
    [Temp_LvDays]                   NUMERIC (18, 2) NULL,
    [Emp_full_Name]                 VARCHAR (250)   NULL,
    [Alpha_Emp_Code]                VARCHAR (50)    NULL,
    [Emp_Code]                      NUMERIC (18)    NOT NULL,
    [Grd_Name]                      VARCHAR (100)   NOT NULL,
    [Shift_name]                    VARCHAR (100)   NULL,
    [dept_name]                     VARCHAR (100)   NULL,
    [Type_Name]                     VARCHAR (100)   NULL,
    [Desig_Name]                    VARCHAR (100)   NULL,
    [CMP_NAME]                      VARCHAR (100)   NOT NULL,
    [CMP_ADDRESS]                   VARCHAR (250)   NOT NULL,
    [P_From_date]                   VARCHAR (19)    NOT NULL,
    [P_To_Date]                     VARCHAR (19)    NOT NULL,
    [Shift_Start_Time]              VARCHAR (10)    NULL,
    [Shift_END_Time]                VARCHAR (10)    NULL,
    [Actual_In_Time]                VARCHAR (10)    NULL,
    [Actual_Out_Time]               VARCHAR (10)    NULL,
    [On_Date]                       VARCHAR (10)    NULL,
    [Leave_Footer]                  VARCHAR (1499)  NOT NULL,
    [Branch_Name]                   VARCHAR (100)   NULL,
    [Comp_Name]                     VARCHAR (200)   NULL,
    [Branch_Address]                VARCHAR (250)   NULL,
    [Desig_Dis_No]                  NUMERIC (18)    NULL,
    [Vertical_Name]                 VARCHAR (100)   NULL,
    [SubVertical_Name]              VARCHAR (100)   NULL,
    [Designation]                   VARCHAR (100)   NULL,
    [Department]                    VARCHAR (100)   NULL,
    [Business_Unit]                 VARCHAR (100)   NULL,
    [Cost_center]                   VARCHAR (MAX)   NULL,
    [Function]                      VARCHAR (MAX)   NULL,
    [Manager_Details]               VARCHAR (MAX)   NULL,
    [HOD_Details]                   VARCHAR (MAX)   NULL,
    [Brnch_NAME]                    VARCHAR (100)   NULL,
    [Imm_Supervisor]                VARCHAR (250)   NULL
);

