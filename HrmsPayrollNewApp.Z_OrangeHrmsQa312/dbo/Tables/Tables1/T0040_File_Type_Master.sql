CREATE TABLE [dbo].[T0040_File_Type_Master] (
    [F_TypeID]             INT            NOT NULL,
    [TypeCode]             NVARCHAR (MAX) NULL,
    [TypeTitle]            NVARCHAR (MAX) NOT NULL,
    [TypeCDTM]             DATETIME       NULL,
    [TypeUDTM]             DATETIME       NULL,
    [TypeLog]              NVARCHAR (MAX) NULL,
    [Is_Active]            INT            DEFAULT ((1)) NULL,
    [Cmp_ID]               INT            NULL,
    [File_Type_Number]     NVARCHAR (MAX) NULL,
    [Created_By]           VARCHAR (MAX)  NULL,
    [File_Type_Start_Date] DATETIME       NULL,
    [File_Type_End_Date]   DATETIME       NULL,
    CONSTRAINT [PK_T0040_File_Level_Master] PRIMARY KEY CLUSTERED ([F_TypeID] ASC) WITH (FILLFACTOR = 80)
);

