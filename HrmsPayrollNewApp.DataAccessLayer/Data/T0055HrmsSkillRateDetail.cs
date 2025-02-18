using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055HrmsSkillRateDetail
{
    public decimal SkillDetailId { get; set; }

    public decimal? SkillId { get; set; }

    public decimal? SkillDId { get; set; }

    public decimal? SkillActualRate { get; set; }

    public decimal? SkillRRateMin { get; set; }

    public decimal? SkillRRateMax { get; set; }

    public virtual T0040SkillMaster? Skill { get; set; }

    public virtual T0050HrmsSkillRateSetting? SkillD { get; set; }
}
