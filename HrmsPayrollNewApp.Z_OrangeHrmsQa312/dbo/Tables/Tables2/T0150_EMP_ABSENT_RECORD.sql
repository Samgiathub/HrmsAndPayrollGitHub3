﻿CREATE TABLE [dbo].[T0150_EMP_ABSENT_RECORD] (
    [Emp_Id]            INT            NULL,
    [Cmp_ID]            INT            NULL,
    [For_Date]          DATETIME       NULL,
    [Status]            CHAR (1)       NULL,
    [Leave_Count]       FLOAT (53)     NULL,
    [WO_HO]             FLOAT (53)     NULL,
    [Status_2]          CHAR (1)       NULL,
    [Row_ID]            INT            NULL,
    [WO_HO_Day]         FLOAT (53)     NULL,
    [P_days]            FLOAT (53)     NULL,
    [A_days]            FLOAT (53)     NULL,
    [Join_Date]         DATETIME       NULL,
    [Left_Date]         DATETIME       NULL,
    [GatePass_Days]     FLOAT (53)     NULL,
    [Late_deduct_Days]  FLOAT (53)     NULL,
    [Early_deduct_Days] FLOAT (53)     NULL,
    [shift_id]          INT            NULL,
    [Emp_code]          NVARCHAR (50)  NULL,
    [Emp_Full_Name]     NVARCHAR (100) NULL,
    [Branch_Address]    NVARCHAR (255) NULL,
    [comp_name]         NVARCHAR (255) NULL,
    [Branch_Name]       NVARCHAR (255) NULL,
    [Dept_Name]         NVARCHAR (255) NULL,
    [Grd_Name]          NVARCHAR (255) NULL,
    [Desig_Name]        NVARCHAR (255) NULL,
    [P_From_date]       DATETIME       NULL,
    [P_To_Date]         DATETIME       NULL,
    [BRANCH_ID]         INT            NULL,
    [Shift_Name]        NVARCHAR (100) NULL,
    [cmp_name]          NVARCHAR (255) NULL,
    [cmp_address]       NVARCHAR (255) NULL,
    [Mobile_No]         NVARCHAR (20)  NULL,
    [Emp_First_Name]    NVARCHAR (100) NULL,
    [Type_Name]         NVARCHAR (50)  NULL,
    [Reporting_Manager] NVARCHAR (100) NULL,
    [Vertical_Name]     NVARCHAR (100) NULL,
    [SubVertical_Name]  NVARCHAR (100) NULL
);

