using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsEmpSkillSetting
{
    public decimal EmpSkillId { get; set; }

    public decimal SkillRId { get; set; }

    public decimal EmpId { get; set; }

    public decimal SkillId { get; set; }

    public decimal SkilllRateGiven { get; set; }

    public decimal? SkillActualRate { get; set; }

    public decimal? SkillRateEmployee { get; set; }

    public decimal? SkillRateSuperior { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040SkillMaster Skill { get; set; } = null!;

    public virtual T0055HrmsEmpSkillDetail SkillR { get; set; } = null!;
}
