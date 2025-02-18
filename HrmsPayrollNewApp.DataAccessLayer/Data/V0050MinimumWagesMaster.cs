using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050MinimumWagesMaster
{
    public int WagesId { get; set; }

    public int CmpId { get; set; }

    public string? SkillName { get; set; }

    public string StateName { get; set; } = null!;

    public decimal? WagesValue { get; set; }

    public string? EffectiveDate { get; set; }

    public int StateId { get; set; }

    public int SkillTypeId { get; set; }

    public DateTime? EffDate { get; set; }
}
