


CREATE VIEW [dbo].[V0050_Get_Emp_Claim_Scheme]
AS

select distinct Effective_Date,ES.Scheme_ID,SD.Is_Fwd_Leave_Rej,ES.Cmp_ID,ES.Type,ES.Emp_ID from dbo.T0095_EMP_SCHEME ES WITH (NOLOCK)
inner join (
			select MAX(effective_Date) as EfctDate,Emp_ID
			from T0095_EMP_SCHEME WITH (NOLOCK) 
			where Type='Claim'
			group by Emp_ID
			)
ES2 on ES.Effective_Date=ES2.EfctDate and ES.Emp_ID=ES2.Emp_ID --and ES.Scheme_ID=ES2.Scheme_ID
inner join T0050_Scheme_Detail sd WITH (NOLOCK) ON sd.Scheme_Id=ES.Scheme_ID and SD.Cmp_Id=ES.Cmp_ID



