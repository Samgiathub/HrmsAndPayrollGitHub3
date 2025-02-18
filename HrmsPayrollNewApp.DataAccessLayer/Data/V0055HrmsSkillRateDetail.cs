using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0055HrmsSkillRateDetail
{
    public decimal SkillDetailId { get; set; }

    public decimal? SkillId { get; set; }

    public decimal? SkillDId { get; set; }

    public decimal? SkillActualRate { get; set; }

    public decimal? SkillRRateMin { get; set; }

    public decimal? SkillRRateMax { get; set; }

    public string? SkillName { get; set; }
}
