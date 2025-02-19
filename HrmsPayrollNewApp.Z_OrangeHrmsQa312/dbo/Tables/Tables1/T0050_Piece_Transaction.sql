CREATE TABLE [dbo].[T0050_Piece_Transaction] (
    [Piece_Tran_ID]     NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Emp_ID]            NUMERIC (18) NULL,
    [Cmp_ID]            NUMERIC (18) NULL,
    [Product_ID]        NUMERIC (18) NULL,
    [SubProduct_ID]     NUMERIC (18) NULL,
    [Piece_Trans_Count] NUMERIC (18) NULL,
    [Piece_Trans_Date]  DATETIME     NULL,
    CONSTRAINT [PK_T0050_Piece_Transaction] PRIMARY KEY CLUSTERED ([Piece_Tran_ID] ASC)
);

