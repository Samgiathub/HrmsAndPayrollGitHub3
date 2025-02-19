CREATE TABLE [dbo].[T0150_EMP_INOUT_RECORD_Deleted] (
    [IO_Tran_Id]          NUMERIC (18)  NOT NULL,
    [Emp_ID]              NUMERIC (18)  NOT NULL,
    [Cmp_ID]              NUMERIC (18)  NOT NULL,
    [For_Date]            DATETIME      NOT NULL,
    [In_Time]             DATETIME      NULL,
    [Out_Time]            DATETIME      NULL,
    [Duration]            VARCHAR (10)  NULL,
    [Reason]              VARCHAR (100) NULL,
    [Ip_Address]          VARCHAR (50)  NOT NULL,
    [In_Date_Time]        DATETIME      NULL,
    [Out_Date_Time]       DATETIME      NULL,
    [Skip_Count]          NUMERIC (18)  NULL,
    [Late_Calc_Not_App]   NUMERIC (1)   CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Deleted_Late_Calc_Not_App] DEFAULT ((0)) NULL,
    [Chk_By_Superior]     TINYINT       CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Deleted_Chk_By_Superior] DEFAULT ((0)) NULL,
    [Sup_Comment]         VARCHAR (100) NULL,
    [Half_Full_day]       VARCHAR (20)  NULL,
    [Is_Cancel_Late_In]   TINYINT       CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Deleted_Is_Cancel_Late_In] DEFAULT ((0)) NULL,
    [Is_Cancel_Early_Out] TINYINT       CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Deleted_Is_Cancel_Early_Out] DEFAULT ((0)) NULL,
    [Is_Default_In]       TINYINT       CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Deleted_Is_Default_In] DEFAULT ((0)) NULL,
    [Is_Default_Out]      TINYINT       CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Deleted_Is_Default_Out] DEFAULT ((0)) NULL
);

