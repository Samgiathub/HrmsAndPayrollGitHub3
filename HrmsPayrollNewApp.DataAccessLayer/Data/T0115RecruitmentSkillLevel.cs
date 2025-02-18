using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115RecruitmentSkillLevel
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RecAppId { get; set; }

    public decimal SkillId { get; set; }

    public bool Mandatory { get; set; }

    public bool Secondary { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0052HrmsRecruitmentRequestApproval RecApp { get; set; } = null!;
}
