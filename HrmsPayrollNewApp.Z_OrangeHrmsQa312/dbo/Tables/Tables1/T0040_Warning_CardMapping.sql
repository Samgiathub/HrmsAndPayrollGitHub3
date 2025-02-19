CREATE TABLE [dbo].[T0040_Warning_CardMapping] (
    [Cmp_Id]        NUMERIC (18)  NOT NULL,
    [Level_Tran_Id] NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Level_Id]      NUMERIC (18)  NOT NULL,
    [Level_Name]    NVARCHAR (50) NOT NULL,
    [No_Of_Card]    NUMERIC (18)  CONSTRAINT [DF_T0040_Warning_CardMapping_No_Of_Card] DEFAULT ((0)) NOT NULL,
    [Card_Color]    NVARCHAR (50) NOT NULL,
    [Login_Id]      NUMERIC (18)  NOT NULL,
    [System_date]   DATETIME      NOT NULL,
    CONSTRAINT [PK_T0040_Warning_CardMapping] PRIMARY KEY CLUSTERED ([Level_Tran_Id] ASC),
    CONSTRAINT [FK_T0040_Warning_CardMapping_T0040_Warning_CardMapping] FOREIGN KEY ([Level_Tran_Id]) REFERENCES [dbo].[T0040_Warning_CardMapping] ([Level_Tran_Id])
);

