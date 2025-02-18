using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050MinimumWagesMasterNew
{
    public string StateName { get; set; } = null!;

    public string? EffectiveDate { get; set; }

    public int StateId { get; set; }

    public DateTime? EffDate { get; set; }

    public int CmpId { get; set; }
}
