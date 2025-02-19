


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 19/04/2019 
-- Description:	For Insert Early Mark Slab in General Setting -- For Kataria
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_GENERAL_EARLYMARK_SLAB]
	@TRANS_ID NUMERIC(18,0),
    @CMP_ID NUMERIC(18,0),
    @FROM_MIN NUMERIC(18,0),
    @TO_MIN NUMERIC(18,0),
    @DEDUCTION NUMERIC(18,2),
    @DEDUCTION_TYPE Varchar(20),
    @GEN_ID NUMERIC(18,0),
    @tran_type Char(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	if Isnull(@DEDUCTION_TYPE,'') <> '' 
		Begin
			INSERT INTO T0050_GENERAL_EARLYMARK_SLAB Values(@CMP_ID,@FROM_MIN,@TO_MIN,@DEDUCTION,@DEDUCTION_TYPE,@GEN_ID)
		End
END

