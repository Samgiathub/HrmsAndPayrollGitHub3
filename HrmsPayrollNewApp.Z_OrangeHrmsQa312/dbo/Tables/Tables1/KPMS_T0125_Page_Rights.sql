CREATE TABLE [dbo].[KPMS_T0125_Page_Rights] (
    [Cmp_Id]         INT      NULL,
    [Page_Rights_Id] INT      IDENTITY (1, 1) NOT NULL,
    [Emp_Role_Id]    INT      NULL,
    [Module_Id]      INT      NULL,
    [Page_Id]        INT      NULL,
    [Is_Save]        BIT      NULL,
    [Is_Edit]        BIT      NULL,
    [Is_Delete]      BIT      NULL,
    [Is_View]        BIT      NULL,
    [IsActive]       BIT      NULL,
    [CreatedBy_ID]   INT      NULL,
    [Created_Date]   DATETIME CONSTRAINT [DF_KPMS_T0125_Page_Rights_Created_Date] DEFAULT (getdate()) NULL,
    [Modify_Date]    DATETIME NULL,
    CONSTRAINT [PK_KPMS_T0125_Page_Rights] PRIMARY KEY CLUSTERED ([Page_Rights_Id] ASC)
);

