using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0010GetMaxReportingManager
{
    public decimal EmpId { get; set; }

    public decimal? REmpId { get; set; }

    public DateTime? EffectDate { get; set; }
}
