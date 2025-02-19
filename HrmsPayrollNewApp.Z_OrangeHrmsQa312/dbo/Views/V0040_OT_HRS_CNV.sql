Create View V0040_OT_HRS_CNV
As
select Effective_Date,Limit,Cmp_ID from T0040_OT_HRS_CNV
group by Effective_Date,Limit,Cmp_ID 
