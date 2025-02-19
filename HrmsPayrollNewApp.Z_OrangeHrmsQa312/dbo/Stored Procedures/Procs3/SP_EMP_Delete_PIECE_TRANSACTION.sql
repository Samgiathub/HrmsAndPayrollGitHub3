--Exec SP_EMP_Delete_PIECE_TRANSACTION 11,''
CREATE PROCEDURE [dbo].[SP_EMP_Delete_PIECE_TRANSACTION]
	@PieceTrans_id numeric(18,0) = 0
	,@Result Varchar(200)  Output
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
BEGIN	

	If ((Select count(1) from T0050_Piece_Transaction where Piece_Tran_ID = @PieceTrans_id ) > 0)
	BEGIN
		DELETE FROM T0050_Piece_Transaction where Piece_Tran_ID = @PieceTrans_id
		Set @Result = 'Records Delete Successfully.' 
		Select @Result as Result
	END
END

