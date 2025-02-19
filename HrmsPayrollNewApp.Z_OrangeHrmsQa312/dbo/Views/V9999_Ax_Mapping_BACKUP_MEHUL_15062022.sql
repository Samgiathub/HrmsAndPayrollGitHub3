


CREATE VIEW [dbo].[V9999_Ax_Mapping_BACKUP_MEHUL_15062022]
AS
SELECT        Tran_Id, T.Cmp_id, Head_Name, Account, Narration, Month_Year, lastUpdated, Ad_id, Sorting_no, Type, Loan_id, Vender_Code, Bank_Id, 
			  Other_Account, Claim_ID, Is_Highlight, BackColor, ForeColor, T.Center_ID, Segment_ID,C.Center_Name
FROM            dbo.T9999_Ax_Mapping T WITH (NOLOCK) left join
				T0040_COST_CENTER_MASTER C WITH (NOLOCK)  on C.Center_ID = T.Center_ID
