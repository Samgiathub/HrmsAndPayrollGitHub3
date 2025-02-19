


/*	WHERE A.Leave_Approval_ID=3277 AND CAN.Emp_Id IS NULL*/
CREATE VIEW [dbo].[V0150_COMPOFF_LEAVE_DATE]
AS
	SELECT DISTINCT LT.Leave_Tran_ID,A.Emp_ID,D.From_Date, LT.For_Date, LT.CompOff_Credit, LT.CompOff_Debit, LT.CompOff_Balance, LT.CompOff_Used ,A.Leave_Approval_ID,LT.Leave_ID,1 as Selected --Added by Sumit to get selected default in Panel COPH on 30092016  --Added By Jaina 9-12-2015 Leave_id
	FROM T0130_LEAVE_APPROVAL_DETAIL D WITH (NOLOCK) INNER JOIN T0120_LEAVE_APPROVAL A WITH (NOLOCK)  ON D.Leave_Approval_ID=A.Leave_Approval_ID 
		LEFT OUTER JOIN T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  ON  CHARINDEX(replace(CONVERT(varchar(11), LT.FOR_DATE, 106), ' ', '-'), D.Leave_CompOff_Dates) > 0  AND A.Emp_ID=LT.Emp_ID
		--LEFT OUTER JOIN T0140_LEAVE_TRANSACTION LT1 ON (LT1.For_Date BETWEEN D.From_Date AND D.To_Date) AND LT1.Emp_ID=A.Emp_ID
		LEFT OUTER JOIN T0150_LEAVE_CANCELLATION CAN WITH (NOLOCK)  ON LT.Emp_ID=CAN.Emp_Id AND LT.For_Date=CAN.Compoff_Work_Date
	--	WHERE A.Leave_Approval_ID=3277 AND CAN.Emp_Id IS NULL




