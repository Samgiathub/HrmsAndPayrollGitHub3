CREATE TABLE [dbo].[KPMS_T0115_Module_Rights] (
    [Cmp_Id]           INT      NULL,
    [Module_Rights_Id] INT      IDENTITY (1, 1) NOT NULL,
    [Emp_Role_Id]      INT      NULL,
    [Module_Id]        INT      NULL,
    [IsActive]         BIT      CONSTRAINT [DF_KPMS_T0115_Module_Rights_IsActive] DEFAULT ((0)) NULL,
    [CreatedBy_ID]     INT      NULL,
    [Created_Date]     DATETIME CONSTRAINT [DF_KPMS_T0115_Module_Rights_Created_Date] DEFAULT (getdate()) NULL,
    [Modify_Date]      DATETIME NULL,
    CONSTRAINT [PK_KPMS_T0115_Module_Rights] PRIMARY KEY CLUSTERED ([Module_Rights_Id] ASC)
);

