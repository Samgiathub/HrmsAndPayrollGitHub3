using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055RecruitmentSkill
{
    public decimal RecSkillId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RecReqId { get; set; }

    public decimal SkillId { get; set; }

    public bool Mandatory { get; set; }

    public bool Secondary { get; set; }

    public string Comments { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0050HrmsRecruitmentRequest RecReq { get; set; } = null!;

    public virtual T0040SkillMaster Skill { get; set; } = null!;
}
