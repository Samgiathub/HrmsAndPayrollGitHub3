CREATE TABLE [dbo].[T0055_INCENTIVE_SCHEME_PARA] (
    [Scheme_ID]  NUMERIC (18)    NOT NULL,
    [Para_ID]    NUMERIC (18)    NOT NULL,
    [Row_ID]     NUMERIC (18)    NOT NULL,
    [Para_Name]  VARCHAR (MAX)   NOT NULL,
    [From_Slab]  NUMERIC (18, 2) NOT NULL,
    [To_Slab]    NUMERIC (18, 2) NOT NULL,
    [Slab_Value] NUMERIC (18, 2) NOT NULL,
    [P_Formula]  NVARCHAR (MAX)  NULL,
    [Para_For]   VARCHAR (50)    NULL
);

