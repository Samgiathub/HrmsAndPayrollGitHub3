using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055JobSkill
{
    public decimal JobSkillId { get; set; }

    public decimal CmpId { get; set; }

    public decimal JobId { get; set; }

    public decimal SkillId { get; set; }

    public bool Mandatory { get; set; }

    public bool Secondary { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0050JobDescriptionMaster Job { get; set; } = null!;

    public virtual T0040SkillMaster Skill { get; set; } = null!;
}
