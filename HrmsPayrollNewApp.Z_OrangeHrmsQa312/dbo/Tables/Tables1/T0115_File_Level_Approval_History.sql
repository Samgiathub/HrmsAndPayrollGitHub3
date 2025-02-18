﻿CREATE TABLE [dbo].[T0115_File_Level_Approval_History] (
    [FH_ID]                INT            IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]               NUMERIC (18)   NOT NULL,
    [File_App_Id]          NUMERIC (18)   NULL,
    [File_Apr_Id]          NUMERIC (18)   NULL,
    [Emp_Id]               NUMERIC (18)   NOT NULL,
    [H_File_Number]        VARCHAR (50)   NOT NULL,
    [H_F_StatusId]         INT            NULL,
    [H_F_TypeId]           NUMERIC (18)   NULL,
    [H_Subject]            VARCHAR (500)  NULL,
    [H_Description]        VARCHAR (MAX)  NULL,
    [H_S_Emp_Id]           NUMERIC (18)   NULL,
    [H_Process_Date]       DATETIME       NULL,
    [H_File_App_Doc]       NVARCHAR (MAX) NULL,
    [Rpt_Level]            TINYINT        NULL,
    [CreatedDate]          DATETIME       NULL,
    [User ID]              VARCHAR (MAX)  NULL,
    [H_Trans_Type]         VARCHAR (50)   NULL,
    [H_Tran_Id]            NUMERIC (18)   NULL,
    [Tbl_Type]             VARCHAR (MAX)  NULL,
    [H_Approval_Comments]  VARCHAR (500)  NULL,
    [H_Forward_Emp_Id]     NUMERIC (18)   NULL,
    [H_Submit_Emp_Id]      NUMERIC (18)   NULL,
    [H_Review_Emp_Id]      NUMERIC (18)   NULL,
    [H_Reviewed_by_Emp_Id] NUMERIC (18)   NULL,
    [File_Type_Number]     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0115_File_Level_Approval_History] PRIMARY KEY CLUSTERED ([FH_ID] ASC) WITH (FILLFACTOR = 95)
);

