using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0020SkillMaster
{
    public decimal SkillId { get; set; }

    public decimal CmpId { get; set; }

    public string SkillName { get; set; } = null!;

    public string Description { get; set; } = null!;

    public decimal Year1 { get; set; }
}
